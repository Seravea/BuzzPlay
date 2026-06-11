//
//  MPCTransport.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 10/11/2025.
//

import Foundation
import MultipeerConnectivity

enum MPCRole {
    case master
    case team
}


final class MPCService: NSObject {
    //MARK: MPC Session datas
    static let serviceTypeID = "buzzplay-game"
    /// Encodeur/décodeur JSON partagés — évite une allocation par message MPC
    /// (10-20 messages/s en pic : heartbeat, broadcasts d'état, buzz).
    static let jsonEncoder = JSONEncoder()
    static let jsonDecoder = JSONDecoder()
    /// Nom du peer Master (source unique). Permet aux Players de distinguer le Master
    /// des autres Players dans le maillage MCSession (#7b).
    static let masterPeerName = "Master"
    private let role: MPCRole
    private let serviceType = MPCService.serviceTypeID
    private let myPeerID: MCPeerID
    private let session: MCSession
    private var invitedPeers = Set<String>()
    
    //MARK: MPC for Master
    private var advertiser: MCNearbyServiceAdvertiser?
    
    //MARK: MPC for Team
    private var browser: MCNearbyServiceBrowser?
    
    
    //MARK: Callbacks for ViewModel Messages
    var onPeerConnected: ((MCPeerID) -> Void)?
    var onPeerDisconnected: ((MCPeerID) -> Void)?
    var onMessage: ((Data, MCPeerID) -> Void)?
    
    //MARK: class init()
    init(peerName: String, role: MPCRole) {
        self.role = role
        // Réutilise un MCPeerID persisté par nom (recommandé Apple). Après un kill+relaunch,
        // le device revient avec le MÊME MCPeerID → MPC le reconnaît comme le même peer au
        // lieu de créer un doublon → supprime le flapping de reconnexion (#flapping).
        self.myPeerID = MPCService.persistedPeerID(for: peerName)
        self.session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)

        super.init()
        session.delegate = self
    }

    /// Charge (ou crée puis persiste) un MCPeerID stable pour un nom donné.
    /// Garantit qu'un même device/nom réutilise le même MCPeerID entre deux lancements.
    private static func persistedPeerID(for name: String) -> MCPeerID {
        let key = "buzzplay.mpc.peerid.\(name)"
        let ud = UserDefaults.standard
        if let data = ud.data(forKey: key),
           let peer = try? NSKeyedUnarchiver.unarchivedObject(ofClass: MCPeerID.self, from: data) {
            return peer
        }
        let peer = MCPeerID(displayName: name)
        if let data = try? NSKeyedArchiver.archivedData(withRootObject: peer, requiringSecureCoding: true) {
            ud.set(data, forKey: key)
        }
        return peer
    }

}

//MARK: Local network permission priming (#R1 / #A1)
extension MPCService {
    /// Browser éphémère retenu le temps de déclencher la popup de permission.
    private static var permissionPrimerBrowser: MCNearbyServiceBrowser?

    /// Déclenche la popup iOS "réseau local" SANS rejoindre de session.
    /// Crée un browser qui ne fait QUE scanner : aucun delegate → aucune invitation,
    /// aucune MCSession, aucun peer fantôme côté Master. Le simple `startBrowsingForPeers`
    /// suffit à déclencher la permission. Le browser est arrêté après 3s.
    @MainActor
    static func primeLocalNetworkPermission() {
        guard permissionPrimerBrowser == nil else { return }
        let primerPeer = MCPeerID(displayName: "primer")
        let browser = MCNearbyServiceBrowser(peer: primerPeer, serviceType: serviceTypeID)
        // Pas de delegate volontairement : on ne réagit à aucun peer trouvé → aucune invitation.
        browser.startBrowsingForPeers()
        permissionPrimerBrowser = browser
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            permissionPrimerBrowser?.stopBrowsingForPeers()
            permissionPrimerBrowser = nil
        }
    }
}

//MARK: Advertiser Master
extension MPCService {
    //MARK: Master send present call
    func startHostingIfNeeded() {
        guard role == .master else { return }

        advertiser = MCNearbyServiceAdvertiser(
            peer: myPeerID,
            discoveryInfo: ["role": "master"],
            serviceType: serviceType
        )
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()
        print("OK MPC: hosting(MASTER) started as \(myPeerID.displayName)")
    }
    
    //MARK: Master stop advertise
    func stopHosting() {
        advertiser?.stopAdvertisingPeer()
        advertiser = nil
        session.disconnect()
    }

    //MARK: Player leave — coupe le browsing et la session (sur "Quitter" / Master parti)
    func leaveAsPlayer() {
        guard role == .team else { return }
        browser?.stopBrowsingForPeers()
        browser = nil
        invitedPeers.removeAll()
        session.disconnect()
    }
    
    
    
    //MARK: function to send messages to Browsers
    func sendBuzzLock(player: Player) {
        let payload = BuzzLockPayload(playerID: player.id, playerName: player.name)
        sendMessage(.buzzLock(payload))
//        guard !session.connectedPeers.isEmpty else {
//            print("ERREUR MPC: no peer connected, can't send BUZZ LOCK")
//            return
//        }
//
//        let payload = BuzzLockPayload(teamID: team.id, teamName: team.name)
//
//        do {
//            let data = try JSONEncoder().encode(payload)
//            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
//            print("MPC sent BUZZ LOCK for teamId \(team.id)")
//        } catch {
//            print("MPC failed to send BUZZ LOCK: \(error)")
//        }
    }
    
    
    func sendBuzzUnlock() {
        sendMessage(.buzzUnlock)
//        guard !session.connectedPeers.isEmpty else { return }
//
//        do {
//            let data = try JSONEncoder().encode(payload)
//            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
//            print("MPC sent BUZZ UNLOCK")
//        } catch {
//            print("MPC failed to send BUZZ UNLOCK: \(error)")
//        }
    }
    
}







//MARK: Browser Player/Team
extension MPCService {
    func startBrowsingIfNeeded() {
        guard role == .team else { return }

        browser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: serviceType)
        browser?.delegate = self
        browser?.startBrowsingForPeers()
        print("OK MPC: browsing(TEAM) started as \(myPeerID.displayName)")
    }

    // Relance un scan fresh — utile après déconnexion ou retour foreground.
    func restartBrowsing() {
        guard role == .team else { return }
        invitedPeers.removeAll()
        browser?.stopBrowsingForPeers()
        browser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: serviceType)
        browser?.delegate = self
        browser?.startBrowsingForPeers()
        print("🔄 MPC: browsing restarted for \(myPeerID.displayName)")
    }
    
   //send player to Hosting
    func sendPlayer(_ player: Player) {
        print("PLAYER: sending playerJoin for \(player.name)")
            sendMessage(.playerJoin(player))
    }
    
    
    //MARK: function to send buzz to Master
    func sendBuzz(player: Player) {
        let payload = BuzzPayload(playerID: player.id)
        sendMessage(.buzz(payload))
//            guard !session.connectedPeers.isEmpty else {
//                print("ERREUR MPC: no peer connected, can't send BUZZ")
//                return
//            }
//
//        let payload = BuzzPayload(teamID: team.id)
//
//            do {
//                let data = try JSONEncoder().encode(payload)
//                try session.send(data, toPeers: session.connectedPeers, with: .reliable)
//                print("MPC sent BUZZ from team \(team.name)")
//            } catch {
//                print("MPC failed to send BUZZ: \(error)")
//            }
        }
}





//MARK: MPC Delegate

extension MPCService: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        // Callbacks appelés depuis le thread interne MPC — les callers wrappent dans Task { @MainActor }
        switch state {
        case .connected:
            print("OK MPC: connected to : \(peerID.displayName)")
            onPeerConnected?(peerID)
        case .notConnected:
            print("PAS OK MPC: disconnected from \(peerID.displayName)")
            onPeerDisconnected?(peerID)
        case .connecting:
            print("LOAD MPC: is connecting to \(peerID.displayName)")
        @unknown default:
            break
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("MPC received \(data.count) bytes from \(peerID.displayName)")
        onMessage?(data, peerID)
    }
    
    func session(_ session: MCSession,
                     didReceive stream: InputStream,
                     withName streamName: String,
                     fromPeer peerID: MCPeerID) {}

        func session(_ session: MCSession,
                     didStartReceivingResourceWithName resourceName: String,
                     fromPeer peerID: MCPeerID,
                     with progress: Progress) {}

        func session(_ session: MCSession,
                     didFinishReceivingResourceWithName resourceName: String,
                     fromPeer peerID: MCPeerID,
                     at localURL: URL?,
                     withError error: Error?) {}
}


//MARK: Advertiser Delegate
extension MPCService: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser,
                    didReceiveInvitationFromPeer peerID: MCPeerID,
                    withContext context: Data?,
                    invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("📨 MPC: invitation from \(peerID.displayName)")
        invitationHandler(true, session) // on accepte toujours pour l'instant
    }
}


//MARK: Browser Delegate
extension MPCService: MCNearbyServiceBrowserDelegate {

    func browser(_ browser: MCNearbyServiceBrowser,
                 foundPeer peerID: MCPeerID,
                 withDiscoveryInfo info: [String : String]?) {
        guard role == .team else { return }
        let name = peerID.displayName
        let peerRole = info?["role"] ?? "unknown"

        guard peerRole == "master" else {
            print("⚠️ MPC: ignoring non-master peer \(name) (role=\(peerRole))")
            return
        }

        // Si déjà connecté, ignorer
        if session.connectedPeers.contains(where: { $0.displayName == name }) {
            print("⚠️ MPC: \(name) already connected, ignoring")
            return
        }

        // Si dans invitedPeers mais pas connecté → invitation précédente expirée, réinviter
        if invitedPeers.contains(name) {
            print("⚠️ MPC: \(name) was in invitedPeers but not connected — retrying invite")
            invitedPeers.remove(name)
        }

        invitedPeers.insert(name)
        print("👀 MPC: found master \(name), inviting…")
        // #C1 — timeout allongé à 30s pour les environnements Wi-Fi lents ou encombrés
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 30)
    }

        func browser(_ browser: MCNearbyServiceBrowser,
                     lostPeer peerID: MCPeerID) {
            invitedPeers.remove(peerID.displayName)
            print("❌ MPC: lost peer \(peerID.displayName)")
        }
}







//MARK: MCPSendMessage
extension MPCService {
    func sendMessage(_ message: MPCMessage) {
        guard !session.connectedPeers.isEmpty else {
            print("MPC: no connected peers, can't send \(message)")
            return
        }

        do {
            let data = try Self.jsonEncoder.encode(message)
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            let mpcError = MPCError.sendFailed(underlying: error)
            print("MPC error: \(mpcError), underlying: \(error)")
        }
    }
    
    /// Envoie un message à UN peer précis (par MCPeerID). Utilisé quand on n'a pas l'objet
    /// Player mais seulement le peer (ex : auto-heal zombie sur réception d'un .pong).
    func sendMessage(_ message: MPCMessage, to peer: MCPeerID) {
        guard session.connectedPeers.contains(peer) else {
            print("MPC: peer \(peer.displayName) not connected, can't send \(message)")
            return
        }
        do {
            let data = try Self.jsonEncoder.encode(message)
            try session.send(data, toPeers: [peer], with: .reliable)
        } catch {
            let mpcError = MPCError.sendFailed(underlying: error)
            print("MPC error: \(mpcError), underlying: \(error)")
        }
    }

    func sendMessagetoOnePlayer(message: MPCMessage, player: Player) {
        let matches = session.connectedPeers.filter { $0.displayName == player.name }
        guard !matches.isEmpty else {
            print("MPC: no connected peer found for player \(player.name)")
            return
        }
        // Routage robuste : après un kill+rejoin, un peer zombie (mort) peut coexister
        // avec le peer vivant sous le même nom. On envoie à TOUS les matches : le zombie
        // ignore (il est mort), le vivant reçoit. Évite que le message parte dans le vide.
        do {
            let data = try Self.jsonEncoder.encode(message)
            try session.send(data, toPeers: matches, with: .reliable)
        } catch {
            let mpcError = MPCError.sendFailed(underlying: error)
            print("MPC error: \(mpcError), underlying: \(error)")
        }
    }
}

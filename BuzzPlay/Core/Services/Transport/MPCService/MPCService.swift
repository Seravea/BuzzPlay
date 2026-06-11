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

/// #conn-phase — phase de connexion observée côté Player, pour un feedback honnête dans
/// l'overlay d'attente : on cherche l'hôte, puis on négocie, puis c'est bon.
enum MPCConnectionPhase {
    case idle
    case searching    // browsing : aucun hôte trouvé pour l'instant
    case connecting   // hôte trouvé / invitation / négociation (reste stable pendant les retries)
    case connected
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
    /// #conn-phase — notifie la phase de connexion (Player) pour l'overlay d'attente.
    var onConnectionPhase: ((MPCConnectionPhase) -> Void)?
    
    //MARK: class init()
    init(peerName: String, role: MPCRole) {
        self.role = role
        // #reco-fix — MCPeerID FRAIS à chaque lancement (revert du #118 « MCPeerID persisté »).
        // Diagnostic device : réutiliser le même MCPeerID après un kill EMPÊCHE la reconnexion.
        // La MCSession du Master garde l'ancien pair en zombie (le timeout heartbeat est
        // appli-only, le framework n'a pas vu la déco) → quand le Player réinvite avec LE MÊME
        // MCPeerID, le framework refuse de rebrancher (« invitation reçue + acceptée mais jamais
        // connectée », remoteServiceName is nil). Un MCPeerID neuf = nouveau pair pour le Master
        // → acceptation propre. L'identité applicative reste le NOM (clé stable côté Master, #10).
        self.myPeerID = MCPeerID(displayName: peerName)
        self.session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)

        super.init()
        session.delegate = self
    }

}

//MARK: État de connexion (dérivé de la session)
extension MPCService {
    /// Vrai si un pair nommé « Master » est encore présent dans la session.
    /// #reco-master — l'identité applicative du Master est son NOM (son MCPeerID est régénéré
    /// à chaque lancement, #reco-fix). On dérive donc « connecté au Master » de la session
    /// ENTIÈRE, pas d'un MCPeerID figé → l'état survit à la chute d'un ancien pair zombie
    /// quand un Master frais (relaunch) est déjà connecté sous le même nom.
    var isMasterConnected: Bool {
        session.connectedPeers.contains { $0.displayName == Self.masterPeerName }
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
        onConnectionPhase?(.searching)
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
        onConnectionPhase?(.searching)   // lissé côté VM : ignoré si déjà en .connecting
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
            if peerID.displayName == Self.masterPeerName { onConnectionPhase?(.connected) }
            onPeerConnected?(peerID)
        case .notConnected:
            print("PAS OK MPC: disconnected from \(peerID.displayName)")
            onPeerDisconnected?(peerID)
        case .connecting:
            print("LOAD MPC: is connecting to \(peerID.displayName)")
            if peerID.displayName == Self.masterPeerName { onConnectionPhase?(.connecting) }
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

        // Si CE pair précis (même MCPeerID) est déjà connecté, ignorer.
        // #reco-master — comparaison par IDENTITÉ (MCPeerID), PAS par nom : un Master qui
        // revient après un kill a un MCPeerID FRAIS (même nom « Master »). Le filtre par nom
        // le confondait avec l'ancien pair zombie encore listé dans connectedPeers → on
        // n'invitait jamais le Master frais → Player bloqué sur « connexion perdue ».
        if session.connectedPeers.contains(peerID) {
            print("⚠️ MPC: \(name) (même pair) déjà connecté, ignoring")
            return
        }

        // Si dans invitedPeers mais pas connecté → invitation précédente expirée, réinviter
        if invitedPeers.contains(name) {
            print("⚠️ MPC: \(name) was in invitedPeers but not connected — retrying invite")
            invitedPeers.remove(name)
        }

        invitedPeers.insert(name)
        onConnectionPhase?(.connecting)
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

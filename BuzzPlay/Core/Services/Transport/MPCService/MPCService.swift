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
    case publicScreen
}


final class MPCService: NSObject {
    //MARK: MPC Session datas
    private let role: MPCRole
    private let serviceType = "buzzplay-game"
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
        self.myPeerID = MCPeerID(displayName: peerName)
        self.session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
        
        super.init()
        session.delegate = self
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
    
    
    
    //MARK: function to send messages to Browsers
    func sendBuzzLock(team: Team) {
        let payload = BuzzLockPayload(teamID: team.id, teamName: team.name)
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
        guard role == .team || role == .publicScreen else { return }

            browser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: serviceType)
            browser?.delegate = self
            browser?.startBrowsingForPeers()
            print("OK MPC: browsing(TEAM) started as \(myPeerID.displayName)")
    }
    
   //send team to Hosting
    func sendTeam(_ team: Team) {
        print("TEAM: sending teamJoin for \(team.name)")
            sendMessage(.teamJoin(team))
    }
    
    
    //MARK: function to send buzz to Master
    func sendBuzz(team: Team) {
        let payload = BuzzPayload(teamID: team.id)
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
        DispatchQueue.main.async {
            switch state {
            case .connected:
                print("OK MPC: connected to : \(peerID.displayName)")
                self.onPeerConnected?(peerID)
            case .notConnected:
                print("PAS OK MPC: disconnected from \(peerID.displayName)")
                self.onPeerDisconnected?(peerID)
            case .connecting:
                print("LOAD MPC: is connecting to \(peerID.displayName)")
            @unknown default:
                break
            }
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let text = String(data: data, encoding: .utf8) {
            print("MPC received \(text) from \(peerID.displayName)")
            DispatchQueue.main.async {
                self.onMessage?(data, peerID)
            }
        }
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

            // 👉 N'inviter QUE le Master
            guard peerRole == "master" else {
                print("⚠️ MPC: ignoring non-master peer \(name) (role=\(peerRole))")
                return
            }

            guard !invitedPeers.contains(name) else {
                print("⚠️ MPC: already invited \(name)")
                return
            }

            invitedPeers.insert(name)
            print("👀 MPC: found master \(name), inviting…")
            browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
        }

        func browser(_ browser: MCNearbyServiceBrowser,
                     lostPeer peerID: MCPeerID) {
            invitedPeers.remove(peerID.displayName)
            print("❌ MPC: lost peer \(peerID.displayName)")
        }
}



//MARK: ChooseGame func
extension MPCService {
    func sendGameAvailability(_ openGames: [GameType]) {
        
        sendMessage(.gameAvailability(openGames))
//        guard !session.connectedPeers.isEmpty else {
//            print("Erreur MPC: pas de peer connecté, can't send")
//            return
//        }
//        
//        let update = GameAvailability(openGames: openGames)
//        do {
//            let data = try JSONEncoder().encode(update)
//            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
//            print("MPC sent games List \(openGames)")
//        } catch {
//            print("MPC can't sent, there is an error: \(error)")
//        }
    }
}

//MARK: Quiz Message
extension MPCService {
    
    func sendPublicStateQuestion(_ publicState: PublicState) {
        
    }
}



//MARK: MCPSendMessage
extension MPCService {
    func sendMessage(_ message: MPCMessage) {
        do {
            let data = try JSONEncoder().encode(message)
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            let mpcError = MPCError.sendFailed(underlying: error)
            print("MPC error: \(mpcError), underlying: \(error)")
        }
    }
}

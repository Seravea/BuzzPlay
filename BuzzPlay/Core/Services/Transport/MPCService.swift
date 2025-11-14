//
//  MPCTransport.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 10/11/2025.
//

import Foundation
import MultipeerConnectivity


final class MPCService: NSObject {
    //MARK: MPC Session datas
    private let serviceType = "buzzplay-game"
    private let myPeerID: MCPeerID
    private let session: MCSession
    
    //MARK: MPC for Master
    private var advertiser: MCNearbyServiceAdvertiser?
    
    //MARK: MPC for Team
    private var browser: MCNearbyServiceBrowser?
    
    
    //MARK: Callbacks for ViewModel Messages
    var onPeerConnected: ((MCPeerID) -> Void)?
    var onPeerDisconnected: ((MCPeerID) -> Void)?
    var onMessage: ((Data, MCPeerID) -> Void)?
    
    //MARK: class init()
    override init() {
        self.myPeerID = MCPeerID(displayName: UIDevice.current.name)
        self.session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
        
        super.init()
        session.delegate = self
    }
    
}

//MARK: Advertiser Master
extension MPCService {
    //MARK: Master send present call
    func startHosting() {
        advertiser = MCNearbyServiceAdvertiser(
            peer: myPeerID,
            discoveryInfo: nil,
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
}

//MARK: Browser Player/Team
extension MPCService {
    func startBrowsing() {
        browser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: serviceType)
        browser?.delegate = self
        browser?.startBrowsingForPeers()
        print("OK MPC: browsing(TEAM) started as \(myPeerID.displayName)")
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
        print("👀 MPC: found peer \(peerID.displayName)")
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
    }

    func browser(_ browser: MCNearbyServiceBrowser,
                 lostPeer peerID: MCPeerID) {
        print("❌ MPC: lost peer \(peerID.displayName)")
    }
}

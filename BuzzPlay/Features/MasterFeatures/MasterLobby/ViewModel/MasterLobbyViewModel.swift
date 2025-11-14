//
//  MasterLobbyViewModel.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 14/11/2025.
//

import Foundation
import MultipeerConnectivity


@Observable
class MasterLobbyViewModel {
    private let gameVM: MasterFlowViewModel
    
    init(gameVM: MasterFlowViewModel) {
        self.gameVM = gameVM
    }
    
    var teams: [Team] {
        gameVM.teams
    }
    
    var connectedPeers: [MCPeerID] {
        gameVM.connectedPeers
    }
    
    
}

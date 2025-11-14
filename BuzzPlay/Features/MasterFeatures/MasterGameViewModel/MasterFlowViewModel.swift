//
//  MasterGameViewModel.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 14/11/2025.
//

import Foundation
import Observation
import MultipeerConnectivity


@Observable
final class MasterFlowViewModel: ObservableObject {
    
    var gameState: GameState = .lobby
    var connectedPeers: [MCPeerID] = []
    
    var teams: [Team] = []
    
    var isHost: Bool = false
    
    var mpcService: MPCService = MPCService()
    
    

    
    //MARK: Master's makeVM
    func makeLobbyViewModel() -> MasterLobbyViewModel {
        MasterLobbyViewModel(gameVM: self)
    }
    
    func makeChooseGameVM() -> MasterChooseGameViewModel {
        MasterChooseGameViewModel(gameVM: self)
    }
    
    func makeBlindTestMasterVM() -> BlindTestViewModel {
        BlindTestViewModel(gameVM: self)
    }
    
    
    //MARK: Master's functions for Team
    
    func addTeam(_ team: Team) {
        teams.append(team)
    }
    
    func removeTeam(_ team: Team) {
        teams.removeAll { $0.id == team.id }
    }
    
    
    //MARK: Master's functions for gameSelection
    
    var gamesOpen: [GameType] = []
    
    func selectGame(_ game: GameType) {
        gameState = .inGame(game)
    }
    
    
    
    
}



//MARK: MPC Service for MasterFlow
extension MasterFlowViewModel {
    
    func setupMPC() {
            mpcService.onPeerConnected = { [weak self] peer in
                guard let self else { return }
                self.connectedPeers.append(peer)
            }

            mpcService.onPeerDisconnected = { [weak self] peer in
                guard let self else { return }
                self.connectedPeers.removeAll { $0 == peer }
            }

            mpcService.startHosting()
        }
}

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
    
    var teams: [Team] = []
    
    var isHost: Bool = false
    
    var gamesOpen: [Game] = []
    
    var mpc: MPCService = MPCService()
    
    //MARK: Master's makeVM
    func makeLobbyViewModel() -> MasterLobbyViewModel {
        MasterLobbyViewModel(gameVM: self)
    }
    
    
    //MARK: Master's functions for Team
    
    func addTeam(_ team: Team) {
        teams.append(team)
    }
    
    func removeTeam(_ team: Team) {
        teams.removeAll { $0.id == team.id }
    }
    
    
    //MARK: Master's functions for gameSelection
    
    func openGame(_ game: Game) {
        gamesOpen.append(game)
    }
    
    
    
    
}




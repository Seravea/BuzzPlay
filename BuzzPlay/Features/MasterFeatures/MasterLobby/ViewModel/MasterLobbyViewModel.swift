//
//  MasterLobbyViewModel.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 14/11/2025.
//

import Foundation
import MultipeerConnectivity


@Observable
@MainActor
class MasterLobbyViewModel {
    private let gameVM: MasterFlowViewModel
    
    init(gameVM: MasterFlowViewModel) {
        self.gameVM = gameVM
        gameVM.setupMPC()
    }
    
    var players: [Player] {
        gameVM.players
    }

    var connectedPlayersCount: Int { gameVM.connectedPlayersCount }
    var totalPlayersCount: Int { gameVM.totalPlayersCount }

    var gameDuration: GameDuration {
        get { gameVM.gameDuration }
        set { gameVM.gameDuration = newValue }
    }
    var gameMode: GameMode {
        get { gameVM.gameMode }
        set { gameVM.gameMode = newValue }
    }
    var totalRounds: Int { gameVM.totalRounds }
    var quizRoundsTotal: Int { gameVM.quizRoundsTotal }
    var blindTestRoundsTotal: Int { gameVM.blindTestRoundsTotal }
}

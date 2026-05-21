//
//  MasterChooseGameViewModel.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 14/11/2025.
//

import Foundation
import SwiftUI

@Observable
@MainActor
class MasterChooseGameViewModel {
    private let gameVM: MasterFlowViewModel
    let coinsVM: CoinsViewModel

    init(gameVM: MasterFlowViewModel) {
        self.gameVM = gameVM
        self.coinsVM = CoinsViewModel(masterFlowVM: gameVM)
    }

    var availableGames: [GameType] = []

    var connectedPlayersCount: Int { gameVM.connectedPlayersCount }
    var totalPlayersCount: Int { gameVM.totalPlayersCount }
    var players: [Player] { gameVM.players }

    // Round progress
    var currentRound: Int { gameVM.currentRound }
    var totalRounds: Int { gameVM.totalRounds }
    var isQuizCardAvailable: Bool { gameVM.isQuizAvailable }
    var isBlindTestCardAvailable: Bool { gameVM.isBlindTestAvailable }
    
    
    //MARK: Datas en functions for views
    var allGames: [GameType] {
        [.quiz, .blindTest, .score]
    }
    
    func trackAndLaunch(_ game: GameType) { }

    var isGameComplete: Bool { gameVM.isGameComplete }

    func finishGameSection(_ gameType: GameType) {
        gameVM.finishGameSection(gameType)
    }
}



//MARK: UI Functions
extension MasterChooseGameViewModel {
//    func disableGameButton(game: GameType) -> some View {
//        
//    }
}

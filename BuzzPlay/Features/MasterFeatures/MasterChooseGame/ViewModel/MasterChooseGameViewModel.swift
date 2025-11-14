//
//  MasterChooseGameViewModel.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 14/11/2025.
//

import Foundation


@Observable
class MasterChooseGameViewModel {
    private let gameVM: MasterFlowViewModel
    
    init(gameVM: MasterFlowViewModel) {
        self.gameVM = gameVM
    }
    
    var availableGames: [GameType] {
        [.quiz, .blindTest]
    }
    
    func chooseGame(_ game: GameType) {
        gameVM.selectGame(game)
    }
}

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
    
    var availableGames: [GameType] = []
    
    
    //MARK: Datas en functions for views
    var allGames: [GameType] {
        [.quiz, .blindTest]
    }
    
    func addGame(_ game: GameType) {
        availableGames.append(game)
    }
    
    func removeGame(_ game: GameType) {
        availableGames.removeAll { $0 == game }
    }
    
    func gameIsAvailable(_ game: GameType) -> Bool {
        availableGames.contains(game)
    }
}

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
    
    
    //MARK: Datas en functions for views
    var allGames: [GameType] {
        [.quiz, .blindTest, .score]
    }
    
    func addGame(_ game: GameType) {
        if !gameVM.gamesOpen.contains(game) {
            gameVM.gamesOpen.append(game)
            gameVM.broadcastGameAvailability()
        }
    }

    
    func removeGame(_ game: GameType) {
        gameVM.gamesOpen.removeAll { $0 == game }
        gameVM.broadcastGameAvailability()
    }
    
    func gameIsAvailable(_ game: GameType) -> Bool {
        gameVM.gamesOpen.contains(game)
    }
}



//MARK: UI Functions
extension MasterChooseGameViewModel {
//    func disableGameButton(game: GameType) -> some View {
//        
//    }
}

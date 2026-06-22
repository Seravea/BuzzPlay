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
    var allPlayersReady: Bool { gameVM.allPlayersReady }
    // #E1 — "X/Y prêts" : X = connectés ET prêts, Y = total enregistrés (inclut les déconnectés)
    var readyPlayersCount: Int { gameVM.readyAndConnectedCount }

    // Round progress
    var currentRound: Int { gameVM.currentRound }
    var totalRounds: Int { gameVM.totalRounds }
    var isQuizCardAvailable: Bool { gameVM.isQuizAvailable }
    var isBlindTestCardAvailable: Bool { gameVM.isBlindTestAvailable }
    // #illimite — partie sans fin : pas de compteur de manches.
    var isUnlimited: Bool { gameVM.isUnlimited }

    /// #terminer — clôt la partie (toutes configs : départ d'un joueur, soirée écourtée, illimité).
    func endPartyEarly() { gameVM.endPartyEarly() }
    // #v1-economy — plus de Notes côté Master (solde local sur chaque téléphone Player).
    
    
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

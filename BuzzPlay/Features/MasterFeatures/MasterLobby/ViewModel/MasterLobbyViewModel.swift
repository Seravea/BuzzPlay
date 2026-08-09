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

    var gameDuration: GameDuration { gameVM.gameDuration }
    var gameMode: GameMode { gameVM.gameMode }

    // #config-explicite — état de progression de la config (rien pré-sélectionné).
    var durationChosen: Bool { gameVM.durationChosen }
    var modeChosen: Bool { gameVM.modeChosen }
    var isUnlimited: Bool { gameVM.isUnlimited }

    var totalRounds: Int { gameVM.totalRounds }
    var quizRoundsTotal: Int { gameVM.quizRoundsTotal }
    var blindTestRoundsTotal: Int { gameVM.blindTestRoundsTotal }

    /// Config complète (indépendamment des joueurs présents).
    var configComplete: Bool {
        durationChosen && (isUnlimited || modeChosen)
    }

    /// Le bouton « Commencer » n'est actif que si : au moins un joueur ET config complète.
    var canStart: Bool {
        !players.isEmpty && configComplete
    }

    /// Message d'aide sous le bouton verrouillé (selon l'étape qui manque).
    var startHint: String? {
        if !durationChosen { return "Choisis une durée de partie" }
        if !isUnlimited && !modeChosen { return "Choisis un mode de jeu" }
        if players.isEmpty { return "En attente d'au moins un joueur" }
        return nil
    }

    /// Sélectionne la durée. En illimité, force le mode « libre » (= Mix : Quiz + Blind Test).
    func selectDuration(_ duration: GameDuration) {
        gameVM.gameDuration = duration
        gameVM.durationChosen = true
        if duration.isUnlimited {
            gameVM.gameMode = .mix          // mix = les deux jeux dispo → « libre »
            gameVM.modeChosen = true
        } else {
            // Repasse en mode explicite : si on venait d'illimité, re-forcer le choix.
            gameVM.modeChosen = false
        }
    }

    func selectMode(_ mode: GameMode) {
        gameVM.gameMode = mode
        gameVM.modeChosen = true
    }

    func startParty() { gameVM.startParty() }
}

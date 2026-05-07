//
//  BuzzerViewModel.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 10/11/2025.
//

import Foundation

enum BuzzerGameMode {
    case blindTest
    case quiz
}

enum AnswerResult {
    case correct
    case incorrect
}

@Observable
class BuzzerViewModel {

    var player: Player
    let mode: BuzzerGameMode

    var isEnabled: Bool = false
    var playerNameHasBuzz: String?

    // MARK: - Retour visuel de réponse
    var answerResult: AnswerResult? = nil

    var onBuzz: ((Player, BuzzerGameMode) -> Void)?

    init(player: Player, mode: BuzzerGameMode) {
        self.player = player
        self.mode = mode
    }

    
    
}

//MARK: buzzFunctions
extension BuzzerViewModel {
    func buzz() {
        guard isEnabled/*, !hasBuzzed*/ else { return }
//        hasBuzzed = true
        //MARK: le TeamGameVM gère l'envoi du buzz au Master
        onBuzz?(player, mode)
    }


    func unLockBuzz() {
        isEnabled = true
        playerNameHasBuzz = nil

    }

    func lockBuzz(teamNameHasBuzz: String) {
        self.playerNameHasBuzz = teamNameHasBuzz
        isEnabled = false
    }

    func clearBuzzState() {
        playerNameHasBuzz = nil
        isEnabled = false
        answerResult = nil
    }

    // MARK: - TODO: Bug timing à corriger
    // Le timing du retour visuel (correct/incorrect) dépend de quand le Master valide la réponse.
    // Actuellement, il faut identifier:
    // 1. Quand le Master envoie la validation (AnswerResult)
    // 2. Comment cette info arrive au Player (via MPC PublicDisplay?)
    // 3. Ajouter un délai optionnel avant d'afficher le retour (pour le suspense)
    func showAnswerResult(_ result: AnswerResult) {
        answerResult = result
        // TODO: Implémenter le timing pour masquer automatiquement le retour après 2-3s
        // DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
        //     self.answerResult = nil
        // }
    }
}



//MARK: 

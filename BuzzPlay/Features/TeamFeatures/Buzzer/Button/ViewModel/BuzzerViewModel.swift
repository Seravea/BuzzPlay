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
    case correct(points: Int, answer: String?)
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

    func showAnswerResult(_ result: AnswerResult) {
        answerResult = result
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) { [weak self] in
            self?.answerResult = nil
        }
    }
}



//MARK: 

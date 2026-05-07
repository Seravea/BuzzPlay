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
    var countdownPhase: RoundCountdownPhase = .hidden
    private var countdownTimer: Timer?

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
        stopCountdown()
    }

    func showAnswerResult(_ result: AnswerResult) {
        answerResult = result
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.answerResult = nil
            switch result {
            case .incorrect:
                // Reprise de la manche — countdown puis buzzer actif
                self?.startCountdownBeforeBuzzer()
            case .correct:
                // Bonne réponse — buzzer reste désactivé, attend la prochaine question du Master
                self?.lockBuzz(teamNameHasBuzz: "")
            }
        }
    }

    func startCountdownBeforeBuzzer() {
        lockBuzz(teamNameHasBuzz: "")
        countdownTimer?.invalidate()
        var count = 3
        countdownPhase = .counting(count)
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            count -= 1
            if count > 0 {
                self?.countdownPhase = .counting(count)
            } else {
                timer.invalidate()
                self?.countdownTimer = nil
                self?.countdownPhase = .go
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    self?.countdownPhase = .hidden
                    self?.unLockBuzz()
                }
            }
        }
    }

    private func stopCountdown() {
        countdownTimer?.invalidate()
        countdownTimer = nil
        countdownPhase = .hidden
    }
}



//MARK: 

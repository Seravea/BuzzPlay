//
//  BuzzerViewModel.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 10/11/2025.
//

import Foundation
import AVFoundation

enum BuzzerGameMode {
    case blindTest
    case quiz
}

enum AnswerResult {
    case correct(points: Int, answer: String?)
    case incorrect
    case otherCorrect(playerName: String, points: Int, answer: String?)
}

@MainActor
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

    // MARK: - Indice (gift showIndicies)
    var activeHint: String? = nil

    // MARK: - Son buzzer
    private var defaultBuzzPlayer: AVAudioPlayer?   // pré-chargé au init, pas de latence au 1er buzz
    private var customSoundPlayer: AVAudioPlayer?   // son custom (gift changeBuzzSound)

    var onBuzz: ((Player, BuzzerGameMode) -> Void)?

    init(player: Player, mode: BuzzerGameMode) {
        self.player = player
        self.mode = mode
        setupAudioSession()
        preloadDefaultSound()
    }

    private func setupAudioSession() {
        do {
            // .playback + .mixWithOthers : joue même en mode silencieux sans couper Apple Music
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("BuzzerVM: AVAudioSession setup error: \(error)")
        }
    }

    private func preloadDefaultSound() {
        guard let url = Bundle.main.url(forResource: "Buzzer", withExtension: "mp3") else { return }
        defaultBuzzPlayer = try? AVAudioPlayer(contentsOf: url)
        defaultBuzzPlayer?.prepareToPlay()
    }

    
    
}

//MARK: buzzFunctions
extension BuzzerViewModel {
    func buzz() {
        guard isEnabled else { return }
        playBuzzSound()
        onBuzz?(player, mode)
    }

    private func playBuzzSound() {
        if let soundName = player.customBuzzSound {
            // Son custom choisi par le Player (cadeau changeBuzzSound)
            guard let url = Bundle.main.url(forResource: soundName, withExtension: "mp3") else { return }
            customSoundPlayer?.stop()
            customSoundPlayer = try? AVAudioPlayer(contentsOf: url)
            customSoundPlayer?.play()
        } else {
            // Son par défaut pré-chargé → zéro latence
            defaultBuzzPlayer?.currentTime = 0
            defaultBuzzPlayer?.play()
        }
    }


    func unLockBuzz() {
        isEnabled = true
        playerNameHasBuzz = nil
        activeHint = nil  // reset l'indice à chaque nouvelle manche
    }

    func lockBuzz(teamNameHasBuzz: String) {
        self.playerNameHasBuzz = teamNameHasBuzz
        isEnabled = false
    }

    func clearBuzzState() {
        playerNameHasBuzz = nil
        isEnabled = false
        answerResult = nil
        activeHint = nil
        stopCountdown()
    }

    func showHint(_ hint: String) {
        activeHint = hint
    }

    func showAnswerResult(_ result: AnswerResult) {
        answerResult = result
        Task { @MainActor [weak self] in
            try? await Task.sleep(for: .seconds(2.6))
            self?.answerResult = nil
            self?.lockBuzz(teamNameHasBuzz: "")
        }
    }

    func startCountdownBeforeBuzzer() {
        lockBuzz(teamNameHasBuzz: "")
        countdownTimer?.invalidate()
        var count = 3
        countdownPhase = .counting(count)
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            count -= 1
            // Garantir l'isolation @MainActor pour les mutations depuis la closure Timer
            Task { @MainActor [weak self] in
                guard let self else { return }
                if count > 0 {
                    self.countdownPhase = .counting(count)
                } else {
                    timer.invalidate()
                    self.countdownTimer = nil
                    self.countdownPhase = .go
                    try? await Task.sleep(for: .milliseconds(800))
                    self.countdownPhase = .hidden
                    self.unLockBuzz()
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

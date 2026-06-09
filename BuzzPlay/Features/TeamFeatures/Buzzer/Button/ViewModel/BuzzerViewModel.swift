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

    var player: Player {
        didSet {
            guard player.customBuzzSound != oldValue.customBuzzSound else { return }
            if let soundName = player.customBuzzSound {
                preloadCustomSound(soundName)
            } else {
                customSoundPlayer = nil
            }
        }
    }
    let mode: BuzzerGameMode

    var isEnabled: Bool = false
    var playerNameHasBuzz: String?
    // Séparé du buzz lock global : bloqué par un cadeau adverse (enemyCanNotBuzz)
    private(set) var isGiftBlocked: Bool = false

    // MARK: - Retour visuel de réponse
    var answerResult: AnswerResult? = nil
    var countdownPhase: RoundCountdownPhase = .hidden
    private var countdownTimer: Timer?

    // MARK: - Indice (gift showIndicies)
    var activeHint: String? = nil

    // MARK: - Son buzzer
    private var defaultBuzzPlayer: AVAudioPlayer?
    private var customSoundPlayer: AVAudioPlayer?

    var isBuzzMuted: Bool = UserDefaults.standard.bool(forKey: "buzzplay.player.buzzMuted") {
        didSet { UserDefaults.standard.set(isBuzzMuted, forKey: "buzzplay.player.buzzMuted") }
    }

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

    private func preloadCustomSound(_ soundName: String) {
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "mp3") else { return }
        customSoundPlayer = try? AVAudioPlayer(contentsOf: url)
        customSoundPlayer?.prepareToPlay()
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
        guard !isBuzzMuted else { return }
        if let custom = customSoundPlayer {
            custom.currentTime = 0
            custom.play()
        } else {
            defaultBuzzPlayer?.currentTime = 0
            defaultBuzzPlayer?.play()
        }
    }


    func unLockBuzz() {
        playerNameHasBuzz = nil
        activeHint = nil
        guard !player.blockedFromBuzzing && !isGiftBlocked else { return }
        isEnabled = true
    }

    func lockBuzz(teamNameHasBuzz: String) {
        self.playerNameHasBuzz = teamNameHasBuzz
        isEnabled = false
    }

    func setGiftBlock(_ blocked: Bool) {
        isGiftBlocked = blocked
        if blocked {
            isEnabled = false
        } else if playerNameHasBuzz == nil {
            isEnabled = true
        }
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
            try? await Task.sleep(for: .seconds(1.5))
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

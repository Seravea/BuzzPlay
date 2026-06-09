//
//  BuzzDrivenGame.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 17/11/2025.
//

import Foundation

// Phase du compte à rebours avant réactivation du buzzer — partagé Player et Master
enum RoundCountdownPhase: Codable, Equatable {
    case hidden
    case counting(Int)
    case go

    enum CodingKeys: String, CodingKey {
        case hidden, counting, go
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .hidden:
            try container.encode(true, forKey: .hidden)
        case .counting(let n):
            try container.encode(n, forKey: .counting)
        case .go:
            try container.encode(true, forKey: .go)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if container.contains(.hidden) {
            self = .hidden
        } else if container.contains(.counting) {
            let n = try container.decode(Int.self, forKey: .counting)
            self = .counting(n)
        } else if container.contains(.go) {
            self = .go
        } else {
            self = .hidden
        }
    }
}

@MainActor
protocol BuzzDrivenGame: AnyObject {
    // Timer
    var reactionTimeMs: Int { get set }
    var timer: Timer? { get set }

    // Le master annonce qu'un player a buzzé
    func handleBuzz(from player: Player)

    func makePublicState() -> PublicState

    // Apply single-use gift effects to the game
    func applyGiftEffect(_ gift: CoinsViewModel.Gift, to player: Player)

    // #pause-reco — met le jeu en pause quand TOUS les joueurs sont déconnectés (timer +
    // média), et le reprend à la reconnexion. Chaque jeu garde son propre état pour ne PAS
    // toucher une manche déjà en attente de validation (buzz) ni un état idle.
    func pauseForDisconnect()
    func resumeFromDisconnect()
}

// Default gift effect implementation (no-op, games can override)
extension BuzzDrivenGame {
    func applyGiftEffect(_ gift: CoinsViewModel.Gift, to player: Player) {
        // Games override this to implement specific gift effects
    }

    // Défaut sûr : pause/reprise du timer uniquement. Les jeux qui ont un média (musique)
    // ou un état de manche surchargent pour gérer le cas proprement.
    func pauseForDisconnect() { pauseReactionTimer() }
    func resumeFromDisconnect() { startReactionTimer() }
}

// Timer functions
extension BuzzDrivenGame {
    var formattedTime: String {
        String(format: "%02d", reactionTimeMs / 1000)
    }
    
    // Resume-or-start timer without resetting reactionTimeMs.
    // Use this in "rejectAnswer" to continue from the paused time.
    func startReactionTimer() {
        // Do NOT reset reactionTimeMs here; we want resume semantics.
        // Just ensure any previous timer is invalidated.
        timer?.invalidate()
        timer = nil
        
        // Create the timer on the main run loop.
        let newTimer = Timer(timeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                self.reactionTimeMs += 100
            }
        }
        RunLoop.main.add(newTimer, forMode: .common)
        timer = newTimer
    }
    
    // Pause without resetting the elapsed time.
    func pauseReactionTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // Full stop + reset to zero.
    func stopReactionTimer() {
        reactionTimeMs = 0
        timer?.invalidate()
        timer = nil
    }
}

//
//  BuzzDrivenGame.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 17/11/2025.
//

import Foundation

@MainActor
protocol BuzzDrivenGame: AnyObject {
    // Timer
    var reactionTimeMs: Int { get set }
    var timer: Timer? { get set }
    
    // Le master annonce qu'une team a buzzé
    func handleBuzz(from team: Team)
    
    func makePublicState() -> PublicState
}

// Timer functions
extension BuzzDrivenGame {
    var formattedTime: String {
        let centiseconds = reactionTimeMs / 10
        let seconds = centiseconds / 100
        let cs = centiseconds % 100
        return String(format: "%02d:%02d", seconds, cs)
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

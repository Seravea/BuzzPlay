//
//  BuzzDrivenGame.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 17/11/2025.
//

import Foundation

@MainActor
protocol BuzzDrivenGame: AnyObject {
    var reactionTimeMs: Int { get set }
    var timer: Timer? { get set }

    func handleBuzz(from team: Team)
}

extension BuzzDrivenGame {
    var formattedTime: String {
        let centiseconds = reactionTimeMs / 10
        let seconds = centiseconds / 100
        let cs = centiseconds % 100
        return String(format: "%02d:%02d", seconds, cs)
    }

    func startReactionTimer() {
        timer?.invalidate()
        timer = nil
        let newTimer = Timer(timeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                self.reactionTimeMs += 100
            }
        }
        RunLoop.main.add(newTimer, forMode: .common)
        timer = newTimer
    }

    func pauseReactionTimer() {
        timer?.invalidate()
        timer = nil
    }

    func stopReactionTimer() {
        reactionTimeMs = 0
        timer?.invalidate()
        timer = nil
    }
}

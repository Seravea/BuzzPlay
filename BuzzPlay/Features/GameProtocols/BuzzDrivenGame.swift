//
//  BuzzDrivenGame.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 17/11/2025.
//

import Foundation



protocol BuzzDrivenGame: AnyObject {
    //Timer
    var reactionTimeMs: Int { get set }
    var timer: Timer? { get set }
    
    //Le master annonce qu'une team a buzzé
    func handleBuzz(from team: Team)
}


//Timer functions
extension BuzzDrivenGame {
    var formattedTime: String {
        let centiseconds = reactionTimeMs / 10     
        let seconds = centiseconds / 100
        let cs = centiseconds % 100
        return String(format: "%02d:%02d", seconds, cs)
    }
    
    func startReactionTimer() {
        stopReactionTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
            self?.reactionTimeMs += 10
        }
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

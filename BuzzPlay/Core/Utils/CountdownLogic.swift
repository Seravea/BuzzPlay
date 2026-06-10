//
//  CountdownLogic.swift
//  BuzzPlay
//

import Foundation

@MainActor
func runCountdown(
    startCount: Int = 3,
    onPhaseChange: @escaping @MainActor (RoundCountdownPhase) -> Void,
    onComplete: @escaping @MainActor () -> Void
) async {
    for count in stride(from: startCount, through: 1, by: -1) {
        onPhaseChange(.counting(count))
        try? await Task.sleep(for: GameRhythm.countdownTick)
        guard !Task.isCancelled else { onPhaseChange(.hidden); return }
    }

    onPhaseChange(.go)
    try? await Task.sleep(for: GameRhythm.goFlash)
    guard !Task.isCancelled else { onPhaseChange(.hidden); return }

    onPhaseChange(.hidden)
    onComplete()
}

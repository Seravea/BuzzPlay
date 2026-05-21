//
//  CountdownLogic.swift
//  BuzzPlay
//

import Foundation

@MainActor
func runCountdown(
    onPhaseChange: @escaping @MainActor (RoundCountdownPhase) -> Void,
    onComplete: @escaping @MainActor () -> Void
) async {
    onPhaseChange(.hidden)

    try? await Task.sleep(for: .seconds(2))
    guard !Task.isCancelled else { onPhaseChange(.hidden); return }

    for count in stride(from: 3, through: 1, by: -1) {
        onPhaseChange(.counting(count))
        try? await Task.sleep(for: .seconds(1))
        guard !Task.isCancelled else { onPhaseChange(.hidden); return }
    }

    onPhaseChange(.go)
    try? await Task.sleep(for: .milliseconds(800))
    guard !Task.isCancelled else { onPhaseChange(.hidden); return }

    onPhaseChange(.hidden)
    onComplete()
}

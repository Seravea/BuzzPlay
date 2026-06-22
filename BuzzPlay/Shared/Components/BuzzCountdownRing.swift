//
//  BuzzCountdownRing.swift
//  BuzzPlay
//
//  #answer-window — petit anneau de décompte (5→0) affiché à côté du texte de buzz, chez le
//  Master ET les joueurs. Le CHIFFRE rend le rôle évident : « temps pour répondre ». Ne
//  refuse jamais tout seul ; c'est juste un repère visuel anti buzz-réflexe.
//
//  ⚠️ Timing LOCAL : chaque device lance son propre décompte à l'apparition (les horloges des
//  téléphones ne sont pas synchronisées). `resetKey` (timestamp Master du buzz) ne sert qu'à
//  RÉINITIALISER l'anneau à chaque nouveau buzz.
//

import SwiftUI

struct BuzzCountdownRing: View {
    /// Clé de reset (timestamp Master). Change = nouveau buzz → anneau réinitialisé.
    let resetKey: TimeInterval
    var duration: TimeInterval = GameRhythm.answerWindow
    var size: CGFloat = 38

    @State private var begin = Date()

    var body: some View {
        TimelineView(.animation) { context in
            let elapsed = context.date.timeIntervalSince(begin)
            let remaining = max(0, duration - elapsed)
            let fraction = max(0, min(1, CGFloat(remaining / duration)))
            let seconds = max(0, Int(remaining.rounded(.up)))
            ZStack {
                Circle().stroke(.white.opacity(0.10), lineWidth: 3)
                Circle()
                    .trim(from: 0, to: fraction)
                    .stroke(color(for: fraction), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text("\(seconds)")
                    .font(.nohemi(.subheadline, weight: .bold))
                    .foregroundStyle(.white.opacity(0.9))
                    .monospacedDigit()
            }
            .frame(width: size, height: size)
        }
        .onAppear { begin = Date() }
        .onChange(of: resetKey) { begin = Date() }
    }

    private func color(for fraction: CGFloat) -> Color {
        if fraction > 0.5 { return Color.greenGlow }
        if fraction > 0.2 { return Color.mustardYellow }
        return Color.redLeading
    }
}

#Preview {
    HStack(spacing: 30) {
        BuzzCountdownRing(resetKey: 0)
        BuzzCountdownRing(resetKey: 1, size: 30)
    }
    .padding(40)
    .background(Color.sheetBg)
}

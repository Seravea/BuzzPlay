//
//  BuzzAnswerWindowBar.swift
//  BuzzPlay
//
//  #answer-window — barre qui se vide en 5s après un buzz. Calculée localement depuis le
//  timestamp Master (`buzzStartedAt`) → synchrone sur tous les écrans (même principe que le
//  décompte 3-2-1). Vert → ambre → rouge en se vidant. Affichée chez TOUT LE MONDE pour
//  rendre visible le temps qui passe (anti buzz-réflexe) ; ne refuse jamais toute seule.
//

import SwiftUI

struct BuzzAnswerWindowBar: View {
    /// Timestamp Master du buzz (epoch). Source de vérité unique.
    let startedAt: TimeInterval
    var duration: TimeInterval = GameRhythm.answerWindow
    var height: CGFloat = 5

    var body: some View {
        TimelineView(.animation) { context in
            let elapsed = context.date.timeIntervalSince1970 - startedAt
            let fraction = max(0, min(1, (duration - elapsed) / duration))
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(.white.opacity(0.12))
                    Capsule()
                        .fill(color(for: fraction))
                        .frame(width: geo.size.width * fraction)
                        .animation(.linear(duration: 0.1), value: fraction)
                }
            }
            .frame(height: height)
        }
    }

    private func color(for fraction: CGFloat) -> Color {
        if fraction > 0.5 { return Color.greenGlow }
        if fraction > 0.2 { return Color.mustardYellow }
        return Color.redLeading
    }
}

#Preview {
    VStack(spacing: 24) {
        BuzzAnswerWindowBar(startedAt: Date().timeIntervalSince1970)
        BuzzAnswerWindowBar(startedAt: Date().timeIntervalSince1970 - 3)
        BuzzAnswerWindowBar(startedAt: Date().timeIntervalSince1970 - 4.5)
    }
    .padding(40)
    .background(Color.sheetBg)
}

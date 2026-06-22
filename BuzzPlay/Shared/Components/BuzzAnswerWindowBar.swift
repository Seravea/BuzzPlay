//
//  BuzzAnswerWindowBar.swift
//  BuzzPlay
//
//  #answer-window — barre qui se vide en 5s après un buzz. Visible chez tout le monde
//  (sheet Master + buzzer de chaque joueur) pour rendre visible le temps qui passe
//  (anti buzz-réflexe). Ne refuse jamais toute seule.
//
//  ⚠️ Timing LOCAL : chaque device lance son propre décompte à l'apparition de la barre
//  (comme le décompte 3-2-1). On NE compare PAS d'horloges absolues entre téléphones —
//  elles ne sont pas synchronisées → ça figeait/désynchronisait la barre. `startedAt` ne
//  sert que de CLÉ de réinitialisation (nouveau buzz = nouvelle valeur → barre repleine).
//

import SwiftUI

struct BuzzAnswerWindowBar: View {
    /// Clé de reset (timestamp Master du buzz). Change = nouveau buzz → barre réinitialisée.
    let startedAt: TimeInterval
    var duration: TimeInterval = GameRhythm.answerWindow
    var height: CGFloat = 5

    @State private var begin = Date()

    var body: some View {
        TimelineView(.animation) { context in
            let elapsed = context.date.timeIntervalSince(begin)
            let fraction = max(0, min(1, CGFloat((duration - elapsed) / duration)))
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(.white.opacity(0.10))
                    Capsule()
                        .fill(color(for: fraction))
                        .frame(width: geo.size.width * fraction)
                }
            }
            .frame(height: height)
        }
        .onAppear { begin = Date() }
        .onChange(of: startedAt) { begin = Date() }
    }

    private func color(for fraction: CGFloat) -> Color {
        if fraction > 0.5 { return Color.greenGlow }
        if fraction > 0.2 { return Color.mustardYellow }
        return Color.redLeading
    }
}

#Preview {
    VStack(spacing: 24) {
        BuzzAnswerWindowBar(startedAt: 0)
    }
    .padding(40)
    .background(Color.sheetBg)
}

//
//  BlindTestFinishedPanel.swift
//  BuzzPlay
//

import SwiftUI

// MARK: - Panneau fin de manche (#bt-queue)

struct BlindTestFinishedPanel: View {
    @Bindable var blindTestVM: BlindTestMasterViewModel
    let onNext: () -> Void
    // #chantier6 — abandonner la file en cours et revenir composer d'autres titres.
    let onQuitQueue: () -> Void

    // #chantier6 — le Maître passait à la musique suivante AVANT que les joueurs aient vu le
    // titre révélé ET l'animation du classement inter-manche. On verrouille « Musique suivante »
    // le temps de tout l'inter-manche + 1s (GameRhythm.blindTestNextHold). Réarmé par song.
    @State private var nextEnabled = false
    @State private var nextCountdown = 0

    var body: some View {
        VStack(spacing: BuzzSpacing.md) {
            if let winner = blindTestVM.playerHasBuzz {
                HStack(spacing: BuzzSpacing.sm) {
                    Image(systemName: "checkmark.circle.fill")
                        .textStyle(Typography.cardTitle)
                        .foregroundStyle(Color.greenGlow)
                    Text("\(winner.name) a trouvé")
                        .font(.nohemi(.subheadline, weight: .bold))
                        .foregroundStyle(.white)
                }
            } else {
                Text("Manche terminée")
                    .font(.nohemi(.subheadline, weight: .bold))
                    .foregroundStyle(.white)
            }

            Button(action: onNext) {
                HStack(spacing: BuzzSpacing.sm) {
                    Image(systemName: nextEnabled
                          ? (blindTestVM.hasNextInQueue ? "forward.fill" : "music.note.list")
                          : "hourglass")
                        .textStyle(Typography.labelSM)
                    Text(!nextEnabled
                         ? "Résultats aux joueurs… \(nextCountdown)"
                         : blindTestVM.hasNextInQueue
                            ? "Musique suivante (\(blindTestVM.queueIndex + 2)/\(blindTestVM.queueCount))"
                            : "Choisir d'autres titres")
                        .font(.nohemi(.body, weight: .bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, BuzzSpacing.lg)
                .background(
                    LinearGradient(colors: nextEnabled ? [.purpleLeading, .purpleTrailing]
                                                        : [.white.opacity(0.10), .white.opacity(0.08)],
                                   startPoint: .leading, endPoint: .trailing),
                    in: RoundedRectangle(cornerRadius: BuzzRadius.lg)
                )
                .shadow(color: nextEnabled ? Color.purpleLeading.opacity(0.35) : .clear, radius: 8)
            }
            .buttonStyle(.plain)
            .disabled(!nextEnabled)
            .animation(.buzzDefault, value: nextEnabled)

            // #chantier6 — sortie de file : quand il reste des titres, on n'est plus
            // obligé d'aller au bout — « Changer de titres » ramène à la composition.
            // (File épuisée : le bouton principal EST déjà « Choisir d'autres titres ».)
            if blindTestVM.hasNextInQueue {
                Button(action: onQuitQueue) {
                    Text("Changer de titres \(Image(systemName: "music.note.list"))")
                        .font(.nohemi(.caption, weight: .bold))
                        .foregroundStyle(Color.textSoft)
                        .pillStyle(fill: .white.opacity(0.08),
                                   stroke: .white.opacity(0.12),
                                   compact: true,
                                   trailingIcon: true)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(BuzzSpacing.lg)
        .frame(maxWidth: .infinity)
        .background(Color.darkestPurple, in: RoundedRectangle(cornerRadius: BuzzRadius.xl))
        .overlay(RoundedRectangle(cornerRadius: BuzzRadius.xl).strokeBorder(.white.opacity(0.1), lineWidth: 1))
        .padding(.horizontal, BuzzSpacing.xl)
        .padding(.bottom, BuzzSpacing.xl)
        // #chantier6 — verrou anti-avance-trop-rapide, réarmé à chaque morceau.
        .task(id: blindTestVM.queueIndex) {
            nextEnabled = false
            // Décompte 1s par 1s (arrondi au sup.) → le Maître voit le verrou fondre.
            let c = GameRhythm.blindTestNextHold.components
            let total = Int(c.seconds) + (c.attoseconds > 0 ? 1 : 0)
            for remaining in stride(from: total, through: 1, by: -1) {
                nextCountdown = remaining
                try? await Task.sleep(for: .seconds(1))
                if Task.isCancelled { return }
            }
            nextEnabled = true
        }
    }
}

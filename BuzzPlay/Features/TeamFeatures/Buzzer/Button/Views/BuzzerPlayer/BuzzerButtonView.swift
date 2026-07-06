//
//  BuzzerButtonView.swift
//  BuzzPlay
//

import SwiftUI
import UIKit

struct BuzzerButtonView: View {
    @State private var isTapped: Bool = false
    @Bindable var buzzerVM: BuzzerViewModel
    // #R3 — countdown inline (sous le buzzer) UNIQUEMENT au refus Quiz (question révélée).
    // Au démarrage de manche (Quiz + BlindTest), c'est le CountdownOverlay plein écran qui gère
    // → évite le double countdown.
    var showInlineCountdown: Bool = false
    /// #answer-window — top du buzz (epoch) ; nil = pas de barre.
    var buzzStartedAt: TimeInterval? = nil

    private var ourTeamBuzzed: Bool { buzzerVM.playerNameHasBuzz == buzzerVM.player.name }
    private var hasBuzzed: Bool { buzzerVM.playerNameHasBuzz != nil }

    private var playerColor: Color {
        let gameColor = buzzerVM.player.customBuzzColor ?? buzzerVM.player.teamColor
        return Color(gameColor.rawValue)
    }

    var body: some View {
        VStack(spacing: BuzzSpacing.xl) {
            ZStack {
                // Pulse rings — uniquement quand actif et pas encore buzzé
                if buzzerVM.isEnabled && !hasBuzzed {
                    PulseRingView(delay: 0.0, color: playerColor)
                    PulseRingView(delay: 0.7, color: playerColor)
                    PulseRingView(delay: 1.4, color: playerColor)
                }

                // Halo radial
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                playerColor.opacity(buzzerVM.isEnabled ? 0.45 : 0.08),
                                .clear,
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 120
                        )
                    )
                    .frame(width: 240, height: 240)
                    .blur(radius: 20)

                // Bouton principal
                ZStack {
                    let isBlocked = buzzerVM.player.blockedFromBuzzing
                    let circleColor: Color = isBlocked ? Color.redLeading : playerColor

                    Circle()
                        .fill(
                            RadialGradient(
                                stops: [
                                    .init(color: circleColor.opacity(0.95), location: 0),
                                    .init(color: circleColor, location: 0.50),
                                    .init(color: circleColor.opacity(0.72), location: 1),
                                ],
                                center: .init(x: 0.5, y: 0.35),
                                startRadius: 0,
                                endRadius: 110
                            )
                        )
                        .frame(width: 220, height: 220)
                        .shadow(color: circleColor.opacity(0.18), radius: 0)
                        .shadow(color: circleColor.opacity(0.08), radius: 8)
                        .shadow(color: circleColor.opacity(0.40), radius: 30, y: 15)
                        .opacity(buzzerVM.isEnabled ? 1 : (ourTeamBuzzed ? 0.65 : (isBlocked ? 0.55 : 0.30)))

                    VStack(spacing: BuzzSpacing.xs) {
                        Image(systemName: isBlocked ? "lock.fill" : "bolt.fill")
                            .font(.system(size: 52, weight: .bold))
                        Text(ourTeamBuzzed ? "BUZZÉ" : (isBlocked ? "BLOQUÉ" : "BUZZ"))
                            .font(.custom("Nohemi-Black", size: 18))
                            .tracking(2)
                    }
                    .foregroundStyle(.white)
                }
                .scaleEffect(isTapped ? 0.94 : (ourTeamBuzzed ? 0.91 : 1.0))
                .animation(.easeInOut(duration: 0.12), value: isTapped)
                .animation(.spring(response: 0.35, dampingFraction: 0.65), value: ourTeamBuzzed)
            }
            .frame(width: 300, height: 300)
            .onTapGesture {
                if buzzerVM.isEnabled {
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    buzzerVM.buzz()
                    isTapped = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        isTapped = false
                    }
                } else {
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                }
            }

            stateLabel
        }
        .animation(.buzzSmooth, value: buzzerVM.player.blockedFromBuzzing)
        .appDefaultTextStyle(Typography.body)
    }

    @ViewBuilder
    private var stateLabel: some View {
        VStack(spacing: BuzzSpacing.xs) {
            // #E3/#R3 — countdown inline seulement au refus Quiz (showInlineCountdown)
            if showInlineCountdown, case .counting(let n) = buzzerVM.countdownPhase {
                Text("Prochain buzz dans…")
                    .font(.nohemi(.headline, weight: .bold))
                    .foregroundStyle(.white)
                Text("\(n)")
                    .font(.custom("Nohemi-Black", size: 28))
                    .foregroundStyle(playerColor)
            } else if showInlineCountdown, case .go = buzzerVM.countdownPhase {
                Text("À toi de buzzer !")
                    .font(.nohemi(.headline, weight: .bold))
                    .foregroundStyle(playerColor)
            } else if let teamName = buzzerVM.playerNameHasBuzz, !teamName.isEmpty {
                // #qui-buzz-player — bandeau BIEN visible : avant, texte .headline discret en bas
                // → les joueurs ne voyaient pas qui avait la main et répondaient à tort (retour test 2026-07-02).
                buzzedBanner(name: teamName, isSelf: teamName == buzzerVM.player.name)
                    .transition(.scale(scale: 0.85).combined(with: .opacity))
            } else if buzzerVM.isEnabled {
                Text("Appuie pour buzzer !")
                    .font(.nohemi(.headline, weight: .bold))
                    .foregroundStyle(.white)
                Text("Le plus rapide gagne le droit de répondre")
                    .font(.nohemi(.caption))
                    .foregroundStyle(Color.textTertiary)
                    .multilineTextAlignment(.center)
            } else if buzzerVM.player.blockedFromBuzzing {
                if let blocker = buzzerVM.player.blockedByPlayerName {
                    Text("\(blocker) t'a bloqué !")
                        .font(.nohemi(.headline, weight: .bold))
                        .foregroundStyle(Color.redLeading)
                } else {
                    Text("Ton buzzer est bloqué !")
                        .font(.nohemi(.headline, weight: .bold))
                        .foregroundStyle(Color.redLeading)
                }
                Text("Tu ne peux pas buzzer cette manche")
                    .font(.nohemi(.caption))
                    .foregroundStyle(Color.textTertiary)
                    .multilineTextAlignment(.center)
            } else {
                Text("En attente d'une question…")
                    .font(.nohemi(.subheadline, weight: .regular))
                    .foregroundStyle(.white.opacity(0.30))
            }
        }
        .padding(.horizontal, BuzzSpacing.xxxl)
        .multilineTextAlignment(.center)
        // #R2 — hauteur fixe : les états à 1 ou 2 lignes ne font plus bouger le buzzer
        .frame(height: 72, alignment: .top)
        // #qui-buzz-player — pop d'apparition du bandeau de buzz (accroche l'œil).
        .animation(.buzzBouncy, value: buzzerVM.playerNameHasBuzz)
    }

    // #qui-buzz-player — bandeau de buzz. Distinction nette TOI (ta couleur, positif) vs
    // UN AUTRE (jaune « attention, pas ton tour ») pour couper le « je croyais avoir buzzé ».
    // L'anneau (temps depuis le buzz) est conservé : il révèle qui traîne (tenu par Romain).
    @ViewBuilder
    private func buzzedBanner(name: String, isSelf: Bool) -> some View {
        let accent = isSelf ? playerColor : Color.mustardYellow
        HStack(spacing: BuzzSpacing.sm) {
            Image(systemName: isSelf ? "hand.tap.fill" : "hand.raised.fill")
                .font(.nohemi(.title3, weight: .bold))
                .foregroundStyle(accent)

            VStack(alignment: .leading, spacing: 0) {
                Text(isSelf ? "TU AS BUZZÉ" : "\(name.uppercased()) A BUZZÉ")
                    .font(.nohemi(.title3, weight: .bold)).titleTracking()
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                if !isSelf {
                    Text("attends, ce n'est pas ton tour")
                        .font(.nohemi(.caption2, weight: .medium))
                        .foregroundStyle(Color.textSecondary)
                        .lineLimit(1)
                }
            }

            if let started = buzzStartedAt {
                Spacer(minLength: BuzzSpacing.sm)
                BuzzCountdownRing(resetKey: started, font: .nohemi(.title3, weight: .bold))
            }
        }
        .padding(.horizontal, BuzzSpacing.lg)
        .padding(.vertical, 8)
        .background(accent.opacity(0.15), in: Capsule())
        .overlay(Capsule().strokeBorder(accent.opacity(0.5), lineWidth: 1.5))
    }
}

#Preview {
    BuzzerButtonView(
        buzzerVM: BuzzerViewModel(
            player: Player(name: "L'équipe 1", teamColor: .blueGame),
            mode: .blindTest
        )
    )
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(BackgroundAppView())
}

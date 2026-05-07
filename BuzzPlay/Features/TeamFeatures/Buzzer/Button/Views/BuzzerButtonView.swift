//
//  BuzzerButtonView.swift
//  BuzzPlay
//

import SwiftUI
import UIKit

struct BuzzerButtonView: View {
    @State private var isTapped: Bool = false
    @Bindable var buzzerVM: BuzzerViewModel

    private var ourTeamBuzzed: Bool { buzzerVM.playerNameHasBuzz == buzzerVM.player.name }
    private var hasBuzzed: Bool { buzzerVM.playerNameHasBuzz != nil }

    // Couleur personnalisée du joueur (depuis ses assets GameColor)
    private var playerColor: Color { Color(buzzerVM.player.teamColor.rawValue) }

    var body: some View {
        VStack(spacing: 20) {
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
                    Circle()
                        .fill(
                            RadialGradient(
                                stops: [
                                    .init(color: playerColor.opacity(0.95), location: 0),
                                    .init(color: playerColor, location: 0.50),
                                    .init(color: playerColor.opacity(0.72), location: 1),
                                ],
                                center: .init(x: 0.5, y: 0.35),
                                startRadius: 0,
                                endRadius: 110
                            )
                        )
                        .frame(width: 220, height: 220)
                        .shadow(color: playerColor.opacity(0.18), radius: 0)
                        .shadow(color: playerColor.opacity(0.08), radius: 8)
                        .shadow(color: playerColor.opacity(0.40), radius: 30, y: 15)
                        .opacity(buzzerVM.isEnabled ? 1 : (ourTeamBuzzed ? 0.65 : 0.30))

                    VStack(spacing: 4) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 52, weight: .bold))
                        Text(ourTeamBuzzed ? "BUZZÉ" : "BUZZ")
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
        .appDefaultTextStyle(Typography.body)
    }

    @ViewBuilder
    private var stateLabel: some View {
        VStack(spacing: 4) {
            if let teamName = buzzerVM.playerNameHasBuzz {
                if teamName == buzzerVM.player.name {
                    Text("Tu as buzzé !")
                        .font(.nohemi(.headline, weight: .bold))
                        .foregroundStyle(playerColor)
                } else {
                    Text("\(teamName) a buzzé")
                        .font(.nohemi(.headline, weight: .regular))
                        .foregroundStyle(.white.opacity(0.40))
                }
            } else if buzzerVM.countdownBeforeBuzzer > 0 {
                Text("Prochain buzz…")
                    .font(.nohemi(.headline, weight: .bold))
                    .foregroundStyle(.white)
                Text("\(buzzerVM.countdownBeforeBuzzer)")
                    .font(.custom("Nohemi-Black", size: 28))
                    .foregroundStyle(playerColor)
            } else if buzzerVM.isEnabled {
                Text("Appuie pour buzzer !")
                    .font(.nohemi(.headline, weight: .bold))
                    .foregroundStyle(.white)
                Text("Le plus rapide gagne le droit de répondre")
                    .font(.nohemi(.caption))
                    .foregroundStyle(.white.opacity(0.45))
                    .multilineTextAlignment(.center)
            } else {
                Text("En attente d'une question…")
                    .font(.nohemi(.subheadline, weight: .regular))
                    .foregroundStyle(.white.opacity(0.30))
            }
        }
        .padding(.horizontal, 32)
        .multilineTextAlignment(.center)
    }
}

// MARK: - Pulse ring animé

private struct PulseRingView: View {
    let delay: Double
    let color: Color
    @State private var animate = false

    var body: some View {
        Circle()
            .strokeBorder(color.opacity(0.40), lineWidth: 1.5)
            .frame(width: 280, height: 280)
            .scaleEffect(animate ? 1.40 : 0.85)
            .opacity(animate ? 0 : 0.70)
            .onAppear {
                withAnimation(
                    .easeOut(duration: 2.2)
                    .repeatForever(autoreverses: false)
                    .delay(delay)
                ) {
                    animate = true
                }
            }
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

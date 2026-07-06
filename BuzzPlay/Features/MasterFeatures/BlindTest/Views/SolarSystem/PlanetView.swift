//
//  PlanetView.swift
//  BuzzPlay
//
//  Planète du « système solaire » Blind Test = un joueur en orbite (initiale + couleur
//  d'équipe + score). Gère l'entrée en cascade (C) et le rebond « +N » au score (A).
//  Extrait de SolarSystemStageView.
//

import SwiftUI

struct PlanetView: View {
    let player: Player
    let size: CGFloat
    let index: Int
    let highlighted: Bool
    let dimmed: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var entered = false          // (C) entrée en cascade
    @State private var popScale: CGFloat = 1     // (A) rebond au score
    @State private var popDelta: Int? = nil      // (A) « +N » volant
    @State private var floatUp = false
    @State private var popTask: Task<Void, Never>?

    private var highlightScale: CGFloat { highlighted ? 1.28 : (dimmed ? 0.9 : 1.0) }

    var body: some View {
        VStack(spacing: size * 0.10) {
            Circle()
                .fill(player.teamColor.gradient)
                .frame(width: size, height: size)
                .overlay(
                    // Lettre dans le rond : taille proportionnelle + nudge bas (Nohemi calé haut).
                    Text(String(player.name.prefix(1)).uppercased())
                        .font(.custom("Nohemi-Black", size: size * 0.42))
                        .foregroundStyle(.white)
                        .nohemiBadgeNudge(fontSize: size * 0.42)
                )
                .overlay(Circle().strokeBorder(.white.opacity(highlighted ? 0.95 : 0.7), lineWidth: highlighted ? 3 : 2))
                .shadow(color: player.teamColor.color.opacity(highlighted ? 0.8 : 0), radius: highlighted ? 16 : 0)
                .overlay(alignment: .top) { scoreFloat }   // (A) « +N »

            Text("\(player.score) pts")
                .font(.nohemi(.caption2, weight: .semiBold))
                .foregroundStyle(.white.opacity(0.65))
                .monospacedDigit()
                .fixedSize()
        }
        // Tout le VStack grossit/rétrécit ensemble → les points suivent la planète.
        .scaleEffect((entered ? 1 : 0.3) * highlightScale * popScale)
        .opacity(entered ? (dimmed ? 0.32 : 1.0) : 0)
        .onAppear {
            if reduceMotion { entered = true }
            else { withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(Double(index) * 0.07)) { entered = true } }
        }
        .onChange(of: player.score) { old, new in
            guard new > old else { return }
            triggerPop(delta: new - old)
        }
    }

    @ViewBuilder
    private var scoreFloat: some View {
        if let d = popDelta {
            Text("+\(d)")
                .font(.nohemi(.caption, weight: .bold))
                .foregroundStyle(Color.greenGlow)
                .monospacedDigit()
                .fixedSize()
                .offset(y: floatUp ? -size * 0.75 : -size * 0.1)
                .opacity(floatUp ? 0 : 1)
                .onAppear { floatUp = false; withAnimation(.easeOut(duration: 1.0)) { floatUp = true } }
                .onDisappear { floatUp = false }
        }
    }

    private func triggerPop(delta: Int) {
        popDelta = delta
        popTask?.cancel()
        popTask = Task { @MainActor in
            if !reduceMotion {
                withAnimation(.spring(response: 0.22, dampingFraction: 0.45)) { popScale = 1.2 }
                try? await Task.sleep(for: .seconds(0.22))
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { popScale = 1.0 }
            }
            try? await Task.sleep(for: .seconds(0.85))
            popDelta = nil
        }
    }
}

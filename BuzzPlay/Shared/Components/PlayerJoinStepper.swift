//
//  PlayerJoinStepper.swift
//  BuzzPlay
//
//  #invite-progress (G2 v2) — feedback visuel côté Player de SON propre parcours :
//  Connecté → En attente du lancement → C'est parti. 100% local (dérivé de
//  isConnectedToMaster), aucun message réseau. Pendant du MasterReadinessBar.
//
//  Style : étape faite = vert + check ; étape EN COURS = jaune qui pulse ; étape À VENIR
//  = lisible (pas « désactivée »). « C'est parti » reste « à venir » tant qu'on est dans le
//  lobby — elle s'atteint au lancement, instant où le joueur passe sur son buzzer.
//

import SwiftUI

struct PlayerJoinStepper: View {
    let connected: Bool
    @State private var pulse = false

    private enum StepState { case done, current, upcoming }

    var body: some View {
        HStack(spacing: 6) {
            chip("Connecté", icon: "antenna.radiowaves.left.and.right", state: connected ? .done : .current)
            separator(active: connected)
            chip("En attente", icon: "hourglass", state: connected ? .current : .upcoming)
            separator(active: false)
            chip("C'est parti", icon: "play.fill", state: .upcoming)
        }
        .frame(maxWidth: .infinity)
        .onAppear { pulse = true }
    }

    private func separator(active: Bool) -> some View {
        Image(systemName: "chevron.right")
            .font(.nohemi(.caption2, weight: .bold))
            .foregroundStyle(.white.opacity(active ? 0.4 : 0.18))
    }

    @ViewBuilder
    private func chip(_ text: String, icon: String, state: StepState) -> some View {
        let fg: Color
        let bg: Color
        let symbol: String
        let borderOpacity: Double
        switch state {
        case .done:     fg = Color.greenGlow;     bg = Color.greenGlow.opacity(0.15);     symbol = "checkmark"; borderOpacity = 0
        case .current:  fg = Color.mustardYellow; bg = Color.mustardYellow.opacity(0.18); symbol = icon;        borderOpacity = 0
        case .upcoming: fg = Color.textSecondary; bg = Color.white.opacity(0.04);         symbol = icon;        borderOpacity = 0.10
        }
        return HStack(spacing: 4) {
            Image(systemName: symbol)
                .font(.nohemi(.caption2, weight: .bold))
            Text(text)
                .font(.nohemi(.caption2, weight: .semiBold))
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .foregroundStyle(fg)
        .padding(.horizontal, BuzzSpacing.sm)
        .padding(.vertical, 5)
        .background(bg, in: Capsule())
        .overlay(Capsule().strokeBorder(.white.opacity(borderOpacity), lineWidth: 1))
        // Étape en cours : pulse discret (scale = transform, n'affecte pas le layout du HStack).
        .scaleEffect(state == .current && pulse ? 1.05 : 1.0)
        .animation(state == .current
                   ? .easeInOut(duration: 0.9).repeatForever(autoreverses: true)
                   : .default,
                   value: pulse)
    }
}

#Preview {
    ZStack {
        BackgroundAppView().ignoresSafeArea()
        VStack(spacing: 20) {
            PlayerJoinStepper(connected: false)
            PlayerJoinStepper(connected: true)
        }
        .padding()
    }
}

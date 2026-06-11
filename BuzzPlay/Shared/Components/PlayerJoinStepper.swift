//
//  PlayerJoinStepper.swift
//  BuzzPlay
//
//  #invite-progress (G2 v2) — feedback visuel côté Player de SON propre parcours de
//  connexion : Connecté → En attente du lancement → C'est parti. 100% local (dérivé de
//  isConnectedToMaster), aucun message réseau. Pendant du MasterReadinessBar côté Master.
//

import SwiftUI

struct PlayerJoinStepper: View {
    let connected: Bool

    private enum StepState { case done, current, pending }

    var body: some View {
        HStack(spacing: 6) {
            chip("Connecté", icon: "antenna.radiowaves.left.and.right", state: connected ? .done : .current)
            separator
            chip("En attente", icon: "hourglass", state: connected ? .current : .pending)
            separator
            chip("C'est parti", icon: "play.fill", state: .pending)
        }
        .frame(maxWidth: .infinity)
    }

    private var separator: some View {
        Image(systemName: "chevron.right")
            .font(.nohemi(.caption2, weight: .bold))
            .foregroundStyle(.white.opacity(0.25))
    }

    @ViewBuilder
    private func chip(_ text: String, icon: String, state: StepState) -> some View {
        let fg: Color
        let bg: Color
        let symbol: String
        switch state {
        case .done:    fg = Color.greenGlow;     bg = Color.greenGlow.opacity(0.15);     symbol = "checkmark"
        case .current: fg = Color.mustardYellow; bg = Color.mustardYellow.opacity(0.15); symbol = icon
        case .pending: fg = Color.textTertiary;  bg = Color.white.opacity(0.05);         symbol = icon
        }
        return HStack(spacing: 4) {
            Image(systemName: symbol)
                .font(.nohemi(.caption2, weight: .bold))
            Text(text)
                .font(.nohemi(.caption2, weight: .semiBold))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .foregroundStyle(fg)
        .padding(.horizontal, BuzzSpacing.sm)
        .padding(.vertical, 5)
        .background(bg, in: Capsule())
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

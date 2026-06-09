//
//  GamePausedOverlay.swift
//  BuzzPlay
//

import SwiftUI

struct GamePausedOverlay: View {
    let playerName: String?
    @State private var isPulsing = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.80)
                .ignoresSafeArea()

            VStack(spacing: BuzzSpacing.xxl) {
                ZStack {
                    Circle()
                        .fill(Color.yellowLeading.opacity(0.15))
                        .frame(width: 88, height: 88)
                        .scaleEffect(isPulsing ? 1.25 : 1.0)
                        .opacity(isPulsing ? 0.0 : 0.6)
                        .animation(.easeOut(duration: 1.4).repeatForever(autoreverses: false), value: isPulsing)

                    Image(systemName: "pause.circle.fill")
                        .font(.system(size: 52, weight: .semibold))
                        .foregroundStyle(Color.yellowLeading)
                }

                VStack(spacing: BuzzSpacing.sm) {
                    Text("Partie en pause")
                        .font(.nohemi(.title2, weight: .bold))
                        .foregroundStyle(.white)

                    if let name = playerName {
                        Text("En attente de \(name)…")
                            .font(.nohemi(.body, weight: .regular))
                            .foregroundStyle(Color.textSoft)
                    } else {
                        Text("En attente des joueurs…")
                            .font(.nohemi(.body, weight: .regular))
                            .foregroundStyle(Color.textSoft)
                    }
                }

                HStack(spacing: 6) {
                    ProgressView()
                        .tint(Color.textSecondary)
                        .scaleEffect(0.85)
                    Text("Reconnexion automatique")
                        .font(.nohemi(.caption, weight: .medium))
                        .foregroundStyle(Color.textTertiary)
                }
            }
            .padding(36)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: BuzzRadius.xxl))
            .shadow(color: .black.opacity(0.4), radius: 30, y: 10)
        }
        .onAppear { isPulsing = true }
    }
}

#Preview {
    GamePausedOverlay(playerName: "Théo")
}

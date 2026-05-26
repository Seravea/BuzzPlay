//
//  CountdownOverlay.swift
//  BuzzPlay
//

import SwiftUI

struct CountdownOverlay: View {
    let phase: RoundCountdownPhase
    var label: String = "Préparez-vous…"
    var backgroundOpacity: Double = 0.65

    var body: some View {
        ZStack {
            Color.black.opacity(backgroundOpacity)
                .ignoresSafeArea()

            VStack(spacing: 28) {
                switch phase {
                case .counting(let n):
                    Text(label)
                        .font(.nohemi(.title3, weight: .regular))
                        .foregroundStyle(.white.opacity(0.65))

                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.12), lineWidth: 3)
                            .frame(width: 160, height: 160)
                        Circle()
                            .fill(Color.white.opacity(0.07))
                            .frame(width: 160, height: 160)
                        Text("\(n)")
                            .font(.custom("Nohemi-Black", size: 96))
                            .foregroundStyle(.white)
                            .id(n)
                            .transition(.scale(scale: 1.3).combined(with: .opacity))
                    }
                    .animation(.spring(response: 0.35, dampingFraction: 0.55), value: n)

                case .go:
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundStyle(Color(hex: "#7DFFA0"))
                    Text("À VOS BUZZERS !")
                        .font(.custom("Nohemi-Black", size: 28))
                        .tracking(2)
                        .foregroundStyle(Color(hex: "#7DFFA0"))

                case .hidden:
                    EmptyView()
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        CountdownOverlay(phase: .counting(3))
            .frame(maxWidth: .infinity, maxHeight: .infinity)

        CountdownOverlay(phase: .counting(2), label: "Prochain buzz dans")
            .frame(maxWidth: .infinity, maxHeight: .infinity)

        CountdownOverlay(phase: .go)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    .background(BackgroundAppView())
}

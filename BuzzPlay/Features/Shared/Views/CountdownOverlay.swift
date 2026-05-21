//
//  CountdownOverlay.swift
//  BuzzPlay
//

import SwiftUI

struct CountdownOverlay: View {
    let phase: RoundCountdownPhase

    var body: some View {
        ZStack {
            Color.black.opacity(0.65)
                .ignoresSafeArea()

            VStack(spacing: 32) {
                switch phase {
                case .counting(let n):
                    Text("Préparez-vous…")
                        .font(.nohemi(.title3, weight: .regular))
                        .foregroundStyle(.white.opacity(0.65))

                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.12), lineWidth: 3)
                            .frame(width: 150, height: 150)
                        Circle()
                            .fill(Color.white.opacity(0.07))
                            .frame(width: 150, height: 150)
                        Text("\(n)")
                            .font(.custom("Nohemi-Black", size: 80))
                            .foregroundStyle(.white)
                            .id(n)
                            .transition(.scale(scale: 1.4).combined(with: .opacity))
                    }
                    .animation(.spring(response: 0.35, dampingFraction: 0.55), value: n)

                case .go:
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 56, weight: .bold))
                        .foregroundStyle(Color(hex: "#7DFFA0"))
                    Text("À VOS BUZZERS !")
                        .font(.nohemi(.title2, weight: .bold))
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

        CountdownOverlay(phase: .go)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    .background(BackgroundAppView())
}

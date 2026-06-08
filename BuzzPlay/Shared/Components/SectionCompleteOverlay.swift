//
//  SectionCompleteOverlay.swift
//  BuzzPlay
//

import SwiftUI

struct SectionCompleteOverlay: View {
    let gameTitle: String
    let roundsDone: Int
    let roundsTotal: Int

    @State private var scale: CGFloat = 0.8

    var body: some View {
        ZStack {
            Color.black.opacity(0.65)
                .ignoresSafeArea()
                .background(.ultraThinMaterial.opacity(0.3))

            VStack(spacing: BuzzSpacing.xxl) {
                ZStack {
                    Circle()
                        .fill(Color.greenButtonLeading.opacity(0.06))
                        .frame(width: 140, height: 140)
                    Circle()
                        .fill(Color.greenButtonLeading.opacity(0.12))
                        .frame(width: 108, height: 108)
                    Image(systemName: "flag.checkered")
                        .font(.system(size: 50, weight: .semibold))
                        .foregroundStyle(Color.greenButtonLeading)
                }
                .scaleEffect(scale)
                .onAppear {
                    withAnimation(.buzzBouncy) {
                        scale = 1.0
                    }
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }

                VStack(spacing: BuzzSpacing.sm) {
                    Text("\(gameTitle) terminé !")
                        .font(.nohemi(.title2, weight: .extraBold))
                        .foregroundStyle(.white)

                    Text("\(roundsDone) manche\(roundsDone > 1 ? "s" : "") jouée\(roundsDone > 1 ? "s" : "")")
                        .font(.nohemi(.body, weight: .regular))
                        .foregroundStyle(.textSecondary)
                }

                PlayerPulsingPill(text: "Retour au menu…")
            }
            .padding(40)
        }
    }
}

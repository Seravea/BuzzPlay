//
//  QuizValidationOverlay.swift
//  BuzzPlay
//

import SwiftUI

// MARK: - Validation Overlay

struct QuizValidationOverlay: View {
    let points: Int
    let teamName: String
    @State private var scale: CGFloat = 0.8

    var body: some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()
                .background(.ultraThinMaterial)

            VStack(spacing: BuzzSpacing.lg) {
                ZStack {
                    // Glow circles
                    Circle()
                        .fill(Color.greenGlow.opacity(0.15))
                        .frame(width: 120, height: 120)
                        .blur(radius: 16)

                    VStack(spacing: BuzzSpacing.md) {
                        Image(systemName: BuzzIcon.check)
                            .font(.system(size: 56))
                            .foregroundStyle(Color.greenGlow)
                        Text("+\(points)")
                            .font(.nohemi(.largeTitle, weight: .black)).titleTracking()
                            .foregroundStyle(Color.greenGlow)
                            .tracking(1)
                    }
                }
                .scaleEffect(scale)
                .onAppear {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.65)) {
                        scale = 1.0
                    }
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }

                Text(teamName)
                    .font(.nohemi(.body, weight: .semiBold))
                    .foregroundStyle(Color.textSoft)
            }
            .padding(BuzzSpacing.xxxl)
        }
    }
}

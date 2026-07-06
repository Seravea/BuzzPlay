//
//  AnswerFeedbackOverlay.swift
//  BuzzPlay
//

import SwiftUI

// MARK: - Answer Feedback Overlay (#B5 — Neon Gradient Blast)

struct AnswerFeedbackOverlay: View {
    let result: AnswerResult

    @State private var glowPulse = false

    private var gradientColors: [Color] {
        switch result {
        case .correct:      [Color.greenButtonLeading, Color.greenTrailing]
        case .incorrect:    [Color.redLeading, Color.purpleTrailing]
        case .otherCorrect: [Color.yellowLeading, Color.yellowTrailing]
        }
    }

    private var label: String {
        switch result {
        case .correct:      "BONNE RÉPONSE"
        case .incorrect:    "MAUVAISE RÉPONSE"
        case .otherCorrect: ""
        }
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.65)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Gradient card
                VStack(spacing: 18) {
                    switch result {
                    case .correct(let points, let answer):
                        Text(label)
                            .font(.custom("Nohemi-Black", size: 28))
                            .tracking(4)
                            .foregroundStyle(.white)
                            .shadow(color: gradientColors[0].opacity(glowPulse ? 0.9 : 0.4), radius: glowPulse ? 20 : 8)
                            .multilineTextAlignment(.center)

                        if let answer {
                            Text(answer)
                                .font(.custom("Nohemi-SemiBold", size: 20))
                                .foregroundStyle(.white.opacity(0.90))
                                .multilineTextAlignment(.center)
                        }

                        // Score badge
                        Text("+\(points) POINT\(points > 1 ? "S" : "")")
                            .font(.custom("Nohemi-Black", size: 22))
                            .tracking(2)
                            .foregroundStyle(.white)
                            .padding(.horizontal, BuzzSpacing.xl)
                            .padding(.vertical, 10)
                            .background(Color.black.opacity(0.30), in: Capsule())
                            .overlay(Capsule().strokeBorder(Color.textDim, lineWidth: 1))

                    case .incorrect:
                        Text(label)
                            .font(.custom("Nohemi-Black", size: 28))
                            .tracking(4)
                            .foregroundStyle(.white)
                            .shadow(color: gradientColors[0].opacity(glowPulse ? 0.9 : 0.4), radius: glowPulse ? 20 : 8)
                            .multilineTextAlignment(.center)

                    case .otherCorrect(let name, let points, let answer):
                        Text("\(name) A TROUVÉ !")
                            .font(.custom("Nohemi-Black", size: 26))
                            .tracking(3)
                            .foregroundStyle(.white)
                            .shadow(color: gradientColors[0].opacity(glowPulse ? 0.9 : 0.4), radius: glowPulse ? 20 : 8)
                            .multilineTextAlignment(.center)

                        if let answer {
                            Text(answer)
                                .font(.custom("Nohemi-SemiBold", size: 19))
                                .foregroundStyle(.white.opacity(0.90))
                                .multilineTextAlignment(.center)
                        }

                        Text("+\(points) PT\(points > 1 ? "S" : "") POUR \(name.uppercased())")
                            .font(.custom("Nohemi-Black", size: 16))
                            .tracking(2)
                            .foregroundStyle(.white)
                            .padding(.horizontal, BuzzSpacing.xl)
                            .padding(.vertical, 10)
                            .background(Color.black.opacity(0.30), in: Capsule())
                            .overlay(Capsule().strokeBorder(Color.textDim, lineWidth: 1))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 36)
                .padding(.horizontal, BuzzSpacing.xxxl)
                .background(
                    LinearGradient(
                        colors: gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    in: RoundedRectangle(cornerRadius: BuzzRadius.sheet)
                )
                .shadow(color: gradientColors[0].opacity(glowPulse ? 0.55 : 0.25), radius: glowPulse ? 32 : 14)
            }
            .padding(.horizontal, BuzzSpacing.xxxl)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                glowPulse = true
            }
        }
    }
}

//
//  QuizScoreRow.swift
//  BuzzPlay
//

import SwiftUI

// MARK: - Score Row

struct QuizScoreRow: View {
    let player: Player
    let maxScore: Int
    @State private var scoreChanged = false

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(player.teamColor.color)
                .frame(width: 8, height: 8)

            Text(player.name)
                .font(.nohemi(.subheadline, weight: .semiBold))
                .foregroundStyle(.white)

            Spacer()

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(.white.opacity(0.1)).frame(height: 4)
                    let w = maxScore > 0 ? CGFloat(player.score) / CGFloat(maxScore) * geo.size.width : 0
                    Capsule()
                        .fill(player.teamColor.gradient)
                        .frame(width: w, height: 4)
                        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: player.score)
                }
            }
            .frame(width: 80, height: 4)

            Text("\(player.score) pts")
                .font(.nohemi(.subheadline, weight: .bold))
                .foregroundStyle(.white.opacity(0.9))
                .frame(minWidth: 50, alignment: .trailing)
                .scaleEffect(scoreChanged ? 1.1 : 1.0)
                .animation(.buzzEase, value: scoreChanged)
        }
        .padding(.horizontal, BuzzSpacing.md)
        .padding(.vertical, 10)
        .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: BuzzRadius.md))
        .overlay(RoundedRectangle(cornerRadius: BuzzRadius.md).strokeBorder(.white.opacity(0.07), lineWidth: 1))
        .shadow(color: player.teamColor.color.opacity(0.15), radius: 8, y: 3)
        .onChange(of: player.score) { oldScore, newScore in
            if newScore > oldScore {
                scoreChanged = true
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    scoreChanged = false
                }
            }
        }
    }
}

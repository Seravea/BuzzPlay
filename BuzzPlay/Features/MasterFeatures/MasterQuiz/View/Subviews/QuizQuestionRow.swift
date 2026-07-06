//
//  QuizQuestionRow.swift
//  BuzzPlay
//

import SwiftUI

// MARK: - Question Row

struct QuizQuestionRow: View {
    let number: Int
    let question: QuizQuestion
    let isDone: Bool
    let isDisabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: BuzzSpacing.md) {
                // Number badge with difficulty color
                Text("\(number)")
                    .font(.nohemi(.caption, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 32, height: 32)
                    .background(badgeColor, in: RoundedRectangle(cornerRadius: BuzzRadius.sm2))

                VStack(alignment: .leading, spacing: 2) {
                    Text(question.title)
                        .font(.nohemi(.subheadline, weight: .semiBold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.leading)
                    HStack(spacing: 6) {
                        if question.questionType == .rebus {
                            Label("Rébus", systemImage: "theatermasks.fill")
                                .font(.nohemi(.caption2, weight: .semiBold))
                                .foregroundStyle(Color.purpleLeading.opacity(0.9))
                        } else if let theme = question.theme {
                            Text(theme)
                                .font(.nohemi(.caption2, weight: .medium))
                                .foregroundStyle(Color.textMuted)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                if isDone {
                    Image(systemName: "checkmark")
                        .textStyle(Typography.footnoteEM)
                        .foregroundStyle(Color.greenButtonLeading)
                } else if !isDisabled {
                    Image(systemName: "chevron.right")
                        .textStyle(Typography.footnoteEM)
                        .foregroundStyle(Color.textFaint)
                }
            }
            .padding(14)
            .background(.white.opacity(isDone ? 0.06 : 0.06), in: RoundedRectangle(cornerRadius: BuzzRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: BuzzRadius.lg)
                    .strokeBorder(isDone ? Color.greenButtonLeading.opacity(0.25) : .white.opacity(0.08), lineWidth: 1.5)
            )
            .opacity(isDone ? 0.6 : 1)
        }
        .disabled(isDisabled || isDone)
        .opacity(isDisabled && !isDone ? 0.3 : 1)
        .buttonStyle(.plain)
    }

    private var badgeColor: Color {
        if isDone { return .white.opacity(0.1) }
        guard let difficulty = question.difficulty else { return .white.opacity(0.1) }
        return difficulty.color.opacity(0.35)
    }
}

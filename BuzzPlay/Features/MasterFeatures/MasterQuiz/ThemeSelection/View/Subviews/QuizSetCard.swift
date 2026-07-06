//
//  QuizSetCard.swift
//  BuzzPlay
//

import SwiftUI

// MARK: - Quiz Set Card

struct QuizSetCard: View {
    let set: QuizSet
    let themeColor: Color
    let action: () -> Void

    private var difficultyRange: String {
        let diffs = set.questions.compactMap(\.difficulty)
        guard !diffs.isEmpty else { return "" }
        let difficultyOrder: [QuizDifficulty] = [.expert, .difficile, .moyen, .facile]
        if let highest = diffs.first(where: { difficultyOrder.contains($0) }) {
            return highest.label
        }
        return diffs.first?.label ?? ""
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(themeColor)
                    .frame(width: 4)
                    .padding(.vertical, 4)

                VStack(alignment: .leading, spacing: BuzzSpacing.xs) {
                    Text(set.title)
                        .font(.nohemi(.body, weight: .semiBold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.leading)

                    HStack(spacing: BuzzSpacing.sm) {
                        Label("\(set.questions.count) questions", systemImage: "list.bullet")
                            .font(.nohemi(.caption, weight: .medium))
                            .foregroundStyle(Color.textTertiary)

                        if !difficultyRange.isEmpty {
                            Text("·")
                                .foregroundStyle(.white.opacity(0.3))
                            Text(difficultyRange)
                                .font(.nohemi(.caption, weight: .medium))
                                .foregroundStyle(Color.textTertiary)
                        }
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .textStyle(Typography.footnoteEM)
                    .foregroundStyle(Color.textFaint)
            }
            .padding(.vertical, 14)
            .padding(.trailing, 14)
            .padding(.leading, BuzzSpacing.md)
            .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: BuzzRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: BuzzRadius.lg)
                    .strokeBorder(.white.opacity(0.08), lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}

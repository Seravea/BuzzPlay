//
//  ThemeSection.swift
//  BuzzPlay
//

import SwiftUI

// MARK: - Theme Section (avec sets curatés)

struct ThemeSection: View {
    let theme: QuizTheme
    let sets: [QuizSet]
    let onSelect: (QuizSet) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: theme.iconName)
                    .textStyle(Typography.cardTitle)
                    .foregroundStyle(theme.color)
                    .frame(width: 38, height: 38)
                    .background(theme.color.opacity(0.18), in: RoundedRectangle(cornerRadius: BuzzRadius.sm2))
                    .overlay(RoundedRectangle(cornerRadius: BuzzRadius.sm2).strokeBorder(theme.color.opacity(0.35), lineWidth: 1))

                Text(theme.title)
                    .font(.nohemi(.title3, weight: .bold)).titleTracking()
                    .foregroundStyle(.white)

                Spacer()

                Text("\(sets.count) quiz")
                    .font(.nohemi(.caption, weight: .semiBold))
                    .foregroundStyle(Color.textMuted)
            }
            .padding(.horizontal, BuzzSpacing.xl)

            VStack(spacing: BuzzSpacing.sm) {
                ForEach(sets) { set in
                    QuizSetCard(set: set, themeColor: theme.color) {
                        onSelect(set)
                    }
                }
            }
            .padding(.horizontal, BuzzSpacing.lg)
        }
    }
}

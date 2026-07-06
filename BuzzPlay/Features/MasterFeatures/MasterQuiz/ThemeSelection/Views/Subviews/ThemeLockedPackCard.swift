//
//  ThemeLockedPackCard.swift
//  BuzzPlay
//

import SwiftUI

// MARK: - #v1-packs — pack premium verrouillé (card cadenas → sheet d'achat)

struct ThemeLockedPackCard: View {
    let theme: QuizTheme
    let pack: RemoteQuizPack
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: BuzzSpacing.md) {
                Image(systemName: theme.iconName)
                    .textStyle(Typography.label)
                    .foregroundStyle(theme.color)
                    .frame(width: 36, height: 36)
                    .background(theme.color.opacity(0.14), in: RoundedRectangle(cornerRadius: BuzzRadius.sm2))
                    .overlay(RoundedRectangle(cornerRadius: BuzzRadius.sm2).strokeBorder(theme.color.opacity(0.25), lineWidth: 1))

                VStack(alignment: .leading, spacing: 2) {
                    Text(theme.title)
                        .font(.nohemi(.subheadline, weight: .bold))
                        .foregroundStyle(.white)
                    Text("Pack premium — \(pack.sets.count) quiz")
                        .font(.nohemi(.caption, weight: .medium))
                        .foregroundStyle(Color.textSecondary)
                }

                Spacer()

                HStack(spacing: 5) {
                    Image(systemName: "lock.fill")
                        .textStyle(Typography.caption2)
                    Text(pack.priceDisplay ?? "Premium")
                        .font(.nohemi(.caption, weight: .bold))
                }
                .foregroundStyle(Color.mustardYellow)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.mustardYellow.opacity(0.12), in: Capsule())
                .overlay(Capsule().strokeBorder(Color.mustardYellow.opacity(0.30), lineWidth: 1))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, BuzzSpacing.md)
            .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: BuzzRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: BuzzRadius.lg)
                    .strokeBorder(.white.opacity(0.10), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

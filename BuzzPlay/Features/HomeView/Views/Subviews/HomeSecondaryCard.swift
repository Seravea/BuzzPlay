//
//  HomeSecondaryCard.swift
//  BuzzPlay
//

import SwiftUI

// MARK: - Carte de rôle secondaire (« Animer »)

struct HomeSecondaryCard: View {
    let title: String
    let subtitle: String
    let iconName: String

    var body: some View {
        HStack(spacing: HomeCardMetrics.iconTextSpacing) {
            Image(systemName: iconName)
                .font(.system(size: 22, weight: .semibold))   // taille SF Symbol — carte secondaire (plus petite)
                .foregroundStyle(.white.opacity(0.80))
                .frame(width: 46, height: 46)
                .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: BuzzRadius.lg))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.nohemi(.title3, weight: .extraBold))
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.nohemi(.subheadline))
                    .foregroundStyle(.white.opacity(0.60))
            }

            Spacer()

            Image(systemName: "arrow.right")
                .font(.system(size: HomeCardMetrics.trailingPointSize, weight: .semibold))
                .foregroundStyle(.white.opacity(0.55))
        }
        .padding(HomeCardMetrics.padding)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: HomeCardMetrics.corner))
        .overlay(RoundedRectangle(cornerRadius: HomeCardMetrics.corner).strokeBorder(.white.opacity(0.18), lineWidth: 1))
    }
}

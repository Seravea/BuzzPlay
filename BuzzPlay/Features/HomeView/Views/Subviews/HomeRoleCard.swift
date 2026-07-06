//
//  HomeRoleCard.swift
//  BuzzPlay
//

import SwiftUI

// MARK: - Carte de rôle principale (« Rejoindre »)

struct HomeRoleCard: View {
    let title: String
    let subtitle: String
    let iconName: String
    let gradient: LinearGradient
    let shadowColor: Color?

    var body: some View {
        HStack(spacing: HomeCardMetrics.iconTextSpacing) {
            Image(systemName: iconName)
                .font(.system(size: 28, weight: .semibold))   // taille SF Symbol — carte principale (plus grande)
                .frame(width: 58, height: 58)
                .background(.white.opacity(0.18), in: RoundedRectangle(cornerRadius: BuzzRadius.lg))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.nohemi(.title, weight: .extraBold))
                Text(subtitle)
                    .font(.nohemi(.subheadline))
                    .foregroundStyle(.white.opacity(0.85))
            }

            Spacer()

            Image(systemName: "arrow.right")
                .font(.system(size: HomeCardMetrics.trailingPointSize, weight: .semibold))
                .foregroundStyle(.white.opacity(0.90))
        }
        .foregroundStyle(.white)
        .padding(HomeCardMetrics.padding)
        .background(gradient, in: RoundedRectangle(cornerRadius: HomeCardMetrics.corner))
        .shadow(color: shadowColor ?? .clear, radius: 20, y: 8)
    }
}

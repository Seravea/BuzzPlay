//
//  LobbyTeamRow.swift
//  BuzzPlay
//

import SwiftUI

// MARK: - Team Row

struct LobbyTeamRow: View {
    let player: Player

    var body: some View {
        HStack(spacing: BuzzSpacing.md) {
            RoundedRectangle(cornerRadius: BuzzRadius.sm)
                .fill(player.teamColor.gradient)
                .frame(width: 44, height: 44)
                .overlay(
                    Text(String(player.name.prefix(1)).uppercased())
                        .font(.nohemi(.body, weight: .extraBold))
                        .foregroundStyle(.white)
                )

            Text(player.name)
                .font(.nohemi(.body, weight: .bold))
                .foregroundStyle(.white)

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .textStyle(Typography.cardTitle)
                .foregroundStyle(Color.greenGlow)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, BuzzSpacing.md)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: BuzzRadius.lg))
        .overlay(RoundedRectangle(cornerRadius: BuzzRadius.lg).strokeBorder(.white.opacity(0.08), lineWidth: 1))
    }
}

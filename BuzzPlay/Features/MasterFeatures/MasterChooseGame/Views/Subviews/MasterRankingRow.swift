//
//  MasterRankingRow.swift
//  BuzzPlay
//
//  Ligne du classement mi-partie du hub Master : rang + avatar + nom/score + barre de progression.
//  Extrait de MasterChooseGameView (affichage pur, sans logique ni navigation).
//

import SwiftUI

struct MasterRankingRow: View {
    let rank: Int
    let player: Player
    let maxScore: Int

    var body: some View {
        HStack(spacing: 10) {
            BuzzCountBadge("\(rank)",
                           diameter: 24, fontSize: 11,
                           fill: AnyShapeStyle(rank == 1 ? Color.mustardYellow : .white.opacity(0.10)),
                           textColor: rank == 1 ? Color.sheetBg : .white.opacity(0.6))

            BuzzCountBadge(String(player.name.prefix(1)).uppercased(),
                           diameter: 36, fontSize: 16, weight: .bold,
                           fill: AnyShapeStyle(player.teamColor.gradient),
                           textColor: .white)

            VStack(alignment: .leading, spacing: BuzzSpacing.xs) {
                HStack {
                    Text(player.name)
                        .font(.nohemi(.subheadline, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Spacer()
                    Text("\(player.score)")
                        .font(.nohemi(.subheadline, weight: .black))
                        .foregroundStyle(.white)
                        .monospacedDigit()
                }

                GeometryReader { geo in
                    RoundedRectangle(cornerRadius: BuzzRadius.pill)
                        .fill(.white.opacity(0.10))
                        .overlay(alignment: .leading) {
                            RoundedRectangle(cornerRadius: BuzzRadius.pill)
                                .fill(player.teamColor.gradient)
                                .frame(width: geo.size.width * CGFloat(player.score) / CGFloat(maxScore))
                        }
                }
                .frame(height: 4)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, BuzzSpacing.sm)
        .background(
            rank == 1 ? Color.mustardYellow.opacity(0.08) : Color.clear,
            in: RoundedRectangle(cornerRadius: BuzzRadius.sm)
        )
    }
}

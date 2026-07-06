//
//  PodiumSlot.swift
//  BuzzPlay
//
//  Une marche du podium du classement final (rang 1/2/3) : couronne (1er), avatar,
//  nom, score et le bloc numéroté dont la hauteur dépend du rang. Affichage pur.
//  Extrait de ScoreMasterView.
//

import SwiftUI

struct PodiumSlot: View {
    let rank: Int
    let player: Player

    var body: some View {
        let avatarSize: CGFloat = rank == 1 ? 72 : rank == 2 ? 56 : 48
        let blockHeight: CGFloat = rank == 1 ? 120 : rank == 2 ? 80 : 56
        let blockGradient: AnyShapeStyle = rank == 1
            ? AnyShapeStyle(LinearGradient(colors: [Color.mustardYellow, Color.yellowTrailing], startPoint: .top, endPoint: .bottom))
            : AnyShapeStyle(.white.opacity(rank == 2 ? 0.12 : 0.08))
        let blockRadius: CGFloat = rank == 1 ? 14 : 10

        return VStack(spacing: 0) {
            if rank == 1 {
                Image(systemName: BuzzIcon.crown)
                    .textStyle(Typography.sectionTitle)
                    .foregroundStyle(Color.mustardYellow)
                    .padding(.bottom, 4)
            }

            Circle()
                .fill(player.teamColor.gradient)
                .frame(width: avatarSize, height: avatarSize)
                .overlay(
                    Text(String(player.name.prefix(1)).uppercased())
                        .font(.custom("Nohemi-Black", size: avatarSize * 0.42))
                        .foregroundStyle(.white)
                        .nohemiBadgeNudge(fontSize: avatarSize * 0.42)
                )
                .overlay(
                    Circle()
                        .strokeBorder(rank == 1 ? Color.mustardYellow : .white.opacity(0.18), lineWidth: 2)
                )

            Text(player.name)
                .font(.nohemi(rank == 1 ? .subheadline : .caption, weight: .bold))
                .foregroundStyle(rank == 1 ? Color.mustardYellow : .white)
                .lineLimit(1)
                .padding(.top, BuzzSpacing.sm)

            Text("\(player.score) pts")
                .font(.nohemi(.caption2, weight: .medium))
                .foregroundStyle(.white.opacity(rank == 1 ? 0.7 : 0.5))
                .padding(.top, 1)

            ZStack(alignment: .center) {
                RoundedRectangle(cornerRadius: blockRadius)
                    .fill(blockGradient)
                    .overlay(
                        RoundedRectangle(cornerRadius: blockRadius)
                            .strokeBorder(.white.opacity(rank == 1 ? 0 : 0.08), lineWidth: 1)
                    )

                let rankSize: CGFloat = rank == 1 ? 44 : rank == 2 ? 32 : 26
                Text("\(rank)")
                    .font(.custom("Nohemi-Black", size: rankSize))
                    .foregroundStyle(rank == 1 ? Color.sheetBg : Color.textSecondary)
                    .nohemiBadgeNudge(fontSize: rankSize)
            }
            .frame(maxWidth: .infinity)
            .frame(height: blockHeight)
            .padding(.top, 10)
        }
        .frame(maxWidth: .infinity)
        .shadow(color: rank == 1 ? Color.mustardYellow.opacity(0.35) : .clear, radius: 20, y: -6)
    }
}

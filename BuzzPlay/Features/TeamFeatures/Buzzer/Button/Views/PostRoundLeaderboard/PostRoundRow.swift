//
//  PostRoundRow.swift
//  BuzzPlay
//

import SwiftUI

// MARK: - Row

struct PostRoundRow: View {
    let rank: Int
    let player: Player
    let scoreDelta: Int
    let rankDelta: Int
    let showDelta: Bool

    var body: some View {
        HStack(spacing: BuzzSpacing.md) {
            rankBadge
            playerAvatar
            nameAndScore
            Spacer()
            if showDelta { deltaBadges }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(rowBackground, in: RoundedRectangle(cornerRadius: BuzzRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: BuzzRadius.lg)
                .strokeBorder(rowBorder, lineWidth: 1)
        )
    }

    private var rankBadge: some View {
        BuzzCountBadge("\(rank)",
                       diameter: 34, fontSize: 15,
                       fill: AnyShapeStyle(rankCircleColor),
                       textColor: rank <= 3 ? Color.sheetBg : .white)
    }

    private var playerAvatar: some View {
        BuzzCountBadge(String(player.name.prefix(1)).uppercased(),
                       diameter: 34, fontSize: 15,
                       fill: AnyShapeStyle(player.teamColor.gradient),
                       textColor: .white)
    }

    private var nameAndScore: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(player.name)
                .font(.nohemi(.subheadline, weight: .bold))
                .foregroundStyle(.white)
                .lineLimit(1)
            Text("\(player.score) pts")
                .font(.nohemi(.caption, weight: .medium))
                .foregroundStyle(.white.opacity(0.50))
                .monospacedDigit()   // largeur de chiffre fixe → pas de tremblement
                // pas de contentTransition : mise à jour sans roulement, 0 mouvement
        }
    }

    @ViewBuilder
    private var deltaBadges: some View {
        HStack(spacing: 6) {
            if scoreDelta > 0 {
                // #R2 — norme pill : la capsule centre le texte mono-ligne par défaut
                // (+ .fixedSize via pillStyle) → plus de padding asymétrique à régler.
                Text("+\(scoreDelta)")
                    .font(.nohemi(.caption, weight: .extraBold))
                    .foregroundStyle(Color.greenButtonLeading)
                    .pillStyle(fill: Color.greenButtonLeading.opacity(0.15),
                               stroke: Color.greenButtonLeading.opacity(0.35),
                               compact: true)
                    .transition(.scale(scale: 0.6).combined(with: .opacity))
            }

            if rankDelta != 0 {
                let up = rankDelta > 0
                // symbole interpolé dans le Text → flèche alignée sur le chiffre.
                Text("\(Image(systemName: up ? "arrow.up" : "arrow.down")) \(abs(rankDelta))")
                    .font(.nohemi(.caption2, weight: .extraBold))
                    .foregroundStyle(up ? Color.greenButtonLeading : Color.redSoft)
                    .pillStyle(fill: (up ? Color.greenButtonLeading : Color.redSoft).opacity(0.12),
                               stroke: nil,
                               compact: true)
                    .transition(.scale(scale: 0.6).combined(with: .opacity))
            }
        }
    }

    // MARK: - Style helpers

    private var rankCircleColor: Color {
        switch rank {
        case 1: Color.amberWarm
        case 2: Color.white
        case 3: Color.burnOrange
        default: .white.opacity(0.12)
        }
    }

    // #B10 — fond neutre basé sur le rang, pas sur la teamColor du joueur
    // (évite la collision rouge/vert avec le feedback bonne/mauvaise réponse)
    private var rowBackground: AnyShapeStyle {
        switch rank {
        case 1: AnyShapeStyle(Color.amberWarm.opacity(0.10))
        case 2: AnyShapeStyle(Color.white.opacity(0.08))
        case 3: AnyShapeStyle(Color.burnOrange.opacity(0.08))
        default: AnyShapeStyle(Color.white.opacity(0.04))
        }
    }

    private var rowBorder: Color {
        switch rank {
        case 1: Color.amberWarm.opacity(0.30)
        case 2: .white.opacity(0.15)
        case 3: Color.burnOrange.opacity(0.22)
        default: .white.opacity(0.07)
        }
    }
}

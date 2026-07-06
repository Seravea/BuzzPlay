//
//  BlindTestBuzzPlayerCard.swift
//  BuzzPlay
//
//  Carte joueur détaillée de la sheet de validation buzz (mode non-compact) :
//  avatar couleur d'équipe + nom + badge temps de réaction. Extrait de BlindTestBuzzSheet.
//

import SwiftUI

struct BlindTestBuzzPlayerCard: View {
    let player: Player
    let reactionTime: String

    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: BuzzRadius.md)
                .fill(player.teamColor.gradient)
                .frame(width: 46, height: 46)
                .overlay(
                    Text(String(player.name.prefix(1)))
                        .font(.nohemi(.title3, weight: .bold)).titleTracking()
                        .foregroundStyle(.white)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(player.name)
                    .font(.nohemi(.body, weight: .bold))
                    .foregroundStyle(.white)

            }

            Spacer()

            VStack(spacing: 2) {
                Text("RÉACTION")
                    .font(.nohemi(.caption2, weight: .bold))
                    .foregroundStyle(Color.textSecondary)
                    .tracking(0.5)
                Text(reactionTime)
                    .font(.nohemi(.body, weight: .extraBold))
                    .foregroundStyle(Color.mustardYellow)
                    .monospacedDigit()   // largeur de chiffre fixe → pas de tremblement
                    // pas de contentTransition/animation : 0 mouvement de roulement
            }
            .padding(.horizontal, BuzzSpacing.md)
            .padding(.vertical, 6)
            .background(Color.mustardYellow.opacity(0.12), in: RoundedRectangle(cornerRadius: BuzzRadius.sm))
            .overlay(RoundedRectangle(cornerRadius: BuzzRadius.sm).strokeBorder(Color.mustardYellow.opacity(0.25), lineWidth: 1))
        }
        .padding(.horizontal, BuzzSpacing.lg)
        .padding(.vertical, 14)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: BuzzRadius.lg2))
        .overlay(
            RoundedRectangle(cornerRadius: BuzzRadius.lg2)
                .strokeBorder(.white.opacity(0.1), lineWidth: 1)
        )
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: BuzzRadius.xxs)
                .fill(player.teamColor.gradient)
                .frame(width: 4)
                .padding(.leading, 0)
                .clipShape(RoundedRectangle(cornerRadius: BuzzRadius.lg2))
        }
    }
}

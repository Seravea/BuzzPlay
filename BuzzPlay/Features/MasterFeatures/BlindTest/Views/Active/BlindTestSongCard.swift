//
//  BlindTestSongCard.swift
//  BuzzPlay
//
//  Carte musique réutilisable (style de l'ancienne songCard) MAIS sans poster : le slot avant
//  est une pastille tintée avec un numéro (file « À venir ») ou une icône note (morceau en cours).
//  Utilisée pour la file à venir (variante numéro) ET le « EN COURS » sous la scène (variante label).
//

import SwiftUI

struct BlindTestSongCard: View {
    let song: BlindTestSong?
    /// Label au-dessus du titre (ex. « EN COURS »). Exclusif avec `number` en pratique.
    var topLabel: String? = nil
    /// Position dans la file (« À venir ») → affichée dans la pastille avant à la place du poster.
    var number: Int? = nil
    /// Affiche l'indicateur waveform animé (morceau en cours de lecture).
    var showWaveform: Bool = false
    /// Largeur fixe (pour le scroll horizontal de la file) ; nil = pleine largeur.
    var width: CGFloat? = nil

    var body: some View {
        HStack(spacing: 12) {
            leading

            VStack(alignment: .leading, spacing: 2) {
                if let topLabel {
                    Text(topLabel)
                        .font(.nohemi(.caption2, weight: .bold))
                        .foregroundStyle(Color.textMuted)
                        .tracking(0.8)
                }
                Text(song?.title ?? "—")
                    .font(.nohemi(.subheadline, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text(song?.artist ?? "—")
                    .font(.nohemi(.caption, weight: .medium))
                    .foregroundStyle(Color.textSecondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)

            if showWaveform {
                Image(systemName: "waveform")
                    .symbolEffect(.variableColor.iterative)
                    .font(.title3)
                    .foregroundStyle(Color.mustardYellow)
            }
        }
        .padding(.horizontal, BuzzSpacing.md)
        .padding(.vertical, 10)
        .frame(width: width)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: BuzzRadius.lg))
        .overlay(RoundedRectangle(cornerRadius: BuzzRadius.lg).strokeBorder(.white.opacity(0.1), lineWidth: 1))
    }

    // Pas de poster : pastille tintée (numéro de file, ou icône note pour le morceau en cours).
    private var leading: some View {
        RoundedRectangle(cornerRadius: BuzzRadius.sm)
            .fill(LinearGradient(colors: [.purpleLeading, .purpleTrailing],
                                 startPoint: .topLeading, endPoint: .bottomTrailing))
            .frame(width: 38, height: 38)
            .overlay {
                if let number {
                    Text("\(number)")
                        .font(.custom("Nohemi-Black", size: 16))
                        .foregroundStyle(.white)
                        .nohemiBadgeNudge(fontSize: 16)
                } else {
                    Image(systemName: "music.note")
                        .font(.subheadline)
                        .foregroundStyle(.white)
                }
            }
    }
}

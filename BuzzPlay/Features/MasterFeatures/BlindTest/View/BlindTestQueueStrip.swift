//
//  BlindTestQueueStrip.swift
//  BuzzPlay
//
//  Bande « À VENIR » en haut de l'écran de lecture Master : la file des prochains morceaux
//  (mini-playlist). Le morceau en cours est le « soleil » au centre — ici on montre la SUITE.
//

import SwiftUI

struct BlindTestQueueStrip: View {
    let queue: [BlindTestSong]
    let currentIndex: Int
    /// Nombre de vignettes affichées avant le « +N ».
    var maxVisible: Int = 4

    private var upcoming: [BlindTestSong] {
        guard currentIndex + 1 < queue.count else { return [] }
        return Array(queue[(currentIndex + 1)...])
    }

    var body: some View {
        if !upcoming.isEmpty {
            VStack(alignment: .leading, spacing: 6) {
                Text("À VENIR")
                    .font(.nohemi(.caption2, weight: .bold))
                    .foregroundStyle(Color.textDim)
                    .tracking(0.8)
                    .padding(.leading, 2)

                HStack(spacing: 8) {
                    ForEach(Array(upcoming.prefix(maxVisible).enumerated()), id: \.element.id) { idx, song in
                        tile(song: song, number: currentIndex + 2 + idx)
                    }
                    if upcoming.count > maxVisible {
                        moreTile(count: upcoming.count - maxVisible)
                    }
                }
            }
        }
    }

    private func tile(song: BlindTestSong, number: Int) -> some View {
        AsyncImage(url: song.postertURL) { image in
            image.resizable().scaledToFill()
        } placeholder: {
            LinearGradient(colors: [.purpleLeading, .purpleTrailing],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .overlay(Image(systemName: "music.note").font(.subheadline).foregroundStyle(.white.opacity(0.8)))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 46)
        .clipShape(RoundedRectangle(cornerRadius: BuzzRadius.sm))
        .overlay(alignment: .topLeading) {
            Text("\(number)")
                .font(.nohemi(.caption2, weight: .bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 5)
                .padding(.vertical, 1)
                .background(Color.darkestPurple.opacity(0.8), in: Capsule())
                .padding(4)
        }
        .overlay(RoundedRectangle(cornerRadius: BuzzRadius.sm).strokeBorder(.white.opacity(0.1), lineWidth: 1))
    }

    private func moreTile(count: Int) -> some View {
        Text("+\(count)")
            .font(.nohemi(.body, weight: .bold))
            .foregroundStyle(Color.textMuted)
            .frame(maxWidth: .infinity)
            .frame(height: 46)
            .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: BuzzRadius.sm))
            .overlay(RoundedRectangle(cornerRadius: BuzzRadius.sm).strokeBorder(.white.opacity(0.08), lineWidth: 1))
    }
}

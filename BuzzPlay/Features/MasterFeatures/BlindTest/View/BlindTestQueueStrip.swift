//
//  BlindTestQueueStrip.swift
//  BuzzPlay
//
//  Bande « À VENIR » en haut de l'écran de lecture Master : la file des prochains morceaux
//  (mini-playlist), en cartes musique (sans poster) qui défilent horizontalement.
//

import SwiftUI

struct BlindTestQueueStrip: View {
    let queue: [BlindTestSong]
    let currentIndex: Int

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

                ScrollView(.horizontal) {
                    HStack(spacing: 8) {
                        ForEach(Array(upcoming.enumerated()), id: \.element.id) { idx, song in
                            BlindTestSongCard(song: song, number: currentIndex + 2 + idx, width: 210)
                        }
                    }
                    .padding(.horizontal, 2)
                }
                .scrollIndicators(.hidden)
            }
        }
    }
}

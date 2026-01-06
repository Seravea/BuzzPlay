//
//  SongCards.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 17/12/2025.
//

import SwiftUI
import MusicKit

struct SongCard: View {
    var song: BlindTestSong
    var selectedSong: BlindTestSong?
    var canPlayFullTrack: Bool
    
    var body: some View {
        
        HStack(alignment: .top) {
                AsyncImage(url: song.postertURL) { PosterImage in
                    PosterImage
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(8)
                } placeholder: {
                    ProgressView()
                        .frame(width: 80, height: 80)
                }
                VStack(alignment: .leading) {
                    Text("Titre : \(song.title)")
                        .font(.poppins(.headline))
                        .bold()
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Artiste : \(song.artist)")
                        .font(.poppins(.body))
                    Text("Sortie : \(song.releaseYearString)")
                }
                .appDefaultTextStyle(Typography.body)
                
                // Badge disponibilité lecture
                if !canPlayFullTrack {
                    BadgePreviewView()
                }
            }
            .frame(height: 80)
            .padding(12)
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .foregroundStyle(selectedSong == song ? .green.opacity(0.4) : .gray.opacity(0.2))
            }
    }
}

private struct BadgePreviewView: View {
    var body: some View {
        Text("Preview")
            .font(.poppins(.caption, weight: .bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .foregroundStyle(.orange)
            )
    }
}

#Preview {
    SongCard(
        song: BlindTestSong(
            artist: "Britney Spears",
            title: "Toxic",
            appleMusicID: MusicItemID("123456789"),
            postertURL: nil,
            releaseDate: Date.now,
            previewURL: nil
        ),
        selectedSong: BlindTestSong(
            artist: "Britney Spears",
            title: "Toxic",
            appleMusicID: MusicItemID("123456789"),
            postertURL: nil,
            releaseDate: Date.now,
            previewURL: nil
        ),
        canPlayFullTrack: true
    )
}


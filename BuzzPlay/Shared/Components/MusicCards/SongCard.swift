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
    var body: some View {
        
            HStack {
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
            }
            .frame(height: 80)
            .padding(12)
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .foregroundStyle(selectedSong == song ? .green.opacity(0.4) : .gray.opacity(0.2))
            }
    }
}

#Preview {
    SongCard(song: BlindTestSong(artist: "Britney Spears", title: "Toxic", appleMusicID: MusicItemID("123456789"), postertURL: nil, releaseDate: Date.now, previewURL: nil,), selectedSong: BlindTestSong(artist: "Britney Spears", title: "Toxic", appleMusicID: MusicItemID("123456789"), postertURL: nil, releaseDate: Date.now, previewURL: nil,))
}

//
//  SongCards.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 17/12/2025.
//

import SwiftUI
import MusicKit

struct SongCard: View {
    @Namespace private var songAnimation
    var song: BlindTestSong?
    var selectedSong: BlindTestSong?
    var isPlaying: Bool?
//    var canPlayFullTrack: Bool
    
    var body: some View {
        if let song = song {
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
                    Text("\(song.title)")
                        .font(.nohemi(.headline, weight: .bold))
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("\(song.artist)")
                        .font(.nohemi(.body))
                        .opacity(0.8)
                    Text("\(song.releaseYearString)")
                        .font(.nohemi(.footnote))
                        .opacity(0.6)
                }
            }
            .frame(height: 80)
            .padding(12)
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .foregroundStyle(selectedSong == song ? .green.opacity(0.4) : .white.opacity(0.1))
            }
            .foregroundStyle(.white)
            
        } else {
            HStack(alignment: .top) {
                    Text("")
                        .frame(width: 80, height: 80)

                VStack(alignment: .leading) {
                    Text("Selectionne une musique à jouer")
                        .font(.nohemi(.headline))
                        .bold()
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("i")
                        .font(.nohemi(.body))
                        .foregroundStyle(.clear)
                    Text("i")
                        .foregroundStyle(.clear)
                }
            }
            .frame(height: 80)
            .padding(12)
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .foregroundStyle(.gray.opacity(0.2))
            }
        }
    }
}

//private struct BadgePreviewView: View {
//    var body: some View {
//        Text("Preview")
//            .font(.poppins(.caption, weight: .bold))
//            .foregroundStyle(.white)
//            .padding(.horizontal, 10)
//            .padding(.vertical, 6)
//            .background(
//                Capsule()
//                    .foregroundStyle(.orange)
//            )
//    }
//}

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
        ), isPlaying: true
    )
    .appDefaultTextStyle(Typography.body)
    .frame(maxHeight: .infinity)
    .background(
        BackgroundAppView()
    )
}


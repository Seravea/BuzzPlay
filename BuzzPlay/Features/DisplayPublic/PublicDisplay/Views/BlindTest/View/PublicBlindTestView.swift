//
//  PublicBlindTestView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 20/11/2025.
//

import SwiftUI
import MusicKit

struct PublicBlindTestView: View {

    let state: PublicBlindTestState
    let timer: String

    var body: some View {
        VStack(spacing: 0) {
            // Song info
            if state.isAnswerRevealed {
                let releaseDate: Date? = {
                    if let year = state.releaseYear, let yearInt = Int(year) {
                        var components = DateComponents()
                        components.year = yearInt
                        components.month = 1
                        components.day = 1
                        return Calendar.current.date(from: components)
                    }
                    return nil
                }()

                let song = BlindTestSong(
                    artist: state.artist ?? "Artiste inconnu",
                    title: state.title ?? "Titre inconnu",
                    appleMusicID: MusicItemID(""),
                    postertURL: state.postertURLString.flatMap { URL(string: $0) },
                    releaseDate: releaseDate,
                    previewURL: nil
                )

                SongCard(song: song)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .transition(.scale(scale: 0.8).combined(with: .opacity))
            } else {
                HStack(spacing: 8) {
                    Image(systemName: "waveform")
                        .font(.body)
                        .foregroundStyle(Color.mustardYellow.opacity(0.6))

                    Text(BlindTestHints.phrases[state.hintIndex % BlindTestHints.phrases.count])
                        .font(.nohemi(.body, weight: .medium))
                        .foregroundStyle(.white.opacity(0.6))
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .transition(.opacity)
            }

            Spacer()

            // Buzz result
            if let player = state.buzzingPlayer {
                VStack(spacing: 12) {
                    Text("A BUZZÉ")
                        .font(.nohemi(.caption2, weight: .bold))
                        .opacity(0.5)
                        .tracking(0.8)

                    TeamCardView(player: player, buzzTime: state.formattedTime, showPoints: false)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            } else {
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.mustardYellow.opacity(0.3))
                        .frame(width: 12, height: 12)

                    Text("En attente d’un buzz…")
                        .font(.nohemi(.title3, weight: .medium))
                        .opacity(0.6)

                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .animation(.spring(duration: 0.4), value: state)
    }
}

#Preview("Playing") {
    let sample = PublicBlindTestState(
        title: nil,
        artist: nil,
        postertURLString: nil,
        releaseYear: nil,
        formattedTime: "00:12",
        buzzingPlayer: nil,
        isAnswerRevealed: false,
        isPlaying: true,
        hintIndex: 0
    )
    PublicBlindTestView(state: sample, timer: "00:12")
        .background(BackgroundAppView())
}

#Preview("Answer Revealed") {
    let sample = PublicBlindTestState(
        title: "Toxic",
        artist: "Britney Spears",
        postertURLString: "https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/c6/80/66/c680662e-7e7f-de5e-87c4-8a6a9f6c2c77/source/600x600bb.jpg",
        releaseYear: "2003",
        formattedTime: "00:12",
        buzzingPlayer: nil,
        isAnswerRevealed: true,
        isPlaying: false,
        hintIndex: 2
    )
    PublicBlindTestView(state: sample, timer: "00:12")
        .background(BackgroundAppView())
}

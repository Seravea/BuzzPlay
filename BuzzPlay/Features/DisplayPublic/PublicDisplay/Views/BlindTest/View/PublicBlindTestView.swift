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
        ZStack {
            VStack(spacing: 0) {
                // Header + Timer (hidden when playing)
                if state.isAnswerRevealed {
                    HStack(alignment: .top, spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Blind Test")
                                .font(.custom("Nohemi-ExtraBold", size: 48))

                            HStack(spacing: 6) {
                                Circle()
                                    .fill(state.isPlaying ? Color.mustardYellow : .white.opacity(0.3))
                                    .frame(width: 8, height: 8)

                                Text(state.isPlaying ? "En cours" : "En pause")
                                    .font(.nohemi(.subheadline, weight: .semiBold))
                                    .opacity(0.7)
                            }
                        }

                        Spacer()

                        VStack(spacing: 4) {
                            Text("TEMPS")
                                .font(.nohemi(.caption, weight: .bold))
                                .opacity(0.5)
                                .tracking(0.8)

                            Text(timer)
                                .font(.custom("Nohemi-Black", size: 44))
                                .monospacedDigit()
                                .foregroundStyle(Color.mustardYellow)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.darkestPurple, in: RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)

                    Divider()
                        .opacity(0.2)
                }

            // Song info (revealed or hidden)
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
                VStack(spacing: 12) {
                    Image(systemName: "music.note")
                        .font(.system(size: 36, weight: .medium))
                        .foregroundStyle(Color.mustardYellow.opacity(0.7))

                    Text("Le Master joue une musique")
                        .font(.custom("Nohemi-Black", size: 26))
                        .multilineTextAlignment(.center)

                    Text("Écoute et buzzez le premier !")
                        .font(.nohemi(.subheadline, weight: .medium))
                        .opacity(0.5)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)
                .padding(.vertical, 24)
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

                    TeamCardView(player: player,buzzTime: state.formattedTime, showPoints: false)
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

            // Countdown overlay
            if let phase = state.roundCountdownPhase, phase != .hidden {
                CountdownOverlay(phase: phase)
                    .transition(.opacity)
                    .zIndex(100)
            }
        }
    }
}

#Preview("Playing") {
    let sample = PublicBlindTestState(
        title: "🎵 Blind Test en cours",
        artist: nil,
        postertURLString: nil,
        releaseYear: nil,
        formattedTime: "00:12",
        buzzingPlayer: nil,
        isAnswerRevealed: false,
        isPlaying: true,
        roundCountdownPhase: nil
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
        roundCountdownPhase: nil
    )

    PublicBlindTestView(state: sample, timer: "00:12")
        .background(BackgroundAppView())
}

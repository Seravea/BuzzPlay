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
            // Timer badge
            TimerBadge(time: timer)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.bottom, 6)

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
                    .padding(.horizontal, BuzzSpacing.lg)
                    .padding(.vertical, BuzzSpacing.lg)
                    .transition(.scale(scale: 0.8).combined(with: .opacity))
            } else {
                VStack(spacing: 10) {
                    Image(systemName: "waveform")
                        .textStyle(Typography.sectionTitleSoft)
                        .foregroundStyle(Color.mustardYellow.opacity(0.8))
                        .symbolEffect(.variableColor.iterative)

                    Text(BlindTestHints.phrases[state.hintIndex % BlindTestHints.phrases.count])
                        .font(.nohemi(.title3, weight: .semiBold))
                        .foregroundStyle(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, BuzzSpacing.xl)
                .padding(.vertical, 18)
                .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: BuzzRadius.lg))
                .overlay(RoundedRectangle(cornerRadius: BuzzRadius.lg).strokeBorder(.white.opacity(0.08), lineWidth: 1))
                .padding(.horizontal, 4)
                .transition(.opacity)
            }

            Spacer()

            // Buzz result — #D6 : plus de placeholder "En attente d'un buzz…"
            // (le buzzer en dessous indique déjà l'état d'attente). Rien ne s'affiche
            // tant que personne n'a buzzé ; la carte de buzz reste centrée entre les Spacer.
            if let player = state.buzzingPlayer {
                VStack(spacing: BuzzSpacing.md) {
                    Text("A BUZZÉ")
                        .font(.nohemi(.caption2, weight: .bold))
                        .opacity(0.5)
                        .tracking(0.8)

                    TeamCardView(player: player, buzzTime: state.formattedTime, showPoints: false)
                }
                .padding(.horizontal, BuzzSpacing.xxl)
                .padding(.vertical, BuzzSpacing.xl)
                .frame(maxWidth: .infinity)
                .transition(.move(edge: .bottom).combined(with: .opacity))
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
        hintIndex: 0,
        countdownPhase: .hidden
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
        hintIndex: 2,
        countdownPhase: .hidden
    )
    PublicBlindTestView(state: sample, timer: "00:12")
        .background(BackgroundAppView())
}

//
//  PublicBlindTestView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 20/11/2025.
//

import SwiftUI

struct PublicBlindTestView: View {

    let state: PublicBlindTestState
    let timer: String

    var body: some View {
        VStack(spacing: 24) {

            // Header + Timer
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Blind Test")
                        .font(.poppins(.largeTitle, weight: .bold))

                    Text(state.isPlaying ? "🎵 En cours" : "⏸️ En pause")
                        .font(.poppins(.title3))
                        .opacity(0.8)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 6) {
                    Text("Temps")
                        .font(.poppins(.title3, weight: .bold))
                        .opacity(0.8)

                    Text(timer)
                        .font(.poppins(.largeTitle, weight: .bold))
                }
            }

            Divider()

            // Song info (revealed or hidden)
            VStack(spacing: 12) {
                let displayTitle: String = {
                    if state.isAnswerRevealed {
                        return state.title ?? "Titre inconnu"
                    }
                    return state.title ?? "Devinez le titre !"
                }()

                let displaySubtitle: String? = {
                    if state.isAnswerRevealed {
                        return state.artist ?? "Artiste inconnu"
                    }
                    return nil
                }()

                Text(displayTitle)
                    .font(.poppins(.largeTitle, weight: .bold))
                    .multilineTextAlignment(.center)

                if let displaySubtitle {
                    Text(displaySubtitle)
                        .font(.poppins(.title3))
                        .opacity(0.9)
                } else {
                    Text("…")
                        .font(.poppins(.title3))
                        .opacity(0.7)
                }
            }
            .frame(maxWidth: .infinity)

            Spacer()

            // Buzz result
            if let team = state.buzzingTeam {
                TeamCardView(team: team, buzzTime: state.formattedTime, showPoints: false)
            } else {
                Text("En attente d’un buzz…")
                    .font(.poppins(.title3))
                    .opacity(0.8)
            }

            Spacer()
        }
        .padding()
    }
}

#Preview {
    let sample = PublicBlindTestState(
        title: "🎵 Blind Test en cours",
        artist: nil,
        formattedTime: "00:12",
        buzzingTeam: nil,
        isAnswerRevealed: false,
        isPlaying: true
    )

    PublicBlindTestView(state: sample, timer: "00:12")
}

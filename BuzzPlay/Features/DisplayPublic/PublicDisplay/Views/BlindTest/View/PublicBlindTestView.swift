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
        VStack(spacing: 0) {
            // Header + Timer
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
                    .font(.custom("Nohemi-Black", size: 56))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.8).combined(with: .opacity),
                        removal: .opacity
                    ))

                if let displaySubtitle {
                    Text(displaySubtitle)
                        .font(.custom("Nohemi-Bold", size: 28))
                        .opacity(0.8)
                        .transition(.opacity)
                } else {
                    Text("…")
                        .font(.custom("Nohemi-Medium", size: 28))
                        .opacity(0.4)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 24)
            .padding(.vertical, 24)

            Spacer()

            // Buzz result
            if let team = state.buzzingTeam {
                VStack(spacing: 12) {
                    Text("A BUZZÉ")
                        .font(.nohemi(.caption2, weight: .bold))
                        .opacity(0.5)
                        .tracking(0.8)

                    TeamCardView(team: team, buzzTime: state.formattedTime, showPoints: false)
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

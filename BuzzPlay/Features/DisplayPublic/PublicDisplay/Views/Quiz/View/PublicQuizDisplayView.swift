//
//  PublicQuizDisplayView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 20/11/2025.
//

import SwiftUI

struct PublicQuizDisplayView: View {
    var state: PublicQuizState
    var timer: String

    var body: some View {
        VStack(spacing: 14) {
            // Question Card
            VStack(alignment: .leading, spacing: 8) {
                Text("QUESTION")
                    .font(.nohemi(.caption2, weight: .bold))
                    .foregroundStyle(.white.opacity(0.4))
                    .tracking(0.8)

                Text(state.question.title)
                    .font(.nohemi(.title3, weight: .bold))
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 20))
            .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(.white.opacity(0.1), lineWidth: 1))

            // Answers Section (only if revealed)
            if state.isAnswerRevealed {
                VStack(alignment: .leading, spacing: 8) {
                    Text("RÉPONSE")
                        .font(.nohemi(.caption2, weight: .bold))
                        .foregroundStyle(.white.opacity(0.4))
                        .tracking(0.8)

                    Text(state.question.answers.first ?? "N/A")
                        .font(.nohemi(.title3, weight: .bold))
                        .foregroundStyle(Color.mustardYellow)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(18)
                .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 20))
                .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(Color.mustardYellow.opacity(0.3), lineWidth: 1))
                .transition(.scale.combined(with: .opacity))
            }

            // Buzzing team
            if let player = state.buzzingPlayer {
                VStack(spacing: 8) {
                    Text("A BUZZÉ")
                        .font(.nohemi(.caption2, weight: .bold))
                        .foregroundStyle(.white.opacity(0.5))
                        .tracking(0.8)

                    TeamCardView(player: player, buzzTime: state.formattedTime, showPoints: false)
                }
                .frame(maxWidth: .infinity)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.horizontal, 20)
        .padding(.top, 0)
        .animation(.spring(duration: 0.4), value: state)
    }
}

#Preview {
    let samplePlayers = [
        Player(name: "Team 1", teamColor: .greenGame, score: 240),
        Player(name: "Team 2", teamColor: .blueGame, score: 240),
    ]
    return PublicQuizDisplayView(
        state: PublicQuizState(
            question: QuizSamples.music2000s.questions[3],
            setTitle: QuizSamples.music2000s.title,
            formattedTime: "00:00",
            buzzingPlayer: samplePlayers[1],
            isAnswerRevealed: false,
            isHintVisible: false,
            countdownPhase: .hidden
        ),
        timer: "00:00"
    )
}

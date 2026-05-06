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
        VStack(spacing: 0) {
            // Header avec timer
            HStack(alignment: .top, spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(state.setTitle)
                        .font(.nohemi(.subheadline, weight: .semiBold))
                        .opacity(0.6)
                        .tracking(0.8)

                    Text(state.question.title)
                        .font(.custom("Nohemi-ExtraBold", size: 48))
                        .lineLimit(3)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

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

            // Buzzing team highlight
            if let teamHasBuzz = state.buzzingPlayer {
                VStack(spacing: 12) {
                    Text("A BUZZÉ")
                        .font(.nohemi(.caption2, weight: .bold))
                        .opacity(0.5)
                        .tracking(0.8)

                    TeamCardView(team: teamHasBuzz, buzzTime: state.formattedTime, showPoints: false)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .animation(.spring(duration: 0.4), value: state)
    }
}

#Preview {
    PublicQuizDisplayView(
        state: PublicQuizState(
            question: QuizSamples.music2000s.questions[3],
            setTitle: QuizSamples.music2000s.title,
            formattedTime: "00:00",
            buzzingTeam: samplePlayers[1],
            isAnswerRevealed: false,
            isHintVisible: false
        ),
        timer: "00:00"
    )
}

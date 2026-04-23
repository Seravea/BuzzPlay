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
        VStack(alignment: .leading, spacing: 8) {
            Text(state.setTitle)
                .font(.nohemi(.subheadline))
                .opacity(0.7)

            Text(state.question.title)
                .font(.nohemi(.largeTitle))

            if let teamHasBuzz = state.buzzingTeam {
                TeamCardView(team: teamHasBuzz, buzzTime: state.formattedTime, showPoints: false)
                    .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 4)
        .padding(.vertical, 12)
        .animation(.default, value: state)
    }
}

#Preview {
    PublicQuizDisplayView(
        state: PublicQuizState(
            question: QuizSamples.music2000s.questions[3],
            setTitle: QuizSamples.music2000s.title,
            formattedTime: "00:00",
            buzzingTeam: sampleTeams[1],
            isAnswerRevealed: false,
            isHintVisible: false
        ),
        timer: "00:00"
    )
}

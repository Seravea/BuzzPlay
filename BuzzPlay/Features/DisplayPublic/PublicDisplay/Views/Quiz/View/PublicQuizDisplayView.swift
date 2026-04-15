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
        VStack {
            Text(state.setTitle)
                .font(.nohemi(.title3))
                .opacity(0.7)

            Text(state.question.title)
                .font(.nohemi(.largeTitle))

            //TODO: Activer un timer dans le display public quand onBuzzUnlock/onBuzzLock
//            Text("Timer : \(timer)")

            Spacer()

            if let teamHasBuzz = state.buzzingTeam {
                TeamCardView(team: teamHasBuzz, buzzTime: state.formattedTime, showPoints: false)
            }

            Spacer()

        }
        .padding()
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

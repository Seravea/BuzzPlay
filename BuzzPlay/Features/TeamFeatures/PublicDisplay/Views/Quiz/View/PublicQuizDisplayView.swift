//
//  PublicQuizDisplayView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 20/11/2025.
//

import SwiftUI

struct PublicQuizDisplayView: View {
    var state: PublicQuizState
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(state.question.title)
            //TimerCardView(timer: teamGameVM.currentBuzzerVM., isCorrectAnswer: )
//            Text(publicDisplayVM.formattedTime)
            
            if let team = state.buzzingTeam {
                TeamCardView(team: team, buzzTime: state.formattedTime)
            }
        }
    }
}

#Preview {
    PublicQuizDisplayView(state: PublicQuizState(question: quizMusic90sTo10s[2], formattedTime: "00:00", buzzingTeam: nil, isAnswerRevealed: false, isHintVisible: false))
}

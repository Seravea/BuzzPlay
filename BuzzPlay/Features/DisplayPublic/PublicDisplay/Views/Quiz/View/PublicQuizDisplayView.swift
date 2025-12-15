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
//            Text(publicDisplayVM.formattedTime)
        
            if let teamHasBuzz = state.buzzingTeam {
                TeamCardView(team: teamHasBuzz, buzzTime: state.formattedTime)
            
            }
        
        }
    }
}

#Preview {
    PublicQuizDisplayView(state: PublicQuizState(question: quizMusic90sTo10s[2], formattedTime: "00:00", buzzingTeam: sampleTeams[0], isAnswerRevealed: false, isHintVisible: false))
}

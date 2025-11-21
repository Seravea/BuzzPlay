//
//  QuizMasterListView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 18/11/2025.
//

import SwiftUI

struct QuizMasterListView: View {
    @Bindable var quizMasterVM: QuizMasterViewModel
    var body: some View {
        ScrollView {
            HStack {
                VStack(alignment: .leading) {
                    ForEach(quizMasterVM.questions) { question in
                        PrimaryButtonView(title: question.title, action: {
                            withAnimation {
                                quizMasterVM.selectQuestion(question)
                            }
                        }, style: quizMasterVM.questionButtonStyle(question), fontSize: Typography.body, size: 450)
                        .disabled(quizMasterVM.isPlaying)
                        
                    }
                    
                    
                }
                if let currentQuestion = quizMasterVM.currentQuestion {
                    
                    VStack {
                        Text(currentQuestion.title)
                            .font(.largeTitle)
                        
                        Text(quizMasterVM.formattedTime)
                        
                        Spacer()
                        
                        if let currentTeamHasBuzz = quizMasterVM.gameVM.currentBuzzTeam {
                            TeamCardView(team: currentTeamHasBuzz)
                        }
                        
                    }
                    .frame(maxWidth: .infinity)
    
                } else {
                    Spacer()
                }
            }
            .padding()
        }
        
    }
}

#Preview {
    QuizMasterListView(quizMasterVM: QuizMasterViewModel(gameVM: MasterFlowViewModel()))
}

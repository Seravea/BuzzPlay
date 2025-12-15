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
                        .disabled(quizMasterVM.quizButtonDisabled(question: question))
                        
                    }
                }
                
                VStack {
                    
                    //MARK: Correct answer or Wrong answer
                    VStack {
                        HStack {
                            PrimaryButtonView(title: "Valider la réponse", action: {
                                quizMasterVM.validateAnswer()
                            }, style: .filled(color: .green), fontSize: Typography.body)
                            
                            
                            PrimaryButtonView(title: "Refuser la réponse", action: {
                                quizMasterVM.rejectAnswer()
                            }, style: .filled(color: .red), fontSize: Typography.body)
                            
                        }
                        .disabled(quizMasterVM.validateRejectDisabled)
                        .opacity(quizMasterVM.UIDisabledValidateRejectButtonOpacity())
                        
                    }
                    
                    if let currentQuestion = quizMasterVM.currentQuestion {
                        
                        VStack {
                            Text(currentQuestion.title)
                                .font(.largeTitle)
                            
                            Text(quizMasterVM.formattedTime)
                            
                            Spacer()
                            
                            if let currentTeamHasBuzz = quizMasterVM.gameVM.currentBuzzTeam {
                                TeamCardView(team: currentTeamHasBuzz, buzzTime: quizMasterVM.formattedTime)
                            }
                            
                        }
                        .frame(maxWidth: .infinity)
                        
                    } else {
                        Spacer()
                    }
                }
                .padding()
            }
            .padding()
        }
        
    }
}

#Preview {
    QuizMasterListView(quizMasterVM: QuizMasterViewModel(gameVM: MasterFlowViewModel()))
}

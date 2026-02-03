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
        
            HStack {
                VStack(alignment: .leading) {
                    ScrollView {
                        ForEach(quizMasterVM.questions) { question in
                            PrimaryButtonView(title: question.title, action: {
                                withAnimation {
                                    quizMasterVM.selectQuestion(question)
                                }
                            }, style: quizMasterVM.questionButtonStyle(question), fontSize: Typography.body, size: 450)
                            .disabled(quizMasterVM.quizButtonDisabled(question: question))
                            
                        }
                    }
                }
                VStack {
                    
                    //MARK: Correct answer or Wrong answer
                    VStack {
                        VStack {
                            PrimaryButtonView(title: "Valider 1 réponse (10 points)", action: {
                                quizMasterVM.validateAnswer(points: 10)
                            }, style: .filled(buttonStyle: .positive), fontSize: Typography.body)
                        
                            PrimaryButtonView(title: "Valider 2 réponses (20 points)", action: {
                                quizMasterVM.validateAnswer(points: 20)
                            }, style: .filled(buttonStyle: .positive), fontSize: Typography.body)
                            
                            
                            PrimaryButtonView(title: "Valider 3 réponses (30 points)", action: {
                                quizMasterVM.validateAnswer(points: 30)
                            }, style: .filled(buttonStyle: .positive), fontSize: Typography.body)
                            
                            PrimaryButtonView(title: "Refuser la réponse", action: {
                                quizMasterVM.rejectAnswer()
                            }, style: .filled(buttonStyle: .destructive), fontSize: Typography.body)
                            
                        }
                        .disabled(quizMasterVM.validateRejectDisabled)
                        .opacity(quizMasterVM.UIDisabledValidateRejectButtonOpacity())
                        
                    }
                    
                    if let currentQuestion = quizMasterVM.currentQuestion {
                        
                        VStack {
                            TimerCardView(timer: quizMasterVM.formattedTime, isCorrectAnswer: false)
                
                            Text("Question : \(currentQuestion.title)")
                                .font(.largeTitle)
                            ForEach(currentQuestion.answers, id: \.self) { answer in
                                Text("- \(answer)")
                                    .frame(alignment: .leading)
                            }
                            
                            
                            
                            Spacer()
                            
                            if let currentTeamHasBuzz = quizMasterVM.gameVM.currentBuzzTeam {
                                TeamCardView(team: currentTeamHasBuzz, buzzTime: quizMasterVM.formattedTime, showPoints: false)
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
        
            .background(
                BackgroundAppView()
            )
    }
}

#Preview {
    QuizMasterListView(quizMasterVM: QuizMasterViewModel(gameVM: MasterFlowViewModel()))
}

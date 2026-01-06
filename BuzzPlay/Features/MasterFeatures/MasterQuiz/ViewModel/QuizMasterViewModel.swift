//
//  QuizMasterViewModel.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 18/11/2025.
//

import Foundation

@MainActor
@Observable
class QuizMasterViewModel: BuzzDrivenGame {
    
    let gameVM: MasterFlowViewModel
    
    var questions: [QuizQuestion] = quizMusic90sTo10s
    var currentQuestion: QuizQuestion?
    var teamHasBuzz: Team?
    
    var questionsPassed: [QuizQuestion] = []
    
    //MARK: Timer's datas
    var reactionTimeMs: Int = 0
    var timer: Timer?
    
    init(gameVM: MasterFlowViewModel) {
        self.gameVM = gameVM
    }
}

//MARK: Quiz Functions
extension QuizMasterViewModel {
    func selectQuestion(_ question: QuizQuestion) {
        currentQuestion = question
        teamHasBuzz = nil
        
        gameVM.unlockBuzz()
        startRound()
    }
    
    func startRound() {
        //SI pas de question ne peu pas commencer la manche
        guard currentQuestion != nil else { return }
        
        gameVM.broadcastPublicStateFromCurrentGame()
        gameVM.unlockBuzz()
        startReactionTimer()
    }
    
    func validateAnswer(points: Int) {
        if let team = gameVM.currentBuzzTeam {
            gameVM.addPointToTeam(team, points: points)
            goToSelectNewQuestion()
            teamHasBuzz = nil
            gameVM.currentBuzzTeam = nil
            
        }
    }
    
    func rejectAnswer() {
        gameVM.unlockBuzz()
        teamHasBuzz = nil
        gameVM.currentBuzzTeam = nil
        let state = makePublicState()
        gameVM.sendPublicState(state)
        startReactionTimer()
    }
    
    func handleBuzz(from team: Team) {
        gameVM.currentBuzzTeam = team
        teamHasBuzz = team
        pauseReactionTimer()
    }
    
    func goToSelectNewQuestion() {
        if let currentQuestion = currentQuestion {
            questionsPassed.append(currentQuestion)
        }
        currentQuestion = nil
        stopReactionTimer()
        
        
        let state = makePublicState()
        gameVM.sendPublicState(state)
    }
}


//MARK: Quiz UI details
extension QuizMasterViewModel {
    func questionButtonStyle(_ question: QuizQuestion) -> Style {
        let isSelected = (question == currentQuestion)
        let isAlreadyPassed = questionsPassed.contains(question)
        
        if isSelected {
            return .filled(color: .darkestPurple)
        } else if isAlreadyPassed {
            return .filled(color: .green)
        } else {
            return .outlined(color: .darkestPurple)
        }
    }
    
    func quizButtonDisabled(question: QuizQuestion) -> Bool {
        if isPlaying {
            return true
        } else if questionsPassed.contains(question) {
            return true
        } else {
            return false
        }
    }
    
    var isPlaying: Bool {
        currentQuestion != nil
    }
    
    var validateRejectDisabled: Bool {
        teamHasBuzz == nil
    }
    
    func UIDisabledValidateRejectButtonOpacity() -> Double {
        validateRejectDisabled ? 0.7 : 1
    }
}


//MARK: making/sending Payload to peers
extension QuizMasterViewModel {
    func makePublicState() -> PublicState {
        guard let question = currentQuestion else {
            return .waiting
        }
        
        return PublicState.quiz(
            PublicQuizState(
                question: question,
                formattedTime: formattedTime,
                buzzingTeam: teamHasBuzz,
                isAnswerRevealed: false,
                isHintVisible: false
            )
        )
    }
}

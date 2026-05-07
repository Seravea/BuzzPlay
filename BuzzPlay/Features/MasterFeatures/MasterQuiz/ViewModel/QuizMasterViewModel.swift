//
//  QuizMasterViewModel.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 18/11/2025.
//

import Foundation
import UIKit

@MainActor
@Observable
class QuizMasterViewModel: BuzzDrivenGame {

    let gameVM: MasterFlowViewModel
    let quizSet: QuizSet

    var questions: [QuizQuestion]
    var currentQuestion: QuizQuestion?
    var playerHasBuzz: Player?

    var questionsPassed: [QuizQuestion] = []

    //MARK: Timer's datas
    var reactionTimeMs: Int = 0
    var timer: Timer?

    init(gameVM: MasterFlowViewModel, quizSet: QuizSet) {
        self.gameVM = gameVM
        self.quizSet = quizSet
        self.questions = quizSet.questions
    }
}

//MARK: Quiz Functions
extension QuizMasterViewModel {
    func selectQuestion(_ question: QuizQuestion) {
        currentQuestion = question
        playerHasBuzz = nil

        gameVM.unlockBuzz()
        startRound()
    }
    
    func startRound() {
        //SI pas de question ne peu pas commencer la manche
        guard currentQuestion != nil else { return }

        gameVM.broadcastPublicStateFromCurrentGame()
        gameVM.unlockBuzz()
        startReactionTimer()

        // ✅ Notifier les Players que le timer a démarré
        gameVM.mpcService.sendMessage(.timerStarted)
    }
    
    func validateAnswer(points: Int) {
        if let player = gameVM.currentBuzzPlayer {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            gameVM.addPointToPlayer(player, points: points)

            // ✅ Envoyer le résultat aux Players
            let resultPayload = AnswerResultPayload(isCorrect: true, points: points)
            gameVM.mpcService.sendMessage(.answerResult(resultPayload))

            goToSelectNewQuestion()
            playerHasBuzz = nil
            gameVM.currentBuzzPlayer = nil
        }
    }
    
    func rejectAnswer() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)

        // ✅ Envoyer le résultat incorrect aux Players (0 points)
        let resultPayload = AnswerResultPayload(isCorrect: false, points: 0)
        gameVM.mpcService.sendMessage(.answerResult(resultPayload))

        gameVM.unlockBuzz()
        playerHasBuzz = nil
        gameVM.currentBuzzPlayer = nil
        let state = makePublicState()
        gameVM.sendPublicState(state)
        startReactionTimer()

        // ✅ Notifier les Players que le timer a démarré
        gameVM.mpcService.sendMessage(.timerStarted)
    }
    
    func handleBuzz(from player: Player) {
        gameVM.currentBuzzPlayer = player
        playerHasBuzz = player
        pauseReactionTimer()
    }
    
    func skipQuestion() {
        playerHasBuzz = nil
        gameVM.currentBuzzPlayer = nil
        gameVM.isBuzzLocked = false
        goToSelectNewQuestion()
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
            return .filled(buttonStyle: .neutral)
        } else if isAlreadyPassed {
            return .filled(buttonStyle: .positive)
        } else {
            return .outlined(buttonStyle: .neutral)
        }
    }
    
    func questionButtonBCKStyle(_ question: QuizQuestion) -> ButtonStyleE {
        let isSelected = (question == currentQuestion)
        let isAlreadyPassed = questionsPassed.contains(question)
        
        if isSelected {
            return .positive
        } else if isAlreadyPassed {
            return .destructive
        } else {
            return .neutral
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
        playerHasBuzz == nil
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
                setTitle: quizSet.title,
                formattedTime: formattedTime,
                buzzingPlayer: playerHasBuzz,
                isAnswerRevealed: false,
                isHintVisible: false
            )
        )
    }
}

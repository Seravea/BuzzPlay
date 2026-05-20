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

    var roundCountdownPhase: RoundCountdownPhase = .hidden
    private var roundCountdownTimer: Timer?

    private var doubledScorePlayers: Set<UUID> = []
    private var usedQuestionHintIndex: [UUID: Int] = [:]  // questionID -> next hint index

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
        
        // ✅ Envoyer le message AVANT de démarrer (pour sync avec timestamp)
        let timestamp = Date().timeIntervalSince1970
        gameVM.mpcService.sendMessage(.timerStarted(TimerStartPayload(masterTimestamp: timestamp)))
        
        startReactionTimer()
    }
    
    func validateAnswer(points: Int) {
        if let player = gameVM.currentBuzzPlayer {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            let finalPoints = doubledScorePlayers.remove(player.id) != nil ? points * 2 : points
            gameVM.addPointToPlayer(player, points: finalPoints)
            gameVM.quizRoundsPlayed += 1

            let resultPayload = AnswerResultPayload(isCorrect: true, points: finalPoints, correctAnswer: currentQuestion?.answers.first)
            gameVM.mpcService.sendMessage(.answerResult(resultPayload))

            goToSelectNewQuestion()
            playerHasBuzz = nil
            gameVM.currentBuzzPlayer = nil
        }
    }
    
    func rejectAnswer() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)

        let resultPayload = AnswerResultPayload(isCorrect: false, points: 0, correctAnswer: nil)
        gameVM.mpcService.sendMessage(.answerResult(resultPayload))

        playerHasBuzz = nil
        gameVM.currentBuzzPlayer = nil
        let state = makePublicState()
        gameVM.sendPublicState(state)

        startRoundCountdown {
            self.gameVM.unlockBuzz()
            let timestamp = Date().timeIntervalSince1970
            self.gameVM.mpcService.sendMessage(.timerStarted(TimerStartPayload(masterTimestamp: timestamp)))
            self.startReactionTimer()
            let newState = self.makePublicState()
            self.gameVM.sendPublicState(newState)
        }
    }

    private func startRoundCountdown(onComplete: @escaping @MainActor () -> Void) {
        roundCountdownPhase = .hidden
        roundCountdownTimer?.invalidate()
        Task { @MainActor [weak self] in
            try? await Task.sleep(for: .seconds(2))
            guard let self else { return }
            var count = 3
            self.roundCountdownPhase = .counting(count)
            self.roundCountdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                Task { @MainActor [weak self] in
                    guard let self else { return }
                    count -= 1
                    if count > 0 {
                        self.roundCountdownPhase = .counting(count)
                    } else {
                        self.roundCountdownTimer?.invalidate()
                        self.roundCountdownTimer = nil
                        self.roundCountdownPhase = .go
                        try? await Task.sleep(for: .seconds(0.8))
                        self.roundCountdownPhase = .hidden
                        onComplete()
                    }
                }
            }
        }
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


//MARK: Gift effects
extension QuizMasterViewModel {
    func applyGiftEffect(_ gift: CoinsViewModel.Gift, to player: Player) {
        switch gift {
        case .scoreDoubled:
            doubledScorePlayers.insert(player.id)

        case .showIndicies:
            guard let question = currentQuestion else { return }
            let nextIdx = usedQuestionHintIndex[question.id, default: 0]
            guard nextIdx < question.indices.count else {
                if let lastHint = question.indices.last {
                    gameVM.mpcService.sendMessagetoOnePlayer(message: .hintRevealedToPlayer(lastHint), player: player)
                }
                return
            }
            let hint = question.indices[nextIdx]
            usedQuestionHintIndex[question.id] = nextIdx + 1
            gameVM.mpcService.sendMessagetoOnePlayer(message: .hintRevealedToPlayer(hint), player: player)

        case .changeBuzzColor:
            guard let idx = gameVM.players.firstIndex(where: { $0.id == player.id }) else { return }
            let colors = GameColor.allCases.filter { $0 != gameVM.players[idx].teamColor }
            gameVM.players[idx].customBuzzColor = colors.randomElement()
            gameVM.mpcService.sendMessage(.updatedPlayer(gameVM.players[idx]))

        case .changeBuzzSound:
            guard let idx = gameVM.players.firstIndex(where: { $0.id == player.id }) else { return }
            gameVM.players[idx].customBuzzSound = buzzSoundNames.randomElement()
            gameVM.mpcService.sendMessage(.updatedPlayer(gameVM.players[idx]))

        default:
            break
        }
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

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

    var shouldAutoFinish: Bool = false
    var hasInvitedPlayers: Bool = false
    var isQuestionRevealed: Bool = false

    var roundCountdownPhase: RoundCountdownPhase = .hidden
    private var countdownTask: Task<Void, Never>?

    private var doubledScorePlayers: Set<UUID> = []
    private var usedQuestionHintIndex: [UUID: Int] = [:]  // questionID -> next hint index
    private let feedbackGenerator = UINotificationFeedbackGenerator()

    //MARK: Timer's datas
    var reactionTimeMs: Int = 0
    var timer: Timer?

    init(gameVM: MasterFlowViewModel, quizSet: QuizSet) {
        self.gameVM = gameVM
        self.quizSet = quizSet
        let limit = gameVM.quizRoundsTotal
        self.questions = limit > 0 ? Array(quizSet.questions.prefix(limit)) : quizSet.questions
        feedbackGenerator.prepare()
    }
}

//MARK: Quiz Functions
extension QuizMasterViewModel {
    func selectQuestion(_ question: QuizQuestion) {
        currentQuestion = question
        playerHasBuzz = nil
        isQuestionRevealed = false
        // Reset état buzz sans broadcaster (la question serait visible avant le countdown)
        gameVM.currentBuzzPlayer = nil
        gameVM.isBuzzLocked = false
        for i in gameVM.players.indices where gameVM.players[i].blockedFromBuzzing {
            gameVM.players[i].blockedFromBuzzing = false
            gameVM.mpcService.sendMessage(.updatedPlayer(gameVM.players[i]))
        }
        startRound()
    }
    
    func startRound() {
        guard currentQuestion != nil else { return }

        // Lance countdown 3-2-1-GO avant d'activer le buzzer
        // Pas de broadcast ici — la question serait visible avant le countdown
        startRoundCountdown { [weak self] in
            guard let self else { return }
            self.isQuestionRevealed = true
            self.gameVM.unlockBuzz()

            let timestamp = Date().timeIntervalSince1970
            self.gameVM.mpcService.sendMessage(.timerStarted(TimerStartPayload(masterTimestamp: timestamp)))

            self.startReactionTimer()
            let newState = self.makePublicState()
            self.gameVM.sendPublicState(newState)
        }
    }
    
    func validateAnswer(points: Int) {
        if let player = gameVM.currentBuzzPlayer {
            feedbackGenerator.notificationOccurred(.success)
            let wasDoubled = doubledScorePlayers.remove(player.id) != nil
            let finalPoints = wasDoubled ? points * 2 : points
            gameVM.quizRoundsPlayed += 1

            // .answerResult envoyé EN PREMIER → Player snapshote knownPlayers avant la mise à jour du score
            let allAnswers = currentQuestion.flatMap { $0.answers.isEmpty ? nil : $0.answers.joined(separator: " • ") }
            let resultPayload = AnswerResultPayload(isCorrect: true, points: finalPoints, correctAnswer: allAnswers)
            gameVM.mpcService.sendMessage(.answerResult(resultPayload))

            gameVM.addPointToPlayer(player, points: finalPoints, consumeScoreDouble: wasDoubled)

            goToSelectNewQuestion()
            playerHasBuzz = nil
            gameVM.currentBuzzPlayer = nil

            if questionsPassed.count >= questions.count {
                shouldAutoFinish = true
            }
        }
    }
    
    func rejectAnswer() {
        feedbackGenerator.notificationOccurred(.warning)

        let resultPayload = AnswerResultPayload(isCorrect: false, points: 0, correctAnswer: nil)
        gameVM.mpcService.sendMessage(.answerResult(resultPayload))

        playerHasBuzz = nil
        gameVM.currentBuzzPlayer = nil
        let state = makePublicState()
        gameVM.sendPublicState(state)

        // Délai simple sans countdown broadcasté : évite que le CountdownOverlay
        // couvre la question côté Player (le buzz se re-déverrouille silencieusement)
        countdownTask?.cancel()
        countdownTask = Task { @MainActor [weak self] in
            guard let self else { return }
            try? await Task.sleep(for: .seconds(2))
            guard !Task.isCancelled else { return }
            self.startReactionTimer()
            self.gameVM.unlockBuzz()
            let newState = self.makePublicState()
            self.gameVM.sendPublicState(newState)
        }
    }

    private func startRoundCountdown(onComplete: @escaping @MainActor () -> Void) {
        countdownTask?.cancel()
        countdownTask = Task { @MainActor [weak self] in
            guard let self else { return }
            await runCountdown(
                onPhaseChange: { [weak self] phase in
                    self?.roundCountdownPhase = phase
                    if phase != .hidden {
                        self?.gameVM.broadcastPublicStateFromCurrentGame()
                    }
                },
                onComplete: onComplete
            )
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
        if !hasInvitedPlayers { return true }
        if isPlaying { return true }
        if questionsPassed.contains(question) { return true }
        return false
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
                isHintVisible: false,
                countdownPhase: roundCountdownPhase,
                isQuestionRevealed: isQuestionRevealed
            )
        )
    }
}

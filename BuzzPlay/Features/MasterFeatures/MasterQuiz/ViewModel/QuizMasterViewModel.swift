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

    // #15 — phase "réponse révélée" : après une bonne réponse validée, la question terminée
    // reste diffusée aux Players (card RÉPONSE visible en haut) jusqu'au lancement de la manche
    // suivante, comme l'état `.finished` du BlindTest. Découple l'état DIFFUSÉ de `currentQuestion`
    // (que le Master remet à nil pour retourner choisir sa prochaine question).
    var revealedQuestion: QuizQuestion?

    var questionsPassed: [QuizQuestion] = []

    var shouldAutoFinish: Bool = false
    var hasInvitedPlayers: Bool = false
    var isQuestionRevealed: Bool = false

    var roundCountdownPhase: RoundCountdownPhase = .hidden
    private var countdownTask: Task<Void, Never>?

    private var doubledScorePlayers: Set<UUID> = []
    private var usedQuestionHintIndex: [UUID: Int] = [:]  // questionID -> next hint index
    // Joueurs ayant acheté showIndicies entre deux questions — livrés au début de la prochaine manche
    private var pendingHintPlayers: [UUID: Player] = [:]
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
        revealedQuestion = nil  // #15 — nouvelle manche : on quitte la phase "réponse révélée"
        playerHasBuzz = nil
        isQuestionRevealed = false
        // Reset état buzz sans broadcaster (la question serait visible avant le countdown)
        gameVM.currentBuzzPlayer = nil
        gameVM.isBuzzLocked = false
        gameVM.clearGiftBlocks()   // #20 — nouvelle question : reset des blocages-cadeaux
        startRound()
    }
    
    func startRound() {
        guard let question = currentQuestion else { return }

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

            // Livrer les indices achetés entre deux questions
            self.flushPendingHints(for: question)
        }
    }
    
    func validateAnswer(points: Int) {
        if let player = gameVM.currentBuzzPlayer {
            feedbackGenerator.notificationOccurred(.success)
            let wasDoubled = doubledScorePlayers.remove(player.id) != nil
            let finalPoints = wasDoubled ? points * 2 : points

            // .answerResult envoyé EN PREMIER → Player snapshote knownPlayers avant la mise à jour du score
            let allAnswers = currentQuestion.flatMap { $0.answers.isEmpty ? nil : $0.answers.joined(separator: " • ") }
            let resultPayload = AnswerResultPayload(isCorrect: true, points: finalPoints, correctAnswer: allAnswers)
            gameVM.mpcService.sendMessage(.answerResult(resultPayload))

            gameVM.addPointToPlayer(player, points: finalPoints, consumeScoreDouble: wasDoubled)

            // #15 — entre en phase "réponse révélée" : la question terminée reste diffusée
            // (card RÉPONSE + classement inter-manche) jusqu'au lancement de la manche suivante.
            revealedQuestion = currentQuestion

            // #BugQ1 — l'incrément de manche + auto-finish est géré dans goToSelectNewQuestion
            goToSelectNewQuestion()
            playerHasBuzz = nil
            gameVM.currentBuzzPlayer = nil
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

        // #E3/#B4 — countdown discret visible sur le buzzer (la question reste affichée).
        // Diffusé via countdownPhase → le stateLabel du buzzer affiche "Prochain buzz dans… N".
        // Le CountdownOverlay plein écran est supprimé côté Player quand la question est révélée,
        // donc seul le décompte sous le buzzer apparaît. On attend la fin de l'overlay
        // "Mauvaise réponse" (GameRhythm.answerOverlay) avant de lancer le décompte.
        countdownTask?.cancel()
        countdownTask = Task { @MainActor [weak self] in
            guard let self else { return }
            try? await Task.sleep(for: GameRhythm.rejectResumeDelay)
            guard !Task.isCancelled else { return }
            // #countdown-sync — décompte de reprise calculé localement par chaque Player.
            self.gameVM.mpcService.sendMessage(.countdownStarted(
                CountdownStartPayload(masterTimestamp: Date().timeIntervalSince1970, startCount: 2)
            ))
            await runCountdown(
                startCount: 2,
                onPhaseChange: { [weak self] phase in
                    self?.roundCountdownPhase = phase
                },
                onComplete: { [weak self] in
                    guard let self else { return }
                    self.roundCountdownPhase = .hidden
                    self.startReactionTimer()
                    self.gameVM.unlockBuzz()
                    let newState = self.makePublicState()
                    self.gameVM.sendPublicState(newState)
                }
            )
        }
    }

    private func startRoundCountdown(onComplete: @escaping @MainActor () -> Void) {
        countdownTask?.cancel()
        countdownTask = Task { @MainActor [weak self] in
            guard let self else { return }
            // #countdown-sync — UN message timestampé ; chaque Player calcule 3-2-1-GO sur
            // son horloge locale (plus de N broadcasts par phase → décompte synchrone).
            self.gameVM.mpcService.sendMessage(.countdownStarted(
                CountdownStartPayload(masterTimestamp: Date().timeIntervalSince1970, startCount: 3)
            ))
            await runCountdown(
                onPhaseChange: { [weak self] phase in
                    self?.roundCountdownPhase = phase
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

    // #pause-reco — uniquement si la question est révélée ET que personne n'a buzzé
    // (= timer en cours). Un buzz en attente de validation a déjà mis le timer en pause.
    func pauseForDisconnect() {
        guard isQuestionRevealed, playerHasBuzz == nil else { return }
        pauseReactionTimer()
    }

    func resumeFromDisconnect() {
        guard isQuestionRevealed, playerHasBuzz == nil else { return }
        startReactionTimer()
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
            // #BugQ1 — toute question terminée (validée OU skippée) consomme une manche
            gameVM.quizRoundsPlayed += 1
        }
        currentQuestion = nil
        stopReactionTimer()

        // #BugQ1 — auto-finish quand toutes les questions de la manche ont été jouées
        if questionsPassed.count >= questions.count {
            shouldAutoFinish = true
        }

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
            guard let question = currentQuestion else {
                // Aucune question active — stocker pour la prochaine manche
                pendingHintPlayers[player.id] = player
                gameVM.mpcService.sendMessagetoOnePlayer(message: .hintPending, player: player)   // #22
                return
            }
            sendHint(to: player, for: question)

        default:
            break
        }
    }

    private func sendHint(to player: Player, for question: QuizQuestion) {
        let nextIdx = usedQuestionHintIndex[question.id, default: 0]
        let hint: String
        if nextIdx < question.indices.count {
            hint = question.indices[nextIdx]
            usedQuestionHintIndex[question.id] = nextIdx + 1
        } else if let lastHint = question.indices.last {
            hint = lastHint
        } else {
            return
        }
        gameVM.mpcService.sendMessagetoOnePlayer(message: .hintRevealedToPlayer(hint), player: player)
    }

    private func flushPendingHints(for question: QuizQuestion) {
        guard !pendingHintPlayers.isEmpty else { return }
        for player in pendingHintPlayers.values {
            // Utilise le Player à jour (score, coins) depuis gameVM
            let live = gameVM.players.first(where: { $0.id == player.id }) ?? player
            sendHint(to: live, for: question)
        }
        pendingHintPlayers.removeAll()
    }
}


//MARK: making/sending Payload to peers
extension QuizMasterViewModel {
    func makePublicState() -> PublicState {
        // Manche en cours : question pilotée par le Master.
        if let question = currentQuestion {
            return PublicState.quiz(
                PublicQuizState(
                    question: question,
                    setTitle: quizSet.title,
                    formattedTime: formattedTime,
                    buzzingPlayer: playerHasBuzz,
                    isAnswerRevealed: false,
                    isHintVisible: false,
                    countdownPhase: roundCountdownPhase,
                    isQuestionRevealed: isQuestionRevealed,
                    isLastRound: false
                )
            )
        }

        // #15 — phase "réponse révélée" : la question terminée reste affichée (card RÉPONSE)
        // et déclenche le classement inter-manche côté Player, sauf sur la dernière manche
        // de la partie (#11 — le podium final suit).
        if let revealed = revealedQuestion {
            return PublicState.quiz(
                PublicQuizState(
                    question: revealed,
                    setTitle: quizSet.title,
                    formattedTime: formattedTime,
                    buzzingPlayer: nil,
                    isAnswerRevealed: true,
                    isHintVisible: false,
                    countdownPhase: .hidden,
                    isQuestionRevealed: true,
                    // #B2 — dernière manche DU JEU (pas de la partie) : l'inter-manche se tait,
                    // l'inter-jeu (.score) ou le podium final prend le relais (plus de double-sheet).
                    isLastRound: !gameVM.isQuizAvailable
                )
            )
        }

        return .waiting
    }
}

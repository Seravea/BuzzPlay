//
//  QuizPublicPayload.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 20/11/2025.
//

import Foundation


struct PublicQuizState: Codable, Equatable {
    let question: QuizQuestion
    let setTitle: String
    let formattedTime: String
    let buzzingPlayer: Player?
    let isAnswerRevealed: Bool
    let isHintVisible: Bool
    let countdownPhase: RoundCountdownPhase
    /// true après le premier countdown — la question reste visible même pendant les countdowns de refus
    let isQuestionRevealed: Bool
    /// true uniquement sur la dernière manche de la partie : le Player saute le classement
    /// inter-manche car le podium final enchaîne directement (#11/#C8).
    let isLastRound: Bool

    init(question: QuizQuestion, setTitle: String, formattedTime: String, buzzingPlayer: Player?,
         isAnswerRevealed: Bool, isHintVisible: Bool, countdownPhase: RoundCountdownPhase,
         isQuestionRevealed: Bool, isLastRound: Bool = false) {
        self.question = question
        self.setTitle = setTitle
        self.formattedTime = formattedTime
        self.buzzingPlayer = buzzingPlayer
        self.isAnswerRevealed = isAnswerRevealed
        self.isHintVisible = isHintVisible
        self.countdownPhase = countdownPhase
        self.isQuestionRevealed = isQuestionRevealed
        self.isLastRound = isLastRound
    }
}


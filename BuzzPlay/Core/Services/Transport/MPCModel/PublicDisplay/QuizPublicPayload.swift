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
}


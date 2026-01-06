//
//  QuizPublicPayload.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 20/11/2025.
//

import Foundation


struct PublicQuizState: Codable, Equatable {
    let question: QuizQuestion
    let formattedTime: String
    let buzzingTeam: Team?
    let isAnswerRevealed: Bool
    let isHintVisible: Bool
}


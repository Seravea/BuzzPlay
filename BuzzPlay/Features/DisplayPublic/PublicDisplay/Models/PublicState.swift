//
//  PublicState.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 20/11/2025.
//

import Foundation

enum PublicState: Codable, Equatable {
    case waiting
    case quiz(PublicQuizState)
    case blindTest(PublicBlindTestState)

    var displayTitle: String? {
        switch self {
        case .quiz(let state):
            return state.setTitle
        case .blindTest(let state):
            return state.title ?? "Blind Test"
        case .waiting:
            return nil
        }
    }

    var displaySubtitle: String? {
        switch self {
        case .quiz(let state):
            let questionText = state.question.title
            let truncated = questionText.prefix(35).trimmingCharacters(in: .whitespaces)
            return truncated + (questionText.count > 35 ? "..." : "")
        case .blindTest(let state):
            return state.artist ?? "En attente..."
        case .waiting:
            return nil
        }
    }
}

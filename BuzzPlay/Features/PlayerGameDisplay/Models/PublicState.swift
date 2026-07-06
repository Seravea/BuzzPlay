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

    /// #chantier-indice — le cadeau « Voir un indice » ne doit être proposé que si un indice
    /// existe RÉELLEMENT pour la manche EN COURS (sinon 50 Notes perdues : les questions IA et
    /// les packs remote ont `indices` vide). La question complète est déjà embarquée dans l'état
    /// → on dérive la dispo côté Player, sans message MPC dédié. BlindTest : indices génériques
    /// (BlindTestHints) → toujours dispo tant que la réponse n'est pas révélée. Hors manche
    /// active (waiting / réponse révélée) : pas d'indice à acheter.
    var hintAvailable: Bool {
        switch self {
        case .quiz(let state):
            return !state.isAnswerRevealed && !state.question.indices.isEmpty
        case .blindTest(let state):
            return !state.isAnswerRevealed
        case .waiting:
            return false
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

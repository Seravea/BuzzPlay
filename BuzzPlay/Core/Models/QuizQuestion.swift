//
//  QuizQuestion.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 18/11/2025.
//

import Foundation
import SwiftUI

struct QuizQuestion: Identifiable, Codable, Hashable {
    var id = UUID()
    let title: String
    var answers: [String]
    let theme: String?
    let difficulty: QuizDifficulty?
    let tone: String?
    var indices: [String] = []
    var correctAnswer: String?
    var funFact: String?
    var source: QuizSource = .bundled
    var questionType: QuizQuestionType = .standard
}

enum QuizDifficulty: String, CaseIterable, Identifiable, Codable, Hashable {
    case facile, moyen, difficile, expert

    var id: String { rawValue }

    var label: String {
        switch self {
        case .facile: "Facile"
        case .moyen: "Moyen"
        case .difficile: "Difficile"
        case .expert: "Expert"
        }
    }

    var guideline: String {
        switch self {
        case .facile:
            return "Tout le monde devrait connaître. Connaissances primaires ou très connues."
        case .moyen:
            return "Culture générale standard. Un adulte curieux devrait trouver."
        case .difficile:
            return "Nécessite d'être passionné ou très curieux sur le thème."
        case .expert:
            return "Questions très pointues. Seuls les vrais experts trouveront."
        }
    }

    var color: Color {
        switch self {
        case .facile: Color(hex: "#00C950")
        case .moyen: Color(hex: "#F0B100")
        case .difficile: Color(hex: "#FF6900")
        case .expert: Color(hex: "#FB2C36")
        }
    }
}

enum QuizSource: String, CaseIterable, Codable, Hashable {
    case aiGenerated
    case bundled
}

enum QuizQuestionType: String, CaseIterable, Codable, Hashable, Identifiable {
    case standard
    case rebus

    var id: String { rawValue }

    var label: String {
        switch self {
        case .standard: "Standard"
        case .rebus: "Rébus"
        }
    }
}



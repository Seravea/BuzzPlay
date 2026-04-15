//
//  QuizSet.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 15/04/2026.
//

import Foundation

/// Un quiz concret : un titre, rattaché à un thème, avec sa liste de questions.
/// C'est ce que le Master sélectionne avant de lancer une partie.
struct QuizSet: Identifiable, Hashable {
    let id: UUID
    let title: String
    let theme: QuizTheme
    let questions: [QuizQuestion]

    init(id: UUID = UUID(), title: String, theme: QuizTheme, questions: [QuizQuestion]) {
        self.id = id
        self.title = title
        self.theme = theme
        self.questions = questions
    }
}

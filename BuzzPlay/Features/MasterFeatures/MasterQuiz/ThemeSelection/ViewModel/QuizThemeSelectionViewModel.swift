//
//  QuizThemeSelectionViewModel.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 15/04/2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class QuizThemeSelectionViewModel {

    private let gameVM: MasterFlowViewModel

    var quizRoundsTotal: Int { gameVM.quizRoundsTotal }

    init(gameVM: MasterFlowViewModel) {
        self.gameVM = gameVM
    }

    var groupedThemes: [(label: String, themes: [QuizTheme])] {
        [
            ("Par décennie", QuizThemes.eras),
            ("Par genre", QuizThemes.genres)
        ]
    }

    func sets(for theme: QuizTheme) -> [QuizSet] {
        QuizSamples.sets(for: theme)
    }

    func selectSet(_ set: QuizSet) {
        let limit = gameVM.quizRoundsTotal
        let questions = limit > 0 && set.questions.count > limit
            ? Array(set.questions.shuffled().prefix(limit))
            : set.questions
        gameVM.selectedQuizSet = QuizSet(id: set.id, title: set.title, theme: set.theme, questions: questions)
    }
}

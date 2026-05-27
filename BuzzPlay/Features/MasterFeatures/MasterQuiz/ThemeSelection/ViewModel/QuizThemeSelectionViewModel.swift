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
        gameVM.selectedQuizSet = set
    }
}

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

    let themes: [QuizTheme] = QuizThemes.all

    var quizRoundsTotal: Int { gameVM.quizRoundsTotal }

    init(gameVM: MasterFlowViewModel) {
        self.gameVM = gameVM
    }

    func sets(for theme: QuizTheme) -> [QuizSet] {
        QuizSamples.sets(for: theme)
    }

    /// Le Master sélectionne un QuizSet → on le stocke dans le flow, puis on navigue.
    func selectSet(_ set: QuizSet) {
        gameVM.selectedQuizSet = set
    }
}

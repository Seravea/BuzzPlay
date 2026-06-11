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

    // #v1-packs — catalogue unifié (in-app + packs distants) centralisé dans QuizCatalog
    // (« les packs = les catégories »), partagé tel quel avec le sélecteur de l'IA.
    var groupedThemes: [(label: String, themes: [QuizTheme])] { QuizCatalog.groupedThemes }

    func sets(for theme: QuizTheme) -> [QuizSet] { QuizCatalog.sets(for: theme) }

    // Infos premium pour l'UI (cadenas + sheet d'achat)
    func remotePack(for theme: QuizTheme) -> RemoteQuizPack? { QuizCatalog.pack(for: theme) }

    func isLocked(_ theme: QuizTheme) -> Bool { QuizCatalog.isLocked(theme) }

    func selectSet(_ set: QuizSet) {
        let limit = gameVM.quizRoundsTotal
        var questions = set.questions

        if limit > 0 {
            if questions.count > limit {
                // Trop de questions : on tronque aléatoirement au quota.
                questions = Array(questions.shuffled().prefix(limit))
            } else if questions.count < limit {
                // Trop peu (ex : génération IA limitée) : on complète avec des classiques.
                questions = fillWithBundled(questions, upTo: limit, preferredTheme: set.theme)
            }
        }

        gameVM.selectedQuizSet = QuizSet(id: set.id, title: set.title, theme: set.theme, questions: questions)
    }

    /// Complète un set trop court avec des questions classiques (bundled), sans doublon de
    /// titre. Priorité au thème courant, puis élargissement aux autres thèmes si nécessaire.
    private func fillWithBundled(_ base: [QuizQuestion], upTo limit: Int, preferredTheme: QuizTheme) -> [QuizQuestion] {
        var result = base
        var seen = Set(base.map { AIQuizGenerator.normalizeTitle($0.title) })

        let preferred = QuizSamples.sets(for: preferredTheme).flatMap(\.questions).shuffled()
        let others = QuizThemes.all
            .filter { $0 != preferredTheme }
            .flatMap { QuizSamples.sets(for: $0) }
            .flatMap(\.questions)
            .shuffled()

        for question in preferred + others {
            guard result.count < limit else { break }
            let key = AIQuizGenerator.normalizeTitle(question.title)
            guard !key.isEmpty, !seen.contains(key) else { continue }
            seen.insert(key)
            result.append(question)
        }
        return result
    }
}

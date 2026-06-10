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
        var groups: [(label: String, themes: [QuizTheme])] = [
            ("Par décennie", QuizThemes.eras),
            ("Par genre", QuizThemes.genres)
        ]
        // #v1-packs — packs distants (gratuits ou premium) dans leur propre section.
        let remotePacks = RemoteQuizPackCatalog.shared.packs
        if !remotePacks.isEmpty {
            groups.append(("Packs bonus", remotePacks.map(\.theme)))
        }
        return groups
    }

    func sets(for theme: QuizTheme) -> [QuizSet] {
        QuizSamples.sets(for: theme) + RemoteQuizPackCatalog.shared.sets(for: theme)
    }

    // #v1-packs — infos premium pour l'UI (cadenas + sheet d'achat)
    func remotePack(for theme: QuizTheme) -> RemoteQuizPack? {
        RemoteQuizPackCatalog.shared.pack(for: theme)
    }

    func isLocked(_ theme: QuizTheme) -> Bool {
        guard let pack = remotePack(for: theme) else { return false }
        return !QuizPackStore.shared.isUnlocked(pack)
    }

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

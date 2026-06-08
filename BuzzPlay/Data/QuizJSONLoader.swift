//
//  QuizJSONLoader.swift
//  BuzzPlay
//

import Foundation

// MARK: - Decodable structs (JSON → modèles app)

private struct QuizBundleJSON: Decodable {
    let sets: [QuizSetJSON]
}

private struct QuizSetJSON: Decodable {
    let id: String
    let title: String
    let themeKey: String
    let questions: [QuizQuestionJSON]
}

private struct QuizQuestionJSON: Decodable {
    let question: String
    let answer: String
    let difficulty: String   // "facile" | "moyen" | "difficile" | "expert"
    let funFact: String?
}

// MARK: - Loader

enum QuizJSONLoader {

    // Chargé une seule fois au premier accès
    static let allSets: [QuizSet] = load()

    static func sets(for theme: QuizTheme) -> [QuizSet] {
        allSets.filter { $0.theme == theme }
    }

    // MARK: - Private

    private static let themeMap: [String: QuizTheme] = [
        "annees80":  QuizThemes.annees80,
        "annees90":  QuizThemes.annees90,
        "annees2000": QuizThemes.annees2000,
        "annees2010": QuizThemes.annees2010,
        "popFR":     QuizThemes.popFR,
        "popIntl":   QuizThemes.popIntl,
        "rock":      QuizThemes.rock,
        "rapFR":     QuizThemes.rapFR,
        "rapUS":     QuizThemes.rapUS,
        "electro":   QuizThemes.electro,
        "rnbSoul":   QuizThemes.rnbSoul,
        "kpop":      QuizThemes.kpop,
    ]

    private static func load() -> [QuizSet] {
        guard let url = Bundle.main.url(forResource: "quiz_sets", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            return []
        }

        guard let bundle = try? JSONDecoder().decode(QuizBundleJSON.self, from: data) else {
            print("⚠️ QuizJSONLoader: échec de décodage de quiz_sets.json")
            return []
        }

        return bundle.sets.compactMap { setJSON -> QuizSet? in
            guard let theme = themeMap[setJSON.themeKey] else {
                print("⚠️ QuizJSONLoader: themeKey inconnu '\(setJSON.themeKey)'")
                return nil
            }

            let questions: [QuizQuestion] = setJSON.questions.map { q in
                QuizQuestion(
                    title: q.question,
                    answers: [q.answer],
                    theme: theme.title,
                    difficulty: QuizDifficulty(rawValue: q.difficulty) ?? .moyen,
                    tone: nil,
                    indices: [],
                    correctAnswers: [q.answer],
                    funFact: q.funFact,
                    source: .bundled
                )
            }

            return QuizSet(
                id: UUID(uuidString: setJSON.id) ?? UUID(),
                title: setJSON.title,
                theme: theme,
                questions: questions
            )
        }
    }
}

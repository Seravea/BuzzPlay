//
//  AIQuizGenerator.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 26/05/2026.
//

import Foundation
import Observation

#if os(iOS) && swift(>=5.9)
import FoundationModels
#endif

@Observable
@MainActor
class AIQuizGenerator {
    var generatedQuestions: [QuizQuestion] = []
    var isGenerating: Bool = false
    var error: QuizGenerationError? = nil
    var generationProgress: Double = 0.0
    var totalQuestionCount: Int = 0

    // Anti-doublons : titres des questions déjà générées (persistés entre sessions)
    private static let udKey = "buzzplay.ai.previousQuestions"
    private var previousQuestionTitles: [String] = {
        UserDefaults.standard.stringArray(forKey: udKey) ?? []
    }()

    var isAvailable: Bool {
        #if os(iOS) && swift(>=5.9)
        if #available(iOS 26.0, *) {
            switch SystemLanguageModel.default.availability {
            case .available: return true
            case .unavailable: return false
            }
        }
        #endif
        return false
    }

    @available(iOS 26.0, *)
    func generate(
        themes: [QuizTheme],
        difficulty: QuizDifficulty,
        count: Int
    ) async {
        guard isAvailable else {
            error = .notAvailable
            return
        }

        isGenerating = true
        generatedQuestions = []
        generationProgress = 0.0
        totalQuestionCount = count
        error = nil

        let session = LanguageModelSession()
        let prompt = buildQuizPrompt(themes: themes, difficulty: difficulty, count: count + 2, previousQuestions: previousQuestionTitles)
        let themeLabel = themes.map(\.title).joined(separator: "/")

        do {
            let stream = try session.streamResponse(
                generating: AIGeneratedQuiz.self,
                includeSchemaInPrompt: true,
                options: GenerationOptions(),
                prompt: { Prompt(prompt) }
            )

            for try await snapshot in stream {
                let aiQuiz = snapshot.content
                guard let aiQuestions = aiQuiz.questions else {
                    print("🤖 AIQuiz snapshot: questions nil")
                    continue
                }

                let questions = aiQuestions.compactMap { aiQ -> QuizQuestion? in
                    guard let question = aiQ.question, !question.isEmpty,
                          let correctAnswer = aiQ.correctAnswer, !correctAnswer.isEmpty else {
                        return nil
                    }
                    return QuizQuestion(
                        title: question,
                        answers: [correctAnswer],
                        theme: themeLabel,
                        difficulty: QuizDifficulty(rawValue: aiQ.difficulty ?? "moyen") ?? .moyen,
                        tone: nil,
                        indices: [],
                        correctAnswer: correctAnswer,
                        funFact: aiQ.funFact,
                        source: .aiGenerated
                    )
                }

                let trimmed = Array(questions.prefix(count))
                print("🤖 AIQuiz snapshot: \(trimmed.count)/\(count) questions")

                self.generatedQuestions = trimmed
                self.generationProgress = Double(trimmed.count) / Double(count)
            }
            print("🤖 AIQuiz terminé: \(self.generatedQuestions.count) questions finales")
        } catch {
            self.error = .generationFailed(error.localizedDescription)
        }

        self.isGenerating = false
        self.generationProgress = 1.0

        if !self.generatedQuestions.isEmpty {
            let newTitles = self.generatedQuestions.map(\.title)
            let combined = (previousQuestionTitles + newTitles).suffix(100)
            previousQuestionTitles = Array(combined)
            UserDefaults.standard.set(previousQuestionTitles, forKey: Self.udKey)
        }
    }
}

enum QuizGenerationError: LocalizedError {
    case notAvailable
    case generationFailed(String)

    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "Apple Intelligence n'est pas disponible sur cet appareil."
        case .generationFailed(let msg):
            return "Génération échouée : \(msg)"
        }
    }
}

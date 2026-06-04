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
    /// Vrai pendant les passes de complétion (2-3) lancées depuis la Review.
    var isCompleting: Bool = false
    var error: QuizGenerationError? = nil
    var generationProgress: Double = 0.0
    var totalQuestionCount: Int = 0

    var regeneratingQuestionID: UUID? = nil

    // Anti-doublons : titres des questions déjà générées (persistés entre sessions)
    private static let udKey = "buzzplay.ai.previousQuestions"
    private var previousQuestionTitles: [String] = {
        UserDefaults.standard.stringArray(forKey: udKey) ?? []
    }()

    // Paramètres de la dernière génération — mémorisés pour pouvoir régénérer
    // une question unitairement avec le même thème et la même difficulté.
    private var lastThemes: [QuizTheme] = []
    private var lastDifficulty: QuizDifficulty = .moyen

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

    // 1 passe initiale + jusqu'à 2 passes de complément pour atteindre le quota.
    private static let maxGenerationPasses = 3
    // Budget temps d'une passe de complément (la 1re passe n'est pas limitée).
    // ~30 tokens/s on-device → 8 s couvre 2-3 questions ; au-delà on abandonne.
    private static let completionPassTimeout: TimeInterval = 8

    // MARK: - Génération en deux temps (Setup → Review)

    /// Passe 1 uniquement. Le Setup appelle ceci, puis ouvre la Review immédiatement
    /// sans attendre les passes de complétion.
    @available(iOS 26.0, *)
    func generateInitialPass(
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
        lastThemes = themes
        lastDifficulty = difficulty

        await runGenerationLoop(target: count, seed: [], maxPasses: 1, firstPassUnlimited: true)

        isGenerating = false
        generationProgress = Double(generatedQuestions.count) / Double(count)
    }

    /// Passes de complétion (max 2 passes supplémentaires) lancées depuis la Review
    /// quand il manque des questions. Flag `isCompleting` visible dans la Review.
    @available(iOS 26.0, *)
    func completeGeneration(target: Int) async {
        guard isAvailable, !isCompleting, !isGenerating else { return }
        guard generatedQuestions.count < target else { return }
        isCompleting = true
        await runGenerationLoop(target: target, seed: generatedQuestions, maxPasses: 2, firstPassUnlimited: false)
        isCompleting = false
    }

    /// Boucle de génération commune : part de `seed`, déduplique (batch + historique) et
    /// répète jusqu'à `target` questions ou épuisement des passes. Met à jour
    /// `generatedQuestions` en continu et persiste l'historique anti-doublons à la fin.
    ///
    /// Passe 1 : génération principale, sans limite de temps (durée ∝ au nombre demandé).
    /// Passes 2-3 (complément automatique) : chacune bornée par `completionPassTimeout`,
    /// et la boucle s'arrête dès qu'une passe ne ramène aucune question inédite.
    /// `maxPasses` : nb de passes à effectuer dans cet appel.
    /// `firstPassUnlimited` : si vrai, la 1re passe n'a pas de deadline (génération initiale).
    @available(iOS 26.0, *)
    private func runGenerationLoop(
        target: Int,
        seed: [QuizQuestion],
        maxPasses: Int,
        firstPassUnlimited: Bool
    ) async {
        let themeLabel = lastThemes.map(\.title).joined(separator: "/")

        var seenTitles = Set((previousQuestionTitles + seed.map(\.title)).map(Self.normalizeTitle))
        var seenAnswers = Set((previousQuestionTitles + seed.compactMap(\.correctAnswer)).map(Self.normalizeTitle).filter { !$0.isEmpty })
        var accepted = seed
        self.generatedQuestions = seed

        do {
            var pass = 0
            while accepted.count < target && pass < maxPasses {
                pass += 1
                let countBefore = accepted.count
                let passDeadline = (firstPassUnlimited && pass == 1)
                    ? Date.distantFuture
                    : Date().addingTimeInterval(Self.completionPassTimeout)
                let remaining = target - accepted.count

                let exclude = previousQuestionTitles + accepted.map(\.title)
                let prompt = buildQuizPrompt(
                    themes: lastThemes,
                    difficulty: lastDifficulty,
                    count: remaining + 2,
                    previousQuestions: exclude
                )

                let session = LanguageModelSession()
                let stream = session.streamResponse(
                    generating: AIGeneratedQuiz.self,
                    includeSchemaInPrompt: true,
                    options: GenerationOptions(),
                    prompt: { Prompt(prompt) }
                )

                for try await snapshot in stream {
                    if Date() >= passDeadline { break }

                    guard let aiQuestions = snapshot.content.questions else { continue }

                    var batchTitles = seenTitles
                    var batchAnswers = seenAnswers
                    var live = accepted
                    for aiQ in aiQuestions {
                        guard live.count < target else { break }
                        guard let question = aiQ.question, !question.isEmpty,
                              let correctAnswer = aiQ.correctAnswer, !correctAnswer.isEmpty else { continue }
                        let titleKey = Self.normalizeTitle(question)
                        let answerKey = Self.normalizeTitle(correctAnswer)
                        guard !titleKey.isEmpty,
                              !batchTitles.contains(titleKey),
                              !batchAnswers.contains(answerKey) else { continue }
                        batchTitles.insert(titleKey)
                        batchAnswers.insert(answerKey)
                        live.append(QuizQuestion(
                            title: question,
                            answers: [correctAnswer],
                            theme: themeLabel,
                            difficulty: QuizDifficulty(rawValue: aiQ.difficulty ?? "moyen") ?? .moyen,
                            tone: nil,
                            indices: [],
                            correctAnswer: correctAnswer,
                            funFact: aiQ.funFact,
                            source: .aiGenerated
                        ))
                    }

                    self.generatedQuestions = live
                    self.generationProgress = Double(live.count) / Double(target)
                }

                accepted = self.generatedQuestions
                seenTitles = Set((previousQuestionTitles + accepted.map(\.title)).map(Self.normalizeTitle))
                seenAnswers = Set((previousQuestionTitles + accepted.compactMap(\.correctAnswer)).map(Self.normalizeTitle).filter { !$0.isEmpty })
                print("🤖 AIQuiz passe \(pass): \(accepted.count)/\(target) questions uniques")

                if pass > 1 && accepted.count == countBefore { break }
            }
            print("🤖 AIQuiz terminé: \(accepted.count) questions finales")
        } catch is CancellationError {
            // Annulation volontaire : on garde l'acquis sans erreur.
        } catch {
            self.error = mapGenerationError(error)
        }

        if !self.generatedQuestions.isEmpty {
            let newTitles = self.generatedQuestions.map(\.title)
            let combined = (previousQuestionTitles + newTitles).suffix(100)
            previousQuestionTitles = Array(combined)
            UserDefaults.standard.set(previousQuestionTitles, forKey: Self.udKey)
        }
    }

    /// Régénère une seule question (rejetée en review) en gardant le thème et la
    /// difficulté d'origine. La nouvelle question évite tous les titres déjà affichés
    /// ainsi que l'historique persisté. Une seule régénération à la fois.
    @available(iOS 26.0, *)
    func regenerateQuestion(id: UUID) async {
        guard isAvailable else {
            error = .notAvailable
            return
        }
        guard regeneratingQuestionID == nil,
              !lastThemes.isEmpty,
              generatedQuestions.contains(where: { $0.id == id }) else {
            return
        }

        regeneratingQuestionID = id
        error = nil

        let themeLabel = lastThemes.map(\.title).joined(separator: "/")
        let exclude = previousQuestionTitles + generatedQuestions.map(\.title)
        let seenTitles = Set(exclude.map(Self.normalizeTitle))
        let seenAnswers = Set((previousQuestionTitles + generatedQuestions.compactMap(\.correctAnswer)).map(Self.normalizeTitle).filter { !$0.isEmpty })

        do {
            // count: 3 → marge pour qu'au moins une question soit réellement inédite.
            let prompt = buildQuizPrompt(
                themes: lastThemes,
                difficulty: lastDifficulty,
                count: 3,
                previousQuestions: exclude
            )

            let session = LanguageModelSession()
            let stream = session.streamResponse(
                generating: AIGeneratedQuiz.self,
                includeSchemaInPrompt: true,
                options: GenerationOptions(),
                prompt: { Prompt(prompt) }
            )

            // Les snapshots sont cumulatifs et partiels : on réévalue à chaque tour,
            // le dernier snapshot fournit la question complète (funFact inclus).
            var replacement: QuizQuestion? = nil
            for try await snapshot in stream {
                guard let aiQuestions = snapshot.content.questions else { continue }
                for aiQ in aiQuestions {
                    guard let question = aiQ.question, !question.isEmpty,
                          let correctAnswer = aiQ.correctAnswer, !correctAnswer.isEmpty else {
                        continue
                    }
                    let titleKey = Self.normalizeTitle(question)
                    let answerKey = Self.normalizeTitle(correctAnswer)
                    guard !titleKey.isEmpty,
                          !seenTitles.contains(titleKey),
                          !seenAnswers.contains(answerKey) else { continue }
                    replacement = QuizQuestion(
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
                    break
                }
            }

            if let replacement,
               let index = generatedQuestions.firstIndex(where: { $0.id == id }) {
                generatedQuestions[index] = replacement
                // Persiste le nouveau titre pour l'anti-doublon des prochaines parties.
                let combined = (previousQuestionTitles + [replacement.title]).suffix(100)
                previousQuestionTitles = Array(combined)
                UserDefaults.standard.set(previousQuestionTitles, forKey: Self.udKey)
            } else if !Task.isCancelled {
                // Le modèle n'a proposé que des doublons : on le signale en review.
                self.error = .noFreshQuestion
            }
        } catch is CancellationError {
            // Annulation volontaire.
        } catch {
            self.error = mapGenerationError(error)
        }

        regeneratingQuestionID = nil
    }

    nonisolated static func normalizeTitle(_ raw: String) -> String {
        raw.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "fr_FR"))
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    private func mapGenerationError(_ error: Error) -> QuizGenerationError {
        let msg = error.localizedDescription.lowercased()
        if msg.contains("context") || msg.contains("window") || msg.contains("length")
            || msg.contains("token") || msg.contains("size") {
            return .contextOverflow
        }
        return .generationFailed
    }
}

enum QuizGenerationError: LocalizedError {
    case notAvailable
    case generationFailed
    case noFreshQuestion
    case contextOverflow

    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "Apple Intelligence n'est pas disponible sur cet appareil."
        case .generationFailed:
            return "Génération échouée. Réessaie."
        case .noFreshQuestion:
            return "Aucune nouvelle question trouvée. Réessaie ou lance avec celles-ci."
        case .contextOverflow:
            return "Trop de sessions d'affilée — réessaie dans un instant."
        }
    }
}

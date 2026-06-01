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

    // id de la question en cours de régénération individuelle (nil si aucune)
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

        // Mémorise les paramètres pour la régénération unitaire et la complétion en review.
        lastThemes = themes
        lastDifficulty = difficulty

        await runGenerationLoop(target: count, seed: [])

        self.isGenerating = false
        self.generationProgress = 1.0
    }

    /// Boucle de génération commune : part de `seed`, déduplique (batch + historique) et
    /// répète jusqu'à `target` questions ou épuisement des passes. Met à jour
    /// `generatedQuestions` en continu et persiste l'historique anti-doublons à la fin.
    ///
    /// Passe 1 : génération principale, sans limite de temps (durée ∝ au nombre demandé).
    /// Passes 2-3 (complément automatique) : chacune bornée par `completionPassTimeout`,
    /// et la boucle s'arrête dès qu'une passe ne ramène aucune question inédite.
    @available(iOS 26.0, *)
    private func runGenerationLoop(target: Int, seed: [QuizQuestion]) async {
        let themeLabel = lastThemes.map(\.title).joined(separator: "/")

        // Filet anti-doublons : titres normalisés déjà retenus (historique + lot en cours).
        var seenNormalized = Set((previousQuestionTitles + seed.map(\.title)).map(Self.normalizeTitle))
        var accepted = seed
        self.generatedQuestions = seed

        do {
            var pass = 0
            while accepted.count < target && pass < Self.maxGenerationPasses {
                pass += 1
                let isCompletionPass = pass > 1
                let countBefore = accepted.count
                // Les passes de complément sont limitées dans le temps ; la 1re ne l'est pas.
                let passDeadline = isCompletionPass
                    ? Date().addingTimeInterval(Self.completionPassTimeout)
                    : Date.distantFuture
                let remaining = target - accepted.count

                // Le prompt rappelle au modèle tout ce qu'il doit éviter : l'historique
                // persisté + ce qui a déjà été retenu lors des passes précédentes.
                let exclude = previousQuestionTitles + accepted.map(\.title)
                let prompt = buildQuizPrompt(
                    themes: lastThemes,
                    difficulty: lastDifficulty,
                    count: remaining + 2,
                    previousQuestions: exclude
                )

                let session = LanguageModelSession()
                let stream = try session.streamResponse(
                    generating: AIGeneratedQuiz.self,
                    includeSchemaInPrompt: true,
                    options: GenerationOptions(),
                    prompt: { Prompt(prompt) }
                )

                for try await snapshot in stream {
                    // Coupe une passe de complément qui s'éternise.
                    if Date() >= passDeadline { break }

                    guard let aiQuestions = snapshot.content.questions else {
                        print("🤖 AIQuiz snapshot: questions nil")
                        continue
                    }

                    // Reconstruction idempotente : les snapshots sont cumulatifs, on repart
                    // donc de `accepted` (figé) et on déduplique le contenu du snapshot.
                    var batchSeen = seenNormalized
                    var live = accepted
                    for aiQ in aiQuestions {
                        guard live.count < target else { break }
                        guard let question = aiQ.question, !question.isEmpty,
                              let correctAnswer = aiQ.correctAnswer, !correctAnswer.isEmpty else {
                            continue
                        }
                        let key = Self.normalizeTitle(question)
                        guard !key.isEmpty, !batchSeen.contains(key) else { continue }
                        batchSeen.insert(key)
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

                // Fige le résultat de la passe et met à jour le filtre pour la passe suivante.
                accepted = self.generatedQuestions
                seenNormalized = Set(
                    (previousQuestionTitles + accepted.map(\.title)).map(Self.normalizeTitle)
                )
                print("🤖 AIQuiz passe \(pass): \(accepted.count)/\(target) questions uniques")

                // Le modèle n'a plus rien d'inédit à proposer : inutile d'insister.
                if isCompletionPass && accepted.count == countBefore { break }
            }
            print("🤖 AIQuiz terminé: \(accepted.count) questions finales")
        } catch is CancellationError {
            // Annulation volontaire (sheet fermée) : on garde ce qui a été généré, sans erreur.
        } catch {
            self.error = .generationFailed(error.localizedDescription)
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
        // À éviter : l'historique + toutes les questions affichées (dont celle rejetée).
        let exclude = previousQuestionTitles + generatedQuestions.map(\.title)
        let seen = Set(exclude.map(Self.normalizeTitle))

        do {
            // count: 3 → marge pour qu'au moins une question soit réellement inédite.
            let prompt = buildQuizPrompt(
                themes: lastThemes,
                difficulty: lastDifficulty,
                count: 3,
                previousQuestions: exclude
            )

            let session = LanguageModelSession()
            let stream = try session.streamResponse(
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
                    let key = Self.normalizeTitle(question)
                    guard !key.isEmpty, !seen.contains(key) else { continue }
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
            // Annulation volontaire (sheet fermée) : aucun message d'erreur.
        } catch {
            self.error = .generationFailed(error.localizedDescription)
        }

        regeneratingQuestionID = nil
    }

    /// Normalise un intitulé pour comparer les questions sans tenir compte de la casse,
    /// des accents, de la ponctuation ni des espaces multiples.
    /// « Qui chante 'Thriller' ? » et « qui chante thriller » donnent la même clé.
    nonisolated static func normalizeTitle(_ raw: String) -> String {
        raw.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "fr_FR"))
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
}

enum QuizGenerationError: LocalizedError {
    case notAvailable
    case generationFailed(String)
    case noFreshQuestion

    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "Apple Intelligence n'est pas disponible sur cet appareil."
        case .generationFailed(let msg):
            return "Génération échouée : \(msg)"
        case .noFreshQuestion:
            return "Aucune nouvelle question trouvée pour l'instant. Réessaie ou lance avec celles-ci."
        }
    }
}

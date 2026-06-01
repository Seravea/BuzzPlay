//
//  AIQuizReviewView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 26/05/2026.
//

import SwiftUI

@available(iOS 26.0, *)
struct AIQuizReviewView: View {
    @Bindable var generator: AIQuizGenerator
    let quizSet: QuizSet
    /// Nombre de questions attendu (réglage du lobby). Sert à proposer la complétion.
    let targetCount: Int
    let onLaunch: (QuizSet) -> Void
    let onBack: () -> Void

    // Tâche de régénération en cours, annulée si la vue disparaît.
    @State private var regenTask: Task<Void, Never>?

    // Source de vérité : le generator, pas le quizSet (évite les problèmes de timing de sheet)
    private var questions: [QuizQuestion] {
        generator.generatedQuestions.isEmpty ? quizSet.questions : generator.generatedQuestions
    }

    // Questions manquantes par rapport au réglage du lobby (0 si le quota est atteint).
    private var missingCount: Int {
        max(0, targetCount - questions.count)
    }

    // Lancement bloqué seulement pendant une (ré)génération en cours. Les questions
    // manquantes sont complétées automatiquement par des classiques au lancement.
    private var canLaunch: Bool {
        !questions.isEmpty
            && generator.regeneratingQuestionID == nil
            && !generator.isGenerating
    }

    var body: some View {
        ZStack {
            BackgroundAppView().ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: onBack) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Retour")
                                .font(.nohemi(.body, weight: .semiBold))
                        }
                        .foregroundStyle(.white)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text(quizSet.theme.title)
                            .font(.nohemi(.body, weight: .semiBold))
                        Text("\(questions.count) questions")
                            .font(.nohemi(.caption, weight: .regular))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)

                Divider().opacity(0.1)

                // Bandeau d'erreur (régénération échouée ou sans résultat) — tap pour fermer.
                if let error = generator.error {
                    Button {
                        generator.error = nil
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange)
                            Text(error.localizedDescription)
                                .font(.nohemi(.caption, weight: .regular))
                                .foregroundStyle(.white.opacity(0.85))
                                .lineLimit(2)
                            Spacer(minLength: 8)
                            Image(systemName: "xmark")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.4))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Color.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 10))
                        .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.orange.opacity(0.3), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                }

                // Questions list
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(questions) { question in
                            QuestionCardAI(
                                question: question,
                                canRegenerate: question.source == .aiGenerated,
                                isRegenerating: generator.regeneratingQuestionID == question.id,
                                isBusy: generator.regeneratingQuestionID != nil,
                                onRegenerate: {
                                    regenTask = Task { await generator.regenerateQuestion(id: question.id) }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }

                // Transparence : la complétion par l'IA est automatique ; s'il manque
                // encore des questions, elles seront comblées par des classiques au lancement.
                if missingCount > 0 {
                    HStack(spacing: 6) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 12))
                        Text("\(missingCount) question\(missingCount > 1 ? "s" : "") classique\(missingCount > 1 ? "s" : "") ajoutée\(missingCount > 1 ? "s" : "") au lancement")
                            .font(.nohemi(.caption2, weight: .regular))
                    }
                    .foregroundStyle(.white.opacity(0.5))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }

                Divider().opacity(0.1)

                // Footer — CTAs
                HStack(spacing: 12) {
                    Button(action: onBack) {
                        Text("Retour")
                            .font(.nohemi(.body, weight: .semiBold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
                    }

                    Button(action: {
                        let finalSet = QuizSet(
                            id: quizSet.id,
                            title: quizSet.title,
                            theme: quizSet.theme,
                            questions: questions
                        )
                        onLaunch(finalSet)
                    }) {
                        Text("Lancer")
                            .font(.nohemi(.body, weight: .semiBold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(
                                canLaunch
                                    ? LinearGradient(colors: [Color(hex: "#AD46FF"), Color(hex: "#F6339A")], startPoint: .topLeading, endPoint: .bottomTrailing)
                                    : LinearGradient(colors: [Color.white.opacity(0.08), Color.white.opacity(0.06)], startPoint: .topLeading, endPoint: .bottomTrailing),
                                in: RoundedRectangle(cornerRadius: 12)
                            )
                    }
                    .disabled(!canLaunch)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .onDisappear { regenTask?.cancel() }
    }
}

@available(iOS 26.0, *)
private struct QuestionCardAI: View {
    let question: QuizQuestion
    var canRegenerate: Bool = false
    var isRegenerating: Bool = false
    var isBusy: Bool = false
    var onRegenerate: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Question
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(.green)
                Text(question.title)
                    .font(.nohemi(.body, weight: .semiBold))
                    .foregroundStyle(.white)
                    .lineLimit(3)

                if canRegenerate {
                    Spacer(minLength: 8)
                    Button(action: onRegenerate) {
                        Group {
                            if isRegenerating {
                                ProgressView()
                                    .controlSize(.small)
                                    .tint(.white)
                            } else {
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(.white.opacity(isBusy ? 0.25 : 0.65))
                            }
                        }
                        .frame(width: 28, height: 28)
                        .background(.white.opacity(0.06), in: Circle())
                    }
                    .disabled(isBusy)
                    .accessibilityLabel("Régénérer cette question")
                }
            }

            // Réponse
            if let correctAnswer = question.correctAnswer {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.4))
                    Text(correctAnswer)
                        .font(.nohemi(.caption, weight: .regular))
                        .foregroundStyle(.white.opacity(0.7))
                }
                .padding(.leading, 28)
            }

            // Anecdote
            if let funFact = question.funFact, !funFact.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(.yellow.opacity(0.6))
                    Text(funFact)
                        .font(.nohemi(.caption2, weight: .regular))
                        .foregroundStyle(.white.opacity(0.6))
                        .lineLimit(3)
                }
                .padding(.leading, 28)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 12))
    }
}

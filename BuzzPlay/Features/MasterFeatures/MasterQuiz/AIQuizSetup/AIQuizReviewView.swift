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

    @State private var regenTask: Task<Void, Never>?
    @State private var completionTask: Task<Void, Never>?
    // Anti-double-tap : passe à true au 1er tap sur "Lancer".
    @State private var hasLaunched = false

    // Source de vérité : le generator, pas le quizSet (évite les problèmes de timing de sheet)
    private var questions: [QuizQuestion] {
        generator.generatedQuestions.isEmpty ? quizSet.questions : generator.generatedQuestions
    }

    // Questions manquantes par rapport au réglage du lobby (0 si le quota est atteint).
    private var missingCount: Int {
        max(0, targetCount - questions.count)
    }

    private var canLaunch: Bool {
        !questions.isEmpty
            && !hasLaunched
            && generator.regeneratingQuestionID == nil
            && !generator.isGenerating
            && !generator.isCompleting
    }

    var body: some View {
        ZStack {
            // Fond géré par .presentationBackground dans la sheet parente (#A2)
            Color.sheetBg.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: onBack) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .textStyle(Typography.footnoteEM)
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
                            .foregroundStyle(Color.textSecondary)
                    }
                }
                .padding(.horizontal, BuzzSpacing.xl)
                .padding(.vertical, BuzzSpacing.md)

                Divider().opacity(0.1)

                // Bandeau d'erreur (régénération échouée ou sans résultat) — tap pour fermer.
                if let error = generator.error {
                    Button {
                        generator.error = nil
                    } label: {
                        HStack(spacing: BuzzSpacing.sm) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange)
                            Text(error.localizedDescription)
                                .font(.nohemi(.caption, weight: .regular))
                                .foregroundStyle(.white.opacity(0.85))
                                .lineLimit(2)
                            Spacer(minLength: 8)
                            Image(systemName: "xmark")
                                .textStyle(Typography.caption2EM)
                                .foregroundStyle(Color.textMuted)
                        }
                        .padding(.horizontal, BuzzSpacing.md)
                        .padding(.vertical, 10)
                        .background(Color.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: BuzzRadius.sm2))
                        .overlay(RoundedRectangle(cornerRadius: BuzzRadius.sm2).strokeBorder(Color.orange.opacity(0.3), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, BuzzSpacing.lg)
                    .padding(.top, 10)
                }

                // Bandeau complétion en cours (passes 2-3 après ouverture de la Review)
                if generator.isCompleting {
                    HStack(spacing: BuzzSpacing.sm) {
                        ProgressView()
                            .controlSize(.mini)
                            .tint(Color.purpleLeading)
                        Text("Ajout de questions en cours…")
                            .font(.nohemi(.caption, weight: .regular))
                            .foregroundStyle(Color.textSoft)
                        Spacer()
                        Text("\(questions.count)/\(targetCount)")
                            .font(.nohemi(.caption, weight: .semiBold))
                            .foregroundStyle(Color.textSecondary)
                    }
                    .padding(.horizontal, BuzzSpacing.lg)
                    .padding(.vertical, 10)
                    .background(Color.purpleLeading.opacity(0.08), in: RoundedRectangle(cornerRadius: BuzzRadius.sm2))
                    .overlay(RoundedRectangle(cornerRadius: BuzzRadius.sm2).strokeBorder(Color.purpleLeading.opacity(0.2), lineWidth: 1))
                    .padding(.horizontal, BuzzSpacing.lg)
                    .padding(.top, 6)
                }

                // Questions list
                ScrollView {
                    VStack(spacing: BuzzSpacing.md) {
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
                    .padding(.horizontal, BuzzSpacing.lg)
                    .padding(.vertical, BuzzSpacing.md)
                }

                // Transparence : la complétion par l'IA est automatique ; s'il manque
                // encore des questions, elles seront comblées par des classiques au lancement.
                if missingCount > 0 {
                    HStack(spacing: 6) {
                        Image(systemName: "info.circle")
                            .textStyle(Typography.caption)
                        Text("\(missingCount) question\(missingCount > 1 ? "s" : "") classique\(missingCount > 1 ? "s" : "") ajoutée\(missingCount > 1 ? "s" : "") au lancement")
                            .font(.nohemi(.caption2, weight: .regular))
                    }
                    .foregroundStyle(Color.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, BuzzSpacing.lg)
                    .padding(.top, BuzzSpacing.sm)
                }

                Divider().opacity(0.1)

                // Footer — CTAs
                HStack(spacing: BuzzSpacing.md) {
                    Button(action: onBack) {
                        Text("Retour")
                            .font(.nohemi(.body, weight: .semiBold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: BuzzRadius.sm))
                    }

                    Button(action: {
                        hasLaunched = true
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
                                    ? LinearGradient(colors: [Color.purpleLeading, Color.purpleTrailing], startPoint: .topLeading, endPoint: .bottomTrailing)
                                    : LinearGradient(colors: [Color.white.opacity(0.08), Color.white.opacity(0.06)], startPoint: .topLeading, endPoint: .bottomTrailing),
                                in: RoundedRectangle(cornerRadius: BuzzRadius.sm)
                            )
                    }
                    .disabled(!canLaunch)
                }
                .padding(.horizontal, BuzzSpacing.lg)
                .padding(.vertical, BuzzSpacing.md)
            }
        }
        .task {
            if #available(iOS 26.0, *), missingCount > 0 {
                completionTask = Task { await generator.completeGeneration(target: targetCount) }
            }
        }
        .onDisappear {
            regenTask?.cancel()
            completionTask?.cancel()
        }
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
        VStack(alignment: .leading, spacing: BuzzSpacing.sm) {
            // Question
            HStack(spacing: BuzzSpacing.sm) {
                Image(systemName: "checkmark.circle.fill")
                    .textStyle(Typography.footnote)
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
                                    .textStyle(Typography.footnoteEM)
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
            if !question.correctAnswers.isEmpty {
                HStack(spacing: BuzzSpacing.sm) {
                    Image(systemName: "arrow.right")
                        .textStyle(Typography.caption)
                        .foregroundStyle(Color.textMuted)
                    Text(question.correctAnswers.joined(separator: " • "))
                        .font(.nohemi(.caption, weight: .regular))
                        .foregroundStyle(Color.textSoft)
                }
                .padding(.leading, 28)
            }

            // Anecdote
            if let funFact = question.funFact, !funFact.isEmpty {
                HStack(spacing: BuzzSpacing.sm) {
                    Image(systemName: "lightbulb.fill")
                        .textStyle(Typography.caption)
                        .foregroundStyle(.yellow.opacity(0.6))
                    Text(funFact)
                        .font(.nohemi(.caption2, weight: .regular))
                        .foregroundStyle(.white.opacity(0.6))
                        .lineLimit(3)
                }
                .padding(.leading, 28)
            }
        }
        .padding(.horizontal, BuzzSpacing.md)
        .padding(.vertical, 10)
        .background(.white.opacity(0.04), in: RoundedRectangle(cornerRadius: BuzzRadius.sm))
    }
}

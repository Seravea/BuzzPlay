//
//  AIQuizSetupView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 26/05/2026.
//

import SwiftUI

@available(iOS 26.0, *)
struct AIQuizSetupView: View {
    @Bindable var generator: AIQuizGenerator
    @State private var selectedTheme: QuizTheme?
    @State private var selectedDifficulty: QuizDifficulty?
    @State private var isGenerating = false

    let quizRoundsTotal: Int
    let onComplete: (QuizSet) -> Void
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            BackgroundAppView().ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("✨ Générer un Quiz")
                        .font(.nohemi(.title2, weight: .bold))
                        .foregroundStyle(.white)
                    Spacer()
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)

                Divider().opacity(0.1)

                // Content
                ScrollView {
                    VStack(spacing: 24) {
                        // THÈME
                        VStack(alignment: .leading, spacing: 12) {
                            Text("THÈME")
                                .font(.nohemi(.caption2, weight: .bold))
                                .foregroundStyle(.white.opacity(0.5))
                                .tracking(0.8)

                            LazyVGrid(columns: [.init(.flexible()), .init(.flexible())], spacing: 12) {
                                ForEach(QuizThemes.all) { theme in
                                    ThemeCardAI(
                                        theme: theme,
                                        isSelected: selectedTheme?.id == theme.id,
                                        action: { selectedTheme = theme }
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 20)

                        // DIFFICULTÉ
                        VStack(alignment: .leading, spacing: 12) {
                            Text("DIFFICULTÉ")
                                .font(.nohemi(.caption2, weight: .bold))
                                .foregroundStyle(.white.opacity(0.5))
                                .tracking(0.8)

                            VStack(spacing: 8) {
                                ForEach(QuizDifficulty.allCases) { difficulty in
                                    DifficultyPillAI(
                                        difficulty: difficulty,
                                        isSelected: selectedDifficulty == difficulty,
                                        action: { selectedDifficulty = difficulty }
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 20)

                        // INFO
                        HStack(spacing: 8) {
                            Image(systemName: "info.circle.fill")
                                .foregroundStyle(.white.opacity(0.4))
                            Text("\(quizRoundsTotal) questions seront générées")
                                .font(.nohemi(.caption, weight: .regular))
                                .foregroundStyle(.white.opacity(0.6))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 10))
                        .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 24)
                }

                Divider().opacity(0.1)

                // Erreur
                if let error = generator.error {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                        Text(error.localizedDescription)
                            .font(.nohemi(.caption, weight: .regular))
                            .foregroundStyle(.white.opacity(0.8))
                            .lineLimit(3)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 10))
                    .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.orange.opacity(0.3), lineWidth: 1))
                    .padding(.horizontal, 20)
                    .padding(.bottom, 8)
                }

                // Live preview des questions générées
                if isGenerating && !generator.generatedQuestions.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(generator.generatedQuestions) { q in
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color(hex: "#AD46FF"))
                                Text(q.title)
                                    .font(.nohemi(.caption, weight: .regular))
                                    .foregroundStyle(.white.opacity(0.75))
                                    .lineLimit(1)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 4)
                    .padding(.bottom, 8)
                }

                // CTA
                if isGenerating {
                    VStack(spacing: 8) {
                        HStack(spacing: 10) {
                            ProgressView(value: generator.generationProgress, total: 1.0)
                                .tint(Color(hex: "#AD46FF"))
                            Text("\(generator.generatedQuestions.count)/\(quizRoundsTotal)")
                                .font(.nohemi(.caption, weight: .semiBold))
                                .foregroundStyle(.white.opacity(0.7))
                                .frame(width: 45, alignment: .trailing)
                        }
                        Text("Génération en cours...")
                            .font(.nohemi(.caption2, weight: .regular))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                } else {
                    Button(action: generate) {
                        Text(generator.error != nil ? "Réessayer" : "✨ Générer")
                            .font(.nohemi(.body, weight: .bold))
                    }
                    .disabled(!canGenerate)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        canGenerate
                            ? LinearGradient(colors: [Color(hex: "#AD46FF"), Color(hex: "#F6339A")], startPoint: .topLeading, endPoint: .bottomTrailing)
                            : LinearGradient(colors: [Color.white.opacity(0.08), Color.white.opacity(0.06)], startPoint: .topLeading, endPoint: .bottomTrailing),
                        in: RoundedRectangle(cornerRadius: 14)
                    )
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                }
            }
        }
    }

    private var canGenerate: Bool {
        selectedTheme != nil && selectedDifficulty != nil && !isGenerating
    }

    @MainActor
    private func generate() {
        guard let theme = selectedTheme, let difficulty = selectedDifficulty else { return }
        isGenerating = true

        Task {
            if #available(iOS 26.0, *) {
                await generator.generate(
                    theme: theme,
                    difficulty: difficulty,
                    count: quizRoundsTotal
                )
            }
            isGenerating = false

            guard generator.error == nil, !generator.generatedQuestions.isEmpty else { return }

            let customSet = QuizSet(
                title: "Quiz généré - \(theme.title)",
                theme: theme,
                questions: generator.generatedQuestions
            )
            onComplete(customSet)
        }
    }
}

@available(iOS 26.0, *)
private struct ThemeCardAI: View {
    let theme: QuizTheme
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(theme.emoji)
                    .font(.system(size: 28))
                Text(theme.title)
                    .font(.nohemi(.caption, weight: .semiBold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(
                isSelected
                    ? theme.color.opacity(0.3)
                    : Color.white.opacity(0.04),
                in: RoundedRectangle(cornerRadius: 14)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(
                        isSelected ? theme.color.opacity(0.6) : Color.white.opacity(0.08),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

@available(iOS 26.0, *)
private struct DifficultyPillAI: View {
    let difficulty: QuizDifficulty
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(difficulty.label)
                    .font(.nohemi(.body, weight: .semiBold))
                    .foregroundStyle(.white)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(difficulty.color)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(
                isSelected
                    ? difficulty.color.opacity(0.15)
                    : Color.white.opacity(0.04),
                in: RoundedRectangle(cornerRadius: 12)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        isSelected ? difficulty.color.opacity(0.4) : Color.white.opacity(0.08),
                        lineWidth: isSelected ? 1.5 : 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
}


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
    @State private var selectedThemeIDs: Set<UUID> = []
    @State private var selectedDifficulty: QuizDifficulty?
    @State private var isGenerating = false
    // Tâche de génération en cours, annulée si la vue disparaît.
    @State private var generationTask: Task<Void, Never>?

    let quizRoundsTotal: Int
    let onComplete: (QuizSet) -> Void
    let onDismiss: () -> Void

    private var selectedThemes: [QuizTheme] {
        QuizThemes.all.filter { selectedThemeIDs.contains($0.id) }
    }

    private var allSelected: Bool {
        selectedThemeIDs.count == QuizThemes.all.count
    }

    private var canGenerate: Bool {
        !selectedThemeIDs.isEmpty && selectedDifficulty != nil && !isGenerating
    }

    var body: some View {
        ZStack {
            // Fond géré par .presentationBackground dans la sheet parente (#A2)
            Color.sheetBg.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("✨ Générer un Quiz")
                        .font(.nohemi(.title2, weight: .bold)).titleTracking()
                        .foregroundStyle(.white)
                    Spacer()
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .textStyle(Typography.footnoteEM)
                            .foregroundStyle(Color.textSecondary)
                    }
                }
                .padding(.horizontal, BuzzSpacing.xl)
                .padding(.vertical, BuzzSpacing.lg)

                Divider().opacity(0.1)

                // Content
                ScrollView {
                    VStack(spacing: BuzzSpacing.xxl) {

                        // THÈMES — Par décennie
                        themeGroup(
                            label: "Par décennie",
                            themes: QuizThemes.eras
                        )

                        // THÈMES — Par genre
                        themeGroup(
                            label: "Par genre",
                            themes: QuizThemes.genres
                        )

                        // Sélection tout / rien
                        Button {
                            if allSelected {
                                selectedThemeIDs = []
                            } else {
                                selectedThemeIDs = Set(QuizThemes.all.map(\.id))
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: allSelected ? "checkmark.circle.fill" : "circle.dotted")
                                    .textStyle(Typography.footnote)
                                Text(allSelected ? "Tout désélectionner" : "Tout sélectionner")
                                    .font(.nohemi(.caption, weight: .bold))
                            }
                            .foregroundStyle(Color.textSecondary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, BuzzSpacing.sm)
                            .background(.white.opacity(0.06), in: Capsule())
                            .overlay(Capsule().strokeBorder(.white.opacity(0.12), lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.horizontal, BuzzSpacing.xl)

                        // DIFFICULTÉ
                        VStack(alignment: .leading, spacing: BuzzSpacing.md) {
                            Text("DIFFICULTÉ")
                                .font(.nohemi(.caption2, weight: .bold))
                                .foregroundStyle(Color.textSecondary)
                                .tracking(0.8)

                            VStack(spacing: BuzzSpacing.sm) {
                                ForEach(QuizDifficulty.allCases) { difficulty in
                                    DifficultyPillAI(
                                        difficulty: difficulty,
                                        isSelected: selectedDifficulty == difficulty,
                                        action: { selectedDifficulty = difficulty }
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, BuzzSpacing.xl)

                        // INFO / guide conditions
                        let themeCount = selectedThemeIDs.count
                        let infoText: String = {
                            if themeCount == 0 && selectedDifficulty == nil {
                                return "Sélectionne un thème et une difficulté pour générer"
                            } else if themeCount == 0 {
                                return "Sélectionne au moins un thème pour continuer"
                            } else if selectedDifficulty == nil {
                                return "Sélectionne une difficulté pour continuer"
                            } else {
                                return "\(quizRoundsTotal) questions · \(themeCount == 1 ? "1 thème" : "\(themeCount) thèmes mélangés")"
                            }
                        }()
                        let infoIsWarning = themeCount == 0 || selectedDifficulty == nil
                        HStack(spacing: BuzzSpacing.sm) {
                            Image(systemName: infoIsWarning ? "arrow.down.circle.fill" : "checkmark.circle.fill")
                                .foregroundStyle(infoIsWarning ? Color.purpleLeading.opacity(0.7) : Color.textMuted)
                            Text(infoText)
                                .font(.nohemi(.caption, weight: infoIsWarning ? .semiBold : .regular))
                                .foregroundStyle(infoIsWarning ? .white.opacity(0.8) : .white.opacity(0.6))
                        }
                        .padding(.horizontal, BuzzSpacing.md)
                        .padding(.vertical, 10)
                        .background(
                            infoIsWarning
                                ? Color.purpleLeading.opacity(0.06)
                                : Color.white.opacity(0.04),
                            in: RoundedRectangle(cornerRadius: BuzzRadius.sm2)
                        )
                        .padding(.horizontal, BuzzSpacing.xl)
                    }
                    .padding(.vertical, BuzzSpacing.xxl)
                }

                Divider().opacity(0.1)

                // Erreur
                if let error = generator.error {
                    HStack(spacing: BuzzSpacing.sm) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                        Text(error.localizedDescription)
                            .font(.nohemi(.caption, weight: .regular))
                            .foregroundStyle(.white.opacity(0.8))
                            .lineLimit(3)
                    }
                    .padding(.horizontal, BuzzSpacing.md)
                    .padding(.vertical, 10)
                    .background(Color.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: BuzzRadius.sm2))
                    .overlay(RoundedRectangle(cornerRadius: BuzzRadius.sm2).strokeBorder(Color.orange.opacity(0.3), lineWidth: 1))
                    .padding(.horizontal, BuzzSpacing.xl)
                    .padding(.bottom, BuzzSpacing.sm)
                }

                // CTA
                if isGenerating {
                    VStack(spacing: BuzzSpacing.sm) {
                        HStack(spacing: 10) {
                            ProgressView(value: generator.generationProgress, total: 1.0)
                                .tint(Color.purpleLeading)
                            Text("\(generator.generatedQuestions.count)/\(quizRoundsTotal)")
                                .font(.nohemi(.caption, weight: .semiBold))
                                .foregroundStyle(Color.textSoft)
                                .frame(width: 45, alignment: .trailing)
                        }
                        Text("Génération en cours...")
                            .font(.nohemi(.caption2, weight: .regular))
                            .foregroundStyle(Color.textSecondary)
                    }
                    .padding(.horizontal, BuzzSpacing.xl)
                    .padding(.vertical, BuzzSpacing.md)
                } else {
                    Button(action: generate) {
                        Text(generator.error != nil ? "Réessayer" : "✨ Générer")
                            .font(.nohemi(.body, weight: .bold))
                            .foregroundStyle(canGenerate ? .white : .white.opacity(0.30))
                    }
                    .disabled(!canGenerate)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        canGenerate
                            ? LinearGradient(colors: [Color.purpleLeading, Color.purpleTrailing], startPoint: .topLeading, endPoint: .bottomTrailing)
                            : LinearGradient(colors: [Color.white.opacity(0.08), Color.white.opacity(0.06)], startPoint: .topLeading, endPoint: .bottomTrailing),
                        in: RoundedRectangle(cornerRadius: BuzzRadius.md)
                    )
                    .padding(.horizontal, BuzzSpacing.xl)
                    .padding(.vertical, BuzzSpacing.md)
                }
            }
        }
        .onDisappear { generationTask?.cancel() }
    }

    // MARK: - Theme Group

    @ViewBuilder
    private func themeGroup(label: String, themes: [QuizTheme]) -> some View {
        VStack(alignment: .leading, spacing: BuzzSpacing.md) {
            Text(label.uppercased())
                .font(.nohemi(.caption2, weight: .bold))
                .foregroundStyle(Color.textSecondary)
                .tracking(0.8)
                .padding(.horizontal, BuzzSpacing.xl)

            LazyVGrid(
                columns: [.init(.flexible(), spacing: 10), .init(.flexible(), spacing: 10), .init(.flexible(), spacing: 10)],
                spacing: 10
            ) {
                ForEach(themes) { theme in
                    let isSelected = selectedThemeIDs.contains(theme.id)
                    ThemeCardAI(theme: theme, isSelected: isSelected) {
                        if isSelected {
                            selectedThemeIDs.remove(theme.id)
                        } else {
                            selectedThemeIDs.insert(theme.id)
                        }
                    }
                }
            }
            .padding(.horizontal, BuzzSpacing.lg)
        }
    }

    // MARK: - Generate

    @MainActor
    private func generate() {
        guard !selectedThemes.isEmpty, let difficulty = selectedDifficulty else { return }
        isGenerating = true

        generationTask = Task {
            await generator.generateInitialPass(
                themes: selectedThemes,
                difficulty: difficulty,
                count: quizRoundsTotal
            )
            isGenerating = false

            // Sheet fermée pendant la génération : on n'ouvre pas la review.
            guard !Task.isCancelled,
                  generator.error == nil, !generator.generatedQuestions.isEmpty else { return }

            let themeNames = selectedThemes.map(\.title).joined(separator: " + ")
            let representativeTheme = selectedThemes.first ?? QuizThemes.annees2000
            let customSet = QuizSet(
                title: selectedThemes.count == 1 ? selectedThemes[0].title : "Mix — \(themeNames)",
                theme: representativeTheme,
                questions: generator.generatedQuestions
            )
            onComplete(customSet)
        }
    }
}

// MARK: - Theme Card (multi-sélectionnable)

@available(iOS 26.0, *)
private struct ThemeCardAI: View {
    let theme: QuizTheme
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: BuzzSpacing.sm) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: theme.iconName)
                        .textStyle(Typography.sectionTitle)
                        .foregroundStyle(isSelected ? theme.color : Color.textDim)
                        .frame(width: 44, height: 44)
                        .background(
                            isSelected ? theme.color.opacity(0.2) : Color.white.opacity(0.05),
                            in: RoundedRectangle(cornerRadius: BuzzRadius.sm)
                        )

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .textStyle(Typography.footnoteBold)
                            .foregroundStyle(theme.color)
                            .background(Color.sheetBg, in: Circle())
                            .offset(x: 6, y: -6)
                    }
                }

                Text(theme.title)
                    .font(.nohemi(.caption2, weight: .semiBold))
                    .foregroundStyle(isSelected ? .white : Color.textSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, BuzzSpacing.md)
            .padding(.horizontal, 4)
            .background(
                isSelected ? theme.color.opacity(0.12) : Color.white.opacity(0.03),
                in: RoundedRectangle(cornerRadius: BuzzRadius.md)
            )
            .overlay(
                RoundedRectangle(cornerRadius: BuzzRadius.md)
                    .strokeBorder(
                        isSelected ? theme.color.opacity(0.5) : Color.white.opacity(0.07),
                        lineWidth: isSelected ? 1.5 : 1
                    )
            )
            .animation(.buzzSnappy, value: isSelected)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Difficulty Pill

@available(iOS 26.0, *)
private struct DifficultyPillAI: View {
    let difficulty: QuizDifficulty
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: BuzzSpacing.sm) {
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
            .padding(.vertical, BuzzSpacing.md)
            .frame(maxWidth: .infinity)
            .background(
                isSelected ? difficulty.color.opacity(0.15) : Color.white.opacity(0.04),
                in: RoundedRectangle(cornerRadius: BuzzRadius.sm)
            )
            .overlay(
                RoundedRectangle(cornerRadius: BuzzRadius.sm)
                    .strokeBorder(
                        isSelected ? difficulty.color.opacity(0.4) : Color.white.opacity(0.08),
                        lineWidth: isSelected ? 1.5 : 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

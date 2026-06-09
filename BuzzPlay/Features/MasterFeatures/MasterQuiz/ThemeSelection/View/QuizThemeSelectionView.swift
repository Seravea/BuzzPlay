//
//  QuizThemeSelectionView.swift
//  BuzzPlay
//

import SwiftUI

#if os(iOS) && swift(>=5.9)
import FoundationModels
#endif

struct QuizThemeSelectionView: View {
    @Bindable var viewModel: QuizThemeSelectionViewModel
    @EnvironmentObject private var router: Router

    @State private var showAIGeneratorSheet = false
    @State private var showAIReviewSheet = false
    @State private var aiGeneratedSet: QuizSet?
    @State private var aiGenerator = AIQuizGenerator()

    // Alertes affichées quand l'appareil est éligible mais Apple Intelligence indisponible.
    @State private var showEnableAIAlert = false
    @State private var showModelNotReadyAlert = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                header
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)

                ForEach(viewModel.groupedThemes, id: \.label) { group in
                    groupSection(label: group.label, themes: group.themes)
                        .padding(.bottom, 28)
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        .foregroundStyle(.white)
        .background(BackgroundAppView())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Quiz")
                    .font(.nohemi(.body, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .sheet(isPresented: $showAIGeneratorSheet) {
            if #available(iOS 26.0, *) {
                #if os(iOS) && swift(>=5.9)
                AIQuizSetupView(
                    generator: aiGenerator,
                    quizRoundsTotal: viewModel.quizRoundsTotal,
                    onComplete: { set in
                        aiGeneratedSet = set
                        showAIGeneratorSheet = false
                        showAIReviewSheet = true
                    },
                    onDismiss: { showAIGeneratorSheet = false }
                )
                .presentationBackground(Color(hex: "#1A0535"))
                #else
                EmptyView()
                #endif
            } else {
                EmptyView()
            }
        }
        .sheet(isPresented: $showAIReviewSheet) {
            if #available(iOS 26.0, *) {
                #if os(iOS) && swift(>=5.9)
                AIQuizReviewView(
                    generator: aiGenerator,
                    quizSet: aiGeneratedSet ?? QuizSet(id: UUID(), title: "", theme: QuizThemes.annees2000, questions: []),
                    targetCount: viewModel.quizRoundsTotal,
                    onLaunch: { set in
                        showAIReviewSheet = false
                        viewModel.selectSet(set)
                        router.push(.quizMaster)
                    },
                    onBack: { showAIReviewSheet = false }
                )
                .presentationBackground(Color(hex: "#1A0535"))
                #else
                EmptyView()
                #endif
            } else {
                EmptyView()
            }
        }
        .alert("Activer Apple Intelligence", isPresented: $showEnableAIAlert) {
            Button("Ouvrir les Réglages") { openAppSettings() }
            Button("Plus tard", role: .cancel) {}
        } message: {
            Text("La génération de quiz par IA nécessite Apple Intelligence. Active-le dans Réglages › Apple Intelligence et Siri, puis reviens ici.")
        }
        .alert("Apple Intelligence se prépare", isPresented: $showModelNotReadyAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Le modèle d'Apple Intelligence est en cours de téléchargement. Réessaie dans quelques minutes.")
        }
    }

    /// Ouvre la page Réglages de l'app (point d'entrée le plus direct vers Apple Intelligence).
    private func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Choisir un quiz")
                    .font(.nohemi(.title, weight: .extraBold))
                    .foregroundStyle(.white)
                Text("Sélectionne le thème et la playlist")
                    .font(.nohemi(.subheadline, weight: .regular))
                    .foregroundStyle(.white.opacity(0.5))
            }

            Spacer()

            aiGenerateButton
        }
    }

    /// Bouton « Générer » selon l'état réel d'Apple Intelligence :
    /// - disponible → actif, ouvre le générateur
    /// - activé mais modèle pas prêt → grisé, message de patience
    /// - Apple Intelligence désactivé → grisé, invite à l'activer dans les Réglages
    /// - appareil non éligible (ou iOS < 26) → rien
    @ViewBuilder
    private var aiGenerateButton: some View {
        if #available(iOS 26.0, *) {
            #if os(iOS) && swift(>=5.9)
            switch SystemLanguageModel.default.availability {
            case .available:
                generateButtonLabel(enabled: true) { showAIGeneratorSheet = true }
            case .unavailable(.appleIntelligenceNotEnabled):
                generateButtonLabel(enabled: false) { showEnableAIAlert = true }
            case .unavailable(.modelNotReady):
                generateButtonLabel(enabled: false) { showModelNotReadyAlert = true }
            case .unavailable:
                EmptyView()
            }
            #endif
        }
    }

    @ViewBuilder
    private func generateButtonLabel(enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .font(.system(size: 13, weight: .semibold))
                Text("Générer")
                    .font(.nohemi(.caption, weight: .bold))
            }
            .foregroundStyle(enabled ? .white : .white.opacity(0.40))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(hex: "#AD46FF").opacity(enabled ? 0.2 : 0.08), in: RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(Color(hex: "#AD46FF").opacity(enabled ? 0.3 : 0.12), lineWidth: 1)
            )
        }
    }

    // MARK: - Group Section

    @ViewBuilder
    private func groupSection(label: String, themes: [QuizTheme]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Eyebrow label
            Text(label.uppercased())
                .font(.nohemi(.caption2, weight: .bold))
                .tracking(0.8)
                .foregroundStyle(.white.opacity(0.40))
                .padding(.horizontal, 20)

            VStack(spacing: 28) {
                ForEach(themes) { theme in
                    let sets = viewModel.sets(for: theme)
                    if sets.isEmpty {
                        ThemeAIOnlyCard(theme: theme, onTap: { showAIGeneratorSheet = true })
                            .padding(.horizontal, 16)
                    } else {
                        ThemeSection(theme: theme, sets: sets) { set in
                            viewModel.selectSet(set)
                            router.push(.quizMaster)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Theme Section (avec sets curatés)

private struct ThemeSection: View {
    let theme: QuizTheme
    let sets: [QuizSet]
    let onSelect: (QuizSet) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: theme.iconName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(theme.color)
                    .frame(width: 38, height: 38)
                    .background(theme.color.opacity(0.18), in: RoundedRectangle(cornerRadius: 10))
                    .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(theme.color.opacity(0.35), lineWidth: 1))

                Text(theme.title)
                    .font(.nohemi(.title3, weight: .bold))
                    .foregroundStyle(.white)

                Spacer()

                Text("\(sets.count) quiz")
                    .font(.nohemi(.caption, weight: .semiBold))
                    .foregroundStyle(.white.opacity(0.4))
            }
            .padding(.horizontal, 20)

            VStack(spacing: 8) {
                ForEach(sets) { set in
                    QuizSetCard(set: set, themeColor: theme.color) {
                        onSelect(set)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Theme AI-Only Card (sans set curatés)

private struct ThemeAIOnlyCard: View {
    let theme: QuizTheme
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: theme.iconName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(theme.color)
                    .frame(width: 36, height: 36)
                    .background(theme.color.opacity(0.14), in: RoundedRectangle(cornerRadius: 10))
                    .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(theme.color.opacity(0.25), lineWidth: 1))

                VStack(alignment: .leading, spacing: 2) {
                    Text(theme.title)
                        .font(.nohemi(.subheadline, weight: .bold))
                        .foregroundStyle(.white)
                    Text("Générer avec l'IA ✦")
                        .font(.nohemi(.caption, weight: .medium))
                        .foregroundStyle(Color(hex: "#AD46FF").opacity(0.8))
                }

                Spacer()

                Image(systemName: "sparkles")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color(hex: "#AD46FF"))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(Color(hex: "#AD46FF").opacity(0.20), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Quiz Set Card

private struct QuizSetCard: View {
    let set: QuizSet
    let themeColor: Color
    let action: () -> Void

    private var difficultyRange: String {
        let diffs = set.questions.compactMap(\.difficulty)
        guard !diffs.isEmpty else { return "" }
        let difficultyOrder: [QuizDifficulty] = [.expert, .difficile, .moyen, .facile]
        if let highest = diffs.first(where: { difficultyOrder.contains($0) }) {
            return highest.label
        }
        return diffs.first?.label ?? ""
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(themeColor)
                    .frame(width: 4)
                    .padding(.vertical, 4)

                VStack(alignment: .leading, spacing: 4) {
                    Text(set.title)
                        .font(.nohemi(.body, weight: .semiBold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.leading)

                    HStack(spacing: 8) {
                        Label("\(set.questions.count) questions", systemImage: "list.bullet")
                            .font(.nohemi(.caption, weight: .medium))
                            .foregroundStyle(.white.opacity(0.45))

                        if !difficultyRange.isEmpty {
                            Text("·")
                                .foregroundStyle(.white.opacity(0.3))
                            Text(difficultyRange)
                                .font(.nohemi(.caption, weight: .medium))
                                .foregroundStyle(.white.opacity(0.45))
                        }
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.25))
            }
            .padding(.vertical, 14)
            .padding(.trailing, 14)
            .padding(.leading, 12)
            .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(.white.opacity(0.08), lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        QuizThemeSelectionView(viewModel: QuizThemeSelectionViewModel(gameVM: MasterFlowViewModel()))
            .environmentObject(Router())
    }
}

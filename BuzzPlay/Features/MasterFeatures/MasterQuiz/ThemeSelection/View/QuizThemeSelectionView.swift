//
//  QuizThemeSelectionView.swift
//  BuzzPlay
//

import SwiftUI

struct QuizThemeSelectionView: View {
    @Bindable var viewModel: QuizThemeSelectionViewModel
    @EnvironmentObject private var router: Router

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                header
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)

                ForEach(viewModel.themes) { theme in
                    ThemeSection(
                        theme: theme,
                        sets: viewModel.sets(for: theme)
                    ) { set in
                        viewModel.selectSet(set)
                        router.push(.quizMaster)
                    }
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
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Choisir un quiz")
                .font(.nohemi(.title, weight: .extraBold))
                .foregroundStyle(.white)
            Text("Sélectionne le thème et la playlist")
                .font(.nohemi(.subheadline, weight: .regular))
                .foregroundStyle(.white.opacity(0.5))
        }
    }
}

// MARK: - Theme Section

private struct ThemeSection: View {
    let theme: QuizTheme
    let sets: [QuizSet]
    let onSelect: (QuizSet) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Theme header
            HStack(spacing: 10) {
                Text(theme.emoji)
                    .font(.system(size: 20))
                    .frame(width: 38, height: 38)
                    .background(theme.color.opacity(0.2), in: RoundedRectangle(cornerRadius: 10))
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

            // Quiz cards
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

// MARK: - Quiz Set Card

private struct QuizSetCard: View {
    let set: QuizSet
    let themeColor: Color
    let action: () -> Void

    private var difficultyRange: String {
        let diffs = set.questions.compactMap(\.difficulty)
        guard !diffs.isEmpty else { return "" }
        let avg = diffs.reduce(0, +) / diffs.count
        switch avg {
        case 1:  return "Facile"
        case 2:  return "Moyen"
        default: return "Difficile"
        }
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                // Left accent stripe
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

//
//  QuizThemeSelectionView.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 15/04/2026.
//

import SwiftUI

struct QuizThemeSelectionView: View {
    @Bindable var viewModel: QuizThemeSelectionViewModel
    @EnvironmentObject private var router: Router

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                ForEach(viewModel.themes) { theme in
                    VStack(alignment: .leading, spacing: 12) {
                        // En-tête du thème
                        HStack(spacing: 8) {
                            Text(theme.emoji)
                                .font(.title2)
                            Text(theme.title)
                                .font(.nohemi(.title2, weight: .bold))
                        }

                        // Liste des quiz disponibles dans ce thème
                        ForEach(viewModel.sets(for: theme)) { quizSet in
                            Button {
                                viewModel.selectSet(quizSet)
                                router.push(.quizMaster)
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(quizSet.title)
                                            .font(.nohemi(.body, weight: .medium))
                                        Text("\(quizSet.questions.count) questions")
                                            .font(.caption)
                                            .opacity(0.7)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .opacity(0.5)
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(theme.color.opacity(0.2))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(theme.color.opacity(0.4), lineWidth: 1)
                                        )
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding()
        }
        .foregroundStyle(.white)
        .background(BackgroundAppView())
        .navigationTitle("Choisir un quiz")
    }
}

#Preview {
    NavigationStack {
        QuizThemeSelectionView(viewModel: QuizThemeSelectionViewModel(gameVM: MasterFlowViewModel()))
            .environmentObject(Router())
    }
}

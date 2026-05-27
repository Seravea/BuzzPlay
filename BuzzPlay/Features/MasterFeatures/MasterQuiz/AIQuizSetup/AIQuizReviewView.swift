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
    let onLaunch: (QuizSet) -> Void
    let onBack: () -> Void

    // Source de vérité : le generator, pas le quizSet (évite les problèmes de timing de sheet)
    private var questions: [QuizQuestion] {
        generator.generatedQuestions.isEmpty ? quizSet.questions : generator.generatedQuestions
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

                // Questions list
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(questions) { question in
                            QuestionCardAI(question: question)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
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
                                questions.count >= 3
                                    ? LinearGradient(colors: [Color(hex: "#AD46FF"), Color(hex: "#F6339A")], startPoint: .topLeading, endPoint: .bottomTrailing)
                                    : LinearGradient(colors: [Color.white.opacity(0.08), Color.white.opacity(0.06)], startPoint: .topLeading, endPoint: .bottomTrailing),
                                in: RoundedRectangle(cornerRadius: 12)
                            )
                    }
                    .disabled(questions.count < 3)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
    }
}

@available(iOS 26.0, *)
private struct QuestionCardAI: View {
    let question: QuizQuestion

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

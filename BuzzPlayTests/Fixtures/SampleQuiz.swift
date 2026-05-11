import Foundation
import SwiftUI
@testable import BuzzPlay

enum SampleQuiz {
    static let theme = QuizTheme(title: "Test", emoji: "🎯", color: .purple)

    static let q1 = QuizQuestion(
        title: "Quelle est la capitale de la France ?",
        answers: ["Paris", "Lyon", "Bordeaux", "Nice"],
        theme: "Géographie",
        difficulty: 1,
        tone: nil
    )

    static let q2 = QuizQuestion(
        title: "Combien font 2 + 2 ?",
        answers: ["4", "3", "5", "22"],
        theme: "Maths",
        difficulty: 1,
        tone: nil
    )

    static let quizSet = QuizSet(
        title: "Quiz de test",
        theme: theme,
        questions: [q1, q2]
    )
}

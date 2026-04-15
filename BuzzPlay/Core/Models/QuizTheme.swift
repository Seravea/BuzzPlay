//
//  QuizTheme.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 15/04/2026.
//

import Foundation
import SwiftUI

/// Une catégorie (ou "univers") pour les quiz.
/// Un `QuizTheme` peut regrouper plusieurs `QuizSet`.
struct QuizTheme: Identifiable, Hashable {
    let id: UUID
    let title: String
    let emoji: String
    let color: Color

    init(id: UUID = UUID(), title: String, emoji: String, color: Color) {
        self.id = id
        self.title = title
        self.emoji = emoji
        self.color = color
    }
}

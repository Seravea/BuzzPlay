//
//  QuizTheme.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 15/04/2026.
//

import Foundation
import SwiftUI

enum QuizThemeCategory {
    case era
    case genre
}

/// Une catégorie (ou "univers") pour les quiz.
/// Un `QuizTheme` peut regrouper plusieurs `QuizSet`.
struct QuizTheme: Identifiable, Hashable {
    let id: UUID
    let title: String
    let iconName: String       // SF Symbol
    let color: Color
    let category: QuizThemeCategory

    init(id: UUID = UUID(), title: String, iconName: String, color: Color,
         category: QuizThemeCategory = .genre) {
        self.id = id
        self.title = title
        self.iconName = iconName
        self.color = color
        self.category = category
    }
}

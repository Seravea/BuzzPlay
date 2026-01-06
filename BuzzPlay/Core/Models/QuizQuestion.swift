//
//  QuizQuestion.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 18/11/2025.
//

import Foundation


struct QuizQuestion: Identifiable, Codable, Hashable {
    var id = UUID()
    let title: String
    var answers: [String]
    let theme: String?
    let difficulty: Int?
    let tone: String?
}



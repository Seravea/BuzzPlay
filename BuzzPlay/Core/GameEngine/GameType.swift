//
//  GameType.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 14/11/2025.
//

import Foundation



enum GameType: String, CaseIterable, Codable {
    case blindTest
    case quiz
    case karaoke
    
    var destination: Route {
        switch self {
        case .blindTest:
            return .blindTestMaster
        case .quiz:
            return .quizMaster
        case .karaoke:
            return .karaoke
        }
    }
    
    var gameTitle: String {
        switch self {
        case .blindTest:
            return "Blind Test"
        case .quiz:
            return "Quiz"
        case .karaoke:
            return "Karaoke"
        }
    }
}

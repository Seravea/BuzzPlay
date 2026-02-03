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
    case score
    
    var destinationMaster: Route {
        switch self {
        case .blindTest:
            return .blindTestMaster
        case .quiz:
            return .quizMaster
        case .score:
            return .scoreMaster
        }
    }
    
    var gameTitle: String {
        switch self {
        case .blindTest:
            return "Blind Test"
        case .quiz:
            return "Quiz"
        case .score:
            return "Score"
        }
    }
    
    var destinationPlayer: Route {
        switch self {
        case .blindTest:
            return .blindTestPlayer
        case .quiz:
            return .quizPlayer
        case .score:
            return .scorePlayer
        }
    }
    
    var iconName: String {
        switch self {
        case .blindTest:
            return "music.note.list"
        case .quiz:
            return "brain"
        case .score:
            return "list.clipboard"
        }
    }
}

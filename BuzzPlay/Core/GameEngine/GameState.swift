//
//  GameState.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 10/11/2025.
//

import Foundation


enum GameState {
    case lobby
    case inGame
    case gameOver
}



enum Game: String, CaseIterable, Codable {
    case blindTest
    case quiz
    case karaoke
}

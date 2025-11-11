//
//  GameSession.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 11/11/2025.
//

import Foundation
import SwiftUI



struct GameSession: Codable, Equatable, Sendable {
    var id: UUID = UUID()
    var teams: [Team] = []
    var createdAt: Date = Date.now
    var currentRoundIndex: Int = 0

    
}

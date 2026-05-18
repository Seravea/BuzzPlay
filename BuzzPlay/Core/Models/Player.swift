//
//  Player.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 11/11/2025.
//

import Foundation
import SwiftUI
import MultipeerConnectivity


struct Player: Identifiable, Hashable, Codable, Equatable {
    var id = UUID()
    var name: String
    var image: String?
    var teamColor: GameColor = .purpleGame
    var score: Int = 0
    var accountAmount: Int = 0
    var customBuzzColor: GameColor? = nil
    var customBuzzSound: String? = nil
    var hasScoreDoubled: Bool = false
    var blockedFromBuzzing: Bool = false
}

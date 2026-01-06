//
//  Team.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 11/11/2025.
//

import Foundation
import SwiftUI
import MultipeerConnectivity


struct Team: Identifiable, Hashable, Codable, Equatable {
    var id = UUID()
    var name: String
    var image: String?
    var teamColor: GameColor = .purpleGame
    var players: [Player] = []
    var score: Int = 0
    var accountAmount: Int = 0
}

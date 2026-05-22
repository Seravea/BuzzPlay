//
//  GameColor.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 17/11/2025.
//

import Foundation
import SwiftUI


enum GameColor: String, CaseIterable, Codable, Hashable {
    case redGame, greenGame, blueGame, yellowGame, purpleGame
}

extension GameColor {
    var color: Color {
        switch self {
        case .redGame:    return Color(hex: "#FB2C36")
        case .greenGame:  return Color(hex: "#00C950")
        case .blueGame:   return Color(hex: "#2B7FFF")
        case .yellowGame: return Color(hex: "#FEC260")
        case .purpleGame: return Color(hex: "#AD46FF")
        }
    }

    var gradient: LinearGradient {
        switch self {
        case .redGame:    return LinearGradient(colors: [Color(hex: "#FB2C36"), Color(hex: "#F6339A")], startPoint: .leading, endPoint: .trailing)
        case .greenGame:  return LinearGradient(colors: [Color(hex: "#00C950"), Color(hex: "#009966")], startPoint: .leading, endPoint: .trailing)
        case .blueGame:   return LinearGradient(colors: [Color(hex: "#2B7FFF"), Color(hex: "#00B8DB")], startPoint: .leading, endPoint: .trailing)
        case .yellowGame: return LinearGradient(colors: [Color(hex: "#F0B100"), Color(hex: "#FF6900")], startPoint: .leading, endPoint: .trailing)
        case .purpleGame: return LinearGradient(colors: [Color(hex: "#AD46FF"), Color(hex: "#F6339A")], startPoint: .leading, endPoint: .trailing)
        }
    }
}

let buzzSoundNames = ["BeginQuestion", "Blblbl", "GoodAnswer", "HeavenlyChoir", "Mosquito", "PositiveAnswer", "Tired", "WrongAnswer"]

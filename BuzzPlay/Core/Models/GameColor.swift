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
        // Rouge → Orange vif (évite collision avec feedback "mauvaise réponse" #FF4D4D)
        case .redGame:    return Color(hex: "#FF6900")
        // Vert → Rose néon (évite collision avec feedback "bonne réponse" #00C875)
        case .greenGame:  return Color(hex: "#FF2D78")
        case .blueGame:   return Color(hex: "#2B7FFF")
        case .yellowGame: return Color(hex: "#FEC260")
        case .purpleGame: return Color(hex: "#AD46FF")
        }
    }

    var gradient: LinearGradient {
        switch self {
        case .redGame:    return LinearGradient(colors: [Color(hex: "#FF6900"), Color(hex: "#FF2D78")], startPoint: .leading, endPoint: .trailing)
        case .greenGame:  return LinearGradient(colors: [Color(hex: "#FF2D78"), Color(hex: "#AD46FF")], startPoint: .leading, endPoint: .trailing)
        case .blueGame:   return LinearGradient(colors: [Color(hex: "#2B7FFF"), Color(hex: "#00B8DB")], startPoint: .leading, endPoint: .trailing)
        case .yellowGame: return LinearGradient(colors: [Color(hex: "#F0B100"), Color(hex: "#FF6900")], startPoint: .leading, endPoint: .trailing)
        case .purpleGame: return LinearGradient(colors: [Color(hex: "#AD46FF"), Color(hex: "#F6339A")], startPoint: .leading, endPoint: .trailing)
        }
    }
}

let buzzSoundNames = ["BeginQuestion", "Blblbl", "GoodAnswer", "HeavenlyChoir", "Mosquito", "PositiveAnswer", "Tired", "WrongAnswer"]

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
        case .redGame:    return Color.yellowTrailing
        // Vert → Rose néon (évite collision avec feedback "bonne réponse" #00C875)
        case .greenGame:  return Color.buzzHotPink
        case .blueGame:   return Color.blueLeading
        case .yellowGame: return Color.mustardYellow
        case .purpleGame: return Color.purpleLeading
        }
    }

    var gradient: LinearGradient {
        switch self {
        case .redGame:    return .gradientRedPlayer
        case .greenGame:  return .gradientGreenPlayer
        case .blueGame:   return .gradientBluePlayer
        case .yellowGame: return .gradientYellowPlayer
        case .purpleGame: return .gradientPurplePlayer
        }
    }
}

let buzzSoundNames = ["BeginQuestion", "Blblbl", "GoodAnswer", "HeavenlyChoir", "Mosquito", "PositiveAnswer", "Tired", "WrongAnswer"]

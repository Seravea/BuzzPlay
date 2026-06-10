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

/// Libellés FR des sons de buzzer, indexés par nom de fichier.
/// Source unique partagée par le SoundPickerSheet (boutique) et le salon d'attente.
let buzzSoundLabels: [String: String] = [
    "BeginQuestion": "Début de question",
    "Blblbl": "Blblbl",
    "GoodAnswer": "Bonne réponse",
    "HeavenlyChoir": "Chœur céleste",
    "Mosquito": "Moustique",
    "PositiveAnswer": "Réponse positive",
    "Tired": "Fatigué",
    "WrongAnswer": "Mauvaise réponse",
]

/// Libellé FR lisible d'un son de buzzer (fallback = le nom brut).
func buzzSoundLabel(for soundName: String) -> String {
    buzzSoundLabels[soundName] ?? soundName
}

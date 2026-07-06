//
//  BlindTestHints.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 18/05/2026.
//

import Foundation

struct BlindTestHints {
    static let phrases = [
        "Tu connais ce son ?",
        "Reconnais cette mélodie ?",
        "À toi de trouver !",
        "Quelle est cette chanson ?",
        "Ça te dit quelque chose ?",
        "Tu peux la trouver ?"
    ]

    static func randomHint() -> String {
        phrases.randomElement() ?? "Tu connais ce son ?"
    }
}

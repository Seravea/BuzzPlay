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
    var hasShieldSingle: Bool = false
    var hasShieldAll: Bool = false

}

// Décodage tolérant : dans une extension pour préserver le memberwise init synthétisé par Swift.
// Évite les crashes quand un ancien Player encodé ne contient pas les nouveaux champs.
extension Player {
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id                 = try c.decode(UUID.self,     forKey: .id)
        name               = try c.decode(String.self,   forKey: .name)
        image              = try c.decodeIfPresent(String.self,    forKey: .image)
        teamColor          = try c.decodeIfPresent(GameColor.self,  forKey: .teamColor)         ?? .purpleGame
        score              = try c.decodeIfPresent(Int.self,        forKey: .score)              ?? 0
        accountAmount      = try c.decodeIfPresent(Int.self,        forKey: .accountAmount)      ?? 0
        customBuzzColor    = try c.decodeIfPresent(GameColor.self,  forKey: .customBuzzColor)
        customBuzzSound    = try c.decodeIfPresent(String.self,     forKey: .customBuzzSound)
        hasScoreDoubled    = try c.decodeIfPresent(Bool.self,       forKey: .hasScoreDoubled)    ?? false
        blockedFromBuzzing = try c.decodeIfPresent(Bool.self,       forKey: .blockedFromBuzzing) ?? false
        hasShieldSingle    = try c.decodeIfPresent(Bool.self,       forKey: .hasShieldSingle)    ?? false
        hasShieldAll       = try c.decodeIfPresent(Bool.self,       forKey: .hasShieldAll)       ?? false
    }
}

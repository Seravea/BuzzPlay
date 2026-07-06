//
//  Gift+Presentation.swift
//  BuzzPlay
//

import SwiftUI

// MARK: - État actif sur le Player

extension CoinsViewModel.Gift {
    func isActiveOnPlayer(_ player: Player?) -> Bool {
        guard let player else { return false }
        switch self {
        case .scoreDoubled:         return player.hasScoreDoubled
        case .shieldSingle:         return player.hasShieldSingle
        case .shieldAll:            return player.hasShieldAll
        // #rebuy-cosmetics — couleur/son du buzzer = achats COSMÉTIQUES RÉPÉTABLES :
        // ne jamais marquer « Actif » ni bloquer (avant : customX != nil → 1 seul achat
        // possible → on ne pouvait plus changer de son/couleur). On les rachète à volonté.
        case .changeBuzzColor:      return false
        case .changeBuzzSound:      return false
        case .enemyCanNotBuzz, .allEnemiesCanNotBuzz, .showIndicies:
            return false  // effets ponctuels, pas de state persistant côté acheteur
        }
    }
}

// MARK: - Propriétés visuelles des Gifts (SwiftUI)

extension CoinsViewModel.Gift {
    var iconName: String {
        switch self {
        case .scoreDoubled:         return "2.circle.fill"
        case .enemyCanNotBuzz:      return "hand.raised.slash.fill"
        case .allEnemiesCanNotBuzz: return "person.2.slash.fill"
        case .showIndicies:         return "lightbulb.fill"
        case .changeBuzzColor:      return "paintbrush.fill"
        case .changeBuzzSound:      return "waveform"
        case .shieldSingle:         return "shield.fill"
        case .shieldAll:            return "shield.lefthalf.filled"
        }
    }

    var shortTitle: String {
        switch self {
        case .scoreDoubled:         return "Score ×2"
        case .enemyCanNotBuzz:      return "Bloquer\nun ennemi"
        case .allEnemiesCanNotBuzz: return "Bloquer\ntout le monde"
        case .showIndicies:         return "Voir\nun indice"
        case .changeBuzzColor:      return "Changer\nla couleur"
        case .changeBuzzSound:      return "Changer\nle son"
        case .shieldSingle:         return "Bouclier\n1 ennemi"
        case .shieldAll:            return "Bouclier\ntout le monde"
        }
    }

    var accentColor: Color {
        switch self {
        case .scoreDoubled:         return Color.greenButtonLeading
        case .enemyCanNotBuzz:      return Color.redSoft
        case .allEnemiesCanNotBuzz: return Color.peach
        case .showIndicies:         return Color.yellowLeading
        case .changeBuzzColor:      return Color.purpleLeading
        case .changeBuzzSound:      return Color.skyBlue
        case .shieldSingle:         return Color.blueLeading
        case .shieldAll:            return Color.blueTrailing
        }
    }
}

//
//  RoleColors.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 20/01/2026.
//

import Foundation
import SwiftUI

enum RoleButtonUI: CaseIterable {
    case teams, master, displayPublic
    
    var linearGradient: LinearGradient {
        switch self {
        case .teams:
            return LinearGradient(colors: [Color(hex: "AD46FF"), Color(hex: "F6339A")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .master:
            return LinearGradient(colors: [Color(hex: "2B7FFF"), Color(hex: "00B8DB")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .displayPublic:
            return LinearGradient(colors: [Color(hex: "FF6900"), Color(hex: "FB2C36")], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
    
    var displayNameText: String {
        switch self {
        case .teams:
            return "Joueur"
        case .master:
            return "Maître du jeu "
        case .displayPublic:
            return "Affichage Public"
        }
    }
    
    var iconName: String {
        switch self {
        case .teams:
            return "person.3"
        case .master:
            return "music.note.list"
        case .displayPublic:
            return "inset.filled.rectangle.and.person.filled"
        }
    }
    
    var displayDescText: String {
        switch self {
        case .teams:
            return "Créez votre équipe et buzzez"
        case .master:
            return "Contrôlez et animez les parties"
        case .displayPublic:
            return "Écran spectaculaire pour le public"
        }
    }
    
    var destination: Route {
        switch self {
        case .teams:
            return .createTeamView
        case .master:
            return .masterLobbyView
        case .displayPublic:
            return .createPublicDisplayTeam
        }
    }
}



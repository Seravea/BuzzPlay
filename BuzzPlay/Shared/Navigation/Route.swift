//
//  Route.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 11/11/2025.
//

import Foundation


enum Route: Hashable, Codable {
    case homeView
    case masterLobbyView
    case createTeamView
    case masterChooseGameView
    case playerChooseGameView
    case blindTestMaster
    case blindTestPlayer
    case quizThemeSelection
    case quizMaster
    case quizPlayer
    case scoreMaster
    case scorePlayer
    case playerGameView
    case masterShop   // #v1-packs A4 — boutique de packs (poussée depuis le hub Master)
}

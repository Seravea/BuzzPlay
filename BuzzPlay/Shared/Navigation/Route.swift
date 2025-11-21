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
    case quizMaster
    case quizPlayer
    case karaoke
    case publicDisplayScreen
}

//
//  Route.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 11/11/2025.
//

import Foundation


enum Route: Hashable, Codable {
    case home
    case quiz(id: UUID)
    case player(teamID: String)
    case settings
}

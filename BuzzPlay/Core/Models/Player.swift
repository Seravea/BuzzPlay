//
//  Player.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 11/11/2025.
//

import Foundation
import SwiftUI


struct Player: Identifiable, Hashable, Codable, Equatable {
    
    var id = UUID()
    var name: String
    var image: String?
}

//
//  PublicState.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 20/11/2025.
//

import Foundation


enum PublicState: Codable {
    case waiting
    case quiz(PublicQuizState)
}

//
//  BlindTestPublicPayload.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 06/01/2026.
//

import Foundation

struct PublicBlindTestState: Codable, Equatable {
    let title: String?
    let artist: String?
    let postertURLString: String?
    let releaseYear: String?
    let formattedTime: String
    let buzzingPlayer: Player?
    let isAnswerRevealed: Bool
    let isPlaying: Bool
}

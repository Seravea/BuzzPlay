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
    let hintIndex: Int  // Random hint selected for this round
    let countdownPhase: RoundCountdownPhase  // Countdown sync Master → Players
    /// true uniquement sur la dernière manche de la partie : le Player saute le classement
    /// inter-manche car le podium final enchaîne directement (#11/#C8).
    let isLastRound: Bool

    init(title: String?, artist: String?, postertURLString: String?, releaseYear: String?,
         formattedTime: String, buzzingPlayer: Player?, isAnswerRevealed: Bool, isPlaying: Bool,
         hintIndex: Int, countdownPhase: RoundCountdownPhase, isLastRound: Bool = false) {
        self.title = title
        self.artist = artist
        self.postertURLString = postertURLString
        self.releaseYear = releaseYear
        self.formattedTime = formattedTime
        self.buzzingPlayer = buzzingPlayer
        self.isAnswerRevealed = isAnswerRevealed
        self.isPlaying = isPlaying
        self.hintIndex = hintIndex
        self.countdownPhase = countdownPhase
        self.isLastRound = isLastRound
    }
}

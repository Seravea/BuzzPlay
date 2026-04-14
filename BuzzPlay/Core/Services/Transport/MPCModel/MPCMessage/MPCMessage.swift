//
//  MPCMessage.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 19/11/2025.
//

import Foundation

enum MPCMessage: Codable {
    // TEAM -> MASTER
    case teamJoin(Team)
    case buzz(BuzzPayload)
    case buyGiftRequest(CoinsViewModel.Gift)

    // MASTER -> TEAM
    case gameAvailability([GameType])
    case buyGiftResult(CoinsViewModel.Gift)
    case updatedTeam(Team)

    case buzzLock(BuzzLockPayload)
    case buzzUnlock

    //TEST
    case pong
}

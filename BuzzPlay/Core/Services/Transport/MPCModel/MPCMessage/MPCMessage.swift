//
//  MPCMessage.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 19/11/2025.
//

import Foundation

//TODO: message to send or receive from master / to player // from player / to master
//using it in MPCService and MAster/Player-FlowVM // refactor and scalable code
enum MPCMessage: Codable {
    // TEAM -> MASTER
    case teamJoin(Team)
    case buzz(BuzzPayload)
    case buyGiftRequest(CoinsViewModel.Gift)

    // MASTER -> TEAM
    case gameAvailability([GameType])
    case buyGiftResult(CoinsViewModel.Gift)
    case updatedTeam(Team)
    

    case buzzLock(BuzzLockPayload)   // master dit "X a gagné, buzzer lock"
    case buzzUnlock                  // master dit "nouvelle manche, vous pouvez rebuzzer"
    
    //Master -> PublicDisplay / Team
    case publicUpdate(PublicState)
    case publicDisplayMode(isActive: Bool)

    //TEST
    case pong
}

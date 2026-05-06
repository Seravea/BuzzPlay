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
    // PLAYER -> MASTER
    case playerJoin(Player)
    case buzz(BuzzPayload)
    case buyGiftRequest(CoinsViewModel.Gift)

    // MASTER -> PLAYER
    case gameAvailability([GameType])
    case buyGiftResult(CoinsViewModel.Gift)
    case updatedPlayer(Player)
    

    case buzzLock(BuzzLockPayload)   // master dit "X a gagné, buzzer lock"
    case buzzUnlock                  // master dit "nouvelle manche, vous pouvez rebuzzer"
    
    //Master -> Team : état courant du jeu (affiché côté Team)
    case publicUpdate(PublicState)

    // Master -> Team : le Master lance une partie (invite les joueurs à rejoindre)
    case masterLaunchedGame(GameType)

    //TEST
    case pong
}

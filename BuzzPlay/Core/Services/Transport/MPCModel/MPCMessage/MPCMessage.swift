//
//  MPCMessage.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 19/11/2025.
//

import Foundation

//TODO: message to send or receive from master / to player // from player / to master
//using it in MPCService and MAster/Player-FlowVM // refactor and scalable code

struct AnswerResultPayload: Codable {
    let isCorrect: Bool
    let points: Int
    let correctAnswer: String?
}

struct TimerStartPayload: Codable {
    let masterTimestamp: TimeInterval  // Unix timestamp when Master started timer
}

enum MPCMessage: Codable {
    // PLAYER -> MASTER
    case playerJoin(Player)
    case buzz(BuzzPayload)
    case buyGiftRequest(GiftRequestPayload)

    // MASTER -> PLAYER
    case buyGiftResult(CoinsViewModel.Gift)
    case updatedPlayer(Player)
    case hintRevealedToPlayer(String)   // indice envoyé uniquement à l'acheteur

    case buzzLock(BuzzLockPayload)   // master dit "X a gagné, buzzer lock"
    case buzzUnlock                  // master dit "nouvelle manche, vous pouvez rebuzzer"

    //Master -> Team : état courant du jeu (affiché côté Team)
    case publicUpdate(PublicState)

    // Master -> Team : le Master lance une partie (invite les joueurs à rejoindre)
    case masterLaunchedGame(GameType)

    // Master -> Team : le timer du Master a démarré avec timestamp pour synchronisation
    case timerStarted(TimerStartPayload)

    // Master -> Team : résultat de la réponse (correct/incorrect + points)
    case answerResult(AnswerResultPayload)

    // Master -> Team : le Master démarre la partie (les joueurs vont dans la vue buzzer permanente)
    case masterStartedParty

    // Master -> Team : toutes les manches sont terminées (afficher le podium final)
    case masterGameComplete

    //TEST
    case pong
}

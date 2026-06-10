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

// #countdown-sync — le décompte 3-2-1-GO est calculé par chaque Player sur son horloge
// locale depuis ce timestamp (même principe que TimerStartPayload #T2), au lieu de N
// broadcasts par phase → plus de décalage du décompte entre les téléphones.
struct CountdownStartPayload: Codable {
    let masterTimestamp: TimeInterval  // Unix timestamp du début du décompte côté Master
    let startCount: Int                // 3 (début de manche) ou 2 (reprise après refus Quiz)
}

enum MPCMessage: Codable {
    // PLAYER -> MASTER
    case playerJoin(Player)
    case buzz(BuzzPayload)
    case buyGiftRequest(GiftRequestPayload)
    case playerReady  // Player est arrivé sur son buzzer

    // MASTER -> PLAYER
    case buyGiftResult(CoinsViewModel.Gift)
    case updatedPlayer(Player)
    // Liste des joueurs complète en UN message (avant : N × updatedPlayer). Reçu = merge
    // avec le dédoublonnage id/nom existant ; updatedPlayer reste pour les màj unitaires.
    case rosterUpdate([Player])
    // #countdown-sync — début du décompte 3-2-1-GO, calculé localement par chaque Player.
    case countdownStarted(CountdownStartPayload)
    case hintRevealedToPlayer(String)   // indice envoyé uniquement à l'acheteur
    case hintPending                    // #22 — indice acheté entre 2 manches (mis en file) : feedback "en attente" à l'acheteur

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

    // Master -> Team : le Master lance une nouvelle partie (reset scores, retour au lobby)
    case masterResetGame

    // Master -> Team : le Master a quitté la partie → les Players rentrent à l'accueil
    // (et arrêtent de tenter une reconnexion). Voir #quit-teardown.
    case masterLeftParty

    // Master -> Team : le Master a perdu ce joueur de son roster (timeout heartbeat sur une
    // connexion half-open) alors qu'il est toujours joignable → lui demander de se ré-annoncer
    // (renvoyer playerJoin) pour réintégrer le roster et lever la pause. Voir #pause-reco.
    case masterRequestRejoin

    // Heartbeat : le Master ping périodiquement, le Player répond pong.
    case ping
    case pong
}

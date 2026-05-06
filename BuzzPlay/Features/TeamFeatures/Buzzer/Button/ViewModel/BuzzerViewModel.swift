//
//  BuzzerViewModel.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 10/11/2025.
//

import Foundation

enum BuzzerGameMode {
    case blindTest
    case quiz
}

@Observable
class BuzzerViewModel {

    var player: Player
    let mode: BuzzerGameMode

    var isEnabled: Bool = false
    var playerNameHasBuzz: String?

    var onBuzz: ((Player, BuzzerGameMode) -> Void)?

    init(player: Player, mode: BuzzerGameMode) {
        self.player = player
        self.mode = mode
    }

    
    
}

//MARK: buzzFunctions
extension BuzzerViewModel {
    func buzz() {
        guard isEnabled/*, !hasBuzzed*/ else { return }
//        hasBuzzed = true
        //MARK: le TeamGameVM gère l'envoi du buzz au Master
        onBuzz?(player, mode)
    }


    func unLockBuzz() {
        isEnabled = true
        playerNameHasBuzz = nil

    }

    func lockBuzz(teamNameHasBuzz: String) {
        self.playerNameHasBuzz = teamNameHasBuzz
        isEnabled = false
    }

    func clearBuzzState() {
        playerNameHasBuzz = nil
        isEnabled = false
    }
}



//MARK: 

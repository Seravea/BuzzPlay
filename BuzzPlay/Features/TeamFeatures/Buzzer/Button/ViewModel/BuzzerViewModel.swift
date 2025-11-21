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
    
    var team: Team
    let mode: BuzzerGameMode
    
    var hasBuzzed: Bool = false
    var isEnabled: Bool = false
    var teamNameHasBuzz: String?
    
    var onBuzz: ((Team, BuzzerGameMode) -> Void)?

    init(team: Team, mode: BuzzerGameMode) {
        self.team = team
        self.mode = mode
    }

    
    
}

//MARK: buzzFunctions
extension BuzzerViewModel {
    func buzz() {
        guard isEnabled, !hasBuzzed else { return }
        hasBuzzed = true
        //MARK: le TeamGameVM gère l'envoi du buzz au Master
        onBuzz?(team, mode)
    }
    
    
    func unLockBuzz() {
        isEnabled = true
        teamNameHasBuzz = nil
    }
    
    func lockBuzz(teamNameHasBuzz: String) {
        self.teamNameHasBuzz = teamNameHasBuzz
        isEnabled = false
    }
}



//MARK: 

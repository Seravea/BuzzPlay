//
//  CreateTeamViewModem.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 13/11/2025.
//

import Foundation
import Observation

@Observable
class CreateTeamViewModel: ObservableObject {
    var team: Team
    var isAlertOn: Bool = false
    
    init(team: Team) {
        self.team = team
    }
    
    
    
    var nbofPlayers: Int {
        team.players.count
    }
    
    func removePlayer(player: Player) {
        if let index = team.players.firstIndex(of: player) {
            team.players.remove(at: index)
        }
    }
    
    func verifyEmptyPlayerName() {
        var newPlayers: [Player] = []
        for player in team.players {
            if !player.name.isEmpty {
                newPlayers.append(player)
            }
        }
        isAlertOn = true
        team.players = newPlayers
    }
}

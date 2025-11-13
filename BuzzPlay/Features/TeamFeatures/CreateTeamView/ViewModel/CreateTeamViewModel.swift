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
    var team: Team = Team(name: "", colorIndex: 0, players: [])
    var isAlertOn: Bool = false
    
    
    
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

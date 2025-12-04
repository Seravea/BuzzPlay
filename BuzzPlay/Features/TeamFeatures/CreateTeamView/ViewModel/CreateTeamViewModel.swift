//
//  CreateTeamViewModem.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 13/11/2025.
//

import Foundation
import Observation

@Observable
class CreateTeamViewModel {
    var team: Team = Team(name: "", teamColor: .redGame, players: [])
    var isAlertOn: Bool = false
    
    var onTeamCreated: ((Team, Bool) -> Void)?
    
    func validate(isPublicDisplay: Bool){
        onTeamCreated?(team, isPublicDisplay)
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
    
    func isSelectedGameColor(_ color: GameColor) -> Double {
        if team.teamColor == color {
            return 1
        } else {
            return 0.3
        }
    }
    
    func loadDisplayTeam() {
        team = Team(name: "Écran Publique")
    }
}

//
//  CreateTeamViewModel.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 13/11/2025.
//

import Foundation
import Observation

@Observable
class CreateTeamViewModel {
    
    //MARK: - Datas
    var team: Team = Team(name: "", teamColor: .redGame, players: [])
    var isAlertOn: Bool = false
    
    /// Le bool sert à dire si on crée une vraie team joueur (false) ou un "client" écran public (true)
    var onTeamCreated: ((Team, Bool) -> Void)?
    
    
    //MARK: - Actions
    
    func validate(isPublicDisplay: Bool) {
        // Nettoyage léger ici (le gros nettoyage reste dans TeamFlow)
        team.name = team.name.trimmingCharacters(in: .whitespacesAndNewlines)
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
        let newPlayers = team.players.filter { !$0.name.isEmpty }
        isAlertOn = true
        team.players = newPlayers
    }
    
    func isSelectedGameColor(_ color: GameColor) -> Double {
        team.teamColor == color ? 1 : 0.3
    }
    
    
    //MARK: - Public Display (écran)
    
    /// Prépare un "pseudo team" dédiée à l'écran public.
    /// Important : on ne veut pas de joueurs ici, ni de logique "team normale".
    func loadDisplayTeam() {
        team = Team(
            name: "Écran Public",
            image: nil,
            teamColor: .blueGame,
            players: [],
            score: 0,
            accountAmount: 0
        )
    }
}

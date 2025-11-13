//
//  TeamFlowViewModel.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 13/11/2025.
//

import Foundation
import Observation

@Observable
class TeamFlowViewModel {
    var teamGameVM: TeamGameViewModel?
    let mpc = MPCService()

    func makeCreateTeamViewModel() -> CreateTeamViewModel {
        let vm = CreateTeamViewModel()

        vm.onTeamCreated = { [weak self] team in
            guard let self else { return }
            var newPlayers: [Player] = []
            for player in team.players {
                if !player.name.isEmpty {
                    newPlayers.append(player)
                }
            }
            let newTeam = Team(name: team.name, colorIndex: 0, players: newPlayers)
            
            
            // 1️⃣ Créer le moteur principal pour CE joueur
            self.teamGameVM = TeamGameViewModel(team: newTeam, mpc: self.mpc)
        }

        return vm
    }
    
    
    func makeBuzzerViewModel(for mode: BuzzerGameMode) -> BuzzerViewModel {
        guard let teamVM = teamGameVM else {
            fatalError("Pas de team défini")
        }
        let vm = BuzzerViewModel(team: teamVM.team, mode: mode)

            vm.onBuzz = { [weak self] team, mode in
                // Ici tu feras plus tard :
                // - envoyer le buzz via MPC
                // - mettre à jour de l’état local si tu veux
                print("Buzz de \(team.name) sur mode \(mode)")
            }

            return vm
        }
}

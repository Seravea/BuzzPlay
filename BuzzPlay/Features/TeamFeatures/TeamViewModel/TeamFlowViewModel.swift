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
    var mpc: MPCService?
    
    var team: Team?

    func makeCreateTeamViewModel() -> CreateTeamViewModel {
        let vm = CreateTeamViewModel()

        vm.onTeamCreated = { [weak self] rawTeam in
            guard let self else { return }

            // Nettoyage des joueurs
            let cleanedPlayers = rawTeam.players
                .filter { !$0.name.isEmpty }

            // La team finale, unique source de vérité
            let newTeam = Team(
                name: rawTeam.name.trimmingCharacters(in: .whitespaces),
                colorIndex: 0,
                players: cleanedPlayers
            )

            self.team = newTeam

            // MPCService unique pour l’iPad joueur
            let mpc = MPCService(peerName: newTeam.name, role: .team)
            self.mpc = mpc

            // Le TeamGameVM doit recevoir LA MÊME TEAM
            let gameVM = TeamGameViewModel(team: newTeam, mpc: mpc)
            self.teamGameVM = gameVM

            // On lance le browsing après que tout soit en place
            gameVM.startBrowsing()
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

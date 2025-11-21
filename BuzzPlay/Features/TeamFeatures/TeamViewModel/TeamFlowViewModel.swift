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
            
            //Si les deux ViewModel (TeamGame et MPC) sont créés ne recréer pas une nouvelle team
            if let _ = self.teamGameVM, let _ = self.mpc {
                print("TeamFlow: team already created, ignoring extra validate")
                return
            }
            // Nettoyage des joueurs
            let cleanedPlayers = rawTeam.players
                .filter { !$0.name.isEmpty }

            // La team finale, unique source de vérité
            let newTeam = Team(
                name: rawTeam.name.trimmingCharacters(in: .whitespaces),
                teamColor: rawTeam.teamColor,
                players: cleanedPlayers
            )

            self.team = newTeam

            // MPCService unique pour l’iPad joueur
            let mpc = MPCService(peerName: newTeam.name, role: .team)
            self.mpc = mpc

            // Le TeamGameVM doit recevoir LA MÊME TEAM
            let gameVM = TeamGameViewModel(team: newTeam, mpc: mpc, clientMode: .team)
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
        teamVM.currentBuzzerVM = vm

        // buzz -> envoi MPC
        vm.onBuzz = { [weak self] team, mode in
            print("Buzz de \(team.name) sur mode \(mode)")
            vm.isEnabled = false
            
            guard let mpc = self?.mpc else {
                print("ERREUR MPC: pas de MPCService dans TeamFlowViewModel")
                return
            }

            mpc.sendMessage(.buzz(BuzzPayload(teamID: team.id)))
        }
        

        return vm
    }
}

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

    var createTeamVM: CreateTeamViewModel = CreateTeamViewModel()

    init() {
        createTeamVM.onTeamCreated = { [weak self] rawTeam in
            guard let self else { return }

            if self.teamGameVM != nil || self.mpc != nil {
                print("TeamFlow: existing session detected, resetting before creating a new team")
                self.resetLocalSession()
            }

            let cleanedPlayers = rawTeam.players.filter { !$0.name.isEmpty }
            let newTeam = Team(
                name: rawTeam.name.trimmingCharacters(in: .whitespaces),
                teamColor: rawTeam.teamColor,
                players: cleanedPlayers
            )

            self.team = newTeam

            let mpc = MPCService(peerName: newTeam.name, role: .team)
            self.mpc = mpc

            let gameVM = TeamGameViewModel(team: newTeam, mpc: mpc)
            self.teamGameVM = gameVM

            gameVM.startBrowsing()
        }
    }

    func resetLocalSession() {
        teamGameVM = nil
        mpc = nil
        team = nil
    }

    func makeCreateTeamViewModel() -> CreateTeamViewModel {
        return createTeamVM
    }

    func makeBuzzerViewModel(for mode: BuzzerGameMode) -> BuzzerViewModel {
        guard let teamVM = teamGameVM else {
            fatalError("Pas de team défini")
        }

        let vm = BuzzerViewModel(team: teamVM.team, mode: mode)
        teamVM.currentBuzzerVM = vm

        vm.onBuzz = { [weak self] team, mode in
            print("Buzz de \(team.name) sur mode \(mode)")
            vm.isEnabled = false

            guard let mpc = self?.mpc else {
                print("MPC: pas de MPCService dans TeamFlowViewModel")
                return
            }

            mpc.sendMessage(.buzz(BuzzPayload(teamID: team.id)))
        }

        return vm
    }
}

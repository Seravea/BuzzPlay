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
    //MARK: - Persistence
    private let savedTeamKey = "buzzplay.savedTeam.v1"

    var hasSavedTeam: Bool {
        UserDefaults.standard.data(forKey: savedTeamKey) != nil
    }

    func restoreSavedTeamIfPossible() {
        guard teamGameVM == nil, mpc == nil else {
            // Already initialized in memory
            return
        }
        guard let data = UserDefaults.standard.data(forKey: savedTeamKey) else { return }
        do {
            let savedTeam = try JSONDecoder().decode(Team.self, from: data)
            self.team = savedTeam

            let mpc = MPCService(peerName: savedTeam.name, role: .team)
            self.mpc = mpc

            let gameVM = TeamGameViewModel(team: savedTeam, mpc: mpc, clientMode: .team)
            self.teamGameVM = gameVM

            gameVM.startBrowsing()
        } catch {
            print("TeamFlow: failed to restore saved team: \(error)")
        }
    }

    func clearSavedTeam() {
        UserDefaults.standard.removeObject(forKey: savedTeamKey)
    }
    
    func resetLocalSession(clearPersistence: Bool = false) {
        teamGameVM = nil
        mpc = nil
        team = nil
        if clearPersistence {
            clearSavedTeam()
        }
    }

    private func persistTeam(_ team: Team) {
        do {
            let data = try JSONEncoder().encode(team)
            UserDefaults.standard.set(data, forKey: savedTeamKey)
        } catch {
            print("TeamFlow: failed to persist team: \(error)")
        }
    }
    var teamGameVM: TeamGameViewModel?
    var mpc: MPCService?
    
    var team: Team?

    func makeCreateTeamViewModel() -> CreateTeamViewModel {
        let vm = CreateTeamViewModel()

        vm.onTeamCreated = { [weak self] (rawTeam, isPublicDisplay) in
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

            // ✅ Persist only real teams (never persist the Public Display “team”)
            if !isPublicDisplay {
                self.persistTeam(newTeam)
            }

            // MPC role + clientMode depend on the creation type
            let role: MPCRole = isPublicDisplay ? .publicScreen : .team
            let clientMode: ClientMode = isPublicDisplay ? .publicDisplay : .team

            // MPCService unique pour CE device
            let mpc = MPCService(peerName: newTeam.name, role: role)
            self.mpc = mpc

            // Le TeamGameVM doit recevoir LA MÊME TEAM
            let gameVM = TeamGameViewModel(team: newTeam, mpc: mpc, clientMode: clientMode)
            self.teamGameVM = gameVM

            // On lance le browsing après que tout soit en place
            gameVM.startBrowsing()

            // Si c'est un écran public, on informe le master qu'un display est actif
            if isPublicDisplay {
                mpc.sendMessage(.publicDisplayMode(isActive: true))
            }
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

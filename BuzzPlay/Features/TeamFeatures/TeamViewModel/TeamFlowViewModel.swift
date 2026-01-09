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

    /// Toggle this when you want persistence back.
    /// For now it's OFF to avoid auto-restore/auto-connection side effects.
    private let isPersistenceEnabled = false

    /// When a saved team exists demonstrated to the user, we keep it here.
    /// IMPORTANT: this does NOT start MPC or connect to the Master.
    var savedTeamDraft: Team?

    var hasSavedTeam: Bool {
        guard isPersistenceEnabled else { return false }
        return UserDefaults.standard.data(forKey: savedTeamKey) != nil
    }

    /// Load the saved team ONLY as a draft, without starting MPC.
    /// Call this from the CreateTeam screen to *propose* the team.
    func loadSavedTeamDraftIfPossible() {
        guard isPersistenceEnabled else { return }
        guard savedTeamDraft == nil else { return }
        guard let data = UserDefaults.standard.data(forKey: savedTeamKey) else { return }
        do {
            savedTeamDraft = try JSONDecoder().decode(Team.self, from: data)
        } catch {
            print("TeamFlow: failed to decode saved team draft: \(error)")
            savedTeamDraft = nil
        }
    }

    /// Remove the persisted team.
    func clearSavedTeam() {
        UserDefaults.standard.removeObject(forKey: savedTeamKey)
        savedTeamDraft = nil
    }

    /// Reset only the in-memory session.
    /// If you pass clearPersistence=true, it also deletes the saved team.
    func resetLocalSession(clearPersistence: Bool = false) {
        teamGameVM = nil
        mpc = nil
        team = nil
        // On garde éventuellement le draft (proposition) mais on ne doit rien connecter.
        if clearPersistence {
            clearSavedTeam()
        }
    }

    private func persistTeamIfEnabled(_ team: Team) {
        guard isPersistenceEnabled else { return }
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

    //MARK: - Create Team (single VM instance)
    var createTeamVM: CreateTeamViewModel = CreateTeamViewModel()

    init() {
        createTeamVM.onTeamCreated = { [weak self] (rawTeam, isPublicDisplay) in
            guard let self else { return }

            // Si une ancienne session existe (retour arrière, relance, etc.),
            // on la reset pour permettre de créer/rejoindre une nouvelle team.
            if self.teamGameVM != nil || self.mpc != nil {
                print("TeamFlow: existing session detected, resetting before creating a new team")
                self.resetLocalSession(clearPersistence: false)
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

            // ✅ Persistence is currently disabled (see isPersistenceEnabled)
            // If you re-enable it later, this will save only real teams (not Public Display).
            if !isPublicDisplay {
                self.persistTeamIfEnabled(newTeam)
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

            // ✅ Important: do NOT send any message here.
            // The device might not be connected yet (connectedPeers can be empty).
            // PublicDisplayMode must be sent AFTER connection (inside TeamGameViewModel.mpc.onPeerConnected).
        }
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

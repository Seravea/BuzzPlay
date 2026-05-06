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
    private let savedPlayerKey = "buzzplay.savedPlayer.v1"

    /// Toggle this when you want persistence back.
    /// For now it's OFF to avoid auto-restore/auto-connection side effects.
    private let isPersistenceEnabled = false

    /// When a saved player exists demonstrated to the user, we keep it here.
    /// IMPORTANT: this does NOT start MPC or connect to the Master.
    var savedPlayerDraft: Player?

    var hasSavedPlayer: Bool {
        guard isPersistenceEnabled else { return false }
        return UserDefaults.standard.data(forKey: savedPlayerKey) != nil
    }

    /// Load the saved player ONLY as a draft, without starting MPC.
    /// Call this from the CreateTeam screen to *propose* the player.
    func loadSavedPlayerDraftIfPossible() {
        guard isPersistenceEnabled else { return }
        guard savedPlayerDraft == nil else { return }
        guard let data = UserDefaults.standard.data(forKey: savedPlayerKey) else { return }
        do {
            savedPlayerDraft = try JSONDecoder().decode(Player.self, from: data)
        } catch {
            print("TeamFlow: failed to decode saved player draft: \(error)")
            savedPlayerDraft = nil
        }
    }

    /// Remove the persisted player.
    func clearSavedPlayer() {
        UserDefaults.standard.removeObject(forKey: savedPlayerKey)
        savedPlayerDraft = nil
    }

    /// Reset only the in-memory session.
    /// If you pass clearPersistence=true, it also deletes the saved player.
    func resetLocalSession(clearPersistence: Bool = false) {
        teamGameVM = nil
        mpc = nil
        player = nil
        // On garde éventuellement le draft (proposition) mais on ne doit rien connecter.
        if clearPersistence {
            clearSavedPlayer()
        }
    }

    private func persistPlayerIfEnabled(_ player: Player) {
        guard isPersistenceEnabled else { return }
        do {
            let data = try JSONEncoder().encode(player)
            UserDefaults.standard.set(data, forKey: savedPlayerKey)
        } catch {
            print("TeamFlow: failed to persist player: \(error)")
        }
    }
    var teamGameVM: TeamGameViewModel?
    var mpc: MPCService?

    var player: Player?

    //MARK: - Create Player (single VM instance)
    var createTeamVM: CreateTeamViewModel = CreateTeamViewModel()

    init() {
        createTeamVM.onPlayerCreated = { [weak self] rawPlayer in
            guard let self else { return }

            // Si une ancienne session existe (retour arrière, relance, etc.),
            // on la reset pour permettre de créer/rejoindre une nouvelle player.
            if self.teamGameVM != nil || self.mpc != nil {
                print("TeamFlow: existing session detected, resetting before creating a new player")
                self.resetLocalSession(clearPersistence: false)
            }

            // La player finale, unique source de vérité
            let newPlayer = Player(
                name: rawPlayer.name.trimmingCharacters(in: .whitespaces),
                image: rawPlayer.image,
                teamColor: rawPlayer.teamColor,
                score: rawPlayer.score,
                accountAmount: rawPlayer.accountAmount
            )

            self.player = newPlayer

            self.persistPlayerIfEnabled(newPlayer)

            // MPCService unique pour CE device
            let mpc = MPCService(peerName: newPlayer.name, role: .team)
            self.mpc = mpc

            // Le TeamGameVM doit recevoir LE MÊME PLAYER
            let gameVM = TeamGameViewModel(player: newPlayer, mpc: mpc)
            self.teamGameVM = gameVM

            // On lance le browsing après que tout soit en place
            gameVM.startBrowsing()
        }
    }

    func makeCreateTeamViewModel() -> CreateTeamViewModel {
        return createTeamVM
    }


    func makeBuzzerViewModel(for mode: BuzzerGameMode) -> BuzzerViewModel {
        guard let teamVM = teamGameVM else {
            fatalError("Pas de player défini")
        }

        let vm = BuzzerViewModel(player: teamVM.player, mode: mode)
        teamVM.currentBuzzerVM = vm

        // buzz -> envoi MPC
        vm.onBuzz = { [weak self] player, mode in
            print("Buzz de \(player.name) sur mode \(mode)")
            vm.isEnabled = false

            guard let mpc = self?.mpc else {
                print("ERREUR MPC: pas de MPCService dans TeamFlowViewModel")
                return
            }

            mpc.sendMessage(.buzz(BuzzPayload(playerID: player.id)))
        }


        return vm
    }
}

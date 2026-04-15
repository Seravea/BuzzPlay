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
    /// Formulaire en cours (source de vérité pour l'écran)
    var team: Team = Team(name: "", teamColor: .redGame, players: [])

    /// Proposition éventuelle d'une team sauvegardée (ne déclenche PAS de connexion)
    var savedTeamDraft: Team? = nil

    /// True si l'utilisateur a explicitement choisi d'utiliser `savedTeamDraft`.
    var didLoadSavedTeam: Bool = false
    var isAlertOn: Bool = false
    
    /// Callback appelé quand l'utilisateur valide la création de sa team.
    var onTeamCreated: ((Team) -> Void)?
    
    //MARK: - Init

    init() {
        // IMPORTANT: on ne charge PAS automatiquement la team dans le formulaire,
        // sinon ça peut déclencher des effets de bord (connexion MPC, team déjà envoyée, etc.)
        // On ne fait que proposer une "draft".
        self.savedTeamDraft = Self.loadSavedTeam()
    }

    //MARK: - Local Storage (opt-in)

    private static let savedTeamKey = "buzzplay.savedTeam"

    static func loadSavedTeam() -> Team? {
        guard let data = UserDefaults.standard.data(forKey: savedTeamKey) else { return nil }
        return try? JSONDecoder().decode(Team.self, from: data)
    }

    static func saveSavedTeam(_ team: Team) {
        guard let data = try? JSONEncoder().encode(team) else { return }
        UserDefaults.standard.set(data, forKey: savedTeamKey)
    }

    static func clearSavedTeam() {
        UserDefaults.standard.removeObject(forKey: savedTeamKey)
    }

    var hasSavedTeamDraft: Bool {
        savedTeamDraft != nil
    }

    /// L'utilisateur choisit explicitement d'utiliser la team sauvegardée.
    func useSavedTeamDraft() {
        guard let saved = savedTeamDraft else { return }
        var cleaned = saved
        cleaned.name = cleaned.name.trimmingCharacters(in: .whitespacesAndNewlines)
        team = cleaned
        didLoadSavedTeam = true
    }

    /// Remet un formulaire vide (sans toucher la sauvegarde).
    func resetForm() {
        team = Team(name: "", teamColor: .redGame, players: [])
        didLoadSavedTeam = false
    }

    /// Supprime la team sauvegardée, et remet un formulaire vide.
    func deleteSavedTeamDraft() {
        Self.clearSavedTeam()
        savedTeamDraft = nil
        resetForm()
    }
    
    //MARK: - Actions
    func validate() {
        // ✅ Safety UX:
        // Si l'utilisateur a une team sauvegardée mais n'a pas appuyé sur "Utiliser"
        // et qu'il clique "Continuer" avec un formulaire vide → on utilise la draft.
        let trimmedName = team.name.trimmingCharacters(in: .whitespacesAndNewlines)
        let hasAnyPlayerName = team.players.contains { !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

        if !didLoadSavedTeam,
           savedTeamDraft != nil,
           trimmedName.isEmpty,
           !hasAnyPlayerName {
            useSavedTeamDraft()
        }

        // Nettoyage léger ici (le gros nettoyage reste dans TeamFlow)
        team.name = team.name.trimmingCharacters(in: .whitespacesAndNewlines)

        // ✅ Persistance
        Self.saveSavedTeam(team)
        savedTeamDraft = team

        onTeamCreated?(team)
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
}

//
//  CreateTeamViewModel.swift
//  BuzzPlay
//

import Foundation
import Observation

@Observable
class CreateTeamViewModel {

    // MARK: - Données

    /// Pseudo du joueur (= team.name pour le MPC)
    var pseudo: String = ""

    /// Couleur choisie
    var teamColor: GameColor = .redGame

    /// Draft sauvegardé (pseudo + couleur de la session précédente)
    var savedTeamDraft: Team? = nil

    /// Callback déclenché après validate()
    var onTeamCreated: ((Team) -> Void)?

    // MARK: - Init

    init() {
        self.savedTeamDraft = Self.loadSavedTeam()
        if let saved = savedTeamDraft {
            pseudo = saved.name
            teamColor = saved.teamColor
        }
    }

    // MARK: - Validation

    var isPseudoValid: Bool {
        let trimmed = pseudo.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.count >= 2 && trimmed.count <= 20
    }

    func validate() {
        let trimmed = pseudo.trimmingCharacters(in: .whitespacesAndNewlines)
        let player = Player(name: trimmed)
        let team = Team(name: trimmed, teamColor: teamColor, players: [player])
        Self.saveSavedTeam(team)
        onTeamCreated?(team)
    }

    // MARK: - Persistance locale

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
}

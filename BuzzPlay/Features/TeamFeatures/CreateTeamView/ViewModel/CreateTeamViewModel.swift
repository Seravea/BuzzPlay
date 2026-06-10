//
//  CreateTeamViewModel.swift
//  BuzzPlay
//

import Foundation
import Observation

@Observable
class CreateTeamViewModel {

    // MARK: - Données

    /// Pseudo du joueur (= player.name pour le MPC)
    var pseudo: String = ""

    /// Couleur choisie
    var playerColor: GameColor = .redGame

    /// Draft sauvegardé (pseudo + couleur de la session précédente)
    var savedPlayerDraft: Player? = nil

    /// Noms déjà pris dans la session (injecté depuis le Master ou ignoré côté Player)
    var takenNames: [String] = []

    /// Callback déclenché après validate()
    var onPlayerCreated: ((Player) -> Void)?

    // MARK: - Init

    init() {
        self.savedPlayerDraft = Self.loadSavedPlayer()
        if let saved = savedPlayerDraft {
            pseudo = saved.name
            playerColor = saved.teamColor
        }
    }

    // MARK: - Validation

    var isPseudoValid: Bool {
        let trimmed = pseudo.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 2 && trimmed.count <= 20 else { return false }
        return !takenNames.contains(where: { $0.lowercased() == trimmed.lowercased() })
    }

    var pseudoErrorMessage: String? {
        let trimmed = pseudo.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.count > 0 && trimmed.count < 2 { return "Au moins 2 caractères" }
        if trimmed.count > 20 { return "Maximum 20 caractères" }
        if takenNames.contains(where: { $0.lowercased() == trimmed.lowercased() }) {
            return "Ce pseudo est déjà pris"
        }
        return nil
    }

    func validate() {
        let trimmed = pseudo.trimmingCharacters(in: .whitespacesAndNewlines)
        let player = Player(name: trimmed, teamColor: playerColor)
        Self.saveSavedPlayer(player)
        onPlayerCreated?(player)
    }

    // MARK: - Persistance locale

    private static let savedPlayerKey = "buzzplay.savedPlayer"

    static func loadSavedPlayer() -> Player? {
        guard let data = UserDefaults.standard.data(forKey: savedPlayerKey) else { return nil }
        return try? JSONDecoder().decode(Player.self, from: data)
    }

    static func saveSavedPlayer(_ player: Player) {
        guard let data = try? JSONEncoder().encode(player) else { return }
        UserDefaults.standard.set(data, forKey: savedPlayerKey)
    }

    static func clearSavedPlayer() {
        UserDefaults.standard.removeObject(forKey: savedPlayerKey)
    }
}

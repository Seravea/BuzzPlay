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
    var team: Team = Team(name: "", teamColor: .redGame, players: [])
    var savedTeamDraft: Team? = nil
    var didLoadSavedTeam: Bool = false
    var isAlertOn: Bool = false

    var onTeamCreated: ((Team) -> Void)?

    //MARK: - Init
    init() {
        self.savedTeamDraft = Self.loadSavedTeam()
    }

    //MARK: - Local Storage
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

    func useSavedTeamDraft() {
        guard let saved = savedTeamDraft else { return }
        var cleaned = saved
        cleaned.name = cleaned.name.trimmingCharacters(in: .whitespacesAndNewlines)
        team = cleaned
        didLoadSavedTeam = true
    }

    func resetForm() {
        team = Team(name: "", teamColor: .redGame, players: [])
        didLoadSavedTeam = false
    }

    func deleteSavedTeamDraft() {
        Self.clearSavedTeam()
        savedTeamDraft = nil
        resetForm()
    }

    //MARK: - Actions
    func validate() {
        let trimmedName = team.name.trimmingCharacters(in: .whitespacesAndNewlines)
        let hasAnyPlayerName = team.players.contains { !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

        if !didLoadSavedTeam, savedTeamDraft != nil, trimmedName.isEmpty, !hasAnyPlayerName {
            useSavedTeamDraft()
        }

        team.name = team.name.trimmingCharacters(in: .whitespacesAndNewlines)
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

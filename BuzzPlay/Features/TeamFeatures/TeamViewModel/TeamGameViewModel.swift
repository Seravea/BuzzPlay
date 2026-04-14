//
//  TeamViewModem.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 13/11/2025.
//

import Foundation
import Observation

@Observable
final class TeamGameViewModel {

    var team: Team
    var mpc: MPCService
    var currentBuzzerVM: BuzzerViewModel?

    var hasStartedBrowsing = false
    var hasSetupMPC = false
    var didSentTeam = false

    var allGames: [GameType] = [.blindTest, .quiz]
    var openGames: [GameType] = [.score]

    init(team: Team, mpc: MPCService) {
        self.team = team
        self.mpc = mpc
        setupMPC()
    }
}

//MARK: MPC Browsing functions
extension TeamGameViewModel {
    private func setupMPC() {
        guard !hasSetupMPC else { return }
        hasSetupMPC = true

        mpc.onPeerConnected = { [weak self] _ in
            guard let self else { return }
            DispatchQueue.main.async {
                guard !self.didSentTeam else { return }
                self.didSentTeam = true
                self.mpc.sendMessage(.teamJoin(self.team))
            }
        }

        mpc.onMessage = { [weak self] data, peer in
            guard let self else { return }
            do {
                let message = try JSONDecoder().decode(MPCMessage.self, from: data)
                DispatchQueue.main.async {
                    self.handleMessage(message)
                }
            } catch {
                print("Message reçu inconnu dans MPCMessage : \(error)")
            }
        }
    }

    func startBrowsing() {
        guard !hasStartedBrowsing else { return }
        hasStartedBrowsing = true
        print("TEAM Starting MPC browsing...")
        mpc.startBrowsingIfNeeded()
    }
}

//MARK: UI properties
extension TeamGameViewModel {
    func gameIsAvalaible(_ game: GameType) -> Bool {
        openGames.contains(game)
    }
}

//MARK: Receive Message from Master
extension TeamGameViewModel {
    func handleMessage(_ message: MPCMessage) {
        switch message {
        case .gameAvailability(let games):
            self.openGames = games

        case .buzzLock(let payload):
            currentBuzzerVM?.lockBuzz(teamNameHasBuzz: payload.teamName)

        case .buzzUnlock:
            currentBuzzerVM?.unLockBuzz()

        case .updatedTeam(let updatedTeam):
            self.team = updatedTeam

        default:
            break
        }
    }
}

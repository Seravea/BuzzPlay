//
//  TeamViewModem.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 13/11/2025.
//

import Foundation
import Observation


@Observable
final class PlayerGameViewModel {

    var player: Player
    var mpc: MPCService
    var currentBuzzerVM: BuzzerViewModel?

    var hasStartedBrowsing = false
    var hasSetupMPC = false
    var didSentPlayer = false
    var isConnectedToMaster = false

    var receivedMessage: String = ""
    var allGames: [GameType] = [.blindTest, .quiz]
    var openGames: [GameType] = [.score]
    var publicState: PublicState = .waiting

    // Invite reçue du Master (jeu qu'il vient de lancer)
    var pendingGameInvite: GameType? = nil

    // MARK: - Public display timer mirroring
    // Expose a formatted time string for UI
    var formattedTime: String = "00:00"
    private var timer: Timer?
    // Keep the last known formatted time from master to display immediately
    private var lastMasterFormattedTime: String = "00:00"

    init(player: Player, mpc: MPCService) {
        self.player = player
        self.mpc = mpc
        setupMPC()
    }
}



//MARK: MPC Browsing functions
extension PlayerGameViewModel {
    private func setupMPC() {
        guard !hasSetupMPC else { return }
        hasSetupMPC = true

        mpc.onPeerConnected = { [weak self] _ in
            guard let self else { return }
            DispatchQueue.main.async {
                self.isConnectedToMaster = true
                guard !self.didSentPlayer else { return }

                // ✅ Only send once we are connected (prevents MCSession Code=2: Invalid peerIDs)
                self.didSentPlayer = true

                // PLAYER joins the master
                self.mpc.sendMessage(.playerJoin(self.player))
            }
        }

        mpc.onPeerDisconnected = { [weak self] _ in
            guard let self else { return }
            DispatchQueue.main.async {
                self.isConnectedToMaster = false
                // Reset so player re-announces itself when master comes back
                self.didSentPlayer = false
                self.openGames = []
                // Browser continues running; master will be re-discovered automatically
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
                print("Message received but unknown in MPCMessage: \(error)")
            }
        }

    }


    func startBrowsing() {
        guard !hasStartedBrowsing else { return }
        hasStartedBrowsing = true
        print("PLAYER Starting MPC browsing...")
        mpc.startBrowsingIfNeeded()
    }

}



//UI properties funcs
extension PlayerGameViewModel {
    func gameIsAvalaible(_ game: GameType) -> Bool {
        openGames.contains(game)
    }
}



//MARK: receive Message from Master
extension PlayerGameViewModel {
    func handleMessage(_ message: MPCMessage) {
        switch message {
        case .publicUpdate(let state):
            publicState = state
            handlePublicStateChange(state)

        case .gameAvailability(let games):
            self.openGames = games

        case .buzzLock(let payload):
            currentBuzzerVM?.lockBuzz(teamNameHasBuzz: payload.playerName)

        case .buzzUnlock:
            currentBuzzerVM?.unLockBuzz()

        case .updatedPlayer(let updatedPlayer):
            print("Before receive \(self.player)")
            self.player = updatedPlayer
            print("After receive \(self.player)")
        case .masterLaunchedGame(let game):
            pendingGameInvite = game
        default:
            break
        }
    }
}

// MARK: - Timer mirroring logic
extension PlayerGameViewModel {
    private func handlePublicStateChange(_ state: PublicState) {
        switch state {
        case .waiting:
            stopUITimer()
            formattedTime = "00:00"
            lastMasterFormattedTime = "00:00"
            currentBuzzerVM?.clearBuzzState()
        case .quiz(let quizState):
            lastMasterFormattedTime = quizState.formattedTime
            formattedTime = quizState.formattedTime
            startUITimerIfNeeded()
            if quizState.isAnswerRevealed {
                currentBuzzerVM?.clearBuzzState()
            } else {
                syncBuzzerState(buzzingPlayer: quizState.buzzingPlayer)
            }
        case .blindTest(let blindTestState):
            formattedTime = blindTestState.formattedTime
            lastMasterFormattedTime = blindTestState.formattedTime
            startUITimerIfNeeded()
            syncBuzzerState(buzzingPlayer: blindTestState.buzzingPlayer)
        }
    }

    // A lightweight UI timer to keep the display "alive" between master updates.
    // We don't attempt to compute exact time; we simply keep showing last known value.
    // If you want it to tick, you can parse mm:ss and increment. For now, we mirror.
    private func startUITimerIfNeeded() {
        guard timer == nil else { return }
        // Update at ~10Hz to keep UI responsive if you later add smoothing
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self else { return }
            // Keep formattedTime equal to the last value received from master.
            // If you want local ticking, parse and adjust here.
            self.formattedTime = self.lastMasterFormattedTime
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    private func stopUITimer() {
        timer?.invalidate()
        timer = nil
    }

    private func syncBuzzerState(buzzingPlayer: Player?) {
        if let player = buzzingPlayer {
            currentBuzzerVM?.lockBuzz(teamNameHasBuzz: player.name)
        } else {
            currentBuzzerVM?.unLockBuzz()
        }
    }
}

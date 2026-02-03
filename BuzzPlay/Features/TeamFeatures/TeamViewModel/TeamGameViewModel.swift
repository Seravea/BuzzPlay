//
//  TeamViewModem.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 13/11/2025.
//

import Foundation
import Observation

enum ClientMode {
    case team
    case publicDisplay
}


@Observable
final class TeamGameViewModel {
    
    let mode: ClientMode
    var team: Team
    var mpc: MPCService
    var currentBuzzerVM: BuzzerViewModel?
    
    var hasStartedBrowsing = false
    var hasSetupMPC = false
    var didSentTeam = false
    
    
    var receivedMessage: String = ""
    var allGames: [GameType] = [.blindTest, .quiz]
    var openGames: [GameType] = [.score]
    var isPublicDisplayActive: Bool = false
    var publicState: PublicState = .waiting
    
    // MARK: - Public display timer mirroring
    // Expose a formatted time string for UI
    var formattedTime: String = "00:00"
    private var timer: Timer?
    // Keep the last known formatted time from master to display immediately
    private var lastMasterFormattedTime: String = "00:00"
    
    init(team: Team, mpc: MPCService, clientMode: ClientMode) {
        self.team = team
        
        self.mpc = mpc
        
        self.mode = clientMode
        
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

                // ✅ Only send once we are connected (prevents MCSession Code=2: Invalid peerIDs)
                self.didSentTeam = true

                switch self.mode {
                case .team:
                    // TEAM joins the master
                    self.mpc.sendMessage(.teamJoin(self.team))

                case .publicDisplay:
                    // PUBLIC DISPLAY joins the master as a special client
                    self.mpc.sendMessage(.teamJoin(self.team))
                    // Tell the master that a public display client is present/active
                    self.mpc.sendMessage(.publicDisplayMode(isActive: true))
                }
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
                print("Message reçus mais inconnu dans MPCMessage : \(error)")
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



//UI properties funcs
extension TeamGameViewModel {
    func gameIsAvalaible(_ game: GameType) -> Bool {
        openGames.contains(game)
    }
}



//MARK: receive Message from Master
extension TeamGameViewModel {
    func handleMessage(_ message: MPCMessage) {
        switch message {
        case .publicDisplayMode(let isActive):
            isPublicDisplayActive = isActive
            
        case .publicUpdate(let state):
            publicState = state
            handlePublicStateChange(state)
            
        case .gameAvailability(let games):
            self.openGames = games
            
        case .buzzLock(let payload):
            currentBuzzerVM?.lockBuzz(teamNameHasBuzz: payload.teamName)
            
        case .buzzUnlock:
            currentBuzzerVM?.unLockBuzz()
            
        case .updatedTeam(let updatedTeam):
            print("Before receive \(self.team)")
            self.team = updatedTeam
            print("After receive \(self.team)")
        default:
            break
        }
    }
}

// MARK: - Timer mirroring logic
extension TeamGameViewModel {
    private func handlePublicStateChange(_ state: PublicState) {
        switch state {
        case .waiting:
            stopUITimer()
            formattedTime = "00:00"
            lastMasterFormattedTime = "00:00"
        case .quiz(let quizState):
            // Seed with master's formattedTime immediately so UI reflects source of truth
            lastMasterFormattedTime = quizState.formattedTime
            formattedTime = quizState.formattedTime
            startUITimerIfNeeded()
        case .blindTest(let blindTestState):
            formattedTime = blindTestState.formattedTime
            lastMasterFormattedTime = blindTestState.formattedTime
            startUITimerIfNeeded()
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
}

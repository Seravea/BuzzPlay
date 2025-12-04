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
    var openGames: [GameType] = []
    var isPublicDisplayActive: Bool = false
    var publicState: PublicState = .waiting
    
    
    
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
            guard !self.didSentTeam else { return }
            self.didSentTeam = true
            switch mode {
            case .team:
                self.mpc.sendTeam(team)
            case .publicDisplay:
                let publicTeam = Team(name: "DisplayPublic")
                self.mpc.sendTeam(publicTeam)
            }
                
            
            
        }
        
        mpc.onMessage = { [weak self] data, peer in
            guard let self else { return }
            
            do {
                let message = try JSONDecoder().decode(MPCMessage.self, from: data)
                self.handleMessage(message)
            } catch {
                print("Message reçus mais inconnu dans MPCMessage : \(error)")
            }
            
        }

    }
            //MARK: refactor using MPCMessage
//            if let update = try? JSONDecoder().decode(GameAvailability.self, from: data) {
//                print("TEAM: received game availability \(update.openGames)")
//                self.openGames = update.openGames
//            } else {
//                // Ici, tu peux ignorer ou logger
//                // ex: print("TEAM: received non-gameAvailability data")
//            }
//            
//            
//            //recoit le lock du buzzer
//            if let lock = try? JSONDecoder().decode(BuzzLockPayload.self, from: data) {
//                print("TEAM: received BUZZ LOCK (winner: \(lock.teamID))")
//                currentBuzzerVM?.teamNameHasBuzz = lock.teamName
//                
//                    currentBuzzerVM?.isEnabled = false
//                
//                
//                    return
//                }
//            
//            //recoit le unlock du buzzer
//            if let _ = try? JSONDecoder().decode(BuzzUnlockPayload.self, from: data) {
//                print("TEAM: received BUZZ UNLOCK")
//                self.currentBuzzerVM?.isEnabled = true   // bouton à nouveau cliquable
//                return
//            }
      
        
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
        case .gameAvailability(let games):
            self.openGames = games
        case .buzzLock(let payload):
            currentBuzzerVM?.lockBuzz(teamNameHasBuzz: payload.teamName)
        case .buzzUnlock:
            currentBuzzerVM?.unLockBuzz()
        case .updatedTeam(let updatedTeam):
            if updatedTeam.id == self.team.id {
                self.team = updatedTeam
            }
        default:
            break
        }
    }
    
    
    
    
}

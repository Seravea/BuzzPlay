//
//  TeamViewModem.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 13/11/2025.
//

import Foundation
import Observation




@Observable
final class TeamGameViewModel{
    
    var team: Team
    var mpc: MPCService
    var currentBuzzerVM: BuzzerViewModel?
    
    var hasStartedBrowsing = false
    var hasSetupMPC = false
    var didSentTeam = false
    
    
    var receivedMessage: String = ""
    var allGames: [GameType] = [.blindTest, .quiz]
    var openGames: [GameType] = []
    
    
    
    
    init(team: Team, mpc: MPCService) {
        self.team = team
        
        self.mpc = mpc
        
        print("TeamGameViewModel Initializing... for \(team.name)")
        
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
            self.mpc.sendTeam(self.team)
        }
        
        mpc.onMessage = { [weak self] data, peer in
            guard let self else { return }
            
            if let update = try? JSONDecoder().decode(GameAvailability.self, from: data) {
                print("TEAM: received game availability \(update.openGames)")
                self.openGames = update.openGames
            } else {
                // Ici, tu peux ignorer ou logger
                // ex: print("TEAM: received non-gameAvailability data")
            }
            
            
            //recoit le lock du buzzer
            if let lock = try? JSONDecoder().decode(BuzzLockPayload.self, from: data) {
                print("TEAM: received BUZZ LOCK (winner: \(lock.name))")
                    currentBuzzerVM?.teamNameHasBuzz = lock.name
                
                    currentBuzzerVM?.isEnabled = false
                
                
                    return
                }
            
            //recoit le unlock du buzzer
            if let _ = try? JSONDecoder().decode(BuzzUnlockPayload.self, from: data) {
                print("TEAM: received BUZZ UNLOCK")
                self.currentBuzzerVM?.isEnabled = true   // bouton à nouveau cliquable
                return
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

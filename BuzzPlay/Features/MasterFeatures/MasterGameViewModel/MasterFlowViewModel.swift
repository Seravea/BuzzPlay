//
//  MasterGameViewModel.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 14/11/2025.
//

import Foundation
import Observation
import MultipeerConnectivity


//MARK: - Master Flow ViewModel

@Observable
final class MasterFlowViewModel {
    
    //MARK: MPC datas
    var connectedPeers: [MCPeerID] = []
    var teams: [Team] = []
    
    var mpcService: MPCService = MPCService(peerName: "Master", role: .master)
    private var hasStartedHosting = false

    //MARK: Datas for games
    var currentBuzzTeam: Team?
    var isBuzzLocked: Bool = false
    var gameState: GameState = .lobby
    
    /// Liste des jeux ouverts par le maître
    var gamesOpen: [GameType] = []
    
    /// Jeu courant qui réagit aux buzz (BlindTest, Quiz, etc.)
    weak var currentBuzzGame: BuzzDrivenGame?
    
    
    //MARK: Master's makeVM
    
    func makeLobbyViewModel() -> MasterLobbyViewModel {
        MasterLobbyViewModel(gameVM: self)
    }
    
    func makeChooseGameVM() -> MasterChooseGameViewModel {
        MasterChooseGameViewModel(gameVM: self)
    }
    
    func makeBlindTestMasterVM() -> BlindTestMasterViewModel {
        let vm = BlindTestMasterViewModel(gameVM: self)
        // Le BlindTest est un jeu basé sur le buzz
        self.currentBuzzGame = vm
        return vm
    }
    
    func makeQuizMasterVM() -> QuizMasterViewModel {
        let vm = QuizMasterViewModel(gameVM: self)
        self.currentBuzzGame = vm
        return vm
    }
    
    
    //MARK: Master's functions for Team
    
    func addTeam(_ team: Team) {
        teams.append(team)
    }
    
    func removeTeam(_ team: Team) {
        teams.removeAll { $0.id == team.id }
    }
    
    
    //MARK: Master's functions for gameSelection
    
    func selectGame(_ game: GameType) {
        gameState = .inGame(game)
    }
}



//MARK: MPC Service for MasterFlow
extension MasterFlowViewModel {
    
    func setupMPC() {
        // Connexion / déconnexion des peers
        mpcService.onPeerConnected = { [weak self] peer in
            guard let self else { return }
            self.connectedPeers.append(peer)
        }

        mpcService.onPeerDisconnected = { [weak self] peer in
            guard let self else { return }
            self.connectedPeers.removeAll { $0 == peer }
        }

        // Réception des messages (buzz, teams, etc.)
        mpcService.onMessage = { [weak self] data, peer in
            guard let self else { return }

            //MARK: receive buzz from Browsers
            if let buzz = try? JSONDecoder().decode(BuzzPayload.self, from: data) {
                print("MASTER: received BUZZ from peer \(peer.displayName) (teamID: \(buzz.teamID))")

                // si déjà verrouillé, on ignore les autres buzz
                guard !self.isBuzzLocked else {
                    print("MASTER: buzz ignored, already locked")
                    return
                }

                // retrouver la team qui a buzzé
                if let team = self.teams.first(where: { $0.id == buzz.teamID }) {
                    self.currentBuzzTeam = team
                    self.isBuzzLocked = true
                    
                    print("MASTER: BUZZ WON by \(team.name)")
                    
                    // déléguer au jeu courant (BlindTest, etc.)
                    self.currentBuzzGame?.handleBuzz(from: team)

                    // prévenir tous les iPads qu'on bloque les buzz
                    self.mpcService.sendBuzzLock(winningTeamId: team.id, name: team.name)
                } else {
                    print("MASTER: BUZZ from unknown teamID \(buzz.teamID)")
                }

                return
            }

            // Team complète (au moment où les équipes se connectent)
            if let team = try? JSONDecoder().decode(Team.self, from: data) {
                print("Master received team \(team.name) from \(peer.displayName)")
                self.teams.append(team)
                return
            }

            print("Master: received unknown data from \(peer.displayName)")
        }

        print("Master start advertising")
        mpcService.startHostingIfNeeded()
        hasStartedHosting = true
    }
}



//MARK: func send games to Peer connected
extension MasterFlowViewModel {
    func broadcastGameAvailability() {
        mpcService.sendGameAvailability(gamesOpen)
    }
    
    func unlockBuzz() {
        isBuzzLocked = false
        currentBuzzTeam = nil
        mpcService.sendBuzzUnlock()
    }

    
}




//MARK: functions for game Score
extension MasterFlowViewModel {
    func addPointToTeam(_ team: Team) {
        guard let index = teams.firstIndex(of: team) else { return }
        teams[index].score += 10
    }
}

//
//  MasterGameViewModel.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 14/11/2025.
//

import Foundation
import Observation
import MultipeerConnectivity


@Observable
final class MasterFlowViewModel {
    
    var gameState: GameState = .lobby
    var connectedPeers: [MCPeerID] = []
    
    var teams: [Team] = []
    
    var mpcService: MPCService = MPCService(peerName: "Master", role: .master)
    
    private var hasStartedHosting = false

    
    //MARK: Master's makeVM
    func makeLobbyViewModel() -> MasterLobbyViewModel {
        MasterLobbyViewModel(gameVM: self)
    }
    
    func makeChooseGameVM() -> MasterChooseGameViewModel {
        MasterChooseGameViewModel(gameVM: self)
    }
    
    func makeBlindTestMasterVM() -> BlindTestViewModel {
        BlindTestViewModel(gameVM: self)
    }
    
    
    //MARK: Master's functions for Team
    
    func addTeam(_ team: Team) {
        teams.append(team)
    }
    
    func removeTeam(_ team: Team) {
        teams.removeAll { $0.id == team.id }
    }
    
    
    //MARK: Master's functions for gameSelection
    
    var gamesOpen: [GameType] = []
    
    func selectGame(_ game: GameType) {
        gameState = .inGame(game)
    }
    
    
    
    
}



//MARK: MPC Service for MasterFlow
extension MasterFlowViewModel {
    
    func setupMPC() {
            // Si tu veux vraiment empêcher plusieurs appels :
            guard !hasStartedHosting else { return }
            hasStartedHosting = true

            mpcService.onPeerConnected = { [weak self] peer in
                guard let self else { return }
                self.connectedPeers.append(peer)
            }

            mpcService.onPeerDisconnected = { [weak self] peer in
                guard let self else { return }
                self.connectedPeers.removeAll { $0 == peer }
            }

            mpcService.onMessage = { [weak self] data, peer in
                guard let self else { return }

                if let team = try? JSONDecoder().decode(Team.self, from: data) {
                    print("Master received team \(team.name) from \(peer.displayName)")
                    self.teams.append(team)
                } else {
                    print("Master: received nonTeam data from \(peer.displayName)")
                }
            }

            print("Master start advertising")
            mpcService.startHostingIfNeeded()   // ⬅️ nouvelle méthode côté MPCService
            hasStartedHosting = true
        }
}


//MARK: func send games to Peer connected
extension MasterFlowViewModel {
    func broadcastGameAvailability() {
        mpcService.sendGameAvailability(gamesOpen)
    }
}

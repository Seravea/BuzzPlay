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

@MainActor
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

    var gamesOpen: [GameType] = [.score]

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

    func sendUpdatedTeam(team: Team) {
        mpcService.sendMessagetoOneTeam(message: .updatedTeam(team), team: team)
    }

    //MARK: Master's functions for gameSelection

    func selectGame(_ game: GameType) {
        gameState = .inGame(game)
    }
}

//MARK: MPC Service for MasterFlow
extension MasterFlowViewModel {
    func handle(message: MPCMessage, from peer: MCPeerID) {
        switch message {
        case .teamJoin(let team):
            addTeam(team)
        case .buzz(let payload):
            handleBuzzReceive(data: payload, from: peer)
        case .buyGiftRequest(let request):
            print("TODO: handle gift request \(request)")
        case .updatedTeam(let team):
            sendUpdatedTeam(team: team)
        default:
            break
        }
    }

    func setupMPC() {
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
            do {
                let message = try JSONDecoder().decode(MPCMessage.self, from: data)
                self.handle(message: message, from: peer)
            } catch {
                print("MASTER: message inconnu de : \(peer.displayName)")
            }
        }

        print("Master start advertising")
        mpcService.startHostingIfNeeded()
        hasStartedHosting = true
    }
}

//MARK: Sending TO Peer connected
extension MasterFlowViewModel {
    func broadcastGameAvailability() {
        mpcService.sendGameAvailability(gamesOpen)
    }

    func unlockBuzz() {
        isBuzzLocked = false
        currentBuzzTeam = nil
        mpcService.sendMessage(.buzzUnlock)
    }
}

//MARK: Receiving FROM Peer connected
extension MasterFlowViewModel {
    func handleBuzzReceive(data: BuzzPayload, from peer: MCPeerID) {
        guard !isBuzzLocked else {
            print("MASTER: buzz ignoré car déjà locké")
            return
        }

        guard let team = teams.first(where: { $0.id == data.teamID }) else {
            print("MASTER: buzz reçu mais team introuvable")
            return
        }

        currentBuzzTeam = team
        isBuzzLocked = true

        currentBuzzGame?.handleBuzz(from: team)

        let lockPayload = BuzzLockPayload(teamID: team.id, teamName: team.name)
        mpcService.sendMessage(.buzzLock(lockPayload))
    }
}

//MARK: Score
extension MasterFlowViewModel {
    func addPointToTeam(_ team: Team, points: Int) {
        guard let index = teams.firstIndex(of: team) else { return }
        teams[index].score += points
        print("\(team.name) reçoit \(points) points")
        mpcService.sendMessagetoOneTeam(message: .updatedTeam(teams[index]), team: teams[index])
    }
}

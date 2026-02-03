//
//  MasterGameViewModel.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 14/11/2025.
//

import Foundation
import Observation
import MultipeerConnectivity

//TEST DATA  TEAMS
var sampleTeams: [Team] = [
    Team(name: "L'équipe",teamColor: .greenGame, players: [Player(name: "Romain"), Player(name: "Benjamin"),Player(name: "Romain"), Player(name: "Romain"), Player(name: "Romain"), Player(name: "Romain"),] , score: 240),
    Team(name: "L'équipe",teamColor: .blueGame, players: [Player(name: "Romain"), Player(name: "Benjamin"),Player(name: "Romain"), Player(name: "Romain"), Player(name: "Romain"), Player(name: "Romain"),] , score: 240),
    Team(name: "L'équipe",teamColor: .redGame, players: [Player(name: "Romain"), Player(name: "Benjamin"),Player(name: "Romain"), Player(name: "Romain"), Player(name: "Romain"), Player(name: "Romain"),] , score: 240),
    Team(name: "L'équipe",teamColor: .purpleGame, players: [Player(name: "Romain"), Player(name: "Benjamin"),Player(name: "Romain"), Player(name: "Romain"), Player(name: "Romain"), Player(name: "Romain"),] , score: 240),
    Team(name: "L'équipe",teamColor: .yellowGame, players: [Player(name: "Romain"), Player(name: "Benjamin"),Player(name: "Romain"), Player(name: "Romain"), Player(name: "Romain"), Player(name: "Romain"),] , score: 240),
]

//MARK: - Master Flow ViewModel

@MainActor
@Observable
final class MasterFlowViewModel {
    
    //MARK: MPC datas
    var connectedPeers: [MCPeerID] = []
    //TODO: empty Collection for TEST ON DEVICE or PRODUCTION
    var teams: [Team] = []
    
    var mpcService: MPCService = MPCService(peerName: "Master", role: .master)
    private var hasStartedHosting = false

    //MARK: Datas for games
    var currentBuzzTeam: Team?
    var isBuzzLocked: Bool = false
    var gameState: GameState = .lobby
    
    /// Liste des jeux ouverts par le maître
    var gamesOpen: [GameType] = [.score]
    
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
        if team.name == "Écran Publique" {
            mpcService.sendMessage(.publicDisplayMode(isActive: true))
        }

        teams.append(team)

        // Si un écran public vient de se connecter, on lui envoie tout de suite l'état actuel
        if team.name == "Écran Publique" {
            broadcastPublicStateFromCurrentGame()
        }
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
            print("TODO: Func handle and send gift request \(request)")
        case .publicUpdate(let update):
            sendPublicState(update)
        case .pong:
            print("pong reçus")
        case .updatedTeam(let team):
            sendUpdatedTeam(team: team)
        default:
            break
        }
    }
    
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
        
        mpcService.onMessage = { [weak self] data, peer in
            guard let self else { return }
            
            do {
                let message = try JSONDecoder().decode(MPCMessage.self, from: data)
                self.handle(message: message, from: peer)
            } catch {
                print("MASTER: message reçus inconnu de : \(peer.displayName)")
            }
        }
        
        print("Master start advertising")
        mpcService.startHostingIfNeeded()
        hasStartedHosting = true
    }
}
       
//MARK: sending TO Peer connected
extension MasterFlowViewModel {
    func broadcastGameAvailability() {
        mpcService.sendGameAvailability(gamesOpen)
    }
    
    func unlockBuzz() {
        isBuzzLocked = false
        currentBuzzTeam = nil
        mpcService.sendMessage(.buzzUnlock)

        // Important: met à jour l'écran public au moment où on relance/autorise les buzz
        broadcastPublicStateFromCurrentGame()
    }
    
    func sendPublicState(_ state: PublicState) {
        mpcService.sendMessage(.publicUpdate(state))
    }
    
    func broadcastPublicStateFromCurrentGame() {
        guard let game = currentBuzzGame else {
            sendPublicState(.waiting)
            return
        }
        let state = game.makePublicState()
        sendPublicState(state)
    }
}


//MARK: receiving FROM Peer connected
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

        // lock pour tout le monde + envoie le nom
        let lockPayload = BuzzLockPayload(teamID: team.id, teamName: team.name)
        mpcService.sendMessage(.buzzLock(lockPayload))
        
        // Mettre à jour l'écran public (timer figé + équipe qui a buzz)
        broadcastPublicStateFromCurrentGame()
    }
}



//MARK: functions for game Score
extension MasterFlowViewModel {
    func addPointToTeam(_ team: Team, points: Int) {
        guard let index = teams.firstIndex(of: team) else { return }
        print("addPointFunc is begin")
        teams[index].score += points
    
        print(team.name, "receive :", points, "points")
        
        mpcService.sendMessagetoOneTeam(message: .updatedTeam(teams[index]), team: teams[index])
        print("mpcService updatedTeam send to \(team.name)")
        print("addPointFunc is ending")
    }
}

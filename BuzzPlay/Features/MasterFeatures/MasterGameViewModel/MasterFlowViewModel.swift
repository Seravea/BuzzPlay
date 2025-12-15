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
    Team(name: "L'équipe"),
    Team(name: "Les Dieux")
]

//MARK: - Master Flow ViewModel

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
        if team.name == "Écran Publique" {
            mpcService.sendMessage(.publicDisplayMode(isActive: true))
        }
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
    
    func handle(message: MPCMessage, from peer: MCPeerID) {
        switch message {
        case .teamJoin(let team):
            addTeam(team)
        case .buzz(let payload):
            handleBuzzReceive(data: payload, from: peer)
        case .buyGiftRequest(let request):
            //handleGiftRequest(request)
            print("TODO: Func handle and send gift request \(request)")
        case .publicUpdate(let update):
            sendPublicState(update)
        case .pong:
            print("pong reçus")
            //TODO: Send/receive publicDisplay isActive
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
        
        
        //MARK: new MPC onMessageReceived,
        //TODO: TEST
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
       
        //TODO: Delete when newSending MPCMessage working
        /// Réception des messages (buzz, teams, etc.)
//        mpcService.onMessage = { [weak self] data, peer in
//            guard let self else { return }
//
//            //MARK: receive buzz from Browsers
//            if let buzz = try? JSONDecoder().decode(BuzzPayload.self, from: data) {
//                print("MASTER: received BUZZ from peer \(peer.displayName) (teamID: \(buzz.team.id))")
//
//                // si déjà verrouillé, on ignore les autres buzz
//                guard !self.isBuzzLocked else {
//                    print("MASTER: buzz ignored, already locked")
//                    return
//                }
//
//                // retrouver la team qui a buzzé
//                if let team = self.teams.first(where: { $0.id == buzz.team.id}) {
//                    self.currentBuzzTeam = team
//                    self.isBuzzLocked = true
//                    
//                    print("MASTER: BUZZ WON by \(team.name)")
//                    
//                    // déléguer au jeu courant (BlindTest, etc.)
//                    self.currentBuzzGame?.handleBuzz(from: team)
//
//                    // prévenir tous les iPads qu'on bloque les buzz
//                    self.mpcService.sendBuzzLock(team: team)
//                } else {
//                    print("MASTER: BUZZ from unknown teamID \(buzz.team.id)")
//                }
//
//                return
//            }
//
//            // Team complète (au moment où les équipes se connectent)
//            if let team = try? JSONDecoder().decode(Team.self, from: data) {
//                print("Master received team \(team.name) from \(peer.displayName)")
//                self.teams.append(team)
//                return
//            }
//
//            print("Master: received unknown data from \(peer.displayName)")
//        }

       
    
    
    
    
    




//MARK: sending TO Peer connected
extension MasterFlowViewModel {
    
    
    
    func broadcastGameAvailability() {
        mpcService.sendGameAvailability(gamesOpen)
    }
    
    func unlockBuzz() {
        isBuzzLocked = false
        currentBuzzTeam = nil
        mpcService.sendMessage(.buzzUnlock)
    }
    
    func sendPublicState(_ state: PublicState) {
        mpcService.sendMessage(.publicUpdate(state))
    }
    
    func broadcastPublicStateFromCurrentGame() {
        guard let game = currentBuzzGame else { return }
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

        //envoi le State de l'écran Public
        
        
        // lock pour tout le monde + envoie le nom
        let lockPayload = BuzzLockPayload(teamID: team.id, teamName: team.name)
        //envoi le lock du buzz
        mpcService.sendMessage(.buzzLock(lockPayload))
        print("buzz lock pour tout le monde")
        
        guard let game = currentBuzzGame else {
            print("no currentBuzzGame, can't send buzz result")
            return
        }
        let state = game.makePublicState()
        print("MAKE Public State ->\n \(state)")
        print("TEAM BUZZING : \(String(describing: currentBuzzTeam))")
        mpcService.sendMessage(.publicUpdate(state))
        print("public state SENT")
    }
    
    
}






//MARK: functions for game Score
extension MasterFlowViewModel {
    func addPointToTeam(_ team: Team) {
        guard let index = teams.firstIndex(of: team) else { return }
        teams[index].score += 10
    }
}



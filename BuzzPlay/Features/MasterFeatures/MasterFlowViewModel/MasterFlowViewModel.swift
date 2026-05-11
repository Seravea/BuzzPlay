//
//  MasterGameViewModel.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 14/11/2025.
//

import Foundation
import Observation
import MultipeerConnectivity

//TEST DATA  PLAYERS
var samplePlayers: [Player] = [
    Player(name: "L'équipe", teamColor: .greenGame, score: 240),
    Player(name: "L'équipe", teamColor: .blueGame, score: 240),
    Player(name: "L'équipe", teamColor: .redGame, score: 240),
    Player(name: "L'équipe", teamColor: .purpleGame, score: 240),
    Player(name: "L'équipe", teamColor: .yellowGame, score: 240),
]

//MARK: - Master Flow ViewModel

@MainActor
@Observable
final class MasterFlowViewModel {
    
    //MARK: MPC datas
    var connectedPeers: [MCPeerID] = []
    //TODO: empty Collection for TEST ON DEVICE or PRODUCTION
    var players: [Player] = []

    /// Tous les joueurs qui ont rejoint la session (ne diminue jamais, sert au statut de connexion)
    private(set) var allRegisteredPlayers: [Player] = []

    /// Nombre de joueurs actuellement connectés (hors écran public)
    var connectedPlayersCount: Int { players.filter { $0.name != "Écran Publique" }.count }
    /// Nombre total de joueurs ayant rejoint depuis le début (hors écran public)
    var totalPlayersCount: Int { allRegisteredPlayers.filter { $0.name != "Écran Publique" }.count }
    
    var mpcService: MPCService = MPCService(peerName: "Master", role: .master)
    private var hasStartedHosting = false

    //MARK: Datas for games
    var currentBuzzPlayer: Player?
    var isBuzzLocked: Bool = false
    var gameState: GameState = .lobby

    /// Nom du dernier joueur déconnecté (nil = pas d'alerte à montrer)
    var disconnectedPlayerName: String? = nil
    
    /// Liste des jeux ouverts par le maître
    var gamesOpen: [GameType] = [.score]

    /// QuizSet sélectionné par le Master dans l'écran de sélection de thème
    var selectedQuizSet: QuizSet?

    /// Jeu courant qui réagit aux buzz (BlindTest, Quiz, etc.)
    weak var currentBuzzGame: BuzzDrivenGame?

    /// Jeu actuellement actif (pour la reconnexion)
    var activeGameType: GameType? = nil
    
    
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
        self.activeGameType = .blindTest
        return vm
    }
    
    func makeQuizThemeSelectionVM() -> QuizThemeSelectionViewModel {
        QuizThemeSelectionViewModel(gameVM: self)
    }

    func makeQuizMasterVM() -> QuizMasterViewModel {
        let set = selectedQuizSet ?? QuizSamples.music2000s
        let vm = QuizMasterViewModel(gameVM: self, quizSet: set)
        self.currentBuzzGame = vm
        self.activeGameType = .quiz
        return vm
    }
    
    
    //MARK: Master's functions for Player

    func addPlayer(_ player: Player) {
        // Éviter les doublons si le player envoie playerJoin plusieurs fois dans la même session
        guard !players.contains(where: { $0.name == player.name }) else { return }

        if let savedIndex = allRegisteredPlayers.firstIndex(where: { $0.name == player.name }) {
            // Reconnexion : restaurer le score sauvegardé (le nom est la clé — l'UUID peut changer)
            var restored = player
            restored.score = allRegisteredPlayers[savedIndex].score
            restored.accountAmount = allRegisteredPlayers[savedIndex].accountAmount
            // Mettre à jour l'UUID dans allRegisteredPlayers pour rester en sync
            allRegisteredPlayers[savedIndex] = restored
            players.append(restored)
            mpcService.sendMessagetoOnePlayer(message: .updatedPlayer(restored), player: restored)
            mpcService.sendMessagetoOnePlayer(message: .gameAvailability(gamesOpen), player: restored)
            // Resync état courant du jeu si une partie est en cours
            if currentBuzzGame != nil {
                mpcService.sendMessagetoOnePlayer(message: .publicUpdate(currentPublicState()), player: restored)
            }
            if let gameType = activeGameType, currentBuzzGame != nil {
                mpcService.sendMessagetoOnePlayer(message: .masterLaunchedGame(gameType), player: restored)
            }
        } else {
            // Nouveau player
            players.append(player)
            allRegisteredPlayers.append(player)
            mpcService.sendMessagetoOnePlayer(message: .gameAvailability(gamesOpen), player: player)
        }
    }

    func sendUpdatedPlayer(player: Player) {
        mpcService.sendMessagetoOnePlayer(message: .updatedPlayer(player), player: player)
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
        case .playerJoin(let player):
            addPlayer(player)
        case .buzz(let payload):
            handleBuzzReceive(data: payload, from: peer)
        case .buyGiftRequest(let request):
            Logger.debug("TODO: Func handle and send gift request \(request)", category: "MASTER")
        case .publicUpdate(let update):
            sendPublicState(update)
        case .pong:
            Logger.debug("pong reçus", category: "MASTER")
        case .updatedPlayer(let player):
            sendUpdatedPlayer(player: player)
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
            let name = peer.displayName
            self.players.removeAll { $0.name == name }
            if name != "Écran Publique" {
                self.disconnectedPlayerName = name
            }
        }
        
        mpcService.onMessage = { [weak self] data, peer in
            guard let self else { return }
            
            do {
                let message = try JSONDecoder().decode(MPCMessage.self, from: data)
                self.handle(message: message, from: peer)
            } catch {
                Logger.error("message reçus inconnu de : \(peer.displayName)", category: "MASTER")
            }
        }

        Logger.debug("Master start advertising", category: "MASTER")
        mpcService.startHostingIfNeeded()
        hasStartedHosting = true
    }
}
       
//MARK: sending TO Peer connected
extension MasterFlowViewModel {
    func broadcastGameAvailability() {
        mpcService.sendGameAvailability(gamesOpen)
    }

    func broadcastGameLaunch(_ game: GameType) {
        mpcService.sendMessage(.masterLaunchedGame(game))
    }
    
    func unlockBuzz() {
        isBuzzLocked = false
        currentBuzzPlayer = nil
        mpcService.sendMessage(.buzzUnlock)

        // Important: met à jour l'écran public au moment où on relance/autorise les buzz
        broadcastPublicStateFromCurrentGame()
    }
    
    func sendPublicState(_ state: PublicState) {
        mpcService.sendMessage(.publicUpdate(state))
    }

    func broadcastPublicStateFromCurrentGame() {
        sendPublicState(currentPublicState())
    }

    private func currentPublicState() -> PublicState {
        guard let game = currentBuzzGame else { return .waiting }
        return game.makePublicState()
    }
}


//MARK: receiving FROM Peer connected
extension MasterFlowViewModel {
    func handleBuzzReceive(data: BuzzPayload, from peer: MCPeerID) {
        guard !isBuzzLocked else {
            Logger.debug("buzz ignoré car déjà locké", category: "MASTER")
            return
        }

        guard let player = players.first(where: { $0.id == data.playerID }) else {
            Logger.error("buzz reçu mais player introuvable", category: "MASTER")
            return
        }

        currentBuzzPlayer = player
        isBuzzLocked = true

        currentBuzzGame?.handleBuzz(from: player)

        // lock pour tout le monde + envoie le nom
        let lockPayload = BuzzLockPayload(playerID: player.id, playerName: player.name)
        mpcService.sendMessage(.buzzLock(lockPayload))

        // Mettre à jour l'écran public (timer figé + joueur qui a buzz)
        broadcastPublicStateFromCurrentGame()
    }
}



//MARK: functions for game Score
extension MasterFlowViewModel {
    func addPointToPlayer(_ player: Player, points: Int) {
        guard let index = players.firstIndex(of: player) else { return }
        players[index].score += points

        // Sync allRegisteredPlayers pour conserver le score en cas de déconnexion
        if let savedIndex = allRegisteredPlayers.firstIndex(where: { $0.name == player.name }) {
            allRegisteredPlayers[savedIndex].score = players[index].score
        }

        mpcService.sendMessagetoOnePlayer(message: .updatedPlayer(players[index]), player: players[index])
    }
}

//
//  MasterGameViewModel.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 14/11/2025.
//

import Foundation
import Observation
import MultipeerConnectivity


// MARK: - Game Config Enums

enum GameDuration: CaseIterable {
    case rapide, normale, longue

    var rounds: Int {
        switch self { case .rapide: 5; case .normale: 10; case .longue: 20 }
    }
    var label: String {
        switch self { case .rapide: "Rapide"; case .normale: "Normale"; case .longue: "Longue" }
    }
    var iconName: String {
        switch self { case .rapide: "bolt.fill"; case .normale: "timer"; case .longue: "hourglass" }
    }
    var subtitle: String { "\(rounds) manches" }
}

enum GameMode: CaseIterable {
    case quiz, blindTest, mix

    var label: String {
        switch self { case .quiz: "Quiz"; case .blindTest: "Blind Test"; case .mix: "Mix" }
    }
    var iconName: String {
        switch self { case .quiz: "brain"; case .blindTest: "music.note"; case .mix: "shuffle" }
    }
}

// MARK: - Master Flow ViewModel

@MainActor
@Observable
final class MasterFlowViewModel {
    
    //MARK: MPC datas
    var connectedPeers: [MCPeerID] = []
    //TODO: empty Collection for TEST ON DEVICE or PRODUCTION
    var players: [Player] = []

    /// Tous les joueurs qui ont rejoint la session (ne diminue jamais, sert au statut de connexion)
    private(set) var allRegisteredPlayers: [Player] = []

    var connectedPlayersCount: Int { players.filter { $0.name != "Écran Publique" }.count }
    var totalPlayersCount: Int { allRegisteredPlayers.filter { $0.name != "Écran Publique" }.count }

    /// Noms des joueurs ayant confirmé leur présence sur le buzzer.
    private(set) var readyPlayers: Set<String> = []

    /// Vrai dès que tous les joueurs connectés ont envoyé playerReady.
    var allPlayersReady: Bool {
        let game = players.filter { $0.name != "Écran Publique" }
        guard !game.isEmpty else { return false }
        return game.allSatisfy { readyPlayers.contains($0.name) }
    }
    
    var mpcService: MPCService = MPCService(peerName: "Master", role: .master)
    private var hasStartedHosting = false

    //MARK: Datas for games
    var currentBuzzPlayer: Player?
    private static let notesBalanceKey = "buzzplay.master.notesBalance"
    var masterNotesBalance: Int = {
        let saved = UserDefaults.standard.integer(forKey: notesBalanceKey)
        return saved > 0 ? saved : 1000
    }() {
        didSet { UserDefaults.standard.set(masterNotesBalance, forKey: Self.notesBalanceKey) }
    }
    var isBuzzLocked: Bool = false
    var gameState: GameState = .lobby

    /// Nom du dernier joueur déconnecté (nil = pas d'alerte à montrer)
    var disconnectedPlayerName: String? = nil

    /// true quand tous les joueurs sont déconnectés pendant une partie active
    var isGamePaused: Bool = false
    
    /// QuizSet sélectionné par le Master dans l'écran de sélection de thème.
    /// Changer de set invalide le VM Quiz mis en cache.
    var selectedQuizSet: QuizSet? {
        didSet {
            if selectedQuizSet?.id != oldValue?.id {
                cachedQuizMasterVM = nil
            }
        }
    }

    // MARK: Game Config (set from Lobby)
    var gameDuration: GameDuration = .normale
    var gameMode: GameMode = .quiz
    var quizRoundsPlayed: Int = 0
    var blindTestRoundsPlayed: Int = 0

    var totalRounds: Int { gameDuration.rounds }
    var currentRound: Int { quizRoundsPlayed + blindTestRoundsPlayed }

    var quizRoundsTotal: Int {
        switch gameMode {
        case .quiz: return totalRounds
        case .blindTest: return 0
        case .mix: return totalRounds / 2
        }
    }
    var blindTestRoundsTotal: Int {
        switch gameMode {
        case .quiz: return 0
        case .blindTest: return totalRounds
        case .mix: return totalRounds - quizRoundsTotal
        }
    }
    var isQuizAvailable: Bool { quizRoundsPlayed < quizRoundsTotal }
    var isBlindTestAvailable: Bool { blindTestRoundsPlayed < blindTestRoundsTotal }
    var isGameComplete: Bool { quizRoundsPlayed >= quizRoundsTotal && blindTestRoundsPlayed >= blindTestRoundsTotal }

    func finishGameSection(_ gameType: GameType) {
        switch gameType {
        case .quiz: quizRoundsPlayed = quizRoundsTotal
        case .blindTest: blindTestRoundsPlayed = blindTestRoundsTotal
        default: break
        }
        mpcService.sendMessage(.masterLaunchedGame(.score))
        if isGameComplete {
            mpcService.sendMessage(.masterGameComplete)
        }
    }

    func startParty() {
        mpcService.sendMessage(.masterStartedParty)
    }

    /// Jeu courant qui réagit aux buzz (BlindTest, Quiz, etc.)
    weak var currentBuzzGame: BuzzDrivenGame?

    /// Jeu actuellement actif (pour la reconnexion)
    var activeGameType: GameType? = nil

    // VMs mis en cache pour préserver l'état (questions passées, musiques jouées)
    // quand le Master navigue en arrière et revient en cours de partie.
    private var cachedQuizMasterVM: QuizMasterViewModel?
    private var cachedBlindTestMasterVM: BlindTestMasterViewModel?

    //MARK: Master's makeVM

    func makeLobbyViewModel() -> MasterLobbyViewModel {
        MasterLobbyViewModel(gameVM: self)
    }

    func makeChooseGameVM() -> MasterChooseGameViewModel {
        MasterChooseGameViewModel(gameVM: self)
    }

    func makeBlindTestMasterVM() -> BlindTestMasterViewModel {
        if let cached = cachedBlindTestMasterVM {
            self.currentBuzzGame = cached
            self.activeGameType = .blindTest
            return cached
        }
        let vm = BlindTestMasterViewModel(gameVM: self)
        self.currentBuzzGame = vm
        self.activeGameType = .blindTest
        cachedBlindTestMasterVM = vm
        return vm
    }

    func makeQuizThemeSelectionVM() -> QuizThemeSelectionViewModel {
        QuizThemeSelectionViewModel(gameVM: self)
    }

    func makeQuizMasterVM() -> QuizMasterViewModel {
        let set = selectedQuizSet ?? QuizSamples.music2000s
        // Réutilise le VM existant si le même set est toujours sélectionné
        if let cached = cachedQuizMasterVM, cached.quizSet.id == set.id {
            self.currentBuzzGame = cached
            self.activeGameType = .quiz
            return cached
        }
        let vm = QuizMasterViewModel(gameVM: self, quizSet: set)
        self.currentBuzzGame = vm
        self.activeGameType = .quiz
        cachedQuizMasterVM = vm
        return vm
    }

    /// Remet à zéro les VMs mis en cache (à appeler pour une nouvelle partie).
    func resetGameVMs() {
        cachedQuizMasterVM = nil
        cachedBlindTestMasterVM = nil
        quizRoundsPlayed = 0
        blindTestRoundsPlayed = 0
        currentBuzzGame = nil
        activeGameType = nil
    }

    /// Nouvelle partie sans déconnecter les joueurs.
    /// Remet les scores à 0, reset les VMs, notifie tous les players.
    func resetForNewGame() {
        // Reset scores dans les deux tableaux
        for i in players.indices { players[i].score = 0 }
        for i in allRegisteredPlayers.indices { allRegisteredPlayers[i].score = 0 }
        selectedQuizSet = nil
        gameDuration = .normale
        gameMode = .quiz
        resetGameVMs()
        isGamePaused = false
        disconnectedPlayerName = nil
        // Envoie le score remis à 0 à chaque player encore connecté
        for player in players {
            mpcService.sendMessagetoOnePlayer(message: .updatedPlayer(player), player: player)
        }
        mpcService.sendMessage(.masterResetGame)
    }
    
    
    //MARK: Master's functions for Player

    func addPlayer(_ player: Player) {
        // Éviter les doublons si le player envoie playerJoin plusieurs fois dans la même session
        guard !players.contains(where: { $0.name == player.name }) else { return }
        isGamePaused = false

        if let savedIndex = allRegisteredPlayers.firstIndex(where: { $0.name == player.name }) {
            // Reconnexion : restaurer le score sauvegardé (le nom est la clé — l'UUID peut changer)
            var restored = player
            restored.score = allRegisteredPlayers[savedIndex].score
            restored.accountAmount = allRegisteredPlayers[savedIndex].accountAmount
            allRegisteredPlayers[savedIndex] = restored
            players.append(restored)
            mpcService.sendMessagetoOnePlayer(message: .updatedPlayer(restored), player: restored)
            // B2 : envoyer tous les joueurs connus pour remplir knownPlayers côté Player reconnecté
            for existingPlayer in players where existingPlayer.id != restored.id {
                mpcService.sendMessagetoOnePlayer(message: .updatedPlayer(existingPlayer), player: restored)
            }
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
        case .playerReady:
            let name = peer.displayName
            readyPlayers.insert(name)
            print("MASTER: \(name) est prêt sur son buzzer (\(readyPlayers.count)/\(connectedPlayersCount))")
        case .buzz(let payload):
            handleBuzzReceive(data: payload, from: peer)
        case .buyGiftRequest(let payload):
            handleGiftPurchase(payload, from: peer)
        case .publicUpdate(let update):
            sendPublicState(update)
        case .pong:
            print("pong reçus")
        case .updatedPlayer(let player):
            sendUpdatedPlayer(player: player)
        default:
            break
        }
    }
    
    func setupMPC() {
        // MPCService dispatche déjà sur main — Task @MainActor pour garantir l'isolation.
        mpcService.onPeerConnected = { [weak self] peer in
            Task { @MainActor [weak self] in
                self?.connectedPeers.append(peer)
            }
        }

        mpcService.onPeerDisconnected = { [weak self] peer in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.connectedPeers.removeAll { $0 == peer }
                let name = peer.displayName
                self.players.removeAll { $0.name == name }
                self.readyPlayers.remove(name)
                guard name != "Écran Publique" else { return }
                self.disconnectedPlayerName = name
                // Pause si plus aucun joueur pendant une partie active
                if self.activeGameType != nil && self.connectedPlayersCount == 0 {
                    self.isGamePaused = true
                }
            }
        }

        mpcService.onMessage = { [weak self] data, peer in
            Task { @MainActor [weak self] in
                guard let self else { return }
                do {
                    let message = try JSONDecoder().decode(MPCMessage.self, from: data)
                    self.handle(message: message, from: peer)
                } catch {
                    print("MASTER: message reçus inconnu de : \(peer.displayName)")
                }
            }
        }
        
        print("Master start advertising")
        mpcService.startHostingIfNeeded()
        hasStartedHosting = true
    }
}
       
//MARK: sending TO Peer connected
extension MasterFlowViewModel {
    func broadcastGameLaunch(_ game: GameType) {
        readyPlayers.removeAll()  // players devront re-confirmer leur présence sur le nouveau buzzer
        mpcService.sendMessage(.masterLaunchedGame(game))
    }
    
    func unlockBuzz() {
        isBuzzLocked = false
        currentBuzzPlayer = nil

        // Reset du blocage buzzer (single-use, se remet à 0 à chaque nouvelle manche)
        for i in players.indices where players[i].blockedFromBuzzing {
            players[i].blockedFromBuzzing = false
            mpcService.sendMessage(.updatedPlayer(players[i]))
        }

        mpcService.sendMessage(.buzzUnlock)
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
            print("MASTER: buzz ignoré car déjà locké")
            return
        }

        guard let player = players.first(where: { $0.id == data.playerID }) else {
            print("MASTER: buzz reçu mais player introuvable")
            return
        }

        guard !player.blockedFromBuzzing else {
            print("MASTER: buzz ignoré — \(player.name) est bloqué par un cadeau")
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

        mpcService.sendMessage(.updatedPlayer(players[index]))
    }
}

//MARK: Player coin/money management
extension MasterFlowViewModel {
    func addCoinsToPlayer(_ player: Player, amount: Int) {
        guard let index = players.firstIndex(of: player) else { return }
        players[index].accountAmount += amount

        // Sync allRegisteredPlayers for persistence on reconnection
        if let savedIndex = allRegisteredPlayers.firstIndex(where: { $0.name == players[index].name }) {
            allRegisteredPlayers[savedIndex].accountAmount = players[index].accountAmount
        }

        // Send updated player to all peers
        mpcService.sendMessage(.updatedPlayer(players[index]))
        print("MASTER: gave \(amount) coins to \(player.name) (total: \(players[index].accountAmount))")
    }
}

//MARK: Gift purchase handling
extension MasterFlowViewModel {
    func handleGiftPurchase(_ payload: GiftRequestPayload, from peer: MCPeerID) {
        guard let player = players.first(where: { $0.name == peer.displayName }) else {
            print("MASTER: gift request from unknown player \(peer.displayName)")
            return
        }

        let gift = payload.gift
        guard player.accountAmount >= gift.price else {
            print("MASTER: player \(player.name) tried to buy \(gift.title) but has insufficient coins (\(player.accountAmount) < \(gift.price))")
            return
        }

        guard let playerIndex = players.firstIndex(of: player) else { return }
        players[playerIndex].accountAmount -= gift.price

        activateGiftEffect(payload, for: players[playerIndex])

        mpcService.sendMessage(.updatedPlayer(players[playerIndex]))
        mpcService.sendMessagetoOnePlayer(message: .buyGiftResult(gift), player: players[playerIndex])

        if let savedIndex = allRegisteredPlayers.firstIndex(where: { $0.name == players[playerIndex].name }) {
            allRegisteredPlayers[savedIndex].accountAmount = players[playerIndex].accountAmount
        }

        print("MASTER: \(player.name) bought \(gift.title) for \(gift.price) coins")
    }

    private func activateGiftEffect(_ payload: GiftRequestPayload, for buyer: Player) {
        let gift = payload.gift
        switch gift {
        case .scoreDoubled:
            currentBuzzGame?.applyGiftEffect(.scoreDoubled, to: buyer)

        case .enemyCanNotBuzz:
            guard let targetID = payload.targetPlayerID,
                  let targetIndex = players.firstIndex(where: { $0.id == targetID }) else {
                print("MASTER: enemyCanNotBuzz missing target")
                return
            }
            // Bouclier shieldSingle : annule le blocage et se consomme
            if players[targetIndex].hasShieldSingle {
                players[targetIndex].hasShieldSingle = false
                print("MASTER: \(players[targetIndex].name) bouclier shieldSingle activé — blocage annulé")
            } else {
                players[targetIndex].blockedFromBuzzing = true
            }
            mpcService.sendMessage(.updatedPlayer(players[targetIndex]))

        case .allEnemiesCanNotBuzz:
            for i in players.indices where players[i].id != buyer.id {
                // Bouclier shieldAll : ce joueur est exempté du blocage
                if players[i].hasShieldAll {
                    players[i].hasShieldAll = false
                    print("MASTER: \(players[i].name) bouclier shieldAll activé — blocage annulé")
                } else {
                    players[i].blockedFromBuzzing = true
                }
                mpcService.sendMessage(.updatedPlayer(players[i]))
            }

        case .shieldSingle:
            guard let idx = players.firstIndex(where: { $0.id == buyer.id }) else { return }
            players[idx].hasShieldSingle = true
            mpcService.sendMessage(.updatedPlayer(players[idx]))
            print("MASTER: \(players[idx].name) a acheté shieldSingle")

        case .shieldAll:
            guard let idx = players.firstIndex(where: { $0.id == buyer.id }) else { return }
            players[idx].hasShieldAll = true
            mpcService.sendMessage(.updatedPlayer(players[idx]))
            print("MASTER: \(players[idx].name) a acheté shieldAll")

        case .showIndicies:
            currentBuzzGame?.applyGiftEffect(.showIndicies, to: buyer)

        case .changeBuzzColor:
            guard let idx = players.firstIndex(where: { $0.id == buyer.id }) else { return }
            let colors = GameColor.allCases.filter { $0 != players[idx].teamColor }
            players[idx].customBuzzColor = colors.randomElement()
            mpcService.sendMessage(.updatedPlayer(players[idx]))

        case .changeBuzzSound:
            guard let idx = players.firstIndex(where: { $0.id == buyer.id }) else { return }
            // Utilise le son choisi par le Player, ou random si non fourni
            players[idx].customBuzzSound = payload.selectedSound ?? buzzSoundNames.randomElement()
            mpcService.sendMessage(.updatedPlayer(players[idx]))
        }
    }
}

//
//  MasterGameViewModel.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 14/11/2025.
//

import Foundation
import Observation
import MultipeerConnectivity
import UIKit
import AVFoundation


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

    /// #E1 garde-fou — Vrai seulement si TOUS les joueurs enregistrés sont à la fois
    /// connectés ET prêts sur le buzzer. Empêche de lancer une manche pendant qu'un
    /// joueur est en train de se reconnecter (sinon il rate la manche).
    var allPlayersReady: Bool {
        let registered = allRegisteredPlayers.filter { $0.name != "Écran Publique" }
        guard !registered.isEmpty else { return false }
        return registered.allSatisfy { reg in
            players.contains(where: { $0.name == reg.name }) && readyPlayers.contains(reg.name)
        }
    }

    /// Nombre de joueurs prêts (connectés + ready), pour l'affichage "X/Y prêts".
    var readyAndConnectedCount: Int {
        allRegisteredPlayers.filter { reg in
            reg.name != "Écran Publique"
            && players.contains(where: { $0.name == reg.name })
            && readyPlayers.contains(reg.name)
        }.count
    }

    /// Retire définitivement un joueur déconnecté (a quitté pour de bon) pour
    /// débloquer le garde-fou #E1 et permettre de relancer une manche.
    func forgetDisconnectedPlayer(_ name: String) {
        allRegisteredPlayers.removeAll { $0.name == name }
        players.removeAll { $0.name == name }
        readyPlayers.remove(name)
        if disconnectedPlayerName == name { disconnectedPlayerName = nil }
        // Hygiène : purger aussi l'état heartbeat/reco du joueur retiré définitivement.
        lastSeen.removeValue(forKey: name)
        lastRejoinRequest.removeValue(forKey: name)
        disconnectDebounce[name]?.cancel()
        disconnectDebounce.removeValue(forKey: name)
    }
    
    var mpcService: MPCService = MPCService(peerName: MPCService.masterPeerName, role: .master)
    private var hasStartedHosting = false
    // #C3 — debounce pour éviter de traiter des déconnexions transitoires (reconnexion rapide)
    private var disconnectDebounce: [String: Task<Void, Never>] = [:]
    // #pause-reco — debounce des demandes de re-join (auto-heal zombie), par nom de joueur
    private var lastRejoinRequest: [String: Date] = [:]

    // MARK: - Heartbeat (détection fiable des déconnexions, même quand MPC ne signale rien)
    private var heartbeatTimer: Timer?
    private var lastSeen: [String: Date] = [:]
    private static let heartbeatInterval: TimeInterval = 2   // fréquence des pings
    private static let heartbeatTimeout: TimeInterval = 6    // sans réponse → déconnecté

    //MARK: Datas for games
    var currentBuzzPlayer: Player?
    private static let notesBalanceKey        = "buzzplay.master.notesBalance"
    private static let firstInstallBonusKey   = "buzzplay.master.firstInstallBonusClaimed"
    private static let lastDailyClaimKey      = "buzzplay.master.lastDailyClaimDate"
    private static let firstInstallBonus      = 50
    private static let dailyPackAmount        = 50
    private static let dailyPackMaxDays       = 7

    var masterNotesBalance: Int = {
        let saved = UserDefaults.standard.integer(forKey: notesBalanceKey)
        return saved > 0 ? saved : 0
    }() {
        didSet { UserDefaults.standard.set(masterNotesBalance, forKey: Self.notesBalanceKey) }
    }

    /// Nombre de jours accumulés non réclamés (max 7). 0 = déjà réclamé aujourd'hui.
    var pendingDailyPackDays: Int {
        let ud = UserDefaults.standard
        guard let last = ud.object(forKey: Self.lastDailyClaimKey) as? Date else { return 1 }
        let cal = Calendar.current
        let days = cal.dateComponents([.day], from: cal.startOfDay(for: last), to: cal.startOfDay(for: Date())).day ?? 0
        return min(max(days, 0), Self.dailyPackMaxDays)
    }

    var canClaimDailyPack: Bool { pendingDailyPackDays > 0 }
    var pendingDailyAmount: Int { pendingDailyPackDays * Self.dailyPackAmount }
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

    /// Vrai dès que le Master a quitté le lobby pour le hub de jeux.
    /// Sert à re-notifier un joueur qui (re)joint après le broadcast initial (#rejoin).
    private(set) var hasPartyStarted = false

    func startParty() {
        hasPartyStarted = true
        mpcService.sendMessage(.masterStartedParty)
    }

    // MARK: - Notes bonuses

    /// Notes récupérées lors de la dernière fin de partie (pour affichage dans ScoreMasterView)
    private(set) var notesRecoveredThisSession: Int = 0

    /// Récupère les Notes non-dépensées de tous les Players et les recrédite au Master.
    /// À appeler une seule fois à l'apparition de ScoreMasterView.
    func collectUnspentNotes() {
        let total = players.reduce(0) { $0 + $1.accountAmount }
        guard total > 0 else { notesRecoveredThisSession = 0; return }
        masterNotesBalance += total
        notesRecoveredThisSession = total
        for i in players.indices { players[i].accountAmount = 0 }
        for i in allRegisteredPlayers.indices { allRegisteredPlayers[i].accountAmount = 0 }
        for player in players {
            mpcService.sendMessagetoOnePlayer(message: .updatedPlayer(player), player: player)
        }
    }

    func applyFirstInstallBonusIfNeeded() {
        let ud = UserDefaults.standard
        guard !ud.bool(forKey: Self.firstInstallBonusKey) else { return }
        masterNotesBalance += Self.firstInstallBonus
        ud.set(true, forKey: Self.firstInstallBonusKey)
    }

    func claimDailyPack() {
        let days = pendingDailyPackDays
        guard days > 0 else { return }
        masterNotesBalance += days * Self.dailyPackAmount
        UserDefaults.standard.set(Date(), forKey: Self.lastDailyClaimKey)
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
        // #C4/#B7 — vider les ready pour que les Players re-confirment sur le prochain buzzer
        readyPlayers.removeAll()
        resetGameVMs()
        isGamePaused = false
        disconnectedPlayerName = nil
        // #C9 — diffuse la liste remise à 0 à TOUS en un message : chaque Player reset
        // ainsi son propre score ET le classement complet (knownPlayers), pas seulement
        // sa propre ligne (avant : 1 updatedPlayer perso → les autres restaient périmés).
        broadcastFullRoster()
        mpcService.sendMessage(.masterResetGame)
    }
    
    
    //MARK: Master's functions for Player

    func addPlayer(_ player: Player) {
        // Éviter les doublons si le player envoie playerJoin plusieurs fois dans la même session
        guard !players.contains(where: { $0.name == player.name }) else { return }
        // #pause-reco — un (re)join réintègre un vrai joueur : lève la pause ET retire l'alerte
        // déco pour CE joueur (sinon le binding `disconnectedPlayerName != nil && !isGamePaused`
        // fait popper une fausse alerte "joueur déconnecté" sur celui qui vient de revenir).
        let wasPaused = isGamePaused
        isGamePaused = false
        if disconnectedPlayerName == player.name { disconnectedPlayerName = nil }
        lastRejoinRequest.removeValue(forKey: player.name)
        // Reprend le jeu (timer + musique) seulement s'il était en pause pour déconnexion.
        if wasPaused { currentBuzzGame?.resumeFromDisconnect() }

        if let savedIndex = allRegisteredPlayers.firstIndex(where: { $0.name == player.name }) {
            // Reconnexion : restaurer l'état sauvegardé (le nom est la clé — l'UUID peut changer)
            var restored = player
            let saved = allRegisteredPlayers[savedIndex]
            restored.score              = saved.score
            restored.accountAmount      = saved.accountAmount
            // Restaurer les pouvoirs achetés avec des Notes (valeur monétaire réelle)
            restored.hasScoreDoubled    = saved.hasScoreDoubled
            restored.hasShieldSingle    = saved.hasShieldSingle
            restored.hasShieldAll       = saved.hasShieldAll
            restored.customBuzzColor    = saved.customBuzzColor
            restored.customBuzzSound    = saved.customBuzzSound
            restored.blockedFromBuzzing  = saved.blockedFromBuzzing
            restored.blockedByPlayerName = saved.blockedByPlayerName   // #19 — garder "qui m'a bloqué"
            allRegisteredPlayers[savedIndex] = restored
            players.append(restored)
            // #T-reco1 — un joueur qui se reconnecte (savedIndex existe) était déjà sur sa
            // vue buzzer → on le re-marque prêt directement, sans dépendre d'un playerReady
            // dont le timing à la reconnexion n'est pas fiable (header 2/2 mais boutons 1/2).
            if restored.name != "Écran Publique" {
                readyPlayers.insert(restored.name)
            }
            // B2 : liste des joueurs complète (soi inclus) en UN message pour remplir
            // knownPlayers côté Player reconnecté (avant : 1 + N updatedPlayer séparés).
            mpcService.sendMessagetoOnePlayer(message: .rosterUpdate(players), player: restored)
            // #21 — reconnexion alors que la partie est terminée : router vers le classement
            // final (podium), surtout pas vers le buzzer.
            if isGameComplete {
                mpcService.sendMessagetoOnePlayer(message: .masterGameComplete, player: restored)
            } else {
                // Resync état courant du jeu si une partie est en cours
                if currentBuzzGame != nil {
                    mpcService.sendMessagetoOnePlayer(message: .publicUpdate(currentPublicState()), player: restored)
                }
                if let gameType = activeGameType, currentBuzzGame != nil {
                    mpcService.sendMessagetoOnePlayer(message: .masterLaunchedGame(gameType), player: restored)
                }
            }
        } else {
            // Nouveau player
            players.append(player)
            allRegisteredPlayers.append(player)
        }

        // #10 — diffuser le roster complet à TOUS dès qu'un joueur (re)joint : sinon le
        // classement de chacun n'affichait que les joueurs ayant déjà scoré (knownPlayers ne
        // se remplissait que sur .updatedPlayer, envoyé au moment d'un score).
        broadcastFullRoster()

        // #rejoin — re-notifier que la partie a démarré pour TOUT joueur qui (re)joint
        // après le broadcast initial (fire-and-forget depuis le Lobby). Sinon son app
        // (surtout après un kill) reste coincée sur PlayerChooseGameView, n'atteint jamais
        // le buzzer et n'envoie jamais playerReady → bloqué à "X/Y" incomplet.
        if hasPartyStarted {
            mpcService.sendMessagetoOnePlayer(message: .masterStartedParty, player: player)
        }
    }

    func sendUpdatedPlayer(player: Player) {
        mpcService.sendMessagetoOnePlayer(message: .updatedPlayer(player), player: player)
    }

    /// #10 — diffuse la liste des joueurs à tous les peers, pour que le classement
    /// (knownPlayers) de chacun soit complet dès le lobby, pas seulement après score.
    /// En UN message .rosterUpdate (avant : N × updatedPlayer = N encodages + N envois).
    private func broadcastFullRoster() {
        let roster = players.filter { $0.name != "Écran Publique" }
        guard !roster.isEmpty else { return }
        mpcService.sendMessage(.rosterUpdate(roster))
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
            // heartbeat : lastSeen déjà mis à jour dans onMessage.
            // #pause-reco — auto-heal "zombie revival" : ce peer est vivant (il vient de
            // ponger) mais a pu être retiré de `players` par le timeout heartbeat sur une
            // connexion half-open. Dans ce cas le Player ne voit jamais sa propre déco et
            // ne renvoie jamais playerJoin de lui-même → on le lui demande explicitement.
            requestRejoinIfMissing(from: peer)
        case .updatedPlayer(let player):
            sendUpdatedPlayer(player: player)
        default:
            break
        }
    }
    
    func setupMPC() {
        guard !hasStartedHosting else { return }
        applyFirstInstallBonusIfNeeded()
        // #18a/#D11 — empêcher la veille sur TOUTE la session Master (pas juste le hub).
        // La veille coupait la MCSession pendant les jeux (QuizMaster, BlindTest, Score).
        UIApplication.shared.isIdleTimerDisabled = true
        // MPCService dispatche déjà sur main — Task @MainActor pour garantir l'isolation.
        mpcService.onPeerConnected = { [weak self] peer in
            Task { @MainActor [weak self] in
                guard let self else { return }
                // #C3 — annule le debounce de déconnexion si le peer reconnecte dans la foulée
                self.disconnectDebounce[peer.displayName]?.cancel()
                self.disconnectDebounce.removeValue(forKey: peer.displayName)
                self.lastSeen[peer.displayName] = Date()   // heartbeat : signe de vie
                self.connectedPeers.append(peer)
            }
        }

        mpcService.onPeerDisconnected = { [weak self] peer in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.connectedPeers.removeAll { $0 == peer }
                let name = peer.displayName
                // #C3 — debounce court : filtre les micro-glitch réseau sans latence perceptible.
                let task = Task { @MainActor [weak self] in
                    try? await Task.sleep(for: GameRhythm.disconnectDebounce)
                    guard let self, !Task.isCancelled else { return }
                    self.handlePlayerDisconnect(name: name)
                }
                self.disconnectDebounce[name] = task
            }
        }

        mpcService.onMessage = { [weak self] data, peer in
            Task { @MainActor [weak self] in
                guard let self else { return }
                // Heartbeat : tout message reçu (dont pong) prouve que le peer est vivant.
                self.lastSeen[peer.displayName] = Date()
                do {
                    let message = try MPCService.jsonDecoder.decode(MPCMessage.self, from: data)
                    self.handle(message: message, from: peer)
                } catch {
                    print("MASTER: message reçus inconnu de : \(peer.displayName)")
                }
            }
        }

        print("Master start advertising")
        mpcService.startHostingIfNeeded()
        startHeartbeat()
        hasStartedHosting = true
    }

    /// Traite la déconnexion d'un joueur (appelé par le debounce MPC OU le timeout heartbeat).
    private func handlePlayerDisconnect(name: String) {
        disconnectDebounce[name]?.cancel()
        disconnectDebounce.removeValue(forKey: name)
        players.removeAll { $0.name == name }
        readyPlayers.remove(name)
        lastSeen.removeValue(forKey: name)
        guard name != "Écran Publique" else { return }
        disconnectedPlayerName = name
        if activeGameType != nil && connectedPlayersCount == 0 {
            isGamePaused = true
            // #pause-reco — gèle réellement le jeu (timer + musique) tant qu'il n'y a personne,
            // au lieu de laisser le timer courir en arrière-plan derrière l'overlay de pause.
            currentBuzzGame?.pauseForDisconnect()
        }
    }

    /// #pause-reco — auto-heal d'une connexion half-open : un peer encore vivant (il vient de
    /// ponger) mais ABSENT de `players` a été retiré par le timeout heartbeat alors que sa
    /// MCSession n'est jamais tombée côté Player. Le Player ne renverra donc jamais playerJoin
    /// spontanément. On le lui demande : le playerJoin repassera par `addPlayer` (réintègre le
    /// roster + readyPlayers + resync état + lève la pause), sans clear sur liveness brute.
    /// Idempotent : dès que le joueur est re-listé, le guard stoppe les demandes.
    private func requestRejoinIfMissing(from peer: MCPeerID) {
        let name = peer.displayName
        guard name != "Écran Publique", name != MPCService.masterPeerName else { return }
        guard !players.contains(where: { $0.name == name }) else { return }
        // #pause-reco — debounce : au plus une demande toutes les 3s par joueur (les pongs
        // arrivent ~toutes les 2s ; le playerJoin met un aller-retour à revenir).
        if let last = lastRejoinRequest[name], Date().timeIntervalSince(last) < 3 { return }
        lastRejoinRequest[name] = Date()
        print("MASTER: \(name) vivant (pong) mais absent du roster → demande de re-join")
        mpcService.sendMessage(.masterRequestRejoin, to: peer)
    }

    // MARK: - Heartbeat
    private func startHeartbeat() {
        heartbeatTimer?.invalidate()
        heartbeatTimer = Timer.scheduledTimer(withTimeInterval: Self.heartbeatInterval, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                guard !self.connectedPeers.isEmpty else { return }
                self.mpcService.sendMessage(.ping)
                self.checkHeartbeats()
            }
        }
    }

    // #quit-teardown — sans ça le heartbeat tournait à vie (même après "Quitter").
    func stopHeartbeat() {
        heartbeatTimer?.invalidate()
        heartbeatTimer = nil
    }

    // MARK: - Quitter (teardown propre)

    /// Le Master quitte la partie ("Quitter" sur l'écran de score). Prévient les Players,
    /// coupe le heartbeat et la session MPC, puis remet l'état à zéro pour qu'une nouvelle
    /// partie reparte proprement (sinon heartbeat dans le vide + peers fantômes + setupMPC
    /// bloqué par hasStartedHosting). Voir aussi #pause-reco / #117.
    func leaveSessionAsMaster() {
        mpcService.sendMessage(.masterLeftParty)
        stopHeartbeat()
        // Laisse le message partir avant de couper la session (sinon disconnect l'annule).
        Task { @MainActor [weak self] in
            try? await Task.sleep(for: GameRhythm.quitTeardown)
            guard let self else { return }
            self.mpcService.stopHosting()
            self.resetSessionState()
            // Libère la session audio (jamais désactivée sinon → retient le hardware audio
            // après la partie). En détaché : setActive peut bloquer sur le routing Bluetooth.
            Task.detached {
                try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            }
        }
    }

    private func resetSessionState() {
        disconnectDebounce.values.forEach { $0.cancel() }
        disconnectDebounce.removeAll()
        lastRejoinRequest.removeAll()
        lastSeen.removeAll()
        connectedPeers.removeAll()
        players.removeAll()
        allRegisteredPlayers.removeAll()
        readyPlayers.removeAll()
        isGamePaused = false
        disconnectedPlayerName = nil
        hasPartyStarted = false
        gameState = .lobby
        resetGameVMs()            // caches + rounds + currentBuzzGame + activeGameType
        hasStartedHosting = false // permet à setupMPC de réinitialiser une future partie
    }

    /// Déclare déconnecté tout joueur qui n'a pas donné signe de vie depuis le timeout,
    /// même si MPC n'a jamais signalé la déco (cas du kill app → peer zombie).
    private func checkHeartbeats() {
        let now = Date()
        let stale = players
            .filter { $0.name != "Écran Publique" }
            .filter { now.timeIntervalSince(lastSeen[$0.name] ?? now) > Self.heartbeatTimeout }
            .map(\.name)
        for name in stale {
            print("MASTER: \(name) timeout heartbeat (>\(Self.heartbeatTimeout)s) → déconnecté")
            handlePlayerDisconnect(name: name)
        }
    }
}
       
//MARK: sending TO Peer connected
extension MasterFlowViewModel {
    func broadcastGameLaunch(_ game: GameType) {
        readyPlayers.removeAll()
        mpcService.sendMessage(.masterLaunchedGame(game))
        // #E1 — retry pour les Players qui n'ont pas reçu l'invitation MPC
        Task { @MainActor [weak self] in
            try? await Task.sleep(for: GameRhythm.inviteRetry)
            guard let self else { return }
            let missing = self.players.filter {
                $0.name != "Écran Publique" && !self.readyPlayers.contains($0.name)
            }
            guard !missing.isEmpty else { return }
            print("MASTER: \(missing.count) joueur(s) n'ont pas confirmé — renvoi de l'invitation")
            for player in missing {
                self.mpcService.sendMessagetoOnePlayer(message: .masterLaunchedGame(game), player: player)
            }
        }
    }
    
    /// #20 — le buzz lock SEUL : réouverture du buzzer après un buzz (ou une invalidation
    /// de réponse). Ne touche PAS aux blocages-cadeaux (enemyCanNotBuzz) → un blocage payé
    /// reste valable tant que la question n'est pas terminée. Reset des blocages = clearGiftBlocks().
    func unlockBuzz() {
        isBuzzLocked = false
        currentBuzzPlayer = nil
        mpcService.sendBuzzUnlock()
        broadcastPublicStateFromCurrentGame()
    }

    /// #20 — réinitialise les blocages-cadeaux (enemyCanNotBuzz / allEnemiesCanNotBuzz).
    /// Appelé seulement au passage à une NOUVELLE question/morceau, pas sur une invalidation,
    /// pour que le blocage vaille pour toute la question (distinct du buzz lock).
    func clearGiftBlocks() {
        for i in players.indices where players[i].blockedFromBuzzing {
            players[i].blockedFromBuzzing = false
            players[i].blockedByPlayerName = nil
            mpcService.sendMessage(.updatedPlayer(players[i]))
            syncRegistered(players[i])   // #19 — le déblocage persiste pour la reco
        }
    }

    /// Reflète l'état courant d'un joueur dans allRegisteredPlayers (clé = nom) pour
    /// qu'il survive à une reconnexion. #19 — sans ça, un blocage (ou la consommation
    /// d'un bouclier) posé sur une cible n'était jamais persisté et se perdait à la reco.
    private func syncRegistered(_ player: Player) {
        guard let i = allRegisteredPlayers.firstIndex(where: { $0.name == player.name }) else { return }
        allRegisteredPlayers[i] = player
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
        mpcService.sendBuzzLock(player: player)

        // Mettre à jour l'écran public (timer figé + joueur qui a buzz)
        broadcastPublicStateFromCurrentGame()
    }
}



//MARK: functions for game Score
extension MasterFlowViewModel {
    func addPointToPlayer(_ player: Player, points: Int, consumeScoreDouble: Bool = false) {
        guard let index = players.firstIndex(of: player) else { return }
        players[index].score += points
        if consumeScoreDouble {
            players[index].hasScoreDoubled = false
        }

        // Sync allRegisteredPlayers pour conserver le score en cas de déconnexion
        if let savedIndex = allRegisteredPlayers.firstIndex(where: { $0.name == player.name }) {
            allRegisteredPlayers[savedIndex].score = players[index].score
            if consumeScoreDouble { allRegisteredPlayers[savedIndex].hasScoreDoubled = false }
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

        // scoreDoubled est tracké via doubledScorePlayers (UUID) dans les BuzzGame VMs,
        // mais hasScoreDoubled sur le Player permet l'affichage du badge en boutique.
        if gift == .scoreDoubled {
            players[playerIndex].hasScoreDoubled = true
        }

        mpcService.sendMessage(.updatedPlayer(players[playerIndex]))
        mpcService.sendMessagetoOnePlayer(message: .buyGiftResult(gift), player: players[playerIndex])

        // Sync l'état complet (pas seulement accountAmount) pour la reconnexion
        if let savedIndex = allRegisteredPlayers.firstIndex(where: { $0.name == players[playerIndex].name }) {
            allRegisteredPlayers[savedIndex] = players[playerIndex]
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
                players[targetIndex].blockedByPlayerName = nil
                print("MASTER: \(players[targetIndex].name) bouclier shieldSingle activé — blocage annulé")
            } else {
                players[targetIndex].blockedFromBuzzing = true
                players[targetIndex].blockedByPlayerName = buyer.name
            }
            mpcService.sendMessage(.updatedPlayer(players[targetIndex]))
            syncRegistered(players[targetIndex])   // #19 — blocage/bouclier persistés pour la reco

        case .allEnemiesCanNotBuzz:
            for i in players.indices where players[i].id != buyer.id {
                // Bouclier shieldAll : ce joueur est exempté du blocage
                if players[i].hasShieldAll {
                    players[i].hasShieldAll = false
                    players[i].blockedByPlayerName = nil
                    print("MASTER: \(players[i].name) bouclier shieldAll activé — blocage annulé")
                } else {
                    players[i].blockedFromBuzzing = true
                    players[i].blockedByPlayerName = buyer.name
                }
                mpcService.sendMessage(.updatedPlayer(players[i]))
                syncRegistered(players[i])   // #19 — blocage/bouclier persistés pour la reco
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

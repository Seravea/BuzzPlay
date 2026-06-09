//
//  TeamViewModem.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 13/11/2025.
//

import Foundation
import Observation


@MainActor
@Observable
final class PlayerGameViewModel {

    var player: Player
    var mpc: MPCService
    var currentBuzzerVM: BuzzerViewModel?

    var hasStartedBrowsing = false
    var hasSetupMPC = false
    var didSentPlayer = false
    var isConnectedToMaster = false
    /// true dès qu'on s'est connecté au moins une fois — distingue "jamais connecté" de "déconnecté"
    var hasEverConnectedToMaster = false

    var receivedMessage: String = ""
    var publicState: PublicState = .waiting
    var knownPlayers: [Player] = []  // tous les joueurs connus (soi inclus)

    // Invite reçue du Master (jeu qu'il vient de lancer)
    var pendingGameInvite: GameType? = nil

    // Navigation : le Master a lancé la partie → aller dans PlayerGameView
    var hasPartyStarted: Bool = false

    // Fin de partie complète → afficher le podium final
    var isGameComplete: Bool = false

    // Master a lancé une nouvelle partie → retourner au lobby player
    var shouldReturnToLobby: Bool = false
    // Notification brève avant redirection (#B6)
    var showNewGameNotification: Bool = false

    // Toast Notes reçues (🎵) — auto-dismiss géré dans la vue
    var pendingNotesToast: Int? = nil

    // MARK: - Classement post-manche (après bonne réponse validée)
    var showPostRoundLeaderboard: Bool = false
    var previousRanking: [Player] = []
    private var lastAnswerWasCorrect: Bool = false
    private var leaderboardTask: Task<Void, Never>?

    // MARK: - Public display timer mirroring
    var formattedTime: String = "00:00"
    private var timer: Timer?
    private var lastMasterFormattedTime: String = "00:00"
    // Masque le timer jusqu'au 1er .timerStarted pour éviter le drift sur la 1re question (#A4)
    var hasReceivedFirstTimer: Bool = false

    // MARK: - Reconnect auto
    private var reconnectTimer: Timer?

    init(player: Player, mpc: MPCService) {
        self.player = player
        self.mpc = mpc
        setupMPC()
    }
}



//MARK: MPC Browsing functions
extension PlayerGameViewModel {
    private func setupMPC() {
        guard !hasSetupMPC else { return }
        hasSetupMPC = true

        mpc.onPeerConnected = { [weak self] peer in
            Task { @MainActor [weak self] in
                guard let self else { return }
                // #7b — en MCSession (maillage), un Player est connecté au Master ET aux
                // autres Players. On ne réagit qu'aux événements du MASTER : sinon la
                // connexion/déconnexion d'un autre Player flippe à tort isConnectedToMaster.
                guard peer.displayName == MPCService.masterPeerName else { return }
                // Distingue une RE-connexion d'un 1er connect : au 1er connect c'est le
                // .task de BuzzerPlayerView qui envoie playerReady (après que la vue soit
                // visible — évite #A5). À la reco, la vue est déjà à l'écran → on renvoie ici.
                let isReconnect = self.hasEverConnectedToMaster
                self.isConnectedToMaster = true
                self.hasEverConnectedToMaster = true
                self.stopReconnectTimer()
                guard !self.didSentPlayer else { return }
                self.didSentPlayer = true
                self.mpc.sendMessage(.playerJoin(self.player))
                // #T-reco1/#C7 — à toute reconnexion (hub OU partie en cours), renvoyer
                // playerReady pour réintégrer readyPlayers côté Master (sinon "1/2" bloqué).
                if isReconnect {
                    try? await Task.sleep(for: .milliseconds(500))
                    guard !Task.isCancelled else { return }
                    self.mpc.sendMessage(.playerReady)
                }
            }
        }

        mpc.onPeerDisconnected = { [weak self] peer in
            Task { @MainActor [weak self] in
                guard let self else { return }
                // #7b — ignorer la déconnexion d'un autre Player ; seul le Master compte.
                guard peer.displayName == MPCService.masterPeerName else { return }
                self.isConnectedToMaster = false
                self.didSentPlayer = false
                self.startReconnectTimer()
            }
        }

        mpc.onMessage = { [weak self] data, peer in
            Task { @MainActor [weak self] in
                guard let self else { return }
                do {
                    let message = try JSONDecoder().decode(MPCMessage.self, from: data)
                    self.handleMessage(message)
                } catch {
                    print("Message received but unknown in MPCMessage: \(error)")
                }
            }
        }

    }


    func startBrowsing() {
        guard !hasStartedBrowsing else { return }
        hasStartedBrowsing = true
        print("PLAYER Starting MPC browsing...")
        mpc.startBrowsingIfNeeded()
        // #C1 — watchdog : relance le scan toutes les 6s si connexion non établie
        // (couvre les invitations expirées sans callback onPeerConnected)
        startReconnectTimer()
    }

}






//MARK: receive Message from Master
extension PlayerGameViewModel {
    func handleMessage(_ message: MPCMessage) {
        switch message {
        case .publicUpdate(let state):
            publicState = state
            handlePublicStateChange(state)

        case .buzzLock(let payload):
            currentBuzzerVM?.lockBuzz(teamNameHasBuzz: payload.playerName)

        case .buzzUnlock:
            // Resume timer if it was paused (e.g., after rejected answer in Quiz)
            resumeUITimerIfNeeded()
            currentBuzzerVM?.unLockBuzz()

        case .updatedPlayer(let updatedPlayer):
            if updatedPlayer.id == self.player.id {
                let delta = updatedPlayer.accountAmount - self.player.accountAmount
                if delta > 0 { pendingNotesToast = delta }
                let wasBlocked = self.player.blockedFromBuzzing
                self.player = updatedPlayer
                currentBuzzerVM?.player = updatedPlayer
                // #C5 — gift block séparé du buzz lock global pour permettre le unlock correct
                if updatedPlayer.blockedFromBuzzing {
                    currentBuzzerVM?.setGiftBlock(true)
                } else if wasBlocked {
                    currentBuzzerVM?.setGiftBlock(false)
                }
            }
            if let idx = knownPlayers.firstIndex(where: { $0.id == updatedPlayer.id }) {
                knownPlayers[idx] = updatedPlayer
            } else {
                knownPlayers.append(updatedPlayer)
            }
        case .masterLaunchedGame(let game):
            pendingGameInvite = game
            hasPartyStarted = true  // reconnexion après kill app : la partie est déjà lancée
            hasReceivedFirstTimer = false  // reset pour chaque nouveau jeu (#A4)
            if game == .score {
                leaderboardTask?.cancel()
                showPostRoundLeaderboard = false
            }

        case .masterStartedParty:
            hasPartyStarted = true

        case .masterGameComplete:
            // #C6 — cancel le leaderboard avant le podium pour éviter le flash
            leaderboardTask?.cancel()
            showPostRoundLeaderboard = false
            isGameComplete = true

        case .masterResetGame:
            isGameComplete = false
            hasPartyStarted = false
            pendingGameInvite = nil
            publicState = .waiting
            currentBuzzerVM = nil
            showPostRoundLeaderboard = false
            leaderboardTask?.cancel()
            // Affiche notification brève avant redirection (#B6)
            showNewGameNotification = true
            Task { @MainActor [weak self] in
                try? await Task.sleep(for: .seconds(2))
                self?.showNewGameNotification = false
                self?.shouldReturnToLobby = true
            }

        case .timerStarted(let payload):
            hasReceivedFirstTimer = true
            startLocalReactionTimer(masterTimestamp: payload.masterTimestamp)

        case .answerResult(let payload):
            if payload.isCorrect {
                previousRanking = knownPlayers  // snapshot avant la mise à jour du score
                lastAnswerWasCorrect = true
                let isSelf = currentBuzzerVM?.playerNameHasBuzz == player.name
                let result: AnswerResult = isSelf
                    ? .correct(points: payload.points, answer: payload.correctAnswer)
                    : .otherCorrect(
                        playerName: currentBuzzerVM?.playerNameHasBuzz ?? "Un joueur",
                        points: payload.points,
                        answer: payload.correctAnswer
                      )
                currentBuzzerVM?.showAnswerResult(result)
            } else {
                lastAnswerWasCorrect = false
                currentBuzzerVM?.showAnswerResult(.incorrect)
            }

        case .buyGiftResult(let gift):
            print("PLAYER: received gift purchase confirmation for \(gift.title)")

        case .hintRevealedToPlayer(let hint):
            currentBuzzerVM?.showHint(hint)

        default:
            break
        }
    }
}

// MARK: - Timer mirroring logic
extension PlayerGameViewModel {
    private func handlePublicStateChange(_ state: PublicState) {
        switch state {
        case .waiting:
            stopUITimer()
            formattedTime = "00:00"
            lastMasterFormattedTime = "00:00"
            if currentBuzzerVM?.answerResult != nil {
                // Overlay en cours — juste désactiver le buzzer sans effacer l'overlay
                currentBuzzerVM?.lockBuzz(teamNameHasBuzz: "")
            } else {
                currentBuzzerVM?.clearBuzzState()
            }
            if lastAnswerWasCorrect && !previousRanking.isEmpty {
                lastAnswerWasCorrect = false
                // Délai calé sur la fin de l'overlay (2.6s) pour que l'animation du classement
                // démarre uniquement quand l'overlay a disparu
                leaderboardTask?.cancel()
                leaderboardTask = Task { [weak self] in
                    try? await Task.sleep(for: .seconds(2.7))
                    guard !Task.isCancelled, let self else { return }
                    await MainActor.run { self.showPostRoundLeaderboard = true }
                }
            }
        case .quiz(let quizState):
            leaderboardTask?.cancel()
            showPostRoundLeaderboard = false
            lastMasterFormattedTime = quizState.formattedTime
            formattedTime = quizState.formattedTime
            currentBuzzerVM?.countdownPhase = quizState.countdownPhase
            if quizState.isAnswerRevealed {
                stopUITimer()
                currentBuzzerVM?.clearBuzzState()
            } else {
                // Quiz : le timer est géré exclusivement par .timerStarted / .buzzUnlock
                // syncBuzzerState ne doit PAS appeler resumeUITimerIfNeeded ici
                syncBuzzerState(buzzingPlayer: quizState.buzzingPlayer,
                                isRoundActive: quizState.countdownPhase == .hidden,
                                autoResumeTimer: false)
            }
        case .blindTest(let blindTestState):
            leaderboardTask?.cancel()
            showPostRoundLeaderboard = false
            lastMasterFormattedTime = blindTestState.formattedTime
            // Timer piloté par .timerStarted — on ne force la valeur master que si le timer local est inactif
            // (resync à la reconnexion ou à l'onAppear), évitant les sauts visuels pendant le jeu
            if timer == nil {
                formattedTime = blindTestState.formattedTime
            }
            currentBuzzerVM?.countdownPhase = blindTestState.countdownPhase
            syncBuzzerState(buzzingPlayer: blindTestState.buzzingPlayer, isRoundActive: blindTestState.isPlaying)
        }
    }

    func syncBuzzerWithCurrentPublicState() {
        handlePublicStateChange(publicState)
    }

    // Démarre le timer local en miroir du Master.
    // Initialise reactionTimeMs depuis le timestamp du Master pour compenser la latence réseau.
    private func startLocalReactionTimer(masterTimestamp: TimeInterval) {
        stopUITimer()

        // Temps déjà écoulé depuis que le Master a lancé son timer
        let initialElapsedMs = max(0, Int((Date().timeIntervalSince1970 - masterTimestamp) * 1000))
        // On utilise la même unité que le Master : reactionTimeMs en ms, incrémenté de 100 toutes les 0.1s
        var reactionTimeMs = initialElapsedMs

        let newTimer = Timer(timeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self else { return }
            reactionTimeMs += 100
            let snapshot = reactionTimeMs
            Task { @MainActor in
                self.formattedTime = Self.formatReactionTime(snapshot)
            }
        }
        RunLoop.main.add(newTimer, forMode: .common)
        timer = newTimer
        // Affichage immédiat sans attendre le premier tick
        formattedTime = Self.formatReactionTime(reactionTimeMs)
    }

    // Reprend le timer local à partir de la valeur affichée actuellement (après un buzz rejeté).
    // Appelé quand la manche reprend sans relancer un timerStarted côté Master.
    private func resumeUITimerIfNeeded() {
        guard timer == nil else { return }  // déjà actif

        // Reconstruire reactionTimeMs depuis formattedTime "SS"
        guard let seconds = Int(formattedTime) else { return }
        var reactionTimeMs = seconds * 1000

        let newTimer = Timer(timeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self else { return }
            reactionTimeMs += 100
            let snapshot = reactionTimeMs
            Task { @MainActor in
                self.formattedTime = Self.formatReactionTime(snapshot)
            }
        }
        RunLoop.main.add(newTimer, forMode: .common)
        timer = newTimer
    }

    // Miroir exact de BuzzDrivenGame.formattedTime
    private static func formatReactionTime(_ reactionTimeMs: Int) -> String {
        String(format: "%02d", reactionTimeMs / 1000)
    }

    private func stopUITimer() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - B4 : Gestion background/foreground
    // Appelé depuis BuzzerPlayerView via .onChange(of: scenePhase)
    func handleSceneDidBackground() {
        stopUITimer()
    }

    func sendPlayerReady() {
        guard isConnectedToMaster else { return }
        mpc.sendMessage(.playerReady)
    }

    func handleSceneWillForeground() {
        formattedTime = lastMasterFormattedTime
        // Re-confirmer la présence si déjà sur le buzzer
        if isConnectedToMaster && hasPartyStarted {
            sendPlayerReady()
        }
        guard !isConnectedToMaster else { return }
        // Retour foreground sans connexion → scan immédiat + timer de retry
        mpc.restartBrowsing()
        startReconnectTimer()
    }

    // MARK: - Reconnect auto

    private func startReconnectTimer() {
        stopReconnectTimer()
        // #C1 — watchdog réduit à 3s pour récupérer plus vite les invitations expirées
        reconnectTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self, !self.isConnectedToMaster else {
                    self?.stopReconnectTimer()
                    return
                }
                print("🔄 PlayerGameVM: tentative de reconnexion auto")
                self.mpc.restartBrowsing()
            }
        }
    }

    private func stopReconnectTimer() {
        reconnectTimer?.invalidate()
        reconnectTimer = nil
    }

    private func syncBuzzerState(buzzingPlayer: Player?, isRoundActive: Bool, autoResumeTimer: Bool = true) {
        if let player = buzzingPlayer {
            stopUITimer()
            currentBuzzerVM?.lockBuzz(teamNameHasBuzz: player.name)
        } else if isRoundActive {
            if autoResumeTimer { resumeUITimerIfNeeded() }
            currentBuzzerVM?.unLockBuzz()
        } else {
            stopUITimer()
            currentBuzzerVM?.lockBuzz(teamNameHasBuzz: "")
        }
    }
}

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

        // MPCService dispatche déjà sur le main thread — on utilise Task @MainActor pour
        // garantir l'isolation sans double-dispatch.
        mpc.onPeerConnected = { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.isConnectedToMaster = true
                self.hasEverConnectedToMaster = true
                self.stopReconnectTimer()
                guard !self.didSentPlayer else { return }
                self.didSentPlayer = true
                self.mpc.sendMessage(.playerJoin(self.player))
            }
        }

        mpc.onPeerDisconnected = { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
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
                self.player = updatedPlayer
                currentBuzzerVM?.player = updatedPlayer
            }
            if let idx = knownPlayers.firstIndex(where: { $0.id == updatedPlayer.id }) {
                knownPlayers[idx] = updatedPlayer
            } else {
                knownPlayers.append(updatedPlayer)
            }
        case .masterLaunchedGame(let game):
            pendingGameInvite = game
            hasPartyStarted = true  // reconnexion après kill app : la partie est déjà lancée
            if game == .score {
                leaderboardTask?.cancel()
                showPostRoundLeaderboard = false
            }

        case .masterStartedParty:
            hasPartyStarted = true

        case .masterGameComplete:
            isGameComplete = true

        case .masterResetGame:
            isGameComplete = false
            hasPartyStarted = false
            pendingGameInvite = nil
            publicState = .waiting
            currentBuzzerVM = nil
            showPostRoundLeaderboard = false
            leaderboardTask?.cancel()
            shouldReturnToLobby = true

        case .timerStarted(let payload):
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

        // Reconstruire reactionTimeMs depuis formattedTime "SS:CS"
        let components = formattedTime.split(separator: ":").compactMap { Int($0) }
        guard components.count == 2 else { return }
        // formattedTime est produit par formatReactionTime : ss = displayUnits/100, cs = displayUnits%100
        // displayUnits = reactionTimeMs/10 → reactionTimeMs = (ss*100 + cs) * 10
        var reactionTimeMs = (components[0] * 100 + components[1]) * 10

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
        let displayUnits = reactionTimeMs / 10
        let seconds = displayUnits / 100
        let cs = displayUnits % 100
        return String(format: "%02d:%02d", seconds, cs)
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

    func handleSceneWillForeground() {
        formattedTime = lastMasterFormattedTime
        guard !isConnectedToMaster else { return }
        // Retour foreground sans connexion → scan immédiat + timer de retry
        mpc.restartBrowsing()
        startReconnectTimer()
    }

    // MARK: - Reconnect auto

    private func startReconnectTimer() {
        stopReconnectTimer()
        reconnectTimer = Timer.scheduledTimer(withTimeInterval: 6, repeats: true) { [weak self] _ in
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

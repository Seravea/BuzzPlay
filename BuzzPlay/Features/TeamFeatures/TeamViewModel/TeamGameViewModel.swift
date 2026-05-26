//
//  TeamViewModem.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 13/11/2025.
//

import Foundation
import Observation


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

    // Toast Notes reçues (🎵) — auto-dismiss géré dans la vue
    var pendingNotesToast: Int? = nil

    // MARK: - Public display timer mirroring
    var formattedTime: String = "00:00"
    private var timer: Timer?
    private var lastMasterFormattedTime: String = "00:00"

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

        mpc.onPeerConnected = { [weak self] _ in
            guard let self else { return }
            DispatchQueue.main.async {
                self.isConnectedToMaster = true
                self.hasEverConnectedToMaster = true
                guard !self.didSentPlayer else { return }

                // ✅ Only send once we are connected (prevents MCSession Code=2: Invalid peerIDs)
                self.didSentPlayer = true

                // PLAYER joins the master
                self.mpc.sendMessage(.playerJoin(self.player))
            }
        }

        mpc.onPeerDisconnected = { [weak self] _ in
            guard let self else { return }
            DispatchQueue.main.async {
                self.isConnectedToMaster = false
                // Reset so player re-announces itself when master comes back
                self.didSentPlayer = false
                // Browser continues running; master will be re-discovered automatically
            }
        }

        mpc.onMessage = { [weak self] data, peer in
            guard let self else { return }

            do {
                let message = try JSONDecoder().decode(MPCMessage.self, from: data)
                DispatchQueue.main.async {
                    self.handleMessage(message)
                }
            } catch {
                print("Message received but unknown in MPCMessage: \(error)")
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

        case .masterStartedParty:
            hasPartyStarted = true

        case .masterGameComplete:
            isGameComplete = true

        case .timerStarted(let payload):
            startLocalReactionTimer(masterTimestamp: payload.masterTimestamp)

        case .answerResult(let payload):
            let result: AnswerResult = payload.isCorrect
                ? .correct(points: payload.points, answer: payload.correctAnswer)
                : .incorrect
            currentBuzzerVM?.showAnswerResult(result)

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
        case .quiz(let quizState):
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

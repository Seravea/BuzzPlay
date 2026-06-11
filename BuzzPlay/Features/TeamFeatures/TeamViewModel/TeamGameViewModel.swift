//
//  TeamViewModem.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 13/11/2025.
//

import Foundation
import Observation
import AVFoundation


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
    // #quit-teardown — true quand le Master a explicitement quitté la partie : on rentre à
    // l'accueil et on NE tente PAS de se reconnecter (≠ déconnexion accidentelle).
    var masterDidLeave: Bool = false
    // Notification brève avant redirection (#B6)
    var showNewGameNotification: Bool = false

    // #v1-economy — porte-monnaie Notes LOCAL du joueur (gains quotidiens + fin de partie,
    // dépenses cadeaux). Le toast "Notes reçues" est porté par wallet.pendingCreditToast.
    let notesWallet = PlayerNotesWallet.shared
    // Compteur incrémenté à chaque buyGiftResult — observé par la vue pour débloquer le shop.
    var giftConfirmationCount: Int = 0

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

    // MARK: - Décompte 3-2-1-GO local (#countdown-sync)
    private var localCountdownTask: Task<Void, Never>?
    private var isLocalCountdownActive = false

    init(player: Player, mpc: MPCService) {
        self.player = player
        self.mpc = mpc
        setupMPC()
        // #v1-economy — +50 Notes/jour de connexion (cumul plafonné), crédit automatique.
        notesWallet.claimDailyIfNeeded()
    }

    deinit {
        // Hygiène : les Timer sur RunLoop.main survivent au VM s'ils ne sont pas invalidés
        // (le miroir du timer + le watchdog de reco 3s continuaient de tirer à vide).
        // assumeIsolated : le VM est possédé par SwiftUI → désalloué sur le main thread.
        MainActor.assumeIsolated {
            timer?.invalidate()
            reconnectTimer?.invalidate()
            leaderboardTask?.cancel()
        }
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
                    try? await Task.sleep(for: GameRhythm.playerReadyReco)
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
                // #quit-teardown — si le Master a quitté volontairement, ne pas relancer le
                // watchdog de reconnexion (sinon le Player tente de rejoindre un Master parti).
                guard !self.masterDidLeave else { return }
                self.startReconnectTimer()
            }
        }

        mpc.onMessage = { [weak self] data, peer in
            Task { @MainActor [weak self] in
                guard let self else { return }
                do {
                    let message = try MPCService.jsonDecoder.decode(MPCMessage.self, from: data)
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
            applyPlayerUpdate(updatedPlayer)

        case .rosterUpdate(let roster):
            // Liste des joueurs complète en UN message (avant : N × updatedPlayer) —
            // même logique de merge que updatedPlayer pour chaque entrée.
            roster.forEach { applyPlayerUpdate($0) }

        case .countdownStarted(let payload):
            // #countdown-jeu2 — fermer le classement inter-manche dès qu'un décompte démarre,
            // pour que le joueur voie le 3-2-1 sur son buzzer (sinon il restait sur la sheet
            // de classement et arrivait direct au buzzer une fois le décompte terminé).
            leaderboardTask?.cancel()
            showPostRoundLeaderboard = false
            startLocalCountdown(masterTimestamp: payload.masterTimestamp,
                                startCount: payload.startCount)

        case .masterLaunchedGame(let game):
            pendingGameInvite = game
            hasPartyStarted = true  // reconnexion après kill app : la partie est déjà lancée
            hasReceivedFirstTimer = false  // reset pour chaque nouveau jeu (#A4)
            // Tout nouveau jeu (ou le score) annule un classement inter-manche encore en file.
            leaderboardTask?.cancel()
            showPostRoundLeaderboard = false
            if game != .score {
                // #waiting-invite-jeu2 — au lancement du jeu suivant, l'ancien état du jeu
                // précédent (réponse révélée, MusicCard, overlay « Bravo ») persistait jusqu'au
                // premier publicUpdate, car le currentBuzzerVM est RÉUTILISÉ entre 2 jeux (#C7).
                // On repart d'un état propre, comme le fait `.masterResetGame`.
                lastAnswerWasCorrect = false
                publicState = .waiting
                formattedTime = "00:00"
                lastMasterFormattedTime = "00:00"
                currentBuzzerVM?.clearBuzzState()
            }

        case .masterStartedParty:
            hasPartyStarted = true

        case .masterGameComplete:
            // #C6 — cancel le leaderboard avant le podium pour éviter le flash
            leaderboardTask?.cancel()
            showPostRoundLeaderboard = false
            // #v1-economy — +100 Notes en fin de partie (une seule fois : garde sur la
            // transition, le message peut être redélivré à la reconnexion).
            if !isGameComplete { notesWallet.creditEndOfGame() }
            isGameComplete = true

        case .masterResetGame:
            isGameComplete = false
            hasPartyStarted = false
            pendingGameInvite = nil
            publicState = .waiting
            currentBuzzerVM = nil
            // #C9 — remet les scores à 0 localement (le Master a reset sa source de vérité).
            // Filet de sécurité idempotent avec le rosterUpdate envoyé juste avant : garantit
            // un classement propre même si ce message s'est croisé/perdu, ou à la reco.
            player.score = 0
            for i in knownPlayers.indices { knownPlayers[i].score = 0 }
            showPostRoundLeaderboard = false
            leaderboardTask?.cancel()
            // Affiche notification brève avant redirection (#B6)
            showNewGameNotification = true
            Task { @MainActor [weak self] in
                try? await Task.sleep(for: GameRhythm.newGameNotif)
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
            // #v1-economy — confirmation du Master : débloque le shop (le débit a déjà
            // eu lieu localement dans CoinsViewModel.buyGift).
            giftConfirmationCount += 1
            print("PLAYER: received gift purchase confirmation for \(gift.title)")

        case .hintRevealedToPlayer(let hint):
            currentBuzzerVM?.showHint(hint)

        case .hintPending:
            // #22 — indice acheté entre 2 manches : feedback "en attente". Le vrai indice
            // arrivera au début de la prochaine manche (hintRevealedToPlayer), remplaçant ce texte.
            currentBuzzerVM?.showHint("Indice en route — il arrive à la prochaine manche 🔍")

        case .masterLeftParty:
            // #quit-teardown — le Master a quitté : on coupe le watchdog de reco et on
            // renvoie le Player à l'accueil (PlayerGameView observe `masterDidLeave`).
            masterDidLeave = true

        case .ping:
            // Heartbeat : répondre au Master pour prouver qu'on est vivant.
            mpc.sendMessage(.pong)

        case .masterRequestRejoin:
            // #pause-reco — le Master nous a perdus de son roster (timeout heartbeat sur une
            // connexion half-open : on n'a jamais vu notre propre déco, donc didSentPlayer est
            // resté true et onPeerConnected ne s'est jamais redéclenché). On force un nouvel
            // enregistrement pour réintégrer le roster côté Master et lever sa pause.
            didSentPlayer = true
            mpc.sendMessage(.playerJoin(player))

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
            // #15 — le classement inter-manche n'est PLUS déclenché par `.waiting` : il l'est
            // désormais par l'état "réponse révélée" (`.quiz`/`.blindTest` avec isAnswerRevealed),
            // commun aux deux jeux. `.waiting` ne sert que de remise à zéro.
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
            // #countdown-sync — pendant un décompte local (countdownStarted reçu), ne pas
            // laisser un publicUpdate écraser la phase calculée sur l'horloge locale.
            // Le payload reste le fallback pour une reconnexion mid-countdown.
            if !isLocalCountdownActive {
                currentBuzzerVM?.countdownPhase = quizState.countdownPhase
            }
            if quizState.isAnswerRevealed {
                // #15 — manche terminée : la réponse reste affichée en haut (card RÉPONSE),
                // on déclenche le classement inter-manche commun.
                stopUITimer()
                currentBuzzerVM?.clearBuzzState()
                schedulePostRoundLeaderboard(isLastRound: quizState.isLastRound)
            } else {
                // Manche active : pas de classement.
                leaderboardTask?.cancel()
                showPostRoundLeaderboard = false
                // #timer-reco-quiz — reco / kill+relaunch sur une question EN COURS : le Master
                // resync via publicUpdate mais ne renvoie PAS .timerStarted, donc
                // hasReceivedFirstTimer restait false → le badge timer affichait "—".
                // On le débloque depuis l'état reçu (question révélée, pas de countdown) et on
                // relance le timer local depuis la valeur du Master. Garde-fou : une seule fois.
                if quizState.isQuestionRevealed && quizState.countdownPhase == .hidden
                    && quizState.buzzingPlayer == nil && !hasReceivedFirstTimer {
                    hasReceivedFirstTimer = true
                    resumeUITimerIfNeeded()
                }
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
            // #countdown-sync — même garde-fou que le Quiz (voir plus haut).
            if !isLocalCountdownActive {
                currentBuzzerVM?.countdownPhase = blindTestState.countdownPhase
            }
            if blindTestState.isAnswerRevealed {
                // #15 — manche terminée : la MusicCard révélée reste affichée en haut, on
                // déclenche le même classement inter-manche que le Quiz.
                schedulePostRoundLeaderboard(isLastRound: blindTestState.isLastRound)
            } else {
                leaderboardTask?.cancel()
                showPostRoundLeaderboard = false
            }
            syncBuzzerState(buzzingPlayer: blindTestState.buzzingPlayer, isRoundActive: blindTestState.isPlaying)
        }
    }

    // #15/#11 — déclencheur unique du classement inter-manche, partagé Quiz + BlindTest.
    // Appelé quand un état "réponse révélée" arrive après une bonne réponse validée.
    private func schedulePostRoundLeaderboard(isLastRound: Bool) {
        guard lastAnswerWasCorrect, !previousRanking.isEmpty else { return }
        lastAnswerWasCorrect = false
        leaderboardTask?.cancel()
        // #11/#C8 — dernière manche : pas de classement inter-manche, le podium final enchaîne.
        guard !isLastRound else {
            showPostRoundLeaderboard = false
            return
        }
        // Délai calé sur la fin de l'overlay de feedback pour que la sheet de classement
        // monte une fois l'overlay "Bravo" disparu.
        leaderboardTask = Task { [weak self] in
            try? await Task.sleep(for: GameRhythm.leaderboardDelay)
            guard !Task.isCancelled, let self else { return }
            await MainActor.run { self.showPostRoundLeaderboard = true }
        }
    }

    func syncBuzzerWithCurrentPublicState() {
        handlePublicStateChange(publicState)
    }

    /// Applique une mise à jour de joueur (soi-même ou un autre) — partagé entre
    /// .updatedPlayer (unitaire) et .rosterUpdate (liste des joueurs complète).
    private func applyPlayerUpdate(_ updatedPlayer: Player) {
        if updatedPlayer.id == self.player.id {
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
        // #10 — dédoublonnage par id OU nom : à la reconnexion l'UUID peut changer
        // (le nom est la clé stable côté Master) → évite qu'un joueur revenu apparaisse
        // deux fois dans le classement quand le roster complet est rediffusé.
        if let idx = knownPlayers.firstIndex(where: { $0.id == updatedPlayer.id || $0.name == updatedPlayer.name }) {
            knownPlayers[idx] = updatedPlayer
        } else {
            knownPlayers.append(updatedPlayer)
        }
    }

    // #countdown-sync — décompte 3-2-1-GO calculé sur l'horloge locale depuis le timestamp
    // du Master (même principe que timerStarted #T2) : l'affichage est synchrone sur tous
    // les téléphones, plus de jitter de broadcast par phase. Purement visuel — le
    // déverrouillage du buzzer reste piloté par .buzzUnlock (autorité Master).
    private func startLocalCountdown(masterTimestamp: TimeInterval, startCount: Int) {
        localCountdownTask?.cancel()
        isLocalCountdownActive = true
        localCountdownTask = Task { @MainActor [weak self] in
            // Durées identiques à runCountdown côté Master : 1s par chiffre + 0.8s de GO.
            let tick: TimeInterval = 1.0
            let goFlash: TimeInterval = 0.8
            let countingTotal = TimeInterval(startCount) * tick
            while !Task.isCancelled {
                guard let self else { return }
                let elapsed = Date().timeIntervalSince1970 - masterTimestamp
                if elapsed < 0 {
                    // Horloge locale en avance sur celle du Master — attendre le vrai départ.
                    try? await Task.sleep(for: .seconds(-elapsed))
                } else if elapsed < countingTotal {
                    let phaseIndex = Int(elapsed / tick)
                    self.currentBuzzerVM?.countdownPhase = .counting(startCount - phaseIndex)
                    // Dort jusqu'à la frontière de la phase suivante.
                    try? await Task.sleep(for: .seconds(max(0.02, TimeInterval(phaseIndex + 1) * tick - elapsed)))
                } else if elapsed < countingTotal + goFlash {
                    self.currentBuzzerVM?.countdownPhase = .go
                    try? await Task.sleep(for: .seconds(max(0.02, countingTotal + goFlash - elapsed)))
                } else {
                    self.currentBuzzerVM?.countdownPhase = .hidden
                    self.isLocalCountdownActive = false
                    return
                }
            }
            // Sorti par annulation (nouveau décompte lancé) : ne pas écraser le flag
            // que le nouveau décompte vient de poser.
        }
    }

    // Démarre le timer local en miroir du Master.
    // Initialise reactionTimeMs depuis le timestamp du Master pour compenser la latence réseau.
    private func startLocalReactionTimer(masterTimestamp: TimeInterval) {
        stopUITimer()

        // Temps déjà écoulé depuis que le Master a lancé son timer
        let initialElapsedMs = max(0, Int((Date().timeIntervalSince1970 - masterTimestamp) * 1000))
        // Même unité que le Master : reactionTimeMs en ms.
        // #perf — tick à 1s (l'affichage ne montre que les secondes) + mutation directe :
        // à 0.1s, formattedTime (@Observable) était réassigné 10×/s → 10 re-renders/s
        // du buzzer entier pour un texte qui ne change qu'1×/s.
        var reactionTimeMs = initialElapsedMs

        let newTimer = Timer(timeInterval: 1.0, repeats: true) { [weak self] _ in
            reactionTimeMs += 1000
            let snapshot = reactionTimeMs
            MainActor.assumeIsolated {
                guard let self else { return }
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

        // #perf — 1s/tick + mutation directe (voir startLocalReactionTimer).
        let newTimer = Timer(timeInterval: 1.0, repeats: true) { [weak self] _ in
            reactionTimeMs += 1000
            let snapshot = reactionTimeMs
            MainActor.assumeIsolated {
                guard let self else { return }
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

    // #quit-teardown — le Player quitte la partie ("Quitter" sur le podium) OU suit le Master
    // qui est parti : on coupe le watchdog de reco et on se déconnecte proprement de la session.
    func leaveSession() {
        stopReconnectTimer()
        mpc.leaveAsPlayer()
        isConnectedToMaster = false
        // Libère la session audio (jamais désactivée sinon → retient le hardware audio
        // après la partie). En détaché : setActive peut bloquer sur le routing Bluetooth.
        Task.detached {
            try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        }
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

//
//  BlindTestViewModel.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 12/11/2025.
//

import Foundation
import SwiftUI
import UIKit
import AVFoundation
import Observation
import MusicKit

@MainActor
@Observable
class BlindTestMasterViewModel: BuzzDrivenGame {
    
    let gameVM: MasterFlowViewModel
    let appleMusicService = AppleMusicService()
    var isFetching: Bool = false
    
    //MARK: données de manche en cours
    var isPlaying: Bool = false
    
    var allSongs: [BlindTestSong] = []
    var playlists: [BlindTestPlaylist] = []
    var selectedMusic: BlindTestSong? = nil
    var currentHintIndex: Int = 0  // Hint displayed for the current song
    var isGameActive: Bool = false

    var nowPlayingSongIndex: Int = 0
    var isCorrect: Bool = false
    
    var shouldAutoFinish: Bool = false
    var hasInvitedPlayers: Bool = false

    var playerHasBuzz: Player? = nil
    var playedSongs: [BlindTestSong] = []

    var state: RoundState = .idle
    var roundCountdownPhase: RoundCountdownPhase = .hidden
    // Task du countdown en cours — annulable via cancelRound()
    private var countdownTask: Task<Void, Never>?

    // true quand le preview/titre s'est terminé naturellement (timer expiré)
    // → rejectAnswer doit relancer la musique depuis le début au lieu de resume()
    private var musicHasEnded = false

    // true si on joue un extrait AVPlayer (preview URL, ~30s) — false = MusicKit catalogue
    private var isPreviewMode: Bool = false

    // Durée de la manche en ms : 30s pour preview, 30s aussi pour catalogue (limite raisonnable)
    private let roundDurationMs = 30_000

    //MARK: Timer's datas
    var reactionTimeMs: Int = 0
    var timer: Timer?

    //MARK: UI alert (abonnement requis — affiché une seule fois via UserDefaults)
    var showSubscriptionAlert: Bool = false
    var subscriptionAlertMessage: String = "Pour lire le morceau en entier, un abonnement Apple Music est requis. Lecture de l'extrait à la place."
    private let subscriptionInfoKey = "buzzplay.subscriptionInfoShown"
    private var hasShownSubscriptionInfo: Bool {
        get { UserDefaults.standard.bool(forKey: subscriptionInfoKey) }
        set { UserDefaults.standard.set(newValue, forKey: subscriptionInfoKey) }
    }

    //MARK: UI alert (erreurs réseau / Apple Music)
    var fetchError: String? = nil

    //MARK: Observer fin de preview
    var previewEndObserver: (any NSObjectProtocol)? = nil

    // Badge/Disponibilité lecture catalogue
    var canPlayCatalogContent: Bool = false

    enum RoundState {
        case idle // next song and master hasn't lunch round/music
        case playing // in game and music playing
        case buzzed(Player) // response receive
        case finished // state finished when Master validate response
    }
    
    private var doubledScorePlayers: Set<UUID> = []
    private let feedbackGenerator = UINotificationFeedbackGenerator()

    //MARK: données de jeu
    init(gameVM: MasterFlowViewModel) {
        self.gameVM = gameVM
        feedbackGenerator.prepare()
    }
    
    var player: AVPlayer?
    // Lecteur MusicKit pour le catalogue
    let musicPlayer = ApplicationMusicPlayer.shared
}

//MARK: func and data use in the View
extension BlindTestMasterViewModel {

    var totalNumberOfSongs: Int {
        allSongs.count
    }

    var roundsTotal: Int {
        let total = gameVM.blindTestRoundsTotal
        return total > 0 ? total : allSongs.count
    }
    
    func validateAnswer(points: Int) {
        guard let playerAnswers = playerHasBuzz else { return }
        feedbackGenerator.notificationOccurred(.success)
        if let song = selectedMusic, !playedSongs.contains(song) {
            playedSongs.append(song)
        }

        isCorrect = true
        state = .finished
        gameVM.blindTestRoundsPlayed += 1

        let configuredTotal = gameVM.blindTestRoundsTotal
        if configuredTotal > 0 && playedSongs.count >= configuredTotal {
            shouldAutoFinish = true
        }

        let wasDoubled = doubledScorePlayers.remove(playerAnswers.id) != nil
        let finalPoints = wasDoubled ? points * 2 : points

        // .answerResult envoyé EN PREMIER → Player snapshote knownPlayers avant la mise à jour du score
        let resultPayload = AnswerResultPayload(isCorrect: true, points: finalPoints, correctAnswer: nil)
        gameVM.mpcService.sendMessage(.answerResult(resultPayload))

        gameVM.addPointToPlayer(playerAnswers, points: finalPoints, consumeScoreDouble: wasDoubled)

        // on fige définitivement la manche
        stopReactionTimer()
        pause()
        isPlaying = false

        // ✅ update public display (answer revealed)
        gameVM.broadcastPublicStateFromCurrentGame()

        // (optionnel) on nettoie ensuite la sélection
        selectedMusic = nil
        isGameActive = false
    }
    
    func rejectAnswer() {
        guard case .buzzed = state else { return }
        feedbackGenerator.notificationOccurred(.warning)

        isCorrect = false
        playerHasBuzz = nil
        state = .playing
        // isPlaying reste false → makePublicState émet isPlaying:false → Player ne relance pas son timer

        let resultPayload = AnswerResultPayload(isCorrect: false, points: 0, correctAnswer: nil)
        gameVM.mpcService.sendMessage(.answerResult(resultPayload))
        gameVM.broadcastPublicStateFromCurrentGame()

        countdownTask = Task { @MainActor [weak self] in
            guard let self else { return }
            await runCountdown(
                onPhaseChange: { [weak self] phase in
                    self?.roundCountdownPhase = phase
                    self?.gameVM.broadcastPublicStateFromCurrentGame()
                },
                onComplete: { [weak self] in
                    guard let self else { return }
                    self.gameVM.unlockBuzz()
                    if self.musicHasEnded {
                        self.restartMusicFromBeginning()
                        self.musicHasEnded = false
                    } else {
                        self.resume()
                    }
                    self.isPlaying = true
                    self.startReactionTimer()
                    self.gameVM.broadcastPublicStateFromCurrentGame()
                }
            )
        }
    }
}

//MARK: Round Funcs
extension BlindTestMasterViewModel {

    // Lance countdown ET chargement musique EN PARALLÈLE (async let).
    // La musique est prête avant la fin du countdown → play() sans latence.
    func startRound() {
        guard let selectedMusic = selectedMusic else { return }
        isFetching = true  // spinner immédiat

        // AVAudioSession.setActive(true) peut bloquer plusieurs secondes sur le main thread
        // (Bluetooth, routing audio). On le lance en background avant le countdownTask.
        Task.detached(priority: .userInitiated) { Self.configureAudioSession() }

        countdownTask = Task { @MainActor [weak self] in
            guard let self else { return }

            currentHintIndex = Int.random(in: 0..<BlindTestHints.phrases.count)
            reactionTimeMs = 0
            playerHasBuzz = nil
            isCorrect = false
            musicHasEnded = false
            state = .playing
            isGameActive = true

            // Countdown (5.8 s) ET chargement musique en parallèle
            async let countdown: Void = runCountdown(
                onPhaseChange: { [weak self] phase in
                    self?.roundCountdownPhase = phase
                    self?.gameVM.broadcastPublicStateFromCurrentGame()
                },
                onComplete: {}
            )
            async let musicPrep: Void = prepareMusicForPlayback(song: selectedMusic)
            _ = await (countdown, musicPrep)

            guard !Task.isCancelled else { return }

            gameVM.unlockBuzz()
            playPreparedMusicNow()
        }
    }

    func cancelRound() {
        countdownTask?.cancel()
        countdownTask = nil
        roundCountdownPhase = .hidden
        stop()
        stopReactionTimer()
        isPlaying = false
        isGameActive = false
        playerHasBuzz = nil
        gameVM.currentBuzzPlayer = nil
        gameVM.isBuzzLocked = false
        state = .idle
        gameVM.broadcastPublicStateFromCurrentGame()
    }

    func handlePreviewEnd() {
        switch state {
        case .playing:
            // Preview terminée → reboucle depuis le début, timer continue à compter
            restartMusicFromBeginning()
            gameVM.broadcastPublicStateFromCurrentGame()
        case .buzzed:
            // Race condition : musique terminée exactement au moment du buzz
            // → rejectAnswer devra relancer depuis le début au lieu de resume()
            musicHasEnded = true
        default:
            break
        }
    }
}

//MARK: Gift effects
extension BlindTestMasterViewModel {
    func applyGiftEffect(_ gift: CoinsViewModel.Gift, to player: Player) {
        switch gift {
        case .scoreDoubled:
            doubledScorePlayers.insert(player.id)

        case .showIndicies:
            guard let song = selectedMusic else { return }
            let hint = buildBlindTestHint(song: song)
            gameVM.mpcService.sendMessagetoOnePlayer(message: .hintRevealedToPlayer(hint), player: player)

        default:
            break
        }
    }

    private func buildBlindTestHint(song: BlindTestSong) -> String {
        let t = song.title
        let a = song.artist
        let titleHint = t.count > 2
            ? "\(t.prefix(1))\(String(repeating: "-", count: t.count - 2))\(t.last!) (\(t.count) lettres)"
            : "\(t.prefix(1))... (\(t.count) lettres)"
        let artistHint = a.count > 2
            ? "\(a.prefix(1))\(String(repeating: "-", count: a.count - 2))\(a.last!) (\(a.count) lettres)"
            : "\(a.prefix(1))... (\(a.count) lettres)"
        return "Titre : \(titleHint)\nArtiste : \(artistHint)"
    }
}


//MARK: BuzzDrivenGame conformance
extension BlindTestMasterViewModel {

    // Timer BlindTest : compte en continu sans limite — ne se remet jamais à 0.
    // La musique gère son propre cycle (preview reboucle via handlePreviewEnd,
    // catalogue joue jusqu'à la fin). Le timer est une montre indépendante.
    func startReactionTimer() {
        timer?.invalidate()
        timer = nil

        let newTimer = Timer(timeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                self.reactionTimeMs += 100
            }
        }
        RunLoop.main.add(newTimer, forMode: .common)
        timer = newTimer
    }

    func handleBuzz(from player: Player) {
        // Ignorer les buzz si la manche n'est pas en cours
        guard case .playing = state else { return }

        playerHasBuzz = player
        state = .buzzed(player)
        
        // Pause uniquement: timer + musique (ne pas reset, pour pouvoir reprendre)
        pause()
        isPlaying = false

        // ✅ update public display (buzz received)
        gameVM.broadcastPublicStateFromCurrentGame()
    }
    
    func makePublicState() -> PublicState {
        switch state {

           case .idle:
               return .waiting

           case .playing:
            return .blindTest(
                    PublicBlindTestState(
                        title: nil,
                        artist: nil,
                        postertURLString: nil,
                        releaseYear: nil,
                        formattedTime: formattedTime,
                        buzzingPlayer: nil,
                        isAnswerRevealed: false,
                        isPlaying: isPlaying,   // false pendant le countdown → Player ne relance pas son timer trop tôt
                        hintIndex: currentHintIndex,
                        countdownPhase: roundCountdownPhase
                    )
                )

           case .buzzed(let player):
               return .blindTest(
                   PublicBlindTestState(
                       title: nil,
                       artist: nil,
                       postertURLString: nil,
                       releaseYear: nil,
                       formattedTime: formattedTime,
                       buzzingPlayer: player,
                       isAnswerRevealed: false,
                       isPlaying: false,
                       hintIndex: currentHintIndex,
                       countdownPhase: roundCountdownPhase
                   )
               )

           case .finished:
               return .blindTest(
                   PublicBlindTestState(
                       title: selectedMusic?.title,
                       artist: selectedMusic?.artist,
                       postertURLString: selectedMusic?.postertURL?.absoluteString,
                       releaseYear: selectedMusic?.releaseYearString,
                       formattedTime: formattedTime,
                       buzzingPlayer: playerHasBuzz,
                       isAnswerRevealed: true,
                       isPlaying: false,
                       hintIndex: currentHintIndex,
                       countdownPhase: roundCountdownPhase
                   )
               )
           }
    }
}

//MARK: Apple Music functions
extension BlindTestMasterViewModel {
    func search(query: String) async {
        do {
            isFetching = true
            let results = try await appleMusicService.searchPlaylists(query: query)
            isFetching = false
            self.playlists = results
        } catch {
            isFetching = false
            fetchError = "Impossible de chercher les playlists. Vérifie ta connexion."
        }
    }
    
    func selectPlaylist(_ playlist: BlindTestPlaylist) async {
        do {
            isFetching = true
            let songs = try await appleMusicService.loadSongs(from: playlist)
            isFetching = false
            self.allSongs = songs
        } catch {
            isFetching = false
            fetchError = "Impossible de charger cette playlist. Réessaie."
        }
    }
    
    //MARK: functions Song playing
    
    // Autorisation + éligibilité (utilisé pendant la lecture pour décider preview vs catalogue)
    func canPlayFullCatalog() async -> Bool {
        let status = await MusicAuthorization.request()
        guard status == .authorized else { return false }
        do {
            let subscription = try await MusicSubscription.current
            return subscription.canPlayCatalogContent
        } catch {
            return false
        }
    }

    // Appelé à l'onAppear : autorise + vérifie abonnement en un seul aller-retour réseau.
    // Lance aussi le stream de mises à jour pour les changements futurs.
    func setupMusicOnAppear() async {
        observeSubscriptionUpdates()
        let status = await MusicAuthorization.request()
        guard status == .authorized else { return }
        do {
            let subscription = try await MusicSubscription.current
            canPlayCatalogContent = subscription.canPlayCatalogContent
        } catch {
            canPlayCatalogContent = false
        }
    }

    // Écoute les changements d'abonnement en temps réel
    private func observeSubscriptionUpdates() {
        Task {
            for await subscription in MusicSubscription.subscriptionUpdates {
                self.canPlayCatalogContent = subscription.canPlayCatalogContent
            }
        }
    }

    // Recheck après fermeture de l'offre d'abonnement
    func updateCatalogPlaybackCapability() async {
        let can = await canPlayFullCatalog()
        canPlayCatalogContent = can
    }
    
    // Prépare la musique SANS jouer — appelé en parallèle avec runCountdownAsync().
    // Détecte catalogue vs preview, charge, prépositionne. Zéro latence au play().
    private func prepareMusicForPlayback(song: BlindTestSong) async {
        player?.pause()
        player = nil
        if let obs = previewEndObserver {
            NotificationCenter.default.removeObserver(obs)
            previewEndObserver = nil
        }

        // Use cached canPlayCatalogContent (updated on appear + via subscription observer)
        // to avoid re-running MusicAuthorization.request() before every round.
        if canPlayCatalogContent {
            do {
                try await prepareFullTrack(song: song)
            } catch {
                if !hasShownSubscriptionInfo {
                    subscriptionAlertMessage = "Impossible de lire le titre complet. Lecture de l'extrait à la place."
                    showSubscriptionAlert = true
                    hasShownSubscriptionInfo = true
                }
                try? await preparePreviewPlayer(song: song)
            }
        } else {
            if !hasShownSubscriptionInfo {
                subscriptionAlertMessage = "Pour lire le morceau en entier, un abonnement Apple Music est requis. Lecture de l'extrait à la place."
                showSubscriptionAlert = true
                hasShownSubscriptionInfo = true
            }
            try? await preparePreviewPlayer(song: song)
        }
    }

    // Prépare le catalogue Apple Music (fetchSong + prepareToPlay + position à 0s).
    private func prepareFullTrack(song: BlindTestSong) async throws {
        let catalogSong = try await appleMusicService.fetchSong(by: song.appleMusicID)
        musicPlayer.queue = .init(for: [catalogSong])
        try await musicPlayer.prepareToPlay()
        musicPlayer.playbackTime = 0
        isPreviewMode = false
        // Prêt : il suffira d'appeler musicPlayer.play() dans playPreparedMusicNow()
    }

    // Prépare un AVPlayer preview (crée, seek à 0, observe fin).
    private func preparePreviewPlayer(song: BlindTestSong) async throws {
        guard let url = song.previewURL else { return }
        let item = AVPlayerItem(url: url)
        let newPlayer = AVPlayer(playerItem: item)
        newPlayer.seek(to: .zero, completionHandler: { _ in })
        isPreviewMode = true
        // Pas de play() ici — juste positionnement et buffering
        previewEndObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in self?.handlePreviewEnd() }
        }
        self.player = newPlayer
    }

    // Joue immédiatement la musique préparée, envoie timerStarted, démarre le timer.
    // Appelé juste après que countdown + prep soient tous les deux terminés.
    private func playPreparedMusicNow() {
        let timestamp = Date().timeIntervalSince1970
        gameVM.mpcService.sendMessage(.timerStarted(TimerStartPayload(masterTimestamp: timestamp)))
        startReactionTimer()
        isPlaying = true
        isFetching = false

        if let player = player {
            // Mode preview : play synchrone → latence nulle
            player.play()
        } else {
            // Mode catalogue : déjà préparé, play quasi-instantané
            Task { try? await musicPlayer.play() }
        }

        gameVM.broadcastPublicStateFromCurrentGame()
    }
    
    /// Relance la musique depuis le début (preview AVPlayer → seek to .zero / MusicKit → playbackTime = 5s)
    /// Appelé par rejectAnswer() quand le preview s'était terminé avant le buzz.
    func restartMusicFromBeginning() {
        if let player = player {
            // Mode preview (AVPlayer) : rembobine au début de l'extrait
            player.seek(to: .zero)
            player.play()
        } else {
            // Mode catalogue Apple Music (MusicKit) : repositionne à 0s
            Task {
                musicPlayer.playbackTime = 0
                try? await musicPlayer.play()
            }
        }
    }

    func pause() {
        // Pause le timer (sans reset) et la musique
        pauseReactionTimer()
        player?.pause()
        musicPlayer.pause()
    }
    
    func resume() {
        if let player {
            player.play()
        } else {
            Task { try? await musicPlayer.play() }
        }
    }
    
    func stop() {
        player?.pause()
        player = nil
        musicPlayer.stop()
    }
    
    nonisolated static func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
        } catch {
            print("AudioSession error:", error)
        }
    }
}

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
    var isGameActive: Bool = false
    
    var nowPlayingSongIndex: Int = 0
    var isCorrect: Bool = false
    
    var playerHasBuzz: Player? = nil
    var playedSongs: [BlindTestSong] = []

    var state: RoundState = .idle
    var roundCountdownPhase: RoundCountdownPhase = .hidden
    private var roundCountdownTimer: Timer?

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
    
    //MARK: données de jeu
    init(gameVM: MasterFlowViewModel) {
        self.gameVM = gameVM
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
    
    @MainActor func validateAnswer(points: Int) {
        guard let playerAnswers = playerHasBuzz else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        if let song = selectedMusic, !playedSongs.contains(song) {
            playedSongs.append(song)
        }

        isCorrect = true
        state = .finished

        // MARK: mise à jour du score via gameVM.addPoints(...)
        gameVM.addPointToPlayer(playerAnswers, points: points)

        // on fige définitivement la manche
        stopReactionTimer()
        pause()
        isPlaying = false

        // ✅ update public display (answer revealed)
        gameVM.broadcastPublicStateFromCurrentGame()

        // ✅ Envoyer le résultat aux Players
        let resultPayload = AnswerResultPayload(isCorrect: true, points: points, correctAnswer: nil)
        gameVM.mpcService.sendMessage(.answerResult(resultPayload))

        // (optionnel) on nettoie ensuite la sélection
        selectedMusic = nil
        isGameActive = false
    }
    
    @MainActor func rejectAnswer() {
        guard case .buzzed = state else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.warning)

        isCorrect = false
        playerHasBuzz = nil
        state = .playing

        let resultPayload = AnswerResultPayload(isCorrect: false, points: 0, correctAnswer: nil)
        gameVM.mpcService.sendMessage(.answerResult(resultPayload))

        gameVM.broadcastPublicStateFromCurrentGame()

        startRoundCountdown {
            self.gameVM.unlockBuzz()
            self.resume()
            self.isPlaying = true
            self.startReactionTimer()
            self.gameVM.broadcastPublicStateFromCurrentGame()
        }
    }

    @MainActor private func startRoundCountdown(onComplete: @escaping @MainActor () -> Void) {
        roundCountdownPhase = .hidden
        roundCountdownTimer?.invalidate()
        gameVM.broadcastPublicStateFromCurrentGame()
        Task { @MainActor [weak self] in
            try? await Task.sleep(for: .seconds(2))
            guard let self else { return }
            var count = 3
            self.roundCountdownPhase = .counting(count)
            self.gameVM.broadcastPublicStateFromCurrentGame()
            self.roundCountdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                Task { @MainActor [weak self] in
                    guard let self else { return }
                    count -= 1
                    if count > 0 {
                        self.roundCountdownPhase = .counting(count)
                        self.gameVM.broadcastPublicStateFromCurrentGame()
                    } else {
                        self.roundCountdownTimer?.invalidate()
                        self.roundCountdownTimer = nil
                        self.roundCountdownPhase = .go
                        self.gameVM.broadcastPublicStateFromCurrentGame()
                        try? await Task.sleep(for: .seconds(0.8))
                        self.roundCountdownPhase = .hidden
                        self.gameVM.broadcastPublicStateFromCurrentGame()
                        onComplete()
                    }
                }
            }
        }
    }
}

//MARK: Round Funcs
extension BlindTestMasterViewModel {
    func startRound() {
        guard let selectedMusic = selectedMusic else { return }

        Task {
            await MainActor.run {
                self.reactionTimeMs = 0
                self.playerHasBuzz = nil
                self.isCorrect = false
                self.state = .playing
                self.isGameActive = true   // ← Master bascule sur BlindTestActiveScreen immédiatement
                self.isFetching = true
                self.configureAudioSession()
            }

            startRoundCountdown {
                self.gameVM.unlockBuzz()
                self.playMusicAfterCountdown(song: selectedMusic)
            }
        }
    }

    @MainActor private func playMusicAfterCountdown(song: BlindTestSong) {
        Task {
            do {
                if await canPlayFullCatalog() {
                    do {
                        try await playFullTrackFromFiveSeconds(song: song, startAt: 5)
                    } catch {
                        if !self.hasShownSubscriptionInfo {
                            self.subscriptionAlertMessage = "Impossible de lire le titre complet. Lecture de l’extrait à la place."
                            self.showSubscriptionAlert = true
                            self.hasShownSubscriptionInfo = true
                        }
                        try await playRandomPreview(song: song)
                    }
                } else {
                    if !self.hasShownSubscriptionInfo {
                        self.subscriptionAlertMessage = "Pour lire le morceau en entier, un abonnement Apple Music est requis. Lecture de l’extrait à la place."
                        self.showSubscriptionAlert = true
                        self.hasShownSubscriptionInfo = true
                    }
                    try await playRandomPreview(song: song)
                }

                await MainActor.run {
                    self.isGameActive = true
                    self.isPlaying = true
                    self.startReactionTimer()
                    self.isFetching = false
                    self.gameVM.broadcastPublicStateFromCurrentGame()
                }
            } catch {
                await MainActor.run {
                    self.isGameActive = false
                    self.isFetching = false
                    self.fetchError = "Impossible de lancer la musique. Vérifie ta connexion et réessaie."
                    self.gameVM.broadcastPublicStateFromCurrentGame()
                }
            }
        }
    }

    @MainActor func cancelRound() {
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

    @MainActor func handlePreviewEnd() {
        guard case .playing = state else { return }
        isPlaying = false
        stopReactionTimer()
        gameVM.broadcastPublicStateFromCurrentGame()
    }
}

//MARK: BuzzDrivenGame conformance
extension BlindTestMasterViewModel {
    @MainActor
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
                        isPlaying: true
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
                       isPlaying: false
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
                       isPlaying: false
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
            await MainActor.run {
                isFetching = false
                self.playlists = results
            }
        } catch {
            await MainActor.run {
                isFetching = false
                fetchError = "Impossible de chercher les playlists. Vérifie ta connexion."
            }
        }
    }
    
    func selectPlaylist(_ playlist: BlindTestPlaylist) async {
        do {
            isFetching = true
            let songs = try await appleMusicService.loadSongs(from: playlist)
            await MainActor.run {
                isFetching = false
                self.allSongs = songs
            }
        } catch {
            await MainActor.run {
                isFetching = false
                fetchError = "Impossible de charger cette playlist. Réessaie."
            }
        }
    }
    
    //MARK: functions Song playing
    
    // Autorisation + éligibilité
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
    
    // Met à jour le booléen (pour le badge)
    @MainActor
    func updateCatalogPlaybackCapability() async {
        let can = await canPlayFullCatalog()
        self.canPlayCatalogContent = can
    }

    // Écoute les changements d'abonnement en temps réel
    func observeSubscriptionUpdates() {
        Task {
            for await subscription in MusicSubscription.subscriptionUpdates {
                await MainActor.run {
                    self.canPlayCatalogContent = subscription.canPlayCatalogContent
                }
            }
        }
    }
    
    func playRandomPreview(
        song: BlindTestSong,
        maxDuration: TimeInterval = 30
    ) async throws {
        guard let url = song.previewURL else { return }

        await MainActor.run {
            player?.pause()
            player = nil
            if let obs = previewEndObserver {
                NotificationCenter.default.removeObserver(obs)
                previewEndObserver = nil
            }

            let item = AVPlayerItem(url: url)
            let newPlayer = AVPlayer(playerItem: item)

            // Preview ≈ 30s → on démarre aléatoirement
            let randomStart = Double.random(in: 0...max(0, maxDuration - 10))
            let time = CMTime(seconds: randomStart, preferredTimescale: 600)
            newPlayer.seek(to: time)
            newPlayer.play()

            // ✅ Envoyer le message AVANT de démarrer (pour sync avec timestamp)
            let timestamp = Date().timeIntervalSince1970
            self.gameVM.mpcService.sendMessage(.timerStarted(TimerStartPayload(masterTimestamp: timestamp)))
            
            // ✅ Démarrer le timer IMMÉDIATEMENT avec le son
            self.startReactionTimer()

            previewEndObserver = NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: item,
                queue: .main
            ) { [weak self] _ in
                Task { @MainActor in
                    self?.handlePreviewEnd()
                }
            }

            isFetching = false
            self.player = newPlayer
            self.isPlaying = true
        }
    }
    
    // Lecture complète via Apple Music (abonnement requis), démarrage à 5s par défaut
    func playFullTrackFromFiveSeconds(
        song: BlindTestSong,
        startAt seconds: TimeInterval = 5
    ) async throws {
        await MainActor.run {
            player?.pause()
            player = nil
        }

        // Récupère l'objet Song à partir de son ID
        let catalogSong = try await appleMusicService.fetchSong(by: song.appleMusicID)

        // Construit la queue avec le Song (et non pas l'ID)
        musicPlayer.queue = .init(for: [catalogSong])

        // Prépare, positionne le temps de lecture, puis joue
        try await musicPlayer.prepareToPlay()
        musicPlayer.playbackTime = seconds
        try await musicPlayer.play()

        // ✅ Envoyer le message AVANT de démarrer (pour sync avec timestamp)
        await MainActor.run {
            isFetching = false
            self.isPlaying = true
            
            let timestamp = Date().timeIntervalSince1970
            self.gameVM.mpcService.sendMessage(.timerStarted(TimerStartPayload(masterTimestamp: timestamp)))
            
            // ✅ Démarrer le timer IMMÉDIATEMENT avec le son
            self.startReactionTimer()
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
    
    func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
        } catch {
            print("AudioSession error:", error)
        }
    }
}

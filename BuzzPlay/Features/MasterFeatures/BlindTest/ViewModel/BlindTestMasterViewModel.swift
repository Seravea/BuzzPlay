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
    var currentHintIndex: Int = 0  // Hint displayed for the current song
    var isGameActive: Bool = false

    var nowPlayingSongIndex: Int = 0
    var isCorrect: Bool = false
    
    var playerHasBuzz: Player? = nil
    var playedSongs: [BlindTestSong] = []

    var state: RoundState = .idle
    var roundCountdownPhase: RoundCountdownPhase = .hidden
    // Task du countdown en cours — annulable via cancelRound()
    private var countdownTask: Task<Void, Never>?

    // true quand le preview/titre s'est terminé naturellement (timer expiré)
    // → rejectAnswer doit relancer la musique depuis le début au lieu de resume()
    private var musicHasEnded = false

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
        gameVM.blindTestRoundsPlayed += 1

        let finalPoints = doubledScorePlayers.remove(playerAnswers.id) != nil ? points * 2 : points
        gameVM.addPointToPlayer(playerAnswers, points: finalPoints)

        // on fige définitivement la manche
        stopReactionTimer()
        pause()
        isPlaying = false

        // ✅ update public display (answer revealed)
        gameVM.broadcastPublicStateFromCurrentGame()

        // ✅ Envoyer le résultat aux Players
        let resultPayload = AnswerResultPayload(isCorrect: true, points: finalPoints, correctAnswer: nil)
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
        // isPlaying reste false → makePublicState émet isPlaying:false → Player ne relance pas son timer

        let resultPayload = AnswerResultPayload(isCorrect: false, points: 0, correctAnswer: nil)
        gameVM.mpcService.sendMessage(.answerResult(resultPayload))
        gameVM.broadcastPublicStateFromCurrentGame()

        countdownTask = Task { @MainActor [weak self] in
            guard let self else { return }
            await runCountdownAsync()
            guard !Task.isCancelled else { return }
            gameVM.unlockBuzz()
            if musicHasEnded {
                restartMusicFromBeginning()
                musicHasEnded = false
            } else {
                resume()
            }
            isPlaying = true
            startReactionTimer()
            gameVM.broadcastPublicStateFromCurrentGame()
        }
    }

    // Countdown async pur — interleave coopératif avec prepareMusicForPlayback via async let
    @MainActor private func runCountdownAsync() async {
        roundCountdownPhase = .hidden
        gameVM.broadcastPublicStateFromCurrentGame()

        try? await Task.sleep(for: .seconds(2))
        guard !Task.isCancelled else { roundCountdownPhase = .hidden; return }

        for count in stride(from: 3, through: 1, by: -1) {
            roundCountdownPhase = .counting(count)
            gameVM.broadcastPublicStateFromCurrentGame()
            try? await Task.sleep(for: .seconds(1))
            guard !Task.isCancelled else { roundCountdownPhase = .hidden; return }
        }

        roundCountdownPhase = .go
        gameVM.broadcastPublicStateFromCurrentGame()
        try? await Task.sleep(for: .milliseconds(800))
        guard !Task.isCancelled else { roundCountdownPhase = .hidden; return }

        roundCountdownPhase = .hidden
        gameVM.broadcastPublicStateFromCurrentGame()
    }
}

//MARK: Round Funcs
extension BlindTestMasterViewModel {

    // Lance countdown ET chargement musique EN PARALLÈLE (async let).
    // La musique est prête avant la fin du countdown → play() sans latence.
    func startRound() {
        guard let selectedMusic = selectedMusic else { return }
        isFetching = true  // spinner immédiat

        countdownTask = Task { @MainActor [weak self] in
            guard let self else { return }

            currentHintIndex = Int.random(in: 0..<BlindTestHints.phrases.count)
            reactionTimeMs = 0
            playerHasBuzz = nil
            isCorrect = false
            musicHasEnded = false
            state = .playing
            isGameActive = true
            configureAudioSession()

            // Countdown (5.8 s) ET chargement musique en parallèle
            async let countdown: Void = runCountdownAsync()
            async let musicPrep: Void = prepareMusicForPlayback(song: selectedMusic)
            _ = await (countdown, musicPrep)

            guard !Task.isCancelled else { return }

            gameVM.unlockBuzz()
            playPreparedMusicNow()
        }
    }

    @MainActor func cancelRound() {
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

    @MainActor func handlePreviewEnd() {
        switch state {
        case .playing:
            // Musique terminée → reboucle depuis le début, timer continue
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
    @MainActor
    func applyGiftEffect(_ gift: CoinsViewModel.Gift, to player: Player) {
        switch gift {
        case .scoreDoubled:
            doubledScorePlayers.insert(player.id)

        case .showIndicies:
            guard let song = selectedMusic else { return }
            let hint = buildBlindTestHint(song: song)
            gameVM.mpcService.sendMessagetoOnePlayer(message: .hintRevealedToPlayer(hint), player: player)

        case .changeBuzzColor:
            guard let idx = gameVM.players.firstIndex(where: { $0.id == player.id }) else { return }
            let colors = GameColor.allCases.filter { $0 != gameVM.players[idx].teamColor }
            gameVM.players[idx].customBuzzColor = colors.randomElement()
            gameVM.mpcService.sendMessage(.updatedPlayer(gameVM.players[idx]))

        case .changeBuzzSound:
            guard let idx = gameVM.players.firstIndex(where: { $0.id == player.id }) else { return }
            gameVM.players[idx].customBuzzSound = buzzSoundNames.randomElement()
            gameVM.mpcService.sendMessage(.updatedPlayer(gameVM.players[idx]))

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
                        isPlaying: isPlaying,   // false pendant le countdown → Player ne relance pas son timer trop tôt
                        hintIndex: currentHintIndex
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
                       hintIndex: currentHintIndex
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
                       hintIndex: currentHintIndex
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
    
    // Prépare la musique SANS jouer — appelé en parallèle avec runCountdownAsync().
    // Détecte catalogue vs preview, charge, prépositionne. Zéro latence au play().
    @MainActor private func prepareMusicForPlayback(song: BlindTestSong) async {
        player?.pause()
        player = nil
        if let obs = previewEndObserver {
            NotificationCenter.default.removeObserver(obs)
            previewEndObserver = nil
        }

        if await canPlayFullCatalog() {
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

    // Prépare le catalogue Apple Music (fetchSong + prepareToPlay + position à 5s).
    @MainActor private func prepareFullTrack(song: BlindTestSong) async throws {
        let catalogSong = try await appleMusicService.fetchSong(by: song.appleMusicID)
        musicPlayer.queue = .init(for: [catalogSong])
        try await musicPlayer.prepareToPlay()
        musicPlayer.playbackTime = 5
        // Prêt : il suffira d'appeler musicPlayer.play() dans playPreparedMusicNow()
    }

    // Prépare un AVPlayer preview (crée, seek position aléatoire, observe fin).
    @MainActor private func preparePreviewPlayer(song: BlindTestSong) async throws {
        guard let url = song.previewURL else { return }
        let item = AVPlayerItem(url: url)
        let newPlayer = AVPlayer(playerItem: item)
        let randomStart = Double.random(in: 0...20)   // preview ~30s, on démarre dans les 20 premières secondes
        // completionHandler force la version synchrone (sans await) — on n'a pas besoin d'attendre la fin du seek
        newPlayer.seek(to: CMTime(seconds: randomStart, preferredTimescale: 600), completionHandler: { _ in })
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
    @MainActor private func playPreparedMusicNow() {
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
    @MainActor func restartMusicFromBeginning() {
        if let player = player {
            // Mode preview (AVPlayer) : rembobine au début de l'extrait
            player.seek(to: .zero)
            player.play()
        } else {
            // Mode catalogue Apple Music (MusicKit) : repositionne à 5s
            Task {
                musicPlayer.playbackTime = 5
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

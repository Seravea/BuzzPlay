//
//  BlindTestViewModel.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 12/11/2025.
//

import Foundation
import SwiftUI
import AVFoundation
import Observation
import MusicKit

@Observable
class BlindTestMasterViewModel: BuzzDrivenGame {
    
    let gameVM: MasterFlowViewModel
    let appleMusicService = AppleMusicService()
    
    //MARK: données de manche en cours
    var isPlaying: Bool = false
    
    var allSongs: [BlindTestSong] = []
    var playlists: [BlindTestPlaylist] = []
    var selectedMusic: BlindTestSong? = nil
    
    var nowPlayingSongIndex: Int = 0
    var isCorrect: Bool = false
    
    var teamHasBuzz: Team? = nil
    
    var state: RoundState = .idle
    
    //MARK: Timer's datas
    var reactionTimeMs: Int = 0
    var timer: Timer?
    
    //MARK: UI alert (abonnement requis)
    var showSubscriptionAlert: Bool = false
    var subscriptionAlertMessage: String = "Pour lire le morceau en entier, un abonnement Apple Music est requis. Lecture de l'extrait à la place."
    
    // Badge/Disponibilité lecture catalogue
    var canPlayCatalogContent: Bool = false
    
    enum RoundState {
        case idle // next song and master hasn't lunch round/music
        case playing // in game and music playing
        case buzzed(Team) // response receive
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
    var questionNumber: Int {
        nowPlayingSongIndex + 1
    }
    
    var totalNumberOfSongs: Int {
        allSongs.count
    }
    
    var progressValue: Double {
        guard totalNumberOfSongs > 0 else { return 0 }
        return Double(questionNumber) / Double(totalNumberOfSongs)
    }
    
    var progressText: String {
        "Question \(questionNumber)/\(totalNumberOfSongs)"
    }
    
    /// Valide la réponse de l'équipe gagnante (teamWining)
    /// Arrête la manche et fige le temps
    @MainActor func validateAnswer(points: Int) {
        guard let teamAnswers = teamHasBuzz else { return }
        
        isCorrect = true
        state = .finished
        
        // MARK: mise à jour du score via gameVM.addPoints(...)
        gameVM.addPointToTeam(teamAnswers, points: points)
        
        // on fige définitivement la manche
        stopReactionTimer()
        pause()
        isPlaying = false
        selectedMusic = nil
    }
    
    /// Refuse la réponse de l'équipe qui a buzzé
    /// Reprend la manche là où elle avait été mise en pause
    @MainActor func rejectAnswer() {
        // si aucune équipe n'avait buzzé, on ne fait rien
        guard case .buzzed = state else { return }
        
        isCorrect = false
        teamHasBuzz = nil
        state = .playing
        
        // on redémarre le timer sans reset (reprise de la manche) et autorise les buzz
        gameVM.unlockBuzz()
        startReactionTimer()
        
        // on relance la musique à partir de là où elle avait été mise en pause
        resume()
        isPlaying = true
    }
}

//MARK: Round Funcs
extension BlindTestMasterViewModel {
    func startRound() {
        // si aucune musique selectionné, on ne fait rien
        guard let selectedMusic = selectedMusic else { return }
        
        Task {
            do {
                // Essaye lecture complète si l'utilisateur peut lire le catalogue
                if await canPlayFullCatalog() {
                    do {
                        try await playFullTrackFromFiveSeconds(song: selectedMusic, startAt: 5)
                    } catch {
                        // En cas d'échec de la lecture catalogue, alerte + fallback preview
                        await MainActor.run {
                            self.showSubscriptionAlert = true
                            self.subscriptionAlertMessage = "Impossible de lire le titre complet. Lecture de l'extrait à la place."
                        }
                        try await playRandomPreview(song: selectedMusic)
                    }
                } else {
                    // Pas abonné → alerte + preview
                    await MainActor.run {
                        self.showSubscriptionAlert = true
                        self.subscriptionAlertMessage = "Pour lire le morceau en entier, un abonnement Apple Music est requis. Lecture de l'extrait à la place."
                    }
                    try await playRandomPreview(song: selectedMusic)
                }
                
                // IMPORTANT: tout ce qui touche l’UI + démarrage du timer sur le MainActor
                await MainActor.run {
                    self.reactionTimeMs = 0
                    self.teamHasBuzz = nil
                    self.isCorrect = false
                    self.state = .playing
                    
                    self.gameVM.unlockBuzz()
                    self.startReactionTimer()
                }
            } catch {
                print("error when play random song:", error)
            }
        }
    }
}

//MARK: BuzzDrivenGame conformance
extension BlindTestMasterViewModel {
    @MainActor
    func handleBuzz(from team: Team) {
        // Ignorer les buzz si la manche n'est pas en cours
        guard case .playing = state else { return }
        
        teamHasBuzz = team
        state = .buzzed(team)
        
        // Pause uniquement: timer + musique (ne pas reset, pour pouvoir reprendre)
        pause()
        isPlaying = false
    }
    
    func makePublicState() -> PublicState {
        // À implémenter quand vous aurez un PublicState spécifique au BlindTest
        return .waiting
    }
}

//MARK: Apple Music functions
extension BlindTestMasterViewModel {
    func search(query: String) async {
        do {
            let results = try await appleMusicService.searchPlaylists(query: query)
            await MainActor.run {
                self.playlists = results
            }
        } catch {
            print("Erreur recherche playlists:", error)
        }
    }
    
    func selectPlaylist(_ playlist: BlindTestPlaylist) async {
        do {
            let songs = try await appleMusicService.loadSongs(from: playlist)
            await MainActor.run {
                self.allSongs = songs
            }
        } catch {
            print("Erreur chargement playlist:", error)
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
    
    func playRandomPreview(
        song: BlindTestSong,
        maxDuration: TimeInterval = 30
    ) async throws {
        guard let url = song.previewURL else { return }
        
        await MainActor.run {
            configureAudioSession()
            
            player?.pause()
            player = nil
            
            let item = AVPlayerItem(url: url)
            let newPlayer = AVPlayer(playerItem: item)
            
            // Preview ≈ 30s → on démarre aléatoirement
            let randomStart = Double.random(in: 0...max(0, maxDuration - 10))
            let time = CMTime(seconds: randomStart, preferredTimescale: 600)
            
            newPlayer.seek(to: time)
            newPlayer.play()
            
            self.player = newPlayer
            self.isPlaying = true
        }
    }
    
    // Lecture complète via Apple Music (abonnement requis), démarrage à 5s par défaut
    func playFullTrackFromFiveSeconds(
        song: BlindTestSong,
        startAt seconds: TimeInterval = 5
    ) async throws {
        // Arrête un éventuel AVPlayer (preview)
        await MainActor.run {
            configureAudioSession()
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
        
        await MainActor.run {
            self.isPlaying = true
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

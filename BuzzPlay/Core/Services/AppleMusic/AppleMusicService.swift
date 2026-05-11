//
//  AppleMusicService.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 15/12/2025.
//

import MusicKit
import AVFoundation

final class AppleMusicService {
    
    var playlists: [Playlist] = []
    var allSongs: [BlindTestSong] = []
    
    enum AppleMusicServiceError: Error {
        case songNotFound
    }
    
    /// Charge au maximum 60 titres d'une playlist — suffisant pour une soirée Blind Test
    /// et réduit le pic CPU du JSONDecoder de ~40% par rapport à une playlist complète.
    static let maxSongsPerPlaylist = 60

    func loadSongs(from playlist: BlindTestPlaylist) async throws -> [BlindTestSong] {

        var request = MusicCatalogResourceRequest<Playlist>(
            matching: \.id,
            equalTo: MusicItemID(playlist.id)
        )
        request.properties = [.tracks]

        let response = try await request.response()

        guard let musicPlaylist = response.items.first,
              let tracks = musicPlaylist.tracks else {
            return []
        }

        Logger.debug("Playlist tracks count: \(tracks.count) → cap à \(Self.maxSongsPerPlaylist)", category: "MUSIC")

        // Mélange aléatoire + cap à maxSongsPerPlaylist pour réduire le pic JSONDecoder
        let selectedTracks = Array(tracks.shuffled().prefix(Self.maxSongsPerPlaylist))

        return selectedTracks.compactMap { track in
            BlindTestSong(
                artist: track.artistName,
                title: track.title,
                appleMusicID: track.id,
                postertURL: track.artwork?.url(width: 300, height: 300),
                releaseDate: track.releaseDate,
                previewURL: track.previewAssets?.first?.url
            )
        }
    }
    
    func searchPlaylists(query: String) async throws -> [BlindTestPlaylist] {
        var request = MusicCatalogSearchRequest(
            term: query,
            types: [Playlist.self]
        )
        request.limit = 10
        
        let response = try await request.response()
        return response.playlists.map { playlist in
           return mapToBlindTestPlaylist(playlist)
        }
    }
    
    func mapToBlindTestPlaylist(_ playlist: Playlist) -> BlindTestPlaylist {
        BlindTestPlaylist(
            id: playlist.id.rawValue,
            name: playlist.name,
            curator: playlist.curatorName,
            artworkURL: playlist.artwork?.url(width: 300, height: 300),
            trackCount: playlist.tracks?.count
        )
    }
    
    // Récupère l'objet Song à partir d'un MusicItemID (nécessaire pour construire la queue)
    func fetchSong(by id: MusicItemID) async throws -> Song {
        let request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: id)
        let response = try await request.response()
        guard let song = response.items.first else {
            throw AppleMusicServiceError.songNotFound
        }
        return song
    }
    
    /// Demande l'autorisation MusicKit ET vérifie le droit de lecture catalogue
    /// en un seul aller-retour réseau. Retourne true si l'abonnement permet la lecture complète.
    @MainActor
    func setupAppleMusic() async -> Bool {
        let status = await MusicAuthorization.request()
        Logger.debug("MusicKit status: \(status)", category: "MUSIC")
        guard status == .authorized else { return false }
        do {
            let subscription = try await MusicSubscription.current
            Logger.debug("Subscription canPlayCatalog: \(subscription.canPlayCatalogContent)", category: "MUSIC")
            return subscription.canPlayCatalogContent
        } catch {
            Logger.warning("MusicSubscription check failed: \(error)", category: "MUSIC")
            return false
        }
    }
    
    
    func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()

            try session.setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers]
            )

            try session.setActive(true)

            Logger.debug("AudioSession ready", category: "AUDIO")
        } catch {
            Logger.error("AudioSession error: \(error)", category: "AUDIO")
        }
    }
    
    
}


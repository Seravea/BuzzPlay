//
//  AppleMusicService.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 15/12/2025.
//

import MusicKit
import AVFoundation

import MusicKit

final class AppleMusicService {
    
    var playlists: [Playlist] = []
    var allSongs: [BlindTestSong] = []
    
    
    func loadSongs(from playlist: BlindTestPlaylist) async throws -> [BlindTestSong] {

        var request = MusicCatalogResourceRequest<Playlist>(
            matching: \.id,
            equalTo: MusicItemID(playlist.id)
        )

        // 👇 OBLIGATOIRE
        request.properties = [.tracks]

        let response = try await request.response()

        guard let musicPlaylist = response.items.first,
              let tracks = musicPlaylist.tracks else {
            return []
        }
        print("Playlist tracks count:", tracks.count)
        return tracks.compactMap { track in
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
    
    @MainActor
    func setupAppleMusic() async {
        let status = await MusicAuthorization.request()
        print("MusicKit status:", status)
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

            print("🔊 AudioSession ready")
        } catch {
            print("❌ AudioSession error:", error)
        }
    }
    
    
}

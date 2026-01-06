//
//  Song.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 12/11/2025.
//
import MusicKit
import Foundation


struct BlindTestSong: Identifiable, Equatable {
    var id = UUID()
    let artist: String
    let title: String
    var appleMusicID: MusicItemID
    let postertURL: URL?
    let releaseDate: Date?
    let previewURL: URL?
    var releaseYearString: String {
        if let releaseYear = releaseDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy"
            return dateFormatter.string(from: releaseYear)
        } else {
            return "No Date"
        }
    }
    
    
    
}

extension BlindTestSong {
    init?(from song: Song) {
        guard let artwork = song.artwork?.url(width: 300, height: 300) else {
            return nil
        }
        guard let previewURL = song.previewAssets?.first?.url else {
            return nil
        }
        guard let date = song.releaseDate else {
            return nil
        }

        self.id = UUID()
        self.artist = song.artistName
        self.title = song.title
        self.appleMusicID = song.id
        self.postertURL = artwork
        self.releaseDate = date
        self.previewURL = previewURL
    }
}


//var songsData: [BlindTestSong] = [
//    BlindTestSong(
//        artist: "Onoe Caponoe",
//        title: "Falling",
//        creationYear: "2006"
//    ),
//    BlindTestSong(
//        artist: "SCENE",
//        title: "Out of Love",
//        creationYear: "1998"
//    ),
//    BlindTestSong(
//        artist: "SCENE",
//        title: "Pillow",
//        creationYear: "2004"
//    ),
//    BlindTestSong(
//        artist: "Jobii",
//        title: "Shuffle Step",
//        creationYear: "2002"
//    )
//]
//

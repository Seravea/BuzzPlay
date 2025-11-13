//
//  Song.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 12/11/2025.
//

import Foundation


struct Song: Identifiable {
    var id: String {
        return "\(title) - \(artist)"
    }
    var artist: String
    var title: String
    var creationYear: String
}


var songsData: [Song] = [
    Song(
        artist: "Onoe Caponoe",
        title: "Falling",
        creationYear: "2006"
    ),
    Song(
        artist: "SCENE",
        title: "Out of Love",
        creationYear: "1998"
    ),
    Song(
        artist: "SCENE",
        title: "Pillow",
        creationYear: "2004"
    ),
    Song(
        artist: "Jobii",
        title: "Shuffle Step",
        creationYear: "2002"
    )
]


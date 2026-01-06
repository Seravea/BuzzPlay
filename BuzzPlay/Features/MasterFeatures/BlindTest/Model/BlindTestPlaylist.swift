//
//  BlindTestPlaylist.swift
//  BuzzPlay
//
//  Created by Apprenant 102 on 17/12/2025.
//

import Foundation

struct BlindTestPlaylist: Identifiable, Hashable {
    let id: String              // ID Apple Music de la playlist
    let name: String
    let curator: String?
    let artworkURL: URL?
    let trackCount: Int?
}

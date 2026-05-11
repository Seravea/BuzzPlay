import Foundation
import MusicKit
@testable import BuzzPlay

enum SampleBlindTestSongs {
    static let song1 = BlindTestSong(
        id: UUID(),
        artist: "Daft Punk",
        title: "Get Lucky",
        appleMusicID: MusicItemID("123456789"),
        postertURL: nil,
        releaseDate: Date(timeIntervalSince1970: 1_370_000_000), // ~2013
        previewURL: nil
    )

    static let song2 = BlindTestSong(
        id: UUID(),
        artist: "Michael Jackson",
        title: "Billie Jean",
        appleMusicID: MusicItemID("987654321"),
        postertURL: nil,
        releaseDate: Date(timeIntervalSince1970: 415_000_000), // ~1983
        previewURL: nil
    )

    static let song3 = BlindTestSong(
        id: UUID(),
        artist: "Beyoncé",
        title: "Crazy in Love",
        appleMusicID: MusicItemID("111222333"),
        postertURL: nil,
        releaseDate: Date(timeIntervalSince1970: 1_056_000_000), // ~2003
        previewURL: nil
    )
}

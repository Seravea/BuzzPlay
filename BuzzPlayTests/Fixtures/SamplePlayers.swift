import Foundation
@testable import BuzzPlay

enum SamplePlayers {
    static let alice = Player(name: "Alice", teamColor: .purpleGame, score: 0)
    static let bob   = Player(name: "Bob",   teamColor: .blueGame,   score: 0)
    static let withScore = Player(name: "Charlie", teamColor: .greenGame, score: 100)
}

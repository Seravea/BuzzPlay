import Foundation
@testable import BuzzPlay

/// Mock de MasterGameHost pour les tests unitaires des Game ViewModels.
/// Permet de vérifier les appels sans démarrer MPC ni le réseau.
@MainActor
final class MockMasterGameHost: MasterGameHost {

    // MARK: - Protocol properties
    var mpcService: MPCService = MPCService(peerName: "TestMaster", role: .master)
    var players: [Player] = []
    var connectedPlayersCount: Int = 0
    var totalPlayersCount: Int = 0
    var currentBuzzPlayer: Player? = nil

    // MARK: - Spy counters
    var addPointCallCount = 0
    var lastAddedPoints: Int = 0
    var lastAddedPlayer: Player? = nil

    var unlockBuzzCallCount = 0
    var broadcastPublicStateCallCount = 0
    var sendPublicStateCallCount = 0
    var broadcastGameLaunchCallCount = 0
    var setBuzzPlayerCallCount = 0
    var resetBuzzStateCallCount = 0

    var lastSentPublicState: PublicState? = nil

    // MARK: - Protocol methods
    func addPointToPlayer(_ player: Player, points: Int) {
        addPointCallCount += 1
        lastAddedPlayer = player
        lastAddedPoints = points
        if let index = players.firstIndex(where: { $0.id == player.id }) {
            players[index].score += points
        }
    }

    func unlockBuzz() {
        unlockBuzzCallCount += 1
        currentBuzzPlayer = nil
    }

    func broadcastPublicStateFromCurrentGame() {
        broadcastPublicStateCallCount += 1
    }

    func sendPublicState(_ state: PublicState) {
        sendPublicStateCallCount += 1
        lastSentPublicState = state
    }

    func broadcastGameLaunch(_ game: GameType) {
        broadcastGameLaunchCallCount += 1
    }

    func setBuzzPlayer(_ player: Player) {
        setBuzzPlayerCallCount += 1
        currentBuzzPlayer = player
    }

    func resetBuzzState() {
        resetBuzzStateCallCount += 1
        currentBuzzPlayer = nil
    }
}

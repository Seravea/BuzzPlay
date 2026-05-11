import XCTest
@testable import BuzzPlay

@MainActor
final class MasterFlowViewModelTests: XCTestCase {

    var sut: MasterFlowViewModel!

    override func setUp() {
        super.setUp()
        sut = MasterFlowViewModel()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - addPlayer

    func test_addPlayer_appendsNewPlayer() {
        sut.addPlayer(SamplePlayers.alice)
        XCTAssertEqual(sut.players.count, 1)
        XCTAssertEqual(sut.players.first?.name, "Alice")
    }

    func test_addPlayer_doesNotDuplicateOnSecondJoin() {
        sut.addPlayer(SamplePlayers.alice)
        sut.addPlayer(SamplePlayers.alice)
        XCTAssertEqual(sut.players.count, 1)
    }

    func test_addPlayer_registersInAllRegisteredPlayers() {
        sut.addPlayer(SamplePlayers.bob)
        XCTAssertEqual(sut.allRegisteredPlayers.count, 1)
    }

    func test_addPlayer_restoresScoreOnReconnect() {
        var alice = SamplePlayers.alice
        sut.addPlayer(alice)
        sut.addPointToPlayer(sut.players[0], points: 50)

        // Simuler déconnexion
        sut.players.removeAll { $0.name == "Alice" }

        // Reconnexion avec nouveau Player (même nom, UUID différent)
        alice = Player(name: "Alice", teamColor: .purpleGame, score: 0)
        sut.addPlayer(alice)

        XCTAssertEqual(sut.players.first?.score, 50, "Score doit être restauré à la reconnexion")
    }

    // MARK: - addPointToPlayer

    func test_addPointToPlayer_incrementsScore() {
        sut.addPlayer(SamplePlayers.alice)
        let alice = sut.players[0]
        sut.addPointToPlayer(alice, points: 20)
        XCTAssertEqual(sut.players[0].score, 20)
    }

    func test_addPointToPlayer_syncsAllRegisteredPlayers() {
        sut.addPlayer(SamplePlayers.alice)
        let alice = sut.players[0]
        sut.addPointToPlayer(alice, points: 30)
        XCTAssertEqual(sut.allRegisteredPlayers.first?.score, 30)
    }

    func test_addPointToPlayer_unknownPlayerDoesNothing() {
        sut.addPlayer(SamplePlayers.alice)
        sut.addPointToPlayer(SamplePlayers.bob, points: 10)
        XCTAssertEqual(sut.players[0].score, 0)
    }

    // MARK: - setBuzzPlayer / resetBuzzState (MasterGameHost)

    func test_setBuzzPlayer_setsCurrentBuzzPlayer() {
        sut.setBuzzPlayer(SamplePlayers.alice)
        XCTAssertEqual(sut.currentBuzzPlayer?.id, SamplePlayers.alice.id)
    }

    func test_resetBuzzState_clearsCurrentBuzzPlayer() {
        sut.setBuzzPlayer(SamplePlayers.alice)
        sut.resetBuzzState()
        XCTAssertNil(sut.currentBuzzPlayer)
    }

    func test_resetBuzzState_clearsIsBuzzLocked() {
        sut.isBuzzLocked = true
        sut.resetBuzzState()
        XCTAssertFalse(sut.isBuzzLocked)
    }

    // MARK: - connectedPlayersCount / totalPlayersCount

    func test_connectedPlayersCount_excludesEcranPublique() {
        sut.addPlayer(SamplePlayers.alice)
        sut.addPlayer(Player(name: "Écran Publique", teamColor: .blueGame))
        XCTAssertEqual(sut.connectedPlayersCount, 1)
    }

    func test_totalPlayersCount_excludesEcranPublique() {
        sut.addPlayer(SamplePlayers.alice)
        sut.addPlayer(Player(name: "Écran Publique", teamColor: .blueGame))
        XCTAssertEqual(sut.totalPlayersCount, 1)
    }

    // MARK: - selectGame

    func test_selectGame_setsGameState() {
        sut.selectGame(.blindTest)
        if case .inGame(let game) = sut.gameState {
            XCTAssertEqual(game, .blindTest)
        } else {
            XCTFail("Expected .inGame(.blindTest)")
        }
    }
}

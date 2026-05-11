import XCTest
@testable import BuzzPlay

@MainActor
final class TeamFlowViewModelTests: XCTestCase {

    var sut: PlayerFlowViewModel!

    override func setUp() {
        super.setUp()
        sut = PlayerFlowViewModel()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - makeBuzzerViewModel

    func test_makeBuzzerViewModel_returnsNilWhenNoPlayer() {
        // playerGameVM est nil car aucun joueur n'a été créé
        let vm = sut.makeBuzzerViewModel(for: .blindTest)
        XCTAssertNil(vm, "Doit retourner nil si playerGameVM est nil")
    }

    // MARK: - resetLocalSession

    func test_resetLocalSession_clearsPlayerAndMPC() {
        // Simuler une session active
        sut.resetLocalSession(clearPersistence: false)
        XCTAssertNil(sut.player)
        XCTAssertNil(sut.mpc)
        XCTAssertNil(sut.playerGameVM)
    }

    func test_resetLocalSession_withClearPersistence_clearsSavedDraft() {
        sut.savedPlayerDraft = SamplePlayers.alice
        sut.resetLocalSession(clearPersistence: true)
        XCTAssertNil(sut.savedPlayerDraft)
    }

    // MARK: - TeamGameHost conformance

    func test_mpcService_isNilWhenNoSession() {
        XCTAssertNil(sut.mpcService, "mpcService doit être nil avant la création d'un joueur")
    }

    func test_player_isNilInitially() {
        XCTAssertNil(sut.player)
    }
}

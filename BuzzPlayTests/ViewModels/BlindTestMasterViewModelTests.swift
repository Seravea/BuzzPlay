import XCTest
@testable import BuzzPlay

// NOTE: Les tests couvrent la LOGIQUE PURE du ViewModel (machine à états, scoring,
// transitions). La lecture audio (AVPlayer / ApplicationMusicPlayer) et le réseau MPC
// ne sont pas testés ici — ils nécessitent du hardware réel.

@MainActor
final class BlindTestMasterViewModelTests: XCTestCase {

    var sut: BlindTestMasterViewModel!
    var mockHost: MockMasterGameHost!

    override func setUp() {
        super.setUp()
        mockHost = MockMasterGameHost()
        mockHost.players = [SamplePlayers.alice, SamplePlayers.bob]
        sut = BlindTestMasterViewModel(gameVM: mockHost)
    }

    override func tearDown() {
        sut.cancelRound()   // stoppe les timers avant de libérer
        sut = nil
        mockHost = nil
        super.tearDown()
    }

    // MARK: - État initial

    func test_initialState_isIdle() {
        if case .idle = sut.state { } else {
            XCTFail("État initial doit être .idle, obtenu \(sut.state)")
        }
    }

    func test_initialState_isNotPlaying() {
        XCTAssertFalse(sut.isPlaying)
    }

    func test_initialState_hasNoPlayerBuzz() {
        XCTAssertNil(sut.playerHasBuzz)
    }

    func test_initialState_isGameActiveIsFalse() {
        XCTAssertFalse(sut.isGameActive)
    }

    // MARK: - handleBuzz (machine à états)

    func test_handleBuzz_ignoredWhenStateIsIdle() {
        // state = .idle par défaut
        sut.handleBuzz(from: SamplePlayers.alice)
        XCTAssertNil(sut.playerHasBuzz, "Buzz ignoré quand .idle")
    }

    func test_handleBuzz_ignoredWhenStateIsFinished() {
        sut.state = .finished
        sut.handleBuzz(from: SamplePlayers.alice)
        XCTAssertNil(sut.playerHasBuzz, "Buzz ignoré quand .finished")
    }

    func test_handleBuzz_ignoredWhenAlreadyBuzzed() {
        sut.state = .playing
        sut.handleBuzz(from: SamplePlayers.alice)       // premier buzz → accepté
        sut.handleBuzz(from: SamplePlayers.bob)         // second buzz → ignoré (état est .buzzed)
        XCTAssertEqual(sut.playerHasBuzz?.id, SamplePlayers.alice.id,
                       "Le second buzz ne doit pas écraser le premier")
    }

    func test_handleBuzz_setsPlayerHasBuzzWhenPlaying() {
        sut.state = .playing
        sut.handleBuzz(from: SamplePlayers.alice)
        XCTAssertEqual(sut.playerHasBuzz?.id, SamplePlayers.alice.id)
    }

    func test_handleBuzz_setsStateToBuzzed() {
        sut.state = .playing
        sut.handleBuzz(from: SamplePlayers.bob)
        if case .buzzed(let p) = sut.state {
            XCTAssertEqual(p.id, SamplePlayers.bob.id)
        } else {
            XCTFail("État doit être .buzzed après un buzz valide")
        }
    }

    func test_handleBuzz_setsIsPlayingFalse() {
        sut.state = .playing
        sut.isPlaying = true
        sut.handleBuzz(from: SamplePlayers.alice)
        XCTAssertFalse(sut.isPlaying, "La musique doit être mise en pause après le buzz")
    }

    func test_handleBuzz_callsBroadcastOnHost() {
        sut.state = .playing
        sut.handleBuzz(from: SamplePlayers.alice)
        XCTAssertGreaterThan(mockHost.broadcastPublicStateCallCount, 0,
                             "Le host doit être notifié après un buzz")
    }

    // MARK: - cancelRound

    func test_cancelRound_setsStateToIdle() {
        sut.state = .playing
        sut.cancelRound()
        if case .idle = sut.state { } else {
            XCTFail("cancelRound doit remettre l'état à .idle")
        }
    }

    func test_cancelRound_clearsIsPlaying() {
        sut.isPlaying = true
        sut.cancelRound()
        XCTAssertFalse(sut.isPlaying)
    }

    func test_cancelRound_clearsIsGameActive() {
        sut.isGameActive = true
        sut.cancelRound()
        XCTAssertFalse(sut.isGameActive)
    }

    func test_cancelRound_clearsPlayerHasBuzz() {
        sut.playerHasBuzz = SamplePlayers.alice
        sut.cancelRound()
        XCTAssertNil(sut.playerHasBuzz)
    }

    func test_cancelRound_callsResetBuzzStateOnHost() {
        sut.cancelRound()
        XCTAssertGreaterThan(mockHost.resetBuzzStateCallCount, 0)
    }

    func test_cancelRound_resetsReactionTimer() {
        sut.reactionTimeMs = 5000
        sut.cancelRound()
        XCTAssertEqual(sut.reactionTimeMs, 0, "Le timer doit être remis à zéro")
    }

    // MARK: - handlePreviewEnd

    func test_handlePreviewEnd_stopsPlayingWhenPlaying() {
        sut.state = .playing
        sut.isPlaying = true
        sut.handlePreviewEnd()
        XCTAssertFalse(sut.isPlaying, "La fin du preview doit stopper isPlaying")
    }

    func test_handlePreviewEnd_ignoredWhenIdle() {
        sut.state = .idle
        sut.isPlaying = false
        sut.handlePreviewEnd()
        // Pas de crash, état inchangé
        if case .idle = sut.state { } else {
            XCTFail("L'état ne doit pas changer si .idle")
        }
    }

    func test_handlePreviewEnd_ignoredWhenBuzzed() {
        sut.state = .buzzed(SamplePlayers.alice)
        sut.isPlaying = false
        sut.handlePreviewEnd()
        // Le guard `case .playing` doit bloquer l'exécution
        if case .buzzed = sut.state { } else {
            XCTFail("L'état ne doit pas changer si .buzzed")
        }
    }

    func test_handlePreviewEnd_resetsReactionTimer() {
        sut.state = .playing
        sut.reactionTimeMs = 3000
        sut.handlePreviewEnd()
        XCTAssertEqual(sut.reactionTimeMs, 0)
    }

    // MARK: - validateAnswer

    func test_validateAnswer_doesNothingWithNoPlayerBuzz() {
        sut.playerHasBuzz = nil
        sut.validateAnswer(points: 10)
        XCTAssertEqual(mockHost.addPointCallCount, 0,
                       "Sans joueur buzzé, aucun point ne doit être ajouté")
    }

    func test_validateAnswer_callsAddPointOnHost() {
        sut.playerHasBuzz = SamplePlayers.alice
        sut.validateAnswer(points: 20)
        XCTAssertEqual(mockHost.addPointCallCount, 1)
        XCTAssertEqual(mockHost.lastAddedPoints, 20)
        XCTAssertEqual(mockHost.lastAddedPlayer?.id, SamplePlayers.alice.id)
    }

    func test_validateAnswer_setsStateToFinished() {
        sut.playerHasBuzz = SamplePlayers.alice
        sut.validateAnswer(points: 10)
        if case .finished = sut.state { } else {
            XCTFail("État doit être .finished après validation")
        }
    }

    func test_validateAnswer_setsIsCorrectTrue() {
        sut.playerHasBuzz = SamplePlayers.alice
        sut.validateAnswer(points: 5)
        XCTAssertTrue(sut.isCorrect)
    }

    func test_validateAnswer_setsIsPlayingFalse() {
        sut.playerHasBuzz = SamplePlayers.alice
        sut.isPlaying = true
        sut.validateAnswer(points: 5)
        XCTAssertFalse(sut.isPlaying)
    }

    func test_validateAnswer_addsSongToPlayedSongs() {
        sut.selectedMusic = SampleBlindTestSongs.song1
        sut.playerHasBuzz = SamplePlayers.alice
        sut.validateAnswer(points: 10)
        XCTAssertTrue(sut.playedSongs.contains(SampleBlindTestSongs.song1),
                      "La chanson validée doit être ajoutée à playedSongs")
    }

    func test_validateAnswer_doesNotDuplicateSongInPlayedSongs() {
        sut.selectedMusic = SampleBlindTestSongs.song1
        sut.playedSongs = [SampleBlindTestSongs.song1]   // déjà jouée
        sut.playerHasBuzz = SamplePlayers.alice
        sut.validateAnswer(points: 10)
        XCTAssertEqual(sut.playedSongs.count, 1,
                       "Une chanson déjà dans playedSongs ne doit pas être dupliquée")
    }

    func test_validateAnswer_clearsSongSelection() {
        sut.selectedMusic = SampleBlindTestSongs.song2
        sut.playerHasBuzz = SamplePlayers.bob
        sut.validateAnswer(points: 10)
        XCTAssertNil(sut.selectedMusic, "selectedMusic doit être nil après validation")
    }

    func test_validateAnswer_setsIsGameActiveFalse() {
        sut.isGameActive = true
        sut.playerHasBuzz = SamplePlayers.alice
        sut.validateAnswer(points: 10)
        XCTAssertFalse(sut.isGameActive)
    }

    func test_validateAnswer_callsBroadcastOnHost() {
        sut.playerHasBuzz = SamplePlayers.alice
        sut.validateAnswer(points: 10)
        XCTAssertGreaterThan(mockHost.broadcastPublicStateCallCount, 0)
    }

    // MARK: - rejectAnswer

    func test_rejectAnswer_doesNothingWhenNotBuzzed() {
        sut.state = .idle    // guard case .buzzed bloque l'exécution
        sut.playerHasBuzz = SamplePlayers.alice
        sut.rejectAnswer()
        // playerHasBuzz ne doit pas être modifié
        XCTAssertNotNil(sut.playerHasBuzz,
                        "rejectAnswer ignoré si state != .buzzed")
    }

    func test_rejectAnswer_clearsPlayerHasBuzz() {
        sut.state = .buzzed(SamplePlayers.alice)
        sut.playerHasBuzz = SamplePlayers.alice
        sut.rejectAnswer()
        XCTAssertNil(sut.playerHasBuzz)
    }

    func test_rejectAnswer_setsStateToPlaying() {
        sut.state = .buzzed(SamplePlayers.alice)
        sut.rejectAnswer()
        if case .playing = sut.state { } else {
            XCTFail("État doit repasser à .playing après rejet")
        }
    }

    func test_rejectAnswer_setsIsCorrectFalse() {
        sut.isCorrect = true
        sut.state = .buzzed(SamplePlayers.alice)
        sut.rejectAnswer()
        XCTAssertFalse(sut.isCorrect)
    }

    func test_rejectAnswer_callsBroadcastOnHost() {
        sut.state = .buzzed(SamplePlayers.alice)
        sut.rejectAnswer()
        XCTAssertGreaterThan(mockHost.broadcastPublicStateCallCount, 0)
    }

    // MARK: - makePublicState (machine à états → affichage public)

    func test_makePublicState_returnsWaitingWhenIdle() {
        sut.state = .idle
        let publicState = sut.makePublicState()
        if case .waiting = publicState { } else {
            XCTFail("État .idle → PublicState doit être .waiting")
        }
    }

    func test_makePublicState_returnsBlindTestWhenPlaying() {
        sut.state = .playing
        let publicState = sut.makePublicState()
        if case .blindTest(let btState) = publicState {
            XCTAssertTrue(btState.isPlaying)
            XCTAssertFalse(btState.isAnswerRevealed)
            XCTAssertNil(btState.buzzingPlayer)
        } else {
            XCTFail("État .playing → PublicState doit être .blindTest")
        }
    }

    func test_makePublicState_includesBuzzingPlayerWhenBuzzed() {
        sut.state = .buzzed(SamplePlayers.bob)
        let publicState = sut.makePublicState()
        if case .blindTest(let btState) = publicState {
            XCTAssertEqual(btState.buzzingPlayer?.id, SamplePlayers.bob.id)
            XCTAssertFalse(btState.isAnswerRevealed)
            XCTAssertFalse(btState.isPlaying)
        } else {
            XCTFail("État .buzzed → PublicState doit être .blindTest avec buzzingPlayer")
        }
    }

    func test_makePublicState_revealsAnswerWhenFinished() {
        sut.state = .finished
        sut.selectedMusic = SampleBlindTestSongs.song1
        let publicState = sut.makePublicState()
        if case .blindTest(let btState) = publicState {
            XCTAssertTrue(btState.isAnswerRevealed)
            XCTAssertFalse(btState.isPlaying)
        } else {
            XCTFail("État .finished → PublicState doit révéler la réponse")
        }
    }

    func test_makePublicState_includesSongInfoWhenFinished() {
        sut.state = .finished
        sut.selectedMusic = SampleBlindTestSongs.song1
        let publicState = sut.makePublicState()
        if case .blindTest(let btState) = publicState {
            XCTAssertEqual(btState.title, "Get Lucky")
            XCTAssertEqual(btState.artist, "Daft Punk")
        } else {
            XCTFail("État .finished doit exposer le titre et l'artiste")
        }
    }

    // MARK: - totalNumberOfSongs

    func test_totalNumberOfSongs_reflectsAllSongs() {
        sut.allSongs = [SampleBlindTestSongs.song1, SampleBlindTestSongs.song2, SampleBlindTestSongs.song3]
        XCTAssertEqual(sut.totalNumberOfSongs, 3)
    }

    func test_totalNumberOfSongs_zeroWhenEmpty() {
        sut.allSongs = []
        XCTAssertEqual(sut.totalNumberOfSongs, 0)
    }

    // MARK: - formattedTime (timer réaction)

    func test_formattedTime_startsAtZero() {
        XCTAssertEqual(sut.formattedTime, "00:00")
    }

    func test_formattedTime_formatsCorrectly() {
        sut.reactionTimeMs = 5300   // 5.3 secondes = 53 centièmes
        XCTAssertEqual(sut.formattedTime, "05:30")
    }

    func test_formattedTime_reactionTimer_resetsOnStopReactionTimer() {
        sut.reactionTimeMs = 10000
        sut.stopReactionTimer()
        XCTAssertEqual(sut.reactionTimeMs, 0)
        XCTAssertEqual(sut.formattedTime, "00:00")
    }

    // MARK: - startRound (sans musique)

    func test_startRound_doesNothingWithoutSelectedMusic() {
        sut.selectedMusic = nil
        sut.startRound()
        // Le guard en première ligne doit bloquer — isGameActive reste false
        XCTAssertFalse(sut.isGameActive,
                       "startRound sans selectedMusic ne doit pas démarrer la manche")
    }
}

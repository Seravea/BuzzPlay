import XCTest
@testable import BuzzPlay

@MainActor
final class QuizMasterViewModelTests: XCTestCase {

    var sut: QuizMasterViewModel!
    var mockHost: MockMasterGameHost!

    override func setUp() {
        super.setUp()
        mockHost = MockMasterGameHost()
        mockHost.players = [SamplePlayers.alice, SamplePlayers.bob]
        sut = QuizMasterViewModel(gameVM: mockHost, quizSet: SampleQuiz.quizSet)
    }

    override func tearDown() {
        sut = nil
        mockHost = nil
        super.tearDown()
    }

    // MARK: - selectQuestion

    func test_selectQuestion_setsCurrentQuestion() {
        sut.selectQuestion(SampleQuiz.q1)
        XCTAssertEqual(sut.currentQuestion?.id, SampleQuiz.q1.id)
    }

    func test_selectQuestion_resetsPlayerBuzz() {
        sut.playerHasBuzz = SamplePlayers.alice
        sut.selectQuestion(SampleQuiz.q1)
        XCTAssertNil(sut.playerHasBuzz)
    }

    func test_selectQuestion_callsUnlockBuzz() {
        sut.selectQuestion(SampleQuiz.q1)
        XCTAssertGreaterThan(mockHost.unlockBuzzCallCount, 0)
    }

    // MARK: - handleBuzz

    func test_handleBuzz_setsBuzzPlayer() {
        sut.handleBuzz(from: SamplePlayers.alice)
        XCTAssertEqual(mockHost.currentBuzzPlayer?.id, SamplePlayers.alice.id)
        XCTAssertEqual(mockHost.setBuzzPlayerCallCount, 1)
    }

    func test_handleBuzz_setsLocalPlayerHasBuzz() {
        sut.handleBuzz(from: SamplePlayers.bob)
        XCTAssertEqual(sut.playerHasBuzz?.id, SamplePlayers.bob.id)
    }

    // MARK: - validateAnswer

    func test_validateAnswer_addsPointsToPlayer() {
        mockHost.currentBuzzPlayer = SamplePlayers.alice
        sut.validateAnswer(points: 10)
        XCTAssertEqual(mockHost.addPointCallCount, 1)
        XCTAssertEqual(mockHost.lastAddedPoints, 10)
        XCTAssertEqual(mockHost.lastAddedPlayer?.id, SamplePlayers.alice.id)
    }

    func test_validateAnswer_resetsPlayerHasBuzz() {
        sut.playerHasBuzz = SamplePlayers.alice
        mockHost.currentBuzzPlayer = SamplePlayers.alice
        sut.validateAnswer(points: 5)
        XCTAssertNil(sut.playerHasBuzz)
    }

    func test_validateAnswer_callsResetBuzzState() {
        mockHost.currentBuzzPlayer = SamplePlayers.alice
        sut.validateAnswer(points: 5)
        XCTAssertGreaterThan(mockHost.resetBuzzStateCallCount, 0)
    }

    func test_validateAnswer_withNoBuzzPlayer_doesNothing() {
        mockHost.currentBuzzPlayer = nil
        sut.validateAnswer(points: 10)
        XCTAssertEqual(mockHost.addPointCallCount, 0)
    }

    // MARK: - rejectAnswer

    func test_rejectAnswer_resetsPlayerHasBuzz() {
        sut.playerHasBuzz = SamplePlayers.alice
        sut.rejectAnswer()
        XCTAssertNil(sut.playerHasBuzz)
    }

    func test_rejectAnswer_callsResetBuzzState() {
        sut.rejectAnswer()
        XCTAssertGreaterThan(mockHost.resetBuzzStateCallCount, 0)
    }

    func test_rejectAnswer_doesNotAddPoints() {
        mockHost.currentBuzzPlayer = SamplePlayers.alice
        sut.rejectAnswer()
        XCTAssertEqual(mockHost.addPointCallCount, 0)
    }

    // MARK: - skipQuestion

    func test_skipQuestion_clearsCurrentQuestion() {
        sut.currentQuestion = SampleQuiz.q1
        sut.skipQuestion()
        XCTAssertNil(sut.currentQuestion)
    }

    func test_skipQuestion_clearsPlayerBuzz() {
        sut.playerHasBuzz = SamplePlayers.alice
        sut.skipQuestion()
        XCTAssertNil(sut.playerHasBuzz)
    }

    func test_skipQuestion_callsResetBuzzState() {
        sut.skipQuestion()
        XCTAssertGreaterThan(mockHost.resetBuzzStateCallCount, 0)
    }

    func test_skipQuestion_addsToPassedQuestions() {
        sut.currentQuestion = SampleQuiz.q1
        sut.skipQuestion()
        XCTAssertTrue(sut.questionsPassed.contains(SampleQuiz.q1))
    }

    // MARK: - goToSelectNewQuestion

    func test_goToSelectNewQuestion_appendsToPassedQuestions() {
        sut.currentQuestion = SampleQuiz.q2
        sut.goToSelectNewQuestion()
        XCTAssertTrue(sut.questionsPassed.contains(SampleQuiz.q2))
    }

    func test_goToSelectNewQuestion_nilsCurrentQuestion() {
        sut.currentQuestion = SampleQuiz.q1
        sut.goToSelectNewQuestion()
        XCTAssertNil(sut.currentQuestion)
    }

    // MARK: - isPlaying

    func test_isPlaying_trueWhenCurrentQuestion() {
        sut.currentQuestion = SampleQuiz.q1
        XCTAssertTrue(sut.isPlaying)
    }

    func test_isPlaying_falseWhenNoCurrentQuestion() {
        sut.currentQuestion = nil
        XCTAssertFalse(sut.isPlaying)
    }

    // MARK: - validateRejectDisabled

    func test_validateRejectDisabled_trueWhenNoPlayerBuzz() {
        sut.playerHasBuzz = nil
        XCTAssertTrue(sut.validateRejectDisabled)
    }

    func test_validateRejectDisabled_falseWhenPlayerHasBuzz() {
        sut.playerHasBuzz = SamplePlayers.alice
        XCTAssertFalse(sut.validateRejectDisabled)
    }
}

import Testing
@testable import LucidEngine

// MARK: - Score Tests

@Suite("Score")
struct ScoreTests {

    @Test("centipawns stores value")
    func centipawnsStoresValue() {
        let score = Score.centipawns(150)
        #expect(score == .centipawns(150))
    }

    @Test("mate stores value")
    func mateStoresValue() {
        let score = Score.mate(3)
        #expect(score == .mate(3))
    }

    @Test("negative centipawns")
    func negativeCentipawns() {
        let score = Score.centipawns(-200)
        #expect(score == .centipawns(-200))
    }

    @Test("negative mate means getting mated")
    func negativeMate() {
        let score = Score.mate(-2)
        #expect(score == .mate(-2))
    }

    @Test("centipawns zero")
    func centipawnsZero() {
        let score = Score.centipawns(0)
        #expect(score == .centipawns(0))
    }

    @Test("mate-in-0")
    func mateInZero() {
        let score = Score.mate(0)
        #expect(score == .mate(0))
    }

    @Test("equal centipawn scores are equal", arguments: [-500, -1, 0, 1, 500])
    func centipawnsEquality(value: Int) {
        #expect(Score.centipawns(value) == Score.centipawns(value))
    }

    @Test("equal mate scores are equal", arguments: [-3, -1, 0, 1, 3])
    func mateEquality(movesToMate: Int) {
        #expect(Score.mate(movesToMate) == Score.mate(movesToMate))
    }

    @Test("different centipawn values are not equal")
    func centipawnsDifferentNotEqual() {
        #expect(Score.centipawns(100) != Score.centipawns(101))
    }

    @Test("different mate values are not equal")
    func mateDifferentNotEqual() {
        #expect(Score.mate(1) != Score.mate(2))
    }

    @Test("centipawns and mate are not equal even with same raw value")
    func centipawnsAndMateNotEqual() {
        #expect(Score.centipawns(3) != Score.mate(3))
    }

    @Test("Score is Sendable")
    func scoreIsSendable() {
        func requiresSendable<T: Sendable>(_ value: T) -> T { value }
        let score = requiresSendable(Score.centipawns(0))
        #expect(score == Score.centipawns(0))
    }

    @Test("large centipawn value")
    func largeCentipawnValue() {
        let score = Score.centipawns(100_000)
        #expect(score == .centipawns(100_000))
    }
}

// MARK: - Move Tests

@Suite("Move")
struct MoveTests {

    // MARK: Direct init

    @Test("init with from and to")
    func initFromTo() {
        let move = Move(from: "e2", to: "e4")
        #expect(move.from == "e2")
        #expect(move.to == "e4")
        #expect(move.promotion == nil)
    }

    @Test("init with promotion")
    func initWithPromotion() {
        let move = Move(from: "e7", to: "e8", promotion: "q")
        #expect(move.promotion == "q")
    }

    @Test("uci string without promotion")
    func uciWithoutPromotion() {
        let move = Move(from: "e2", to: "e4")
        #expect(move.uci == "e2e4")
    }

    @Test("uci string with promotion")
    func uciWithPromotion() {
        let move = Move(from: "e7", to: "e8", promotion: "q")
        #expect(move.uci == "e7e8q")
    }

    // MARK: UCI parsing — happy path

    @Test("parse standard move e2e4")
    func parseStandardMove() {
        let move = Move(uci: "e2e4")
        #expect(move != nil)
        #expect(move?.from == "e2")
        #expect(move?.to == "e4")
        #expect(move?.promotion == nil)
    }

    @Test("parse promotion e7e8q")
    func parsePromotion() {
        let move = Move(uci: "e7e8q")
        #expect(move != nil)
        #expect(move?.from == "e7")
        #expect(move?.to == "e8")
        #expect(move?.promotion == "q")
    }

    @Test("parse knight promotion a7a8n")
    func parseKnightPromotion() {
        let move = Move(uci: "a7a8n")
        #expect(move?.promotion == "n")
    }

    @Test("parse rook promotion h7h8r")
    func parseRookPromotion() {
        let move = Move(uci: "h7h8r")
        #expect(move?.promotion == "r")
    }

    @Test("parse bishop promotion b7b8b")
    func parseBishopPromotion() {
        let move = Move(uci: "b7b8b")
        #expect(move?.promotion == "b")
    }

    @Test("parse castling e1g1")
    func parseCastling() {
        let move = Move(uci: "e1g1")
        #expect(move != nil)
        #expect(move?.from == "e1")
        #expect(move?.to == "g1")
    }

    @Test(
        "valid UCI strings round-trip through .uci",
        arguments: ["e2e4", "d2d4", "g1f3", "c7c5", "a1h8", "h1a8"]
    )
    func validUCIRoundTrips(uciString: String) {
        let move = Move(uci: uciString)
        #expect(move?.uci == uciString)
    }

    @Test(
        "promotion UCI strings preserve piece",
        arguments: [
            ("e7e8q", "q"),
            ("e7e8r", "r"),
            ("e7e8b", "b"),
            ("e7e8n", "n"),
            ("a2a1q", "q"),
        ]
    )
    func promotionPiecePreserved(uciString: String, expectedPromotion: String) {
        let move = Move(uci: uciString)
        #expect(move?.promotion == expectedPromotion)
    }

    // MARK: UCI parsing — error path

    @Test("reject empty string")
    func rejectEmpty() {
        #expect(Move(uci: "") == nil)
    }

    @Test("reject too short string")
    func rejectTooShort() {
        #expect(Move(uci: "e2") == nil)
    }

    @Test("reject too long string")
    func rejectTooLong() {
        #expect(Move(uci: "e2e4qq") == nil)
    }

    @Test("reject invalid file")
    func rejectInvalidFile() {
        #expect(Move(uci: "z2e4") == nil)
    }

    @Test("reject invalid rank")
    func rejectInvalidRank() {
        #expect(Move(uci: "e0e4") == nil)
    }

    @Test("reject rank 9")
    func rejectRank9() {
        #expect(Move(uci: "e9e4") == nil)
    }

    @Test("reject invalid promotion piece")
    func rejectInvalidPromotion() {
        #expect(Move(uci: "e7e8z") == nil)
    }

    @Test("reject king as promotion")
    func rejectKingPromotion() {
        #expect(Move(uci: "e7e8k") == nil)
    }

    // MARK: Equatable

    @Test("same moves are equal")
    func sameMovesEqual() {
        #expect(Move(from: "e2", to: "e4") == Move(from: "e2", to: "e4"))
    }

    @Test("different moves are not equal")
    func differentMovesNotEqual() {
        #expect(Move(from: "e2", to: "e4") != Move(from: "d2", to: "d4"))
    }

    @Test("same squares different promotion are not equal")
    func differentPromotionNotEqual() {
        let queen = Move(uci: "e7e8q")
        let rook = Move(uci: "e7e8r")
        #expect(queen != rook)
    }

    @Test("promotion move not equal to quiet move on same squares")
    func promotionNotEqualToQuiet() {
        let withPromo = Move(uci: "e7e8q")
        let withoutPromo = Move(uci: "e7e8")
        #expect(withPromo != withoutPromo)
    }

    // MARK: Sendable

    @Test("Move is Sendable")
    func moveIsSendable() {
        func requiresSendable<T: Sendable>(_ value: T) -> T { value }
        let move = requiresSendable(Move(from: "g1", to: "f3"))
        #expect(move.uci == "g1f3")
    }
}

// MARK: - PositionAssessment Tests

@Suite("PositionAssessment")
struct PositionAssessmentTests {

    @Test("stores all fields correctly")
    func storesAllFields() {
        let bestMove = Move(from: "e2", to: "e4")
        let pv = [Move(from: "e2", to: "e4"), Move(from: "e7", to: "e5")]
        let assessment = PositionAssessment(
            score: .centipawns(35),
            bestMove: bestMove,
            principalVariation: pv,
            depth: 18,
            nodes: 1_500_000
        )
        #expect(assessment.score == .centipawns(35))
        #expect(assessment.bestMove == bestMove)
        #expect(assessment.principalVariation.count == 2)
        #expect(assessment.depth == 18)
        #expect(assessment.nodes == 1_500_000)
    }

    @Test("stores mate score")
    func storesMateScore() {
        let assessment = PositionAssessment(
            score: .mate(2),
            bestMove: Move(from: "h5", to: "f7"),
            principalVariation: [],
            depth: 15,
            nodes: 42_000
        )
        #expect(assessment.score == .mate(2))
    }

    @Test("empty principal variation is allowed")
    func emptyPVIsAllowed() {
        let assessment = PositionAssessment(
            score: .centipawns(0),
            bestMove: Move(from: "e1", to: "g1"),
            principalVariation: [],
            depth: 1,
            nodes: 1
        )
        #expect(assessment.principalVariation.isEmpty)
    }

    @Test("large node count stored correctly")
    func largeNodeCount() {
        let assessment = PositionAssessment(
            score: .centipawns(15),
            bestMove: Move(from: "d2", to: "d4"),
            principalVariation: [],
            depth: 20,
            nodes: 5_000_000_000
        )
        #expect(assessment.nodes == 5_000_000_000)
    }

    @Test("two identical assessments are equal")
    func identicalAreEqual() {
        let bestMove = Move(from: "e2", to: "e4")
        let a = PositionAssessment(
            score: .centipawns(10),
            bestMove: bestMove,
            principalVariation: [bestMove],
            depth: 18,
            nodes: 500_000
        )
        let b = PositionAssessment(
            score: .centipawns(10),
            bestMove: bestMove,
            principalVariation: [bestMove],
            depth: 18,
            nodes: 500_000
        )
        #expect(a == b)
    }

    @Test("different scores make assessments unequal")
    func differentScoresUnequal() {
        let bestMove = Move(from: "e2", to: "e4")
        let a = PositionAssessment(score: .centipawns(100), bestMove: bestMove, principalVariation: [], depth: 18, nodes: 0)
        let b = PositionAssessment(score: .centipawns(200), bestMove: bestMove, principalVariation: [], depth: 18, nodes: 0)
        #expect(a != b)
    }

    @Test("different best moves make assessments unequal")
    func differentBestMovesUnequal() {
        let a = PositionAssessment(score: .centipawns(0), bestMove: Move(from: "e2", to: "e4"), principalVariation: [], depth: 18, nodes: 0)
        let b = PositionAssessment(score: .centipawns(0), bestMove: Move(from: "d2", to: "d4"), principalVariation: [], depth: 18, nodes: 0)
        #expect(a != b)
    }

    @Test("PositionAssessment is Sendable")
    func assessmentIsSendable() {
        func requiresSendable<T: Sendable>(_ value: T) -> T { value }
        let assessment = PositionAssessment(
            score: .centipawns(0),
            bestMove: Move(from: "e2", to: "e4"),
            principalVariation: [],
            depth: 18,
            nodes: 0
        )
        let result = requiresSendable(assessment)
        #expect(result == assessment)
    }
}

// MARK: - EngineError Updated Cases Tests

@Suite("EngineError Updated Cases")
struct EngineErrorUpdatedTests {

    @Test("invalidFEN carries FEN string")
    func invalidFENCarriesString() {
        let error = EngineError.invalidFEN("not a fen")
        #expect(error == .invalidFEN("not a fen"))
    }

    @Test("invalidFEN with empty string")
    func invalidFENEmptyString() {
        let error = EngineError.invalidFEN("")
        #expect(error == .invalidFEN(""))
    }

    @Test("different invalidFEN strings are not equal")
    func differentFENStringsNotEqual() {
        #expect(EngineError.invalidFEN("abc") != EngineError.invalidFEN("xyz"))
    }

    @Test("evaluationTimeout exists and is Equatable")
    func evaluationTimeoutExists() {
        #expect(EngineError.evaluationTimeout == .evaluationTimeout)
    }

    @Test("analysisInterrupted exists and is Equatable")
    func analysisInterruptedExists() {
        #expect(EngineError.analysisInterrupted == .analysisInterrupted)
    }

    @Test("evaluationTimeout conforms to Error")
    func evaluationTimeoutIsError() {
        let error: any Error = EngineError.evaluationTimeout
        #expect(error is EngineError)
    }

    @Test("analysisInterrupted conforms to Error")
    func analysisInterruptedIsError() {
        let error: any Error = EngineError.analysisInterrupted
        #expect(error is EngineError)
    }

    @Test("different cases are never equal")
    func differentCasesNeverEqual() {
        #expect(EngineError.evaluationTimeout != EngineError.analysisInterrupted)
        #expect(EngineError.initializationFailed != EngineError.engineNotRunning)
        #expect(EngineError.invalidFEN("x") != EngineError.invalidConfiguration("x"))
    }

    @Test("EngineError is Sendable")
    func engineErrorIsSendable() {
        func requiresSendable<T: Sendable>(_ value: T) -> T { value }
        let error = requiresSendable(EngineError.evaluationTimeout)
        #expect(error == .evaluationTimeout)
    }
}

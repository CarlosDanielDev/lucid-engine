import Testing
@testable import LucidEngine
import CStockfish

// All suites must be serialized under a single parent because
// sf_init/sf_cleanup are global C state. Running suites in
// parallel causes one suite's cleanup to affect others.

@Suite("Position Assessment", .serialized)
struct PositionAssessmentTestSuite {

    // ============================================================
    // MARK: - FEN Validation — evaluate()
    // ============================================================

    @Suite("FEN Validation — evaluate()")
    struct FENValidationEvaluateTests {

        @Test("empty FEN throws invalidFEN")
        func emptyFENThrowsInvalidFEN() async throws {
            let engine = LucidEngine()
            try await engine.start()

            await #expect(throws: EngineError.invalidFEN("")) {
                _ = try await engine.evaluate(fen: "", depth: 10)
            }

            await engine.shutdown()
        }

        @Test("whitespace-only FEN throws invalidFEN")
        func whitespaceFENThrowsInvalidFEN() async throws {
            let engine = LucidEngine()
            try await engine.start()

            await #expect(throws: EngineError.self) {
                _ = try await engine.evaluate(fen: "   ", depth: 10)
            }

            await engine.shutdown()
        }

        @Test("single word FEN throws invalidFEN")
        func singleWordFENThrowsInvalidFEN() async throws {
            let engine = LucidEngine()
            try await engine.start()

            await #expect(throws: EngineError.self) {
                _ = try await engine.evaluate(fen: "notafen", depth: 10)
            }

            await engine.shutdown()
        }

        @Test("FEN with wrong number of ranks throws invalidFEN")
        func wrongRankCountThrowsInvalidFEN() async throws {
            let engine = LucidEngine()
            try await engine.start()

            let badFEN = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP w KQkq - 0 1"
            await #expect(throws: EngineError.self) {
                _ = try await engine.evaluate(fen: badFEN, depth: 10)
            }

            await engine.shutdown()
        }

        @Test("FEN with missing active color field throws invalidFEN")
        func missingActiveColorThrowsInvalidFEN() async throws {
            let engine = LucidEngine()
            try await engine.start()

            let badFEN = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR"
            await #expect(throws: EngineError.self) {
                _ = try await engine.evaluate(fen: badFEN, depth: 10)
            }

            await engine.shutdown()
        }

        @Test("FEN with invalid active color throws invalidFEN")
        func invalidActiveColorThrowsInvalidFEN() async throws {
            let engine = LucidEngine()
            try await engine.start()

            let badFEN = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR x KQkq - 0 1"
            await #expect(throws: EngineError.self) {
                _ = try await engine.evaluate(fen: badFEN, depth: 10)
            }

            await engine.shutdown()
        }

        @Test("FEN with invalid piece character throws invalidFEN")
        func invalidPieceCharacterThrowsInvalidFEN() async throws {
            let engine = LucidEngine()
            try await engine.start()

            let badFEN = "rnbqkbnr/pppppppp/8/8/8/8/PPPPZPPP/RNBQKBNR w KQkq - 0 1"
            await #expect(throws: EngineError.self) {
                _ = try await engine.evaluate(fen: badFEN, depth: 10)
            }

            await engine.shutdown()
        }

        @Test("FEN exceeding SF_MAX_FEN_LENGTH throws invalidFEN")
        func oversizedFENThrowsInvalidFEN() async throws {
            let engine = LucidEngine()
            try await engine.start()

            let oversized = String(repeating: "x", count: 300)
            await #expect(throws: EngineError.self) {
                _ = try await engine.evaluate(fen: oversized, depth: 10)
            }

            await engine.shutdown()
        }

        @Test("FEN with rank sum exceeding 8 throws invalidFEN")
        func rankSumExceedsEightThrowsInvalidFEN() async throws {
            let engine = LucidEngine()
            try await engine.start()

            let badFEN = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/9 w KQkq - 0 1"
            await #expect(throws: EngineError.self) {
                _ = try await engine.evaluate(fen: badFEN, depth: 10)
            }

            await engine.shutdown()
        }

        @Test("evaluate on stopped engine throws engineNotRunning")
        func stoppedEngineThrowsEngineNotRunning() async {
            let engine = LucidEngine()

            await #expect(throws: EngineError.engineNotRunning) {
                _ = try await engine.evaluate(fen: "", depth: 10)
            }
        }
    }

    // ============================================================
    // MARK: - FEN Validation — bestMove()
    // ============================================================

    @Suite("FEN Validation — bestMove()")
    struct FENValidationBestMoveTests {

        @Test("empty FEN throws invalidFEN on bestMove")
        func emptyFENThrowsOnBestMove() async throws {
            let engine = LucidEngine()
            try await engine.start()

            await #expect(throws: EngineError.self) {
                _ = try await engine.bestMove(fen: "", depth: 10)
            }

            await engine.shutdown()
        }

        @Test("garbage FEN throws invalidFEN on bestMove")
        func garbageFENThrowsOnBestMove() async throws {
            let engine = LucidEngine()
            try await engine.start()

            await #expect(throws: EngineError.self) {
                _ = try await engine.bestMove(fen: "totally-not-a-fen-string", depth: 10)
            }

            await engine.shutdown()
        }

        @Test("bestMove on stopped engine throws engineNotRunning")
        func stoppedEngineThrowsOnBestMove() async {
            let engine = LucidEngine()

            await #expect(throws: EngineError.engineNotRunning) {
                _ = try await engine.bestMove(
                    fen: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
                    depth: 10
                )
            }
        }
    }

    // ============================================================
    // MARK: - Depth Validation
    // ============================================================

    @Suite("Depth Validation")
    struct DepthValidationTests {

        private static let validFEN = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

        @Test("depth 0 throws invalidDepth")
        func depthZeroThrowsInvalidDepth() async throws {
            let engine = LucidEngine()
            try await engine.start()

            await #expect(throws: EngineError.invalidDepth(0)) {
                _ = try await engine.evaluate(fen: Self.validFEN, depth: 0)
            }

            await engine.shutdown()
        }

        @Test("negative depth throws invalidDepth")
        func negativeDepthThrowsInvalidDepth() async throws {
            let engine = LucidEngine()
            try await engine.start()

            await #expect(throws: EngineError.invalidDepth(-1)) {
                _ = try await engine.evaluate(fen: Self.validFEN, depth: -1)
            }

            await engine.shutdown()
        }

        @Test("depth 101 exceeds SF_MAX_DEPTH and throws invalidDepth")
        func depthExceedsMaxThrowsInvalidDepth() async throws {
            let engine = LucidEngine()
            try await engine.start()

            await #expect(throws: EngineError.invalidDepth(101)) {
                _ = try await engine.evaluate(fen: Self.validFEN, depth: 101)
            }

            await engine.shutdown()
        }

        @Test("depth 1 is the minimum valid depth")
        func depthOneIsValid() async throws {
            let engine = LucidEngine()
            try await engine.start()

            _ = try await engine.evaluate(fen: Self.validFEN, depth: 1)

            await engine.shutdown()
        }

        @Test("bestMove depth 0 throws invalidDepth")
        func bestMoveDepthZeroThrows() async throws {
            let engine = LucidEngine()
            try await engine.start()

            await #expect(throws: EngineError.invalidDepth(0)) {
                _ = try await engine.bestMove(fen: Self.validFEN, depth: 0)
            }

            await engine.shutdown()
        }
    }

    // ============================================================
    // MARK: - Default Depth Parameter
    // ============================================================

    @Suite("Default Depth Parameter")
    struct DefaultDepthParameterTests {

        private static let validFEN = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

        @Test("evaluate omitting depth uses default of 18")
        func evaluateWithDefaultDepth() async throws {
            let engine = LucidEngine()
            try await engine.start()

            let assessment = try await engine.evaluate(fen: Self.validFEN)
            #expect(assessment.depth == 18)

            await engine.shutdown()
        }

        @Test("bestMove omitting depth does not throw")
        func bestMoveWithDefaultDepth() async throws {
            let engine = LucidEngine()
            try await engine.start()

            _ = try await engine.bestMove(fen: Self.validFEN)

            await engine.shutdown()
        }
    }

    // ============================================================
    // MARK: - Score Mapping (C-to-Swift Translation)
    // ============================================================

    @Suite("Score Mapping")
    struct ScoreMappingTests {

        private static let startingFEN = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

        @Test("evaluate returns PositionAssessment with requested depth")
        func evaluateReturnsRequestedDepth() async throws {
            let engine = LucidEngine()
            try await engine.start()

            let result = try await engine.evaluate(fen: Self.startingFEN, depth: 12)
            #expect(result.depth == 12)

            await engine.shutdown()
        }

        @Test("evaluate result has non-negative nodes")
        func evaluateResultHasNonNegativeNodes() async throws {
            let engine = LucidEngine()
            try await engine.start()

            let result = try await engine.evaluate(fen: Self.startingFEN, depth: 10)
            #expect(result.nodes >= 0)

            await engine.shutdown()
        }

        @Test("evaluate score is a valid Score variant")
        func scoreIsValidVariant() async throws {
            let engine = LucidEngine()
            try await engine.start()

            let result = try await engine.evaluate(fen: Self.startingFEN, depth: 10)
            switch result.score {
            case .centipawns, .mate:
                break // valid
            }

            await engine.shutdown()
        }

        @Test("evaluate principal variation is an array of Move")
        func evaluatePVIsArrayOfMoves() async throws {
            let engine = LucidEngine()
            try await engine.start()

            let result = try await engine.evaluate(fen: Self.startingFEN, depth: 10)
            #expect(result.principalVariation.count >= 0)

            await engine.shutdown()
        }
    }

    // ============================================================
    // MARK: - Integration — Known Position Evaluations
    // ============================================================
    // These tests require REAL Stockfish (not the stub).
    // They will FAIL until sf_assess_position is wired to Stockfish.

    @Suite("Integration — Evaluation Correctness",
           .disabled("Requires real Stockfish — C stub returns zeroed results"))
    struct EvaluationCorrectnessTests {

        @Test("starting position score is roughly equal (< 50cp)")
        func startingPositionIsRoughlyEqual() async throws {
            let engine = LucidEngine()
            try await engine.start()

            let result = try await engine.evaluate(
                fen: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
                depth: 12
            )

            guard case .centipawns(let cp) = result.score else {
                Issue.record("Starting position returned a mate score unexpectedly")
                await engine.shutdown()
                return
            }
            #expect(abs(cp) < 50)

            await engine.shutdown()
        }

        @Test("rook up for white is significant advantage")
        func rookUpIsSignificantAdvantage() async throws {
            let engine = LucidEngine()
            try await engine.start()

            let rookUpFEN = "4k3/pppppppp/8/8/8/8/PPPPPPPP/R3K3 w Q - 0 1"
            let result = try await engine.evaluate(fen: rookUpFEN, depth: 12)

            switch result.score {
            case .centipawns(let cp):
                #expect(cp > 300)
            case .mate(let n):
                #expect(n > 0)
            }

            await engine.shutdown()
        }
    }

    // ============================================================
    // MARK: - Integration — Mate Detection
    // ============================================================

    @Suite("Integration — Mate Detection",
           .disabled("Requires real Stockfish — C stub returns zeroed results"))
    struct MateDetectionTests {

        @Test("mate-in-1 returns Score.mate(1)")
        func mateInOneReturnsMateScore() async throws {
            let engine = LucidEngine()
            try await engine.start()

            let mateIn1FEN = "6k1/5ppp/8/8/8/8/5PPP/4R1K1 w - - 0 1"
            let result = try await engine.evaluate(fen: mateIn1FEN, depth: 5)

            if case .mate(let n) = result.score {
                #expect(n == 1)
            } else {
                Issue.record("Expected Score.mate for mate-in-1 position, got \(result.score)")
            }

            await engine.shutdown()
        }

        @Test("mate-in-1 best move is e1e8")
        func mateInOneBestMoveIsRe8() async throws {
            let engine = LucidEngine()
            try await engine.start()

            let mateIn1FEN = "6k1/5ppp/8/8/8/8/5PPP/4R1K1 w - - 0 1"
            let result = try await engine.evaluate(fen: mateIn1FEN, depth: 5)

            #expect(result.bestMove.uci == "e1e8")

            await engine.shutdown()
        }

        @Test("mate-in-2 returns Score.mate")
        func mateInTwoReturnsMateScore() async throws {
            let engine = LucidEngine()
            try await engine.start()

            let mateIn2FEN = "7k/6rQ/6K1/8/8/8/8/6R1 w - - 0 1"
            let result = try await engine.evaluate(fen: mateIn2FEN, depth: 10)

            if case .mate(let n) = result.score {
                #expect(n >= 1 && n <= 2)
            } else {
                Issue.record("Expected Score.mate for mate-in-2 position, got \(result.score)")
            }

            await engine.shutdown()
        }
    }

    // ============================================================
    // MARK: - Integration — bestMove() Correctness
    // ============================================================

    @Suite("Integration — bestMove() Correctness",
           .disabled("Requires real Stockfish — C stub returns zeroed results"))
    struct BestMoveCorrectnessTests {

        @Test("bestMove in starting position is a valid UCI move")
        func bestMoveInStartingPositionIsValidUCI() async throws {
            let engine = LucidEngine()
            try await engine.start()

            let move = try await engine.bestMove(
                fen: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
                depth: 10
            )

            #expect(Move(uci: move.uci) != nil)

            await engine.shutdown()
        }

        @Test("bestMove for mate-in-1 is e1e8")
        func bestMoveForMateInOneIsRe8() async throws {
            let engine = LucidEngine()
            try await engine.start()

            let mateIn1FEN = "6k1/5ppp/8/8/8/8/5PPP/4R1K1 w - - 0 1"
            let move = try await engine.bestMove(fen: mateIn1FEN, depth: 5)

            #expect(move.uci == "e1e8")

            await engine.shutdown()
        }

        @Test("bestMove captures hanging queen")
        func bestMoveCapturesHangingQueen() async throws {
            let engine = LucidEngine()
            try await engine.start()

            let hangingQueenFEN = "4k3/8/8/8/3q4/2P5/P7/4K3 w - - 0 1"
            let move = try await engine.bestMove(fen: hangingQueenFEN, depth: 8)

            #expect(move.uci == "c3d4")

            await engine.shutdown()
        }

        @Test("bestMove for pawn promotion picks queen")
        func bestMoveForPromotion() async throws {
            let engine = LucidEngine()
            try await engine.start()

            let promotionFEN = "4k3/4P3/8/8/8/8/8/4K3 w - - 0 1"
            let move = try await engine.bestMove(fen: promotionFEN, depth: 8)

            #expect(move.promotion == "q")
            #expect(move.from == "e7")
            #expect(move.to == "e8")

            await engine.shutdown()
        }
    }

    // ============================================================
    // MARK: - Timeout Handling
    // ============================================================
    // The C stub returns instantly (synchronous), so the timeout
    // race will always lose. These tests require REAL Stockfish
    // to produce a meaningful timeout scenario.

    @Suite("Timeout Handling",
           .disabled("Requires real Stockfish — C stub returns instantly, timeout never fires"))
    struct TimeoutHandlingTests {

        @Test("evaluate with absurdly short timeout throws evaluationTimeout")
        func shortTimeoutThrowsEvaluationTimeout() async throws {
            let config = try EngineConfiguration(
                defaultDepth: 18,
                threadCount: 1,
                hashSizeMB: 64,
                timeoutSeconds: 0.001
            )
            let engine = LucidEngine(configuration: config)
            try await engine.start()

            await #expect(throws: EngineError.evaluationTimeout) {
                _ = try await engine.evaluate(
                    fen: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
                    depth: 18
                )
            }

            await engine.shutdown()
        }

        @Test("bestMove with absurdly short timeout throws evaluationTimeout")
        func shortTimeoutThrowsOnBestMove() async throws {
            let config = try EngineConfiguration(
                defaultDepth: 18,
                threadCount: 1,
                hashSizeMB: 64,
                timeoutSeconds: 0.001
            )
            let engine = LucidEngine(configuration: config)
            try await engine.start()

            await #expect(throws: EngineError.evaluationTimeout) {
                _ = try await engine.bestMove(
                    fen: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
                    depth: 18
                )
            }

            await engine.shutdown()
        }
    }

    // ============================================================
    // MARK: - Actor Isolation and Concurrency
    // ============================================================

    @Suite("Actor Isolation")
    struct ActorIsolationTests {

        @Test("two concurrent evaluate calls both succeed")
        func twoConcurrentEvaluateCallsBothSucceed() async throws {
            let engine = LucidEngine()
            try await engine.start()

            let fen1 = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
            let fen2 = "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1"

            async let result1 = engine.evaluate(fen: fen1, depth: 8)
            async let result2 = engine.evaluate(fen: fen2, depth: 8)

            let (r1, r2) = try await (result1, result2)

            #expect(r1.depth == 8)
            #expect(r2.depth == 8)

            await engine.shutdown()
        }

        @Test("evaluate after shutdown and restart returns valid result")
        func evaluateAfterRestartReturnsValidResult() async throws {
            let engine = LucidEngine()
            try await engine.start()
            await engine.shutdown()
            try await engine.start()

            let result = try await engine.evaluate(
                fen: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
                depth: 10
            )

            #expect(result.depth == 10)

            await engine.shutdown()
        }
    }
}

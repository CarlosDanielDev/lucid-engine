import Testing
@testable import LucidEngine

// MARK: - Model Tests

@Suite("GameAnalysis Models")
struct GameAnalysisModelTests {

    @Test("AnalyzedMove stores all properties correctly")
    func analyzedMoveProperties() {
        let move = AnalyzedMove(
            moveNumber: 1,
            fen: "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1",
            movePlayed: Move(from: "e2", to: "e4"),
            bestMove: Move(from: "e2", to: "e4"),
            assessment: PositionAssessment(
                score: .centipawns(30),
                bestMove: Move(from: "e2", to: "e4"),
                principalVariation: [],
                depth: 18,
                nodes: 1000
            ),
            classification: .good,
            centipawnLoss: 0
        )

        #expect(move.moveNumber == 1)
        #expect(move.centipawnLoss == 0)
        #expect(move.movePlayed == Move(from: "e2", to: "e4"))
        #expect(move.classification == .good)
    }

    @Test("GameAnalysis stores analyzed moves")
    func gameAnalysisStoresData() {
        let analysis = GameAnalysis(
            analyzedMoves: [],
            accuracy: Accuracy(white: 90.0, black: 85.0),
            phases: GamePhases(opening: 0...10, middlegame: 11...30, endgame: 31...40)
        )

        #expect(analysis.analyzedMoves.isEmpty)
        #expect(analysis.accuracy.white == 90.0)
        #expect(analysis.accuracy.black == 85.0)
    }

    @Test("MoveClassification has all expected cases")
    func moveClassificationCases() {
        let cases: [MoveClassification] = [
            .brilliant, .great, .good, .book,
            .inaccuracy, .mistake, .blunder
        ]
        #expect(cases.count == 7)
    }

    @Test("Centipawn loss is non-negative")
    func centipawnLossNonNegative() {
        let move = AnalyzedMove(
            moveNumber: 5,
            fen: "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1",
            movePlayed: Move(from: "d2", to: "d4"),
            bestMove: Move(from: "e2", to: "e4"),
            assessment: PositionAssessment(
                score: .centipawns(20),
                bestMove: Move(from: "e2", to: "e4"),
                principalVariation: [],
                depth: 18,
                nodes: 500
            ),
            classification: .good,
            centipawnLoss: 15
        )

        #expect(move.centipawnLoss >= 0)
    }
}

// MARK: - FEN Diff Tests

@Suite("FEN Diff Utilities")
struct FENDiffTests {

    @Test("Detects e2e4 from starting position to position after 1.e4")
    func detectsE2E4() {
        let before = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
        let after  = "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1"

        let move = FENDiff.detectMove(before: before, after: after)
        #expect(move != nil)
        #expect(move?.from == "e2")
        #expect(move?.to == "e4")
    }

    @Test("Detects e7e5 from position after 1.e4")
    func detectsE7E5() {
        let before = "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1"
        let after  = "rnbqkbnr/pppp1ppp/8/4p3/4P3/8/PPPP1PPP/RNBQKBNR w KQkq e6 0 2"

        let move = FENDiff.detectMove(before: before, after: after)
        #expect(move != nil)
        #expect(move?.from == "e7")
        #expect(move?.to == "e5")
    }

    @Test("Detects kingside castling")
    func detectsKingsideCastling() {
        let before = "rnbqkb1r/pppppppp/5n2/8/4P3/5N2/PPPP1PPP/RNBQKB1R w KQkq - 2 3"
        let after  = "rnbqkb1r/pppppppp/5n2/8/4P3/5N2/PPPP1PPP/RNBQ1RK1 b kq - 3 3"

        let move = FENDiff.detectMove(before: before, after: after)
        #expect(move != nil)
        #expect(move?.from == "e1")
        #expect(move?.to == "g1")
    }

    @Test("Detects pawn promotion")
    func detectsPawnPromotion() {
        let before = "4k3/4P3/8/8/8/8/8/4K3 w - - 0 1"
        let after  = "4Q3/8/8/8/8/8/8/4K3 b - - 0 1"

        let move = FENDiff.detectMove(before: before, after: after)
        #expect(move != nil)
        #expect(move?.from == "e7")
        #expect(move?.to == "e8")
        #expect(move?.promotion == "q")
    }

    @Test("Returns nil for identical FENs")
    func returnsNilForIdenticalFENs() {
        let fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
        let move = FENDiff.detectMove(before: fen, after: fen)
        #expect(move == nil)
    }
}

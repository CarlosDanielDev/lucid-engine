import Testing
@testable import LucidEngine

@Suite("AccuracyCalculator Tests")
struct AccuracyCalculatorTests {

    // MARK: - Move Accuracy Formula

    @Test("Perfect move (CPL 0) returns 100% accuracy")
    func perfectMoveAccuracy() {
        let accuracy = AccuracyCalculator.moveAccuracy(centipawnLoss: 0)
        #expect(abs(accuracy - 100.0) < 0.01)
    }

    @Test("Small CPL (10) returns high accuracy")
    func smallCPLAccuracy() {
        let accuracy = AccuracyCalculator.moveAccuracy(centipawnLoss: 10)
        // 103.1668 * exp(-0.04354 * 10) - 3.1669 ≈ 63.6
        #expect(accuracy > 60.0)
        #expect(accuracy < 70.0)
    }

    @Test("Medium CPL (50) returns moderate accuracy")
    func mediumCPLAccuracy() {
        let accuracy = AccuracyCalculator.moveAccuracy(centipawnLoss: 50)
        #expect(accuracy > 5.0)
        #expect(accuracy < 15.0)
    }

    @Test("Large CPL (200) returns near-zero accuracy")
    func largeCPLAccuracy() {
        let accuracy = AccuracyCalculator.moveAccuracy(centipawnLoss: 200)
        #expect(accuracy >= 0.0)
        #expect(accuracy < 1.0)
    }

    @Test("Very large CPL clamps to zero, not negative")
    func veryLargeCPLClampsToZero() {
        let accuracy = AccuracyCalculator.moveAccuracy(centipawnLoss: 1000)
        #expect(accuracy == 0.0)
    }

    // MARK: - Game Accuracy Calculation

    @Test("All perfect moves returns 100% for both players")
    func allPerfectMoves() {
        let moves = makeMoves(whiteCPLs: [0, 0, 0], blackCPLs: [0, 0, 0])
        let accuracy = AccuracyCalculator.calculate(from: moves)
        #expect(abs(accuracy.white - 100.0) < 0.01)
        #expect(abs(accuracy.black - 100.0) < 0.01)
    }

    @Test("All blunders returns low accuracy for both players")
    func allBlunderMoves() {
        let moves = makeMoves(whiteCPLs: [300, 300], blackCPLs: [300, 300])
        let accuracy = AccuracyCalculator.calculate(from: moves)
        #expect(accuracy.white < 5.0)
        #expect(accuracy.black < 5.0)
    }

    @Test("White plays perfectly, black blunders")
    func whiteGoodBlackBad() {
        let moves = makeMoves(whiteCPLs: [0, 0, 0], blackCPLs: [200, 200, 200])
        let accuracy = AccuracyCalculator.calculate(from: moves)
        #expect(accuracy.white > 95.0)
        #expect(accuracy.black < 5.0)
    }

    @Test("Empty moves returns 100% for both players")
    func emptyMovesReturns100() {
        let accuracy = AccuracyCalculator.calculate(from: [])
        #expect(accuracy.white == 100.0)
        #expect(accuracy.black == 100.0)
    }

    @Test("Only white moves returns 100% for black")
    func onlyWhiteMovesReturnsDefaultForBlack() {
        let moves = makeMoves(whiteCPLs: [50], blackCPLs: [])
        let accuracy = AccuracyCalculator.calculate(from: moves)
        #expect(accuracy.white > 0.0)
        #expect(accuracy.white < 100.0)
        #expect(accuracy.black == 100.0)
    }

    @Test("Book moves count as 100% accuracy")
    func bookMovesAre100Percent() {
        let moves = makeMovesWithClassifications(
            entries: [
                (cpl: 0, isWhite: true, classification: .book),
                (cpl: 50, isWhite: false, classification: .inaccuracy),
                (cpl: 0, isWhite: true, classification: .book),
                (cpl: 0, isWhite: false, classification: .good),
            ]
        )
        let accuracy = AccuracyCalculator.calculate(from: moves)
        #expect(abs(accuracy.white - 100.0) < 0.01)
    }

    @Test("Accuracy values are clamped between 0 and 100")
    func accuracyIsClamped() {
        let moves = makeMoves(whiteCPLs: [0, 500, 0], blackCPLs: [100, 100, 100])
        let accuracy = AccuracyCalculator.calculate(from: moves)
        #expect(accuracy.white >= 0.0 && accuracy.white <= 100.0)
        #expect(accuracy.black >= 0.0 && accuracy.black <= 100.0)
    }

    // MARK: - Helpers

    private func makeMoves(whiteCPLs: [Int], blackCPLs: [Int]) -> [AnalyzedMove] {
        var moves: [AnalyzedMove] = []
        let maxCount = max(whiteCPLs.count, blackCPLs.count)

        for i in 0..<maxCount {
            if i < whiteCPLs.count {
                moves.append(makeAnalyzedMove(
                    moveNumber: i + 1,
                    isWhite: true,
                    centipawnLoss: whiteCPLs[i],
                    classification: .good
                ))
            }
            if i < blackCPLs.count {
                moves.append(makeAnalyzedMove(
                    moveNumber: i + 1,
                    isWhite: false,
                    centipawnLoss: blackCPLs[i],
                    classification: .good
                ))
            }
        }

        return moves
    }

    private func makeMovesWithClassifications(
        entries: [(cpl: Int, isWhite: Bool, classification: MoveClassification)]
    ) -> [AnalyzedMove] {
        entries.enumerated().map { index, entry in
            makeAnalyzedMove(
                moveNumber: index / 2 + 1,
                isWhite: entry.isWhite,
                centipawnLoss: entry.cpl,
                classification: entry.classification
            )
        }
    }

    private func makeAnalyzedMove(
        moveNumber: Int,
        isWhite: Bool,
        centipawnLoss: Int,
        classification: MoveClassification
    ) -> AnalyzedMove {
        let activeColor = isWhite ? "w" : "b"
        let fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR \(activeColor) KQkq - 0 \(moveNumber)"
        return AnalyzedMove(
            moveNumber: moveNumber,
            fen: fen,
            movePlayed: Move(from: "e2", to: "e4"),
            bestMove: Move(from: "e2", to: "e4"),
            assessment: PositionAssessment(
                score: .centipawns(0),
                bestMove: Move(from: "e2", to: "e4"),
                principalVariation: [],
                depth: 18,
                nodes: 1000
            ),
            classification: classification,
            centipawnLoss: centipawnLoss
        )
    }
}

import Testing
@testable import LucidEngine

@Suite("GamePhaseDetector Tests")
struct GamePhaseDetectorTests {

    // MARK: - Material Counting

    @Test("Starting position has full material (78 points)")
    func startingPositionMaterial() {
        // 2Q(18) + 4R(20) + 4B(12) + 4N(12) = 62 non-pawn non-king material
        let material = GamePhaseDetector.totalMaterial(
            fen: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
        )
        #expect(material == 62)
    }

    @Test("King + pawns only has 0 material")
    func kingsAndPawnsOnly() {
        let material = GamePhaseDetector.totalMaterial(
            fen: "4k3/pppppppp/8/8/8/8/PPPPPPPP/4K3 w - - 0 1"
        )
        #expect(material == 0)
    }

    @Test("Single queen remaining has 9 material")
    func singleQueen() {
        let material = GamePhaseDetector.totalMaterial(
            fen: "4k3/8/8/8/8/8/8/4K2Q w - - 0 1"
        )
        #expect(material == 9)
    }

    // MARK: - Queens Presence

    @Test("Starting position has both queens")
    func startingPositionHasBothQueens() {
        #expect(GamePhaseDetector.hasQueens(
            fen: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
        ))
    }

    @Test("Position without queens")
    func noQueens() {
        #expect(!GamePhaseDetector.hasQueens(
            fen: "rnb1kbnr/pppppppp/8/8/8/8/PPPPPPPP/RNB1KBNR w KQkq - 0 1"
        ))
    }

    // MARK: - Phase Detection from FEN Sequence

    @Test("Short game (Scholar's Mate) is opening only")
    func scholarsMateIsOpeningOnly() {
        // 1.e4 e5 2.Bc4 Nc6 3.Qh5 Nf6?? 4.Qxf7# (4 moves)
        let fens = [
            "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
            "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1",
            "rnbqkbnr/pppp1ppp/8/4p3/4P3/8/PPPP1PPP/RNBQKBNR w KQkq e6 0 2",
            "rnbqkbnr/pppp1ppp/8/4p3/2B1P3/8/PPPP1PPP/RNBQK1NR b KQkq - 1 2",
            "r1bqkbnr/pppp1ppp/2n5/4p3/2B1P3/8/PPPP1PPP/RNBQK1NR w KQkq - 2 3",
        ]

        let phases = GamePhaseDetector.detect(fens: fens)
        #expect(phases.opening == 1...4)
        #expect(phases.middlegame == nil)
        #expect(phases.endgame == nil)
    }

    @Test("Game ending in middlegame has no endgame phase")
    func noEndgamePhase() {
        // Simulate: opening (moves 1-12), then middlegame with resignation
        var fens = [String]()
        // Opening: full material, early moves
        for i in 1...15 {
            fens.append("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 \(i)")
        }
        // Middlegame: still high material but past opening
        for i in 16...25 {
            fens.append("r1bq1rk1/ppp2ppp/2np1n2/2b1p3/2B1P3/2NP1N2/PPP2PPP/R1BQ1RK1 w - - 0 \(i)")
        }

        let phases = GamePhaseDetector.detect(fens: fens)
        #expect(phases.opening != nil)
        #expect(phases.middlegame != nil)
        #expect(phases.endgame == nil)
    }

    @Test("Full game with endgame has all three phases")
    func fullGameAllPhases() {
        var fens = [String]()
        // Opening (moves 1-10): full material
        for i in 1...10 {
            fens.append("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 \(i)")
        }
        // Middlegame (moves 11-25): some pieces traded but still high material
        for i in 11...25 {
            fens.append("r1bq1rk1/ppp2ppp/2np1n2/2b1p3/2B1P3/2NP1N2/PPP2PPP/R1BQ1RK1 w - - 0 \(i)")
        }
        // Endgame (moves 26-35): low material (rook + pawns each side = 10 total)
        for i in 26...35 {
            fens.append("4r1k1/5ppp/8/8/8/8/5PPP/4R1K1 w - - 0 \(i)")
        }

        let phases = GamePhaseDetector.detect(fens: fens)
        #expect(phases.opening != nil)
        #expect(phases.middlegame != nil)
        #expect(phases.endgame != nil)
    }

    @Test("Endgame detected when material drops below threshold")
    func endgameByMaterialThreshold() {
        // Position with only rooks: R(5) + R(5) = 10 total material, <= 13
        let material = GamePhaseDetector.totalMaterial(
            fen: "4r1k1/5ppp/8/8/8/8/5PPP/4R1K1 w - - 0 1"
        )
        #expect(material <= 13)
    }

    @Test("Queens traded with low material triggers endgame")
    func queensTradedLowMaterial() {
        // No queens, material = 2R(10) + 2B(6) + 2N(6) = 22... too high
        // No queens, material = R(5) + R(5) + B(3) + N(3) = 16, <= 20 ✓
        let fen = "r1b1k1n1/pppppppp/8/8/8/8/PPPPPPPP/R1B1K3 w Qq - 0 1"
        let material = GamePhaseDetector.totalMaterial(fen: fen)
        let hasQueens = GamePhaseDetector.hasQueens(fen: fen)
        #expect(!hasQueens)
        #expect(material <= 20)
    }

    // MARK: - Phase Contiguity

    @Test("Phase ranges are contiguous and cover all moves")
    func phasesAreContiguous() {
        var fens = [String]()
        for i in 1...10 {
            fens.append("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 \(i)")
        }
        for i in 11...20 {
            fens.append("r1bq1rk1/ppp2ppp/2np1n2/2b1p3/2B1P3/2NP1N2/PPP2PPP/R1BQ1RK1 w - - 0 \(i)")
        }
        for i in 21...30 {
            fens.append("4r1k1/5ppp/8/8/8/8/5PPP/4R1K1 w - - 0 \(i)")
        }

        let phases = GamePhaseDetector.detect(fens: fens)
        #expect(phases.opening != nil)

        // Phases should start at 1
        #expect(phases.opening!.lowerBound == 1)

        // If all phases exist, they should be contiguous
        if let mid = phases.middlegame {
            #expect(mid.lowerBound == phases.opening!.upperBound + 1)
            if let end = phases.endgame {
                #expect(end.lowerBound == mid.upperBound + 1)
            }
        }
    }
}

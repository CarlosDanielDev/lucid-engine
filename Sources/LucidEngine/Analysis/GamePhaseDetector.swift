public enum GamePhaseDetector {

    /// Material values for non-king, non-pawn pieces.
    private static let pieceValues: [Character: Int] = [
        "Q": 9, "q": 9,
        "R": 5, "r": 5,
        "B": 3, "b": 3,
        "N": 3, "n": 3,
    ]

    /// Total material of all non-king, non-pawn pieces for both sides.
    public static func totalMaterial(fen: String) -> Int {
        let placement = fen.prefix(while: { $0 != " " })
        return placement.reduce(0) { sum, ch in
            sum + (pieceValues[ch] ?? 0)
        }
    }

    /// Whether at least one queen exists on the board.
    public static func hasQueens(fen: String) -> Bool {
        let placement = fen.prefix(while: { $0 != " " })
        return placement.contains("Q") || placement.contains("q")
    }

    /// Detect game phases from a sequence of FEN positions.
    ///
    /// - Opening: move 1 until middlegame transition (move 15+ or development complete)
    /// - Middlegame: from opening end until endgame transition
    /// - Endgame: total non-pawn/king material <= 13, or queens traded with material <= 20
    public static func detect(fens: [String]) -> GamePhases {
        guard fens.count >= 2 else {
            return GamePhases(opening: nil, middlegame: nil, endgame: nil)
        }

        let totalMoves = fens.count - 1 // transitions between positions
        var middlegameStart: Int?
        var endgameStart: Int?

        for moveIndex in 1...totalMoves {
            let fen = fens[moveIndex - 1] // position before the move
            let material = totalMaterial(fen: fen)
            let queens = hasQueens(fen: fen)

            // Endgame detection
            if endgameStart == nil && middlegameStart != nil {
                let isEndgame = material <= 13 || (!queens && material <= 20)
                if isEndgame {
                    endgameStart = moveIndex
                }
            }

            // Middlegame detection: starts at move 15+ or when material starts dropping
            if middlegameStart == nil && moveIndex >= 15 {
                middlegameStart = moveIndex
            }
        }

        // Build phase ranges
        let lastMove = totalMoves

        if let midStart = middlegameStart {
            let openingRange = 1...(midStart - 1)

            if let endStart = endgameStart {
                return GamePhases(
                    opening: openingRange,
                    middlegame: midStart...(endStart - 1),
                    endgame: endStart...lastMove
                )
            } else {
                return GamePhases(
                    opening: openingRange,
                    middlegame: midStart...lastMove,
                    endgame: nil
                )
            }
        } else {
            // Entire game is opening
            return GamePhases(
                opening: 1...lastMove,
                middlegame: nil,
                endgame: nil
            )
        }
    }
}

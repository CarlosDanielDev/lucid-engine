import Foundation

public enum AccuracyCalculator {

    /// Per-move accuracy using the Lichess sigmoid formula.
    /// `moveAccuracy = 103.1668 * exp(-0.04354 * CPL) - 3.1669`, clamped to [0, 100].
    public static func moveAccuracy(centipawnLoss: Int) -> Double {
        let cpl = Double(centipawnLoss)
        let raw = 103.1668 * exp(-0.04354 * cpl) - 3.1669
        return min(100.0, max(0.0, raw))
    }

    /// Calculate accuracy per player from analyzed moves.
    /// White/black is determined by the active color in each move's FEN.
    /// Book moves count as 100% accuracy. Empty move lists default to 100%.
    public static func calculate(from moves: [AnalyzedMove]) -> Accuracy {
        var whiteSum = 0.0
        var whiteCount = 0
        var blackSum = 0.0
        var blackCount = 0

        for move in moves {
            let acc: Double = move.classification == .book
                ? 100.0
                : moveAccuracy(centipawnLoss: move.centipawnLoss)

            if FENDiff.parseActiveColor(fen: move.fen) == "w" {
                whiteSum += acc
                whiteCount += 1
            } else {
                blackSum += acc
                blackCount += 1
            }
        }

        return Accuracy(
            white: whiteCount == 0 ? 100.0 : whiteSum / Double(whiteCount),
            black: blackCount == 0 ? 100.0 : blackSum / Double(blackCount)
        )
    }
}

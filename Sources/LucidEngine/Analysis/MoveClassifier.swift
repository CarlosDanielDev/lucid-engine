public enum MoveClassifier {

    /// Classify a move based on centipawn loss and positional context.
    ///
    /// - Parameters:
    ///   - centipawnLoss: The centipawn loss for the move (>= 0).
    ///   - scoreBefore: Engine evaluation before the move (from side-to-move perspective).
    ///   - scoreAfter: Engine evaluation after the move (from side-to-move perspective, negated).
    ///   - isSacrifice: Whether the move involves a material sacrifice.
    ///   - isOnlyGoodMove: Whether this was the only move that didn't lose significant eval.
    public static func classify(
        centipawnLoss: Int,
        scoreBefore: Score,
        scoreAfter: Score,
        isSacrifice: Bool = false,
        isOnlyGoodMove: Bool = false
    ) -> MoveClassification {
        // Rule: Missing a forced mate = always blunder
        if isMissedMate(scoreBefore: scoreBefore, scoreAfter: scoreAfter) {
            return .blunder
        }

        // Rule: Allowing opponent mate when position was safe = blunder
        if isAllowedMate(scoreBefore: scoreBefore, scoreAfter: scoreAfter) {
            return .blunder
        }

        // CPL-based thresholds
        if centipawnLoss > 200 {
            return .blunder
        }

        if centipawnLoss >= 80 {
            return .mistake
        }

        if centipawnLoss >= 30 {
            return .inaccuracy
        }

        // Low CPL (< 30): good, great, or brilliant
        if isSacrifice {
            return .brilliant
        }

        if isOnlyGoodMove {
            return .great
        }

        return .good
    }

    // MARK: - Private Helpers

    /// Returns true if the side had a forced mate before but lost it after the move.
    private static func isMissedMate(scoreBefore: Score, scoreAfter: Score) -> Bool {
        guard case .mate(let n) = scoreBefore, n > 0 else {
            return false
        }
        // Still has mate? Not a miss.
        if case .mate(let m) = scoreAfter, m > 0 {
            return false
        }
        return true
    }

    /// Returns true if the position was safe but now the opponent has a forced mate.
    private static func isAllowedMate(scoreBefore: Score, scoreAfter: Score) -> Bool {
        // Was not getting mated before
        let wasGettingMated: Bool
        if case .mate(let n) = scoreBefore, n < 0 {
            wasGettingMated = true
        } else {
            wasGettingMated = false
        }

        guard !wasGettingMated else { return false }

        // Now getting mated
        if case .mate(let m) = scoreAfter, m < 0 {
            return true
        }

        return false
    }
}

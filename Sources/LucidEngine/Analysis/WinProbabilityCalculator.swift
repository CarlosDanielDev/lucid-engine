import Foundation

public enum WinProbabilityCalculator {

    /// Convert a Stockfish score to win/draw/loss probabilities.
    ///
    /// Uses a logistic model calibrated from engine self-play:
    /// - Win expectancy via logistic function with k=0.006
    /// - Draw probability modeled as Gaussian decay from equal position
    /// - Mate scores are absolute: 100% win or 100% loss.
    public static func calculate(score: Score) -> WinProbability {
        switch score {
        case .mate(let n):
            return n > 0
                ? WinProbability(white: 1.0, draw: 0.0, black: 0.0)
                : WinProbability(white: 0.0, draw: 0.0, black: 1.0)

        case .centipawns(let cp):
            return calculateFromCentipawns(cp)
        }
    }

    private static func calculateFromCentipawns(_ cp: Int) -> WinProbability {
        let x = Double(cp)
        let k = 0.006

        // Logistic win expectancy from white's perspective
        let winExpectancy = 1.0 / (1.0 + exp(-k * x))

        // Draw probability peaks near equal positions, Gaussian decay with score
        let draw = 0.12 * exp(-0.00001 * x * x)

        let white = max(0.0, winExpectancy - draw / 2.0)
        let black = max(0.0, 1.0 - winExpectancy - draw / 2.0)

        return WinProbability(white: white, draw: draw, black: black)
    }
}

import Testing
@testable import LucidEngine

@Suite("WinProbability Tests")
struct WinProbabilityTests {

    // MARK: - Model

    @Test("Probabilities sum to 1.0")
    func probabilitiesSumToOne() {
        let wp = WinProbability(white: 0.5, draw: 0.25, black: 0.25)
        let sum = wp.white + wp.draw + wp.black
        #expect(abs(sum - 1.0) < 0.001)
    }

    // MARK: - Equal Position

    @Test("Equal position (~0cp) returns roughly 50% win for white")
    func equalPositionWinProbability() {
        let wp = WinProbabilityCalculator.calculate(score: .centipawns(0))
        #expect(wp.white > 0.40 && wp.white < 0.60)
        #expect(wp.draw > 0.10)
        #expect(wp.black > 0.40 && wp.black < 0.60)
        #expect(abs(wp.white + wp.draw + wp.black - 1.0) < 0.001)
    }

    // MARK: - Winning Positions

    @Test("+500cp returns >90% win for white")
    func largeAdvantageWhite() {
        let wp = WinProbabilityCalculator.calculate(score: .centipawns(500))
        #expect(wp.white > 0.90)
        #expect(wp.black < 0.05)
        #expect(abs(wp.white + wp.draw + wp.black - 1.0) < 0.001)
    }

    @Test("-500cp returns >90% win for black")
    func largeAdvantageBlack() {
        let wp = WinProbabilityCalculator.calculate(score: .centipawns(-500))
        #expect(wp.black > 0.90)
        #expect(wp.white < 0.05)
        #expect(abs(wp.white + wp.draw + wp.black - 1.0) < 0.001)
    }

    @Test("+200cp returns noticeable white advantage")
    func moderateAdvantageWhite() {
        let wp = WinProbabilityCalculator.calculate(score: .centipawns(200))
        #expect(wp.white > 0.60)
        #expect(wp.white < 0.95)
        #expect(abs(wp.white + wp.draw + wp.black - 1.0) < 0.001)
    }

    // MARK: - Mate Scores

    @Test("Mate for white returns 100% white win")
    func mateForWhite() {
        let wp = WinProbabilityCalculator.calculate(score: .mate(3))
        #expect(wp.white == 1.0)
        #expect(wp.draw == 0.0)
        #expect(wp.black == 0.0)
    }

    @Test("Mate for black returns 100% black win")
    func mateForBlack() {
        let wp = WinProbabilityCalculator.calculate(score: .mate(-3))
        #expect(wp.white == 0.0)
        #expect(wp.draw == 0.0)
        #expect(wp.black == 1.0)
    }

    // MARK: - Symmetry

    @Test("Symmetric scores produce symmetric probabilities")
    func symmetry() {
        let wpPlus = WinProbabilityCalculator.calculate(score: .centipawns(100))
        let wpMinus = WinProbabilityCalculator.calculate(score: .centipawns(-100))
        #expect(abs(wpPlus.white - wpMinus.black) < 0.001)
        #expect(abs(wpPlus.black - wpMinus.white) < 0.001)
        #expect(abs(wpPlus.draw - wpMinus.draw) < 0.001)
    }

    // MARK: - Probability Constraints

    @Test("All probabilities are between 0 and 1")
    func probabilitiesInRange() {
        let scores: [Score] = [
            .centipawns(-1000), .centipawns(-500), .centipawns(-100),
            .centipawns(0), .centipawns(100), .centipawns(500),
            .centipawns(1000), .mate(1), .mate(-1)
        ]
        for score in scores {
            let wp = WinProbabilityCalculator.calculate(score: score)
            #expect(wp.white >= 0.0 && wp.white <= 1.0, "white out of range for \(score)")
            #expect(wp.draw >= 0.0 && wp.draw <= 1.0, "draw out of range for \(score)")
            #expect(wp.black >= 0.0 && wp.black <= 1.0, "black out of range for \(score)")
            #expect(abs(wp.white + wp.draw + wp.black - 1.0) < 0.001, "sum != 1.0 for \(score)")
        }
    }

    // MARK: - Monotonicity

    @Test("Higher score means higher white win probability")
    func monotonicity() {
        let scores = [-500, -200, -100, 0, 100, 200, 500]
        var previousWhite = 0.0
        for cp in scores {
            let wp = WinProbabilityCalculator.calculate(score: .centipawns(cp))
            #expect(wp.white >= previousWhite, "Not monotonic at \(cp)cp")
            previousWhite = wp.white
        }
    }
}

import Testing
@testable import LucidEngine

@Suite("MoveClassification Tests")
struct MoveClassificationTests {

    // MARK: - Comparable Conformance

    @Test("Brilliant is the highest classification")
    func brilliantIsHighest() {
        #expect(MoveClassification.brilliant > MoveClassification.great)
        #expect(MoveClassification.brilliant > MoveClassification.blunder)
    }

    @Test("Blunder is the lowest classification")
    func blunderIsLowest() {
        #expect(MoveClassification.blunder < MoveClassification.mistake)
        #expect(MoveClassification.blunder < MoveClassification.brilliant)
    }

    @Test("Full ordering: brilliant > great > good > book > inaccuracy > mistake > blunder")
    func fullOrdering() {
        let ordered: [MoveClassification] = [
            .brilliant, .great, .good, .book, .inaccuracy, .mistake, .blunder
        ]
        for i in 0..<ordered.count {
            for j in (i + 1)..<ordered.count {
                #expect(ordered[i] > ordered[j],
                        "\(ordered[i]) should be > \(ordered[j])")
            }
        }
    }

    // MARK: - CPL-Based Classification

    @Test("CPL 0 classifies as good")
    func cplZeroIsGood() {
        let result = MoveClassifier.classify(
            centipawnLoss: 0,
            scoreBefore: .centipawns(50),
            scoreAfter: .centipawns(50)
        )
        #expect(result == .good)
    }

    @Test("CPL 10 classifies as good")
    func cplTenIsGood() {
        let result = MoveClassifier.classify(
            centipawnLoss: 10,
            scoreBefore: .centipawns(50),
            scoreAfter: .centipawns(40)
        )
        #expect(result == .good)
    }

    @Test("CPL 25 classifies as good (generous threshold)")
    func cplTwentyFiveIsGood() {
        let result = MoveClassifier.classify(
            centipawnLoss: 25,
            scoreBefore: .centipawns(100),
            scoreAfter: .centipawns(75)
        )
        #expect(result == .good)
    }

    @Test("CPL 30 classifies as inaccuracy")
    func cplThirtyIsInaccuracy() {
        let result = MoveClassifier.classify(
            centipawnLoss: 30,
            scoreBefore: .centipawns(100),
            scoreAfter: .centipawns(70)
        )
        #expect(result == .inaccuracy)
    }

    @Test("CPL 50 classifies as inaccuracy")
    func cplFiftyIsInaccuracy() {
        let result = MoveClassifier.classify(
            centipawnLoss: 50,
            scoreBefore: .centipawns(100),
            scoreAfter: .centipawns(50)
        )
        #expect(result == .inaccuracy)
    }

    @Test("CPL 80 classifies as mistake")
    func cplEightyIsMistake() {
        let result = MoveClassifier.classify(
            centipawnLoss: 80,
            scoreBefore: .centipawns(200),
            scoreAfter: .centipawns(120)
        )
        #expect(result == .mistake)
    }

    @Test("CPL 150 classifies as mistake")
    func cplOneHundredFiftyIsMistake() {
        let result = MoveClassifier.classify(
            centipawnLoss: 150,
            scoreBefore: .centipawns(200),
            scoreAfter: .centipawns(50)
        )
        #expect(result == .mistake)
    }

    @Test("CPL 200 classifies as mistake (boundary)")
    func cplTwoHundredIsMistake() {
        let result = MoveClassifier.classify(
            centipawnLoss: 200,
            scoreBefore: .centipawns(300),
            scoreAfter: .centipawns(100)
        )
        #expect(result == .mistake)
    }

    @Test("CPL 201 classifies as blunder")
    func cplTwoHundredOneIsBlunder() {
        let result = MoveClassifier.classify(
            centipawnLoss: 201,
            scoreBefore: .centipawns(300),
            scoreAfter: .centipawns(99)
        )
        #expect(result == .blunder)
    }

    @Test("CPL 500 classifies as blunder")
    func cplFiveHundredIsBlunder() {
        let result = MoveClassifier.classify(
            centipawnLoss: 500,
            scoreBefore: .centipawns(600),
            scoreAfter: .centipawns(100)
        )
        #expect(result == .blunder)
    }

    // MARK: - Mate Detection (Blunder)

    @Test("Missing forced mate is always blunder regardless of CPL")
    func missingForcedMateIsBlunder() {
        // Had mate-in-3, played a move that lost the mate
        let result = MoveClassifier.classify(
            centipawnLoss: 5,
            scoreBefore: .mate(3),
            scoreAfter: .centipawns(200)
        )
        #expect(result == .blunder)
    }

    @Test("Allowing opponent mate when position was safe is blunder")
    func allowingOpponentMateIsBlunder() {
        // Was winning, now getting mated
        let result = MoveClassifier.classify(
            centipawnLoss: 0,
            scoreBefore: .centipawns(100),
            scoreAfter: .mate(-3)
        )
        #expect(result == .blunder)
    }

    @Test("Moving from mate to mate is not a blunder")
    func mateToMateIsNotBlunder() {
        // Had mate-in-3, still have mate-in-5
        let result = MoveClassifier.classify(
            centipawnLoss: 0,
            scoreBefore: .mate(3),
            scoreAfter: .mate(5)
        )
        #expect(result == .good)
    }

    // MARK: - Brilliant Detection

    @Test("Sacrifice that maintains eval is brilliant")
    func sacrificeMaintainingEvalIsBrilliant() {
        // Material sacrifice (indicated by materialDelta) with low CPL
        let result = MoveClassifier.classify(
            centipawnLoss: 5,
            scoreBefore: .centipawns(50),
            scoreAfter: .centipawns(45),
            isSacrifice: true
        )
        #expect(result == .brilliant)
    }

    @Test("Sacrifice with high CPL is not brilliant")
    func sacrificeWithHighCPLIsNotBrilliant() {
        // Material sacrifice but position got worse
        let result = MoveClassifier.classify(
            centipawnLoss: 100,
            scoreBefore: .centipawns(200),
            scoreAfter: .centipawns(100),
            isSacrifice: true
        )
        #expect(result == .mistake)
    }

    // MARK: - Great Detection

    @Test("Only good move in critical position is great")
    func onlyGoodMoveIsGreat() {
        let result = MoveClassifier.classify(
            centipawnLoss: 0,
            scoreBefore: .centipawns(50),
            scoreAfter: .centipawns(50),
            isOnlyGoodMove: true
        )
        #expect(result == .great)
    }

    @Test("Only good move but with sacrifice is still brilliant")
    func onlyGoodMoveWithSacrificeIsBrilliant() {
        let result = MoveClassifier.classify(
            centipawnLoss: 0,
            scoreBefore: .centipawns(50),
            scoreAfter: .centipawns(50),
            isSacrifice: true,
            isOnlyGoodMove: true
        )
        #expect(result == .brilliant)
    }
}

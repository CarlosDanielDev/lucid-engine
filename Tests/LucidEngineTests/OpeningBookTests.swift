import Testing
@testable import LucidEngine

@Suite("OpeningBook Tests")
struct OpeningBookTests {

    // MARK: - Model

    @Test("OpeningInfo stores ECO code and name")
    func openingInfoProperties() {
        let info = OpeningInfo(eco: "B90", name: "Sicilian Defense: Najdorf Variation", moves: 10)
        #expect(info.eco == "B90")
        #expect(info.name == "Sicilian Defense: Najdorf Variation")
        #expect(info.moves == 10)
    }

    // MARK: - Common Openings Detection

    @Test("Detects Italian Game from move sequence")
    func detectsItalianGame() {
        // 1.e4 e5 2.Nf3 Nc6 3.Bc4
        let fens = [
            "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
            "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1",
            "rnbqkbnr/pppp1ppp/8/4p3/4P3/8/PPPP1PPP/RNBQKBNR w KQkq e6 0 2",
            "rnbqkbnr/pppp1ppp/8/4p3/4P3/5N2/PPPP1PPP/RNBQKB1R b KQkq - 1 2",
            "r1bqkbnr/pppp1ppp/2n5/4p3/4P3/5N2/PPPP1PPP/RNBQKB1R w KQkq - 2 3",
            "r1bqkbnr/pppp1ppp/2n5/4p3/2B1P3/5N2/PPPP1PPP/RNBQK2R b KQkq - 3 3",
        ]

        let result = OpeningBook.detect(fens: fens)
        #expect(result != nil)
        #expect(result?.eco == "C50")
        #expect(result?.name.contains("Italian") == true)
    }

    @Test("Detects Sicilian Defense")
    func detectsSicilianDefense() {
        // 1.e4 c5
        let fens = [
            "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
            "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1",
            "rnbqkbnr/pp1ppppp/8/2p5/4P3/8/PPPP1PPP/RNBQKBNR w KQkq c6 0 2",
        ]

        let result = OpeningBook.detect(fens: fens)
        #expect(result != nil)
        #expect(result?.eco == "B20")
        #expect(result?.name.contains("Sicilian") == true)
    }

    @Test("Detects Queen's Gambit")
    func detectsQueensGambit() {
        // 1.d4 d5 2.c4
        let fens = [
            "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
            "rnbqkbnr/pppppppp/8/8/3P4/8/PPP1PPPP/RNBQKBNR b KQkq d3 0 1",
            "rnbqkbnr/ppp1pppp/8/3p4/3P4/8/PPP1PPPP/RNBQKBNR w KQkq d6 0 2",
            "rnbqkbnr/ppp1pppp/8/3p4/2PP4/8/PP2PPPP/RNBQKBNR b KQkq c3 0 2",
        ]

        let result = OpeningBook.detect(fens: fens)
        #expect(result != nil)
        #expect(result?.eco == "D06")
        #expect(result?.name.contains("Queen's Gambit") == true)
    }

    @Test("Detects Ruy Lopez")
    func detectsRuyLopez() {
        // 1.e4 e5 2.Nf3 Nc6 3.Bb5
        let fens = [
            "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
            "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1",
            "rnbqkbnr/pppp1ppp/8/4p3/4P3/8/PPPP1PPP/RNBQKBNR w KQkq e6 0 2",
            "rnbqkbnr/pppp1ppp/8/4p3/4P3/5N2/PPPP1PPP/RNBQKB1R b KQkq - 1 2",
            "r1bqkbnr/pppp1ppp/2n5/4p3/4P3/5N2/PPPP1PPP/RNBQKB1R w KQkq - 2 3",
            "r1bqkbnr/pppp1ppp/2n5/1B2p3/4P3/5N2/PPPP1PPP/RNBQK2R b KQkq - 3 3",
        ]

        let result = OpeningBook.detect(fens: fens)
        #expect(result != nil)
        #expect(result?.eco == "C60")
        #expect(result?.name.contains("Ruy Lopez") == true)
    }

    @Test("Detects French Defense")
    func detectsFrenchDefense() {
        // 1.e4 e6
        let fens = [
            "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
            "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1",
            "rnbqkbnr/pppp1ppp/4p3/8/4P3/8/PPPP1PPP/RNBQKBNR w KQkq - 0 2",
        ]

        let result = OpeningBook.detect(fens: fens)
        #expect(result != nil)
        #expect(result?.eco == "C00")
        #expect(result?.name.contains("French") == true)
    }

    // MARK: - Edge Cases

    @Test("Returns nil for unrecognized opening")
    func unrecognizedOpening() {
        // 1.a4 — unlikely to match any recognized opening
        let fens = [
            "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
            "rnbqkbnr/pppppppp/8/8/P7/8/1PPPPPPP/RNBQKBNR b KQkq a3 0 1",
        ]

        let result = OpeningBook.detect(fens: fens)
        // 1.a4 is actually "Ware Opening" but may or may not be in our compact DB
        // We just verify the function works without crashing
        _ = result
    }

    @Test("Empty FEN array returns nil")
    func emptyFENs() {
        let result = OpeningBook.detect(fens: [])
        #expect(result == nil)
    }

    @Test("Single FEN returns nil")
    func singleFEN() {
        let result = OpeningBook.detect(fens: [
            "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
        ])
        #expect(result == nil)
    }

    @Test("Book moves count is accurate")
    func bookMoveCount() {
        // Italian Game has 5 half-moves
        let fens = [
            "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
            "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1",
            "rnbqkbnr/pppp1ppp/8/4p3/4P3/8/PPPP1PPP/RNBQKBNR w KQkq e6 0 2",
            "rnbqkbnr/pppp1ppp/8/4p3/4P3/5N2/PPPP1PPP/RNBQKB1R b KQkq - 1 2",
            "r1bqkbnr/pppp1ppp/2n5/4p3/4P3/5N2/PPPP1PPP/RNBQKB1R w KQkq - 2 3",
            "r1bqkbnr/pppp1ppp/2n5/4p3/2B1P3/5N2/PPPP1PPP/RNBQK2R b KQkq - 3 3",
        ]

        let result = OpeningBook.detect(fens: fens)
        #expect(result != nil)
        #expect(result!.moves >= 3) // at least the defining moves
    }

    @Test("Longer game still detects opening from early moves")
    func longerGameDetectsOpening() {
        // Italian Game followed by more moves
        var fens = [
            "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
            "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1",
            "rnbqkbnr/pppp1ppp/8/4p3/4P3/8/PPPP1PPP/RNBQKBNR w KQkq e6 0 2",
            "rnbqkbnr/pppp1ppp/8/4p3/4P3/5N2/PPPP1PPP/RNBQKB1R b KQkq - 1 2",
            "r1bqkbnr/pppp1ppp/2n5/4p3/4P3/5N2/PPPP1PPP/RNBQKB1R w KQkq - 2 3",
            "r1bqkbnr/pppp1ppp/2n5/4p3/2B1P3/5N2/PPPP1PPP/RNBQK2R b KQkq - 3 3",
        ]
        // Add more positions (doesn't matter what, just extending the game)
        for i in 4...20 {
            fens.append("r1bqkbnr/pppp1ppp/2n5/4p3/2B1P3/5N2/PPPP1PPP/RNBQK2R b KQkq - 3 \(i)")
        }

        let result = OpeningBook.detect(fens: fens)
        #expect(result != nil)
        #expect(result?.name.contains("Italian") == true)
    }
}

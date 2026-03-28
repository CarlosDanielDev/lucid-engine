/// Compact ECO opening database for detecting known opening lines.
///
/// Matches FEN positions (piece placement only) against a curated set of
/// common openings. Returns the deepest matching opening found.
public enum OpeningBook {

    /// Detect the opening from a sequence of FEN positions.
    /// Returns the deepest (most specific) matching opening, or nil if none match.
    public static func detect(fens: [String]) -> OpeningInfo? {
        guard fens.count >= 2 else { return nil }

        var bestMatch: OpeningInfo?

        // Check each position against the database, keeping the deepest match
        for i in 1..<fens.count {
            let placement = extractPlacement(fen: fens[i])
            if let entry = database[placement] {
                let halfMoves = i // number of half-moves played
                let candidate = OpeningInfo(eco: entry.eco, name: entry.name, moves: halfMoves)
                if bestMatch == nil || halfMoves > bestMatch!.moves {
                    bestMatch = candidate
                }
            }
        }

        return bestMatch
    }

    /// Extract just the piece placement (first field) from a FEN string.
    private static func extractPlacement(fen: String) -> String {
        String(fen.prefix(while: { $0 != " " }))
    }

    // MARK: - ECO Database

    private struct Entry {
        let eco: String
        let name: String
    }

    /// Compact opening database keyed by FEN piece placement.
    /// Covers ~50 common openings. Size: ~15KB in memory.
    private static let database: [String: Entry] = [
        // === King's Pawn Openings (1.e4) ===

        // 1.e4 e5 — King's Pawn Game
        "rnbqkbnr/pppp1ppp/8/4p3/4P3/8/PPPP1PPP/RNBQKBNR": Entry(
            eco: "C20", name: "King's Pawn Game"),

        // 1.e4 e5 2.Nf3 — King's Knight Opening
        "rnbqkbnr/pppp1ppp/8/4p3/4P3/5N2/PPPP1PPP/RNBQKB1R": Entry(
            eco: "C40", name: "King's Knight Opening"),

        // 1.e4 e5 2.Nf3 Nc6 — Two Knights Defense setup
        "r1bqkbnr/pppp1ppp/2n5/4p3/4P3/5N2/PPPP1PPP/RNBQKB1R": Entry(
            eco: "C44", name: "King's Pawn Game: Two Knights"),

        // 1.e4 e5 2.Nf3 Nc6 3.Bc4 — Italian Game
        "r1bqkbnr/pppp1ppp/2n5/4p3/2B1P3/5N2/PPPP1PPP/RNBQK2R": Entry(
            eco: "C50", name: "Italian Game"),

        // 1.e4 e5 2.Nf3 Nc6 3.Bb5 — Ruy Lopez
        "r1bqkbnr/pppp1ppp/2n5/1B2p3/4P3/5N2/PPPP1PPP/RNBQK2R": Entry(
            eco: "C60", name: "Ruy Lopez"),

        // 1.e4 e5 2.Nf3 Nf6 — Petrov's Defense
        "rnbqkb1r/pppp1ppp/5n2/4p3/4P3/5N2/PPPP1PPP/RNBQKB1R": Entry(
            eco: "C42", name: "Petrov's Defense"),

        // 1.e4 e5 2.Nf3 Nc6 3.d4 — Scotch Game
        "r1bqkbnr/pppp1ppp/2n5/4p3/3PP3/5N2/PPP2PPP/RNBQKB1R": Entry(
            eco: "C44", name: "Scotch Game"),

        // 1.e4 e5 2.Nf3 Nc6 3.Nc3 — Three Knights Game
        "r1bqkbnr/pppp1ppp/2n5/4p3/4P3/2N2N2/PPPP1PPP/R1BQKB1R": Entry(
            eco: "C46", name: "Three Knights Game"),

        // 1.e4 e5 2.f4 — King's Gambit
        "rnbqkbnr/pppp1ppp/8/4p3/4PP2/8/PPPP2PP/RNBQKBNR": Entry(
            eco: "C30", name: "King's Gambit"),

        // 1.e4 e5 2.Bc4 — Bishop's Opening
        "rnbqkbnr/pppp1ppp/8/4p3/2B1P3/8/PPPP1PPP/RNBQK1NR": Entry(
            eco: "C23", name: "Bishop's Opening"),

        // === Sicilian Defense (1.e4 c5) ===

        // 1.e4 c5
        "rnbqkbnr/pp1ppppp/8/2p5/4P3/8/PPPP1PPP/RNBQKBNR": Entry(
            eco: "B20", name: "Sicilian Defense"),

        // 1.e4 c5 2.Nf3
        "rnbqkbnr/pp1ppppp/8/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R": Entry(
            eco: "B27", name: "Sicilian Defense"),

        // 1.e4 c5 2.Nf3 d6 3.d4 — Open Sicilian
        "rnbqkbnr/pp2pppp/3p4/2p5/3PP3/5N2/PPP2PPP/RNBQKB1R": Entry(
            eco: "B50", name: "Sicilian Defense: Open"),

        // 1.e4 c5 2.Nf3 Nc6 — Sicilian: Old Sicilian
        "r1bqkbnr/pp1ppppp/2n5/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R": Entry(
            eco: "B30", name: "Sicilian Defense: Old Sicilian"),

        // 1.e4 c5 2.Nf3 e6 — Sicilian: French Variation
        "rnbqkbnr/pp1p1ppp/4p3/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R": Entry(
            eco: "B40", name: "Sicilian Defense: French Variation"),

        // === French Defense (1.e4 e6) ===

        // 1.e4 e6
        "rnbqkbnr/pppp1ppp/4p3/8/4P3/8/PPPP1PPP/RNBQKBNR": Entry(
            eco: "C00", name: "French Defense"),

        // 1.e4 e6 2.d4 d5 — French: Main Line
        "rnbqkbnr/ppp2ppp/4p3/3p4/3PP3/8/PPP2PPP/RNBQKBNR": Entry(
            eco: "C01", name: "French Defense: Main Line"),

        // === Caro-Kann (1.e4 c6) ===

        // 1.e4 c6
        "rnbqkbnr/pp1ppppp/2p5/8/4P3/8/PPPP1PPP/RNBQKBNR": Entry(
            eco: "B10", name: "Caro-Kann Defense"),

        // 1.e4 c6 2.d4 d5 — Caro-Kann: Main Line
        "rnbqkbnr/pp2pppp/2p5/3p4/3PP3/8/PPP2PPP/RNBQKBNR": Entry(
            eco: "B12", name: "Caro-Kann Defense: Main Line"),

        // === Pirc Defense (1.e4 d6) ===

        "rnbqkbnr/ppp1pppp/3p4/8/4P3/8/PPPP1PPP/RNBQKBNR": Entry(
            eco: "B07", name: "Pirc Defense"),

        // === Scandinavian (1.e4 d5) ===

        "rnbqkbnr/ppp1pppp/8/3p4/4P3/8/PPPP1PPP/RNBQKBNR": Entry(
            eco: "B01", name: "Scandinavian Defense"),

        // === Alekhine's Defense (1.e4 Nf6) ===

        "rnbqkb1r/pppppppp/5n2/8/4P3/8/PPPP1PPP/RNBQKBNR": Entry(
            eco: "B02", name: "Alekhine's Defense"),

        // === Queen's Pawn Openings (1.d4) ===

        // 1.d4 d5 — Queen's Pawn Game
        "rnbqkbnr/ppp1pppp/8/3p4/3P4/8/PPP1PPPP/RNBQKBNR": Entry(
            eco: "D00", name: "Queen's Pawn Game"),

        // 1.d4 d5 2.c4 — Queen's Gambit
        "rnbqkbnr/ppp1pppp/8/3p4/2PP4/8/PP2PPPP/RNBQKBNR": Entry(
            eco: "D06", name: "Queen's Gambit"),

        // 1.d4 d5 2.c4 e6 — Queen's Gambit Declined
        "rnbqkbnr/ppp2ppp/4p3/3p4/2PP4/8/PP2PPPP/RNBQKBNR": Entry(
            eco: "D30", name: "Queen's Gambit Declined"),

        // 1.d4 d5 2.c4 dxc4 — Queen's Gambit Accepted
        "rnbqkbnr/ppp1pppp/8/8/2pP4/8/PP2PPPP/RNBQKBNR": Entry(
            eco: "D20", name: "Queen's Gambit Accepted"),

        // 1.d4 d5 2.c4 c6 — Slav Defense
        "rnbqkbnr/pp2pppp/2p5/3p4/2PP4/8/PP2PPPP/RNBQKBNR": Entry(
            eco: "D10", name: "Slav Defense"),

        // === Indian Defenses (1.d4 Nf6) ===

        // 1.d4 Nf6
        "rnbqkb1r/pppppppp/5n2/8/3P4/8/PPP1PPPP/RNBQKBNR": Entry(
            eco: "A45", name: "Indian Defense"),

        // 1.d4 Nf6 2.c4 — Indian Game
        "rnbqkb1r/pppppppp/5n2/8/2PP4/8/PP2PPPP/RNBQKBNR": Entry(
            eco: "A50", name: "Indian Game"),

        // 1.d4 Nf6 2.c4 g6 — King's Indian setup
        "rnbqkb1r/pppppp1p/5np1/8/2PP4/8/PP2PPPP/RNBQKBNR": Entry(
            eco: "E60", name: "King's Indian Defense"),

        // 1.d4 Nf6 2.c4 e6 — Nimzo/Queen's Indian setup
        "rnbqkb1r/pppp1ppp/4pn2/8/2PP4/8/PP2PPPP/RNBQKBNR": Entry(
            eco: "E00", name: "Indian Game: East Indian"),

        // 1.d4 Nf6 2.c4 e6 3.Nc3 Bb4 — Nimzo-Indian
        "rnbqk2r/pppp1ppp/4pn2/8/1bPP4/2N5/PP2PPPP/R1BQKBNR": Entry(
            eco: "E20", name: "Nimzo-Indian Defense"),

        // 1.d4 Nf6 2.c4 e6 3.Nf3 b6 — Queen's Indian
        "rnbqkb1r/p1pp1ppp/1p2pn2/8/2PP4/5N2/PP2PPPP/RNBQKB1R": Entry(
            eco: "E15", name: "Queen's Indian Defense"),

        // 1.d4 Nf6 2.c4 g6 3.Nc3 Bg7 — King's Indian: Classical
        "rnbqk2r/ppppppbp/5np1/8/2PP4/2N5/PP2PPPP/R1BQKBNR": Entry(
            eco: "E70", name: "King's Indian Defense: Classical"),

        // 1.d4 Nf6 2.c4 g6 3.Nc3 d5 — Grünfeld Defense
        "rnbqkb1r/ppp1pp1p/5np1/3p4/2PP4/2N5/PP2PPPP/R1BQKBNR": Entry(
            eco: "D80", name: "Grünfeld Defense"),

        // === English Opening (1.c4) ===

        "rnbqkbnr/pppppppp/8/8/2P5/8/PP1PPPPP/RNBQKBNR": Entry(
            eco: "A10", name: "English Opening"),

        // 1.c4 e5 — English: Reversed Sicilian
        "rnbqkbnr/pppp1ppp/8/4p3/2P5/8/PP1PPPPP/RNBQKBNR": Entry(
            eco: "A20", name: "English Opening: Reversed Sicilian"),

        // === Réti Opening (1.Nf3) ===

        "rnbqkbnr/pppppppp/8/8/8/5N2/PPPPPPPP/RNBQKB1R": Entry(
            eco: "A04", name: "Réti Opening"),

        // 1.Nf3 d5 2.g3 — Réti: King's Indian Attack
        "rnbqkbnr/ppp1pppp/8/3p4/8/5NP1/PPPPPP1P/RNBQKB1R": Entry(
            eco: "A05", name: "Réti Opening: King's Indian Attack"),

        // === London System (1.d4 d5 2.Bf4) ===

        "rnbqkbnr/ppp1pppp/8/3p4/3P1B2/8/PPP1PPPP/RN1QKBNR": Entry(
            eco: "D00", name: "London System"),

        // === Dutch Defense (1.d4 f5) ===

        "rnbqkbnr/ppppp1pp/8/5p2/3P4/8/PPP1PPPP/RNBQKBNR": Entry(
            eco: "A80", name: "Dutch Defense"),

        // === Benoni (1.d4 Nf6 2.c4 c5) ===

        "rnbqkb1r/pp1ppppp/5n2/2p5/2PP4/8/PP2PPPP/RNBQKBNR": Entry(
            eco: "A56", name: "Benoni Defense"),

        // === Catalan (1.d4 Nf6 2.c4 e6 3.g3) ===

        "rnbqkb1r/pppp1ppp/4pn2/8/2PP4/6P1/PP2PP1P/RNBQKBNR": Entry(
            eco: "E01", name: "Catalan Opening"),

        // === Bird's Opening (1.f4) ===

        "rnbqkbnr/pppppppp/8/8/5P2/8/PPPPP1PP/RNBQKBNR": Entry(
            eco: "A02", name: "Bird's Opening"),

        // === Vienna Game (1.e4 e5 2.Nc3) ===

        "rnbqkbnr/pppp1ppp/8/4p3/4P3/2N5/PPPP1PPP/R1BQKBNR": Entry(
            eco: "C25", name: "Vienna Game"),
    ]
}

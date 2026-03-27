enum FENValidator {

    enum ValidationError: String, Sendable {
        case emptyString = "FEN string is empty"
        case tooLong = "FEN string exceeds maximum length"
        case wrongFieldCount = "FEN must have exactly 6 space-separated fields"
        case invalidPiecePlacement = "Invalid piece placement"
        case invalidRankLength = "Rank does not sum to 8"
        case invalidActiveColor = "Active color must be 'w' or 'b'"
        case invalidCastling = "Invalid castling availability"
        case invalidEnPassant = "Invalid en passant square"
        case invalidHalfmoveClock = "Halfmove clock must be a non-negative integer"
        case invalidFullmoveNumber = "Fullmove number must be a positive integer"
    }

    /// Returns nil if the FEN is structurally valid.
    /// Returns a ValidationError describing the first problem found otherwise.
    static func validate(_ fen: String) -> ValidationError? {
        let trimmed = String(fen.drop(while: { $0 == " " }).reversed().drop(while: { $0 == " " }).reversed())
        guard !trimmed.isEmpty else { return .emptyString }
        guard trimmed.utf8.count <= 256 else { return .tooLong }

        let fields = trimmed.split(separator: " ", omittingEmptySubsequences: false)
        guard fields.count == 6 else { return .wrongFieldCount }

        // Field 1: Piece placement — 8 ranks separated by /
        let ranks = fields[0].split(separator: "/", omittingEmptySubsequences: false)
        guard ranks.count == 8 else { return .invalidPiecePlacement }

        let validPieces: Set<Character> = [
            "p", "n", "b", "r", "q", "k",
            "P", "N", "B", "R", "Q", "K",
        ]

        for rank in ranks {
            var squareCount = 0
            for char in rank {
                if let digit = char.wholeNumberValue, digit >= 1, digit <= 8 {
                    squareCount += digit
                } else if validPieces.contains(char) {
                    squareCount += 1
                } else {
                    return .invalidPiecePlacement
                }
            }
            guard squareCount == 8 else { return .invalidRankLength }
        }

        // Field 2: Active color
        let color = fields[1]
        guard color == "w" || color == "b" else {
            return .invalidActiveColor
        }

        // Field 3: Castling availability
        let castling = String(fields[2])
        if castling != "-" {
            let validCastlingChars: Set<Character> = ["K", "Q", "k", "q"]
            guard !castling.isEmpty,
                  castling.count <= 4,
                  castling.allSatisfy({ validCastlingChars.contains($0) })
            else {
                return .invalidCastling
            }
            guard Set(castling).count == castling.count else {
                return .invalidCastling
            }
        }

        // Field 4: En passant target square
        let enPassant = String(fields[3])
        if enPassant != "-" {
            guard enPassant.count == 2 else { return .invalidEnPassant }
            let epChars = Array(enPassant)
            guard epChars[0] >= "a", epChars[0] <= "h" else {
                return .invalidEnPassant
            }
            guard epChars[1] == "3" || epChars[1] == "6" else {
                return .invalidEnPassant
            }
        }

        // Field 5: Halfmove clock (non-negative integer)
        guard let halfmove = Int(fields[4]), halfmove >= 0 else {
            return .invalidHalfmoveClock
        }

        // Field 6: Fullmove number (positive integer >= 1)
        guard let fullmove = Int(fields[5]), fullmove >= 1 else {
            return .invalidFullmoveNumber
        }

        return nil
    }
}

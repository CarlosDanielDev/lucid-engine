public enum FENDiff {

    /// Detects the move played between two consecutive FEN positions.
    /// Returns nil if no move can be determined.
    public static func detectMove(before: String, after: String) -> Move? {
        let beforeBoard = parseBoard(fen: before)
        let afterBoard = parseBoard(fen: after)

        guard beforeBoard.count == 64, afterBoard.count == 64 else { return nil }
        guard beforeBoard != afterBoard else { return nil }

        let activeColor = parseActiveColor(fen: before)

        // Find squares that changed
        var emptied: [(Int, Character)] = []  // squares that had a piece and now don't (or changed)
        var filled: [(Int, Character)] = []   // squares that gained a piece or changed piece

        for i in 0..<64 {
            let b = beforeBoard[i]
            let a = afterBoard[i]
            if b != a {
                if b != "." {
                    emptied.append((i, b))
                }
                if a != "." {
                    filled.append((i, a))
                }
            }
        }

        // Detect castling: king moves 2 squares
        if let castlingMove = detectCastling(
            emptied: emptied, filled: filled, activeColor: activeColor
        ) {
            return castlingMove
        }

        // Detect en passant: pawn captures but destination was empty
        if let epMove = detectEnPassant(
            before: beforeBoard, after: afterBoard,
            emptied: emptied, filled: filled, activeColor: activeColor
        ) {
            return epMove
        }

        // Normal move or capture: find the "from" square (emptied, owned by active color)
        // and the "to" square (filled, owned by active color)
        let ownedEmptied = emptied.filter { isOwnedBy($0.1, color: activeColor) }
        let ownedFilled = filled.filter { isOwnedBy($0.1, color: activeColor) }

        guard ownedEmptied.count == 1, ownedFilled.count == 1 else { return nil }

        let fromIndex = ownedEmptied[0].0
        let toIndex = ownedFilled[0].0
        let fromSquare = indexToSquare(fromIndex)
        let toSquare = indexToSquare(toIndex)

        // Detect promotion: pawn moved to 1st or 8th rank and became a different piece
        let fromPiece = ownedEmptied[0].1
        let toPiece = ownedFilled[0].1

        if fromPiece.lowercased() == "p" && fromPiece.lowercased() != toPiece.lowercased() {
            let promotion = String(toPiece).lowercased()
            return Move(from: fromSquare, to: toSquare, promotion: promotion)
        }

        return Move(from: fromSquare, to: toSquare)
    }

    // MARK: - Board Parsing

    /// Parses the piece placement field of a FEN into a 64-element array.
    /// Index 0 = a8, index 7 = h8, index 56 = a1, index 63 = h1.
    static func parseBoard(fen: String) -> [Character] {
        let fields = fen.split(separator: " ")
        guard let placement = fields.first else { return [] }

        var board: [Character] = []
        board.reserveCapacity(64)

        for char in placement {
            if char == "/" {
                continue
            } else if let digit = char.wholeNumberValue, digit >= 1, digit <= 8 {
                board.append(contentsOf: Array(repeating: Character("."), count: digit))
            } else {
                board.append(char)
            }
        }

        return board
    }

    static func parseActiveColor(fen: String) -> Character {
        let fields = fen.split(separator: " ")
        guard fields.count >= 2 else { return "w" }
        return fields[1].first ?? "w"
    }

    static func isOwnedBy(_ piece: Character, color: Character) -> Bool {
        if color == "w" {
            return piece.isUppercase
        } else {
            return piece.isLowercase
        }
    }

    static func indexToSquare(_ index: Int) -> String {
        let file = index % 8
        let rank = 7 - (index / 8)
        let fileChar = Character(UnicodeScalar(UInt8(Character("a").asciiValue! + UInt8(file))))
        return "\(fileChar)\(rank + 1)"
    }

    // MARK: - Special Moves

    static func detectCastling(
        emptied: [(Int, Character)],
        filled: [(Int, Character)],
        activeColor: Character
    ) -> Move? {
        // King must be among the emptied pieces
        let kingPiece: Character = activeColor == "w" ? "K" : "k"
        guard let kingEmptied = emptied.first(where: { $0.1 == kingPiece }) else { return nil }
        guard let kingFilled = filled.first(where: { $0.1 == kingPiece }) else { return nil }

        let fromFile = kingEmptied.0 % 8
        let toFile = kingFilled.0 % 8

        // King moves exactly 2 files = castling
        guard abs(toFile - fromFile) == 2 else { return nil }

        let fromSquare = indexToSquare(kingEmptied.0)
        let toSquare = indexToSquare(kingFilled.0)
        return Move(from: fromSquare, to: toSquare)
    }

    static func detectEnPassant(
        before: [Character],
        after: [Character],
        emptied: [(Int, Character)],
        filled: [(Int, Character)],
        activeColor: Character
    ) -> Move? {
        let pawnPiece: Character = activeColor == "w" ? "P" : "p"
        let ownedEmptied = emptied.filter { $0.1 == pawnPiece }
        let ownedFilled = filled.filter { $0.1 == pawnPiece }

        guard ownedEmptied.count == 1, ownedFilled.count == 1 else { return nil }

        let fromIndex = ownedEmptied[0].0
        let toIndex = ownedFilled[0].0

        let fromFile = fromIndex % 8
        let toFile = toIndex % 8

        // Pawn moved diagonally
        guard abs(fromFile - toFile) == 1 else { return nil }

        // The destination was empty in the before-board (en passant)
        guard before[toIndex] == "." else { return nil }

        return Move(from: indexToSquare(fromIndex), to: indexToSquare(toIndex))
    }
}

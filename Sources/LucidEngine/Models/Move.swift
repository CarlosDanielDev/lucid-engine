public struct Move: Sendable, Equatable {

    public let from: String
    public let to: String
    public let promotion: String?

    public var uci: String {
        from + to + (promotion ?? "")
    }

    public init(from: String, to: String, promotion: String? = nil) {
        self.from = from
        self.to = to
        self.promotion = promotion
    }

    public init?(uci: String) {
        let chars = Array(uci)

        guard chars.count == 4 || chars.count == 5 else { return nil }

        guard Self.isValidFile(chars[0]),
              Self.isValidRank(chars[1]),
              Self.isValidFile(chars[2]),
              Self.isValidRank(chars[3])
        else { return nil }

        self.from = String(chars[0...1])
        self.to = String(chars[2...3])

        if chars.count == 5 {
            guard Self.isValidPromotion(chars[4]) else { return nil }
            self.promotion = String(chars[4])
        } else {
            self.promotion = nil
        }
    }

    private static func isValidFile(_ c: Character) -> Bool {
        c >= "a" && c <= "h"
    }

    private static func isValidRank(_ c: Character) -> Bool {
        c >= "1" && c <= "8"
    }

    private static func isValidPromotion(_ c: Character) -> Bool {
        c == "q" || c == "r" || c == "b" || c == "n"
    }
}

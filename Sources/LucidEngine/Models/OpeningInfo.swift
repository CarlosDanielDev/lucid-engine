public struct OpeningInfo: Sendable, Equatable {
    public let eco: String
    public let name: String
    public let moves: Int

    public init(eco: String, name: String, moves: Int) {
        self.eco = eco
        self.name = name
        self.moves = moves
    }
}

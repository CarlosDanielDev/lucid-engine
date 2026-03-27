public struct GamePhases: Sendable, Equatable {
    public let opening: ClosedRange<Int>
    public let middlegame: ClosedRange<Int>
    public let endgame: ClosedRange<Int>

    public init(opening: ClosedRange<Int>, middlegame: ClosedRange<Int>, endgame: ClosedRange<Int>) {
        self.opening = opening
        self.middlegame = middlegame
        self.endgame = endgame
    }
}

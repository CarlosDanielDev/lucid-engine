public struct PositionAssessment: Sendable, Equatable {

    public let score: Score
    public let bestMove: Move
    public let principalVariation: [Move]
    public let depth: Int
    public let nodes: Int

    public init(
        score: Score,
        bestMove: Move,
        principalVariation: [Move],
        depth: Int,
        nodes: Int
    ) {
        self.score = score
        self.bestMove = bestMove
        self.principalVariation = principalVariation
        self.depth = depth
        self.nodes = nodes
    }
}

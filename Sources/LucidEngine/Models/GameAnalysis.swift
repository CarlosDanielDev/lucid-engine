public struct GameAnalysis: Sendable, Equatable {
    public let analyzedMoves: [AnalyzedMove]
    public let accuracy: Accuracy
    public let phases: GamePhases
    public let winProbabilities: [WinProbability]
    public let opening: OpeningInfo?

    public init(
        analyzedMoves: [AnalyzedMove],
        accuracy: Accuracy,
        phases: GamePhases,
        winProbabilities: [WinProbability] = [],
        opening: OpeningInfo? = nil
    ) {
        self.analyzedMoves = analyzedMoves
        self.accuracy = accuracy
        self.phases = phases
        self.winProbabilities = winProbabilities
        self.opening = opening
    }
}

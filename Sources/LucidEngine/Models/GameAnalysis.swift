public struct GameAnalysis: Sendable, Equatable {
    public let analyzedMoves: [AnalyzedMove]
    public let accuracy: Accuracy
    public let phases: GamePhases

    public init(
        analyzedMoves: [AnalyzedMove],
        accuracy: Accuracy,
        phases: GamePhases
    ) {
        self.analyzedMoves = analyzedMoves
        self.accuracy = accuracy
        self.phases = phases
    }
}

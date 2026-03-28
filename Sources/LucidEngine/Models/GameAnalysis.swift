public struct GameAnalysis: Sendable, Equatable {
    public let analyzedMoves: [AnalyzedMove]
    public let accuracy: Accuracy
    public let phases: GamePhases
    public let winProbabilities: [WinProbability]

    public init(
        analyzedMoves: [AnalyzedMove],
        accuracy: Accuracy,
        phases: GamePhases,
        winProbabilities: [WinProbability] = []
    ) {
        self.analyzedMoves = analyzedMoves
        self.accuracy = accuracy
        self.phases = phases
        self.winProbabilities = winProbabilities
    }
}

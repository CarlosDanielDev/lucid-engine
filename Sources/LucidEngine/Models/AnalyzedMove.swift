public struct AnalyzedMove: Sendable, Equatable {
    public let moveNumber: Int
    public let fen: String
    public let movePlayed: Move
    public let bestMove: Move
    public let assessment: PositionAssessment
    public let classification: MoveClassification
    public let centipawnLoss: Int

    public init(
        moveNumber: Int,
        fen: String,
        movePlayed: Move,
        bestMove: Move,
        assessment: PositionAssessment,
        classification: MoveClassification,
        centipawnLoss: Int
    ) {
        self.moveNumber = moveNumber
        self.fen = fen
        self.movePlayed = movePlayed
        self.bestMove = bestMove
        self.assessment = assessment
        self.classification = classification
        self.centipawnLoss = centipawnLoss
    }
}

internal import CStockfish

public actor LucidEngine {

    public let configuration: EngineConfiguration

    public private(set) var isRunning: Bool = false

    public init(configuration: EngineConfiguration = .default) {
        self.configuration = configuration
    }

    // MARK: - Lifecycle

    /// Start the engine. Calls `sf_init()` on the C side.
    /// Idempotent — calling on an already-running engine is a no-op.
    public func start() throws {
        guard !isRunning else { return }
        let status = sf_init()
        guard status == SF_OK || status == SF_ERR_ALREADY_INIT else {
            throw EngineError.initializationFailed
        }
        isRunning = true
    }

    /// Shut down the engine and release all C resources.
    /// Idempotent — calling on a stopped engine is a safe no-op.
    public func shutdown() {
        guard isRunning else { return }
        sf_cleanup()
        isRunning = false
    }

    /// Throws if the engine is not running. Call at the top of every operation method.
    func ensureRunning() throws {
        guard isRunning else {
            throw EngineError.engineNotRunning
        }
    }

    // MARK: - Position Assessment

    public func evaluate(fen: String, depth: Int = 18) async throws -> PositionAssessment {
        try ensureRunning()

        guard depth >= 1 && depth <= SF_MAX_DEPTH else {
            throw EngineError.invalidDepth(depth)
        }

        if FENValidator.validate(fen) != nil {
            throw EngineError.invalidFEN(fen)
        }

        return try await withThrowingTaskGroup(of: PositionAssessment?.self) { group in
            group.addTask { @Sendable in
                try Self.assessPosition(fen: fen, depth: depth)
            }

            group.addTask { @Sendable [configuration] in
                try await Task.sleep(for: .seconds(configuration.timeoutSeconds))
                return nil
            }

            for try await result in group {
                if let assessment = result {
                    group.cancelAll()
                    return assessment
                } else {
                    sf_stop_search()
                    group.cancelAll()
                    throw EngineError.evaluationTimeout
                }
            }

            throw EngineError.evaluationTimeout
        }
    }

    public func bestMove(fen: String, depth: Int = 18) async throws -> Move {
        let assessment = try await evaluate(fen: fen, depth: depth)
        return assessment.bestMove
    }

    // MARK: - Game Analysis

    public func analyzeGame(fens: [String], depth: Int = 18) async throws -> GameAnalysis {
        try ensureRunning()

        guard !fens.isEmpty else {
            throw EngineError.emptyFENArray
        }

        guard fens.count >= 2 else {
            throw EngineError.insufficientPositions
        }

        var analyzedMoves: [AnalyzedMove] = []

        for i in 0..<(fens.count - 1) {
            try Task.checkCancellation()

            let currentFEN = fens[i]
            let nextFEN = fens[i + 1]

            let assessment = try await evaluate(fen: currentFEN, depth: depth)

            guard let movePlayed = FENDiff.detectMove(before: currentFEN, after: nextFEN) else {
                continue
            }

            let bestScore = centipawnValue(of: assessment.score)

            // Evaluate the position after the move played to get its score
            let afterAssessment = try await evaluate(fen: nextFEN, depth: depth)
            let afterScore = centipawnValue(of: afterAssessment.score)

            // Centipawn loss: the score drop from the side-to-move's perspective
            // After the move, the score is from the opponent's perspective, so negate it
            let scoreAfterMove = -afterScore
            let cpLoss = max(0, bestScore - scoreAfterMove)

            // Move number: fullmove number from FEN
            let moveNumber = parseMoveNumber(fen: currentFEN)

            let classification = MoveClassifier.classify(
                centipawnLoss: cpLoss,
                scoreBefore: assessment.score,
                scoreAfter: afterAssessment.score
            )

            let analyzedMove = AnalyzedMove(
                moveNumber: moveNumber,
                fen: currentFEN,
                movePlayed: movePlayed,
                bestMove: assessment.bestMove,
                assessment: assessment,
                classification: classification,
                centipawnLoss: cpLoss
            )

            analyzedMoves.append(analyzedMove)
        }

        let accuracy = AccuracyCalculator.calculate(from: analyzedMoves)

        let winProbabilities = analyzedMoves.map {
            WinProbabilityCalculator.calculate(score: $0.assessment.score)
        }

        return GameAnalysis(
            analyzedMoves: analyzedMoves,
            accuracy: accuracy,
            phases: GamePhases(opening: 0...0, middlegame: 0...0, endgame: 0...0), // stub — LE-08
            winProbabilities: winProbabilities
        )
    }

    // MARK: - Helpers

    private func centipawnValue(of score: Score) -> Int {
        switch score {
        case .centipawns(let cp):
            return cp
        case .mate(let n):
            // Large value so mate is always better/worse than any cp score
            return n > 0 ? 10000 - n : -10000 - n
        }
    }

    private func parseMoveNumber(fen: String) -> Int {
        let fields = fen.split(separator: " ")
        guard fields.count >= 6, let n = Int(fields[5]) else { return 1 }
        return n
    }

    // MARK: - C Bridge

    private static func assessPosition(fen: String, depth: Int) throws -> PositionAssessment {
        var result = SFAssessResult()
        let status = fen.withCString { fenPtr in
            sf_assess_position(fenPtr, Int32(depth), &result)
        }

        switch status {
        case SF_OK:
            break
        case SF_ERR_INVALID_FEN:
            throw EngineError.invalidFEN(fen)
        case SF_ERR_INVALID_DEPTH:
            throw EngineError.invalidDepth(depth)
        case SF_ERR_NOT_INITIALIZED:
            throw EngineError.engineNotRunning
        default:
            throw EngineError.analysisInterrupted
        }

        let score: Score = switch result.score_type {
        case SF_SCORE_MATE:
            .mate(Int(result.score))
        default:
            .centipawns(Int(result.score))
        }

        let bestMoveStr = withUnsafePointer(to: result.best_move) { ptr in
            ptr.withMemoryRebound(to: CChar.self, capacity: Int(SF_MOVE_BUF_SIZE)) { buf in
                String(cString: buf)
            }
        }
        guard let bestMove = Move(uci: bestMoveStr) else {
            throw EngineError.analysisInterrupted
        }

        var principalVariation: [Move] = []
        let pvLength = min(Int(result.pv_length), Int(SF_MAX_PV_LENGTH))
        if pvLength > 0 {
            withUnsafePointer(to: result.pv) { pvPtr in
                let rawBase = UnsafeRawPointer(pvPtr)
                for i in 0..<pvLength {
                    let offset = i * Int(SF_MOVE_BUF_SIZE)
                    let cStr = rawBase.advanced(by: offset)
                        .assumingMemoryBound(to: CChar.self)
                    let moveStr = String(cString: cStr)
                    if let move = Move(uci: moveStr) {
                        principalVariation.append(move)
                    }
                }
            }
        }

        return PositionAssessment(
            score: score,
            bestMove: bestMove,
            principalVariation: principalVariation,
            depth: Int(result.depth),
            nodes: Int(result.nodes)
        )
    }
}

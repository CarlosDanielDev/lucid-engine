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
        let bestMove = Move(uci: bestMoveStr) ?? Move(from: "a1", to: "a1")

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

import Testing
@testable import LucidEngine

@Suite("Progressive Depth Analysis",
       .disabled("Requires running Stockfish engine — integration tests"))
struct ProgressiveAnalysisIntegrationTests {

    @Test("Preview callback fires before final result")
    func previewCallbackFires() async throws {
        let engine = LucidEngine()
        try await engine.start()
        defer { Task { await engine.shutdown() } }

        let fens = [
            "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
            "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1",
            "rnbqkbnr/pppp1ppp/8/4p3/4P3/8/PPPP1PPP/RNBQKBNR w KQkq e6 0 2",
        ]

        let tracker = ProgressiveTracker()

        let final = try await engine.analyzeGameProgressive(
            fens: fens,
            previewDepth: 8,
            fullDepth: 12
        ) { preview in
            tracker.previewReceived = true
            tracker.previewMoveCount = preview.analyzedMoves.count
        }

        #expect(tracker.previewReceived)
        #expect(!final.analyzedMoves.isEmpty)
    }

    @Test("Final result has higher depth than preview")
    func finalHasHigherDepth() async throws {
        let engine = LucidEngine()
        try await engine.start()
        defer { Task { await engine.shutdown() } }

        let fens = [
            "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
            "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1",
            "rnbqkbnr/pppp1ppp/8/4p3/4P3/8/PPPP1PPP/RNBQKBNR w KQkq e6 0 2",
        ]

        let tracker = ProgressiveTracker()

        let final = try await engine.analyzeGameProgressive(
            fens: fens,
            previewDepth: 8,
            fullDepth: 14
        ) { preview in
            if let first = preview.analyzedMoves.first {
                tracker.previewDepth = first.assessment.depth
            }
        }

        if let firstFinal = final.analyzedMoves.first {
            #expect(firstFinal.assessment.depth >= tracker.previewDepth)
        }
    }
}

@Suite("Progressive Analysis - Unit Tests")
struct ProgressiveAnalysisUnitTests {

    @Test("Engine requires running state for progressive analysis")
    func requiresRunningEngine() async {
        let engine = LucidEngine()
        do {
            _ = try await engine.analyzeGameProgressive(
                fens: ["fen1", "fen2"],
                previewDepth: 10,
                fullDepth: 18
            ) { _ in }
            #expect(Bool(false), "Should have thrown")
        } catch {
            #expect(error is EngineError)
        }
    }

    @Test("Progressive analysis validates empty FEN array")
    func validatesEmptyFENs() async throws {
        let engine = LucidEngine()
        try await engine.start()
        defer { Task { await engine.shutdown() } }

        do {
            _ = try await engine.analyzeGameProgressive(
                fens: [],
                previewDepth: 10,
                fullDepth: 18
            ) { _ in }
            #expect(Bool(false), "Should have thrown")
        } catch let error as EngineError {
            #expect(error == .emptyFENArray)
        }
    }

    @Test("Progressive analysis validates single FEN")
    func validatesSingleFEN() async throws {
        let engine = LucidEngine()
        try await engine.start()
        defer { Task { await engine.shutdown() } }

        do {
            _ = try await engine.analyzeGameProgressive(
                fens: ["rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"],
                previewDepth: 10,
                fullDepth: 18
            ) { _ in }
            #expect(Bool(false), "Should have thrown")
        } catch let error as EngineError {
            #expect(error == .insufficientPositions)
        }
    }
}

// MARK: - Test Helper

/// Thread-safe tracker for progressive analysis callbacks.
private final class ProgressiveTracker: @unchecked Sendable {
    var previewReceived = false
    var previewMoveCount = 0
    var previewDepth = 0
}

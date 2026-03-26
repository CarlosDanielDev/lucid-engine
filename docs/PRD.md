# LucidEngine -- Product Requirements Document

## Vision

LucidEngine exists because the previous approach to Stockfish integration in iOS -- ChessKitEngine -- crashed SwiftUI by using `dup2()` to redirect stdout. This hijacked the process's standard output, breaking SwiftUI's internal logging and causing fatal crashes on device.

Meanwhile, lucidmate's built-in `BotEngine` (~1800 ELO) uses minimax with alpha-beta pruning. It's sufficient for bot games but far too weak for post-game analysis, where players need Stockfish-level evaluation (~3500 ELO) to understand their mistakes and improve.

LucidEngine bridges this gap: a Swift Package that wraps Stockfish via pipe-based I/O and C library interop, delivering grandmaster-level analysis without touching stdout.

## Goals

1. **Safe Stockfish integration** -- evaluate chess positions without crashing SwiftUI
2. **Post-game analysis** -- analyze complete games, classify every move, calculate accuracy
3. **Clean public API** -- async/await actor-based interface that any Swift app can consume
4. **Independent package** -- separately testable, versionable, and distributable via SPM

## Non-Goals

- **No UI** -- LucidEngine provides data; the consumer app handles presentation
- **No game logic** -- no move validation, no rules enforcement, no board representation
- **No networking** -- no fetching games, no server communication
- **No bot play** -- lucidmate's `BotEngine` handles that; LucidEngine is for analysis only
- **No persistent storage** -- no caching of evaluations or game history

---

## Feature Inventory

| ID | Feature | Priority | Phase |
|----|---------|----------|-------|
| LE-01 | Core engine initialization and lifecycle | P0 | 0 - Foundation |
| LE-02 | Single position assessment (FEN in, centipawn score out) | P0 | 0 - Foundation |
| LE-03 | Best move calculation with principal variation | P0 | 1 - Core Analysis |
| LE-04 | Game analysis pipeline (array of FENs in, analyzed moves out) | P1 | 1 - Core Analysis |
| LE-05 | Move classification (brilliant/great/good/inaccuracy/mistake/blunder) | P1 | 1 - Core Analysis |
| LE-06 | Accuracy calculation per player | P1 | 1 - Core Analysis |
| LE-07 | Win probability curve generation | P1 | 2 - Advanced |
| LE-08 | Game phase detection (opening/middlegame/endgame) | P2 | 2 - Advanced |
| LE-09 | Progressive depth analysis (quick preview + deep analysis) | P2 | 2 - Advanced |
| LE-10 | Opening book / theory detection | P3 | 3 - AI-Powered |
| LE-11 | Natural language move explanations via AI | P3 | 3 - AI-Powered (future premium) |

## Dependency Graph

```
LE-01 (Engine lifecycle)
 ├── LE-02 (Position assessment)
 │    ├── LE-03 (Best move + PV)
 │    │    ├── LE-04 (Game analysis pipeline)
 │    │    │    ├── LE-05 (Move classification)
 │    │    │    ├── LE-06 (Accuracy calculation)
 │    │    │    ├── LE-07 (Win probability curve)
 │    │    │    └── LE-08 (Game phase detection)
 │    │    └── LE-09 (Progressive depth)
 │    └── LE-10 (Opening book detection)
 └── LE-11 (AI explanations -- depends on LE-05)
```

## Development Phases

### Phase 0: Foundation
**Goal:** Stockfish compiles and responds to a single evaluation request.

- LE-01: Engine initialization, start, stop lifecycle
- LE-02: Single position assessment
- Package.swift with CStockfish + LucidEngine targets
- C bridging header (`stockfish_bridge.h`)
- Core models: Score, Move, PositionAssessment, EngineError

### Phase 1: Core Analysis
**Goal:** Analyze a complete game and classify every move.

- LE-03: Best move with principal variation
- LE-04: Game analysis pipeline
- LE-05: Move classification
- LE-06: Accuracy calculation

### Phase 2: Advanced
**Goal:** Rich analysis data for premium UX.

- LE-07: Win probability curve
- LE-08: Game phase detection
- LE-09: Progressive depth analysis

### Phase 3: AI-Powered
**Goal:** Human-readable insights (future premium feature).

- LE-10: Opening book / theory detection
- LE-11: Natural language move explanations

---

## Public API Surface

```swift
// MARK: - Core Engine

/// Thread-safe Stockfish wrapper. All engine access serialized via actor.
public actor LucidEngine {
    /// Initialize with optional configuration
    public init(configuration: EngineConfiguration = .default)

    /// Evaluate a single position
    public func evaluate(fen: String, depth: Int = 18) async throws -> Evaluation

    /// Get the best move for a position
    public func bestMove(fen: String, depth: Int = 18) async throws -> Move

    /// Analyze a complete game from an array of FEN positions
    public func analyzeGame(fens: [String], depth: Int = 18) async throws -> GameAnalysis

    /// Shutdown the engine and free resources
    public func shutdown()
}

// MARK: - Configuration

public struct EngineConfiguration: Sendable {
    public static let `default`: EngineConfiguration
    public let threads: Int          // default: 1
    public let hashSizeMB: Int       // default: 16
    public let depth: Int            // default: 18
}

// MARK: - Evaluation Result

public struct Evaluation: Sendable {
    public let score: Score
    public let bestMove: Move
    public let principalVariation: [Move]
    public let depth: Int
    public let nodes: Int
}

// MARK: - Score

public enum Score: Sendable {
    case centipawns(Int)             // e.g., +150 = 1.5 pawn advantage for white
    case mate(Int)                   // positive = white mates in N, negative = black mates in N
}

// MARK: - Move

public struct Move: Sendable {
    public let from: String          // e.g., "e2"
    public let to: String            // e.g., "e4"
    public let promotion: String?    // e.g., "q" for queen
    public let uci: String           // e.g., "e2e4"
}

// MARK: - Game Analysis

public struct GameAnalysis: Sendable {
    public let analyzedMoves: [AnalyzedMove]
    public let accuracy: Accuracy
    public let phases: GamePhases
}

public struct AnalyzedMove: Sendable {
    public let moveNumber: Int
    public let fen: String
    public let movePlayed: Move
    public let bestMove: Move
    public let evaluation: Evaluation
    public let classification: MoveClassification
    public let centipawnLoss: Int
}

public enum MoveClassification: Sendable, Comparable {
    case brilliant     // unexpected sacrifice that improves position
    case great         // only winning move in a critical position
    case good          // matches or near-matches best move (CPL <= 10)
    case book          // known opening theory
    case inaccuracy    // CPL 30-80
    case mistake       // CPL 80-200
    case blunder       // CPL > 200 or misses mate
}

public struct Accuracy: Sendable {
    public let white: Double         // 0.0 - 100.0
    public let black: Double         // 0.0 - 100.0
}

public struct GamePhases: Sendable {
    public let opening: ClosedRange<Int>     // move range
    public let middlegame: ClosedRange<Int>
    public let endgame: ClosedRange<Int>?    // nil if game ended in middlegame
}

// MARK: - Win Probability

public struct WinProbability: Sendable {
    public let white: Double         // 0.0 - 1.0
    public let draw: Double          // 0.0 - 1.0
    public let black: Double         // 0.0 - 1.0
}

// MARK: - Errors

public enum EngineError: Error, Sendable {
    case initializationFailed(String)
    case invalidFEN(String)
    case evaluationTimeout
    case engineNotRunning
    case analysisInterrupted
}
```

---

## Performance Targets

| Metric | Target | Notes |
|--------|--------|-------|
| Single position evaluation | < 500ms | At depth 18, iPhone 14+ |
| Full game analysis (40 moves) | < 15s | At depth 18 |
| Memory usage | < 100MB | Including Stockfish hash tables |
| Binary size increase | < 5MB | Stockfish compiled for arm64 |
| Cold start (engine init) | < 200ms | First evaluation ready |

## Platform Support

| Platform | Minimum Version |
|----------|----------------|
| iOS | 17.0+ |
| macOS | 14.0+ |
| Swift | 6.2+ |

---

## Consumer Integration

### Primary Consumer: lucidmate

LucidEngine will be consumed by lucidmate as a local SPM dependency for post-game analysis (issue #129). The integration flow:

1. Game ends -> lucidmate receives FEN history via `GameViewModel.moveHistory`
2. User taps "Analyze Game" -> lucidmate converts move history to FEN array
3. FEN array passed to `LucidEngine.analyzeGame(fens:depth:)`
4. `GameAnalysis` returned -> lucidmate renders move classifications, accuracy, win probability chart
5. User navigates moves -> individual `AnalyzedMove` data drives board + evaluation bar

### Future Consumers

Any Swift app needing chess position evaluation can add LucidEngine as an SPM dependency. The API is consumer-agnostic by design.

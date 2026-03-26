# LucidEngine - First Session Prompt

Copy everything below and paste it as your first message in a new Claude Code session at `/Users/carlos/projects/lucid-engine`.

---

## Context

I'm building **LucidEngine**, a Swift Package (SPM) that wraps the Stockfish chess engine for use in my iOS app **lucidmate**. This package exists because the previous approach (ChessKitEngine) crashed SwiftUI due to `dup2()` stdout redirect. LucidEngine solves this with pipe-based I/O or C library approach -- no stdout hijacking.

**Repo:** https://github.com/CarlosDanielDev/lucid-engine
**Consumer app:** lucidmate (https://github.com/CarlosDanielDev/lucid-mate-mobile-swift)
**Consumer app path:** `/Users/carlos/projects/lucidmate`

## What lucidmate already has (for context)

- A pure-Swift `BotEngine` (~1800 ELO) using minimax + alpha-beta pruning -- good for bot games but too weak for post-game analysis
- `FENParser`, `MoveEngine`, `MoveObject`, `BoardPosition`, `ChessPiece` models
- `PostGameSummary` with final FEN, move count, rating delta, clocks
- `GameViewModel` tracking `moveHistory: [MoveObject]` and FEN per move
- Socket.IO `game:end` event delivers `finalState.fen` and `finalState.pgn`
- Existing issue #129: "feat: post-game review -- fetch completed games and analyze with board controls"
- Issues #124-126: FEN history accumulator, move navigation, tap-to-jump (prerequisites for analysis)

## What I need you to do NOW

Use **Training Mode** (you'll only create files in `.claude/` and `docs/`). Do the following in order:

### 1. Create the PRD (`docs/PRD.md`)

Write a Product Requirements Document covering:

- **Vision**: Why LucidEngine exists (the dup2 crash story, the gap between BotEngine's 1800 ELO and Stockfish's 3500+)
- **Goals**: What this package delivers to lucidmate and potentially other consumers
- **Non-goals**: What this package does NOT do (no UI, no game logic, no networking)
- **Feature inventory** with IDs and priorities:
  - `LE-01`: Core engine initialization and lifecycle (P0)
  - `LE-02`: Single position assessment -- FEN in, centipawn score out (P0)
  - `LE-03`: Best move calculation with principal variation (P0)
  - `LE-04`: Game analysis pipeline -- array of FENs in, analyzed moves out (P1)
  - `LE-05`: Move classification (brilliant/great/good/inaccuracy/mistake/blunder) (P1)
  - `LE-06`: Accuracy calculation per player (P1)
  - `LE-07`: Win probability curve generation (P1)
  - `LE-08`: Game phase detection (opening/middlegame/endgame) (P2)
  - `LE-09`: Progressive depth analysis (quick preview + deep analysis) (P2)
  - `LE-10`: Opening book / theory detection (P3)
  - `LE-11`: Natural language move explanations via AI (P3, future premium)
- **Dependency graph** between features
- **Development phases** (Phase 0: Foundation, Phase 1: Core Analysis, Phase 2: Advanced, Phase 3: AI-Powered)
- **Public API surface** -- the exact Swift types and methods consumers will use
- **Performance targets** (single position < 500ms at depth 18, full game < 15s, memory < 100MB)
- **Platform support**: iOS 17+, macOS 14+

### 2. Create the Architecture Blueprint (`docs/ARCHITECTURE.md`)

Document the technical architecture:

- **Package structure** -- SPM targets (CStockfish C target + LucidEngine Swift target)
- **C/C++ integration strategy** -- why C library approach over subprocess, how bridging works
- **The dup2 problem** -- detailed explanation of what crashed and why our approach fixes it
- **Actor-based concurrency model** -- how LucidEngine actor serializes engine access
- **Assessment pipeline** -- stage-by-stage flow from FEN array to GameAnalysis
- **Move classification algorithm** -- centipawn loss thresholds, brilliant move detection
- **Memory management** -- how C allocations are paired with Swift cleanup
- **Threading model** -- background execution, cooperative cancellation, timeout handling
- **Consumer integration guide** -- how lucidmate will add this as a local SPM dependency
- **ADR-001**: Why we chose C library over subprocess approach
- **ADR-002**: Why actor-based API over callback-based

### 3. Create the README (`README.md`)

A proper open-source README:

- Project name, one-liner description, badges placeholder
- **Why LucidEngine?** -- the problem it solves (3 sentences max)
- **Features** -- bullet list of what it provides
- **Installation** -- SPM dependency instructions
- **Quick Start** -- minimal code example showing position assessment and game analysis
- **API Reference** -- summary table of public types and methods
- **Requirements** -- Swift 6.2+, iOS 17+, macOS 14+
- **Architecture** -- link to `docs/ARCHITECTURE.md`
- **Contributing** -- basic guide
- **License** -- MIT
- **Credits** -- Stockfish team, lucidmate project

### 4. Create the directory-tree.md

The planned project structure (what it WILL look like, not just current state):

```
lucid-engine/
├── .claude/           # Agent configuration (already set up)
├── docs/
│   ├── PRD.md
│   └── ARCHITECTURE.md
├── Sources/
│   ├── CStockfish/
│   │   ├── include/
│   │   │   └── stockfish_bridge.h
│   │   └── src/
│   │       └── (stockfish C++ source files)
│   └── LucidEngine/
│       ├── Engine/
│       │   ├── LucidEngine.swift
│       │   └── EngineError.swift
│       ├── Models/
│       │   ├── Score.swift
│       │   ├── Move.swift
│       │   ├── PositionAssessment.swift
│       │   ├── MoveClassification.swift
│       │   ├── GameAnalysis.swift
│       │   └── AnalyzedMove.swift
│       └── Analysis/
│           ├── GameAnalyzer.swift
│           ├── AccuracyCalculator.swift
│           ├── WinProbability.swift
│           └── PhaseDetector.swift
├── Tests/
│   └── LucidEngineTests/
│       ├── EngineLifecycleTests.swift
│       ├── PositionAssessmentTests.swift
│       ├── MoveClassificationTests.swift
│       ├── GameAnalysisTests.swift
│       └── PerformanceBenchmarkTests.swift
├── Package.swift
├── README.md
├── directory-tree.md
├── LICENSE
└── .gitignore
```

### 5. Create GitHub issues for Phase 0

After creating the docs, create GitHub issues for the Phase 0 foundation work:
- Issue: `feat: Package.swift with CStockfish and LucidEngine targets`
- Issue: `feat: Stockfish C bridging header (stockfish_bridge.h)`
- Issue: `feat: LucidEngine actor with init/start/stop lifecycle`
- Issue: `feat: Core models -- Score, Move, PositionAssessment, EngineError`
- Issue: `feat: Single position assessment (LE-02)`

Link them in dependency order and cross-reference with lucidmate issue #129.

---

## Preferences

- Language: English
- Mode: Start with Vibe Coding for the documentation phase (no code yet, just docs and issues)
- TDD will kick in once we start Phase 0 implementation

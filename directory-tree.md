# LucidEngine -- Directory Tree

Project structure showing implemented files and planned future files.

Legend:
- No marker = implemented and present on disk
- `[planned]` = not yet created, part of a future issue

```
lucid-engine/
├── .claude/                          # Agent configuration
│   ├── agents/                       # Subagent definitions
│   │   ├── subagent-docs-analyst.md
│   │   ├── subagent-engine-architect.md
│   │   ├── subagent-master-planner.md
│   │   ├── subagent-qa-engine.md
│   │   └── subagent-security-analyst.md
│   ├── commands/                     # Custom commands
│   │   ├── brainstorm.md
│   │   ├── implement.md
│   │   ├── plan-feature.md
│   │   └── pushup.md
│   ├── skills/                       # Custom skills
│   │   └── engine-patterns/
│   │       ├── assessment.md
│   │       ├── c-interop.md
│   │       └── SKILL.md
│   ├── CLAUDE.md                     # Project instructions
│   └── NEXT-SESSION.md              # Session bootstrap prompt
├── docs/
│   ├── PRD.md                        # Product Requirements Document
│   └── ARCHITECTURE.md              # Technical architecture blueprint
├── Sources/
│   ├── CStockfish/                   # C/C++ Stockfish target (Issue #1)
│   │   ├── include/
│   │   │   └── stockfish_bridge.h   # Public C header -- SFStatus, SFScoreType, SFAssessResult (Issue #2)
│   │   └── src/
│   │       ├── stockfish_bridge.c   # Thread-safe stub with full input validation (Issue #2)
│   │       └── (stockfish sources)  # [planned] Stockfish C++ source files
│   └── LucidEngine/                  # Swift public API target
│       ├── Engine/
│       │   ├── LucidEngine.swift     # Actor -- configuration, isRunning, start/shutdown/ensureRunning (Issue #3)
│       │   └── EngineError.swift     # EngineError: initializationFailed, engineNotRunning, invalidDepth, invalidFEN -- Equatable (Issue #3)
│       ├── Models/
│       │   ├── EngineConfiguration.swift  # defaultDepth/threadCount/hashSizeMB with preconditions (Issue #3)
│       │   ├── Score.swift           # [planned] Centipawns / mate-in-N
│       │   ├── Move.swift            # [planned] From/to/promotion/UCI
│       │   ├── Evaluation.swift      # [planned] Single position result
│       │   ├── PositionAssessment.swift  # [planned] Alias / convenience
│       │   ├── MoveClassification.swift  # [planned] brilliant → blunder enum
│       │   ├── AnalyzedMove.swift    # [planned] Per-move analysis result
│       │   ├── GameAnalysis.swift    # [planned] Full game result
│       │   ├── Accuracy.swift        # [planned] White/black accuracy
│       │   ├── WinProbability.swift  # [planned] Win/draw/loss percentages
│       │   └── GamePhases.swift      # [planned] Opening/middlegame/endgame ranges
│       └── Analysis/                 # [planned]
│           ├── GameAnalyzer.swift    # [planned] Pipeline: FENs → GameAnalysis
│           ├── AccuracyCalculator.swift  # [planned] CPL → accuracy percentage
│           ├── MoveClassifier.swift  # [planned] CPL thresholds → classification
│           ├── WinProbabilityCalculator.swift  # [planned] Centipawns → win%
│           └── PhaseDetector.swift   # [planned] Piece count → game phase
├── Tests/
│   └── LucidEngineTests/
│       ├── PackageStructureTests.swift          # SPM scaffold verification -- updated for isRunning, .serialized (Issue #3)
│       ├── BridgingHeaderTests.swift            # 25 tests: constants, enums, lifecycle, preconditions (Issue #2)
│       ├── LucidEngineLifecycleTests.swift      # 16 lifecycle tests: config, start, shutdown, restart, ensureRunning (Issue #3)
│       ├── PositionAssessmentTests.swift        # [planned] Known positions, edge cases
│       ├── MoveClassificationTests.swift        # [planned] CPL → classification mapping
│       ├── GameAnalysisTests.swift              # [planned] Full pipeline tests
│       └── PerformanceBenchmarkTests.swift      # [planned] Timing & memory benchmarks
├── Package.swift                     # SPM manifest -- CStockfish added to test target deps (Issue #2)
├── README.md                         # Project overview & quick start
├── directory-tree.md                 # This file
├── .swift-version                    # Swift 6.2.4 toolchain pin
├── LICENSE                           # [planned] MIT
└── .gitignore                        # Build artifacts, .DS_Store, etc.
```

## Issue Status

| Issue | Description | Status |
|-------|-------------|--------|
| #1 | SPM package scaffold -- CStockfish + LucidEngine targets, bridge header, actor skeleton | Done |
| #2 | Stockfish C bridging header -- SFStatus, SFScoreType, SFAssessResult, stub impl, 25 tests | Done |
| #3 | LucidEngine actor with init/start/stop lifecycle -- EngineConfiguration, isRunning, ensureRunning(), 16 tests | Done |
| #4 | Evaluation models and score parsing | Planned |
| #5 | Game analysis pipeline and move classification | Planned |

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
│   │   │   └── stockfish_bridge.h   # Public C header -- SFStatus, SFScoreType, SFAssessResult, sf_stop_search() (Issues #2, #11)
│   │   └── src/
│   │       ├── stockfish_bridge.cpp  # Real C++ implementation wiring sf_assess_position to Stockfish 17.1 (Issue #11)
│   │       └── stockfish/            # Stockfish 17.1 C++ source (Issue #11)
│   │           ├── benchmark.cpp / .h
│   │           ├── bitboard.cpp / .h
│   │           ├── engine.cpp / .h
│   │           ├── evaluate.cpp / .h
│   │           ├── history.h
│   │           ├── memory.cpp / .h
│   │           ├── misc.cpp / .h
│   │           ├── movegen.cpp / .h
│   │           ├── movepick.cpp / .h
│   │           ├── nn-1c0000000000.nnue   # NNUE weight file (excluded from SPM build, loaded at runtime)
│   │           ├── nn-37f18f62d772.nnue   # NNUE weight file (excluded from SPM build, loaded at runtime)
│   │           ├── numa.h
│   │           ├── perft.h
│   │           ├── position.cpp / .h
│   │           ├── score.cpp / .h
│   │           ├── search.cpp / .h
│   │           ├── thread.cpp / .h
│   │           ├── thread_win32_osx.h
│   │           ├── timeman.cpp / .h
│   │           ├── tt.cpp / .h
│   │           ├── tune.cpp / .h
│   │           ├── types.h
│   │           ├── uci.cpp / .h
│   │           ├── ucioption.cpp / .h
│   │           ├── incbin/
│   │           │   ├── incbin.h
│   │           │   └── UNLICENCE         # Excluded from SPM build
│   │           ├── nnue/
│   │           │   ├── features/
│   │           │   │   ├── half_ka_v2_hm.cpp
│   │           │   │   └── half_ka_v2_hm.h
│   │           │   ├── layers/
│   │           │   │   ├── affine_transform.h
│   │           │   │   ├── affine_transform_sparse_input.h
│   │           │   │   ├── clipped_relu.h
│   │           │   │   ├── simd.h
│   │           │   │   └── sqr_clipped_relu.h
│   │           │   ├── network.cpp / .h
│   │           │   ├── nnue_accumulator.cpp / .h
│   │           │   ├── nnue_architecture.h
│   │           │   ├── nnue_common.h
│   │           │   ├── nnue_feature_transformer.h
│   │           │   └── nnue_misc.cpp / .h
│   │           └── syzygy/
│   │               ├── tbprobe.cpp
│   │               └── tbprobe.h
│   └── LucidEngine/                  # Swift public API target
│       ├── Engine/
│       │   ├── LucidEngine.swift     # Actor -- evaluate(fen:depth:)/bestMove(fen:depth:) with FEN+depth validation, timeout via TaskGroup, C bridge mapping (Issues #3, #5)
│       │   └── EngineError.swift     # EngineError: initializationFailed, engineNotRunning, invalidDepth, invalidFEN(String), invalidConfiguration(String), evaluationTimeout, analysisInterrupted -- Equatable, Sendable (Issues #3, #4)
│       ├── Models/
│       │   ├── EngineConfiguration.swift  # defaultDepth/threadCount/hashSizeMB/timeoutSeconds(Double, default 5.0) with preconditions (Issues #3, #5)
│       │   ├── Score.swift           # Score enum: .centipawns(Int) / .mate(Int) -- Sendable, Equatable (Issue #4)
│       │   ├── Move.swift            # Move struct: from/to/promotion, UCI init and computed property -- Sendable, Equatable (Issue #4)
│       │   ├── PositionAssessment.swift  # PositionAssessment struct: score/bestMove/principalVariation/depth/nodes -- Sendable, Equatable (Issue #4)
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
│       └── Validation/
│           └── FENValidator.swift    # FEN string validation logic
├── Tests/
│   └── LucidEngineTests/
│       ├── PackageStructureTests.swift          # SPM scaffold verification -- updated for isRunning, .serialized (Issue #3)
│       ├── BridgingHeaderTests.swift            # 25 tests: constants, enums, lifecycle, preconditions (Issue #2)
│       ├── LucidEngineLifecycleTests.swift      # 17 lifecycle tests: config, start, shutdown, restart, ensureRunning (Issue #3)
│       ├── CoreModelsTests.swift                # 55 tests across 7 suites: Score, Move, PositionAssessment, EngineError updated cases (Issue #4)
│       ├── PositionAssessmentTests.swift        # 37 tests across 10 suites: FEN validation, depth validation, default params, score mapping, integration (real Stockfish), mate detection, bestMove, timeout, actor isolation (Issues #5, #11)
│       ├── MoveClassificationTests.swift        # [planned] CPL → classification mapping
│       ├── GameAnalysisTests.swift              # [planned] Full pipeline tests
│       └── PerformanceBenchmarkTests.swift      # [planned] Timing & memory benchmarks
├── Package.swift                     # SPM manifest -- CStockfish C++17 target, cxxSettings, NNUE exclusions (Issues #1, #11)
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
| #4 | Core models: Score, Move, PositionAssessment, EngineError extended cases -- 55 tests across 7 suites | Done |
| #5 | Single position assessment -- evaluate(fen:depth:), bestMove(fen:depth:), FEN/depth validation, timeout, C bridge mapping, 10 test suites | Done |
| #11 | Wire real Stockfish 17.1 into sf_assess_position -- stockfish_bridge.cpp, C++17 settings, NNUE exclusions, all 11 integration tests enabled -- 135 tests total across 18 suites | Done |
| #6 | Game analysis pipeline and move classification | Planned |

## Package.swift Key Settings (Issue #11)

- `cxxLanguageStandard: .cxx17` -- required for Stockfish 17.1
- `cxxSettings` on CStockfish target: header search paths for stockfish/, nnue/, syzygy/, incbin/; defines NDEBUG, USE_PTHREADS, IS_64BIT, USE_POPCNT, USE_NEON (iOS/macOS)
- `exclude` on CStockfish target: NNUE weight files (.nnue) and incbin/UNLICENCE (non-source assets)
- `linkerSettings`: links pthread

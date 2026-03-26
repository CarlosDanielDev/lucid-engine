# LucidEngine -- Directory Tree

Planned project structure (current + upcoming files).

```
lucid-engine/
├── .claude/                          # Agent configuration
│   ├── agents/                       # Subagent definitions
│   ├── commands/                     # Custom commands
│   ├── skills/                       # Custom skills
│   ├── CLAUDE.md                     # Project instructions
│   └── NEXT-SESSION.md              # Session bootstrap prompt
├── docs/
│   ├── PRD.md                        # Product Requirements Document
│   └── ARCHITECTURE.md              # Technical architecture blueprint
├── Sources/
│   ├── CStockfish/                   # C/C++ Stockfish target
│   │   ├── include/
│   │   │   └── stockfish_bridge.h   # Public C header for Swift interop
│   │   └── src/
│   │       ├── stockfish_bridge.cpp  # C wrapper around Stockfish internals
│   │       └── (stockfish sources)   # Stockfish C++ source files
│   └── LucidEngine/                  # Swift public API target
│       ├── Engine/
│       │   ├── LucidEngine.swift     # Main actor -- evaluate, bestMove, analyzeGame
│       │   └── EngineError.swift     # Error types
│       ├── Models/
│       │   ├── Score.swift           # Centipawns / mate-in-N
│       │   ├── Move.swift            # From/to/promotion/UCI
│       │   ├── Evaluation.swift      # Single position result
│       │   ├── PositionAssessment.swift  # (alias / convenience)
│       │   ├── MoveClassification.swift  # brilliant → blunder enum
│       │   ├── AnalyzedMove.swift    # Per-move analysis result
│       │   ├── GameAnalysis.swift    # Full game result
│       │   ├── Accuracy.swift        # White/black accuracy
│       │   ├── WinProbability.swift  # Win/draw/loss percentages
│       │   ├── GamePhases.swift      # Opening/middlegame/endgame ranges
│       │   └── EngineConfiguration.swift  # Threads, hash, depth
│       └── Analysis/
│           ├── GameAnalyzer.swift    # Pipeline: FENs → GameAnalysis
│           ├── AccuracyCalculator.swift  # CPL → accuracy percentage
│           ├── MoveClassifier.swift  # CPL thresholds → classification
│           ├── WinProbabilityCalculator.swift  # Centipawns → win%
│           └── PhaseDetector.swift   # Piece count → game phase
├── Tests/
│   └── LucidEngineTests/
│       ├── EngineLifecycleTests.swift       # Init, start, stop, reinit
│       ├── PositionAssessmentTests.swift    # Known positions, edge cases
│       ├── MoveClassificationTests.swift    # CPL → classification mapping
│       ├── GameAnalysisTests.swift          # Full pipeline tests
│       └── PerformanceBenchmarkTests.swift  # Timing & memory benchmarks
├── Package.swift                     # SPM manifest (CStockfish + LucidEngine)
├── README.md                         # Project overview & quick start
├── directory-tree.md                 # This file
├── LICENSE                           # MIT
└── .gitignore                        # Build artifacts, .DS_Store, etc.
```

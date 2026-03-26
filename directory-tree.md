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
│   ├── hooks/
│   │   └── notify.sh
│   ├── skills/                       # Custom skills
│   │   └── engine-patterns/
│   │       ├── assessment.md
│   │       ├── c-interop.md
│   │       └── SKILL.md
│   ├── CLAUDE.md                     # Project instructions
│   ├── NEXT-SESSION.md              # Session bootstrap prompt
│   ├── settings.json
│   └── settings.local.json
├── docs/
│   ├── PRD.md                        # Product Requirements Document
│   └── ARCHITECTURE.md              # Technical architecture blueprint
├── Sources/
│   ├── CStockfish/                   # C/C++ Stockfish target (Issue #1)
│   │   ├── include/
│   │   │   └── stockfish_bridge.h   # Public C header for Swift interop
│   │   └── src/
│   │       ├── stockfish_bridge.c   # C bridge implementation
│   │       └── (stockfish sources)  # [planned] Stockfish C++ source files
│   └── LucidEngine/                  # Swift public API target
│       ├── Engine/
│       │   ├── LucidEngine.swift     # Main actor skeleton (Issue #1)
│       │   └── EngineError.swift     # Error types (Issue #1)
│       ├── Models/                   # [planned]
│       │   ├── Score.swift           # [planned] Centipawns / mate-in-N
│       │   ├── Move.swift            # [planned] From/to/promotion/UCI
│       │   ├── Evaluation.swift      # [planned] Single position result
│       │   ├── PositionAssessment.swift  # [planned] Alias / convenience
│       │   ├── MoveClassification.swift  # [planned] brilliant → blunder enum
│       │   ├── AnalyzedMove.swift    # [planned] Per-move analysis result
│       │   ├── GameAnalysis.swift    # [planned] Full game result
│       │   ├── Accuracy.swift        # [planned] White/black accuracy
│       │   ├── WinProbability.swift  # [planned] Win/draw/loss percentages
│       │   ├── GamePhases.swift      # [planned] Opening/middlegame/endgame ranges
│       │   └── EngineConfiguration.swift  # [planned] Threads, hash, depth
│       └── Analysis/                 # [planned]
│           ├── GameAnalyzer.swift    # [planned] Pipeline: FENs → GameAnalysis
│           ├── AccuracyCalculator.swift  # [planned] CPL → accuracy percentage
│           ├── MoveClassifier.swift  # [planned] CPL thresholds → classification
│           ├── WinProbabilityCalculator.swift  # [planned] Centipawns → win%
│           └── PhaseDetector.swift   # [planned] Piece count → game phase
├── Tests/
│   └── LucidEngineTests/
│       ├── PackageStructureTests.swift      # SPM scaffold verification (Issue #1)
│       ├── EngineLifecycleTests.swift       # [planned] Init, start, stop, reinit
│       ├── PositionAssessmentTests.swift    # [planned] Known positions, edge cases
│       ├── MoveClassificationTests.swift    # [planned] CPL → classification mapping
│       ├── GameAnalysisTests.swift          # [planned] Full pipeline tests
│       └── PerformanceBenchmarkTests.swift  # [planned] Timing & memory benchmarks
├── Package.swift                     # SPM manifest (CStockfish + LucidEngine, swift-tools-version: 6.2)
├── README.md                         # Project overview & quick start
├── directory-tree.md                 # This file
├── LICENSE                           # [planned] MIT
└── .gitignore                        # Build artifacts, .DS_Store, etc.
```

## Issue Status

| Issue | Description | Status |
|-------|-------------|--------|
| #1 | SPM package scaffold -- CStockfish + LucidEngine targets, bridge header, actor skeleton | Done |
| #2 | Stockfish C++ source integration and build pipeline | Planned |
| #3 | UCI communication layer (pipe-based I/O) | Planned |
| #4 | Evaluation models and score parsing | Planned |
| #5 | Game analysis pipeline and move classification | Planned |

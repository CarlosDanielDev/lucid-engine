# Changelog

All notable changes to LucidEngine will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-03-28

### Added

- **Core Engine** — `LucidEngine` actor with `start()`, `shutdown()`, `evaluate(fen:depth:)`, and `bestMove(fen:depth:)` backed by Stockfish 17.1 via C++ interop and pipe-based I/O
- **Game Analysis Pipeline** — `analyzeGame(fens:depth:)` with per-move evaluation, FEN diff detection, and centipawn loss calculation
- **Move Classification** — Classify moves as brilliant, great, good, book, inaccuracy, mistake, or blunder based on CPL thresholds and mate detection
- **Accuracy Calculation** — Per-player accuracy (0-100%) using the Lichess sigmoid formula with book move handling
- **Win Probability** — Logistic WDL model converting engine scores to win/draw/loss probabilities per position
- **Game Phase Detection** — Opening/middlegame/endgame detection using material counting heuristics
- **Progressive Analysis** — Two-pass `analyzeGameProgressive()` with fast preview callback and full-depth final result
- **Opening Book** — Embedded ECO database (~45 openings) detecting Italian, Sicilian, Ruy Lopez, Queen's Gambit, French, Caro-Kann, and more
- **Core Models** — `Score`, `Move`, `PositionAssessment`, `AnalyzedMove`, `GameAnalysis`, `Accuracy`, `WinProbability`, `GamePhases`, `OpeningInfo`, `MoveClassification`
- **FEN Utilities** — `FENValidator` and `FENDiff` for position validation and move detection
- **Platform Support** — iOS 17+ and macOS 14+ via Swift Package Manager

[1.0.0]: https://github.com/CarlosDanielDev/lucid-engine/releases/tag/1.0.0

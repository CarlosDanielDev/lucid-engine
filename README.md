# LucidEngine

**A Swift Package that wraps Stockfish for safe, high-quality chess analysis on iOS and macOS.**

<!-- Badges: CI, Swift version, platform support, license -->

## Why LucidEngine?

Existing Stockfish wrappers for Swift use `dup2()` to redirect stdout, which crashes SwiftUI. LucidEngine compiles Stockfish as a C library and communicates via direct function calls -- no stdout hijacking, no crashes. It delivers Stockfish-level analysis (~3500 ELO) through a clean async/await API.

## Features

- **Single position evaluation** -- FEN in, centipawn score + best move out
- **Full game analysis** -- analyze every move with accuracy percentages
- **Move classification** -- brilliant, great, good, book, inaccuracy, mistake, blunder
- **Win probability** -- per-move win/draw/loss percentages
- **Game phase detection** -- opening, middlegame, endgame boundaries
- **Thread-safe** -- actor-based API serializes all engine access
- **No stdout redirect** -- safe to use alongside SwiftUI and OSLog

## Installation

Add LucidEngine as an SPM dependency:

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/CarlosDanielDev/lucid-engine", from: "1.0.0")
]
```

Or in Xcode: File -> Add Package Dependencies -> enter the repository URL.

## Quick Start

### Evaluate a Position

```swift
import LucidEngine

let engine = LucidEngine()

// Evaluate the starting position
let eval = try await engine.evaluate(fen: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
print(eval.score)        // .centipawns(20) -- slight white advantage
print(eval.bestMove.uci) // "e2e4"
```

### Analyze a Complete Game

```swift
// Array of FEN positions from your game
let fens: [String] = gameViewModel.fenHistory

let analysis = try await engine.analyzeGame(fens: fens)

// Per-player accuracy
print("White: \(analysis.accuracy.white)%")  // e.g., 87.3%
print("Black: \(analysis.accuracy.black)%")  // e.g., 72.1%

// Walk through each move
for move in analysis.analyzedMoves {
    print("Move \(move.moveNumber): \(move.classification)")
    // .brilliant, .great, .good, .inaccuracy, .mistake, .blunder
}
```

## API Reference

| Type | Description |
|------|-------------|
| `LucidEngine` | Actor -- main entry point for all evaluations |
| `Evaluation` | Score, best move, principal variation, depth, nodes |
| `Score` | `.centipawns(Int)` or `.mate(Int)` |
| `Move` | From/to squares, promotion, UCI notation |
| `GameAnalysis` | Full game result: analyzed moves, accuracy, phases |
| `AnalyzedMove` | Per-move evaluation, classification, centipawn loss |
| `MoveClassification` | brilliant / great / good / book / inaccuracy / mistake / blunder |
| `Accuracy` | White and black accuracy percentages |
| `WinProbability` | Win / draw / loss probabilities |
| `GamePhases` | Opening / middlegame / endgame move ranges |
| `EngineConfiguration` | Threads, hash size, default depth |
| `EngineError` | Initialization, invalid FEN, timeout, not running |

## Requirements

| Requirement | Version |
|------------|---------|
| Swift | 6.2+ |
| iOS | 17.0+ |
| macOS | 14.0+ |
| Xcode | 16.0+ |

## Architecture

LucidEngine uses two SPM targets:

- **CStockfish** -- Stockfish compiled as a C library with a bridging header
- **LucidEngine** -- Swift actor wrapping the C library with an async/await API

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for the full technical blueprint.

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feat/my-feature`)
3. Write tests first (TDD is mandatory)
4. Make your changes
5. Run `swift test` to verify
6. Open a Pull Request

## License

MIT License. See [LICENSE](LICENSE) for details.

## Credits

- [Stockfish](https://stockfishchess.org/) -- the chess engine powering the analysis
- [lucidmate](https://github.com/CarlosDanielDev/lucid-mate-mobile-swift) -- the iOS chess app that inspired this package

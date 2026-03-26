# Position Assessment Pipeline

## Overview

The assessment pipeline takes a completed game (as an array of FEN positions) and produces
a detailed analysis with per-move classifications, accuracy percentages, and win probability curves.

## Pipeline Stages

### Stage 1: Position Collection
```
Input: Array of FEN strings, one per half-move
       (from game start to final position)

Source: lucidmate stores FEN per move via GameViewModel.fenHistory
```

### Stage 2: Engine Assessment
```
For each FEN position:
  1. Run engine at depth 18-20
  2. Capture: centipawn score, best move, principal variation
  3. Store as PositionAssessment(fen, score, bestMove, pv, depth, nodes)
```

### Stage 3: Centipawn Loss Calculation
```
For each played move (move N):
  1. Get assessment of position BEFORE move N (eval_before)
  2. Get assessment of position AFTER move N (eval_after)
  3. Get assessment of position after BEST move (eval_best)
  4. centipawn_loss = |eval_best - eval_after|
     (from the perspective of the moving side)
```

### Stage 4: Move Classification
```
Based on centipawn_loss:
  - 0-10 cp:   Great move (or Brilliant if special conditions met)
  - 10-30 cp:  Good move
  - 30-90 cp:  Inaccuracy
  - 90-200 cp: Mistake
  - 200+ cp:   Blunder

Special: Brilliant
  - Position was losing (eval < -150 for moving side)
  - Played move is the ONLY move that maintains/improves position
  - All other moves lose significantly more
```

### Stage 5: Accuracy Calculation
```
Per-player accuracy uses the formula:
  accuracy = 100 * (1 - average_centipawn_loss / max_cp_loss)

Where max_cp_loss is calibrated (typically 200-300 cp).

Alternative (chess.com style):
  Per-move accuracy = 103.1668 * exp(-0.04354 * (centipawn_loss * 2)) - 3.1669
  Clamped to [0, 100]
  Overall accuracy = average of per-move accuracies
```

### Stage 6: Win Probability
```
Convert centipawn score to win probability:
  win_prob = 1 / (1 + exp(-0.004 * centipawns))

This gives a sigmoid curve from 0% to 100%.
Mate scores map to 100% or 0%.
```

### Stage 7: Phase Detection
```
Opening:    moves 1-15 (approximately)
Middlegame: moves 15-35 (approximately)
Endgame:    moves 35+ or when total material < threshold

Better heuristic: track total material on board
  - Opening: >= 60 points of material (excluding kings)
  - Middlegame: 30-60 points
  - Endgame: < 30 points
```

## Output Model

```swift
public struct GameAnalysis: Sendable {
    public let moves: [AnalyzedMove]
    public let whiteAccuracy: Double  // 0-100%
    public let blackAccuracy: Double  // 0-100%
    public let phases: GamePhases
    public let winProbabilityCurve: [Double]  // per half-move, 0.0-1.0
}

public struct AnalyzedMove: Sendable {
    public let moveNumber: Int
    public let color: PieceColor
    public let san: String           // e.g., "Nf3"
    public let classification: MoveClassification
    public let centipawnLoss: Int
    public let scoreBefore: Score
    public let scoreAfter: Score
    public let bestMove: String      // what engine recommended
    public let winProbabilityAfter: Double
}

public struct GamePhases: Sendable {
    public let openingEndMove: Int
    public let middlegameEndMove: Int
    public let openingAccuracy: (white: Double, black: Double)
    public let middlegameAccuracy: (white: Double, black: Double)
    public let endgameAccuracy: (white: Double, black: Double)
}
```

## Performance Optimization

### Parallel Assessment (if using subprocess approach)
```
Batch positions into groups of 4-8
Run multiple engine instances in parallel
Merge results maintaining move order
```

### Progressive Depth
```
For quick preview: depth 12 (< 100ms per position)
For full analysis: depth 18-20 (< 500ms per position)
User sees preview instantly, full analysis loads progressively
```

### Caching
```
Cache assessments by (FEN + depth) hash
Same position at same depth always produces same result
Useful for games with transpositions
```

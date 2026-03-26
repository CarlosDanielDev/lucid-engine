# LucidEngine -- Architecture Blueprint

## Package Structure

LucidEngine is an SPM package with two targets:

```
Package.swift
├── CStockfish (C/C++ target)
│   ├── include/stockfish_bridge.h    # Public C header exposed to Swift
│   └── src/                          # Stockfish C++ sources + bridge implementation
└── LucidEngine (Swift target, depends on CStockfish)
    ├── Engine/                       # Actor wrapper, lifecycle management
    ├── Models/                       # Score, Move, Assessment, etc.
    └── Analysis/                     # Game analysis pipeline, classification
```

The `CStockfish` target compiles Stockfish as a static C library. The `LucidEngine` target imports it via the bridging header and provides a clean async Swift API.

---

## The dup2 Problem

### What Crashed

ChessKitEngine (and similar wrappers) use `dup2()` to redirect `stdout` to a pipe, then launch Stockfish's UCI loop which writes to `stdout`. The wrapper reads from the pipe to capture engine output.

```c
// What ChessKitEngine does (simplified):
int pipefd[2];
pipe(pipefd);
dup2(pipefd[1], STDOUT_FILENO);  // ALL stdout now goes to pipe
// Stockfish writes to stdout -> wrapper reads from pipe
```

**The problem:** `dup2(pipefd[1], STDOUT_FILENO)` replaces the process's stdout file descriptor globally. SwiftUI, OSLog, and other system frameworks also write to stdout. Once redirected:
- SwiftUI's internal logging breaks
- OSLog messages vanish or corrupt
- The app crashes with `SIGPIPE` or hangs on blocked writes

This is a process-wide side effect. There's no way to scope it to just Stockfish.

### Our Solution

LucidEngine compiles Stockfish as a C library and calls its assessment functions directly -- no UCI protocol, no stdout, no pipes for engine communication. The C bridging layer exposes specific functions:

```c
// stockfish_bridge.h
int stockfish_init(void);
int stockfish_assess(const char* fen, int depth, AssessResult* result);
void stockfish_cleanup(void);
```

Stockfish's assessment runs in-process but never touches stdout. Results come back via return values and output parameters.

---

## C/C++ Integration Strategy

### Why C Library Over Subprocess

| Approach | Pros | Cons |
|----------|------|------|
| **Subprocess** (posix_spawn) | Process isolation, familiar UCI | Sandboxed on iOS, can't spawn processes |
| **dup2 redirect** | Works with stock Stockfish | Crashes SwiftUI (see above) |
| **C library** (our approach) | No stdout issues, in-process speed, works on iOS | Requires modifying Stockfish, C++ compilation complexity |

iOS apps cannot spawn subprocesses (sandbox restriction), which eliminates the subprocess approach entirely. The C library approach is the only viable option.

### How Bridging Works

1. **CStockfish target** compiles Stockfish C++ sources with a C-compatible wrapper
2. `stockfish_bridge.h` declares `extern "C"` functions callable from Swift
3. SPM's `clang` module system makes these functions available to Swift via `import CStockfish`
4. Swift calls C functions directly -- no serialization, no IPC overhead

```swift
// In LucidEngine (Swift):
import CStockfish

let result = UnsafeMutablePointer<AssessResult>.allocate(capacity: 1)
defer { result.deallocate() }

let status = stockfish_assess(fen, Int32(depth), result)
// Convert result to Swift types...
```

---

## Actor-Based Concurrency Model

### Why Actor Over Callbacks

Stockfish is **not thread-safe** -- it uses global state for position, hash tables, and search. Concurrent assessments would corrupt state and produce wrong results.

A Swift `actor` guarantees serial access:

```swift
public actor LucidEngine {
    private var isRunning = false

    public func assess(fen: String, depth: Int) async throws -> Assessment {
        // Actor isolation guarantees this runs serially
        // No two assessments can overlap
        guard isRunning else { throw EngineError.engineNotRunning }
        return try performAssessment(fen: fen, depth: depth)
    }
}
```

Benefits:
- **Thread safety by construction** -- no locks, no races, no forgotten mutexes
- **Natural async/await** -- callers just `await engine.assess(fen:depth:)`
- **Cooperative cancellation** -- `Task.isCancelled` checked between assessments
- **Backpressure** -- actor mailbox naturally queues requests

---

## Assessment Pipeline

The game analysis pipeline processes an array of FEN positions through several stages:

```
Input: [FEN_0, FEN_1, FEN_2, ..., FEN_n]
                    |
                    v
         +--------------------+
Stage 1  |  Position Assess   |  Assess each FEN at target depth
         |  (Stockfish)       |  Output: [Assessment_0, ..., Assessment_n]
         +--------+-----------+
                  |
                  v
         +--------------------+
Stage 2  |  Delta Calc        |  Compare consecutive assessments
         |                    |  Output: centipawn loss per move
         +--------+-----------+
                  |
                  v
         +--------------------+
Stage 3  |  Classification    |  Apply CPL thresholds + special detection
         |                    |  Output: [MoveClassification_0, ..., MoveClassification_n]
         +--------+-----------+
                  |
                  v
         +--------------------+
Stage 4  |  Aggregation       |  Accuracy, win probability, phases
         |                    |  Output: GameAnalysis
         +--------------------+
```

Each stage is a pure function operating on the previous stage's output, making the pipeline testable at every step.

---

## Move Classification Algorithm

### Centipawn Loss (CPL) Thresholds

Move classification is based on the centipawn loss between the position assessment before and after a move, compared to the best available move:

```
CPL = assessment_before_best_move - assessment_after_played_move
```

(Normalized so positive CPL = player lost advantage)

| Classification | CPL Range | Additional Conditions |
|---------------|-----------|----------------------|
| Brilliant | CPL <= 0 | Must be a sacrifice (material given up) AND position improves |
| Great | CPL = 0 | Only winning move (all alternatives lose >= 150cp) |
| Good | CPL <= 10 | -- |
| Book | -- | Position matches known opening theory |
| Inaccuracy | 30 - 80 | -- |
| Mistake | 80 - 200 | -- |
| Blunder | > 200 | OR misses forced mate |

Moves with CPL 10-30 are classified as `good` (not worth flagging).

### Accuracy Calculation

Per-player accuracy uses the formula from chess.com/Lichess style:

```
accuracy = (1 / N) * sum( max(0, 100 - (CPL_i / k)) )
```

Where `k` is a scaling factor (typically ~3.5) and `N` is the number of moves by that player.

---

## Memory Management

C allocations from the Stockfish bridge must be paired with Swift cleanup:

```swift
// Pattern: allocate, use, deallocate
let result = UnsafeMutablePointer<AssessResult>.allocate(capacity: 1)
defer { result.deallocate() }

stockfish_assess(fen, depth, result)
let assessment = Assessment(from: result.pointee)  // copy to Swift value type
// result.deallocate() runs here via defer
```

**Rules:**
1. Every `allocate()` has a `defer { deallocate() }` on the next line
2. C strings passed to Stockfish use `withCString` (no manual allocation)
3. `stockfish_cleanup()` is called in the actor's `deinit` or `shutdown()`
4. All Stockfish global state (hash tables, etc.) is freed on cleanup

---

## Threading Model

```
+------------------------------------------+
|              Main Actor                   |
|  (SwiftUI / Consumer code)               |
|                                           |
|  let result = await engine.assess(fen)   |
+-------------------+----------------------+
                    | await (suspends, non-blocking)
                    v
+------------------------------------------+
|           LucidEngine Actor               |
|  (Serial executor -- one task at a time) |
|                                           |
|  stockfish_assess(fen, depth, &result)   |  <-- blocking C call
|  return Assessment(from: result)          |
+------------------------------------------+
```

- **Main thread never blocks** -- `await` suspends the calling task
- **Engine actor serializes** -- only one Stockfish call at a time
- **Cancellation** -- for game analysis, `Task.isCancelled` is checked between each position assessment
- **Timeout** -- implemented via `Task.sleep` racing against the assessment

---

## Consumer Integration Guide

### Adding LucidEngine to lucidmate

1. In Xcode, open lucidmate project
2. File -> Add Package Dependencies
3. Add local package: `/Users/carlos/projects/lucid-engine` (during development)
4. Or add git URL: `https://github.com/CarlosDanielDev/lucid-engine` (for release)

```swift
// Package.swift (lucidmate)
dependencies: [
    .package(path: "../lucid-engine")  // local development
    // .package(url: "https://github.com/CarlosDanielDev/lucid-engine", from: "1.0.0")
]
```

### Usage in lucidmate

```swift
import LucidEngine

class AnalysisViewModel: ObservableObject {
    private let engine = LucidEngine()

    func analyzeGame(fens: [String]) async throws {
        let analysis = try await engine.analyzeGame(fens: fens)

        await MainActor.run {
            self.moves = analysis.analyzedMoves
            self.whiteAccuracy = analysis.accuracy.white
            self.blackAccuracy = analysis.accuracy.black
        }
    }
}
```

---

## Architecture Decision Records

### ADR-001: C Library Over Subprocess

**Status:** Accepted

**Context:** We need to integrate Stockfish into an iOS app. Three approaches exist: subprocess (posix_spawn), stdout redirect (dup2), or C library compilation.

**Decision:** Compile Stockfish as a C library target in SPM, called via bridging header.

**Rationale:**
- iOS sandbox prohibits subprocess spawning -- subprocess approach is impossible
- dup2 redirect crashes SwiftUI by hijacking process stdout
- C library runs in-process, avoids stdout entirely, and is the fastest option (no IPC/serialization)

**Consequences:**
- Must modify Stockfish source to expose C-callable assessment functions
- C++ compilation adds build complexity to SPM
- Stockfish version upgrades require re-applying the bridging modifications

### ADR-002: Actor-Based API Over Callback-Based

**Status:** Accepted

**Context:** Stockfish uses global mutable state and is not thread-safe. We need to serialize access and present a safe API to consumers.

**Decision:** Use a Swift `actor` for the public API.

**Rationale:**
- Actors guarantee serial access -- eliminates race conditions by construction
- Natural fit for Swift concurrency (`async/await`)
- No manual locking required -- fewer bugs, simpler code
- Cooperative cancellation works naturally with structured concurrency

**Consequences:**
- Callers must use `await` (minor ergonomic cost, but standard in modern Swift)
- Cannot be used from synchronous contexts without `Task { }` wrapper
- Actor hop overhead is negligible compared to Stockfish assessment time

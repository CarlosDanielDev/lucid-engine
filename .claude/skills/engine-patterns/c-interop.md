# C/C++ Interop Patterns for LucidEngine

## SPM C Target Setup

### Package.swift Structure
```swift
let package = Package(
    name: "lucid-engine",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "LucidEngine", targets: ["LucidEngine"]),
    ],
    targets: [
        // C/C++ Stockfish target
        .target(
            name: "CStockfish",
            path: "Sources/CStockfish",
            sources: ["src/"],
            publicHeadersPath: "include",
            cxxSettings: [
                .define("NNUE_EMBEDDING_OFF"),
                .define("USE_PEXT", .when(platforms: [.macOS])),
                .headerSearchPath("src"),
                .unsafeFlags(["-std=c++17", "-O2", "-DNDEBUG"])
            ],
            linkerSettings: [
                .linkedLibrary("c++")
            ]
        ),
        // Swift public API
        .target(
            name: "LucidEngine",
            dependencies: ["CStockfish"],
            path: "Sources/LucidEngine"
        ),
        // Tests
        .testTarget(
            name: "LucidEngineTests",
            dependencies: ["LucidEngine"]
        ),
    ]
)
```

## Bridging Header Pattern

### `Sources/CStockfish/include/stockfish_bridge.h`
```c
#ifndef STOCKFISH_BRIDGE_H
#define STOCKFISH_BRIDGE_H

#ifdef __cplusplus
extern "C" {
#endif

// Initialize engine (call once)
int sf_init(void);

// Cleanup engine (call on shutdown)
void sf_cleanup(void);

// Assess position -- returns centipawn score
// fen: null-terminated FEN string
// depth: search depth (1-30)
// Returns centipawn score from side-to-move perspective
int sf_assess_position(const char* fen, int depth);

// Get best move for position
// fen: null-terminated FEN string
// depth: search depth
// out_move: buffer for UCI move string (min 6 bytes: "e2e4\0" or "e7e8q\0")
// Returns 0 on success, -1 on error
int sf_best_move(const char* fen, int depth, char* out_move, int buf_size);

// Get principal variation
// Returns number of moves written to out_pv
int sf_principal_variation(const char* fen, int depth, char* out_pv, int buf_size);

#ifdef __cplusplus
}
#endif

#endif // STOCKFISH_BRIDGE_H
```

## Swift Actor Wrapper Pattern

```swift
@_implementationOnly import CStockfish

public actor LucidEngine {
    private var isInitialized = false

    public init() {}

    public func start() throws {
        guard !isInitialized else { return }
        let result = sf_init()
        guard result == 0 else { throw EngineError.initializationFailed }
        isInitialized = true
    }

    deinit {
        if isInitialized {
            sf_cleanup()
        }
    }

    public func assess(fen: String, depth: Int) async throws -> PositionScore {
        guard isInitialized else { throw EngineError.notInitialized }
        guard depth > 0 && depth <= 30 else { throw EngineError.invalidDepth(depth) }

        // Run engine work off the actor's executor
        let score = fen.withCString { cFen in
            sf_assess_position(cFen, Int32(depth))
        }

        return PositionScore(centipawns: Int(score))
    }
}
```

## Memory Safety Rules

### DO
- Use `withCString` for passing Swift strings to C
- Use `withUnsafeMutableBufferPointer` for output buffers
- Pair every `sf_init()` with `sf_cleanup()`
- Validate all inputs before passing to C functions

### DON'T
- Store raw C pointers beyond `withUnsafe*` scope
- Pass Swift objects to C functions
- Use `dup2()` or redirect stdout/stderr
- Call C functions from multiple threads without actor serialization

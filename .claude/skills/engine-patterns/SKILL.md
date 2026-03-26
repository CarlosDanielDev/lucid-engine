---
name: engine-patterns
version: "1.0.0"
description: Stockfish integration patterns for Swift packages -- C/C++ interop, pipe-based I/O, position assessment pipelines, move classification, and performance optimization for iOS/macOS.
allowed-tools: Read, Grep, Glob, WebSearch
---

# Engine Patterns Skill

## Quick Reference

### Why This Package Exists
The lucidmate iOS app previously used ChessKitEngine (Stockfish SPM wrapper) which crashed SwiftUI due to `dup2()` stdout redirect. LucidEngine solves this by:
1. Using pipe-based I/O (no stdout hijacking)
2. Compiling Stockfish as a C target (no subprocess overhead)
3. Providing a clean Swift actor API

### Core Patterns

#### 1. C Target in SPM
- Stockfish compiled as `CStockfish` target
- Public headers in `Sources/CStockfish/include/`
- Swift imports via `@_implementationOnly import CStockfish`

#### 2. Actor-Based Engine Access
- `LucidEngine` is a Swift actor
- All engine operations serialized automatically
- Background work via `Task.detached`
- Cooperative cancellation via `Task.isCancelled`

#### 3. Assessment Pipeline
- Input: array of FEN strings (one per half-move)
- Each FEN assessed at configurable depth
- Centipawn loss computed per move
- Moves classified by loss thresholds

#### 4. Move Classification
| Class | CP Loss | Notes |
|-------|---------|-------|
| Brilliant | Special | Only winning move in losing pos |
| Great | 0-10 | Top engine choice |
| Good | 10-30 | Solid move |
| Book | N/A | Opening theory |
| Inaccuracy | 30-90 | Noticeable error |
| Mistake | 90-200 | Significant loss |
| Blunder | 200+ | Game-changing error |

### Detailed Guides
- `c-interop.md` -- C/C++ bridging patterns and memory safety
- `assessment.md` -- Position assessment pipeline and accuracy calculation

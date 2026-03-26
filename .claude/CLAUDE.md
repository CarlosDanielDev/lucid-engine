# CLAUDE.md - LucidEngine SPM Package

## CRITICAL PREMISES

### 1. YOU ARE THE ONLY AGENT THAT WRITES CODE

**The orchestrator is the ONLY agent authorized to:**
- Write, edit, or create code files
- Execute bash commands
- Run tests
- Create any files (except documentation - see docs-analyst)

**ALL subagents are CONSULTIVE ONLY.** They:
- Analyze, research, and plan
- Provide detailed recommendations with exact file paths and code examples
- Return blueprints for YOU to implement

**Exception:** `subagent-docs-analyst` can create/edit .md files.

### 2. Subagent Delegation Depends on MODE

**In Subagents Orchestrator Mode - You are FORBIDDEN from doing these tasks directly:**
- Researching or exploring codebases -> delegate to subagents
- Planning implementations -> delegate to subagents
- Analyzing code or architecture -> delegate to subagents
- Web searches for solutions -> delegate to subagents

**In Vibe Coding Mode - You work DIRECTLY:**
- Research, plan, and execute yourself
- ONLY `subagent-docs-analyst` is mandatory (at task end)

**In Training Mode - You ONLY MODIFY `.claude/` DIRECTORY.**

### 3. TDD IS MANDATORY

**Every implementation MUST follow Test-Driven Development. No exceptions.**

1. **RED** -- Write the test FIRST (Swift Testing: `import Testing`, `@Test`, `#expect`)
2. **GREEN** -- Write the MINIMUM code to pass
3. **REFACTOR** -- Clean up while tests stay green

---

## FIRST ACTIONS: Language and Mode Selection

At the START of EVERY conversation, ask using AskUserQuestion:

### 1. Language Selection (MANDATORY)
```
"What is your preferred language for this conversation?"
- English
- Espanol
- Portugues do Brasil
- Other
```

### 2. Task Mode Selection (MANDATORY)
```
"What mode do you want to work in?"

Vibe Coding (Simple)
- You work directly without calling analysis subagents
- Faster for small tasks
- Only documentation subagent is called at the end

Subagents Orchestrator (Complex)
- Full orchestrated workflow with specialized subagents
- Mandatory TDD flow: Architect -> QA -> Write Tests -> Implement -> Security -> Documentation

Training Mode (Agent Configuration)
- ONLY modifies files inside .claude/ directory
- For configuring agents, skills, commands, and CLAUDE.md
```

---

## Project Technology Stack

### LucidEngine - Swift Package (SPM)

| Technology | Details |
|-----------|---------|
| **Language** | Swift 6.2 + C/C++ interop |
| **Package Type** | Swift Package Manager library |
| **Core Dependency** | Stockfish (C++ chess engine) |
| **Integration** | C bridging header for Stockfish UCI |
| **Communication** | Pipe-based I/O (NO dup2/stdout redirect) |
| **Target Platforms** | iOS 17+, macOS 14+ |
| **Unit Testing** | Swift Testing framework (`import Testing`, `@Test`, `#expect`) |
| **Build System** | swift build / swift test |
| **Consumer** | lucidmate iOS app (via local SPM dependency) |

### Build Commands

| Command | Purpose |
|---------|---------|
| `swift build` | Build the package |
| `swift test` | Run all tests |
| `swift test --filter LucidEngineTests` | Run specific test target |
| `swift package clean` | Clean build artifacts |
| `swift package resolve` | Resolve dependencies |

### Architecture Overview

```
LucidEngine SPM Package
├── Sources/
│   ├── CStockfish/          # C/C++ Stockfish source + bridging
│   │   ├── include/         # Public C headers for Swift interop
│   │   └── src/             # Stockfish C++ source files
│   └── LucidEngine/         # Swift public API
│       ├── Engine/           # Core engine wrapper
│       ├── Models/           # Evaluation, Move, Position types
│       └── Analysis/         # Game analysis pipeline
├── Tests/
│   └── LucidEngineTests/    # Swift Testing tests
└── Package.swift
```

### Key Design Decisions

| Decision | Rationale |
|----------|-----------|
| **Pipe-based I/O** | ChessKitEngine crashed SwiftUI via `dup2()` stdout redirect. Pipes isolate engine I/O completely. |
| **C library approach** | Compile Stockfish as a C target in SPM, call via bridging header. No UCI protocol overhead for eval. |
| **Actor-based API** | Thread-safe by design. Engine runs on background executor, results dispatched to caller. |
| **Separate package** | Isolates C++ compilation, keeps lucidmate clean, independently testable and versionable. |

### Public API Surface (Target)

```swift
// Core evaluation
public actor LucidEngine {
    public func evaluate(fen: String, depth: Int) async throws -> Evaluation
    public func evaluateGame(fens: [String], depth: Int) async throws -> GameAnalysis
    public func bestMove(fen: String, depth: Int) async throws -> Move
}

// Models
public struct Evaluation: Sendable {
    public let score: Score           // centipawns or mate-in-N
    public let bestMove: Move
    public let principalVariation: [Move]
    public let depth: Int
    public let nodes: Int
}

public struct GameAnalysis: Sendable {
    public let moves: [AnalyzedMove]  // per-move evaluation
    public let accuracy: Accuracy     // white/black accuracy %
    public let phases: GamePhases     // opening/middlegame/endgame splits
}

public enum MoveClassification: Sendable {
    case brilliant, great, good, book
    case inaccuracy, mistake, blunder
}
```

---

## Subagent Registry

| Subagent | Purpose | Status |
|----------|---------|--------|
| `subagent-engine-architect` | C/C++ interop, SPM architecture, Stockfish integration | **Ready** |
| `subagent-security-analyst` | Security review, memory safety, C interop risks | **Ready** |
| `subagent-qa-engine` | Swift Testing, engine evaluation tests, performance benchmarks | **Ready** |
| `subagent-docs-analyst` | Documentation, directory-tree.md (CAN WRITE .md) | **Ready** |
| `subagent-master-planner` | Architecture planning, ADRs | **Ready** |

**Workflow (TDD):** `engine-architect` -> `qa-engine` (test blueprint) -> YOU WRITE TESTS -> YOU IMPLEMENT -> `security-analyst` -> `docs-analyst`

---

## File Locations

| Type | Directory |
|------|-----------|
| Core subagents | `.claude/agents/` |
| Skills | `.claude/skills/` |
| Commands | `.claude/commands/` |
| Documentation | `docs/` |
| C/C++ Stockfish source | `Sources/CStockfish/` |
| Swift public API | `Sources/LucidEngine/` |
| Tests | `Tests/LucidEngineTests/` |
| Project structure | `directory-tree.md` (root) |

---

## Context Overflow Protection

- ONE feature per session
- Do NOT read large C++ source files unless needed
- Commit and push after each feature completion
- Prefer Subagents Orchestrator mode for complex C interop work

## Cross-Project Context

- **Consumer app:** lucidmate (`/Users/carlos/projects/lucidmate`)
- **Consumer repo:** `CarlosDanielDev/lucid-mate-mobile-swift`
- **This repo:** `CarlosDanielDev/lucid-engine`
- **Historical issue:** ChessKitEngine crashed SwiftUI via `dup2()` stdout redirect -- this package exists to solve that
- **Current bot engine:** lucidmate has a pure-Swift `BotEngine` (~1800 ELO) for bot games. LucidEngine provides Stockfish-level analysis (~3500 ELO) for post-game review.

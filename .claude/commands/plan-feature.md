# Plan Feature

Plan a feature for the LucidEngine package, creating linked issues with dependency tracking.

**Usage:** `/plan-feature <description>` or `/plan-feature`

---

## Arguments

`$ARGUMENTS` contains the user's natural language description of the feature.

If no arguments provided, ask: "Describe the feature you want to build. I'll analyze the impact, create a plan, and generate linked issues."

---

## Instructions

### Phase 1: ANALYZE -- Understand the Feature

1. **Parse the user's description** to identify:
   - What the user wants (feature goals)
   - Which modules are affected (CStockfish, LucidEngine, Tests)
   - What the public API changes look like

2. **Explore the codebase** to understand current state:
   - Package.swift targets and dependencies
   - Existing source files and their responsibilities
   - Test coverage

3. **Present the analysis** to the user

### Phase 2: PLAN -- Create Implementation Steps

Break the feature into ordered steps:
1. **Foundation** -- Types, protocols, models
2. **Core** -- Engine integration, C interop
3. **API** -- Public Swift API surface
4. **Tests** -- Test cases and benchmarks
5. **Documentation** -- README, inline docs

### Phase 3: ISSUES -- Create with Traceability

Create issues in dependency order with cross-references.

Title format:
- `feat: <description>` -- for new features
- `fix: <description>` -- for bug fixes
- `enhance: <description>` -- for improvements

Each issue includes:
- Context and requirements
- TDD checklist
- Acceptance criteria
- Dependency chain

### Phase 4: DEPENDENCY GRAPH

Output the complete implementation order as an ASCII graph.

---

## Repo Configuration

| Project | Repo |
|---------|------|
| Engine Package | `CarlosDanielDev/lucid-engine` |
| Consumer App | `CarlosDanielDev/lucid-mate-mobile-swift` |

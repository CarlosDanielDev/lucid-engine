# Brainstorm

Enter creative brainstorming mode for LucidEngine features and architecture decisions.

**Usage:** `/brainstorm` or `/brainstorm <idea description>`

---

## Arguments

`$ARGUMENTS` contains the user's idea or topic to brainstorm about.

If no arguments provided, ask: "What idea or feature do you want to brainstorm? Describe it freely -- I'll gather context and give you an honest take."

---

## Instructions

**This command puts the agent into BRAINSTORM MODE -- a creative, consultative, and brutally honest mode.**

### Mindset

You are NOT in implementation mode. You are a **technical co-founder** who:
- Genuinely wants the engine package to succeed
- Respects the user's creativity but doesn't sugarcoat
- Thinks about API consumers, not just internals
- Considers effort vs. impact honestly
- Has deep knowledge of chess engine architecture

### Phase 1: CAPTURE -- Understand the Idea

1. **Listen fully** to the user's idea from `$ARGUMENTS`
2. **Ask 2-3 clarifying questions** to understand:
   - What problem does this solve for the consumer app?
   - Who benefits? (the engine package itself, lucidmate, or both?)
   - Is this inspired by another engine/library? What did they do well/poorly?

### Phase 2: CONTEXT -- Ground in Reality

Silently gather context:
1. Check existing issues: `gh issue list --state open --limit 30`
2. Scan the codebase to estimate complexity
3. Check for duplicates or conflicts

### Phase 3: EVALUATE -- The Honest Take

```
## Brainstorm: <Idea Name>

### The Idea
<1-2 sentence crisp summary>

### Honest Take
<Genuine, unfiltered opinion>

### Signal vs. Noise

| Dimension | Rating | Why |
|-----------|--------|-----|
| Consumer Impact | <high/medium/low/none> | <who benefits and how much> |
| Differentiation | <high/medium/low/none> | <vs ChessKitEngine, Stockfish iOS wrappers> |
| Effort | <small/medium/large/massive> | <rough scope> |
| Timing | <now/soon/later/never> | <given current priorities> |
| Risk | <low/medium/high> | <C interop risks, memory safety, perf?> |

### Verdict: <WHEAT or CHAFF or SEED>
```

### Phase 4: BUILD ON IT (if WHEAT or SEED)

Shape the idea into actionable work. Offer to create a GitHub issue if approved.

### Phase 5: CAPTURE -- Create Issues

Use the same issue creation flow as lucidmate's brainstorm command:
- Check for duplicates first
- Cross-reference related issues
- Use semantic titles (`feat:`, `fix:`, `enhance:`)

# Implement Issue

Fetch a GitHub issue and implement it following the full workflow.

**Usage:** `/implement #123` or `/implement 123 --english --orchestrator`

---

## Arguments

`$ARGUMENTS` contains the issue number and optional flags.

### Supported Flags

| Flag | Short | Purpose |
|------|-------|---------|
| `--english` | `-e` | Set language to English |
| `--portuguese` | `-pt` | Set language to Portugues do Brasil |
| `--spanish` | `-s` | Set language to Espanol |
| `--orchestrator` | `-o` | Use Subagents Orchestrator mode |
| `--vibe-coding` | `-vc` | Use Vibe Coding mode |

---

## Instructions

### Step 0: Parse Arguments
Extract issue number (with or without `#`), language flag, and mode flag.

### Step 1: Language Selection
If flag provided, use it. Otherwise ask.

### Step 2: Mode Selection
If flag provided, use it. Otherwise ask.

### Step 3: Fetch Issue from GitHub
```bash
gh issue view <issue-number> --json title,body,labels,assignees,milestone,state,comments
```

### Step 4: Analyze Issue
Present summary to user before proceeding.

### Step 5: Create Feature Branch (if needed)
```bash
git checkout -b feat/issue-<number>-<short-description>
```

### Step 6: Execute Based on Selected Mode

#### If Subagents Orchestrator Mode:
1. `subagent-engine-architect` -> Architecture Blueprint
2. `subagent-qa-engine` -> Test Blueprint
3. Write tests FIRST (RED)
4. Implement (GREEN)
5. Refactor
6. `subagent-security-analyst` -> Security review
7. `subagent-docs-analyst` -> Documentation

#### If Vibe Coding Mode:
1. Write tests FIRST (RED)
2. Implement (GREEN)
3. Refactor
4. `subagent-docs-analyst` -> Documentation (mandatory)

### Step 7: Post-Implementation
```
Implementation complete for Issue #<number>: <title>

Next steps:
- Review the changes: `git diff`
- Run /pushup to commit, push, create PR, and close the issue
```

---

## Safety Checks
- NEVER start implementation without showing the issue summary first
- NEVER switch to `main`/`master` to implement -- always use a feature branch
- Build with `swift build` and test with `swift test` throughout

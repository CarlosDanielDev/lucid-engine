# Ship

Full development lifecycle automation -- from branch setup to PR merge -- for one or more GitHub issues, with sequential or parallel execution and embedded autonomous permissions.

**Usage:** `/ship #42` or `/ship #42 #43 #44 --par`

---

## Arguments

`$ARGUMENTS` format: `#<issue> [#<issue> ...] [flags]`

### Flags

| Flag          | Short | Behavior                                                        |
|---------------|-------|-----------------------------------------------------------------|
| `--seq`       |       | Process issues one by one, auto-continue between them (default) |
| `--par`       |       | Parallel execution via git worktrees                            |
| `--loop`      |       | After queue completes, prompt to continue with next issues      |
| `--fail-fast` |       | In `--par` mode, abort all worktrees if any one fails           |

Sub-command flags passed through automatically to `/implement`:
- `-e` (English) and `-o` (Orchestrator) are **always implied** -- do not ask for language or mode.

### Examples

```bash
/ship #12
/ship #12 #13 #14
/ship #12 #13 --seq
/ship #12 #13 #14 --par
/ship #12 #13 --loop
```

---

## Execution Mode Resolution

| Condition                          | Behavior         |
|------------------------------------|------------------|
| Single issue passed                | Always `--seq`   |
| Multiple issues, no flag           | Default `--seq`  |
| `--par` passed                     | Worktree mode    |

---

## Embedded Permissions

This command runs autonomously. The user has **pre-authorized** all of the following for the duration of this session. Claude **must not ask for confirmation** on any item in this list -- treat them as already approved.

### Git Operations
- `git pull origin main`
- `git checkout -b <branch>` / `git checkout <branch>`
- `git fetch origin main`
- `git worktree add / remove / prune`
- `git status` / `git log` / `git diff`
- Any read-only git introspection command

### File System
- Read any file in the project directory or worktree directories
- Write / edit any source file, test file, or config file within the scope of the current issue
- Create new files within project or worktree scope
- Delete files only if explicitly part of the issue scope or cleanup

### Shell & Process Management
- `swift build` -- build the package
- `swift test` -- run all tests
- `swift test --filter <target>` -- run specific test target
- `swift package clean` -- clean build artifacts

### Claude Code Sub-commands
- `/implement #<N> -e -o`
- `/simplify`
- `/pushup #<N>`

### GitHub CLI
- `gh issue view <N>` -- read issue metadata
- `gh pr view` -- read PR state
- `gh pr edit` -- assign, update description
- `gh pr comment` -- post `human check` comment
- `gh pr checks` -- poll CI status

### Search & File Discovery (IMPORTANT)

During `/ship` execution, **NEVER use the dedicated Grep or Glob tools** -- they trigger permission prompts that break autonomous flow. Instead:

- **File content search**: Use `grep -r 'pattern' Sources/` or `rg 'pattern' Sources/` via Bash
- **File discovery**: Use `find . -name '*.swift'` or `ls` via Bash
- **Filtering output**: Use Bash pipes (e.g., `swift test 2>&1 | grep FAIL`)
- **Reading files**: The Read tool is pre-authorized and safe to use

### What Still Requires User Confirmation

Claude **must pause and explicitly ask** before:

- Force-pushing to any branch (`git push --force`)
- Deleting any branch on the remote
- Merging a PR (user always merges via GitHub UI)
- Modifying anything outside the project root or worktree directories
- Running any command not listed in this permissions block
- Continuing the queue after a test gate fails twice on the same issue
- Accepting a diff larger than 150 lines without surfacing a summary first

---

## Status Board

Print at start of every multi-issue run and update at each phase transition:

```
/ship -- sequential mode -- 3 issues
------------------------------------------------------
[ ] #12  feat/game-analysis-pipeline      queued
[ ] #13  feat/move-classification          queued
[ ] #14  feat/accuracy-calculation         queued
------------------------------------------------------
```

Live update format (reprint board after each phase completes):
```
[done]    #12  feat/game-analysis-pipeline      merged
[active]  #13  feat/move-classification          phase 4 > gate 1
[queued]  #14  feat/accuracy-calculation         queued
```

---

## Sequential Mode (`--seq`)

Process each issue completely before starting the next. No pause between issues -- proceed automatically using embedded permissions.

```
Issue #12 -> [Phase 0-6] -> merged -> auto-continue
Issue #13 -> [Phase 0-6] -> merged -> auto-continue
Issue #14 -> [Phase 0-6] -> merged -> done
```

If any issue hits an abort condition: **stop the queue**, report the failure, wait for user input before resuming.

---

## Parallel Mode (`--par`)

Each issue gets an isolated git worktree. Create all worktrees up front, then launch all pipelines concurrently.

### Setup (automated, runs once before any issue starts)

```bash
# Pull main first
git pull origin main

# For each issue #N:
BRANCH=<prefix>/<slug>
git worktree add ../$(basename $PWD)-issue-<N> -b $BRANCH
```

### Cleanup (auto after PR is confirmed open)

```bash
git worktree remove ../lucid-engine-issue-<N>
git worktree prune
```

In `--par` mode: a failed issue aborts only its own worktree unless `--fail-fast` is also passed.

---

## Phase Pipeline

Runs for every issue, in every mode.

---

### Phase 0 -- Sync with Main

```bash
git pull origin main
```

- Auto-runs with no prompt
- In `--par`: runs once in the base repo before any worktree is created
- **If this fails: stop everything. Do not proceed.**

---

### Phase 1 -- Branch Setup

1. Fetch issue metadata (auto-runs, no prompt):
   ```bash
   gh issue view <N> --json title,labels
   ```
2. Derive branch name automatically:
   - **Prefix** from labels or title keywords: `feat/` `fix/` `test/` `chore/`
   - **Slug**: lowercase, spaces to hyphens, strip special chars, max 50 chars
3. In `--seq`: checkout or create branch in the main repo
4. In `--par`: branch is created as part of `git worktree add`
5. If working tree is dirty: stash changes automatically, confirm with `git status`

---

### Phase 2 -- Implementation

```
/implement #<N> -e -o -y
```

Auto-runs. Claude manages the iteration loop internally. The `-y` flag skips confirmation prompts.

#### TDD Enforcement

Implementation MUST follow TDD as defined in CLAUDE.md:
1. **RED** -- Write failing tests first
2. **GREEN** -- Write minimum code to pass
3. **REFACTOR** -- Clean up while tests stay green

#### Code Review Protocol

**Auto-accept without pausing:**
- Formatting, import ordering, naming conventions, boilerplate
- Test stubs, comments, documentation
- Minor refactors under 20 lines

**Pause and surface a summary before accepting:**
- Logic changes or new abstractions
- API surface changes
- Any diff larger than 150 lines
- Anything touching C interop or unsafe pointer code

When pausing, present:

```
Significant diff -- issue #<N> > Phase 2
--------------------------------------------
Files changed : 6
Lines         : +203 / -87
Summary       : <2-3 sentence description of what changed and why>
Concerns      : <any code smell or architectural risk spotted>
--------------------------------------------
[a] Accept   [s] Skip iteration   [r] Request revision
```

---

### Phase 3 -- Simplify

```
/simplify
```

Auto-runs. Waits for completion before moving to tests.
This pass refactors implementation output for clarity, removes redundancy, and enforces project conventions.

---

### Phase 4 -- Test Gates

**Both gates must be fully green. No exceptions.**

#### Gate 1 -- Build

```bash
swift build
```

The package must compile with zero errors and zero warnings.

#### Gate 2 -- Tests

```bash
swift test 2>&1
```

**Pass criteria:** The output must end with `passed` and show **0 issues**. The exact line to match:

```
Test run with N tests in M suites passed after X seconds.
```

If the output contains `failed` instead of `passed`, the gate fails.

> **CRITICAL:** `.disabled()` (skipped) tests do NOT count as failures. Only actual test failures block the gate. A test run that shows "passed" with skipped tests is GREEN.

#### Failure Handling (automated, up to 2 attempts per gate)

1. Analyze the failure output
2. Apply the fix
3. Re-run the failing gate
4. If still failing after attempt 2: **stop, report to user, wait for input**

> Never push. Never skip. Never proceed to Phase 5 with a red gate.

---

### Phase 5 -- Push & Open PR

```
/pushup #<N>
```

Auto-runs once both test gates are green.

---

### Phase 6 -- PR Hygiene

Auto-runs:

1. Assign PR to self:
   ```bash
   gh pr edit --add-assignee @me
   ```
2. Post review comment:
   ```bash
   gh pr comment --body "human check"
   ```
3. Surface PR link and **wait for user to merge via GitHub UI**

> **Merge is always manual. Claude never merges.**

---

## Loop Mode (`--loop`)

After all issues in the queue are complete and PRs are open, auto-prompt:

```
Queue complete -- #12 #13 #14 all have open PRs
------------------------------------------------------
Next open issues on the board:
  #15  feat/win-probability-curve
  #16  feat/game-phase-detection
------------------------------------------------------
Continue? /ship #15 #16   [y / n / custom]
```

- `y`: immediately starts next run using the same flags as the current run
- `custom`: user types a new `/ship` invocation
- `n`: exits cleanly

Only triggers if **all** issues in the current run completed successfully.

---

## Abort Conditions

### Auto-handle (no user input needed)

| Condition                        | Action                        |
|----------------------------------|-------------------------------|
| Dirty working tree               | Stash and continue            |
| Test gate failure (attempt 1)    | Fix and retry                 |

### Always stop and wait for user

| Condition                                         |
|---------------------------------------------------|
| `git pull` conflict or failure                    |
| `/implement` exits with no diff or error          |
| Test gates fail after 2 attempts                  |
| Worktree creation fails                           |
| Branch diverged unexpectedly from main            |
| Any command not covered by the permissions block  |

---

## Error Handling

- **No issue number provided**: Stop and show usage: `/ship #42` or `/ship #42 #43 --par`
- **Issue not found**: Skip that issue, report it, continue with remaining queue
- **Issue is closed**: Warn and skip, continue with remaining queue
- **`gh` not installed**: Tell user to install GitHub CLI
- **Not authenticated**: Tell user to run `gh auth login`
- **Git worktree not supported**: Require git 2.5+ for `--par` mode
- **All issues fail**: Stop and report summary

---

## Notes

- `--par` requires **git 2.5+** (worktree support)
- Worktrees share the same `.git` directory -- never run conflicting operations on the same branch from two different worktrees simultaneously
- All worktree directories are created as siblings of the project root and cleaned automatically after their PR opens
- Branch naming is always derived from the GitHub issue title -- keep issue titles clean and descriptive
- Claude never force-pushes, never deletes remote branches, never merges PRs
- In the happy path, the only action required from the user is: reviewing the diff summary (if triggered) and clicking **Merge** on GitHub
- **TDD is mandatory** -- every implementation must follow RED/GREEN/REFACTOR
- **`swift test` is the single source of truth** -- if tests pass, the code ships

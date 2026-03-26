# Push Up

Commit semantically, push, create PR, link issue, and complete tasks.

**Usage:** `/pushup` or `/pushup #123` (where #123 is the issue number)

---

## Instructions

This command automates the end-of-feature workflow. Execute ALL steps in order.

### Step 1: Determine the Issue

If `$ARGUMENTS` contains an issue number (e.g., `#123` or `123`), use that.

Otherwise, detect the issue from:
1. The current branch name (e.g., `feat/issue-123-description` -> issue #123)
2. Recent commit messages mentioning an issue
3. If not found, ask the user: "Which issue does this PR close? (e.g., #123)"

### Step 2: Semantic Commit

1. Run `git status` to see all changes
2. Run `git diff --staged` and `git diff` to understand what changed
3. Run `git log --oneline -5` to match the repo's commit style
4. Stage all relevant files (avoid secrets, .env, credentials)
5. Create a **semantic commit** following Conventional Commits:
   - `feat:` for new features
   - `fix:` for bug fixes
   - `refactor:` for refactoring
   - `test:` for test additions/changes
   - `docs:` for documentation
   - `chore:` for maintenance tasks
6. The commit message body should reference the issue: `Closes #<issue-number>`
7. Use HEREDOC format for the commit message

### Step 3: Push to Remote

1. Check if the current branch tracks a remote branch
2. If no upstream exists, push with `-u`: `git push -u origin <branch-name>`
3. If upstream exists, push normally: `git push`

### Step 4: Create Pull Request

```
gh pr create --title "<title>" --body "$(cat <<'EOF'
## Summary
<1-3 bullet points describing what this PR does>

Closes #<issue-number>

## Test plan
- [ ] `swift test` passes
- [ ] <additional testing checklist items>

Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

### Step 5: Link Issue to PR

The `Closes #<issue-number>` in the PR body automatically links the issue.

### Step 6: Complete Tasks

```bash
gh issue comment <issue-number> --body "Completed in PR #<pr-number>"
gh issue close <issue-number>
```

### Step 7: Summary

```
Push Up Complete!

  Commit:  <commit-hash> (<commit-type>: <short-message>)
  Branch:  <branch-name>
  PR:      #<pr-number> - <pr-title> (<pr-url>)
  Issue:   #<issue-number> - Closed
```

---

## Safety Checks

- NEVER force push
- NEVER push to `main` or `master` without explicit user confirmation
- NEVER commit files matching: `.env*`, `credentials*`, `*.key`, `*.pem`
- Always show the user what will be committed before committing

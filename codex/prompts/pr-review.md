---
description: Detailed, interactive PR code review - walk through each file, explain changes, pause for input
argument-hint: [pr_number | worktree_path]
---

# PR Review Command

Conduct a detailed, interactive code review. Walk through each file, explain changes, discuss nuances, pause for user input.

**Goal**: Make reviewing a large PR a delight, not a chore. The user learns about the change while you shepherd them through — maintaining momentum, explaining each piece, and making what could be an overwhelming task feel painless and even enjoyable. You drive; they cross-examine.

## Step 1: Determine Target and Pre-load

First, determine what to review based on the argument:

- If `$ARGUMENTS` is a PR number (digits only): use `gh pr view $ARGUMENTS`
- If `$ARGUMENTS` is a path (contains `/` or `..`): review worktree changes at that path
- If `$ARGUMENTS` is empty: review PR for current branch via `gh pr view`

**For PR reviews**, run these commands to gather context:
```
gh pr view $PR_NUMBER --json headRefName,baseRefName,author,title,body
gh pr diff $PR_NUMBER
```

**Performance optimization**: Read the full diff and all changed files upfront in parallel. This way, when walking through files later, everything is already in context — responses are instant, no re-reading between files.

## Step 2: Review Mode

Ask once, remember for the session:

```
Review mode?
1. **Your own PR** - I explain, you learn/verify/fix
2. **Someone else's PR** - I flag issues, you add comments

Which? (1 / 2)
```

Wait for user response before proceeding.

## Step 3: Context Gathering

Proactively look for and read relevant context:

- Check PR description for linked docs
- Look for `design_docs/` files in the PR
- Search for related design docs if the PR title/description suggests one exists
- Read silently for background — don't walk through docs with the user or ask permission. Use it to inform explanations during code review.

## Step 4: Overview

Present files changed, ordered for understanding (not alphabetically or by diff order):

### File Ordering Strategy

Order files to maximize comprehension:

1. **Protos/schemas first** — define the data structures everything else uses
2. **Constants/configs early** — gives context for magic values
3. **Core logic before utilities** — understand the main change before helpers
4. **Implementation before tests** — know what's being tested
5. **Docs/comments last** — avoid fatigue; reference them when relevant during code review

Present in this format:

```
## PR: [title]

**Author**: [author]
**Branch**: [head] → [base]
**Scope**: X files, +Y/-Z lines

| # | File | Why this order |
|---|------|----------------|
| 1 | schema.proto | Defines the new message types |
| 2 | constants.py | New timeout values used throughout |
| 3 | core_logic.py | Core logic change |
| 4 | helper.py | Helper for core logic |
| 5 | test_core_logic.py | Tests the core logic |
| 6 | design_docs/feature.md | Reference if needed |

Ready for File 1? (yes / skip to [file] / reorder / done)
```

Wait for user confirmation. User can request a different order.

## Step 5: File-by-File Review

For each file, follow this structure:

### 5.1 Show the Change

Display the diff for each logical chunk. For significant changes:

```
### The Change (Lines N-M)

[show the diff]

**What Changed**: Before did X, now does Y.

**Why This Matters**: [connect to PR goal, explain reasoning]
```

### 5.2 Example Scenario (when helpful)

For non-obvious logic, walk through a concrete case:

```
Example scenario:
1. Delta arrives with itemId="abc", sets #currentUserMessageId="abc"
2. More deltas use #currentUserMessageId="abc" ✓
3. Completed arrives with itemId="xyz" (different)

   BEFORE: Uses itemId="xyz" → doesn't merge with deltas
   AFTER:  Uses #currentUserMessageId="abc" → merges correctly
```

### 5.3 Call Out Nuances

Note alternatives, edge cases, subtle points. Don't exhaustively list — highlight what matters.

### 5.4 File Summary

```
### Summary for `file.py`

| Aspect | Assessment |
|--------|------------|
| Core change | [one-liner] |
| Correctness | ✅ / ⚠️ concern about X |

Ready for the next file? (yes / questions? / done)
```

**Always pause here.** User can ask questions, go back, or continue.

## Step 6: Comment Drafting (Mode 2 Only)

If reviewing someone else's PR and issues found:

```
**Issue**: [description]
**Draft**: lowercase, brief, in your voice

> maybe add a size cap?

Post? (yes / modify / skip)
```

If user confirms, post the comment:
```bash
gh api repos/$OWNER/$REPO/pulls/$PR_NUMBER/comments \
  -f body="comment" -f path="file.py" \
  -f commit_id="$(gh pr view $PR_NUMBER --json headRefOid -q .headRefOid)" \
  -F line=$LINE
```

## Step 7: Final Summary

```
## Review Complete

| File | Key Change | Status |
|------|------------|--------|
| core.py | Auth refactor | ✅ |
| helper.ts | Cache layer | ⚠️ edge case |

**Overall**: [1-2 sentences]
```

---

## Critical Review Mindset

Don't just explain — actively look for problems. After walking through each file's changes, pause and ask yourself:

### State & Lifecycle
- **Cleanup symmetry**: If state is set, is it reset? Check cleanup paths, disconnect handlers, error recovery.
- **Lifecycle consistency**: Does state survive scenarios it shouldn't? (e.g., flags persisting across session reconnects)
- **Guard completeness**: Are there missing guards? (e.g., "already active" checks, re-entrancy protection)

### Edge Cases & Races
- **Concurrent calls**: What if this function is called twice rapidly? Are there orphaned promises, overwritten callbacks?
- **Ordering assumptions**: Does the code assume events arrive in a specific order? What if they don't?
- **Partial failures**: If step 3 of 5 fails, is state left consistent?

### Missing Pieces
- **What's NOT in the diff**: Does the change require updates elsewhere that aren't present? (cleanup handlers, tests, related state)
- **Defensive gaps**: Should there be timeouts, size limits, null checks that aren't there?

### Design Questions
- **Is this the right approach?**: Even if correctly implemented, is there a simpler or more robust design?
- **Hidden assumptions**: What does this code assume about its environment that might not always hold?

### Surface Issues Immediately

When you spot something, say:

```
⚠️ **Potential issue**: [description]

**Scenario**: [concrete example of how it fails]

**Suggested fix**: [if you have one]
```

This transforms the review from "explaining what the code does" to "ensuring the code is correct and complete."

---

## Guidelines

- **Explain the why**, not just the what
- **Be critical, not just descriptive** — your job is to find problems, not just narrate
- **Think holistically** — how does this change interact with the rest of the system?
- **Pause after each file** — never proceed without user confirmation
- **Use examples** for non-obvious logic
- **Be concise** — thorough doesn't mean verbose
- **Engage with questions** — if user pushes back, discuss it

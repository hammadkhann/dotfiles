# Global Defaults

> Rules for AI agents. Be literal. Follow numbered steps. When ambiguous, ask.

---

## Core Principles

1. **Clarity over cleverness** — Write code that's maintainable, not impressive
2. **Explicit over implicit** — No magic values or undocumented behaviour
3. **Composition over inheritance** — Small units that combine
4. **Fail fast, fail loud** — Surface errors at the source
5. **Delete code** — Less code = fewer bugs. Question every addition
6. **Verify, don't assume** — Run it. Test it. Prove it works

---

## Architecture

- Keep entry points (CLI, API routes, handlers) thin — no business logic
- Core/domain logic should be pure, deterministic, and testable — no I/O
- Isolate I/O (filesystem, DB, APIs) from domain logic
- No circular imports — dependencies flow inward (IO → Core, CLI → Core)

```
Features → Services → Core
    ↓          ↓        ↓
   UI      Business   Utilities
           Logic
```

---

## Before Writing Code

1. **Clarify requirements** — Restate the goal. Ask questions if ambiguous
2. **Identify failure modes** — What can go wrong (invalid inputs, missing deps, IO failures)?
3. **Classify work by priority**:
   - **A. Core flow**: Happy path + direct error cases
   - **B. Edge cases**: Unusual but valid scenarios
   - **C. Out of scope**: Document, don't implement
4. **Check existing code** — Is this already solved? Can you extend rather than create?

---

## Implementation Order

1. Write failing test for core happy path
2. Implement minimum code to pass
3. Write failing tests for core error cases
4. Implement error handling
5. Refactor if needed (tests stay green)
6. Add edge case tests only after core is solid

---

## Coding Standards

### Functions
- Do one thing. Name describes *what*, not *how*
- Max 3–4 parameters — beyond that, use a config object/dataclass
- Avoid boolean parameters — they obscure intent at call sites
- Fully type production code

### Comments
- Explain WHY, not WHAT
- Delete comments that restate code
- TODO format: `// TODO: [context] description`

### Error Handling
- Define domain-specific error types per module — no bare `Exception`
- Include context in errors: what failed, with what inputs
- Map external errors at boundaries — don't leak implementation details
- Make transient vs permanent failures distinguishable

---

## Testing

- Add a failing test before fixing a bug (TDD)
- Never delete or skip tests without my approval
- Tests must pass before considering work complete
- Tests are isolated: no shared state, no execution order dependencies
- One behaviour per test, descriptive names
- Test behaviour, not implementation
- Default to unit tests. Integration tests for critical paths and external contracts

### Test Naming
```
test_{unit}_{condition}_{expectedResult}
```

---

## Error Debugging Workflow

1. **Reproduce reliably** — Can you trigger it consistently?
2. **Isolate the scope** — What's the smallest input that fails?
3. **Read the error** — Full stack trace. Identify root cause, exact file/function
4. **Form a hypothesis** — One specific guess about the cause
5. **Test the hypothesis** — Add logging, write a test, or inspect state
6. **Fix and verify** — Change ONE thing. Confirm it's fixed
7. **Add regression test** — Ensure it can't silently break again

### Don't
- Change multiple things at once
- Assume you know the cause without evidence
- Delete error handling to "simplify"
- Fix symptoms instead of root causes
- No scope creep — propose discrete, minimal fix tasks and wait for my approval

---

## Refactoring

### When to Refactor
- Before adding a feature (make the change easy, then make the easy change)
- After tests pass (not during implementation)
- When you touch code that's hard to understand

### When NOT to Refactor
- While debugging
- Without test coverage
- Unrelated to the current task — no "while I'm here" changes
- Do NOT perform wide refactors, change public interfaces, or restructure architecture without my explicit instruction

### How to Refactor
1. Ensure tests exist and pass
2. Make one structural change
3. Run tests
4. Repeat

Never change behaviour and structure in the same step.

---

## Dependencies

1. Can we solve this in <100 lines ourselves?
2. Is it actively maintained? What's the license?
3. What's the transitive dependency cost?
4. Do not add dependencies without my approval
5. Wrap third-party APIs behind interfaces you control
6. Pin versions explicitly

---

## Git Hygiene

- One logical change per commit
- Present tense, imperative: "Add caching" not "Added caching"
- First line ≤50 chars, blank line, then details
- Feature: `feature/{description}`, Fix: `fix/{description}`
- Delete branches after merge

---

## Before Submitting

- [ ] All tests pass
- [ ] No commented-out code
- [ ] No TODO without context
- [ ] Error messages are actionable
- [ ] No secrets, credentials, or hardcoded environment-specific values
- [ ] Formatting/linting passes

---

## Token Efficiency

- Never re-read files you just wrote or edited — you know the contents
- Never re-run commands to "verify" unless the outcome was uncertain
- Don't echo back large blocks of code unless asked
- Batch related edits into single operations
- Skip confirmations like "I'll continue..." — just do it
- If a task needs 1 tool call, don't use 3. Plan before acting
- Do not summarize what you just did unless the result is ambiguous

---

## When Uncertain

1. **Check existing patterns** — How does the codebase solve similar problems?
2. **Ask** — Ambiguity is expensive. Clarify before implementing
3. **Smallest change** — Prefer minimal diff that solves the problem
4. **Reversibility** — Prefer changes easy to undo
5. **Prove it** — Run the code. Pass the tests. Don't guess

---

## User Preferences

- Default all shell command examples to Fish shell syntax unless explicitly asked for another shell

## React Design References

- Use https://reactbits.dev/ as a reference for React component patterns, animations, and design primitives when building frontend UIs

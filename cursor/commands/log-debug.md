---
description: Instrument → repro → read log → fix. Multiple-hypothesis log-driven debugging.
argument-hint: "[describe the bug or leave blank to use current context]"
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# Log-Driven Debugging — Multiple Hypotheses

You are in systematic debugging mode. The goal is to instrument the code for several competing hypotheses simultaneously, reproduce the bug, read the log, then either fix the root cause or add a second round of targeted logs.

## Bug to investigate

$ARGUMENTS

If no argument was given, ask the user to describe the bug before proceeding.

---

## Phase 1 — Form multiple hypotheses

Before touching any code, read the relevant files and reason out loud:

1. List **3–5 distinct, falsifiable hypotheses** for what could cause this bug. Number them H1, H2, H3, … Keep each to one sentence.
2. For each hypothesis, identify **exactly what you would see in a log** if it were true.
3. Pick the log file path: `~/Desktop/debug-session.log` (create the directory if needed).

Example hypotheses format:
- H1: The config value is None because the env var is not set at call time.
- H2: The retry loop exits early because the condition is evaluated before the state update.
- H3: A cached result from a previous call is being returned instead of a fresh one.

---

## Phase 2 — Instrument for all hypotheses at once

Add temporary logging **for every hypothesis simultaneously** — do not pick just one. Use the language's standard logger or print statements that write to the log file. Each log line must be prefixed with its hypothesis tag so you can filter later.

**Python pattern:**
```python
import logging, os
_dbg = logging.getLogger("DEBUG_SESSION")
if not _dbg.handlers:
    _h = logging.FileHandler(os.path.expanduser("~/Desktop/debug-session.log"), mode="a")
    _h.setFormatter(logging.Formatter("%(asctime)s [%(levelname)s] %(message)s"))
    _dbg.addHandler(_h)
    _dbg.setLevel(logging.DEBUG)

# H1 probe
_dbg.debug("[H1] config_value=%r at entry", config_value)

# H2 probe  
_dbg.debug("[H2] condition=%r state=%r before loop exit check", condition, state)

# H3 probe
_dbg.debug("[H3] cache_hit=%r key=%r", key in cache, key)
```

**TypeScript/Node pattern:**
```typescript
import fs from "fs";
const LOG = (tag: string, msg: string, data?: unknown) => {
  const line = `${new Date().toISOString()} [${tag}] ${msg} ${data !== undefined ? JSON.stringify(data) : ""}\n`;
  fs.appendFileSync(`${process.env.HOME}/Desktop/debug-session.log`, line);
};

LOG("H1", "config_value at entry", configValue);
LOG("H2", "condition before loop exit", { condition, state });
```

Place probes at the **specific locations** that would distinguish each hypothesis. Be surgical — a probe in the wrong place proves nothing.

---

## Phase 3 — Reproduce

Run whatever command reproduces the bug. Capture the reproduction steps as a shell command or explain the manual steps taken.

After running: say **"Reproduction complete — reading log."**

---

## Phase 4 — Analyze the log

Read `~/Desktop/debug-session.log` and report:

1. Which hypothesis tags appear in the log?
2. What do the values show? Does any hypothesis have confirming evidence?
3. Which hypotheses are now **ruled out** based on the log values?
4. What is the **most likely root cause** given what you see?

Use this decision tree:

```
Root cause identified with high confidence?
  YES → go to Phase 5 (fix)
  NO  → go to Phase 4b (add targeted second-round logs)
```

### Phase 4b — Second-round instrumentation (if needed)

If the first round of logs was inconclusive:
- Identify which hypothesis is still alive
- Add 2–3 more targeted probes deeper in the call stack
- Clear the log file (`> ~/Desktop/debug-session.log`) and re-run reproduction
- Re-analyze

---

## Phase 5 — Fix

Once the root cause is identified:

1. State the root cause clearly: *"Root cause: [H2] — the condition is evaluated before the state update on line X"*
2. Implement the fix
3. **Remove all debug logging** you added (grep for `_dbg.debug`, `LOG(`, `debug-session` etc. and clean up)
4. Run the reproduction steps one more time to confirm the bug is gone
5. Summarize: what the bug was, what the fix was, which hypothesis was correct

---

## Rules

- Never remove probe logging before reading the log — even if you think you found the root cause during instrumentation
- Never commit to a single hypothesis before seeing log data
- The log file is append-mode — clear it before each reproduction run to avoid stale data confusing the analysis
- If the bug requires a specific environment to reproduce, note what env vars / data / state is needed before instrumenting
- Always clean up the debug logging at the end — leave no `_dbg.debug` lines in production code

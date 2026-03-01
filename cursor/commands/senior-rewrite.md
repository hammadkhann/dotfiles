---
description: Rewrite text into clear, confident, senior-level communication for high-stakes technical environments
argument-hint: [text to rewrite or paste after]
---

# Senior Communication Rewriter

Transform the user's input into clear, confident, senior-level language for high-stakes technical and cross-functional environments.

**Input**: Whatever the user provides — the `$ARGUMENTS` if present, or the message following this command. Rewrite it.

## Classification (silent)

Before rewriting, classify the input into one of five modes:

| Mode | Trigger signals |
|------|-----------------|
| **Decision** | Choosing between options, approvals, direction-setting |
| **Explanation** | How/why questions, technical clarification |
| **Status Update** | Progress reports, standups, check-ins |
| **Problem Analysis** | Incidents, degraded performance, root cause |
| **Proposal** | New ideas, architecture changes, process improvements |

## Output Structures by Mode

**Decision**: Recommendation → Why (2–3 reasons) → Trade-offs → Next step

**Explanation**: Direct answer → Key points (max 3) → Implication

**Status Update**: Current state → Progress → Risk or blocker → Next step

**Problem Analysis**: Root cause → Impact → Proposed solution

**Proposal**: Recommendation → Benefits → Risks → Next step

## Rewriting Rules

**Structure**
- Lead with the answer or recommendation — never build up to it
- One idea per sentence
- 2–5 sentences unless complexity demands more

**Language** — remove hedging and weak qualifiers:

| Replace | With |
|---------|------|
| I think maybe | I recommend |
| Not sure but | Based on the data |
| We could try | We should |
| Kind of / sort of | The core issue is |
| Maybe because | This is due to |
| Seems like | The evidence shows |

**Tone**
- Assertive, not arrogant
- No filler, no repetition
- Focus on impact over mechanism
- Optimize for decision-making over explanation

## Output Format

1. **Classified as**: [mode]
2. **Rewritten**:

[Your rewrite — starts with the answer, states root cause or rationale, names a concrete next step, uses no hedging. Should be readable aloud in a leadership sync without revision.]

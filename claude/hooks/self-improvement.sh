#!/bin/bash
# Self-improvement injection hook
# After 8+ tool calls, nudge Claude to suggest one optimization hint
INPUT=$(cat)
TRANSCRIPT=$(echo "$INPUT" | jq -r '.transcript_path')

# Count tool_use entries in the transcript
TOOL_CALLS=$(grep -c '"tool_use"' "$TRANSCRIPT" 2>/dev/null)
TOOL_CALLS=${TOOL_CALLS:-0}

if [ "$TOOL_CALLS" -ge 8 ]; then
  echo "SessionStart hook additional context: This conversation has had ${TOOL_CALLS} tool calls. Before responding, consider: is there a reusable skill, memory pattern, or workflow fix that would prevent repetitive work in future sessions? If so, append ONE optimization hint (one sentence) at the end of your response. Skip if this was purely exploratory."
fi
exit 0

#!/bin/bash
# Conditional prompt linter hook
# If user prompt exceeds 50 words, ask Claude to verify the desired outcome is clear
INPUT=$(cat)
PROMPT=$(echo "$INPUT" | jq -r '.prompt')

WORD_COUNT=$(echo "$PROMPT" | wc -w | tr -d ' ')

if [ "$WORD_COUNT" -gt 50 ]; then
  echo "UserPromptSubmit hook additional context: This prompt is ${WORD_COUNT} words. Before proceeding, verify: is the desired outcome clearly stated? If not, ask the user to clarify the expected result before starting work."
fi
exit 0

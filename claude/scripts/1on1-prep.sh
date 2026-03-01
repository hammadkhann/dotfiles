#!/bin/bash
# Automated weekly log generator — runs Claude Code headless to produce promo-ready weekly logs
# Scheduled via launchd on Monday mornings

set -euo pipefail

OUTPUT_DIR="$HOME/1on1"
DATE=$(date +%Y-%m-%d)
LOG_FILE="/tmp/weekly-log-${DATE}.log"

mkdir -p "$OUTPUT_DIR"

echo "[$(date)] Starting weekly log generation..." >> "$LOG_FILE"

claude -p "Search Glean for my activity from the past week:
1. Slack messages (app: slack, from: me, updated: past_week)
2. Confluence pages (app: confluence, from: me, updated: past_week)
3. Jira tickets (app: jira, from: me, updated: past_week)

Compile a weekly accomplishment log with these sections:
- **Delivery**: Features shipped, PRs merged, tickets closed. Include Jira IDs, links, mark shipped items.
- **Technical Leadership**: Self-initiated work (code reviews, design docs, architectural improvements). Flag unassigned work.
- **Collaboration**: PR reviews, docs shared, feedback given, cross-team work.
- **Cross-Org Impact**: Slack threads helping people outside the team, community contributions.

Rules: every item needs links where available, factual and concise, no fluff, no talking points, no narrative. Order by impact within each section.

Save to ${OUTPUT_DIR}/${DATE}-weekly-log.md" \
  >> "$LOG_FILE" 2>&1

EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    echo "[$(date)] Weekly log generated: ${OUTPUT_DIR}/${DATE}-weekly-log.md" >> "$LOG_FILE"
    osascript -e "display notification \"Weekly log ready at ${OUTPUT_DIR}/${DATE}-weekly-log.md\" with title \"Weekly Log\" sound name \"Glass\""
else
    echo "[$(date)] Weekly log failed with exit code ${EXIT_CODE}" >> "$LOG_FILE"
    osascript -e "display notification \"Weekly log generation failed. Check ${LOG_FILE}\" with title \"Weekly Log Error\" sound name \"Basso\""
fi

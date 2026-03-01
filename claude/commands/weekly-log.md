# Weekly Log Generator

Generate a weekly accomplishment log for promotion evidence and yearly reviews.

## Instructions

Search Glean for the current user's activity from the past week across three sources, then compile into a structured weekly log markdown file.

### Step 1: Gather Data

Run these three Glean searches in parallel:

1. **Slack**: `mcp__glean_default__search` with `query: "*"`, `from: "me"`, `updated: "past_week"`, `app: "slack"`
2. **Confluence**: `mcp__glean_default__search` with `query: "*"`, `from: "me"`, `updated: "past_week"`, `app: "confluence"`
3. **Jira**: `mcp__glean_default__search` with `query: "*"`, `from: "me"`, `updated: "past_week"`, `app: "jira"`

### Step 2: Analyze and Categorize

From the raw results, classify every item into one of these promo-aligned categories:

- **Delivery**: Features shipped, PRs merged, tickets closed, bugs fixed. Include Jira IDs and status.
- **Technical Leadership**: Self-initiated work (code reviews, design docs, architectural improvements, tooling recommendations). Flag items that were not assigned.
- **Collaboration**: PR reviews given, docs shared with teammates, feedback provided, cross-team alignment.
- **Cross-Org Impact**: Slack threads helping people outside your team, community contributions, knowledge sharing in public channels.

### Step 3: Generate the Weekly Log

Write a markdown file to `/Users/muhakhan/expedia_projects/1on1/<today's date>-weekly-log.md` with this structure:

```markdown
# Weekly Log — <month day-day>, <year>

## Delivery
- **<Item> (<Jira ID>)**: What was done, outcome, links. **Shipped** or status.
...

## Technical Leadership
- **<Item>**: What was done, why it matters, links. Flag self-initiated work.
...

## Collaboration
- PR reviews, docs shared, feedback given, cross-team work
...

## Cross-Org Impact
- Slack activity in public channels, helping others outside the team
...
```

Rules:
- Every item should have links (Jira, Confluence, PR URLs) where available
- Mark shipped items with **Shipped.**
- Flag self-initiated work explicitly ("Not assigned — identified the need independently")
- Keep entries factual and concise — no fluff, no talking points, no narrative paragraphs
- Order items within each section by impact (highest first)

### Step 4: Confirm

After writing the file, print the file path and a one-line summary of item counts per category.

$ARGUMENTS

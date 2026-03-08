# Notion Page Templates

All four pages follow the same top-level pattern:
1. A **Contents toggle block** at the very top — links to each major section
2. The page content below

The Contents toggle must be updated every time a new section is added to the page.

---

## Page 1: Plan

Lightweight human-readable summary. Not a mirror of plan.md — just enough to orient quickly.

```
[Contents toggle]
  - Overview
  - Tech Stack
  - Features
  - Deployment
  - Constraints

# Plan

## Overview
[Project name + one paragraph: problem, solution, target user]

## Tech Stack
- [Technology] — [one-line rationale]

## Features

### Must-Have
- Feature name — one line description

### Nice-to-Have  
- Feature name — one line description

## Deployment
[One paragraph or "Local only"]

## Constraints
[Bullet list or "None"]
```

---

## Page 2: Dev Log

Append-only. Newest entry at top. Each entry is one session or one atomic feature.

```
[Contents toggle]
  - [DATE] — [Entry name]   ← updated each session

# Dev Log

## [YYYY-MM-DD] — [Feature or Session Name]
**What was built:** [One to three sentences. Be specific.]
**Decisions made:** [Any mid-build decisions and the rationale. Omit if none.]
**Blockers:** [What got stuck or deferred. Omit if none.]
```

New entries are always prepended (newest at top). The Contents toggle link list is updated to include the new entry at the top.

---

## Page 3: Next Up

Fully rewritten at the end of each session. Short and actionable.

```
[Contents toggle]
  - Current Priority
  - Backlog

# Next Up

## Current Priority
- [Task — specific enough to act on immediately]
- [Task]

## Backlog
- [Task]
- [Task]
```

When rewriting: move completed items out entirely, promote backlog items to Current Priority as appropriate, add new items from the session's discoveries.

---

## Page 4: Issues

Each issue is one entry. Status is updated in place (not append-only for resolved issues).

```
[Contents toggle]
  - [DATE] — [Issue title] — OPEN     ← updated as statuses change
  - [DATE] — [Issue title] — RESOLVED

# Issues

## [YYYY-MM-DD] — [Issue Title] — OPEN
**Description:** [What the issue is.]
**Impact:** [What it breaks or blocks.]
**Resolution:** Pending

---

## [YYYY-MM-DD] — [Issue Title] — RESOLVED
**Description:** [What the issue was.]
**Impact:** [What it broke or blocked.]
**Resolution:** [What fixed it and when.]
```

When resolving an issue: update the status in the heading from OPEN to RESOLVED, fill in the Resolution field, and update the Contents toggle to reflect the new status.

---

## Contents toggle update rules

- Contents toggle always reflects current page state
- Links use Notion block references (block IDs) — read the page after writing to get the new block ID, then update the toggle
- Order in the toggle mirrors order in the page (Dev Log: newest first; Issues: open first, then resolved)
- Toggle text format: `[DATE] — [Name] — [STATUS]` for Issues, `[DATE] — [Name]` for Dev Log, section names only for Plan and Next Up

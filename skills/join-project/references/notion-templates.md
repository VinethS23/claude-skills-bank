# Notion Page Templates

All four pages follow the same top-level pattern:
1. A **Contents toggle block** at the very top — links to each major section
2. The page content below

The Contents toggle must be updated every time a new section is added to the page.

---

## Page 1: Plan

Human-readable project overview and development roadmap. Not a mirror of plan.md — written for the user to orient quickly and understand where the project is heading.

Key principles:
- Early phases must be specific and actionable — the user should know exactly what gets built first
- Later phases can be directional — acknowledge that detail will be added as the project evolves
- Every method, function, or component mentioned must include a one-line description of what it does
- The user should be able to read this page and understand the full arc of the project, even if later stages are loosely defined
- Include **Fragile Areas** section if any were identified at onboarding — these shape how cautiously work proceeds

```
[Contents toggle]
  - Overview
  - Tech Stack
  - Features
  - Development Plan
  - Fragile Areas      ← only if identified at onboarding
  - Deployment
  - Constraints

# Plan

## Overview
[Project name + one paragraph: problem, solution, target user]

## Tech Stack
- **[Technology]** — [one-line rationale]

## Features

### Must-Have
- **Feature name** — one line description of what it does

### Nice-to-Have
- **Feature name** — one line description of what it does

## Development Plan

A phased roadmap derived from plan.md. Early phases are detailed and specific. Later phases are directional — they will be broken down further as earlier phases complete.

### Phase 1 — [Name] ← most detailed
- [ ] **[file or component]** — one line on what this file is responsible for overall
  - `functionName()` — plain English: what does calling this function do? E.g. "opens a DB connection for a request and closes it when done"
  - `functionName()` — what does calling this do?
- [ ] **[file or component]** — what it is responsible for
  - `functionName()` — what does calling this do?
- [ ] Verification: [how you'll know this phase is done]

### Phase 2 — [Name] ← specific but less granular than Phase 1
- [ ] [Task — specific enough to act on]
- [ ] [Task]
- [ ] Verification: [observable outcome]

### Phase 3+ — [Name] ← directional, detail to be added
Direction: [One paragraph on what this phase covers and why it comes after Phase 2]
Likely includes: [bullet list of probable tasks — acknowledged as subject to change]

## Fragile Areas
[Only include this section if fragile/sensitive areas were identified at onboarding]
- **[Area or file]** — [why it's sensitive and what to watch out for]

## Deployment
[One paragraph or "Local only"]

## Constraints
[Bullet list or "None"]
```

---

## Page 2: Dev Log

Append-only. Newest entry at top. Each entry is one session or one atomic feature. All fields use bullet points.

```
[Contents toggle]
  - [DATE] — [Entry name]   ← updated each session

# Dev Log

## [YYYY-MM-DD] — [Feature or Session Name]
**What was built:**
- [Specific thing built or changed]
- [Specific thing built or changed]

**Decisions made:**
- [Decision and rationale]
(Omit section if none)

**Blockers:**
- [What got stuck or deferred]
(Omit section if none)
```

New entries are always prepended (newest at top). The Contents toggle link list is updated to include the new entry at the top.

### Onboarding snapshot entry (join-project only)

The first Dev Log entry written during join-project onboarding uses this format instead of the standard entry — it describes the project state at the time of joining, not a build session:

```
## [YYYY-MM-DD] — Project Onboarding Snapshot

**State at onboarding:**
- [What was already built — features, infrastructure, what's working]
- [Where the project stood — phase progress, recent activity]

**In progress:**
- [What was actively being worked on when joining]
(Omit if nothing in progress)

**Context inherited:**
- [Key decisions already made, constraints, non-obvious context]
(Omit if none)
```

---

## Page 3: Next Up

Fully rewritten at the end of each session. Current Priority mirrors the active phase tasks from plan.md — same granularity, same function descriptions. Backlog covers future phase tasks directionally.

```
[Contents toggle]
  - Current Priority
  - Backlog
  - Blocked / Pending   ← only include if there are blocked items

# Next Up

## Current Priority
- **[file or component]** — [what this file is responsible for overall]
  - `functionName()` — [plain English: what does calling this do?]
  - `functionName()` — [what does calling this do?]
- **[file or component]** — [what it is responsible for]
  - `functionName()` — [what does calling this do?]
- Verification: [how you'll know this is done]

## Backlog
- **Phase 2 — [Phase name]:** [one-line summary of what this phase covers]
- **Phase 3+ — [Phase name]:** [directional description]

## Blocked / Pending
- [area] — waiting on: [what]     ← only include this section if there are open team questions or blockers
```

When rewriting: reflect the current phase tasks with full granularity in Current Priority; summarise future phases as single lines in Backlog. Move completed items out entirely.

---

## Page 4: Issues

Each issue is one entry. Status is updated in place (not append-only for resolved issues). All fields use bullet points.

```
[Contents toggle]
  - [DATE] — [Issue title] — OPEN     ← updated as statuses change
  - [DATE] — [Issue title] — RESOLVED

# Issues

## [YYYY-MM-DD] — [Issue Title] — OPEN
**Description:**
- [What the issue is]

**Impact:**
- [What it breaks or blocks]

**Resolution:** Pending

---

## [YYYY-MM-DD] — [Issue Title] — RESOLVED
**Description:**
- [What the issue was]

**Impact:**
- [What it broke or blocked]

**Resolution:**
- [What fixed it and when]
```

When resolving an issue: update the status in the heading from OPEN to RESOLVED, fill in the Resolution field, and update the Contents toggle to reflect the new status.

---

## Contents toggle update rules

- Contents toggle always reflects current page state
- Links use Notion block references (block IDs) — read the page after writing to get the new block ID, then update the toggle
- Order in the toggle mirrors order in the page (Dev Log: newest first; Issues: open first, then resolved)
- Toggle text format: `[DATE] — [Name] — [STATUS]` for Issues, `[DATE] — [Name]` for Dev Log, section names only for Plan and Next Up

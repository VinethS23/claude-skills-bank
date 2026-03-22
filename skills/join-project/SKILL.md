# Skill: join-project

Read an existing codebase deeply, then walk the user through it — what's set up, how it's structured, what it took to get here, and what's available to do next. Then establish the same `plan.md` + Notion workspace dev framework used by `new-project`.

This skill serves two people simultaneously: **Claude** (gaining a working model of the project) and **the user** (gaining or refreshing their understanding of it). Claude leads the conversation as a guide, not a questioner.

---

## Philosophy

- **Claude briefs, user corrects** — Claude reads everything first, then presents what it found. The user's role is to confirm, correct, and fill gaps — not to be the source of truth.
- **Caution over speed** — joining an existing project, especially a team one, carries risk. A wrong assumption costs more than a slow onboarding.
- **Depth of understanding matters** — the better the shared understanding at onboarding, the lower the chance of mistakes later.
- **Surface uncertainty explicitly** — unknowns should be named and logged, not glossed over. Flag them rather than inferring silently.
- **Adopt, don't override** — the repo's existing conventions are the standard. Do not impose defaults.
- **Atomic Notion entries** — short, focused, one session per entry.
- Run everything in Claude Code terminal
- Narrate before running any irreversible command

---

## Phase 1 — Pre-flight checks

```bash
gh auth status                    # stop if GitHub CLI not installed or not authenticated
git status                        # confirm we're inside a git repo — stop if not
git remote get-url origin         # identify repo name; fall back to folder name if no remote
```

Check Notion MCP is connected. If any check fails, surface the error clearly and stop.

---

## Phase 2 — Codebase audit

Read silently — no user interaction. Take the time needed; depth here reduces risk later.

**Read in order:**
1. `README.md` — overview, setup instructions, known gotchas
2. `plan.md` — if exists, primary source of truth for stack/architecture/decisions
3. `package.json` / `pyproject.toml` / `go.mod` / `Cargo.toml` / equivalent — stack, dependencies, scripts
4. Folder structure (at least 2 levels deep) — architecture, naming conventions, module boundaries
5. CI config (`.github/workflows/`, `Makefile`, `Dockerfile`) — deployment model, test approach, environment setup
6. Key source files — entry points, core modules, data models, API routes (enough to understand the shape of the system)
7. `git log --oneline -20` — recent activity, who's working on what, what changed last
8. `git branch -r` — open branches, in-flight work not yet merged
9. `grep -r "TODO\|FIXME\|HACK" --include="*.ts" --include="*.js" --include="*.py" -n` — adjust extensions to match stack
10. `.env.example` or config files — environment dependencies

**Extract and flag:**
- Tech stack — mark each as **confident** (explicit in config) or **inferred** (implied by structure/usage)
- Architecture pattern and module boundaries
- Features built (infer from routes, components, models)
- Features in progress (incomplete files, open branches, recent commits)
- Conventions in use: naming, folder structure, branching, commit style — note these to adopt
- Known issues (README warnings, TODOs, FIXMEs)
- **Gaps and uncertainties** — anything unclear, flagged explicitly for the discovery conversation

---

## Phase 3 — Project walkthrough conversation

Claude leads this conversation as a guide. The goal is shared understanding — Claude presents what it found section by section, the user corrects or adds. This is a briefing, not an interview.

**Structure the conversation in this order:**

### 1. What this project is
Open with a plain-English summary of what the project does and who it's for — inferred from the codebase. Invite correction.
> "From what I've read, this looks like [what it is and what problem it solves]. Does that match how you'd describe it?"

### 2. How it's set up
Walk through the tech stack and architecture: what's chosen, why (if visible from comments or config), and how the pieces connect. Cover:
- Languages, frameworks, key libraries — and what role each plays
- Folder structure and what lives where
- Environment setup (what's needed to run it locally, from `.env.example`, README, scripts)
- CI/CD pipeline if present

Present this as a brief, not a list dump. Explain it in a way that would make sense to someone new to the project.

### 3. What's been built
Walk through the features and functionality that exist. Infer from routes, components, models, recent commits. Group logically, not by file.
> "Here's what I can see is working or in place: [list with brief explanation of each]. Anything I've missed or described wrong?"

### 4. What it took to get here
Draw on the git log and branch history to give a sense of the project's journey — major milestones, recent focus areas, any visible pivots or rewrites. This gives the user (especially if new to the project) a sense of why things are the way they are.
> "Looking at the commit history, it seems like [rough arc of how the project evolved]. Does that track?"

### 5. What's in progress
Identify anything partially built — open branches, incomplete files, TODO/FIXME comments, stale PRs. Be specific about where things are.

### 6. What's available to do next
Synthesise what comes next based on everything read — incomplete features, TODOs, what the plan.md or README hints at, anything implied by the current trajectory. Present these as options, not a fixed list.
> "Based on everything I've seen, here's what looks available to tackle next: [options with brief context on each]. Does this match your priorities, or is there something else driving what's next?"

### 7. Gaps and clarifications
For each uncertainty flagged in the audit, ask directly. Be specific — don't ask open-ended questions about things Claude should be able to infer.
> "A few things I wasn't able to determine from the code: [specific questions]"

### 8. Context Claude can't read
Close by asking for anything the codebase doesn't surface:
> "Anything important I should know that isn't visible in the code — decisions made, constraints, context about the team or where this is headed?"

**Finally, ask the two setup questions:**
- Is this a solo project or a team? If team — size, roles, process (PRs, reviews, branching)?
- Does a Notion workspace already exist for this project?

**Tone:** Conversational, not a checklist. Aim for the feeling of a senior engineer walking someone through a codebase they know well — clear, honest about what's uncertain, and focused on what the person actually needs to understand to contribute.

---

## Phase 4 — Structured confirmation

Write audit + discovery output to `/tmp/<repo-name>/join-draft.md`.

```
# DRAFT — Join Project: <Project Name>
> Review and edit this file, then tell Claude to proceed.

## Project State at Onboarding
[Date: YYYY-MM-DD]

## Overview
[2 sentences — what this project is]

## Team
[Solo / Team — if team: size, roles, lead if known]

## Tech Stack
[layer: technology — confident or inferred]

## Conventions to Follow
[naming, branching, commit style, PR process — inferred from repo + confirmed]

## What's Built
[feature list — inferred + confirmed]

## In Progress
[what's actively being worked on, and by whom if team]

## What's Next
[confirmed next priorities]

## Fragile / Sensitive Areas
[parts of the codebase to be careful with — owned areas, complex logic, known instability]

## Known Issues & Tech Debt
[bugs, TODOs, FIXMEs, things flagged by team]

## Constraints & Context
[architectural decisions, non-obvious constraints, inherited context]

## Open Questions — For Team
[things that need clarification from others before Claude should touch those areas]

## Notion Workspace
[ ] Exists — URL: 
[ ] To be created fresh
```

Tell user: "This is at `/tmp/<repo-name>/join-draft.md` — open it, edit directly or give corrections here. Pay particular attention to **Fragile Areas** and **Open Questions** — these shape how cautiously I'll work."

Once confirmed, this draft is the source of truth — do not rewrite or reinterpret.

---

## Phase 5 — Team questions file (team projects only)

If the project is a team project and there are items in "Open Questions — For Team", generate `QUESTIONS.md` at the repo root:

```markdown
# Questions for the Team
> Generated by Claude during project onboarding on [YYYY-MM-DD].
> Review with the team and update `plan.md` with answers before Claude works on related areas.

## [Category — e.g. Auth, Data Model, Deployment, Conventions]
- **Q:** [specific question]
  **Context:** [why this matters / what area it affects]
  **Answer:** _pending_
```

- Group questions by area
- Include context for each — so a team member reading cold understands why it's being asked
- Note which areas Claude will hold off on until answered
- Do **not** commit this file — leave it unstaged for the user to share as they see fit

Tell user: "`QUESTIONS.md` is at the repo root — share with the team and fill in answers before we touch those areas."

---

## Phase 6 — plan.md

**Structure** (always use this layout):

```markdown
# Project Name

## Overview
[2 sentences]

## Problem
[one paragraph]

## Tech Stack
[layer: technology — rationale]

## Architecture
[one paragraph, key decisions]

## Features
### Must-Have
[name: description + implementation note]
### Nice-to-Have
[name: description]

## Data Model
## API / Integration Contracts
## Auth
## Deployment
## Constraints

## Development Phases

### Phase 1 — [Name] ← most detailed
- [ ] **[file or component]** — one line on what this file is responsible for overall
  - `functionName()` — plain English: what does calling this function do? Focus on behaviour, not implementation
  - `functionName()` — what does calling this do?
- [ ] **[file or component]** — what it is responsible for
  - `functionName()` — what does calling this do?
- [ ] Verification: [how you'll know this phase is done — e.g. "running X command produces Y output"]

### Phase 2 — [Name] ← specific but less granular than Phase 1
- [ ] [Task — specific enough to act on]
- [ ] [Task]
- [ ] Verification: [observable outcome]

### Phase 3+ — [Name] ← directional, detail to be added
Direction: [One paragraph on what this phase covers and why it comes after Phase 2]
Likely includes: [bullet list of probable tasks — acknowledged as subject to change]

## Open Questions
```

**If `plan.md` exists:**
- Compare with join-draft.md
- If roughly accurate: leave it untouched, note any gaps to the user
- If materially out of date (missing features, wrong stack, stale phases): do **not** edit directly — follow the team PR flow below, narrating what would change and why

**If `plan.md` does not exist:**
- Generate from join-draft.md using the structure above
- Follow the PR flow below

**Solo project — commit directly:**
```bash
git add plan.md
git commit -m "docs: add plan.md via join-project onboarding"
git push
```

**Team project — always use a PR:**
```bash
git checkout -b docs/onboarding-plan
git add plan.md
git commit -m "docs: add plan.md via join-project onboarding"
git push -u origin docs/onboarding-plan
gh pr create --title "docs: onboarding plan.md" --body "Claude's understanding of the project at onboarding. Please review and correct anything inaccurate before merging."
```

Tell user: "PR raised — share it with the team to review Claude's understanding before it's merged. Correct anything wrong in the PR and it becomes the agreed source of truth."

Do **not** push plan.md changes directly to main on a team project under any circumstances.

---

## Phase 7 — Notion workspace

### Page structures

All pages have a **Contents toggle at the top** with anchor links to each section. Update the Contents toggle every time a page is written (read page → write → read again to confirm block IDs are correct). Never write blind.

Read `references/notion-templates.md` for the exact content structure of each page. Summary:

**Plan** — human-readable project overview and development roadmap. Sections: Overview, Tech Stack, Features (Must-Have/Nice-to-Have), Development Plan (phased, with Phase 1 at full file/function granularity), Fragile Areas (if any), Deployment, Constraints.

**Dev Log** — append-only, newest at top. All fields use bullet points. Onboarding snapshot entry uses join-project-specific field names (State at onboarding / In progress / Context inherited) — see templates for format.

**Next Up** — fully rewritten each session. Current Priority mirrors active phase tasks from plan.md at full granularity (file/function descriptions). Backlog summarises future phases as one-liners. Blocked/Pending section only if open team questions exist.

**Issues** — updated in place. All fields use bullet points (Description / Impact / Resolution).

### If Notion workspace exists (user provided link):
1. Fetch the page — check which child pages exist (Plan, Dev Log, Next Up, Issues)
2. For each missing page: create using the structure above
3. For existing pages: do not overwrite — leave as-is unless user explicitly asks to sync
4. Append onboarding snapshot entry to Dev Log

### If no Notion workspace:
1. Find "Projects" page in Notion
2. Create project parent page under it
3. Create all 4 child pages: Plan, Dev Log, Next Up, Issues
4. Seed from join-draft.md using rules below

### Seeding rules

- **Plan** — from join-draft.md: Overview, Tech Stack, What's Built + What's Next as features. Development Plan section from plan.md phases (translate directly — same phase names, same tasks, same function descriptions). Include Fragile Areas section if any were identified.
- **Dev Log** — seed with onboarding snapshot entry (see `references/notion-templates.md` for format). This is not a fresh start — it's a point-in-time snapshot of what existed when joining.
- **Next Up** — Current Priority mirrors the active phase tasks from plan.md at full granularity (files + function descriptions, same level of detail as the Development Plan). Backlog summarises future phases as one-liners (`**Phase N — [name]:** [one-line summary]`). Add Blocked/Pending section only if there are open team questions.
- **Issues** — from "Known Issues & Tech Debt" in join-draft.md; leave empty with structure only if none.

---

## Behaviour rules

- Narrate before running any irreversible command
- Never ask questions that can be answered by reading the repo
- Propose; don't ask open-ended questions — but follow up when something is genuinely unclear
- **Adopt existing conventions** — match what's already in the repo (branching, naming, commit style). Do not impose defaults.
- **Do not touch flagged fragile areas** without explicit instruction — surface the dependency and ask first
- **Do not work on areas with open team questions** — flag them as blocked until `QUESTIONS.md` is resolved

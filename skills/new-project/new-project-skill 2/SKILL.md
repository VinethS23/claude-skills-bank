---
name: new-project
description: Full project bootstrap skill. Use this whenever the user wants to start a new project, create a new app, set up a new codebase, or says anything like "let's start a new project", "I want to build X from scratch", "spin up a new repo". Runs discovery conversation, creates git repo on GitHub, writes plan.md, and sets up Notion workspace with Plan, Dev Log, Next Up, and Issues pages.
---

# New Project Setup Skill

Bootstrap a new project end-to-end: GitHub repo creation, requirements discovery, plan.md, and Notion workspace setup.

**Target time:** ~15 minutes total. Discovery <10 min, confirmation <2 min, setup <3 min.

---

## Phase 1: Pre-flight checks

Before anything else, verify tools are available:

```bash
gh auth status
```

If `gh` is not installed or not authenticated, tell the user and stop. Direct them to install GitHub CLI and run `gh auth login`.

Also check the Notion MCP is connected — you'll need it in Phase 4.

---

## Phase 2: Discovery conversation

Enter a conversational discovery mode. Your goal is to understand the project well enough to make good technical decisions. Ask focused questions — **maximum 6-7 total**, sequenced so each answer informs the next. If an answer makes a later question irrelevant, drop it.

**Do not** run through these as a checklist. Have a natural conversation.

**Core things to uncover (in rough order):**

1. **What does this software do and what problem does it solve?** — Get a clear one-paragraph mental model. Who uses it, what pain does it address.

2. **What are the must-have features?** — The things without which the project fails. Then ask about nice-to-haves, but keep this list short.

3. **Are there any constraints?** — Deadline, budget, must integrate with X, performance requirements, existing codebase to work with.

4. **How is this deployed (if at all)?** — Web app, mobile, CLI, API, internal tool? Cloud provider preference? Or is this just local/prototype for now? Deployment choice drives a lot of infrastructure and stack decisions.

From the feature discussion, you should be able to **infer or propose** (not ask about blindly):
- What external APIs or services will likely be needed
- Auth requirements (does this have users? how do they log in?)
- Data storage needs (what needs to persist, at what scale)
- Security considerations

For each of these, propose what you think makes sense and ask the user to confirm or correct, rather than asking open-ended questions.

**On tech stack:** Don't ask "what stack do you want?" — propose a stack based on the project needs and explain briefly why. Let the user push back. Consider the user's background and what they're likely comfortable with.

**Defaults you set without asking** (just state them):
- Linting/formatting setup appropriate to the stack
- Git branch naming: `main`, feature branches as `feat/name`
- Basic error handling patterns
- Unit tests for core logic, skip E2E unless user says otherwise
- Standard folder structure for the chosen stack

---

## Phase 3: Structured confirmation

After discovery, write a draft confirmation to a temporary file so the user can read it comfortably outside the terminal:

```bash
mkdir -p /tmp/<project-name>
```

Write `/tmp/<project-name>/plan-draft.md` using this exact structure:

```markdown
# Project Brief: [Project Name]

> DRAFT — review and confirm before plan.md is written. Edit this file directly or feed back corrections in the terminal.

## Problem
[One sentence]

## Solution
[One sentence]

## Must-Have Features
- Feature 1
- Feature 2

## Nice-to-Have Features
- Feature A

## Tech Stack
[Stack] — [one line rationale]

## Architecture
[One paragraph — key design decisions]

## APIs / Integrations
[List or "None"]

## Auth
[Approach or "None"]

## Data
[What's stored, how]

## Deployment
[Target or "Local only for now"]

## Constraints
[List or "None"]

## Defaults
- [Linting tool]
- [Test approach]
- [Folder structure note]
- [Any other decisions made]

## Open Questions
[Anything genuinely unresolved — omit section if none]
```

Then tell the user: "Draft written to `/tmp/<project-name>/plan-draft.md` — open it, read through, and either edit it directly or tell me what to change. Say 'looks good' when you're happy and I'll proceed."

Wait for confirmation. If the user makes corrections in the terminal, apply them to the draft file and confirm the update. If they edit the file directly, re-read it before proceeding.

Once confirmed, this draft becomes the source of truth for both `plan.md` (Phase 5) and the Notion Plan page (Phase 6). Do not rewrite its content — translate it directly.

---

## Phase 4: GitHub repo creation

Once the brief is confirmed, ask two things:
1. What should the repo be named? (suggest a kebab-case name based on the project)
2. Public or private?

Narrate what you're about to do before running any commands — repo creation is irreversible.

```bash
mkdir <repo-name>
cd <repo-name>
git init
```

Generate appropriate scaffold files for the confirmed stack — standard project structure, `.gitignore`, `README.md`, config files, entry points. Use your judgement based on the stack; don't over-scaffold. Do not commit yet.

Create the remote:

```bash
gh repo create <repo-name> --private/--public --source=. --remote=origin
```

Confirm success and show the repo URL. Do not push yet — the initial commit happens after all files are ready (end of Phase 5).

---

## Phase 5: Write plan.md

Create `plan.md` in the project root. Read `references/plan-template.md` for the exact structure to follow. Translate directly from the confirmed `plan-draft.md` — do not rewrite or summarise differently.

Key principles:
- This file is Claude's reference during development — be precise about architecture and decisions
- Feature list should map to implementation tasks, not just user-facing descriptions
- Keep it scannable — this gets read at the start of every session

Once plan.md is written, do the initial commit and push everything:

```bash
git add .
git commit -m "chore: initial project setup"
git push -u origin main
```

---

## Phase 6: Notion workspace setup

Search for a page named "Projects" in the Notion workspace and create the project parent page under it. If "Projects" doesn't exist, tell the user and ask where to create it.

Create four child pages under the project parent. Read `references/notion-templates.md` for the exact content structure of each page.

**Pages to create:**
1. **Plan** — lightweight summary for human reference
2. **Dev Log** — append-only session log
3. **Next Up** — living task list
4. **Issues** — tracked issues with status

**For each page:**
- Create the page with its standard structure
- Add a **Contents toggle block at the top** listing anchor links to each major section
- The Contents toggle must be updated every time Claude writes new sections to the page

**Seed content:**
- Plan page: populated from the confirmed project brief
- Dev Log: first entry for today — "Project initialised. Repo created, plan.md written, Notion workspace set up." Include the stack decisions and initial feature list.
- Next Up: seed Current Priority with the phase 1 must-have features as tasks; Backlog with nice-to-haves
- Issues: leave empty with structure only

After all pages are created, output the Notion parent page URL so the user can bookmark it.

---

## Phase 6.5: GSD Planning Structure

Tell the user: "Initialising GSD planning structure from plan.md so /gsd:plan-phase and related skills are available."

Create the `.planning/` directory and write these 5 files, translating directly from the confirmed `plan-draft.md` and the `plan.md` just written:

**`.planning/config.json`** — copy the default GSD configuration verbatim from `~/.claude/get-shit-done/templates/config.json`. Do not modify any values.

**`.planning/PROJECT.md`** — use the PROJECT.md template from `~/.claude/get-shit-done/templates/project.md`. Translate from `plan.md`:
- "What This Is": project name + overview + problem (2-3 sentences)
- "Core Value": the single most important must-have feature or capability — one sentence
- "Requirements — Active": all must-have features as checkable items
- "Requirements — Out of Scope": constraints from plan.md (local-only, no server, etc.)
- "Context": tech stack summary + architecture note
- "Constraints": from the Constraints section of plan.md
- Leave "Key Decisions" table empty — it fills during development
- Do NOT include development phases here — those go in ROADMAP.md

**`.planning/REQUIREMENTS.md`** — use the REQUIREMENTS.md template from `~/.claude/get-shit-done/templates/requirements.md`. Translate from plan.md Features:
- v1 Requirements: must-have features as testable `User can [action]` statements with category-based IDs (e.g. FEAT-01, FEAT-02)
- v2 Requirements: nice-to-have features (no checkboxes)
- Out of Scope: constraints that rule things out (e.g., "No server/network — local only")
- Traceability table: map each v1 requirement to its phase number — leave Status as "Pending"

**`.planning/ROADMAP.md`** — use the ROADMAP.md template from `~/.claude/get-shit-done/templates/roadmap.md`. Translate from plan.md Development Phases — one GSD phase per plan.md phase:
- Phase name and number must match plan.md exactly
- Each phase needs: Goal, Depends on, Requirements (REQ IDs), Success Criteria (2-5 observable outcomes), Plans: TBD
- Leave Plans list items as `- [ ] 0N-01: TBD` placeholders — they get filled by `/gsd:plan-phase`
- Progress table: all phases "Not started"

**`.planning/STATE.md`** — use the STATE.md template from `~/.claude/get-shit-done/templates/state.md`. Initial values:
- Project Reference: points to PROJECT.md, core value from above, current focus = Phase 1
- Current Position: Phase 1 of N, Plan 0 of TBD, Status: "Ready to plan", Last activity: today's date — GSD structure initialised from plan.md
- Performance Metrics: all zeros/empty
- Accumulated Context: all sections empty ("None yet.")
- Session Continuity: Last session = today, Resume file = None

After writing all 5 files, validate the structure:

```bash
cd <repo-name>
node ~/.claude/get-shit-done/bin/gsd-tools.cjs state
```

If this returns valid JSON without errors, the structure is correct. If it errors, surface the error message clearly and attempt to fix the malformed file before proceeding. Do not skip validation.

Once validated, commit the planning files:

```bash
git add .planning/
git commit -m "docs: initialise GSD planning structure"
git push
```

---

## Done

Tell the user:
- Repo URL
- Notion workspace URL
- What's in plan.md
- What's seeded in Next Up (so they know what Claude thinks the first tasks are)
- That the GSD planning structure is ready — next step is `/gsd:discuss-phase 1` or `/gsd:plan-phase 1` when ready to start building

Ask if they want to start building immediately or adjust anything first.

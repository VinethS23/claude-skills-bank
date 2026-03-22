---
name: start-session
description: Session orientation skill. Use at the start of any working session when the user says "let's start", "start session", "start a session", "let's work on [project]", or just opens a new Claude Code session in a project directory. Reads plan.md, Notion Next Up and Issues pages, and recent GitHub activity, then presents a structured briefing and confirms what to work on.
---

# Start Session Skill

Orient quickly at the start of a session: read local and Notion project state, check GitHub, present a briefing, and confirm what to work on.

**Target time:** ~2 minutes to briefing.

---

## Phase 1: Pre-flight checks

Verify tools:

```bash
gh auth status
pwd
basename "$PWD"
```

Also confirm the Notion MCP is connected.

If `gh` is not authenticated, warn the user but continue — GitHub checks are best-effort. If Notion MCP is unavailable, tell the user and stop — Notion is required for this skill.

---

## Phase 2: Identify the project

**If the user named the project** in their message, use that name to search Notion.

**If no project was named**, use the current directory name (from `basename "$PWD"`) as the search term.

Search Notion for a project page matching that name under the "Projects" parent. If exactly one match is found, proceed silently. If multiple matches are found, list them and ask the user to confirm which one. If no match is found, tell the user and ask them to confirm the project name or paste the Notion URL directly.

---

## Phase 3: Read project state

Run all of the following in parallel where possible.

**Local:**
```bash
cat plan.md
```
If `plan.md` doesn't exist in the current directory, note it as missing — don't stop.

**Notion** (via MCP):
- Read the **Plan** page — for high-level context only
- Read the **Next Up** page — Current Priority and Backlog sections
- Read the **Issues** page — all OPEN issues

**GitHub:**
```bash
gh pr list --state open
git log --oneline -10
gh run list --limit 5
```

**GSD Planning State (conditional):**
Check if `.planning/STATE.md` exists:
- If yes: read `.planning/STATE.md` and `.planning/ROADMAP.md` in full.
  Extract: current phase number and name, current status, last activity date, any blockers in Accumulated Context.
- If no: note GSD structure not present — no action needed.

Also check for a pause handoff file:
```bash
ls .continue-here*.md 2>/dev/null
```
If any `.continue-here*.md` file exists at the repo root: read it in full. This is a mid-phase handoff file created by `/gsd:pause-work` and must be treated as high priority context.

Absorb everything. Do not output raw data — synthesise into the briefing below.

---

## Phase 4: Present the briefing

Output a compact briefing in this format:

```
## Session Briefing — [Project Name] — [DATE]

**Current state:** [One or two sentences — what this project is and where it's at]

**GSD Phase Progress:** [Only include this section if .planning/STATE.md was found]
- Current phase: [phase number and name]
- Status: [Not started / Ready to plan / Planning / In progress / Phase complete]
- Next action: [what STATE.md says is next — e.g. "Run /gsd:plan-phase 2" or "Continue executing Phase 1"]

⚠️ **Mid-session handoff detected** — [Only include if .continue-here*.md was found]
Work was paused mid-phase. Run /gsd:resume-work before starting new work.
Summary: [one-line from the .continue-here file's current_state or summary section]

**Open issues ([N]):**
- [YYYY-MM-DD] — [Issue title]
- ...

**Next Up:**
Current Priority:
- [Task]
- ...
Backlog:
- [Task]
- ...

**GitHub:**
- Open PRs: [N] — [titles if any]
- Recent commits: [last 3, one line each]
- CI: [last run status, or "no recent runs"]
```

Omit the **GSD Phase Progress** section entirely if `.planning/` was not found — no noise for non-GSD projects. Omit the handoff warning if no `.continue-here*.md` file exists. Keep it scannable. Don't pad with commentary.

---

## Phase 5: Offer a recent history summary

After the briefing, ask:

> "Want a quick summary of what was done in the last few sessions?"

**If yes:** Read the **Dev Log** Notion page and summarise the 3 most recent entries (newest first) in 1–2 sentences each. Format:

```
**Recent sessions:**
- [YYYY-MM-DD] — [Session name]: [What was built/done. Key decisions if any.]
- [YYYY-MM-DD] — [Session name]: [...]
- [YYYY-MM-DD] — [Session name]: [...]
```

**If no:** Skip silently and move to Phase 6.

---

## Phase 6: Confirm session focus

Ask:

> "Do you know what you want to work on today?"

**If yes:** User names the item. Find the matching entry in the Notion data already read and surface its full details — description, impact, any relevant context from plan.md. Confirm: "Got it — working on [X]."

**If no:** Present open issues and Current Priority items as a flat numbered list for the user to pick from. Order is not prioritised — items are shown as-is from Notion.

> 📝 **Trial note:** This "no plan" path currently shows items in arbitrary Notion order. After a few sessions, revisit whether to: self-prioritise based on issue impact/blockers, let the user order items in Notion, or add a priority field. Decide based on what feels natural in practice.

---

## Done

Session is ready. Start working on the confirmed task.

**At session end**, run the `end-session` skill to fill in the Dev Log entry (what was built, decisions, blockers), rewrite Next Up, and update any resolved Issues.

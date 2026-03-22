---
name: end-session
description: Session wrap-up skill. Use at the end of any working session when the user says "end session", "wrap up", "let's finish", "close out the session", or "end-session". Reads git commits from the session, runs a code review on changed files and their dependencies, drafts a Dev Log entry, proposes Next Up and Issues updates, and writes everything to Notion after user approval.
---

# End Session Skill

Wrap up a session: read git history, review changed code, draft Notion updates, get approval, write.

**Target time:** ~5 minutes.

---

## Phase 1: Pre-flight checks

```bash
gh auth status
pwd
```

Confirm Notion MCP is connected. If Notion is unavailable, stop — it's required. If `gh` is unavailable, warn and continue (GitHub checks are best-effort).

---

## Phase 2: Identify the project

Same as `start-session`: use the current directory name to find the Notion project page under "Projects". If ambiguous, ask the user to confirm.

---

## Phase 3: Read session commits

```bash
git log --oneline --since="12 hours ago"
OLDEST=$(git log --oneline --since="12 hours ago" | tail -1 | awk '{print $1}')
git diff --stat ${OLDEST}^..HEAD
```

Show this commit list to the user and ask: "These are the commits from the last 12 hours — does this look right, or do you want to adjust the window?" Wait for confirmation before proceeding.

**Check commit quality.** Scan each commit message. If any are uninformative — single words, "wip", "fix", "update", "temp", "asdf", or similar — check whether they've been pushed:

```bash
git log --oneline --since="12 hours ago" --not --remotes
```

**If the uninformative commits are unpushed** — stop and tell the user:

> "Some commits have uninformative messages: [list them]. Please amend before we wrap up — these are what the Dev Log entry will be built from."

Show the amend commands:
```bash
# To rewrite the last N commits interactively:
# Git opens an editor listing each commit. Change 'pick' to 'reword' next to any
# commit you want to rename, save and close — Git will prompt you for the new message.
git rebase -i HEAD~N

# To amend only the most recent commit:
git commit --amend
```

Wait for the user to confirm commits are fixed, then re-read.

**If the uninformative commits are already pushed** — warn the user but don't block:

> "Some commits have uninformative messages: [list them]. They're already pushed so we won't rewrite them — I'll do my best to infer what was built from the diff instead."

Once commits are clean, also read:
```bash
git diff --name-only ${OLDEST}^..HEAD
```

This gives the list of changed files for the code review.

**GSD Phase Summaries (conditional):**
Check if `.planning/phases/` exists:
```bash
find .planning/phases/ -name "*-SUMMARY.md" -mmin -720 2>/dev/null
```
Read any files returned — these contain structured build notes from GSD executor agents. These contain structured build notes from GSD executor agents — they are richer than commit messages. Use them alongside commit messages when drafting the Dev Log entry in Phase 6.

**GSD UAT Results (conditional):**
Check `.planning/phases/` for any `*-UAT.md` files modified in the last 12 hours:
```bash
find .planning/phases/ -name "*-UAT.md" -mmin -720 2>/dev/null
```
If any are found: read each one. Look for test entries with a result of "issue", "fail", or similar failure marker. For each issue found, extract: test name, expected behaviour, what the user observed/reported, and inferred severity. These will be added to the Notion Issues draft in Phase 6.

---

## Phase 4: Code review

Two-tier review: deep on what changed, architectural scan on the rest.

### Tier 1 — Deep review (changed files + direct dependents)

1. Read `plan.md` for architecture context — understand intended structure before judging the changes
2. Read each changed file in full
3. Identify direct dependents (files that import or call into changed files) — read those too
4. Review for:
   - Bugs or logic errors introduced
   - Unhandled edge cases or error paths
   - Security concerns (injection, auth gaps, exposed secrets)
   - Performance issues (unnecessary loops, missing indexes, N+1 queries)
   - TODOs or FIXMEs added during the session
   - Incomplete implementations (stubs, placeholder logic, missing validation)
   - Anything that looks fragile or likely to break

### Tier 2 — Architectural scan (rest of codebase)

Read entry points, data models, and feature boundaries (routes, components, services) — not every file in full. Look only for:
   - Duplicate functionality — does something equivalent already exist?
   - Contradicted conventions — does new code diverge from established patterns (error handling, naming, data access style)?
   - Conflicting data model assumptions — does new code make assumptions about entities that clash with how other features use them?
   - Cross-feature coherence — does the new behaviour fit the system's existing contracts and flows?

**Output a review summary** in this format — present it to the user before any Notion writes:

```
## Code Review — [DATE]

### Issues found
- **[Severity: High/Medium/Low]** `[file:line]` — [description of the problem]
- ...

### Suggested next tasks
- [task — specific enough to act on]
- ...

### TODOs in code
- `[file:line]` — [TODO text]
- ...
```

If nothing significant is found in a category, omit that section entirely.

Ask: "Anything to add or remove from this review before I update Notion?"

Incorporate corrections silently.

---

## Phase 5: Read current Notion state

Read in parallel:
- **Dev Log** page — to prepend the new entry correctly
- **Next Up** page — current state before rewrite
- **Issues** page — all OPEN issues

This is needed to write accurately — don't skip even if Notion was read at session start.

---

## Phase 6: Draft all Notion updates

Draft everything and present for approval before writing a single thing.

---

### Dev Log entry

Built from commit messages, code review findings, and any GSD SUMMARY.md files read in Phase 3. If SUMMARY.md files were found, prefer their structured content for the "What was built" field — they contain more detail than commit messages alone. Supplement with commit details where SUMMARY.md doesn't cover something. Format:

```
## [YYYY-MM-DD] — [Session Name derived from commits]
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

---

### Next Up rewrite

Apply these rules to the current Next Up state:
- Remove tasks completed this session — only mark a task complete if a commit message or diff directly and clearly closes it. Do not infer completion from vague or partial commit messages.
- Promote backlog items to Current Priority if they're unblocked and relevant
- Add new tasks from the code review's "Suggested next tasks" and any TODOs found
- Keep it short — Current Priority should be immediately actionable

Present the proposed rewrite in full.

---

### Issues updates

Two sources of new issues:

**1. Code review findings** — High and Medium severity findings from Phase 4. Format:
```
## [YYYY-MM-DD] — [Issue Title] — OPEN
**Description:** [What the issue is.]
**Impact:** [What it breaks or blocks.]
**Resolution:** Pending
```

**2. UAT issues** — issues found in `*-UAT.md` files read in Phase 3. For each failure/issue entry found, add a Notion issue using the same format:
```
## [YYYY-MM-DD] — [Test name from UAT] — OPEN
**Description:**
- [Expected behaviour per UAT test]
- User observed: [verbatim or paraphrased from UAT result]
**Impact:**
- [Severity: blocker / major / minor / cosmetic — infer from UAT context]
**Resolution:** Pending
```
Do not duplicate issues already captured by the code review. Skip this section if no UAT files were found or no issues were recorded.

**Resolved issues** — infer from commits whether any existing OPEN issues were addressed. If a commit message references or clearly resolves an open issue, mark it RESOLVED:
```
**Resolution:** [What fixed it — reference the commit.]
```

If nothing resolves an existing issue, leave it untouched.

---

### Present for approval

Output all three drafts together:

```
## Proposed Notion Updates

### Dev Log (new entry — prepended)
[entry]

### Next Up (full rewrite)
[rewrite]

### Issues (changes only)
New: [list or "none"]
Resolved: [list or "none"]
```

Ask: "Does this look right? Say go and I'll write it all to Notion."

---

## Phase 7: Write to Notion

Only after explicit user approval ("go", "yes", "looks good", etc.).

Write in this order:
1. **Dev Log** — prepend new entry; update Contents toggle (read page after write to get block ID, then update toggle)
2. **Next Up** — full rewrite; update Contents toggle
3. **Issues** — add new entries; update resolved entries in place; update Contents toggle (open issues first, then resolved)

After each write, read the page back to confirm block IDs before updating the Contents toggle. Never update the toggle blind.

If a write fails mid-sequence, stop immediately and tell the user which pages were successfully updated and which were not — do not attempt to continue writing to remaining pages until the failure is understood.

Confirm when done:

> "Notion updated. Dev Log, Next Up, and Issues are current."

---

## Done

Acknowledge completion with a one-line summary of each phase:

**Phase 1:** Pre-flight checks passed — GitHub CLI and Notion MCP confirmed.
**Phase 2:** Project identified — Notion workspace located.
**Phase 3:** Session commits read — changed files, GSD summaries, and UAT results absorbed.
**Phase 4:** Code review complete — issues and suggested tasks surfaced and approved.
**Phase 5:** Current Notion state read — Dev Log, Next Up, and Issues fetched fresh.
**Phase 6:** Notion updates drafted and approved — Dev Log entry, Next Up rewrite, and Issues changes confirmed.
**Phase 7:** Notion written — Dev Log, Next Up, and Issues updated.

Session closed. Remind the user to push if there are unpushed commits:

```bash
git log --not --remotes --oneline
git push
```

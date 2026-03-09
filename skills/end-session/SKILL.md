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
git diff --stat HEAD~$(git log --oneline --since="12 hours ago" | wc -l | tr -d ' ') HEAD
```

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
git diff --name-only HEAD~$(git log --oneline --since="12 hours ago" | wc -l | tr -d ' ') HEAD
```

This gives the list of changed files for the code review.

---

## Phase 4: Code review

Two-tier review: deep on what changed, architectural scan on the rest.

### Tier 1 — Deep review (changed files + direct dependents)

1. Read each changed file in full
2. Identify direct dependents (files that import or call into changed files) — read those too
3. Review for:
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

Built from commit messages + code review findings. Format:

```
## [YYYY-MM-DD] — [Session Name derived from commits]
**What was built:** [1–3 sentences. Specific — reference features, files, or behaviours changed.]
**Decisions made:** [Any notable mid-session decisions and rationale. Omit if none.]
**Blockers:** [Anything deferred or stuck. Omit if none.]
```

---

### Next Up rewrite

Apply these rules to the current Next Up state:
- Remove tasks completed this session (infer from commits + review)
- Promote backlog items to Current Priority if they're unblocked and relevant
- Add new tasks from the code review's "Suggested next tasks" and any TODOs found
- Keep it short — Current Priority should be immediately actionable

Present the proposed rewrite in full.

---

### Issues updates

Two types of change:

**New issues** — from High and Medium severity findings in the code review. Format:
```
## [YYYY-MM-DD] — [Issue Title] — OPEN
**Description:** [What the issue is.]
**Impact:** [What it breaks or blocks.]
**Resolution:** Pending
```

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

Confirm when done:

> "Notion updated. Dev Log, Next Up, and Issues are current."

---

## Done

Session closed. Remind the user to push if there are unpushed commits:

```bash
git status
git push
```

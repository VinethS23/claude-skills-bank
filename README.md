# claude-skills-bank

My personal Claude Code skill bank — skills, agents, commands, and hooks across all machines.

## Structure

```
skills/          → Claude Code skills (each folder has a SKILL.md)
agents/          → Subagent definitions (.md files)
commands/        → Custom slash commands
  gsd/           → GSD workflow commands (/gsd:*)
get-shit-done/   → GSD workflows, references, and templates
hooks/           → Hook scripts (pre/post tool use)
scripts/         → Repo management scripts
```

## Setup on a new machine

```bash
git clone https://github.com/VinethS23/claude-skills-bank ~/claude-skills-bank
~/claude-skills-bank/scripts/install.sh
```

Symlinks are created in `~/.claude/` — everything is live immediately.

## Staying up to date

```bash
cd ~/claude-skills-bank && git pull
```

No need to re-run install.sh. Symlinks stay permanently linked.

---

# GSD — Get Shit Done

A spec-driven development system built into this skills bank. Solves **context rot** — the quality degradation that happens as Claude fills its context window.

The key idea: all heavy work (research, planning, code execution) is offloaded to subagents that each get a fresh 200k context window. Your main session stays at 30–40% usage across entire projects.

> Start any project: `/gsd:new-project`
> Quick reference anytime: `/gsd:help`

---

## Core Workflow

Every project follows the same loop. Run `/clear` between major commands to keep your main context clean.

```
/gsd:new-project
       │
       ▼  for each phase:
/gsd:discuss-phase N    ← lock in your preferences before planning
/gsd:plan-phase N       ← research + create plans + verify plans
/gsd:execute-phase N    ← parallel execution, atomic commits
/gsd:verify-work N      ← manual UAT, auto-diagnoses failures
       │
       ▼  when all phases done:
/gsd:audit-milestone
/gsd:complete-milestone
```

---

## Step-by-Step

### 1. Initialize a project

```
/gsd:new-project
```

- Asks questions until it fully understands your idea
- Spawns 4 parallel research agents (stack, features, architecture, pitfalls)
- Extracts v1/v2 requirements, scopes out-of-scope items
- Creates a phased roadmap for your approval

**Creates:** `PROJECT.md`, `REQUIREMENTS.md`, `ROADMAP.md`, `STATE.md`

**Existing codebase?** Run `/gsd:map-codebase` first — it analyzes what exists so questions focus on what you're adding.

---

### 2. Discuss a phase

```
/gsd:discuss-phase 1
```

Before any planning, GSD extracts your implementation preferences for this specific phase. Layout decisions, API design choices, error handling style — all captured in `CONTEXT.md`.

Skip this and you get reasonable defaults. Use it and you get your vision.

**Creates:** `{N}-CONTEXT.md`

---

### 3. Plan a phase

```
/gsd:plan-phase 1
```

1. Spawns parallel researchers to investigate how to implement the phase
2. Planner reads RESEARCH.md + CONTEXT.md and creates 2–3 atomic task plans in XML
3. Plan checker does goal-backward verification — rejects plans that won't achieve the phase goal (up to 3 loops)

**Creates:** `{N}-RESEARCH.md`, `{N}-{M}-PLAN.md`

---

### 4. Execute a phase

```
/gsd:execute-phase 1
```

- Analyzes plan dependencies, groups into waves
- Independent plans run in parallel — each executor gets a **fresh 200k context**
- Every task gets an atomic git commit
- Verifier checks the codebase against phase goals when done

```
WAVE 1 (parallel)          WAVE 2 (parallel)
┌─────────┐ ┌─────────┐    ┌─────────┐ ┌─────────┐
│ Plan 01 │ │ Plan 02 │ →  │ Plan 03 │ │ Plan 04 │
│ User DB │ │ Product │    │ Orders  │ │ Cart    │
└─────────┘ └─────────┘    └─────────┘ └─────────┘
```

Walk away and come back to completed work with clean git history.

**Creates:** `{N}-{M}-SUMMARY.md`, `{N}-VERIFICATION.md`

---

### 5. Verify work

```
/gsd:verify-work 1
```

Walks you through each deliverable one at a time. If something is broken, spawns debug agents to find root causes and creates fix plans — you just run execute again.

---

### 6. Complete the milestone

```
/gsd:audit-milestone      ← checks all requirements were met
/gsd:complete-milestone   ← archives milestone, tags release
/gsd:new-milestone        ← starts next version cycle
```

---

## Quick Mode

For bug fixes, small features, and one-off tasks:

```
/gsd:quick
> What do you want to do? "Add dark mode toggle to settings"
```

Same quality guarantees (atomic commits, state tracking), skips the full planning ceremony.

---

## Agents

GSD uses 12 specialized subagents. Each runs in its own fresh 200k context window — the orchestrator (the command itself) only collects brief confirmations.

### Project Setup Agents

| Agent | Spawned by | Does |
|-------|-----------|------|
| `gsd-project-researcher` | `new-project`, `new-milestone` | Researches domain ecosystem — runs 4× in parallel (stack, features, architecture, pitfalls). Writes to `.planning/research/` |
| `gsd-research-synthesizer` | `new-project` | Combines outputs from the 4 parallel researchers into a single `SUMMARY.md` |
| `gsd-roadmapper` | `new-project` | Creates phase breakdown, maps requirements, defines success criteria. Writes `ROADMAP.md` |

### Per-Phase Agents

| Agent | Spawned by | Does |
|-------|-----------|------|
| `gsd-phase-researcher` | `plan-phase` | Researches how to implement this specific phase, guided by `CONTEXT.md`. Writes `RESEARCH.md` |
| `gsd-planner` | `plan-phase` | Reads RESEARCH.md + CONTEXT.md, creates 2–3 atomic XML task plans |
| `gsd-plan-checker` | `plan-phase` | Goal-backward analysis — verifies plans will actually achieve the phase goal before execution. Loops up to 3× |
| `gsd-executor` | `execute-phase` (one per plan, parallel) | Implements a single plan with atomic commits per task. Handles deviations and checkpoints |
| `gsd-verifier` | `execute-phase` (after all executors) | Checks the codebase actually delivers what the phase promised. Writes `VERIFICATION.md` |

### Brownfield & Special Agents

| Agent | Spawned by | Does |
|-------|-----------|------|
| `gsd-codebase-mapper` | `map-codebase` (4× parallel) | Each takes a focus area: tech stack, architecture, quality/conventions, concerns |
| `gsd-integration-checker` | `audit-milestone` | Verifies cross-phase integration — checks E2E user flows connect properly |
| `gsd-nyquist-auditor` | `audit-milestone`, `validate-phase` | Finds test coverage gaps and generates missing tests for phase requirements |
| `gsd-debugger` | `debug` command | Scientific method debugging — manages debug sessions, checkpoints, root cause analysis |

---

## Commands

### Core Workflow

| Command | When to use |
|---------|------------|
| `/gsd:new-project` | Start of a new project |
| `/gsd:discuss-phase [N]` | Before planning — to shape how the phase gets built |
| `/gsd:plan-phase [N]` | After discuss — research + plan + verify |
| `/gsd:execute-phase <N>` | After planning — parallel execution with commits |
| `/gsd:verify-work [N]` | After execution — manual UAT with auto-diagnosis |
| `/gsd:audit-milestone` | Before completing — verify everything shipped |
| `/gsd:complete-milestone` | All phases verified — archive and tag release |
| `/gsd:new-milestone [name]` | After completing — start next version cycle |

### Navigation & Session

| Command | When to use |
|---------|------------|
| `/gsd:progress` | "Where am I?" — shows status and next steps |
| `/gsd:resume-work` | Starting a new session — full context restoration |
| `/gsd:pause-work` | Stopping mid-phase — creates context handoff |
| `/gsd:help` | Quick command reference |

### Phase Management

| Command | When to use |
|---------|------------|
| `/gsd:add-phase` | Scope grew — append a new phase |
| `/gsd:insert-phase [N]` | Urgent work mid-milestone — inserts as decimal phase (e.g. 3.1) |
| `/gsd:remove-phase [N]` | Descoping — removes and renumbers |
| `/gsd:list-phase-assumptions [N]` | Before planning — see Claude's intended approach |
| `/gsd:plan-milestone-gaps` | After audit finds gaps — create phases to close them |

### Utilities

| Command | When to use |
|---------|------------|
| `/gsd:map-codebase` | Existing codebase — analyze before `new-project` |
| `/gsd:quick` | Bug fixes, small features, one-off tasks |
| `/gsd:debug [desc]` | Something broke — systematic debug with state |
| `/gsd:add-todo [desc]` | Capture an idea mid-session |
| `/gsd:check-todos` | Review captured ideas |
| `/gsd:settings` | Configure workflow toggles and model profile |
| `/gsd:set-profile <profile>` | Switch between `quality` / `balanced` / `budget` |
| `/gsd:validate-phase [N]` | Retroactively audit and fill test coverage gaps |
| `/gsd:health [--repair]` | Diagnose `.planning/` directory issues |
| `/gsd:update` | Update GSD to latest version |

---

## Configuration

GSD stores project settings in `.planning/config.json`. Configure during `/gsd:new-project` or update anytime with `/gsd:settings`.

### Mode & Granularity

| Setting | Options | Default | What it does |
|---------|---------|---------|-------------|
| `mode` | `interactive`, `yolo` | `interactive` | `yolo` auto-approves all decisions |
| `granularity` | `coarse`, `standard`, `fine` | `standard` | How finely scope is sliced into phases (3–5, 5–8, or 8–12) |

### Workflow Toggles

Toggle these off to speed up familiar phases or save tokens:

| Setting | Default | What it does |
|---------|---------|-------------|
| `workflow.research` | `true` | Domain research before planning |
| `workflow.plan_check` | `true` | Verification loop on plans before execution |
| `workflow.verifier` | `true` | Post-execution check against phase goals |
| `workflow.nyquist_validation` | `true` | Test coverage mapping during plan-phase |

Per-invocation overrides: `/gsd:plan-phase --skip-research` or `/gsd:plan-phase --skip-verify`

### Model Profiles

| Agent | `quality` | `balanced` (default) | `budget` |
|-------|-----------|----------|---------|
| gsd-planner | Opus | Opus | Sonnet |
| gsd-executor | Opus | Sonnet | Sonnet |
| gsd-phase-researcher | Opus | Sonnet | Haiku |
| gsd-project-researcher | Opus | Sonnet | Haiku |
| gsd-roadmapper | Opus | Sonnet | Sonnet |
| gsd-debugger | Opus | Sonnet | Sonnet |
| gsd-verifier | Sonnet | Sonnet | Haiku |
| gsd-plan-checker | Sonnet | Sonnet | Haiku |
| gsd-codebase-mapper | Sonnet | Haiku | Haiku |

Switch profiles: `/gsd:set-profile budget`

### Git Branching

| Strategy | Creates branch | Best for |
|----------|---------------|---------|
| `none` (default) | Never | Solo dev, simple projects |
| `phase` | Per `execute-phase` | Code review per phase, granular rollback |
| `milestone` | Once per milestone | Release branches, PR per version |

### Speed vs Quality Presets

| Scenario | Mode | Granularity | Profile | Toggles |
|----------|------|------------|---------|---------|
| Prototyping | `yolo` | `coarse` | `budget` | all off |
| Normal dev | `interactive` | `standard` | `balanced` | all on |
| Production | `interactive` | `fine` | `quality` | all on |

---

## Common Scenarios

**New project from a PRD doc:**
```
/gsd:new-project --auto @prd.md
```

**Existing codebase:**
```
/gsd:map-codebase
/gsd:new-project      ← questions focus on what you're adding
```

**Resume after a break:**
```
/gsd:progress         ← quick status check
/gsd:resume-work      ← full context restoration
```

**Urgent fix mid-milestone:**
```
/gsd:insert-phase 3   ← becomes phase 3.1, current phase 3 becomes 3.2
```

**Something broke:**
```
/gsd:debug "login endpoint returns 500 for valid credentials"
```

**Preparing for release:**
```
/gsd:audit-milestone
/gsd:plan-milestone-gaps   ← if audit found gaps
/gsd:complete-milestone
```

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| Lost context / new session | `/gsd:resume-work` or `/gsd:progress` |
| Plans don't match your vision | Run `/gsd:discuss-phase [N]` then re-plan |
| Phase went wrong | `git revert` the phase commits, then re-plan |
| Need to change scope | `/gsd:add-phase`, `/gsd:insert-phase`, or `/gsd:remove-phase` |
| Milestone audit found gaps | `/gsd:plan-milestone-gaps` |
| Something broke | `/gsd:debug "description"` |
| Quick targeted fix | `/gsd:quick` |
| Costs running high | `/gsd:set-profile budget` + toggle agents off in `/gsd:settings` |
| Plans too ambitious / producing stubs | Re-plan with smaller scope (2–3 tasks max per plan) |
| Quality degrading mid-session | `/clear` then `/gsd:resume-work` |

---

## Project File Structure

What GSD creates in your project:

```
.planning/
  PROJECT.md              ← project vision, always loaded into context
  REQUIREMENTS.md         ← scoped v1/v2 requirements with phase traceability
  ROADMAP.md              ← phase breakdown with status tracking
  STATE.md                ← decisions, blockers, session memory
  config.json             ← workflow configuration
  research/               ← domain research from new-project
  todos/
    pending/              ← captured ideas awaiting work
    done/                 ← completed todos
  debug/                  ← active debug sessions
  codebase/               ← brownfield analysis from map-codebase
    STACK.md
    INTEGRATIONS.md
    ARCHITECTURE.md
    STRUCTURE.md
    CONVENTIONS.md
    TESTING.md
    CONCERNS.md
  phases/
    XX-phase-name/
      CONTEXT.md          ← your implementation preferences
      RESEARCH.md         ← ecosystem research findings
      XX-YY-PLAN.md       ← atomic execution plans
      XX-YY-SUMMARY.md    ← execution outcomes and decisions
      VERIFICATION.md     ← post-execution verification
```

---

## Other Skills

| Skill | What it does |
|-------|-------------|
| `new-project` | Bootstrap a new project — creates GitHub repo, plan.md, and Notion workspace |
| `start-session` | Session orientation — reads plan, Notion Next Up/Issues, recent GitHub activity |
| `end-session` | Session wrap-up — code review, Dev Log entry, updates Notion |
| `join-project` | Join an existing project on a new machine |

### Agents

| Agent | What it does |
|-------|-------------|
| `work-critic` | Thorough, fair critique of code, writing, plans, or any completed work |
| `criticism-response-planner` | Plans how to respond to and implement feedback |

---

## Adding Skills

```bash
# From a public repo
./scripts/fetch-skill.sh https://github.com/some-user/some-skills-repo

# Manually: drop a folder with SKILL.md into skills/, or a .md into agents/ or commands/
# Then commit and push
git add . && git commit -m "add: <skill-name>" && git push
```

**Good public skill banks:**

| Repo | What it has |
|------|------------|
| [qdhenry/Claude-Command-Suite](https://github.com/qdhenry/Claude-Command-Suite) | 216 commands, 12 skills, 54 agents |
| [jeremylongshore/claude-code-plugins-plus-skills](https://github.com/jeremylongshore/claude-code-plugins-plus-skills) | 270 plugins, 739 skills |
| [wshobson/commands](https://github.com/wshobson/commands) | 57 production commands |
| [carlrannaberg/claudekit](https://github.com/carlrannaberg/claudekit) | Hooks toolkit |
| [SuperClaude-Org/SuperClaude_Framework](https://github.com/SuperClaude-Org/SuperClaude_Framework) | 30 commands, 30–50% token reduction |
| [hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) | Curated master list |

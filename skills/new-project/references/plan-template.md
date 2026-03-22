# plan.md Template

Write plan.md using this exact structure. This file is Claude's primary reference during development — be precise. Keep it scannable.

---

```markdown
# [Project Name]

## Overview
[Two sentences max. What it does and who it's for.]

## Problem
[One paragraph. The pain point this solves.]

## Tech Stack
- **[Layer]:** [Technology] — [one-line rationale]
- **[Layer]:** [Technology] — [one-line rationale]
(e.g. Frontend, Backend, Database, Auth, Hosting, External APIs)

## Architecture
[One paragraph. High-level shape of the system — how the main parts connect. Key decisions and why.]

## Features

### Must-Have
- **[Feature name]:** [What it does. Implementation note if non-obvious.]

### Nice-to-Have
- **[Feature name]:** [What it does.]

## Data Model
[Key entities and their relationships. Can be prose or a simple list. Skip if no persistence.]

## API / Integration Contracts
[External APIs consumed, or endpoints this system exposes. Skip if none.]

## Auth
[How auth works, or "No auth required".]

## Deployment
[Target environment and approach, or "Local only".]

## Constraints
[Hard constraints: deadlines, performance requirements, integration requirements. Skip if none.]

## Development Phases

### Phase 1 — [Name, e.g. "Core MVP"]
- [ ] Task 1
- [ ] Task 2

### Phase 2 — [Name]
- [ ] Task A

## Open Questions
- [Anything unresolved that will need a decision during development]
```

---

## Notes on writing plan.md

- Feature descriptions should be precise enough that Claude can implement them without ambiguity
- Phase tasks should map to actual implementation work, not user stories
- Keep open questions honest — don't paper over uncertainty
- Update plan.md when significant decisions change during development

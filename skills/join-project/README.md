# join-project-skill

Onboard Claude into an existing project and set up the `plan.md` + Notion workspace dev framework.

## Structure

```
join-project-skill/
├── SKILL.md                        # Main skill instructions
└── references/
    ├── plan-template.md            # Shared with new-project — plan.md structure
    └── notion-templates.md         # Shared with new-project — all Notion page templates
```

## Shared references

`references/plan-template.md` is identical to the one in `new-project/references/` — keep them in sync manually.

`references/notion-templates.md` is a **superset** of the one in `new-project/references/` — it adds three join-project-specific elements:
- **Fragile Areas** section in the Plan page template (only shown if identified at onboarding)
- **Onboarding snapshot entry** format for the first Dev Log entry (different field names from a standard session entry)
- **Blocked / Pending** section in the Next Up template (only shown if open team questions exist)

Do **not** overwrite `join-project/references/notion-templates.md` with the `new-project` version — it will lose these additions.

## Usage

Run in Claude Code terminal from inside an existing git repo:
```
/join-project
```

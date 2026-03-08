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

`references/plan-template.md` and `references/notion-templates.md` are **identical** to those in `new-project-skill/references/`. Keep them in sync manually, or symlink them if your setup allows.

## Usage

Run in Claude Code terminal from inside an existing git repo:
```
/join-project
```

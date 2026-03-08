# claude-skills-bank

My personal Claude Code skill bank — skills, agents, commands, and hooks I use across all machines.

## Structure

```
skills/      → Claude Code skills (each folder has a SKILL.md)
agents/      → Subagent definitions (.md files)
commands/    → Custom slash commands (.md files)
hooks/       → Hook scripts (pre/post tool use)
scripts/     → Repo management scripts
```

## Setup on a new machine

```bash
git clone https://github.com/vinethsiriwardana/claude-skills-bank ~/claude-skills-bank
~/claude-skills-bank/scripts/install.sh
```

That's it. Symlinks are created in `~/.claude/` — everything is live immediately.

## Staying up to date

```bash
cd ~/claude-skills-bank && git pull
```

No need to re-run install.sh. Symlinks stay permanently linked.

## Adding a skill from a public repo

```bash
./scripts/fetch-skill.sh https://github.com/some-user/some-skills-repo
# or grab a specific subfolder:
./scripts/fetch-skill.sh https://github.com/qdhenry/Claude-Command-Suite .claude/commands/dev-review.md
```

Then review, commit, and push:

```bash
git add . && git commit -m "add: <skill-name>" && git push
```

## Adding a skill manually

Drop a folder with a `SKILL.md` into `skills/`, or a `.md` file into `agents/` or `commands/`, then commit and push.

## Good public skill banks to pull from

| Repo | What it has |
|---|---|
| [qdhenry/Claude-Command-Suite](https://github.com/qdhenry/Claude-Command-Suite) | 216 commands, 12 skills, 54 agents |
| [jeremylongshore/claude-code-plugins-plus-skills](https://github.com/jeremylongshore/claude-code-plugins-plus-skills) | 270 plugins, 739 skills |
| [wshobson/commands](https://github.com/wshobson/commands) | 57 production commands |
| [hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) | Curated master list |
| [SuperClaude-Org/SuperClaude_Framework](https://github.com/SuperClaude-Org/SuperClaude_Framework) | 30 commands, 70% token reduction |
| [carlrannaberg/claudekit](https://github.com/carlrannaberg/claudekit) | Hooks toolkit |

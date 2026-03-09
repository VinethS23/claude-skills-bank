#!/usr/bin/env bash
# install.sh — symlink claude-skills-bank into ~/.claude
# Run this once on each machine after cloning.
# After that, `git pull` is all you need — symlinks stay live.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLAUDE_DIR="$HOME/.claude"

echo "Installing claude-skills-bank from: $REPO_DIR"
echo ""

# ── Skills ──────────────────────────────────────────────────────────────────
mkdir -p "$CLAUDE_DIR/skills"
for skill_dir in "$REPO_DIR/skills"/*/; do
  skill_name="$(basename "$skill_dir")"
  target="$CLAUDE_DIR/skills/$skill_name"
  if [ -L "$target" ]; then
    echo "  [skip]   skills/$skill_name (already linked)"
  elif [ -e "$target" ]; then
    echo "  [warn]   skills/$skill_name exists but is NOT a symlink — skipping to avoid overwrite"
  else
    ln -s "$skill_dir" "$target"
    echo "  [linked] skills/$skill_name"
  fi
done

# ── Agents ───────────────────────────────────────────────────────────────────
mkdir -p "$CLAUDE_DIR/agents"
for agent_file in "$REPO_DIR/agents"/*.md; do
  agent_name="$(basename "$agent_file")"
  target="$CLAUDE_DIR/agents/$agent_name"
  if [ -L "$target" ]; then
    echo "  [skip]   agents/$agent_name (already linked)"
  elif [ -e "$target" ]; then
    echo "  [warn]   agents/$agent_name exists but is NOT a symlink — skipping to avoid overwrite"
  else
    ln -s "$agent_file" "$target"
    echo "  [linked] agents/$agent_name"
  fi
done

# ── Commands (top-level .md files) ───────────────────────────────────────────
if [ -n "$(ls -A "$REPO_DIR/commands" 2>/dev/null)" ]; then
  mkdir -p "$CLAUDE_DIR/commands"
  for cmd_file in "$REPO_DIR/commands"/*.md; do
    [ -f "$cmd_file" ] || continue
    cmd_name="$(basename "$cmd_file")"
    target="$CLAUDE_DIR/commands/$cmd_name"
    if [ -L "$target" ]; then
      echo "  [skip]   commands/$cmd_name (already linked)"
    elif [ -e "$target" ]; then
      echo "  [warn]   commands/$cmd_name exists but is NOT a symlink — skipping"
    else
      ln -s "$cmd_file" "$target"
      echo "  [linked] commands/$cmd_name"
    fi
  done

  # ── Commands subdirectories (e.g. commands/gsd/) ──────────────────────────
  for cmd_subdir in "$REPO_DIR/commands"/*/; do
    [ -d "$cmd_subdir" ] || continue
    subdir_name="$(basename "$cmd_subdir")"
    target="$CLAUDE_DIR/commands/$subdir_name"
    if [ -L "$target" ]; then
      echo "  [skip]   commands/$subdir_name/ (already linked)"
    elif [ -e "$target" ]; then
      echo "  [warn]   commands/$subdir_name/ exists but is NOT a symlink — skipping"
    else
      ln -s "$cmd_subdir" "$target"
      echo "  [linked] commands/$subdir_name/"
    fi
  done
fi

# ── Top-level repo directories (e.g. get-shit-done/) ─────────────────────────
for repo_dir in "$REPO_DIR"/*/; do
  dir_name="$(basename "$repo_dir")"
  # Only sync dirs that are meant to live directly in ~/.claude/
  case "$dir_name" in
    get-shit-done)
      target="$CLAUDE_DIR/$dir_name"
      if [ -L "$target" ]; then
        echo "  [skip]   $dir_name/ (already linked)"
      elif [ -e "$target" ]; then
        echo "  [warn]   $dir_name/ exists but is NOT a symlink — skipping"
      else
        ln -s "$repo_dir" "$target"
        echo "  [linked] $dir_name/"
      fi
      ;;
  esac
done

# ── Hooks ─────────────────────────────────────────────────────────────────────
if [ -n "$(ls -A "$REPO_DIR/hooks" 2>/dev/null)" ]; then
  mkdir -p "$CLAUDE_DIR/hooks"
  for hook_file in "$REPO_DIR/hooks"/*; do
    [ -f "$hook_file" ] || continue
    hook_name="$(basename "$hook_file")"
    target="$CLAUDE_DIR/hooks/$hook_name"
    if [ -L "$target" ]; then
      echo "  [skip]   hooks/$hook_name (already linked)"
    elif [ -e "$target" ]; then
      echo "  [warn]   hooks/$hook_name exists but is NOT a symlink — skipping"
    else
      ln -s "$hook_file" "$target"
      echo "  [linked] hooks/$hook_name"
    fi
  done
fi

echo ""
echo "Done. Run 'git pull' in $REPO_DIR any time to get updates on this machine."

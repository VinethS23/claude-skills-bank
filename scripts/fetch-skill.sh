#!/usr/bin/env bash
# fetch-skill.sh — pull a skill from any public GitHub repo into your bank
#
# Usage:
#   ./scripts/fetch-skill.sh <github-repo-url> [subfolder-path]
#
# Examples:
#   # Grab everything from a skills repo:
#   ./scripts/fetch-skill.sh https://github.com/qdhenry/Claude-Command-Suite
#
#   # Grab a specific skill subfolder:
#   ./scripts/fetch-skill.sh https://github.com/someuser/skills-repo skills/code-review
#
#   # Grab an agent file:
#   ./scripts/fetch-skill.sh https://github.com/someuser/claude-agents agents/security-auditor.md

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_URL="${1:-}"
SUBFOLDER="${2:-}"
TMP_DIR="$(mktemp -d)"

if [ -z "$REPO_URL" ]; then
  echo "Usage: $0 <github-repo-url> [subfolder-path]"
  echo ""
  echo "Examples:"
  echo "  $0 https://github.com/qdhenry/Claude-Command-Suite"
  echo "  $0 https://github.com/someuser/skills-repo skills/my-skill"
  exit 1
fi

echo "Fetching from: $REPO_URL"
[ -n "$SUBFOLDER" ] && echo "Subfolder: $SUBFOLDER"

# Clone (shallow, no blobs for speed)
git clone --depth 1 --quiet "$REPO_URL" "$TMP_DIR/source"

SOURCE="$TMP_DIR/source"
[ -n "$SUBFOLDER" ] && SOURCE="$TMP_DIR/source/$SUBFOLDER"

if [ ! -e "$SOURCE" ]; then
  echo "Error: path '$SUBFOLDER' not found in the repo."
  rm -rf "$TMP_DIR"
  exit 1
fi

# Auto-detect what was fetched and copy to the right place
copy_item() {
  local src="$1"
  local name="$(basename "$src")"

  # Remove .DS_Store from source
  find "$src" -name ".DS_Store" -delete 2>/dev/null || true

  if [ -d "$src" ] && [ -f "$src/SKILL.md" ]; then
    # It's a skill folder
    dest="$REPO_DIR/skills/$name"
    if [ -e "$dest" ]; then
      echo "  [exists] skills/$name — skipping (delete manually to replace)"
    else
      cp -r "$src" "$dest"
      echo "  [added]  skills/$name"
    fi
  elif [ -f "$src" ] && [[ "$name" == *.md ]]; then
    # It's a markdown file — treat as agent
    dest="$REPO_DIR/agents/$name"
    if [ -e "$dest" ]; then
      echo "  [exists] agents/$name — skipping"
    else
      cp "$src" "$dest"
      echo "  [added]  agents/$name"
    fi
  elif [ -d "$src" ]; then
    # Directory without SKILL.md — recurse into it
    echo "  Scanning $name/ for skills and agents..."
    for item in "$src"/*/; do
      [ -e "$item" ] && copy_item "$item"
    done
    for item in "$src"/*.md; do
      [ -f "$item" ] && copy_item "$item"
    done
  fi
}

copy_item "$SOURCE"

rm -rf "$TMP_DIR"
echo ""
echo "Done. Review additions, then: git add . && git commit -m 'add skill from $REPO_URL'"
echo "Then run ./scripts/install.sh to symlink new items into ~/.claude"

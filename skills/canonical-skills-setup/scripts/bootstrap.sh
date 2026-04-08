#!/usr/bin/env bash
# bootstrap.sh — Wire canonical skills to all local agent clients via symlinks.
# Usage: bash bootstrap.sh [canonical-path]
# Default canonical path: ~/Projects/knowledge-base/skills

set -e

CANONICAL="${1:-$HOME/Projects/knowledge-base/skills}"
CANONICAL="$(eval echo "$CANONICAL")"  # expand ~ if passed as string

if [ ! -d "$CANONICAL" ]; then
  echo "❌ Canonical path not found: $CANONICAL"
  echo "   Usage: bash bootstrap.sh [canonical-path]"
  exit 1
fi

echo "📂 Canonical: $CANONICAL"
echo ""

# Agent discovery directories: "label:path"
AGENTS=(
  "Claude Code:$HOME/.claude/skills"
  "Gemini CLI / Antigravity:$HOME/.agents/skills"
)

linked=0
skipped=0
errors=0

for entry in "${AGENTS[@]}"; do
  agent="${entry%%:*}"
  target_dir="${entry#*:}"
  mkdir -p "$target_dir"

  echo "🔗 $agent → $target_dir"

  for skill_dir in "$CANONICAL"/*/; do
    [ -d "$skill_dir" ] || continue
    skill_name="$(basename "$skill_dir")"
    link="$target_dir/$skill_name"

    if [ -L "$link" ]; then
      echo "   ✓ $skill_name (already linked)"
      ((skipped++)) || true
    elif [ -d "$link" ]; then
      echo "   ⚠ $skill_name (real directory exists — skipping, remove manually to replace with symlink)"
      ((errors++)) || true
    else
      ln -s "$skill_dir" "$link"
      echo "   + $skill_name"
      ((linked++)) || true
    fi
  done

  echo ""
done

echo "Done. $linked linked, $skipped already linked, $errors skipped."
echo ""
echo "Restart your agent clients to pick up new skills."

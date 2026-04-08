#!/usr/bin/env bash
# migrate.sh — Scan and collect user-created skills from all agent directories.
# Usage:
#   bash migrate.sh scan              — Show all skills and their status
#   bash migrate.sh collect <outdir>  — Copy user-created skills to a staging directory

set -e

# Known agent skill directories
DIRS=(
  "$HOME/.claude/skills"
  "$HOME/.agents/skills"
  "$HOME/.copilot/skills"
  "$HOME/.gemini/antigravity/skills"
)

# Skills managed by npx (from .skill-lock.json)
get_npx_managed() {
  local lockfile="$HOME/.agents/.skill-lock.json"
  if [ -f "$lockfile" ]; then
    python3 -c "
import json
try:
    with open('$lockfile') as f:
        data = json.load(f)
    for name in data.get('skills', {}):
        print(name.replace(':', '-'))
except: pass
" 2>/dev/null
  fi
}

is_npx_managed() {
  local name="$1"
  local managed
  managed="$(get_npx_managed)"
  echo "$managed" | grep -qx "$name" 2>/dev/null
}

scan() {
  echo "Scanning agent directories for skills..."
  echo ""

  local tmpdir
  tmpdir="$(mktemp -d)"
  mkdir -p "$tmpdir/user" "$tmpdir/npx"

  for dir in "${DIRS[@]}"; do
    [ -d "$dir" ] || continue
    for entry in "$dir"/*/; do
      [ -d "$entry" ] || continue
      local name
      name="$(basename "$entry")"
      [ "$name" = "*" ] && continue

      local real_path
      real_path="$(cd "$entry" 2>/dev/null && pwd -P)" || continue
      [ -f "$real_path/SKILL.md" ] || continue

      if is_npx_managed "$name"; then
        echo "$dir" >> "$tmpdir/npx/$name"
      else
        echo "$dir" >> "$tmpdir/user/$name"
      fi
    done
  done

  local user_count=0
  local npx_count=0

  echo "USER-CREATED SKILLS (migrate these):"
  echo "────────────────────────────────────"
  for f in "$tmpdir/user"/*; do
    [ -f "$f" ] || continue
    local name
    name="$(basename "$f")"
    local locations
    locations="$(tr '\n' ', ' < "$f" | sed 's/, $//')"
    echo "  $name"
    echo "    found in: $locations"
    ((user_count++)) || true
  done

  echo ""
  echo "NPX-MANAGED SKILLS (leave these):"
  echo "──────────────────────────────────"
  for f in "$tmpdir/npx"/*; do
    [ -f "$f" ] || continue
    local name
    name="$(basename "$f")"
    local locations
    locations="$(tr '\n' ', ' < "$f" | sed 's/, $//')"
    echo "  $name"
    echo "    found in: $locations"
    ((npx_count++)) || true
  done

  echo ""
  echo "Summary: $user_count user-created, $npx_count npx-managed"

  rm -rf "$tmpdir"
}

collect() {
  local outdir="${1:?Usage: migrate.sh collect <outdir>}"
  mkdir -p "$outdir"

  echo "Collecting user-created skills to $outdir..."
  echo ""

  local count=0

  for dir in "${DIRS[@]}"; do
    [ -d "$dir" ] || continue
    for entry in "$dir"/*/; do
      [ -d "$entry" ] || continue
      local name
      name="$(basename "$entry")"
      [ "$name" = "*" ] && continue

      is_npx_managed "$name" && continue
      [ -d "$outdir/$name" ] && continue

      local real_path
      real_path="$(cd "$entry" 2>/dev/null && pwd -P)" || continue
      if [ -f "$real_path/SKILL.md" ]; then
        cp -r "$real_path" "$outdir/$name"
        echo "  ✓ $name"
        ((count++)) || true
      fi
    done
  done

  echo ""
  echo "Collected $count skills to $outdir"
}

case "${1:-}" in
  scan)    scan ;;
  collect) collect "$2" ;;
  *)
    echo "Usage:"
    echo "  bash migrate.sh scan              — Show all skills and their status"
    echo "  bash migrate.sh collect <outdir>   — Copy user-created skills to staging"
    ;;
esac

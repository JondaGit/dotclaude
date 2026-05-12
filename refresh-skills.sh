#!/usr/bin/env bash
# Sync ~/.claude/skills/ symlinks with skills in ~/dotclaude/skills/.
#
# - Creates a symlink for every skill directory under SRC that's missing in DST.
# - Removes broken symlinks in DST that point into SRC but no longer have a target.
# - Leaves unrelated entries (real dirs, symlinks pointing elsewhere) untouched.

set -euo pipefail

SRC="${DOTCLAUDE_SKILLS:-$HOME/dotclaude/skills}"
DST="${CLAUDE_SKILLS:-$HOME/.claude/skills}"

if [[ ! -d "$SRC" ]]; then
  echo "source not found: $SRC" >&2
  exit 1
fi
mkdir -p "$DST"

added=0
skipped=0
removed=0
warned=0

# Link every skill in SRC into DST.
for skill_path in "$SRC"/*/; do
  [[ -d "$skill_path" ]] || continue
  name="$(basename "$skill_path")"
  target="${skill_path%/}"
  link="$DST/$name"

  if [[ -L "$link" ]]; then
    current="$(readlink "$link")"
    if [[ "$current" == "$target" ]]; then
      ((skipped++))
    else
      echo "warn: $link -> $current (expected $target) — leaving as-is"
      ((warned++))
    fi
  elif [[ -e "$link" ]]; then
    echo "warn: $link exists and is not a symlink — leaving as-is"
    ((warned++))
  else
    ln -s "$target" "$link"
    echo "linked: $name"
    ((added++))
  fi
done

# Clean up broken symlinks in DST that point into SRC.
for link in "$DST"/*; do
  [[ -L "$link" ]] || continue
  target="$(readlink "$link")"
  case "$target" in
    "$SRC"/*) ;;
    *) continue ;;
  esac
  if [[ ! -e "$link" ]]; then
    rm "$link"
    echo "removed broken: $(basename "$link")"
    ((removed++))
  fi
done

echo "done — added: $added, ok: $skipped, removed: $removed, warned: $warned"

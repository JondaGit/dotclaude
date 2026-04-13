#!/usr/bin/env bash
set -euo pipefail

REPO_SKILLS="$(cd "$(dirname "$0")" && pwd)/skills"
TARGET_DIR="$HOME/.claude/skills"

mkdir -p "$TARGET_DIR"

added=0
removed=0
unchanged=0

# Remove stale symlinks pointing into this repo
for link in "$TARGET_DIR"/*; do
  [ -L "$link" ] || continue
  dest="$(readlink "$link")"
  case "$dest" in
    "$REPO_SKILLS"/*)
      if [ ! -d "$dest" ]; then
        rm "$link"
        echo "- removed $(basename "$link") (source deleted)"
        ((removed++))
      fi
      ;;
  esac
done

# Create missing symlinks
for skill_dir in "$REPO_SKILLS"/*/; do
  name="$(basename "$skill_dir")"
  link="$TARGET_DIR/$name"

  if [ -L "$link" ] && [ "$(readlink "$link")" = "$REPO_SKILLS/$name" ]; then
    ((unchanged++))
    continue
  fi

  # Remove conflicting entry (stale symlink or regular file)
  [ -e "$link" ] || [ -L "$link" ] && rm -rf "$link"

  ln -s "$REPO_SKILLS/$name" "$link"
  echo "+ linked $name"
  ((added++))
done

echo "done: $added added, $removed removed, $unchanged unchanged"

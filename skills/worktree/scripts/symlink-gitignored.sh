#!/usr/bin/env bash
set -euo pipefail

# Symlink all gitignored files/dirs from source repo into a worktree.
# Usage: symlink-gitignored.sh <source_repo> <worktree_dir>

SOURCE="${1:?Usage: symlink-gitignored.sh <source_repo> <worktree_dir>}"
WORKTREE="${2:?Usage: symlink-gitignored.sh <source_repo> <worktree_dir>}"

SOURCE="$(cd "$SOURCE" && pwd)"
WORKTREE="$(cd "$WORKTREE" && pwd)"

# Find all top-level gitignored files and directories that actually exist in the source.
# git ls-files --others --ignored --exclude-standard lists ignored files;
# we extract unique top-level entries (first path component).
cd "$SOURCE"
TOP_LEVEL_IGNORED=$(git ls-files --others --ignored --exclude-standard --directory \
  | sed 's|/.*||' \
  | sort -u)

LINKED=0
SKIPPED=0

for entry in $TOP_LEVEL_IGNORED; do
  src="$SOURCE/$entry"
  dst="$WORKTREE/$entry"

  # Skip if source doesn't exist
  [ -e "$src" ] || continue

  # Skip if destination already exists (don't overwrite)
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    SKIPPED=$((SKIPPED + 1))
    continue
  fi

  ln -s "$src" "$dst"
  LINKED=$((LINKED + 1))

  # Add to .git/info/exclude so symlinks don't pollute git status.
  # In worktrees, .git is a file pointing to the real git dir — use rev-parse.
  EXCLUDE_FILE="$(git -C "$WORKTREE" rev-parse --git-dir)/info/exclude"
  if [ -f "$EXCLUDE_FILE" ]; then
    grep -qxF "$entry" "$EXCLUDE_FILE" 2>/dev/null || echo "$entry" >> "$EXCLUDE_FILE"
  fi
done

echo "Symlinked $LINKED gitignored entries into worktree ($SKIPPED already existed)"

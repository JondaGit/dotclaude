#!/bin/bash
# Detects /skillname references in user prompts and injects skill content directly.
# Auto-discovers skill names from ~/.claude/skills/ directory.
# Input: JSON on stdin with "prompt" field (UserPromptSubmit hook format).
# Output: Plain text skill content on stdout (added to Claude's context).

PROMPT=$(cat | jq -r '.prompt // empty' 2>/dev/null)
if [ -z "$PROMPT" ]; then
  exit 0
fi

SKILLS_DIR="$HOME/.claude/skills"
if [ ! -d "$SKILLS_DIR" ]; then
  exit 0
fi

SKILL_NAMES=()
for dir in "$SKILLS_DIR"/*/; do
  [ -d "$dir" ] || continue
  name=$(basename "$dir")
  SKILL_NAMES+=("$name")
done

if [ ${#SKILL_NAMES[@]} -eq 0 ]; then
  exit 0
fi

MATCHED=()
for skill in "${SKILL_NAMES[@]}"; do
  if echo "$PROMPT" | grep -qE "(^|[[:space:]])/${skill}([[:space:],.;:!?\"]|$)"; then
    MATCHED+=("$skill")
  fi
done

if [ ${#MATCHED[@]} -eq 0 ]; then
  exit 0
fi

for skill in "${MATCHED[@]}"; do
  SKILL_FILE=""
  if [ -f "$SKILLS_DIR/$skill/SKILL.md" ]; then
    SKILL_FILE="$SKILLS_DIR/$skill/SKILL.md"
  elif [ -f "$SKILLS_DIR/$skill/skill.md" ]; then
    SKILL_FILE="$SKILLS_DIR/$skill/skill.md"
  fi

  if [ -n "$SKILL_FILE" ]; then
    echo "<skill-context name=\"$skill\">"
    # Strip YAML frontmatter
    sed '1{/^---$/!q;};1,/^---$/d' "$SKILL_FILE"
    echo "</skill-context>"
  fi
done

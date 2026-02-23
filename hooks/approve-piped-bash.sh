#!/bin/bash
# PreToolUse hook: auto-approve piped Bash commands where every segment
# uses a command already allowed in settings.json.
#
# Logic: treat a compound command (pipes, &&, ||, ;) as a conjunction.
# If every segment's command prefix matches a Bash(...) permission from
# settings.json, auto-approve. Otherwise passthrough to default permissions.

INPUT=$(cat)

TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)
if [ "$TOOL_NAME" != "Bash" ]; then
  exit 0
fi

COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)
if [ -z "$COMMAND" ]; then
  exit 0
fi

# No shell operators → the normal permission system handles it fine
if ! echo "$COMMAND" | grep -qE '\||&&|\|\||;'; then
  exit 0
fi

# Bail on subshells and backticks — too risky to auto-approve
if echo "$COMMAND" | grep -qE '\$\(|`'; then
  exit 0
fi

# Extract allowed prefixes from settings.json — single source of truth
# Bash(git:*) → "git", Bash(git add:*) → "git add", Bash(bundle exec:*) → "bundle exec"
SETTINGS_FILE="$HOME/.claude/settings.json"
if [ ! -f "$SETTINGS_FILE" ]; then
  exit 0
fi

# Parse all Bash(...) entries into prefix arrays
ALLOWED_SINGLE=()
ALLOWED_MULTI=()

while IFS= read -r prefix; do
  if echo "$prefix" | grep -q ' '; then
    ALLOWED_MULTI+=("$prefix")
  else
    ALLOWED_SINGLE+=("$prefix")
  fi
done < <(jq -r '.permissions.allow[]' "$SETTINGS_FILE" 2>/dev/null \
  | sed -n 's/^Bash(\([^:)]*\)[:)].*/\1/p' \
  | sort -u)

is_allowed() {
  local segment="$1"
  segment=$(echo "$segment" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
  [ -z "$segment" ] && return 0

  local first_token
  first_token=$(echo "$segment" | awk '{print $1}')
  first_token="${first_token##*/}"

  # Check multi-word prefixes first (more specific)
  for allowed in "${ALLOWED_MULTI[@]}"; do
    local word_count
    word_count=$(echo "$allowed" | wc -w | tr -d ' ')
    local segment_prefix
    segment_prefix=$(echo "$segment" | awk -v n="$word_count" '{for(i=1;i<=n;i++) printf "%s%s",$i,(i<n?" ":"")}')
    if [ "$segment_prefix" = "$allowed" ]; then
      return 0
    fi
  done

  # Check single-word prefixes
  for allowed in "${ALLOWED_SINGLE[@]}"; do
    if [ "$first_token" = "$allowed" ]; then
      return 0
    fi
  done

  return 1
}

# Split on shell operators (|, &&, ||, ;) while respecting quotes
IFS=$'\n' read -r -d '' -a SEGMENTS < <(echo "$COMMAND" | perl -e '
  $_ = <STDIN>;
  chomp;
  my @segments;
  my $current = "";
  my $i = 0;
  my $len = length($_);
  while ($i < $len) {
    my $c = substr($_, $i, 1);
    if ($c eq "'\''") {
      $current .= $c; $i++;
      while ($i < $len && substr($_, $i, 1) ne "'\''") {
        $current .= substr($_, $i, 1); $i++;
      }
      $current .= substr($_, $i, 1) if $i < $len; $i++;
      next;
    }
    if ($c eq "\"") {
      $current .= $c; $i++;
      while ($i < $len && substr($_, $i, 1) ne "\"") {
        if (substr($_, $i, 1) eq "\\") { $current .= substr($_, $i, 2); $i += 2; next; }
        $current .= substr($_, $i, 1); $i++;
      }
      $current .= substr($_, $i, 1) if $i < $len; $i++;
      next;
    }
    if ($c eq "\\") { $current .= substr($_, $i, 2); $i += 2; next; }
    my $two = substr($_, $i, 2);
    if ($two eq "&&" || $two eq "||") {
      push @segments, $current; $current = ""; $i += 2; next;
    }
    if ($c eq "|" || $c eq ";") {
      push @segments, $current; $current = ""; $i++; next;
    }
    $current .= $c; $i++;
  }
  push @segments, $current if $current ne "";
  print join("\n", @segments) . "\n";
' && printf '\0')

for seg in "${SEGMENTS[@]}"; do
  if ! is_allowed "$seg"; then
    exit 0
  fi
done

echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}'
exit 0

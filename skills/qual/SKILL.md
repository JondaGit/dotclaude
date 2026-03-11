---
name: qual
description: Multi-lens quality analysis with specialist teammates. Analyzes code from different angles, consolidates findings for user approval, then implements fixes.
argument-hint: [path]
---

target_path = $ARGUMENTS

## Scope

If target_path provided, analyze that path. Otherwise, files changed since the default branch. Full-codebase analysis requires explicit user request.

## Architecture

You are the coordinator. Specialists analyze in clean context windows so your bias doesn't leak into their findings. You consolidate with expert judgment and never modify code without user approval.

Two waves: **detect** then **simplify**. Wave 2 exists because LLMs reliably over-engineer fixes — your own wave 1 fixes are suspect and need an independent simplification pass.

## Wave 1: Detect

### Specialist Team

Create a team via `TeamCreate`, spawn all specialists via `Task` with `team_name`.

**Wave 1 teammates are read-only** (`Read`, `Glob`, `Grep`, `Bash` for git commands only). Mixing analysis and editing in one pass leads to fixes that miss the bigger picture.

| Teammate | Agent file | Focus |
|----------|-----------|-------|
| Skeptic | `skeptic.md` | Bugs, security, performance, correctness |
| Silent-failure hunter | `silent-failure.md` | Hidden errors, swallowed exceptions |
| Pattern harmonizer | `patterns.md` | Divergent implementations, inconsistent patterns |
| Comment auditor | `comments.md` | Misleading/stale/useless comments |

Each teammate gets: lens definition from `${CLAUDE_SKILL_DIR}/agents/<name>.md`, the target file list, and the project's stack (detected from package.json / go.mod / pyproject.toml or similar).

Teammates report via `SendMessage`: severity, confidence, file:line, issue, fix.

The Simplifier lens runs in wave 2, not here.

### Actionability Gate

Every finding must pass all five criteria — this filter prevents the report from being dominated by noise:

1. **Scoped** — within the target path or recent changes
2. **Specific** — points to a concrete code path, not a general observation
3. **Certain** — "this WILL cause X", not "this could theoretically..."
4. **Non-intentional** — not a deliberate pattern justified by comments, tests, or conventions
5. **Discrete** — has a single, focused fix (not "rewrite this module")

Deduplicate: when multiple lenses flag the same underlying issue, merge into one finding citing all relevant lenses. Keep the highest severity.

### Triage

| Severity | Boundary |
|----------|----------|
| CRITICAL | Security vulnerabilities, data loss risks, silent failures hiding bugs |
| HIGH | Logic errors, missing error handling on critical paths |
| MEDIUM | Pattern inconsistencies, genuine maintainability issues |
| LOW | Minor improvements |
| IGNORE | False positives, justified patterns, style-only concerns |

**Conflict resolution:** Safety > style. Cohesion > fragmentation. Direct code > abstraction. Pattern consistency > local optimization. Type annotations > JSDoc (typed code is self-documenting).

### Approval Gate

Present findings grouped by severity. Each finding: severity, confidence, location, issue, recommended fix, source lens(es).

**Stop. Wait for user to select which fixes to apply.**

After approval: implement selected fixes, verify with quality gates. If a fix breaks something, revert rather than cascade.

## Wave 2: Simplify

Spawn one Simplifier teammate (`simplifier.md`) on the post-fix codebase. Same actionability gate, triage, approval gate flow as wave 1.

## Cleanup

After all waves: `shutdown_request` to each active teammate, then `TeamDelete`.

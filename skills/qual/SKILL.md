---
name: qual
description: Orchestrate multi-lens quality analysis using agent teams. Spawns specialist teammates that analyze code from different angles, then consolidates findings for user approval before implementing fixes.
argument-hint: [path]
---

target_path = $ARGUMENTS

## Scope

If target_path provided, analyze that path. Otherwise, default to files changed since the default branch. Full-codebase analysis requires explicit user request.

## Scaling

Match analysis depth to the changeset:

- **Small changeset** (<100 lines, 1-3 files): Run the analysis yourself — read the files, apply the lens questions below, present findings. Spawning 4 specialist agents for a 50-line diff adds latency without adding insight.
- **Medium changeset** (100-500 lines, 3-10 files): Spawn 2-3 specialists for the most relevant lenses. Skip lenses that clearly don't apply (e.g., no error handling code = skip Silent-failure hunter).
- **Large changeset** (500+ lines): Full specialist team below. Summarize findings by file before presenting — large flat lists lose signal.

## Workflow

**Two-wave pipeline: wave 1 (detect + fix) → wave 2 (simplify the result).** Wave 2 exists because fixes themselves can introduce new complexity, and LLMs tend to over-engineer fixes. If wave 1 produces only minor changes, skip wave 2.

You coordinate specialists, consolidate findings with expert judgment, and never modify code without user approval.

## Wave 1: Detect Issues

### 1a: Parallel Analysis

Create a team via `TeamCreate`, then spawn specialist teammates (via `Task` tool with `team_name` parameter). Each teammate applies one lens.

Restrict all wave 1 teammates to read-only tools (`Read`, `Glob`, `Grep`, `Bash` for git commands only) — they analyze but never edit, because mixing analysis and editing in the same pass leads to fixes that miss the bigger picture.

| Teammate | Focus |
|----------|-------|
| Skeptic | Bugs, security, performance, correctness |
| Silent-failure hunter | Hidden errors, swallowed exceptions |
| Pattern harmonizer | Divergent implementations, inconsistent patterns |
| Comment auditor | Misleading/stale/useless comments |

Give each teammate: the lens definition loaded from `${CLAUDE_SKILL_DIR}/agents/<name>.md`, the target file list, and a brief description of the project's stack (detected from package.json / go.mod / pyproject.toml or similar).

All teammates report findings via `SendMessage` with severity + confidence + file:line + fix.

The Simplifier lens runs in wave 2 after fixes are applied, not here.

### 1b: Actionability Gate

Before triage, validate each finding. Drop findings that fail any criterion:

1. **Scoped** — Within the target path or recent changes
2. **Specific** — Points to a concrete code path, not a general observation
3. **Certain** — "This WILL cause X" not "this could theoretically be wrong"
4. **Non-intentional** — Not a deliberate pattern justified by comments, tests, or conventions
5. **Discrete** — Has a single, focused fix (not "rewrite this module")

Then deduplicate: when multiple lenses flag the same underlying issue, merge into one finding citing all relevant lenses. Keep the highest severity.

### 1c: Expert Triage

Categorize surviving findings:

- **CRITICAL**: Security vulnerabilities, data loss risks, silent failures hiding bugs
- **HIGH**: Logic errors, missing error handling on critical paths
- **MEDIUM**: Pattern inconsistencies, genuine maintainability issues
- **LOW**: Minor improvements
- **IGNORE**: False positives, justified patterns, style-only concerns

Pair each finding with a confidence level (high / medium / low) — severity says how bad it is, confidence says how sure you are.

**Conflict resolution:** Safety > style. Cohesion > fragmentation. Direct code > abstraction. Pattern consistency > local optimization. Type annotations > JSDoc (typed code is self-documenting).

### 1d: Present and Stop

Present consolidated report grouped by severity. Include summary counts and each finding with: severity, confidence, location, issue, recommended fix, source lens(es).

**Stop here.** Wait for user to select which fixes to apply.

### 1e: Implement + Verify

After user approval, execute approved fixes. Run the project's lint/typecheck/test commands to confirm no regressions. If a fix breaks something, report and revert rather than cascading changes.

## Wave 2: Simplify

Wave 1 fixes may introduce new complexity. The Simplifier runs on the post-fix codebase to catch over-engineering — both pre-existing and newly introduced.

**Skip wave 2 if:** wave 1 produced fewer than 5 changes, or all changes were simple one-line fixes.

### 2a-c: Same flow as wave 1

Spawn one Simplifier teammate applying its lens on the same target path. Same actionability gate, triage, present, stop for approval, implement, verify.

## Team Lifecycle

After all waves, send `shutdown_request` to each active teammate and clean up via `TeamDelete`.

## Final Verification

Run the project's full quality gate suite (lint, typecheck, tests, build) to confirm everything is clean.

---

## Lens Definitions

Each lens is a self-contained agent file under `${CLAUDE_SKILL_DIR}/agents/`. To spawn a specialist: `Read` the agent file from `${CLAUDE_SKILL_DIR}/agents/<name>.md`, then pass its full content as the `prompt` parameter in a `Task` call with `team_name`. Prepend the mode and scope to the prompt content.

| Agent file | Lens |
|------------|------|
| `skeptic.md` | Bugs, security, performance, correctness |
| `silent-failure.md` | Hidden errors, swallowed exceptions |
| `patterns.md` | Divergent implementations, inconsistent patterns |
| `comments.md` | Misleading/stale/useless comments |
| `simplifier.md` | Over-engineering, unnecessary complexity |

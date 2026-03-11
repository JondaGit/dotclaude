---
name: distill
description: >-
  Maximize net LOC reduction while improving or maintaining readability.
  Auto-applies everything except user-facing capability removal.
---

target_module = $ARGUMENTS

If no target module path is provided, ask for one.

**Optional flags** (parse from $ARGUMENTS if present):
- `--tiers 1-3` — run only specified tier range
- `--files foo.py bar.py` — scope to specific files instead of full module

You are the team lead for a distillation. You don't write production code — you orchestrate file-distiller specialists who do. Your job: establish safety, distribute work, handle structural changes (Tier 6), resolve cross-file conflicts, and enforce quality gates.

## Mission

Maximize net LOC reduction while improving or maintaining readability.

**Primary metric:** `git diff --stat` net line delta (negative = good).
**Hard constraint:** Tests pass. External behavior unchanged for auto-applied changes.

## Two Modes

- **Auto-fix** — everything preserving user-facing capabilities. File merges, abstraction collapses, test rewrites, internal API changes — if behavior is preserved and tests pass, just do it.
- **Propose** — user-facing capability removal only (endpoints, tools, CLI commands, features). You can't verify usage patterns, so these need sign-off.

## File-Distiller Agent

The agent prompt lives at `${CLAUDE_SKILL_DIR}/agents/file-distiller.md`. To spawn a specialist: `Read` the agent file, then pass its full content as the `prompt` parameter in a `Task` call with `team_name`. Prepend the file assignment and any dead code scanner findings:

```
You own `{file_path}` (and `{test_file_path}` if applicable).
Dead code scanner findings for this file: {findings or "none available"}
Tier restriction: {tier range or "all tiers"}

<full content of agents/file-distiller.md>
```

Spawn with `isolation: worktree` — prevents mid-flight collisions when teammates edit files that import from each other. Merge each teammate's worktree branch after verifying their changes pass tests.

Why teammates instead of serial analysis: a single agent doing file-by-file analysis loses steam after easy wins. It skims Tiers 2-5 and declares "code is tight." Teammates can't — each one has exactly one file and must justify their results.

## Setup (Lead Solo)

1. **Verify green baseline.** Run tests. If they fail, stop — distillation requires a passing baseline.
2. **Branch:** `git checkout -b distill/$(date +%s)`
3. **Record baseline LOC** for the target module.
4. **Run dead code scanner** (`{dead_code}`) if available. Distribute findings to relevant teammates.

## Execution

Spawn one file-distiller teammate per source file. Each handles Tiers 1-5 and Tier 7 on their assigned file.

After all teammates finish, handle **Tier 6 — Structural Simplification** yourself. This is cross-file work that teammates can't do in isolation:

- **File merges** — single-function files → merge into consumer. Thin `types.py`/`schemas.py`/`exceptions.py` → merge into adjacent modules. Any file under ~30 lines that isn't `__init__.py` — question whether it needs to exist.
- **Abstraction collapse** — ABC/Protocol with one impl → delete ABC. Factory constructing one type → inline. Service class of static methods → module functions.
- **Solution simplification** — complex library when stdlib suffices. Class with state when a function would do.
- **Config knob removal** — knobs always set to the same value in every environment.

**Do not hesitate on structural work.** Moving functions between files feels "risky" because humans fear breaking imports. You grep every reference and fix them all in one pass. The cost of a scattered codebase compounds forever; the cost of a file merge is one edit session.

Fix all import references in one pass. Run full lint + test suite.

## Verification

Run after teammates finish and again after Tier 6. All must pass:
1. Lint — 0 new warnings
2. Tests — all pass
3. Build — succeeds

**On failure:** Up to 3 targeted fixes. If still failing, stop and ask user.

## Report

Report `git diff --stat` and reduction percentage against baseline.

If no user-facing features were flagged, just report the stats. Otherwise:

```
## Auto-fix complete: -XX lines (tests pass)

Feature removal — needs your call:

1. **Remove submit_test_feedback tool** — only used during testing phase, never
   called in production. ~-40 lines. Risk: feature removal.

Which should I remove? (e.g., "1" or "all" or "none")
```

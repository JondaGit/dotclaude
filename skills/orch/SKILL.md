---
name: orch
description: Execute a complex task using an agent team. Creates a team lead that spawns teammates for parallel work units. Use for multi-file features, refactors, or any task benefiting from parallel implementation.
argument-hint: [task or plan reference]
---

task = $ARGUMENTS

You are the team lead. Orchestrate this task by delegating to teammates.

## Scaling

Match orchestration depth to task complexity:

- **Medium task** (clear boundaries, known codebase): Decompose, spawn implementers directly with clear instructions, verify. Skip analysis when you can write adequate implementation instructions yourself.
- **Large task** (cross-cutting concerns, unfamiliar domain): Full analyze-then-implement pipeline. The separation exists because implementers working from ad-hoc exploration produce inconsistent results and duplicate effort across work units. Analysis creates a single source of truth.

Start with the medium path. Spawn an analyzer for any work unit where you can't write confident implementation instructions.

## Team Protocol

All coordination flows through the team system — plain text output is not visible to teammates.

1. `TeamCreate` before spawning any work
2. `Task` with `team_name` for all teammates
3. `SendMessage` for all communication
4. After reporting: `shutdown_request` to active teammates, then `TeamDelete`

## Decomposition

Check `docs/plans/` for an existing plan (or accept a plan path from `$ARGUMENTS`). If a plan provides work units with file paths and acceptance criteria, use it directly.

When decomposing yourself: if two work units need the same file, assign that file to one unit. Concurrent edits to shared files cause merge conflicts that waste more time than parallelism saves.

## Analysis Phase

Analyzers are **read-only** — `Glob`, `Grep`, `Read` tools only. Mixing analysis and editing in one pass leads to fixes that miss the bigger picture.

Each analyzer explores target files and dependencies, then reports via `SendMessage`:
- Current state of the code
- Specific changes needed with file:line references
- Edge cases and concrete implementation steps

This report becomes the contract for the implementer. Wait for all analyzers to finish before spawning implementers.

## Implementation Phase

Each implementer receives the analyzer's report (or your direct instructions for medium tasks) as their guide. If instructions are ambiguous, they ask you rather than guessing — guessing at scale compounds into inconsistent implementations.

## Quality

After all implementers complete:
- Spawn a `/qual` teammate for multi-lens quality analysis on changed files
- Spawn a `/qg` teammate for quality gates (format, lint, typecheck, tests, build)

If issues found: spawn fix teammates for critical/high issues, re-run `/qg`, repeat until clean or escalate to user.

## Report

```
## Summary
<what was accomplished>

### Work Units
| Unit | Status | Files |
|------|--------|-------|

### Quality
| Check | Status | Issues |
|-------|--------|--------|
| /qual | PASS/FAIL | N critical, N high |
| /qg | PASS/FAIL | details |

### Issues / Deferred
<if any>
```

---
name: orch
description: Execute a complex task using an agent team. Creates a team lead that spawns teammates for parallel work units. Use for multi-file features, refactors, or any task benefiting from parallel implementation.
argument-hint: [task or plan reference]
---

task = $ARGUMENTS

You are the team lead. Orchestrate this task using teammates with strict analyze-then-implement separation.

## Scaling

This skill is invoked manually for tasks that need orchestration. Always delegate.

- **Medium task** (clear boundaries, known codebase): Skip the analyzer phase. Decompose, spawn implementers directly with clear instructions, verify.
- **Large task** (cross-cutting concerns, unfamiliar domain): Full analyze-then-implement pipeline below.

If unsure, start with the medium path. You can always spawn an analyzer for a tricky work unit without running the full pipeline.

**Team Setup:** Before spawning teammates, create a team using `TeamCreate`. All teammates must be spawned via the `Task` tool with the `team_name` parameter — this gives them shared task list, messaging via `SendMessage`, and coordinated lifecycle.

## Workflow

1. **Understand** — Read the task/plan. Check `docs/plans/` for an existing plan file, or accept a plan path from `$ARGUMENTS`. If a plan exists with work decomposition, file paths, and acceptance criteria, use it directly — skip to step 4 (Implement) for medium tasks or step 3 (Analyze) for large tasks. Only explore the codebase if no plan exists.

2. **Decompose** (skip if plan already provides work units) — Break work into parallel units. Each unit should touch different files and have clear acceptance criteria. If two units need to edit the same file, assign that file to one unit — concurrent edits to shared files cause merge conflicts that waste more time than the parallelism saves.

3. **Analyze** (skip if plan already provides file:line-level implementation steps) — Spawn read-only analyzer teammates in parallel (one per work unit). Each analyzer uses only Glob, Grep, Read tools (no Edit, Write, Bash) — it explores the target files and their dependencies, then produces a report via `SendMessage` containing: current state, specific changes needed with file:line references, edge cases, and concrete implementation steps. The report becomes the contract for implementation — this separation exists because implementers working from their own ad-hoc exploration produce inconsistent results and duplicate effort.

4. **Implement** — Spawn implementer teammates (one per work unit). Each receives the analyzer's report (or your direct instructions for medium tasks) as their sole guide. If instructions are ambiguous, they ask you rather than guessing — guessing at scale compounds into inconsistent implementations that need rework.

5. **Monitor** — Wait for implementers. Provide guidance if stuck. If one fails 3 times on the same issue, reassign or escalate to the user — repeated failure usually means missing context, not insufficient effort.

6. **Quality** — After all implementers complete, spawn quality teammates:
   - Spawn a `/qual` teammate to run multi-lens quality analysis on all changed files
   - Spawn a `/qg` teammate to run all quality gates (format, lint, typecheck, tests, build)
   - Wait for both to complete

7. **Fix** — If quality teammates find issues:
   - Critical/High issues: spawn fix teammates to resolve them
   - Re-run `/qg` after fixes
   - Repeat until clean or ask user if blocked

8. **Report** — Output what was accomplished:

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

## Constraints

- **Analyze before implement** — Never spawn implementers until all analyzers finish. The analysis report is the single source of truth.
- **Hard role separation** — Analyzers never edit. Implementers follow the report, not their own exploration.
- **Delegate** — Always delegate implementation to teammates.
- **Parallel by default** — Analyzers run in parallel. Implementers run in parallel (after all analyzers complete).
- **No artificial teammate cap** — Scale work units to the task.
- **Wait for completion** — Do not proceed to next phase until current phase teammates finish.
- **Quality is mandatory** — Never report done without /qual and /qg passing.

## Team Lifecycle

1. Create team with `TeamCreate` before spawning any teammates
2. Spawn all work via `Task` tool with `team_name` parameter
3. Use `SendMessage` for all teammate communication — plain text output is not visible to teammates
4. After reporting, send `shutdown_request` to active teammates, then `TeamDelete` to clean up

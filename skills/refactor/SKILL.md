---
name: refactor
description: Execute comprehensive codebase refactoring with architectural analysis, quality dimensions, and parallel agent teams per module. Use when you have dedicated time for deep codebase improvement.
argument-hint: [path] [--dimensions typing,security,...] [--phase N]
---

refactor_path = $ARGUMENTS

You are the team lead for a codebase refactoring. You don't write production code — you orchestrate specialists who do. Your job: establish safety, sequence work correctly, resolve conflicts between agents, and enforce quality gates.

## Scope

- No path → refactor entire codebase
- Path provided → analyze full codebase context but only refactor files within that path
- `--dimensions` → run only named agents (e.g., `--dimensions typing,dead-code,security`)
- `--phase` → resume from that phase (assumes prior phases completed and committed)

**Branch guard:** Check `git branch --show-current` before any edits. If on main/master with no worktree active, STOP — create a worktree or feature branch first. Refactors must be reversible.

!refactoring-guidelines.md

## Specialist Agents

Each file under `agents/` is a self-contained specialist. They operate in two modes:
- **Analyzer**: Read-only. Produces a findings report. Never edits.
- **Implementer**: Receives an analyzer report. Executes fixes. Never freelances.

To spawn a specialist: `Read` the agent file from `${CLAUDE_SKILL_DIR}/agents/<name>.md`, then pass its full content as the `prompt` parameter in a `Task` call with `team_name`. Prepend the mode and scope to the prompt content:

```
You are in ANALYZER mode. Scope: <path or "entire codebase">.
<full content of agents/<name>.md>
```

For implementer mode, also append the analyzer's findings report.

| Agent | Phase | Why This Order |
|-------|-------|---------------|
| `dead-code` | 1 — Structural | Deletes files. Must finish before anyone analyzes deleted code. |
| `structure` | 1 — Structural | Moves/splits/merges files. Must finish before file-local agents start. |
| `typing` | 2A — First | Types constrain all other agents. Fix types before fixing logic. |
| `error-handling` | 2B — After types | Needs accurate types to judge error paths. |
| `correctness` | 2B — After types | Needs accurate types to verify semantic contracts. |
| `duplication` | 2C — Independent | No ordering dependency. |
| `perf` | 2C — Independent | No ordering dependency. |
| `patterns` | 3 — Cross-cutting | Needs stable code to unify patterns across modules. |
| `security` | 3 — Cross-cutting | Needs stable code to audit boundaries. |
| `tests` | 3 — Cross-cutting | Tests the final refactored code, not intermediate states. |

## Scaling Judgment

Not every refactor needs the full pipeline. Match effort to scope:

- **Targeted** (1-2 agents, small module): Phase 0 yourself, spawn agents directly. No team ceremony.
- **Module-scoped** (one module, multiple agents): Phase 0, Phase 1 if structural issues exist, Phase 2 agents in parallel. Skip Phase 3 unless cross-cutting issues surfaced.
- **Full codebase**: All phases. Create a team with `TeamCreate`.

The decision: if you'd spawn 3+ agents, use a team. Otherwise, plain `Agent` calls suffice.

## Phase 0: Safety Baseline (Lead Solo)

You do this yourself. No agents. The goal: establish that the codebase is in a known-good state before anyone touches it.

**What to establish:**
1. **Tests pass.** Run the test suite. If tests fail, stop — the user must fix existing failures or explicitly accept the risk. You cannot measure regression against a broken baseline.
2. **Build succeeds.** Record the build command for later gates.
3. **Clean working tree.** If uncommitted changes exist, ask the user to commit or stash. Current HEAD is the rollback point.
4. **Project classification.** Classify as CLI tool / library / web app / API service / worker. Use the applicability matrix in `refactoring-guidelines.md` to skip irrelevant agents — don't force security analysis on a pure CLI tool or perf analysis on a library with no hot paths.
5. **Baseline metrics.** Count current lint warnings. Later gates measure *delta*, not absolute count.

If "unused" code may be dynamically selected (env vars, config files, feature flags): flag it for the user before any agent deletes it.

## Phase 1: Structural Surgery

**Why first:** These agents change *what files exist*. Every other agent needs a stable file structure to work against. Running typing analysis on a file that dead-code will delete is wasted work.

**Agents:** `dead-code` then `structure` (sequential — structure needs dead code removed first).

**The critical judgment:** File deletions and structural changes are high-risk and hard to review after the fact. Always present the analyzer's proposed changes to the user for approval before spawning the implementer:
- FILES_TO_DELETE, FILES_TO_MERGE, FILES_TO_SPLIT — each with justification
- UNUSED_EXPORTS — exports with no importers
- CYCLES_TO_BREAK — circular dependency chains

Only pass approved items to the implementer agent.

**After implementation:** Run verification gates. Commit: `refactor(phase-1): structural surgery — [summary]`

## Phase 2: Code Quality

**Why this phase exists:** With stable file structure, agents can now improve code *within* files without coordination headaches.

**Ordering within Phase 2:**
- **Batch A — typing first.** Types constrain everything else. Error-handling agents need accurate type info to judge null paths. Correctness agents need types to verify contracts. Always complete typing before spawning Batch B.
- **Batch B — error-handling + correctness.** These depend on types but not on each other. Spawn in parallel.
- **Batch C — duplication + perf.** Independent of everything. Spawn in parallel alongside or after Batch B.

**Analyze-then-implement pattern:** Spawn all applicable Phase 2 analyzers in parallel. Wait for all reports. Check for write conflicts — if two agents want to edit the same file, assign it to one agent (prefer the agent whose concern is more fundamental: typing > error-handling > correctness > duplication > perf). Then spawn implementers with their reports, respecting batch order.

Analyzers use only Glob, Grep, Read. They report findings via `SendMessage`. Implementers receive the analyzer report in their prompt and execute fixes.

**After implementation:** Run verification gates. Commit: `refactor(phase-2): code quality sweep — [summary]`

## Phase 3: Cross-Cutting Concerns

**Why last:** These agents need a global view across the now-stable, quality-improved codebase. Running pattern unification before dead code removal would unify patterns that are about to be deleted.

**Agents:** `patterns`, `security`, `tests` — spawn analyzers in parallel.

**Skip if:** Refactor is module-scoped and no cross-cutting issues surfaced in Phase 2.

**Key constraint:** Cross-cutting changes must unify toward the *dominant existing pattern* (>60% prevalence). Never introduce new patterns during refactoring. The goal is convergence, not innovation.

Serialize implementer changes that touch shared files — two agents must never edit the same file concurrently.

**After implementation:** Run verification gates. Commit: `refactor(phase-3): cross-cutting concerns — [summary]`

## Verification Gates

Run after every phase and after each batch within a phase. Gate order (each must pass before the next):

1. **Typecheck** — 0 errors
2. **Lint** — 0 new warnings vs Phase 0 baseline
3. **Tests** — all pass
4. **Build** — succeeds

**On failure:** Up to 3 targeted fixes per failing gate. If still failing after 3 attempts, stop — summarize root cause, exact error, what was tried. Ask user. Do not disable lint rules or skip tests to force a pass.

## Invariants

These hold throughout the entire refactoring, not just at specific phases:

- **Phase order is strict.** Never start Phase N+1 before Phase N's checkpoint commit. Phases build on each other's guarantees.
- **Analyze before implement.** Never spawn implementers until all analyzers in that phase finish. The lead reviews reports and resolves conflicts first.
- **Hard role separation.** Analyzers never edit. Implementers follow the report. The lead never writes production code.
- **One writer per file.** Two agents must never edit the same file. When conflicts arise, assign the file to the agent whose concern is more fundamental.
- **3-strike rule.** Same file fails verification 3 times → stop, ask user. Something structural is wrong.
- **Preserve comments.** Never strip comments, docstrings, or metadata unless they reference deleted code. LLMs silently drop these in ~7% of transformations.
- **No speculative improvement.** Fix clear quality issues. Working, well-structured code stays as-is.

## Report

When complete, summarize:

```
## Summary
<what was accomplished>

### Phases
| Phase | Agents Used | Status | Files Changed |

### Agent Status
| Agent | Applies | Status | Issues Fixed | Deferred |

### Quality Gates
| Gate | Baseline | Final | Status |
| Typecheck | N errors | N errors | PASS/FAIL |
| Lint | N warnings | N warnings | PASS/FAIL |
| Tests | N pass / N fail | N pass / N fail | PASS/FAIL |
| Build | PASS/FAIL | PASS/FAIL | PASS/FAIL |
```

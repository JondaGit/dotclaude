---
name: plan
description: Create an executable implementation plan that another agent can follow without questions. Use when planning complex features, refactors, or multi-step changes.
argument-hint: [task description]
---

task = $ARGUMENTS

Create an executable implementation plan for this task.

## The One Rule

The executing agent cannot read this conversation. They get only the plan file and the codebase. Every assumption you leave implicit becomes a guess they make wrong. Write for a competent stranger who has zero context about why this change exists.

## When NOT to Plan

If the change is one sentence and 1-2 files — just do it. Planning reduces risk on complex changes. On simple ones, it adds latency without reducing risk. Match plan complexity to task complexity: a 3-step fix needs 3 lines, not 11 sections.

## Exploration

Understand the codebase before writing the plan. Read the relevant code paths yourself.

**Scale up** when you'd need to sequentially explore 5+ files across different concerns: create a team via `TeamCreate` with parallel read-only exploration teammates (codebase patterns, domain research via web search). Synthesize their findings.

**Scale down** for single-concern changes: read the files yourself, write the plan.

## Decomposition Judgment

Choose based on the task shape, not habit:

| Strategy | When | Risk it mitigates |
|----------|------|--------------------|
| **Vertical slice** | Multiple independent behaviors | Integration surprises — each slice proves end-to-end |
| **Walking skeleton** | Uncertain integration path | Late-stage "it doesn't connect" — proves the wiring first |
| **Layer-by-layer** | Clear layers, different complexity zones | Allows parallel work; natural when data model drives everything |

Default to vertical slice. Switch when the task shape clearly fits another.

## Plan Structure

Include all required sections. Include optional sections when the task warrants them — not by default.

### Required Sections

**Background & Problem** — The *why*. Without this, the executor optimizes for the wrong thing.

**Key Concepts** — Domain terms, sentinel values, non-obvious patterns. Table format. The executor will misname things and misuse patterns without this.

**Exploration Checklist** — Files to read *before* coding. The executor explores from these starting points. Always include "find a similar existing feature" — pattern precedent prevents reinvention.
```
- [ ] Schema: `src/db/schema.ts` — understand data structure
- [ ] Service: `src/core/service.ts` — existing patterns
- [ ] Precedent: find a similar existing feature — note its file structure, naming, and patterns to follow
```

**Verification Strategy** — How the executor confirms each milestone works. High-risk changes need per-step checks; low-risk can verify at boundaries.

**Done When** — Acceptance criteria checklist. The executor cannot ask "is this enough?"

### Optional Sections

**Questions** — Surface blockers. Provide concrete options with tradeoffs, not open-ended asks.

**Approach** — 2-3 sentences: strategy, key decision, why this over alternatives.

**Changes** — Grouped by component:
```
### Component Name
- `[NEW]` `path/file.ts` — purpose
- `[MOD]` `path/file.ts` — what changes
- `[DEL]` `path/file.ts` — why removing
```

**Steps** — Atomic tasks with file references and size estimate (S: <1h, M: 1-4h, L: 4h+ → decompose further):
```
1. **Milestone** — goal
   - 1.1 [S] Action → `file.ts:ClassName.method()` — verification
```

**Edge Cases** — 3-5 likely per component (empty/null, large/slow, auth/permission, concurrency). Note how the plan handles each.

**Work Decomposition** — For /orch:
```
Parallel: Unit A (files), Unit B (files)
Sequential: Unit C depends on A
```

**Risks** — Only non-obvious ones with mitigations. High-risk steps get rollback guidance.

## Self-Test

Before saving: re-read the plan as if you have *no memory* of this conversation. Can you execute it without asking a single question? If not, the plan isn't done.

## Save Location

`docs/plans/<type>-<short-name>.md`

Types: `feat-`, `fix-`, `refactor-`, `chore-`

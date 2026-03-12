---
name: code
description: Implement a plan with incremental execution, quality gates, and 3-strike error recovery. Use when ready to code from an existing plan or task description.
---

task = $ARGUMENTS

Implement the plan. CLAUDE.md standards and quality gates apply throughout.

## Incremental Execution

Commit after each meaningful step — a failing change on top of 5 uncommitted steps is much harder to debug than one on top of a clean commit.

## Completion Check

Before declaring done, verify:
- No TODOs, FIXMEs, stubs, or incomplete implementations remain
- No silent fallbacks — default/fallback values inserted to make type errors disappear instead of fixing the actual type or data issue. Models reflexively add these; catch yourself.

## Deviations from Plan

- **Minor** (naming, internal structure): document the reason and continue
- **Major** (different approach, new dependencies, scope change): stop and present options with trade-offs — the plan was approved, departing significantly needs explicit buy-in

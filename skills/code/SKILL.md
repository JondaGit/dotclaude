---
name: code
description: Implement a plan with incremental execution, quality gates, and 3-strike error recovery. Use when ready to code from an existing plan or task description.
---

task = $ARGUMENTS

Implement the plan and ensure quality gates pass. Follow all coding standards from CLAUDE.md — this skill adds execution discipline on top.

## Before Starting

Read the plan or task description fully. If any part is unclear or missing context, stop and ask — implementing against ambiguous requirements produces code that needs rework, which costs more than a clarifying question.

## Execution

Work incrementally: implement a step, verify it works, commit as a save point, then move on. This matters because a failing change on top of 5 uncommitted steps is much harder to debug than a failing change on top of a clean commit.

**Before calling it done, check for:**
- Completeness: no TODOs, FIXMEs, stubs, or incomplete implementations
- Correctness: handles all requirements from the plan
- Silent fallbacks: no default/fallback values inserted to silence type errors — fix the actual type or data issue

## Error Recovery

When something breaks:
- **First attempt**: Try a different approach (different algorithm, different API usage)
- **Second attempt**: Revert to last working state, try a fundamentally different strategy
- **Third attempt**: Stop and tell the user — report what you tried, what failed, and what context you're missing

Repeated failure usually means missing context or a wrong assumption, not insufficient effort. Continuing to hammer the same approach wastes time.

**Hard stops** (don't retry, just ask):
- Same file fails to compile/typecheck/lint 3 times
- Same test fails 3 times after different fixes
- You notice yourself repeating the same action

## Deviations from Plan

- Minor (naming, internal structure): document the reason and continue
- Major (different approach, new dependencies, scope change): stop and present options with trade-offs — the plan was approved, so departing from it significantly needs explicit buy-in

## Quality Gates

After completing implementation, run the project's configured quality gates — typically formatting, linting, type checking, tests, and build. Report PASS or FAIL with specific errors.

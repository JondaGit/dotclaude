# Refactoring Reference

Shared reference for the `/refactor` skill. Dimension details live in `agents/*.md`.

---

## Project-Type Applicability

Not every agent applies to every project. Skip irrelevant agents rather than forcing them.

| Agent | Dimensions | CLI Tool | Library/SDK | Web App | API Service | Worker/Queue |
|-------|-----------|---------|-------------|---------|-------------|-------------|
| typing | 1, 8 | Yes | Yes | Yes | Yes | Yes |
| dead-code | 3 | Yes | Yes | Yes | Yes | Yes |
| error-handling | 2, 4, 9 | Yes | Yes | Yes | Yes | Yes |
| correctness | Logic & Correctness | Yes | Yes | Yes | Yes | Yes |
| structure | 5, 15, 17 | Yes | Yes | Yes | Yes | Yes |
| duplication | 6, 7 | Yes | Yes | Yes | Yes | Yes |
| patterns | 10, 11, 16, 18, 20 | Yes (CLI flags) | Yes (Public API) | Yes (Routes) | Yes (Endpoints) | Yes (Messages) |
| security | 14, 19 | Rarely | Rarely | Yes | Yes | Depends |
| tests | 12 | Yes | Yes | Yes | Yes | Yes |
| perf | 13 | Rarely | Rarely | Yes | Yes | Yes |

---

## Verification Gates

### Gate Pipeline

Run in this order. Each gate must pass before proceeding to the next. Use the project's configured tooling.

| Order | Gate | Pass Criteria |
|-------|------|---------------|
| 1 | Typecheck | 0 errors |
| 2 | Lint | 0 new warnings vs Phase 0 baseline |
| 3 | Tests | All pass |
| 4 | Build | Succeeds |

### On Failure

Iterate up to 3 targeted fixes per failing gate. If still failing after 3 attempts:
1. Stop attempting fixes
2. Summarize: root cause, exact error output, what was tried
3. Ask user for guidance

Do not apply speculative fixes beyond the 3-attempt budget. Do not disable linting rules or skip tests to force a pass.

### Manual Gates

For agents without automated gates (error-handling, correctness, structure, duplication, patterns, security, tests, perf): document evidence in report (files reviewed, patterns found/fixed, what remains).

### Completion

Refactor is complete ONLY when:
- All applicable agents show PASS or DEFERRED (with justification)
- All verification gates pass
- A checkpoint commit exists for each completed phase
- A final summary lists: agents passed, issues fixed (count), issues deferred (count + reasons)

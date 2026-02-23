---
name: lint
description: Run all quality gates (format, lint, typecheck, tests, build) and report PASS/FAIL per gate. Use after implementing changes to verify quality.
argument-hint: [path]
---

lint_path = $ARGUMENTS

If lint_path is not provided, run quality gates on entire codebase.
If lint_path is provided, focus linting on that specific path.

## Execution Order

1. Format: run the project's configured formatter
2. Lint: run the project's configured linter (with auto-fix if available)
3. Typecheck: run the project's configured type checker (if applicable)
4. Tests: run the project's configured test runner
5. Build: run the project's configured build step (if applicable)

## Output

| Gate      | Status    | Issues               |
| --------- | --------- | -------------------- |
| Format    | PASS/FAIL | — or N files changed |
| Lint      | PASS/FAIL | — or N errors        |
| Typecheck | PASS/FAIL | — or N errors        |
| Tests     | PASS/FAIL | N/M passed           |
| Build     | PASS/FAIL | — or error           |

If failures: list top 3 issues with `file:line`, not full error dump.

Do NOT commit or push.

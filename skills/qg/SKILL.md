---
name: qg
description: Run all quality gates (format, lint, typecheck, tests, build) and report PASS/FAIL per gate. Use after implementing changes to verify quality.
argument-hint: [path]
---

target_path = $ARGUMENTS

Run the project's quality gates in order: format, lint (with auto-fix), typecheck, tests, build. Skip gates the project doesn't have configured. If target_path is provided, scope to that path.

## Output

| Gate      | Status    | Issues               |
| --------- | --------- | -------------------- |
| Format    | PASS/FAIL | — or N files changed |
| Lint      | PASS/FAIL | — or N errors        |
| Typecheck | PASS/FAIL | — or N errors        |
| Tests     | PASS/FAIL | N/M passed           |
| Build     | PASS/FAIL | — or error           |

On failure: top 3 issues with `file:line`. No full error dumps — the caller needs actionable locations, not noise.

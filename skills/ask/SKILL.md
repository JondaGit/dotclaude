---
name: ask
description: Research-only mode. Answer questions about the codebase, architecture, or technical topics without editing any files. Use when the user wants to understand code, investigate behavior, get explanations, ask "how does X work", "why does Y happen", "where is Z defined", or any question that needs research not code changes.
argument-hint: <question>
---

# Research-Only Mode

You are in **research-only mode**. Your job is to answer the user's question thoroughly — never to edit, write, or create files.

## Hard constraints

- **NEVER** use the Edit, Write, or NotebookEdit tools. Not even "just a small fix." Not even if you spot a bug. Not even if the user's question implies a change. If a change is needed, describe it — do not make it.
- **NEVER** run commands that modify files (no `sed`, `awk`, `tee`, `>`, `>>`, `patch`, `git commit`, `git stash`, etc.).
- You **may** read files, search the codebase, run exploration commands (`git log`, `git diff`, `git blame`, `ls`, `python -c "..."` for quick computations), and fetch web resources.
- You **may** run scripts that produce output without side effects (e.g., `uv run python -c "import ast; ..."` to parse something, `pnpm --dir frontend typecheck` to check types).
- You **may** use Agent/Explore subagents for deep research — they inherit the same no-edit constraint.

## How to answer

1. **Investigate first.** Read the relevant code, search for patterns, check git history, look up docs if needed.
2. **Be specific.** Reference exact file paths and line numbers. Quote the relevant code.
3. **Be direct.** Lead with the answer, then provide supporting evidence.
4. **If a change is warranted**, describe what you would change and where — but do not make it. Say something like: "To fix this, you'd change X in `src/foo.py:42` from A to B."

## Scope

The user's question: $ARGUMENTS

If no question was provided, ask the user what they'd like to know.

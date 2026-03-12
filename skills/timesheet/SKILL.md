---
name: timesheet
description: Generate monthly work summary from git commits. Use for monthly reporting or time tracking.
---

Generate a markdown table summarizing the current user's git commits for the current month.

## Data Collection

Gather commits from all repositories and submodules in the working directory. Scope to the current month (1st through today) and the current user's git identity (`git config user.name`).

## Output Format

Markdown table, one row per day with commits:

| Day | Summary |
|-----|---------|
| **DD.MM.** | Short summary of work themes |

## Summary Style

Summaries should read like personal shorthand — what you'd jot in a work log, not what you'd write in a PR description.

- **Group by theme**, not by commit. "knowledgebase + RAG tools" over listing each commit separately.
- **Target 10-20 words per day** (minimum 8 — expand terse single-commit days with enough context to be useful later).
- **Skip noise**: lint fixes, merge commits, trivial reformats — unless they represent significant effort.
- **Terse phrasing**: "form table extraction + compliance" not "Added form table extraction feature and implemented compliance checks."

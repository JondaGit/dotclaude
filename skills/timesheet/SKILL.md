---
name: timesheet
description: Generate monthly work summary from git commits. Use for monthly reporting or time tracking.
---

Generate monthly work summary from git commits.

## Execution

1. Determine current month's date range (1st to today)

2. Fetch commits from all relevant repositories/submodules:

   Use: `git log --since="{year}-{month}-01" --until="{year}-{month}-{today+1}" --format="%ad | %an | %s" --date=short --no-merges`

3. Determine the current user's git identity via `git config user.name`. Filter commits by that author only.

4. Group commits by date

5. For each day with commits, create a SHORT summary:
   - Combine related commits into themes
   - Separate sections by repository/submodule if applicable
   - Target ~10-20 words per day (min 8 words — expand terse summaries with context)
   - Skip lint/merge/trivial commits in summary

6. Output as markdown table:

   | Day | Summary |
   |-----|---------|
   | **DD.MM.** | Short summary of work themes for the day |

## Style

- Be terse: "knowledgebase + RAG tools" not "Added knowledgebase feature and implemented RAG tools"
- Group related: "form table extraction + compliance" not listing each commit
- Skip obvious: don't mention "fix", "lint", "merge" unless significant

---
name: jira
description: Use when the user asks to create, update, search, link, or transition JIRA issues, epics, or sub-tasks, or otherwise manage work in JIRA.
---

Manage JIRA work via the Atlassian MCP tools. Capture intent first, then act.

## Language

Always write summaries, descriptions, and comments in **English**, even if the user speaks another language. Translate if needed.

## Writing Style

JIRA fields are read by people scanning a backlog — be brief, not verbose.

- **Summary (title):** short imperative phrase capturing the *intent* — what should be true when this is done. Aim for ≤ 8 words. No trailing period.
- **Description:** the *why* and the *what to know*, not the full implementation. A few sentences or 3–6 bullets. Use bullets when listing acceptance criteria, scope, or affected areas. Skip filler ("This ticket is about…"). Omit sections that add nothing.
- **Comments:** terse status notes — what changed, what's blocked, what's next.

Capture the *meaning* of the task, not a transcript of the conversation that produced it.

## Epic Organization

When the user asks for several tickets that share a goal, theme, or feature, create an **epic** and link the child issues to it. Signs they belong together: shared subject, shared deadline, one would be meaningless without the others, the user described them as a single initiative.

- One epic, multiple child tasks/stories/bugs — link via the epic's issue key as parent.
- Don't create an epic for a single isolated ticket.
- Don't bundle unrelated work into one epic just because it was mentioned in the same message.

If unsure whether items belong under one epic, prefer asking once over guessing wrong — wrong grouping is annoying to clean up later.

## Workflow

1. **Resolve site + project.** First call needs a `cloudId` — try the site hostname (e.g. `blindspot-solutions.atlassian.net`) or use `getAccessibleAtlassianResources`. If the project key isn't obvious from context, use `getVisibleJiraProjects` with a `searchString`.
2. **Pick issue type.** Match what the user wants: Task / Story / Bug / Epic / Sub-task. Project metadata (`getJiraProjectIssueTypesMetadata`) lists the exact names — type names may be localized.
3. **Create epic first** when grouping is needed, then create children referencing it as parent.
4. **Return links.** After every create/edit, show the browse URL (`https://<site>/browse/<KEY>`) so the user can verify.

## Common Operations

| Intent | Tool |
|---|---|
| Create issue | `createJiraIssue` |
| Edit fields | `editJiraIssue` |
| Read one issue | `getJiraIssue` |
| Search | `searchJiraIssuesUsingJql` |
| Comment | `addCommentToJiraIssue` |
| Change status | `getTransitionsForJiraIssue` → `transitionJiraIssue` |
| Link issues | `createIssueLink` (use `getIssueLinkTypes` for valid names) |

## Confirm Before Destructive Edits

Editing summaries, deleting links, or transitioning issues others depend on is visible to the whole team. For bulk changes or anything that overwrites existing content, confirm scope with the user before running.

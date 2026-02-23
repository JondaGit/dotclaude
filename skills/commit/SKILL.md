---
name: commit
description: Commit and push changes following conventional commits. Use when ready to commit completed work.
---

## What This Skill Does

Commit completed work and push it to the remote. Follow conventional commits format.

## Branch Safety

Committing to the wrong branch is the most common costly mistake. Before any commit:

- **Default branches (`main`/`master`) are off-limits.** Direct commits bypass code review and make rollback painful. Auto-create a `<type>/<short-slug>` feature branch from the changes (e.g., `fix/dialog-content-overflow`, `feat/oauth-flow`) and proceed.
- **Wrong feature branch is equally dangerous.** After context switches, verify the branch name relates to what you're committing. Auth changes on `feature/geo-optimization` means you're probably on the wrong branch — confirm with the user.
- **Submodules have independent branches.** Each submodule with changes needs its own branch check via `git -C <submodule> branch --show-current`. A submodule can be on `main` while the parent is on a feature branch.

## Commit Format

!`cat ~/.claude/skills/conventional-commits.md`

### Message Quality

The commit message is the only artifact that survives rebases, squashes, and file renames. Make it count:

- Imperative mood ("add OAuth flow" not "added OAuth flow")
- Capture *intent*, not *implementation* — the diff shows what changed, the message explains why
- If you can't write a focused message, the commit probably contains unrelated changes — split it

## Irreversible Operations

These operations rewrite shared history or destroy local state. Always confirm with the user before executing, even if they seem implied by the task:

- `git push --force` (rewrites remote history others may have pulled)
- `git reset --hard` (destroys uncommitted work permanently)
- Amending pushed commits (rewrites history for anyone who pulled)
- Deleting remote branches (may destroy others' work-in-progress)
- Rebasing shared branches (rewrites history for all collaborators)

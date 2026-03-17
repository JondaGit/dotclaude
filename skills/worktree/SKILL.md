---
name: worktree
description: Create a git worktree for isolated feature development. Use when starting work on a new feature branch.
argument-hint: <task description or branch name>
allowed-tools: Bash
---
input = $ARGUMENTS

Create an isolated worktree for feature development.

## Branch Name

Derive from user input (or ask if not provided). Default format: `<type>/<kebab-description>` using conventional commit types (`feat` when ambiguous). **But check `git branch` first** — if the repo uses a different convention (e.g., `feature/JIRA-123-desc`), match it.

Show the derived name before proceeding.

## Worktree Location

- `{repo_root}/.claude/worktrees/{branch_slug}` where `branch_slug` replaces `/` with `-`
- `repo_root` = `git rev-parse --show-toplevel`
- Ensure `.claude/worktrees/` exists and is in `.gitignore`

## Base Branch

Always branch from the latest remote default branch, not from `HEAD`:

1. Detect default branch: `git symbolic-ref refs/remotes/origin/HEAD | sed 's|refs/remotes/origin/||'` (fallback: try `main`, then `master`)
2. Fetch latest: `git fetch origin {default_branch}`
3. Use `origin/{default_branch}` as the start point

Create: `git worktree add -b {branch} {directory} origin/{default_branch}`
If branch already exists: `git worktree add {directory} {branch}` (no `-b`).

After creation, symlink gitignored files so the worktree is immediately functional without reinstalling:
```
bash ~/.claude/skills/worktree/scripts/symlink-gitignored.sh {repo_root} {directory}
```

## Submodules

`git worktree add` on a parent doesn't create worktrees for submodules — they'd still point at the original branch. Before creating anything, determine scope:

- **Single submodule only** — worktree in that submodule
- **Parent + submodule(s)** — worktrees in both parent AND each affected submodule
- **Ambiguous** — ask

Run the symlink script for each submodule too:
```
bash ~/.claude/skills/worktree/scripts/symlink-gitignored.sh {repo_root}/{submodule} {directory}/{submodule}
```

## Output

Show: worktree path, `claude --cwd {directory}` command, reminder to use `/worktree-clean` when done, and `git worktree list`.

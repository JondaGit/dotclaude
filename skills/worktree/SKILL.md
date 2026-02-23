---
name: worktree
description: Create a git worktree for isolated feature development. Use when starting work on a new feature branch.
argument-hint: <task description or branch name>
allowed-tools: Bash
---
input = $ARGUMENTS

Create an isolated worktree for feature development.

## Branch Name

Derive from user input (or ask if not provided). Format: `<type>/<kebab-description>` using conventional commit types. Default `feat` when ambiguous.

**Convention override:** Check `git branch` first. If the repo uses a different convention (e.g., `feature/JIRA-123-desc`), match it.

Show the derived name before proceeding.

## Worktree Setup

Directory convention:
- `repo_root` = `git rev-parse --show-toplevel`
- `branch_slug` = branch name with `/` → `-`
- Path: `{repo_root}/.claude/worktrees/{branch_slug}`
- Ensure `.claude/worktrees/` exists and is in `.gitignore`

Create: `git worktree add -b {branch} {directory} HEAD`
If branch already exists: `git worktree add {directory} {branch}` (no `-b`).

After creation, symlink gitignored files (node_modules, venv, .env, build caches) so the worktree is immediately functional without reinstalling:
```
bash ~/.claude/skills/worktree/scripts/symlink-gitignored.sh {repo_root} {directory}
```

## Submodules

Each git submodule is an independent repository — `git worktree add` on the parent doesn't create worktrees for submodules, so they'd still point at the original branch. Before creating anything, determine scope:

- **Single submodule only** → worktree in that submodule
- **Parent + submodule(s)** → worktrees in both parent AND each affected submodule
- **Ambiguous** → ask

Run the symlink script for each submodule too:
```
bash ~/.claude/skills/worktree/scripts/symlink-gitignored.sh {repo_root}/{submodule} {directory}/{submodule}
```

## Output

Show: worktree path, `claude --cwd {directory}` command, reminder to use `/worktree-clean` when done, and `git worktree list`.

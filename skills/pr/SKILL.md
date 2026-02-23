---
name: pr
description: Create a pull request from the current worktree branch. Commits uncommitted changes, pushes, and opens a PR with conventional formatting.
---

Prepare and open a PR/MR for the current branch — from "work is done" to "PR is open and reviewable."

## The Core Problem

The reviewer arrives cold. They didn't write this code, and neither did another human — an agent did. The PR description is the only bridge between "what happened in the agent's context" and "what the human needs to decide." Every section exists to serve that handoff. If a section doesn't help the reviewer, cut it.

## Principles

**Assess before acting.** The right action depends on current state — existing PRs, branch status, multiple repos with changes, dirty worktrees. Look first.

**Multi-repo awareness.** Work spanning multiple repositories (parent + submodule, multiple services) needs a separate PR per repo. Cross-reference paired PRs. Always `cd` into each repo root before running the create command — git tools infer the remote project from the current directory.

**Confirm destructive or unusual actions.** Force-pushing, non-default base branches, pushing to a branch with an existing PR — pause and confirm.

**Pass explicit title and body — but verify flags first.** `--fill` conflicts with explicit title/body in both `gh` and `glab`. Always use heredoc for the body. The flag names differ by tool: `gh` uses `--body`, `glab` uses `--description`. When in doubt, check `--help` before invoking — a failed MR create can leave orphaned remote state.

## Conventional Commits Reference

!`cat ~/.claude/skills/conventional-commits.md`

## PR Body

Omit sections that don't apply. No placeholders, no filler.

**Task** — issue link, or one-line description of what was asked.

**Summary** — what + why. Approach chosen and why: "X over Y because Z." 2-4 lines max.

**Changes** — one bullet per meaningful change, grouped by area. A change list, not a file list.

**Self-Review** — markdown checklist of what the agent verified (`[x]`) and what it couldn't (`[ ]`). One concrete claim per item.

**Human Review** — checklist of specific things the reviewer should verify. Action items only — where human judgment matters most.

```
$(cat <<'EOF'
## Task

## Summary

## Changes

-

## Self-Review

- [x]
- [ ]

## Human Review

- [ ]

EOF
)
```

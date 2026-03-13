---
name: rebase
description: Rebase current branch onto a target branch, resolving conflicts and handling submodules. Use when the user says "rebase", "rebase on master", or wants to update their branch.
argument-hint: [target-branch] (defaults to master/main)
---
input = $ARGUMENTS

Rebase the current feature branch onto a target branch. Goal: clean linear history, ready to push.

## Submodule Protocol

Submodules change the rebase from a single-repo operation into a coordinated multi-repo operation. The ordering matters because the parent repo stores submodule SHAs — if you rebase the parent first, its commits reference pre-rebase submodule SHAs that immediately become stale.

**Only rebase submodules that are on their own feature branches.** Submodules on detached HEAD at a pinned commit are dependencies, not co-developed code — leave them alone.

**Ordering — always submodules-first:**
- Rebase: submodules first, then parent
- After parent rebase: amend the parent's tip commit to reference the rebased submodule SHAs (`git add {submodule} && git commit --amend --no-edit`)
- Push: submodules first, then parent (parent refs must resolve on remote)

## Conflict Heuristics

Most conflicts resolve through standard judgment. Two non-obvious cases:

- **Migration files, version bumps, lockfiles, config** — prefer the target branch version. These represent the latest agreed-upon state; merging them produces broken artifacts.
- **Submodule pointer conflicts** — accept the target's ref during rebase (`git checkout HEAD -- {submodule}`). The correct ref gets set after the submodule itself is rebased.

## Flow

Present the rebase plan before starting — which repos, how many commits each, target branch.

After rebase, force-push with `--force-with-lease` (submodules first, then parent). Invoking `/rebase` is the user's intent to rebase and push — no additional confirmation needed. Report: repos rebased, commits applied/dropped, conflicts resolved.

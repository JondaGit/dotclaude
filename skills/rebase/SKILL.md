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

## Conflict Resolution

Rebase bypasses pre-commit hooks — git's design. No local gate catches broken code until you explicitly verify post-rebase.

### Heuristics

- **Migration files, version bumps, lockfiles, config** — prefer the target branch version. These represent the latest agreed-upon state.
- **Submodule pointer conflicts** — accept the target's ref during rebase (`git checkout HEAD -- {submodule}`). The correct ref gets set after the submodule itself is rebased.
- **Refactor vs. feature** — if the target branch removed or extracted code the feature branch references, the removal wins. Don't resurrect dead code; rewire to the new location/API.
- **Partial survival** — if a resolution keeps *usage* of something (component, function, variable), verify the *declaration* and *import* also survived. A JSX element means nothing if its import and state were dropped. Grep the resolved file for every symbol from the feature side.
- **Semantic drift** — if the target branch changed an API's contract (not just its signature), re-test the feature's assumptions against the new behavior. Compile-time survival doesn't mean correctness.

## Flow

Present the rebase plan before starting — which repos, how many commits each, target branch.

After rebase completes, **run `/qg` before pushing.** Rebase bypasses hooks; this is the only safety net.

Force-push with `--force-with-lease` (submodules first, then parent). Invoking `/rebase` is the user's intent to rebase and push — no additional confirmation needed. Report: repos rebased, commits applied/dropped, conflicts resolved, quality gate results.

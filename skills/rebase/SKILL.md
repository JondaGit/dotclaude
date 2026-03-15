---
name: rebase
description: Rebase current branch onto a target branch, resolving conflicts and handling submodules. Use when the user says "rebase", "rebase on master", or wants to update their branch.
argument-hint: [target-branch] (defaults to master/main)
---
input = $ARGUMENTS

Rebase the current feature branch onto a target branch. Goal: clean linear history, ready to push.

## Submodule Coordination

The parent repo stores submodule SHAs — if you rebase the parent first, its commits reference pre-rebase submodule SHAs that immediately become stale. Always go submodules-first for rebase, SHA update, and push.

**Only rebase submodules on their own feature branches.** Submodules on detached HEAD at a pinned commit are dependencies — leave them alone.

After parent rebase completes, amend the tip commit to reference rebased submodule SHAs: `git add {submodule} && git commit --amend --no-edit`.

## Conflict Resolution

Rebase bypasses pre-commit hooks — the only safety net is an explicit post-rebase quality gate.

**Heuristics:**
- **Lockfiles, migrations, config, version bumps** — accept the target branch version. These represent the latest agreed-upon state.
- **Submodule pointer conflicts** — accept the target's ref (`git checkout HEAD -- {submodule}`). The correct ref gets set after the submodule itself is rebased.
- **Refactored-away code** — if the target removed or relocated code the feature branch uses, the removal wins. Rewire to the new location/API; don't resurrect dead code.

**Failure mode — partial survival:** When a resolution keeps *usage* of a symbol (component, function, import target), verify the *declaration* and *import* also survived. A JSX element means nothing if its import and state were dropped. Grep the resolved file for every symbol from the feature side before continuing.

## Migration Reconciliation

**The trap:** Rebase re-chains `down_revision` pointers but does NOT execute the target branch's new migrations against the local database. The `alembic_version` row still holds the feature branch's old tip revision — so `alembic upgrade head` reports "already at head" while the target's schema changes were never applied. The app crashes at runtime on missing columns/tables.

**Fix:** Use `alembic stamp {fork-point-revision}` (the revision just before the first new target migration), then `alembic upgrade head`. Use `stamp`, not `downgrade` — `downgrade` executes destructive down-migrations; `stamp` just moves the version pointer.

**Also:** After migration re-chaining, verify `current_head` in `pyproject.toml` matches the actual chain tip — CI validates this.

## Flow

Present the rebase plan before starting — which repos, how many commits each, target branch.

After rebase completes:
1. Reconcile migrations if any migration files were touched.
2. Run `/qg` — rebase bypasses hooks; this is the only safety net.

Force-push with `--force-with-lease` (submodules first, then parent). Invoking `/rebase` is the user's intent to rebase and push — no additional confirmation needed.

Report: repos rebased, commits applied/dropped, conflicts resolved, migration reconciliation results, quality gate results.

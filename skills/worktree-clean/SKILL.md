---
name: worktree-clean
description: Remove a git worktree and its local branch. Use from the main repo, not from inside the worktree.
argument-hint: [worktree-path]
allowed-tools: Bash
---
worktree_path = $ARGUMENTS

Clean up a local worktree and its local branch.

## Scope: Local Only

This skill manages local git state — worktrees and local branches. Remote branches are out of scope because they carry state that's invisible locally: open MRs, CI pipelines, review comments, deployment triggers. Deleting a remote branch can auto-close an MR and destroy that context silently. Only the user should decide when a remote branch is deleted.

## Key Constraints

**Verify you're not inside the worktree.** Git can't remove a worktree that's your current working directory.

**Investigate before forcing.** When removal fails due to unclean state or unmerged branch, inspect the actual state — `git status` and `git diff` in the worktree, whether the branch was pushed or has a merged MR. Trivial leftovers (build artifacts, debug logs, already-pushed work) → force-remove autonomously. Substantive uncommitted or unmerged work → describe what you found and let the user decide.

**Prune after removal.** `git worktree prune` cleans stale internal references that `git worktree remove` can leave behind.

## Flow

Resolve which worktree to remove (from argument or by listing) → remove the worktree → delete the local branch → prune → confirm what's left.

If no argument is provided, list worktrees and ask the user which to remove.

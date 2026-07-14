---
name: feature
description: Use when the user asks to build a new feature end-to-end — from a fresh branch off the default branch through implementation, BDD coverage, and quality gates. Trigger on "start a feature", "new feature", "implement X on a new branch", or any request to build something that should land as its own branch and MR, even if the user doesn't mention branching.
argument-hint: <feature description>
---

feature = $ARGUMENTS

Deliver a feature on a fresh branch: sync the default branch, branch off it, implement, cover with BDD where the repo supports it, gate, then hand off for review. Do not commit, push, or open an MR until the user approves — the review handoff at the end exists so nothing leaves the machine unreviewed.

If the feature description is missing or too vague to scope, ask before touching git.

## 1. Preflight

Check `git status --porcelain`. If there are uncommitted changes — staged, unstaged, or untracked files that could block checkout or bleed into the new branch — **stop and ask** the user how to proceed (stash, commit, or abort). Never stash or discard on your own initiative: those changes may be work in progress you can't distinguish from junk.

## 2. Sync Default Branch

1. Detect the default branch: `git symbolic-ref refs/remotes/origin/HEAD | sed 's|refs/remotes/origin/||'` — fallback: check whether `origin/main` or `origin/master` exists.
2. `git checkout {default_branch}` and `git pull --ff-only origin {default_branch}`.

If checkout or pull fails, report the exact error and ask — don't force, reset, or merge to work around it.

## 3. Create Feature Branch

Derive the name from the feature description. Default format: `feat/<kebab-description>` — **but check `git branch -a` first** and match the repo's existing convention (e.g., `feature/JIRA-123-desc`). Show the derived name, then `git checkout -b {branch}`.

## 4. Implement

CLAUDE.md standards apply throughout. Before writing code in an unfamiliar area, locate 2+ existing implementations of similar patterns and match their conventions. For multi-step or ambiguous features, plan first (`/plan`); for straightforward ones, implement directly.

Stay on scope: implement the requested feature, surface anything broken you find along the way, fix it only if it blocks you.

## 5. BDD Coverage

Check whether the repo has E2E BDD set up: `playwright-bdd` in package dependencies, existing `.feature` files, or a bddgen/cucumber config. 

- **Set up** → invoke the `/bdd` skill to cover the feature's user-facing behavior.
- **Not set up** → skip entirely. Do not introduce BDD tooling — that's an infrastructure decision the user hasn't made.

## 6. Quality Gates

Run `/qg`. Fix failures at the source — no suppressions without permission. Iterate until PASS or you hit an error-recovery HALT.

## 7. Review Handoff

Stop and report:

- **Summary** — what was built and how: the approach taken, files touched, notable decisions or trade-offs.
- **BDD** — scenarios added, or why skipped.
- **Gates** — PASS/FAIL table from `/qg`.

Then ask the user to review and whether to commit, push, and create an MR. Only on approval: `/commit`, push the branch, then `/pr`.

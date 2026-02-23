---
name: review
description: Review a PR/MR or local diff for correctness, security, and quality. Use when reviewing code changes before merge.
argument-hint: [PR number, branch name, or local path]
---

target = $ARGUMENTS

If target is not provided, review the PR/MR of the current branch.
If target is a local path or branch name (not a PR/MR number), skip platform detection and use `git diff` directly.

## Fetching the Diff

Use the platform's CLI to fetch the PR/MR diff, description, and CI status.

## Gathering Context

The diff alone shows what changed, not what could break.

1. Read full files for each changed file — understand the surrounding code, not just the hunks
2. Read the PR description and any linked issues for intent and acceptance criteria
3. For complex changes, trace one level of callers/callees to assess blast radius
4. Check CI status — note pass/fail state

## Scaling

- **Small PR** (<5 files, <200 lines): Review inline, skip formality. Focus on correctness and security.
- **Medium PR** (5-20 files): Full review with structured output below.
- **Large PR** (20+ files or 1000+ lines): Flag the size as a finding. Prioritize security-sensitive files, core business logic, and public API changes. Cap findings at ~10 most impactful. Note which files were reviewed in depth vs. skimmed.

## Review Focus

Skip style and formatting issues that linters catch. Focus on logic, architecture, and context-dependent concerns.

1. **Scope** — Is the PR focused on one concern? Any files that don't belong?
2. **Correctness** — Does the logic match the stated intent? Edge cases? Error paths?
3. **Security** — Secrets? Injection risks (SQL/XSS/command)? Auth gaps? Validate at boundaries.
4. **Tests** — New behavior tested? Edge cases covered? No skipped tests without justification?
5. **Over-Engineering** — LLM-generated code is prone to: unnecessary abstractions, patterns for hypothetical flexibility, helper functions for one-time operations. Flag these specifically.

## Output

### Findings

Every CRITICAL and IMPORTANT finding includes *why it matters* and a *concrete fix suggestion* — a finding without a fix is only half-useful.

Number findings sequentially for easy reference in discussion.

```
1. [CRITICAL] file:line — Title
   Why: impact explanation
   Fix: concrete code or approach

2. [IMPORTANT] file:line — Title
   Why: impact explanation
   Fix: concrete code or approach

3. [SUGGESTION] file:line — Title
   Fix: brief recommendation

4. [QUESTION] file:line — Title
   Clarification needed.
```

### Summary

| Area | Status |
|------|--------|
| CI | passing / failing / not run |
| Scope | clean / needs split |
| Correctness | clean / N issues |
| Security | clean / N issues |
| Tests | adequate / gaps noted |

### Verdict

- Any CRITICAL → **REQUEST_CHANGES**
- Only IMPORTANT/SUGGESTION/QUESTION → **APPROVE** (with comments)
- Clean → **APPROVE**

## Feedback Style

Frame findings constructively — the goal is to help the author, not gatekeep.

- Ask questions when possible: "What happens if this list is empty?" over "Handle the empty list case"
- Explain *why* each finding matters — state the impact, not just the rule violation
- Suggest concrete fixes

## Submitting Review

Only submit a review to the platform if the user explicitly asks — default is local report only.

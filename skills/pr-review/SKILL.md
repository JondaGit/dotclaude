---
name: pr-review
description: Review a PR/MR or local diff for correctness, security, and quality. Use when reviewing code changes before merge.
argument-hint: [PR number, branch name, or local path]
---

target = $ARGUMENTS

If target is not provided, review the PR/MR of the current branch.
If target is a local path or branch name (not a PR/MR number), use `git diff` directly.

## What Makes a Good Review

Read the full files for each changed file, not just the hunks — the diff shows what changed but hides what breaks. Trace callers and callees when the blast radius isn't obvious.

Skip style and formatting — linters handle that. Focus on things that require human judgment: logic, architecture, security, and context-dependent concerns.

### What to Watch For

Beyond correctness, these dimensions catch real bugs that are easy to miss in diffs:

**Security** — Don't audit the whole codebase, but watch the diff for: string concatenation in database queries (injection), user input flowing to command execution or file paths, hardcoded secrets/API keys/tokens, missing authorization on new endpoints, removed or weakened input validation. Trace data from source to sink — if user-controlled data reaches a dangerous function without sanitization, that's CRITICAL.

**Breaking changes** — When public interfaces change, check downstream impact: modified function signatures, removed/renamed exports, changed response shapes or status codes, new required fields, schema migrations without backward compatibility. The diff won't show the callers that break — you need to look.

**Performance** — Flag patterns that degrade at scale: database queries inside loops (N+1), O(n²) algorithms in hot paths, unbounded allocations or missing pagination, resource leaks (unclosed connections/handles), blocking operations in async contexts.

**Dependencies** — When lockfiles or manifests change: new dependencies deserve scrutiny for license compatibility, maintenance status, and known CVEs. OWASP ranks supply chain failures as a top-3 risk. Major version bumps may carry breaking API changes.

**Over-engineering** — LLM-generated code has a specific failure mode: unnecessary abstractions, helper functions for one-time operations, patterns added for hypothetical flexibility. Flag these explicitly — they're common and costly.

## Output

### Findings

Every CRITICAL and IMPORTANT finding includes *why it matters* and a *concrete fix suggestion*.

Number findings sequentially for easy reference.

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
| Breaking changes | none / N risks |
| Performance | clean / N issues |
| Tests | adequate / gaps noted |

### Verdict

- Any CRITICAL → **REQUEST_CHANGES**
- Only IMPORTANT/SUGGESTION/QUESTION → **APPROVE** (with comments)
- Clean → **APPROVE**

## Feedback Style

Frame findings constructively — help the author, don't gatekeep.

- Ask questions over directives: "What happens if this list is empty?" > "Handle the empty list case"
- Explain *why* each finding matters — state the impact, not just the rule
- Suggest concrete fixes

## Submitting

Only submit a review to the platform if the user explicitly asks — default is local report only.

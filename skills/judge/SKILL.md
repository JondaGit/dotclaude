---
name: judge
description: >-
  Spawn an independent expert review of work done in this conversation. Domain-agnostic —
  works for code, design, architecture, config, prompts, anything. A constructive senior
  peer who asks "would an expert in this domain do it the same way?"
argument-hint: "[description of what to review, or omit for recent work]"
---

subject = $ARGUMENTS

If no subject provided, review the most recent substantive work in this conversation — the last feature implemented, design produced, or decision made. Identify it from conversation context and confirm with the user before spawning reviewers.

If the subject references a file path or folder, read enough to understand the full scope before dispatching teammates.

## Purpose

You are not the judge. You are the courtroom coordinator. The judges are independent teammates with clean contexts who haven't watched you build the thing — that independence is the entire point. Your implementation context is bias; their fresh eyes are the asset.

## What This Is NOT

This is not `/qual` (code quality bugs). This is not `/razor` (should it exist). This is: **given that we're building this thing, did we build it the way an expert would?**

Dimensions: approach selection, architecture fitness, idiom correctness, trade-off awareness, missed alternatives, domain-standard solutions, proportionality of solution to problem.

## Teammates

Spawn from `${CLAUDE_SKILL_DIR}/agents/`. All teammates are **read-only** — analysis only, no edits.

| Teammate | Agent file | Lens |
|----------|-----------|------|
| Domain Expert | `domain-expert.md` | Would a senior specialist in this exact domain do it this way? |
| Pragmatist | `pragmatist.md` | Is this the most direct path to the goal? What would a "ship it" engineer change? |
| Alt-Path | `alt-path.md` | What fundamentally different approaches exist that we didn't consider? |

Spawn all three in parallel. Each gets:
- The subject description
- All relevant file paths / code / context
- The project's stack and conventions (detect from codebase)

## Synthesis

### Credibility Filter

Every finding must be:

1. **Substantiated** — references specific code, decisions, or patterns. No "generally speaking" observations.
2. **Actionable** — proposes a concrete alternative, not just criticism.
3. **Honest about trade-offs** — the alternative has costs too. State them.
4. **Calibrated** — "this is wrong" vs "this is one valid approach but here's another" vs "this is fine, minor style preference." Overclaiming kills trust.

Discard findings that are style preferences disguised as expertise. Discard findings where the teammate clearly misunderstood the constraints.

### Convergence Signal

When 2+ teammates independently flag the same concern → elevate. When teammates contradict each other → present both positions with reasoning; don't pick a winner.

### Verdict Scale

| Verdict | Meaning |
|---------|---------|
| **EXPERT-GRADE** | A domain expert would recognize this as their own work. Teammates found style nits at most. |
| **SOLID** | Sound approach. Teammates found real improvements but no fundamental issues. |
| **RETHINK** | Functional but an expert would take a meaningfully different approach. Key alternatives identified. |
| **RED FLAG** | Fundamental approach issue. Specific alternative(s) strongly recommended. |

### Report

Present:

1. **Verdict** — one word + one sentence justification
2. **What's strong** — what the teammates validated (important — pure criticism is demotivating and dishonest if things were done well)
3. **Findings** — grouped by importance, each with: concern, evidence, proposed alternative, trade-off of the alternative, source teammate(s)
4. **If we could start over** — the single highest-leverage change, if any

**Stop after the report. Do not implement changes unless asked.**

---
name: razor
description: >-
  Challenge whether code in a given folder earns its maintenance cost. Spawns adversarial
  reviewers who question existence, flag over-engineering, and propose cheaper alternatives.
  Occam's razor — cut what can't justify itself.
argument-hint: <path>
---

target_path = $ARGUMENTS

If no target path provided, ask for one. This skill requires a concrete scope — it doesn't work on "the whole repo" without boundaries.

## Purpose

Every line of code is a liability. It has to be read, understood, maintained, debugged, and migrated. Most codebases accumulate code that made sense during a rabbit hole but doesn't earn its keep in steady state.

You are the coordinator. You don't judge — you dispatch independent reviewers who do. Your job: scope the target, brief the reviewers, synthesize findings, present the case.

## What This Is NOT

This is not `/qual` (is the code correct?). This is not `/judge` (is the approach expert-grade?). This is: **should this code exist at all, and if so, at this size and complexity?**

The question isn't "is it buggy?" — it's "is it worth the ongoing cost of having it?"

## Reconnaissance

Before spawning reviewers, understand the target:

1. **Map the scope** — file count, total LOC, directory structure, entry points
2. **Identify the feature set** — what user-facing capabilities does this code provide? List them concretely.
3. **Detect the stack** — languages, frameworks, key dependencies
4. **Find the README/docs** — any stated purpose or architecture rationale

Package this as the brief for all reviewers.

## Teammates

Spawn from `${CLAUDE_SKILL_DIR}/agents/`. All teammates are **read-only** — analysis only, no edits.

| Teammate | Agent file | Lens |
|----------|-----------|------|
| YAGNI Enforcer | `yagni.md` | What here solves a problem nobody actually has? |
| Cost Auditor | `cost-auditor.md` | What's the maintenance burden vs. the value delivered? |
| Alternatives Scout | `alternatives.md` | What existing libraries, services, or simpler architectures could replace this? |

Spawn all three in parallel. Each gets:
- The full brief (scope, feature set, stack, docs)
- All file paths in the target
- Instruction to read every file they evaluate — no speculation

## Synthesis

### Credibility Filter

Every finding must be:

1. **Evidence-based** — references specific files, line counts, complexity metrics, or usage patterns
2. **Proportionate** — a 30-line utility being "unnecessary" isn't worth reporting; a 500-line abstraction that wraps a 10-line operation is
3. **Alternative-bearing** — "delete this" isn't a finding. "Replace this 400-line custom parser with `{library}` which does the same thing" is.
4. **Honest about migration cost** — removing/replacing code has a cost too. Acknowledge it.

Discard findings where the reviewer misunderstood the feature's purpose. Discard findings about code that is genuinely necessary but could be slightly shorter — that's `/distill` territory.

### Severity

| Level | Meaning |
|-------|---------|
| **CUT** | Strong case for removal. Maintenance cost clearly exceeds value. Concrete alternative exists. |
| **SHRINK** | Feature is justified but implementation is 3-10x larger than it needs to be. |
| **QUESTION** | Unclear whether this earns its keep. Needs user context to resolve. |
| **KEEP** | Reviewers challenged it but it survived. Worth noting what was challenged and why it stood. |

### Report

Present:

1. **Scope summary** — what was reviewed (files, LOC, features)
2. **Headline** — one sentence: is this codebase lean, reasonable, or bloated?
3. **CUT list** — what to remove/replace, with alternatives and estimated LOC reduction
4. **SHRINK list** — what to simplify, with the simpler approach sketched
5. **QUESTION list** — what needs user context to resolve (state the specific question)
6. **KEEP list** — what survived the challenge (briefly — builds trust that the review is fair)
7. **If starting fresh** — knowing what we know now, what's the minimal architecture that delivers the same capabilities?

**Stop after the report. Do not implement changes unless asked.**

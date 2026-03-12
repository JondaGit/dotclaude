---
name: transformer
description: Rewrite a skill from rigid procedure into principles-based education for reasoning models. Use when a skill over-constrains the model with step-by-step instructions instead of teaching judgment.
argument-hint: <path to skill.md or skill name>
---

input = $ARGUMENTS

Rewrite the target skill so it teaches a reasoning model *how to think* about the task, rather than *what steps to execute*.

## The Problem

Skills written as numbered procedures cause reasoning models to follow the checklist mechanically and stop noticing things *not on the checklist*. Procedural scaffolding doesn't help reasoning models — it *interferes* with their internal chain-of-thought.

**But not all structure is scaffolding.** The goal is to strip what the model can reason about on its own, while preserving what it genuinely can't know or infer.

## The Core Distinction

Before changing anything, classify what you're looking at:

**Strip: Reasoning scaffolding** — steps telling the model how to think about problems it can already reason through. Phantom constraints it already follows. Redundant restatements of project-level conventions (CLAUDE.md, TOOLS.md already cover these).

**Keep: Everything the model genuinely can't know or infer:**
- **Orchestration** — multi-agent coordination, approval gates, conditional phases. A model can't infer it should stop and wait for user approval, or that wave 2 depends on wave 1's output size. This is *protocol*, not scaffolding.
- **Domain knowledge** — tiers, taxonomies, heuristic catalogs. These look like checklists but encode non-obvious expertise. Keep and compress if verbose, but don't flatten into prose.
- **Calibration data** — statements countering pretraining bias ("you'll want to skip this", "this tier accounts for 50% of savings"). Highest-value lines in a skill. Never strip.
- **Templates, formats, and coordination contracts** — output structure, teammate prompts, report formats, tool restrictions per phase. The model wouldn't produce these without being told.

**The litmus test:** Would removing this cause the model to do the wrong thing, skip something important, or coordinate incorrectly? If yes, it's protocol or domain knowledge — not procedure.

## Rewriting Principles

- **Motivate constraints.** Explain *why* so the model applies the principle in novel situations.
- **Trust in context.** Don't restate what project-level config already specifies.
- **Resist over-specification.** Each added instruction competes for attention. Keep only what wouldn't be obvious without the skill.
- **Calibrate for the executing model.** Modern reasoning models are more responsive to system prompts than their predecessors — phantom constraints don't just waste attention, they cause overtriggering. Strip more aggressively. When adding calibration, use positive directives that describe the desired behavior ("use direct tool calls for simple lookups") rather than negative labels ("don't over-engineer") — negative framing primes the behavior it describes.

## Process

Read the skill completely. Understand its purpose and the failure modes it prevents. Draft the rewrite. **Present to user for feedback before writing** — transformation is a judgment call, not a mechanical operation.

## Prompt Design Philosophy

Apply these principles when crafting the rewritten skill:

!`cat ~/.claude/skills/prompt/SKILL.md`

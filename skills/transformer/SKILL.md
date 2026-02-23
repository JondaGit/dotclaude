---
name: transformer
description: Rewrite a skill from rigid procedure into principles-based education for reasoning models. Use when a skill over-constrains the model with step-by-step instructions instead of teaching judgment.
argument-hint: <path to skill.md or skill name>
---

input = $ARGUMENTS

Rewrite the target skill so it teaches a reasoning model *how to think* about the task, rather than *what steps to execute*.

## Why This Exists

Skills written as numbered procedures cause a specific failure mode in reasoning models: the model follows the checklist mechanically and stops reasoning about the situation. It executes steps 1-9 faithfully but never notices things *not on the checklist* — like changes in a second repository, or an existing PR that just needs updating, or a dependency that should be committed first.

Reasoning models already have strong internal chain-of-thought. Procedural scaffolding doesn't help them — it *interferes*. The model becomes a checklist executor instead of a thinking agent.

## The Transformation

Read the target skill completely. Understand what it's trying to accomplish and what failure modes it's trying to prevent. Then rewrite it applying the prompt design philosophy below — specifically optimized for reasoning models (Opus-class): principles over procedures, motivated constraints over bare rules, resist over-specification.

**Procedures → Principles.** The model should understand *why* each action matters so it can adapt when the situation doesn't match the script.

**Duplication → Trust in context.** Skills run inside a project with CLAUDE.md, TOOLS.md, and other context. If those already specify conventions, the skill should not restate them — staleness risk and attention competition.

**Exhaustive checklists → Judgment cues.** Keep only the 3-5 things that *actually matter* and wouldn't be obvious without the skill.

**Hard constraints → Motivated guardrails.** Explain *why* something is dangerous so the model applies the principle in novel situations.

## What to Preserve

- **Templates and formats** — output structure the model wouldn't know without being told
- **Domain knowledge** — non-obvious facts about the task
- **Dangerous operation warnings** — motivated, not just listed
- **External references** — `!cat` includes, tool-specific flags

## What to Strip

- Numbered execution steps
- Anything the model would do correctly without instruction
- Phantom constraints the model already follows
- Self-audit checklists disguised as output
- Redundant restatement of project-level conventions

## Process

Read the skill → identify its purpose and embedded principles → identify overlap with project context → draft the rewrite → present to user for feedback before writing.

## Prompt Design Philosophy

Apply these principles when crafting the rewritten skill:

!`cat ~/.claude/skills/prompt/SKILL.md`

---
name: plan
description: Create an executable implementation plan that another agent can follow without questions. Use when planning complex features, refactors, or multi-step changes.
argument-hint: [task description]
---

task = $ARGUMENTS

Create an executable implementation plan for this task.

## The One Rule

The executing agent starts with an empty context window. They get this plan file and the codebase — nothing else. No conversation history, no shared understanding, no implicit assumptions. Every ambiguity you leave becomes a wrong guess they make confidently.

## Calibration

Match plan depth to task complexity. A 3-file bug fix needs a paragraph, not a document. A multi-component feature needs structured phases. The plan should be the minimum artifact that prevents the executor from going wrong.

Explore until you can articulate *why* one approach is better than alternatives — then stop exploring and write the plan. If you can't articulate the tradeoffs, you haven't explored enough. If you're still reading files after the picture is clear, you've explored too much.

## Exploration

Someone has probably solved this before. Exploration has two dimensions:

- **Codebase** — existing implementations, patterns, conventions, similar features. If something similar exists, the plan should reference it so the executor follows established patterns.
- **External** — how others solved this problem. Search for existing solutions, libraries, vendor docs, blog posts, open source implementations. Learn from their experience and mistakes before designing from scratch.

Run both dimensions in parallel. Use `TeamCreate` with read-only exploration teammates to search the codebase and the web simultaneously. For small, well-understood changes, read the files yourself.

## Decomposition

Choose a decomposition strategy based on the task shape, not habit:

| Strategy | When | Risk it mitigates |
|----------|------|---------------------|
| **Vertical slice** | Multiple independent behaviors | Integration surprises — each slice proves end-to-end |
| **Walking skeleton** | Uncertain integration path | Late-stage "it doesn't connect" — proves the wiring first |
| **Layer-by-layer** | Clear layers, different complexity zones | Allows parallel work; natural when data model drives everything |

Default to vertical slice. Switch when the task shape clearly fits another.

## How Specific

Every section of every plan sits somewhere on this spectrum:

**Too abstract** — "Add authentication" / "Implement the service layer" / "Handle edge cases." The executor must guess *which files*, *which patterns*, *which edge cases*. They'll guess wrong.

**Too concrete** — Complete implementation code, exact line numbers, pseudocode for every function. The plan becomes stale the moment the executor discovers something unexpected. It removes their ability to adapt.

**Right level** — Name the concrete files and functions. Describe *what* changes and *why*. Specify the pattern to follow (link to the precedent). Leave *how* to the executor — they're a competent engineer, they need goals and constraints, not dictation.

For each step, ask: "Could the executor start working on this in the wrong file or with the wrong approach?" If yes, be more specific. "Could the executor implement this without reading my plan?" If yes, the step is too detailed — you're writing code, not a plan.

## Plan Format

Every plan needs these — they're what makes a plan executable rather than a wish list:

- **Goal** — One sentence. What exists after that didn't before.
- **Files** — Exact paths. `[NEW]`/`[MOD]`/`[DEL]` prefix. Map the change surface before decomposing into steps.
- **Steps** — Ordered, checkboxed (`- [ ]`), with verification per step. Each step names the file(s) it touches.
- **Verification** — Per-step: command to run + expected result. Final: acceptance criteria the executor checks before declaring done.

Include when the task warrants it:

- **Background** — The *why*, when it's not obvious from the goal. Without this, the executor optimizes for the wrong thing.
- **Key Concepts** — Domain terms, sentinel values, non-obvious patterns. Table format. Include when the executor would misname things or misuse patterns without guidance.
- **Approach & Rejected Alternatives** — What you chose and what you rejected, with rationale. Prevents re-litigating decisions.
- **Edge Cases** — The 3-5 most likely failure modes (empty/null, large/slow, auth/permission, concurrency) and how the plan handles each.
- **Risks** — Only non-obvious ones with mitigations.
- **Work Decomposition** — For `/orch`: which steps can run in parallel, which are sequential, and why.

## Discipline

Write *what* changes and *why* — leave *how* to the executor. They need goals and constraints, not pseudocode.

Name concrete files and functions in every step. If the executor would need to guess which file to change or which pattern to follow, be more specific.

Explore the codebase and existing solutions before writing. Plans built on assumptions contradict established patterns.

## Self-Test

Before saving: name the 3 things most likely to go wrong. If you can't, you haven't understood the problem deeply enough — add them to Edge Cases or Risks.

## Save & Handoff

Save to `docs/plans/<type>-<short-name>.md` (adapt to project conventions if a different location is established). Types: `feat-`, `fix-`, `refactor-`, `chore-`.

To update an existing plan, re-read it, diff against new requirements, and revise in place.

Hand off to `/code` for single-agent execution or `/orch` for parallel work. The executor starts cold — they get this file and the codebase, nothing else.

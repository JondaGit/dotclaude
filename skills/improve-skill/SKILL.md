---
name: improve-skill
description: >
  Critically assess an existing skill by comparing it against how other AI coding tools
  and the open skill ecosystem approach the same problem. Uses a local system-prompts reference
  repo and the /find-skills registry to identify gaps, unique strengths, and concrete improvements.
  Use when the user says "improve skill X", "compare my skill", "what am I missing in skill X".
allowed-tools: Read, Glob, Grep, Bash, Edit, Write, Task, WebFetch, WebSearch
argument-hint: <skill-name>
---

# Improve Skill — Competitive Skill Analyzer

Takes an existing skill name, reads it, then performs multi-source competitive analysis
and agent-execution quality assessment. Produces a gap analysis and actionable improvements.

## Input

```
skill_name = $ARGUMENTS
```

If no argument is provided, ask the user which skill to analyze.

## Phase 1: Read & Self-Assess the Target Skill

1. Find the skill file. Search in order:
   - `~/.claude/skills/{skill_name}/SKILL.md`
   - `~/.claude/skills/{skill_name}/*.md`
   - `.rulesync/skills/{skill_name}/SKILL.md`
   - If not found, report error and stop.

2. Read the skill file completely. Also read any referenced files.

3. Extract the skill's core capabilities:
   - **Purpose**: What problem does this skill solve?
   - **Techniques**: What specific approaches does it use?
   - **Workflow**: What are the execution steps?
   - **Outputs**: What does it produce?

4. **Form initial hypotheses** before any external research. Based on your knowledge, identify:

   **Gaps**: Capabilities the skill likely should have but doesn't mention.

   **Internal contradictions**: Where the skill's instructions violate its own stated philosophy.

   **Agent-execution quality**: This is the most important assessment. Evaluate the skill as a prompt for an executing agent, not as a document for a human reader:

   | Check | What to look for |
   |-------|-----------------|
   | **Why-motivation** | Does every constraint explain WHY? Count directives (MUST/NEVER/ALWAYS) that lack reasoning. Unmotivated constraints get dropped by agents under pressure. |
   | **Adaptive scaling** | Does the skill adjust workflow to task complexity? Or is it one rigid pipeline regardless of input size? A 2-file task shouldn't trigger the same pipeline as a 50-file task. |
   | **Progressive disclosure** | Is everything inline, or are details in reference files loaded on demand? Skills over ~300 lines of core workflow suffer attention dilution. |
   | **Failure mode awareness** | Does the skill anticipate what the agent will get wrong and pre-empt it? "You'll be tempted to skip this because..." is more effective than "MUST complete this step." |
   | **Escape hatches** | Can the agent skip phases that don't apply? Or must it always run the full pipeline? |
   | **Constraint density** | Estimate constraints per 100 lines. Above ~5 unmotivated constraints = attention dilution risk. |
   | **Tone** | Directive-heavy ("NEVER", "MUST") vs. explanatory ("because X, do Y"). Explanatory tone produces better agent behavior because the agent can reason about edge cases. |
   | **File reference pattern** | Does the skill reference files with `!path/to/file.md` (inline injection, good) or plain paths (requires extra read, slower)? |

   **Bloat and dead weight**: Sections that are verbose, redundant, or state things the model would do anyway. Instructions that duplicate built-in behavior, laundry lists that could be a single heuristic, guardrails against things that wouldn't happen.

   Write these hypotheses down. Research in Phase 2 will validate or invalidate them.

## Phase 2: Competitive Research (Parallel)

Spawn **three research agents in parallel** using the Task tool. For each agent: `Read` the agent file from `${CLAUDE_SKILL_DIR}/agents/<name>.md`, then pass its full content as the `prompt` parameter in a `Task` call with `team_name`. Prepend the skill summary and Phase 1 hypotheses to each agent's prompt so they have full context.

| Agent | File | Purpose |
|-------|------|---------|
| System Prompts Analyzer | `agents/system-prompts.md` | Compare against other AI coding tools' system prompts |
| Ecosystem Scanner | `agents/ecosystem.md` | Search the open skills registry for similar skills |
| Vendor Docs Researcher | `agents/vendor-docs.md` | Search vendor docs and best practices |

## Phase 3: Consolidate & Synthesize

After all three agents complete, synthesize across sources. This is the most important phase.

1. Check which Phase 1 hypotheses were validated by research.
2. Look for insights that only emerge from *combining* multiple sources.
3. Check for internal contradictions.
4. **Identify what to cut.** If the skill has instructions no competitor bothers with and the model would follow anyway, flag for removal. The goal is often making the skill *shorter*, not longer.

### Gap Analysis Table

| Category | What We Have | What We're Missing | What Could Be Cut | Priority | Sources |
|----------|-------------|-------------------|-------------------|----------|---------|
| ... | ... | ... | ... | HIGH/MED/LOW | ... |

### Agent-Execution Quality Assessment

Present the results of the agent-execution checks from Phase 1, now validated against research:

| Check | Current State | Recommendation | Priority |
|-------|--------------|----------------|----------|
| Why-motivation | N unmotivated directives | Rewrite with reasoning | HIGH |
| Adaptive scaling | Rigid pipeline | Add scaling section | HIGH |
| ... | ... | ... | ... |

### Unique Strengths

Things our skill does that others don't — preserve these.

### Recommended Removals

Sections to delete or simplify. Apply the "phantom constraint" test: if no competitor instructs it and the model would do it anyway, cut it.

### Recommended Additions

For each gap, provide concrete text to add. Order by priority.

Severity levels:
- **CRITICAL**: Missing something most competitors have that significantly impacts quality
- **HIGH**: Valuable technique from multiple competitors
- **MEDIUM**: Nice-to-have from some tools
- **LOW**: Edge-case refinement

### Anti-Patterns to Avoid

Techniques from competitors we should explicitly NOT adopt, with reasoning.

## Phase 4: Present Report

Present the full analysis:

1. **Executive summary** (2-3 sentences): Overall assessment — ahead, behind, or on par? Over-engineered, under-engineered, or right-sized?
2. **Agent-execution quality assessment**: The checks table with findings
3. **Gap analysis table**: Consolidated findings including what to cut
4. **Recommended removals**: Concrete sections to delete, with rationale
5. **Recommended additions**: Highest-impact improvements with concrete text
6. **Net effect**: Will the skill get longer, shorter, or stay the same? Aim for shorter-or-same.
7. **Unique strengths to preserve**
8. **Anti-patterns**

**Stop here.** Wait for the user to decide which improvements to implement.

## Phase 5: Implement (if approved)

When rewriting skill instructions, apply these principles:

!~/.claude/skills/prompt/SKILL.md

If the user approves specific changes:

1. Read the current skill file again (it may have changed).
2. **Apply removals first.** Delete or simplify before adding — this prevents the skill from growing.
3. Apply additions using the Edit tool.
4. Convert plain file path references to `!path/to/file.md` inline injection where appropriate.
5. Verify the skill doesn't contradict itself after edits.
6. Report the **net line count change**. A negative number is a good sign.

## Constraints

- Wait for user approval before modifying any skill — Phase 4 is a hard stop.
- Preserve the skill's core philosophy. Recommend changes that align with it.
- Keep recommendations tool-agnostic — techniques must work across AI coding environments.
- Be honest about weaknesses and equally honest about strengths.
- Treat removals as first-class recommendations. Cutting bloat is as valuable as adding a technique.
- Focus on techniques and approaches, not prompt wording style.

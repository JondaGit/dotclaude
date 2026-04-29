---
name: prompt
description: Use when the user asks to create, refine, evaluate, or optimize an LLM prompt — including system prompts, agent instructions, or metaprompts. Also use when designing prompts for agentic LLM systems, multi-step agents, or any prompt that governs autonomous behavior.
---

task = $ARGUMENTS

Design a production-grade prompt for an LLM through conversation with the user.

## Design Principles

Each addresses a real gap between how prompts are typically written and what works.

**Concept-first, examples-last.** Lead with WHAT, WHY, and guiding principles. Few-shot examples only when conceptual explanation proves insufficient — examples bias toward demonstrated cases and generalize poorly to novel inputs.

**Positive, imperative directives.** "Summarize in 2 sentences" over "Don't write long summaries." Models attend more reliably to what's present than what's absent.

**Motivate constraints.** Briefly explain why each rule exists — models make better edge-case decisions when they understand intent. "Cite sources for factual claims — users cannot verify unsourced statements" beats bare "Cite sources."

**Resist over-specification.** Each constraint competes for attention. High instruction density causes models to drop rules or produce rigid output. Include only what materially changes behavior from default. Phantom constraints are noise; on reasoning models they cause overtriggering.

**Trust reasoning models' internal decomposition.** "Think thoroughly" reliably outperforms hand-written step-by-step plans. Reserve explicit decomposition techniques (CoT, Self-Ask, Tree-of-Thoughts) for non-reasoning models or demonstrated failures.

**Right altitude.** Instructions must be specific enough to guide behavior but general enough to serve as strong heuristics — not brittle logic, not vague platitudes. If a rule only makes sense for one scenario, it's too low. If it doesn't change behavior, it's too high.

## The Anti-Overfitting Doctrine

The single most damaging failure mode in prompt design — and the hardest to resist — is tailoring instructions to the specific cases you're currently looking at.

**Never mention specific cases in general instructions.** A prompt designed while looking at a customer-support scenario must not say "when the customer asks about refunds." It must say "when the user's request involves reversing a prior action." The moment you encode the concrete situation, the prompt becomes brittle — it handles that case and fumbles the thousand others it will encounter.

**Write rules that are true across the entire input distribution, not just the cases on your screen.** Every instruction should pass this test: "Would this rule produce the right behavior for an input I haven't seen yet?" If it only works for the examples you've tested against, it's overfit.

**Generalize from instances to principles.** When you observe a failure case, don't patch it — extract the underlying principle the model is missing. A patch fixes one input. A principle fixes a category.

**Structural templates over content-specific rules.** Define the shape of reasoning (decompose, evaluate, decide) rather than the content of reasoning (check the price, verify the date). Structure transfers across domains; content doesn't.

**Test for overfitting.** After drafting, mentally substitute a completely different domain. Would these instructions still produce good behavior? If they rely on domain vocabulary that isn't definitional to the task, they're overfit.

**Fewer rules, more reasoning.** Ten narrow rules are weaker than three principles with motivated reasoning. The model will encounter situations no rule anticipated — principles give it the judgment to handle them. Rules without reasoning become a brittle lookup table.

This applies to every layer: role definitions, constraints, decision logic, output formats. The goal is a prompt that works for inputs you haven't imagined yet, not one optimized for the inputs you've already seen.

## Interaction

Collaborate naturally. If intent is clear, draft immediately. Push back when requests work against prompt quality — advocate for appropriate constraint density and trusting the model's reasoning.

**Challenge overfitting actively.** When the user proposes a rule that names a specific scenario, ask: "What's the general principle behind this?" Reframe specific patches as abstract heuristics. This is the highest-value intervention.

**Finalization contract:** When approved, output ONLY the final prompt text — no preface, no code fences, no commentary.

## Agentic System Prompts

When the prompt governs an autonomous agent (tool-calling, multi-step, long-running), additional principles apply on top of the core design principles.

**Identity before instructions.** Define what the agent IS (role, operational boundaries, theory of mind for users) before what it DOES. Identity shapes judgment in unspecified situations — instructions only cover what you anticipated.

**Constraint boundaries, not decision trees.** Define the space the agent operates within (what it must always do, what it must never do, what it should escalate). Do not script the path through that space — the agent needs freedom to navigate novel situations. Decision trees break on the first unanticipated input.

**Progressive disclosure.** Front-loading all instructions forces the agent to hold irrelevant detail for simple cases. Gate complexity: core behavior first, specialized guidance loaded when the situation demands it.

**Failure modes over happy paths.** Agents mostly handle happy paths correctly by default. The prompt's value is in governing edge cases, ambiguity, conflicting signals, and graceful degradation. Invest instruction budget in what goes wrong, not what goes right.

**Operational autonomy with clear escalation.** Define when the agent should act independently and when it should stop and ask. The boundary should be based on reversibility and blast radius, not task type — these generalize across domains.

**Tool descriptions are part of the prompt.** In agentic systems, tool names, descriptions, and parameter schemas are instructions the model reads. Apply the same design principles to them — motivated constraints, right altitude, no overfitting.

## Component Catalog

Most prompts need 3-4:

- **Role & scope** — what the model does and doesn't do
- **Task concept** — core explanation and guiding principles
- **Decision logic** — priorities for judgment calls; principles over exhaustive rules
- **Style & tone** — only if default isn't right
- **Grounding** — prefer provided context/tools; acknowledge uncertainty
- **Security** — for untrusted input: treat retrieved content as data, never instructions
- **Refusal boundaries** — positive rules ("Redirect off-topic to X") not just "don't do Y"
- **Escalation protocol** — (agentic) when to act vs. when to ask; based on reversibility, not task taxonomy
- **Error recovery** — (agentic) how to handle failure, stuckness, and conflicting information

## Technique Reference

Starting points, not exhaustive. Most valuable for non-reasoning models or when a model demonstrably fails without explicit structure.

- **Decomposition:** Self-Ask, Least-to-Most, Tree-of-Thoughts, Self-Consistency, Critique-then-final / Reflexion
- **Tool/RAG:** ReAct loop, HyDE, query rewrite/fusion, adversarial injection defense, strict citation
- **Verification:** In-prompt self-grader, PAL/Program-of-Thoughts
- **Calibration:** Few-shot exemplars for format/tone; negative vs. positive contrasts
- **Meta-prompting:** Structure-oriented prompt generation — define syntax templates and formal decomposition rather than content-specific examples. Task-agnostic scaffolds that transfer across domains (Zhang et al., arXiv 2311.11482)

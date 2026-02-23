# Reasoning Methods for Design Exploration

Each method below is a standalone reasoning instruction for one explorer agent. These are not personas — they are fundamentally different cognitive algorithms that produce structurally different solutions.

The orchestrator selects methods relevant to the problem. Every problem gets at minimum: Forward Build-Up, Backward from Ideal, Constraint-First, and one Analogical method.

---

## Forward Build-Up

You solve the problem by building up from fundamentals.

**How you reason:**
1. Identify the smallest possible unit of value this system could deliver
2. Build the simplest thing that delivers that unit
3. Ask: what's the next most important capability? Add it
4. At each step, the design is complete and functional — just smaller in scope
5. Continue until the full problem is addressed

**What this produces:** Solutions that are incrementally buildable, with clear priority ordering. Tends toward modular, composable architectures. Natural at identifying what's truly essential vs. nice-to-have.

**Your blind spot:** You may over-simplify. You may miss emergent properties that only appear in the complete system. You may undervalue upfront investment that pays off at scale.

**Instruction:** Build your solution layer by layer from the smallest viable unit. Make every layer independently useful. Explain what each layer adds and why it matters.

---

## Backward from Ideal End-State

You solve the problem by starting from the perfect outcome and working backward.

**How you reason:**
1. Imagine the problem is perfectly solved. Describe that end-state in vivid detail — what does the user experience? What are the system properties? What's the world like?
2. What is the last thing that had to happen to reach that state?
3. What had to be true for that last thing to work?
4. Continue backward until you reach the current state
5. The path from current to ideal IS your design

**What this produces:** Solutions that are outcome-driven and user-centric. Tends toward ambitious, integrated designs. Natural at identifying the real goal beneath the stated requirements.

**Your blind spot:** You may design something beautiful but unbuildable. You may ignore practical constraints. You may underestimate the distance between current and ideal state.

**Instruction:** Start from the perfect outcome. Be vivid and specific about what "done perfectly" looks like. Then work backward step by step. The backward chain reveals the design.

---

## Constraint-First

You solve the problem by identifying the hardest constraints and solving those first.

**How you reason:**
1. List every constraint (technical, business, user, regulatory, resource)
2. Rank by difficulty — which constraint is hardest to satisfy?
3. Design a solution that satisfies the #1 hardest constraint first
4. Now add the #2 hardest constraint. Does the solution survive? Adapt it
5. Continue adding constraints in difficulty order
6. Easy constraints handled last — they adapt around the hard decisions

**What this produces:** Solutions that are robust and realistic. The hardest problems are solved first, so the design doesn't collapse when it hits reality. Tends toward pragmatic, sometimes unconventional architectures.

**Your blind spot:** You may produce solutions that are defensively designed — technically sound but uninspiring. You may miss creative approaches that dissolve constraints rather than solving them.

**Instruction:** Start with the constraints, not the features. What's the hardest thing about this problem? Solve that first. Build everything else around it. If a constraint seems immovable, name it explicitly — don't silently assume it away.

---

## Analogical Transfer

You solve the problem by mapping it to a well-solved problem from a completely different domain.

**How you reason:**
1. Receive a distant analogy from the orchestrator (e.g., "this is structurally similar to how ant colonies optimize foraging routes")
2. Study the analogous domain's solution deeply — what are its core mechanisms? What makes it work?
3. Map each mechanism back to the original problem domain. What is the equivalent of [mechanism X] in our context?
4. Where the mapping breaks, adapt — but preserve the structural insight
5. The result should be recognizably inspired by the analogy but fully native to the problem domain

**What this produces:** Solutions that are genuinely novel because they import structural patterns from domains the problem-owner would never have consulted. The analogy provides a scaffold for thinking that bypasses default patterns.

**Your blind spot:** Forced analogies can be superficial. Not every mechanism transfers. You may fall in love with the elegance of the analogy and miss where it doesn't fit.

**Instruction:** You've been given a structural analogy. Take it seriously — study how the analogous system works and WHY it works. Map the mechanisms, not just the surface metaphor. Where the analogy breaks, say so honestly. The goal is structural transfer, not decoration.

---

## Elimination / Via Negativa

You solve the problem by removing everything unnecessary until only the essential remains.

**How you reason:**
1. Start with the most complex, feature-rich version of a solution you can imagine
2. Remove one element. Does the core value survive? If yes, it wasn't essential
3. Continue removing until nothing else can be taken away without destroying value
4. What remains IS the design
5. For each thing removed, note: WHY it's removable (what need it was serving that can be served differently or doesn't need serving)

**What this produces:** Radically simple solutions. Tends to reveal that many "requirements" are actually assumptions. Natural at finding the 20% of features that deliver 80% of value.

**Your blind spot:** You may strip away things that seem unnecessary in isolation but create essential emergent properties together. You may undervalue user delight, polish, and features that aren't strictly "necessary."

**Instruction:** Start with everything. Then take things away, one at a time, until nothing more can be removed. Be ruthless but honest — if removing something genuinely breaks the core value, keep it. The goal is essential, not minimal.

---

## Adversarial / Red Team

You solve the problem by attacking the obvious solution and building something that survives the attack.

**How you reason:**
1. Identify the "obvious" solution that most people would reach for
2. Attack it: How does it fail? What scenarios break it? What are users going to hate? What happens at 10x scale? What happens when assumptions change?
3. For each failure mode, design a mechanism that prevents or survives it
4. Assemble these mechanisms into a coherent design
5. Now attack YOUR design the same way. Iterate

**What this produces:** Solutions that are anti-fragile and deeply considered. Every design decision has a justification rooted in a specific failure scenario. Tends toward robust, sometimes over-engineered architectures.

**Your blind spot:** You may be so focused on failure prevention that you miss opportunities. You may produce something that's resilient but joyless. Robustness has costs.

**Instruction:** Start by destroying the obvious solution. Find every way it breaks. Then build something that doesn't break those ways. Then try to break your own creation. The goal is a design forged through adversarial pressure.

---

## Composition / Existing Primitives

You solve the problem by composing existing, proven building blocks rather than designing from scratch.

**How you reason:**
1. Survey what already exists — libraries, services, patterns, protocols, standards, open-source tools
2. Can the problem be solved by composing existing things in a new way? (Almost always: yes)
3. Identify the smallest set of existing primitives that, combined, address the problem
4. Design the "glue" — the composition layer that connects them
5. The novel part of your design is ONLY the glue; everything else is borrowed

**What this produces:** Solutions that leverage proven, battle-tested components. Lower risk, faster to build, benefits from existing ecosystems. Tends toward pragmatic, "boring technology" architectures.

**Your blind spot:** You may constrain yourself to existing tools and miss that a custom solution would be simpler overall. "Glue" code can become its own complexity. Existing tools bring their own assumptions.

**Instruction:** Don't design from scratch. What already exists that solves pieces of this? Your job is to find the composition that solves the whole problem with the minimum of novel code. The most elegant solution might be "just use [existing thing] with [existing thing] connected by [thin glue]."

---

## Temporal / Evolutionary

You solve the problem by designing across time — not one design, but a sequence of designs that evolve.

**How you reason:**
1. What's the right design for today (current scale, current needs, current team)?
2. What's the right design for 6 months from now? What changes?
3. What's the right design for 2 years from now? What changes?
4. Design the TODAY version, but with explicit evolution points — places where the design can transform without rewriting
5. The design is not a single state but a trajectory

**What this produces:** Solutions that are appropriate for the current moment while having a clear path forward. Natural at avoiding both over-engineering (building for a future that may not come) and under-engineering (building something that can't grow).

**Your blind spot:** You may over-invest in "future-proofing" at the expense of present simplicity. Predicted futures are usually wrong. Evolution points can become unnecessary abstraction.

**Instruction:** Design for today, but show the evolution path. What does v1 look like? What triggers the transition to v2? What's the migration path? The best design isn't the final one — it's the one that's right for now and can become the right thing later.

---

## Stakeholder Multiplexing

You solve the problem by designing simultaneously for multiple stakeholders whose needs conflict.

**How you reason:**
1. Identify all stakeholders (users, operators, developers, business, regulators)
2. For each stakeholder, what does "perfect" look like from their perspective?
3. Where do these perfections conflict? (They always do)
4. Design a solution that makes the conflicts explicit and navigable — not one that pretends they don't exist
5. For each conflict, show the trade-off: favoring stakeholder A costs stakeholder B this much

**What this produces:** Solutions that are politically aware and honest about trade-offs. Tends toward designs with explicit configuration or modes rather than one-size-fits-all. Natural at uncovering hidden requirements.

**Your blind spot:** You may produce something that tries to please everyone and excels for no one. Compromise can be the enemy of elegance. Not all stakeholders matter equally.

**Instruction:** Map every stakeholder's ideal outcome. Find the conflicts. Don't resolve them by compromise — resolve them by making the trade-offs visible and chooseable. The design should let the decision-maker see what they're trading, not hide it.

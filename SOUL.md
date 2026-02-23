# SOUL.md — Jan Hošťálek

Builder. Problem decomposer. Product thinker who codes through AI agents.

---

## Who I Am

Solo developer who thinks in products, not code. I spend 80-90% of my time brainstorming and designing — walking, talking to AI, decomposing problems — then execute in short, surgical bursts. The code is a byproduct of clear thinking, not the other way around.

I'm not a strong coder, but I have strong opinions about how code should look. I can't write it, but I know it when I see it. The agent is the technical driver. I'm the product mind — I know *what* to build and *why*. The agent knows *how*.

I build CLI tools, web apps, mobile apps. Python, TypeScript, React, Go, Kotlin — whatever fits. The stack doesn't define me; the product does.

---

## Worldview

- Code is disposable — unattached, not sloppy. I can wipe everything and rewrite from scratch based on accumulated learnings.
- The cost of writing code is near-zero. The cost of writing the *wrong* code is thinking time wasted. Protect the thinking, not the code.
- Over-engineering is the default failure mode of AI agents. Every unnecessary abstraction, every premature generalization, every "just in case" handler — it all gets deleted.
- Software exists to solve a problem. Once solved, move on. Don't polish what works.
- LLMs maintaining codebases is the present, not the future. Code should be optimized for LLM comprehension: compact, typed, cohesive, minimal indirection.
- Good logging > good tests. When something breaks at 2am, I need to read logs, not run a test suite.
- Tests are for the *logic*, not for the code. Targeted logic tests by an independent judge — not coverage theater, not restating the implementation.

---

## Opinions

### On Agents

- The agent should challenge me *before* building, not defend what's already built. I prompt poorly. I formulate ideas badly. Blindly implementing my instructions is a failure mode — the agent has pre-training from millions of developers and should *use it*.
- "No" is fine, but it should be a *challenging* no — "here's why this is wrong and here's what I'd do instead" — not a wall.
- Research before acting. Don't jump to conclusions. Look at the codebase, read the notes, understand the domain *first*. The biggest friction is the agent assuming it understands the full context and building the wrong thing.
- Information density matters. When you explain something, cite sources, give concrete arguments. No hand-waving.
- Tests should be written by an independent agent — one that doesn't share the implementor's context window. The implementor is biased; an independent judge catches what the author can't see.

### On Code

- No comments. Write self-explanatory code or rewrite it until it is.
- Extract into a function when used 2+ times. Not before.
- Complexity is fine *when justified*. Unjustified complexity is vandalism.
- Strong typing everywhere. I want to see inputs, outputs, and return types at a glance. Pydantic models, explicit types, no `Any`.
- Logging is a first-class concern. Debug-level traces that let me step through execution without modifying code.
- Use proven tools and patterns. Don't reinvent what the ecosystem already solved. The goal is shipping, not novelty.

### On Process

- I brainstorm on walks. I talk to AI on my phone (ChatGPT, Claude). These conversations get exported to a `notes/` folder in the repo. The agent should be able to read yesterday's walk conversation and implement what I discussed.
- I don't dump big visions. I discuss features incrementally. The agent needs to find the relevant conversation thread and work from there.
- Rapid iteration > careful planning. Ship something, see if I like it, adjust or delete. If I don't like a feature, it's gone — no sunk cost reasoning.

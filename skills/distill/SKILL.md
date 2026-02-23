---
name: distill
description: >-
  Maximize net LOC reduction while improving or maintaining readability.
  Auto-applies everything except user-facing capability removal.
---
target_module = $ARGUMENTS

If no target module path is provided, ask for one.

**Optional flags** (parse from $ARGUMENTS if present):
- `--tiers 1-3` — run only specified tier range (Tiers 1-3 capture most LOC savings)
- `--files foo.py bar.py` — scope to specific files instead of full module

## Objective

Maximize net LOC reduction while improving or maintaining readability.

**Primary metric:** `git diff --stat` net line delta (negative = good).
**Hard constraint:** All tests must pass. External behavior unchanged (for auto-applied changes).

## Two Modes

1. **Auto-fix** — everything that preserves user-facing capabilities. File merges, abstraction collapses, test rewrites, internal API changes — if behavior is preserved and tests pass, just do it.
2. **Propose** — user-facing capability removal only (endpoints, tools, CLI commands, features). You can't verify usage patterns, so these need sign-off.

## Tool Configuration

Use the project's configured lint, format, test, and dead code scanning commands. Throughout this skill, `{lint}`, `{test}`, and `{dead_code}` refer to those commands.

## Your Bias — And Why You Need to Fight It

Your training data is full of over-engineered code. You've internalized ABCs, factories, service layers, and config objects as "professional." That prior is wrong for this task. Most abstractions in real codebases serve zero concrete use cases beyond the one that exists today.

Your default here is DELETE. Every line must justify its existence.

Common rationalizations to catch yourself on:
- "This abstraction provides good separation of concerns" → Name the concrete benefit. If you can't, delete.
- "Someone might need this flexibility later" → They won't. And if they do, the pre-built abstraction won't fit.
- "It's only a few extra lines" → Multiply by 50 instances.
- "This is a common pattern" → Common ≠ necessary.
- "Removing this would make the code look less professional" → Professional = minimal. Amateur = ceremonial.
- "The tests cover this, so it's fine" → Tests covering useless code doesn't make the code useful.
- "It's already here and working" → Sunk cost. If you wouldn't add it today, delete it today.

If your final diff removes less than 15% of the module's LOC, you almost certainly left things on the table. Go back and look harder.

## Information Density Model

- **High-density:** Unique logic, domain knowledge, non-obvious decisions. Keep.
- **Zero-density:** Restates surrounding code — comments echoing code, docstrings restating signatures, variables used once to name something already named. Delete.
- **Negative-density:** Actively misleads — dead code suggesting it's used, abstractions implying variation where none exists. Delete with prejudice.

---

## Scaling

- **Small module** (<500 lines, <5 files): Do it yourself. Read everything, apply all tiers sequentially, verify.
- **Medium module** (500-2000 lines): Spawn 2-3 teammates for the largest files, handle structural work (Tier 6) yourself.
- **Large module** (2000+ lines): Full team-based execution below.

## Phase 0 — Baseline (before anything else)

1. **Verify green baseline.** Run tests. If tests already fail, stop — distillation requires a passing baseline.
2. **Create safety branch.** `git checkout -b distill/$(date +%s)` — enables instant rollback.
3. **Record baseline LOC.** Count total lines in the target module (`find {target_module} -name '*.{ext}' | xargs wc -l`). This is the denominator for the final reduction percentage.
4. **Run dead code scanner.** Execute `{dead_code}` on the target module. Save output — distribute relevant findings to teammates in Phase 2 as a grounded starting point for Tier 1. If no scanner is available, skip — teammates fall back to grep.

## Phase 1 — Inventory (read everything first)

Read ALL files in the target module and its tests. Build two lists:

### Auto-Fix Tiers

#### Tier 1 — Dead Code

This is usually where 50%+ of LOC savings come from.

Start from the dead code scanner output. For anything the scanner missed, grep the entire codebase for callers — not just the module, the whole repo. Check exports, tests, dynamic references.

If a symbol has zero callers and zero test coverage: delete it. Not comment out. Not TODO. Delete.

- Unreachable functions/methods, unused imports, commented-out code, dead branches (hardcoded feature flags), unused exception classes

**Framework caution:** Before deleting "unused" symbols, check whether the framework discovers them dynamically (Django models, Flask route decorators, React lazy imports, CLI registries, plugin systems).

#### Tier 2 — Premature Generalization

You will want to skip this tier — your pretraining tells you ABCs and factories are "good architecture." They're not when they have one implementation.

Apply this test: count concrete implementations. If the answer is 1, the abstraction is dead weight.

- ABC/Protocol with one concrete class → delete the ABC
- Factory that constructs one type → inline at call sites
- Service classes that are bags of static methods → module-level functions
- Wrapper functions that add nothing → inline the call
- Single-use "utility" functions → inline them

#### Tier 3 — Duplication

Identical or near-identical blocks repeated 2+ times → extract once, call N times. Only extract if 4+ lines, appears 2+ times, needs ≤2 parameters. Don't create new abstractions while killing old ones.

#### Tier 4 — Defensive Bloat

- Re-wrapping exceptions without adding context
- Null checks after non-nullable sources
- Validation duplicating the framework (Pydantic, Zod, serde already validates)
- Try/catch that logs and re-raises unchanged
- Defensive copies nobody asked for — returning a copy of internal data when no caller mutates it
- AI-generated "just in case" code

#### Tier 5 — Surface Compression

Lower yield per item but many items:
- Stale `# noqa:` comments for rules no longer active
- Docstrings that restate the function signature or test name
- Comments narrating the obvious
- Single-use intermediate variables → inline
- Constants used once that are obvious in-place → inline
- Exception message variables → inline into `raise`
- Walrus operator to merge assignment + condition
- Multi-line literals that fit on fewer lines within line-length

#### Tier 6 — Structural Simplification (lead handles)

**Do not hesitate here.** Moving a function between files feels "risky" because humans fear breaking imports. You're an LLM — you grep every reference and fix them all in one pass. This is trivial for you. The cost of a scattered codebase compounds forever; the cost of a file merge is one edit session.

- **File merges** — a file with one function/class imported by one consumer → merge into consumer. Move constants to their sole consumer. Merge thin `types.py`/`schemas.py`/`exceptions.py` into adjacent modules.
- **Any file under ~30 lines** that isn't `__init__.py` — question whether it needs to exist
- **Abstraction collapse** — ABC/Protocol with one impl → delete ABC, keep concrete. Factory constructing one type → inline. Service class that's a bag of static methods → module functions.
- **Solution simplification** — complex library when stdlib suffices. Class with state when a function would do.
- **Config knob removal** — knobs always set to the same value in every environment. Modes/flags never toggled.

#### Tier 7 — Test Pruning

Tests for trivial code, test files with 1-2 tests, test infrastructure more complex than what it tests, tests that mirror implementation.

### Proposal List (capability removal — needs sign-off)

Only user-facing capability removal needs approval. For each: what, why, LOC impact, risk.

## Phase 2 — Execute (team-based for large modules)

Spawn one teammate per source file with `isolation: worktree` so each gets an independent copy of the repo. This prevents mid-flight collisions when teammates edit files that import from each other. The lead merges each teammate's worktree branch after verifying their changes pass tests.

A single agent doing serial file-by-file analysis loses steam after easy wins. It skims Tiers 2-5 on src/ and declares "code is tight." Teammates can't do that — each one has exactly one file and must justify their results.

Each teammate receives: file path(s), dead code scanner findings, tier definitions, the bias-awareness section above.

Each teammate: reads their file, works through Tiers 1-5 and 7 sequentially, runs lint and relevant tests, reports back with per-tier accounting.

**Per-tier accounting is required.** For each tier: what was applied (with LOC delta), what was evaluated and kept (with specific reasons). An empty tier with no evidence of checking = you didn't check.

### Teammate Prompt Template

When spawning teammates, include this context:

> You own `{file_path}` (and `{test_file_path}` if applicable). Your job: maximize LOC reduction on this file using Tiers 1-5 and Tier 7 from the /distill skill. Default is DELETE — every line must justify its existence. Report per-tier accounting when done. Accumulate every win, even 1-liners.

## Phase 3 — Structural Work (lead)

After teammates finish, handle Tier 6: file merges, moves, structural simplification. Fix all import references in one pass.

## Phase 4 — Verify

Run lint and full test suite. All must pass. Report `git diff --stat` and reduction percentage against baseline.

## Phase 5 — Present Proposals (only if capability removals exist)

If no user-facing features were flagged, just report the `git diff --stat` total.

Otherwise present proposals for approval:
```
## Auto-fix complete: -XX lines (tests pass)

Feature removal — needs your call:

1. **Remove submit_test_feedback tool** — only used during testing phase, never
   called in production. ~-40 lines. Risk: feature removal.

Which should I remove? (e.g., "1" or "all" or "none")
```

## Boundaries — What NOT to Cut

- Logging lines (operational observability)
- Type annotations (documentation for LLMs and humans)
- Schema descriptions (user-facing field descriptions)
- Error messages with domain context
- Tests encoding domain knowledge (business rules, integration contracts)
- Framework-registered symbols (decorators, route handlers, model classes)

## Anti-Patterns

- Saving 1 line at cost of readability (need ~3+ lines saved to justify)
- Fighting the formatter
- Breaking encapsulation for LOC
- Deleting dynamically-used code
- Creating new abstractions while killing old ones
- Auto-removing user-facing capabilities

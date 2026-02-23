---
name: ux
description: Evaluate UI from real user perspective — what frustrates, confuses, or blocks users? Applies 13 UX dimensions (mapped to Nielsen's heuristics). Use after implementing UI changes or when reviewing user-facing pages.
argument-hint: [page path or URL]
---

page_path = $ARGUMENTS

Scope: If page_path provided, focus on that page/component. Otherwise, evaluate entire application UI.

## Scaling

- **Single component**: Evaluate inline — read the code, apply the most relevant dimensions, present findings. Skip the full 13-dimension sweep.
- **Full page or feature**: Apply all 13 dimensions from [ui-evaluation.md](ui-evaluation.md).
- **Entire app**: Focus on the 3 highest-traffic flows first. A full audit of every page produces so many findings that none get fixed.

## Gather Context

Use whichever methods are available (in order of preference). Combine multiple for best results.

1. **Live browser** (if any browser MCP tools are available) — Navigate, capture accessibility tree and screenshot, check console for JS errors
2. **Screenshots** — User-provided or captured via available tools
3. **Code review** — Read component/page source and evaluate from markup, styles, and logic

At least one method is required.

## Evaluate

Apply dimensions from [ui-evaluation.md](ui-evaluation.md). Score each 1-5.

**Core questions to keep in mind:**
- What would frustrate users?
- What would confuse first-time users?
- Are interactions intuitive without explanation?
- Is visual hierarchy clear?
- Are error states handled?

## Output

### Scores

Rate each evaluated dimension 1-5 (1=broken, 5=excellent). Compact table. Overall UX score = average.

### Findings

**Critical** (blocks primary task): Issue → `file:line` → specific fix
**High** (major frustration): Issue → location → fix
**What Works**: Preserve these during fixes
**Low** (polish): Brief list

### Validation

For each critical/high fix: what to test (user action) and what success looks like (behavior or outcome).

After presenting: offer to implement top 3 critical/high fixes immediately.

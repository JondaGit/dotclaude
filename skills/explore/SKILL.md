---
name: explore
description: Generate compressed codebase documentation with Repomix, then explore/answer questions using only the generated context instead of crawling the full repo. Use when the user wants to understand the codebase, onboard, investigate architecture, or answer broad questions about the project without burning tokens on full file reads.
argument-hint: [question or area to explore, e.g. "how does auth work" or "explain the data model"]
---

# Explore via Generated Documentation

You are in **documentation-assisted exploration mode**. Instead of crawling the codebase file-by-file, you generate a full compressed dump of the entire repo first, then work exclusively from that dump.

## Hard constraints

- **NEVER** use the Edit, Write, or NotebookEdit tools on project files. This is a read-only exploration mode.
- **NEVER** read source files directly from the project directory. All exploration happens from the generated dump in `/tmp/repomix-explore/`. The whole point is to avoid crawling the repo.
- You **may** write files only to `/tmp/repomix-explore/`.
- You **may** use Agent/Explore subagents — they must also only read from `/tmp/repomix-explore/`, never from project source.

## Phase 1: Generate Full Repo Dump

Dump the entire repository compressed into `/tmp/repomix-explore/`.

```bash
mkdir -p /tmp/repomix-explore

npx repomix --compress --style xml \
  --no-file-summary \
  --output /tmp/repomix-explore/repo.xml \
  --quiet
```

Always use `--compress` and `--no-file-summary`.

If the repo is large and the output exceeds comfortable reading size, use `--split-output 500kb` to split into numbered files, or re-run with `--include` patterns to split by layer (e.g., separate backend and frontend). Use your judgement based on the token count reported by Repomix.

After generation, report the token counts from the Repomix output so the user knows the cost.

## Phase 2: Read and Analyze

1. Read the generated dump file(s) from `/tmp/repomix-explore/`.
2. The compressed output contains all class/function/type signatures, column definitions, interface shapes, decorators, and structural comments — with implementation bodies stripped out.
3. Use **only** these files to answer the user's question. Do not go back to source files.

The compressed format uses `⋮----` delimiters where function/method bodies were stripped. What remains is the full structural skeleton: imports, class definitions, field types, function signatures, decorators, constants, and comments.

## How to answer

1. **State what you generated** — one line, e.g., "Generated compressed dump of the full repo (85K tokens)."
2. **Answer the question directly** — lead with the answer, cite file paths from the dump.
3. **Show the structure** — use tables, trees, or lists to map out what you found.
4. **If the compressed dump lacks detail** (e.g., user asks about specific logic inside a stripped function body), tell the user what's missing and suggest they run the question outside of `/explore` mode for a targeted source read.

## Scope

The user's question: $ARGUMENTS

If no question was provided, generate a high-level overview of the full project architecture: models, API endpoints, frontend pages, hooks, pipelines, and how they connect.

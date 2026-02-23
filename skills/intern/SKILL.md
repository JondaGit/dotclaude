---
name: intern
description: >
  Analyze recent Claude Code sessions to find suboptimal vibe-coding flows and produce
  a review report with lessons learned. Detects issues in both user prompting and agent
  behavior — over-engineering, wasted turns, missed context, poor skill usage, repeated
  friction. Even a single problematic conversation produces findings. Use when the user says
  "reflect", "what did I repeat", "analyze my sessions", "improve skills", "intern observe".
allowed-tools: Read, Glob, Grep, Bash, Edit, Write, Task
argument-hint: "[--days N]"
---

# Intern — Session Analyst

Analyze recent Claude Code sessions. Find what went wrong, what went well, and what to change. Write a review report with concrete improvements.

A single suboptimal conversation is worth learning from — don't require cross-session recurrence. Findings are valuable when actionable and specific: a quoted message, a named file, a concrete proposal. Vague observations ("communication could be improved") are worthless.

## Arguments

| Argument | Default | Description |
|----------|---------|-------------|
| `--days N` | 1 | How many days of sessions to analyze |

## Phase 1: Discover Sessions

Parse `$ARGUMENTS` for flags.

Session transcripts are JSONL files. Scan both locations for `*.jsonl` files:

| Location |
|----------|
| `~/.claude/projects/*/` |
| `~/.ccs/shared/context-groups/*/projects/*/` |

Filter: mtime within `--days` window, >2 lines, mtime >60s old (still-open sessions may be incomplete). Exclude `subagents/` directories.

If zero sessions match, report "No sessions found" and stop.

## Phase 2: Dispatch Analyst Agents

Sessions are large (multi-MB JSONL). Reading them in the main context would cause compaction and lose analytical fidelity — dispatch to subagents instead.

Batch by size: large sessions (messageCount >50) get their own agent, smaller ones batch up to 3 per agent. Spawn all in parallel via Task tool.

To spawn an analyst: `Read` the agent file from `${CLAUDE_SKILL_DIR}/agents/analyst.md`, then pass its content as the `prompt` parameter in a `Task` call. Prepend session file paths to the prompt.

## Phase 3: Synthesize

After all agents return, consolidate findings.

Merge findings pointing to the same root cause across sessions — note which sessions were affected and elevate severity when a pattern recurs. Before including proposed rules or CLAUDE.md changes, read existing `.claude/rules/*.md`, project `CLAUDE.md`, and `~/.claude/CLAUDE.md`. If a proposal contradicts an existing rule, flag the contradiction rather than proposing either side.

For each actionable finding, draft the concrete change: full rule text, specific skill edit, exact CLAUDE.md addition. Rank by impact.

## Phase 4: Write the Review Report

Write to `.intern/{timestamp}.md` (e.g., `.intern/2026-03-06T23-00.md`). Create `.intern/` if needed. Add to `.gitignore` if not present.

Sections (omit empty ones):

- **Header**: date range, session count, quality summary
- **Findings**: ranked by impact, each with severity, evidence, proposed action
- **Proposed Changes**: copy-pasteable rules, skill tweaks, CLAUDE.md edits, user tips — grouped by type
- **What Went Well**: success patterns worth reinforcing
- **Contradictions**: proposals that conflict with existing rules

## Constraints

- Redact API keys, passwords, and tokens from evidence quotes
- Skip unreadable/malformed sessions and note them in the report

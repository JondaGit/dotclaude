---
name: papers
description: Research and download state-of-the-art academic papers on a given topic. Spawns parallel agent teams to search arXiv and the web, download papers (TeX source preferred, PDF fallback), and produce structured summaries. Use when the user wants to find research papers, survey SOTA approaches, do a literature review, understand academic work on a topic, or says "find papers about X".
argument-hint: <research topic>
---

topic = $ARGUMENTS

You are a research coordinator. Your job is to find, download, and summarize the most relevant state-of-the-art academic papers on the given topic. You orchestrate a team of parallel agents to do this efficiently.

## Output structure

All papers go into the project's `.claude/papers/` directory. Create it if it doesn't exist.

```
.claude/papers/
└── <paper-slug>/
    ├── raw/          # Original files (TeX source tar.gz, .tex files, or PDF)
    └── summary/
        └── SUMMARY.md  # Structured summary of the paper
```

`<paper-slug>` is a short, kebab-case name derived from the paper title (e.g., `attention-is-all-you-need`, `rag-survey-2024`).

## Workflow

### Phase 1: Discovery (parallel search agents)

Spawn 3-4 Agent subagents **simultaneously in a single message** to search for papers from different angles:

1. **arXiv search agent** — Use WebSearch to search `site:arxiv.org` for the topic. Find 5-8 highly relevant papers. For each, extract the arXiv ID (e.g., `2301.12345`), title, authors, and abstract snippet. Return a structured list.

2. **Broader academic search agent** — Use WebSearch to search for survey papers, benchmarks, and seminal works on the topic (e.g., "state of the art [topic] survey paper 2024 2025"). Include results from Semantic Scholar, Google Scholar listings, conference proceedings. Return title, URL, and brief description for each.

3. **Recent advances agent** — Use WebSearch to find the most recent papers (last 12 months) pushing SOTA on this topic. Search for "[topic] new method 2025 2026 arxiv". Focus on papers with strong results or novel approaches.

4. **Foundational works agent** (if the topic warrants it) — Search for the seminal/foundational papers that established this research direction. These are the "must-read" papers everyone cites.

Each search agent should return a JSON-formatted list:
```json
[
  {
    "title": "Paper Title",
    "arxiv_id": "2301.12345 or null",
    "url": "https://...",
    "authors": "Author1, Author2",
    "year": 2024,
    "why_relevant": "Brief reason this paper matters for the topic"
  }
]
```

### Phase 2: Deduplicate and rank

After all search agents return, merge their results:
1. Deduplicate by arXiv ID or title similarity
2. Rank by relevance to the user's topic
3. Select the top 5-8 papers (unless the user specified a different number)
4. Present the ranked list to the user and ask if they want to proceed or adjust

### Phase 3: Download and summarize (parallel per-paper agents)

For each selected paper, spawn a dedicated Agent subagent. All paper agents run **simultaneously in a single message**. Each agent handles one paper end-to-end:

#### Download strategy

For arXiv papers, run the bundled download script located next to this skill file:

```bash
python ~/dotclaude/skills/papers/scripts/arxiv_download.py \
  --arxiv-id "ARXIV_ID" \
  --output-dir ".claude/papers/PAPER_SLUG/raw"
```

If the script is not found at that path, look for it at `.claude/skills/papers/scripts/arxiv_download.py` in the project root.

If the paper is **not on arXiv**, download the PDF directly:
```bash
mkdir -p .claude/papers/PAPER_SLUG/raw
curl -L -o .claude/papers/PAPER_SLUG/raw/paper.pdf "DIRECT_PDF_URL"
```

#### Summarize

After downloading, the agent reads the paper content:
- If TeX source is available, read the `.tex` files directly (they're plain text — much richer than PDF)
- If only PDF is available, use the Read tool on the PDF (it supports PDF reading)

Then write `.claude/papers/PAPER_SLUG/summary/SUMMARY.md` with this structure:

```markdown
# <Paper Title>

**Authors:** ...
**Year:** ...
**arXiv:** https://arxiv.org/abs/XXXX.XXXXX (if applicable)
**URL:** ...

## TL;DR
One-paragraph summary of what this paper does and why it matters.

## Key Contributions
- Bullet list of the paper's main contributions

## Approach / Method
Detailed description of the method, architecture, or approach.
Include relevant formulas in LaTeX notation where they help understanding.

## Key Formulas
List the most important equations with brief explanations of each term.
Use LaTeX math notation: $formula$

## Results
- Key quantitative results and benchmarks
- How it compares to prior SOTA
- Tables of results if available

## Interesting Findings
- Surprising or non-obvious insights from the paper
- Ablation study highlights
- Limitations acknowledged by the authors

## Relevance to Our Topic
How this paper specifically relates to: {topic}
```

### Phase 4: Research summary

After all paper agents complete, write a top-level summary at `.claude/papers/RESEARCH_SUMMARY.md` that:
1. Lists all downloaded papers with links to their summary files
2. Synthesizes the key themes and trends across papers
3. Identifies gaps or open problems in the literature
4. Suggests which papers are most relevant for the user's specific needs

## Important notes

- Respect arXiv rate limits: the download script handles this, but if doing manual requests, wait 3+ seconds between arXiv calls
- If a download fails (paper withdrawn, access restricted), note it in the summary and move on
- Prefer TeX source over PDF — TeX is searchable plain text with formulas intact
- When spawning agents, give each one complete context — they don't share memory with each other
- Always tell the user how many papers were found, how many are being processed, and report completion

## If no topic was provided

Ask the user: "What research topic would you like me to find papers on? I'll search arXiv and academic sources for the most relevant state-of-the-art work."

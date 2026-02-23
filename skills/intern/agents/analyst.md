You are analyzing Claude Code session transcripts. Find what went wrong, what went well, and what concrete changes would improve future sessions.

## Analytical principles

**Actionable over observational.** Every finding should suggest a specific change: a rule to add, a skill to tweak, a prompting habit. "The agent was verbose" is an observation. "Add a rule: match the user's message length" is a finding.

**Severity reflects wasted effort and frustration**, not turn counts. A single turn that produces completely wrong output is more severe than 6 turns of minor style negotiation.

**Both sides matter.** Did the user give enough context? Did the agent use it well?

**Track the emotional arc.** Notice if the user grows frustrated (shorter messages, stronger language, repeated instructions), resigns ("fine", "I'll do it myself"), or recovers. The arc often reveals the most important finding.

**Success patterns are findings too.** When a session runs smoothly, identify what made it work.

## Session files

{list each fullPath}

## JSONL format

Each line is JSON. Key fields:
- `type: "user"` — user message, text in `.message.content`
- `type: "assistant"` — agent response, `.message.content` array with `text`, `tool_use`, `tool_result`

## Output

Return valid JSON:

```json
{
  "sessions": [
    {
      "session_id": "...",
      "summary": "1-2 sentences",
      "quality": "smooth | minor-friction | significant-friction | painful",
      "emotional_arc": "Free-text description",
      "findings": [
        {
          "type": "user-prompting | agent-behavior | skill-gap | success-pattern",
          "severity": "critical | notable | minor",
          "what_happened": "Concrete description",
          "evidence": "Direct quote or close paraphrase",
          "lesson": "What should change",
          "suggested_action": {
            "kind": "rule | skill-tweak | claude-md | script | user-habit | none",
            "target": "file path or skill name",
            "detail": "The specific change"
          }
        }
      ]
    }
  ]
}
```

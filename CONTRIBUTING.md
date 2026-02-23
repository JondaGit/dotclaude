# Contributing to dotclaude

Thanks for your interest in contributing!

## Adding or improving a skill

1. Fork the repo and create a branch.
2. Each skill is a self-contained directory under `skills/` with at minimum a `SKILL.md` file.
3. Follow the [Agent Skills open standard](https://agentskills.io/specification) — YAML frontmatter with `name`, `description`, and optional `tools` restrictions.
4. Keep supporting files (references, scripts, examples) inside the skill directory.
5. Open a PR with a clear description of what the skill does and why it's useful.

## Skill quality bar

- The skill should solve a real, recurring problem in the dev workflow.
- It should work out of the box after copying into `~/.claude/skills/`.
- No external dependencies unless absolutely necessary (and documented).
- Test it in a real Claude Code session before submitting.

## Reporting issues

Use the issue templates — they help us understand and fix problems faster.

## Code of conduct

Be respectful. See [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).

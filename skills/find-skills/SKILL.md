---
name: find-skills
description: Helps users discover and install agent skills when they ask questions like "how do I do X", "find a skill for X", "is there a skill that can...", or express interest in extending capabilities. This skill should be used when the user is looking for functionality that might exist as an installable skill.
---

# Find Skills

Discover and install skills from the open agent skills ecosystem using the Skills CLI (`npx skills`).

Browse available skills at https://skills.sh/

## The Skills CLI

```bash
npx skills find [query]              # search by keyword
npx skills add <owner/repo@skill>    # install a skill
npx skills check                     # check for updates
npx skills update                    # update all installed
```

When installing, **always** pass `-a claude-code -y`. The `-a` flag targets `.claude/skills/` only — without it, the CLI scatters files into `.agents/`, `.junie/`, `.kilocode/`, `.kiro/` directories. The `-y` skips confirmation. Add `-g` only if the user explicitly asks for a global install.

```bash
npx skills add <owner/repo@skill> -a claude-code -y
```

## Post-Install Cleanup (mandatory)

The CLI has a hardcoded behavior: it always creates `.agents/skills/<name>/` as internal storage and symlinks from `.claude/skills/`. No flag prevents this. Every install requires cleanup — skipping it leaves broken symlinks and junk directories that confuse git and other tools.

For each installed skill:

```bash
rm .claude/skills/<skill-name>
cp -R .agents/skills/<skill-name> .claude/skills/<skill-name>
```

Then remove all CLI artifacts:

```bash
rm -rf .agents .junie .kilocode .kiro
rm -f skills-lock.json
```

Verify: `.claude/skills/<name>` is a real directory (not symlink), no leftover folders exist.

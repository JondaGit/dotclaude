---
name: conventional-commits
description: Ensures Git commits follow the Conventional Commits specification (v1.0.0). Use when creating commits, reviewing commit messages, or writing commit messages — even when invoked indirectly through the commit skill. Triggers on any commit-related workflow.
---

# Conventional Commits

Commit messages must be human and machine-readable. This specification provides the structure.

## Format

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

## Types

| Type | Purpose | Example |
|------|---------|---------|
| **feat** | New feature | `feat(api): add JWT token generation` |
| **fix** | Bug fix | `fix: resolve login redirect loop` |
| **docs** | Documentation only | `docs(readme): add troubleshooting section` |
| **style** | Formatting, whitespace (no logic change) | `style: format code with StandardRB` |
| **refactor** | Neither fix nor feature | `refactor: extract user validation to service object` |
| **perf** | Performance improvement | `perf(queries): reduce N+1 queries in artifacts index` |
| **test** | Adding or updating tests | `test(integration): add webhook processing tests` |
| **chore** | Build process, deps, maintenance | `chore(deps): bump sidekiq from 7.1.0 to 7.2.0` |
| **build** | Build system or dependencies | `build: configure Docker for production` |
| **ci** | CI configuration | `ci: add security scanning to GitHub Actions` |
| **revert** | Reverts a previous commit | `revert: revert "feat: add export feature"` |

## Scope

Optional context about what part of the codebase changed. Choose scopes that match the project's architecture:

```
feat(auth): add two-factor authentication
fix(api): handle rate limit errors
refactor(services): extract common validation logic
```

## Description Rules

- Imperative, present tense: "add" not "added" or "adds"
- No capital first letter
- No trailing period
- Under 72 characters (ideally under 50)

## Body

Separate from description with a blank line. Use when the change needs explanation — complex logic, non-obvious decisions, breaking changes.

```
feat(api): add webhook signature verification

Add HMAC-SHA256 signature verification for all incoming webhooks
to prevent unauthorized access and replay attacks.

The signature is validated using a secret key stored per
installation. Requests with invalid signatures are rejected
with a 401 response.
```

## Footers

### Breaking Changes

Use `BREAKING CHANGE:` footer or `!` after type/scope:

```
feat(api)!: remove deprecated /login endpoint

BREAKING CHANGE: The /auth endpoint now requires a client_id parameter.
Update all API clients to include client_id in authentication requests.
```

### Issue References

```
fix(auth): resolve session timeout bug

Fixes #123
Related to #789
```

### Co-authors

```
feat: add data export feature

Co-authored-by: Jane Doe <jane@example.com>
```

## Principles

- **Atomic commits** — one logical change per commit
- **Intent over implementation** — the diff shows what; the message explains why
- **If you can't write a focused message, split the commit**
- **Each commit should leave the codebase in a working state**

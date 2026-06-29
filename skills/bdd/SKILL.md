---
name: bdd
description: Use when writing, generating, or implementing end-to-end BDD tests with Gherkin and playwright-bdd — any request to add a `.feature` file, a behavior/acceptance/E2E scenario, a "test the whole flow" check, or to cover a user journey across frontend, backend, and database. Trigger on mentions of Gherkin, Cucumber, `.feature`, scenarios, playwright-bdd, `bddgen`, BDD, or "test it end to end", even when the user doesn't name the tool.
---

You write **end-to-end** BDD tests: Gherkin scenarios that drive the real frontend, which calls the real backend, which reads and writes the real database. The value of these tests is that they exercise the whole system the way a user does. A test that mocks a layer away is not the test you were asked to write.

## The Pipeline

1. **Reconnoiter** the existing E2E BDD setup (always — never assume the layout).
2. **Write** the `.feature` file(s) in Gherkin.
3. **Generate** Playwright spec files from the features with `playwright-bdd` (`bddgen`).
4. **Implement** the step definitions — drive the UI, let it hit the backend, assert at every layer including the DB.
5. **Run** the suite and confirm it passes for the right reason.

Steps 2 and 4 are coupled: `bddgen` binds each Gherkin step to a step definition. Write the feature first, run `bddgen` to see which steps are unbound, then implement them.

## 1. Reconnaissance (do this first, every time)

Before writing anything, find and study the existing E2E BDD test directory. You are matching an established setup, not inventing one.

Find it by locating `.feature` files and the `playwright-bdd` config:

```bash
find . -name '*.feature' -not -path '*/node_modules/*'
grep -rl 'defineBddConfig\|createBdd' --include='*.ts' --include='*.js' . | grep -v node_modules
```

From what you find, establish:

- **Where features live** and where step definitions live (`defineBddConfig({ features, steps })` in the Playwright config is the source of truth).
- **Existing scenarios** — read 2+ of them. Match their Gherkin vocabulary, tagging, and granularity. Reuse existing steps before writing new ones; duplicate steps with slightly different wording are the main way a BDD suite rots.
- **Custom fixtures** — most suites extend `createBdd(test)` with fixtures for an API client, a DB handle, an authenticated page, or test-data factories. Use them; don't reinvent them.
- **How the app under test is started** (Playwright `webServer`, docker compose, a dev script) and **how the DB is provisioned** (migrations, a seed script, a fixture loader, transactional rollback).
- **The run command** — usually `bddgen` then `playwright test`, often wrapped in an npm script.

If there is genuinely no existing E2E BDD setup, say so and confirm the intended layout with the user before scaffolding one.

## 2. Writing Gherkin

Gherkin describes **behavior from the user's perspective**, not implementation. Each scenario is one coherent outcome.

- **Given** establishes state (seeded data, authenticated user). **When** is the user action. **Then** is the observable result.
- Keep steps declarative — "When the customer submits the order", not "When the user clicks #submit-btn". UI selectors belong in step definitions, not in the feature.
- One behavior per scenario. Use `Scenario Outline` with `Examples` for the same flow across input variants; `Background` for shared setup.
- Phrase steps so they can be reused across features. A reusable step library is the payoff of BDD.

## 3. Generating Playwright Specs

`playwright-bdd` converts features into runnable Playwright test files. The config wires it up:

```ts
// playwright.config.ts
import { defineConfig } from '@playwright/test';
import { defineBddConfig } from 'playwright-bdd';

const testDir = defineBddConfig({
  features: 'e2e/features/**/*.feature',
  steps: 'e2e/steps/**/*.ts',
});

export default defineConfig({ testDir, /* webServer, projects, ... */ });
```

Generate, then run:

```bash
npx bddgen && npx playwright test
```

`bddgen` writes generated specs (default `.features-gen/`) — never hand-edit those; they are regenerated every run. It also reports any Gherkin step with no matching definition. That report is your implementation to-do list.

## 4. Implementing Steps — End to End, No Shortcuts

This is where the mandate lives. Step definitions bind to Gherkin steps via `createBdd`:

```ts
import { createBdd } from 'playwright-bdd';
const { Given, When, Then } = createBdd();
```

**Drive the real stack through every link:**

- **FE** — act through the rendered UI (`page.getByRole`, fill forms, click). Do not call the backend API to simulate a user action that the user performs in the browser. The point is to prove the UI actually triggers the backend.
- **BE** — let the frontend's real network calls reach the real backend. Do not stub, intercept, or mock the API for the behavior under test. (Mocking a genuinely external, uncontrollable third party — a payment gateway, an email provider — is acceptable; mocking your own backend defeats the test.)
- **DB** — assert the persisted result directly against the database, not only what the UI echoes back. A green UI message is not proof the row was written.

**Test inputs and outputs honestly — this is the anti-laziness rule.** A passing test must prove the behavior actually happened, end to end:

- After a write action, assert the **actual persisted state** in the DB (the new row exists, with the *correct field values*), then assert the UI reflects it. Both layers, not one.
- Assert on **meaningful values**, not existence. Check the order total is `42.00`, the status is `confirmed`, the foreign keys link correctly — not merely that "a record exists" or "the response was 200".
- Cover the **failure and boundary paths** the scenario implies (validation rejects bad input, the DB is left unchanged on error), not just the happy path.
- Never weaken an assertion, add a blind `waitForTimeout`, or relax a selector just to make a test go green. A test that passes for the wrong reason is worse than no test — it certifies broken behavior.

## 5. Database Seeding & Isolation

Seed however the project's setup prefers — a seed script, factory helpers, direct inserts, or API calls in a `Given` step. The method is free; the rigor is not.

- Each scenario must control its own preconditions and not depend on another scenario's leftovers. Prefer per-test isolation (transactional rollback, truncate-and-reseed, or unique data per run) — match whatever the existing suite does.
- Seed the **specific** data the scenario asserts on, so the `Then` checks are exact, not approximate.
- Clean up what you create so reruns are deterministic.

## 6. Verify

Run `bddgen && playwright test` and confirm green. Then sanity-check that it's green for the right reason: temporarily break the behavior (or the assertion) and confirm the test fails. A test that can't fail isn't testing anything.

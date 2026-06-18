---
name: architecture-language
description: Read architecture vocabulary and acceptance criteria before making or evaluating claims about modules, interfaces, seams, adapters, deep modules, dependency categories, or test seams. Use when refactoring, designing, reviewing, TDD planning, or issue/PRD writing mentions architecture, ports/adapters, module depth, testability, or seams.
---

# Architecture Language

Read this before continuing whenever you are about to use architecture vocabulary as a claim, not as casual prose.

This skill is deliberately small and non-orchestrating. It does not replace `/codebase-design`; it turns the codebase-design vocabulary into acceptance and evidence checks.

## How to use

1. Load the smallest relevant term card before making or evaluating an architecture claim.
2. Use the card's **Accepted when** criteria as the positive definition of done.
3. If evidence is missing, use candidate language instead of pretending the design is proven.
4. Do not over-abstract to satisfy the vocabulary. A simple refactor is better than an unnecessary seam.

## Cards

- [Module](module.md) — a named unit with an interface and implementation.
- [Interface](interface.md) — everything callers must know to use a module correctly.
- [Seam](seam.md) — where behavior can vary without changing callers.
- [Adapter](adapter.md) — a concrete implementation of an interface at a seam.
- [Deep module](deep-module.md) — callers learn less while getting more behavior.
- [Test seam](test-seam.md) — the public interface through which behavior is verified.
- [Dependency categories](dependency-categories.md) — how dependency shape affects seam and test strategy.

## Status language

Use status words when evidence is still missing:

- **Deepening candidate** — the area may become a deep module, but the interface is not accepted yet.
- **Accepted deep module** — the [deep module](deep-module.md) criteria are satisfied and evidenced.
- **Hypothetical seam** — the place could vary behavior, but variation/adapters/tests are not evidenced yet.
- **Proven seam** — the [seam](seam.md) criteria are satisfied and evidenced.
- **Adapter candidate** — a concrete integration point is likely, but the interface/translation strategy is not accepted yet.
- **Accepted adapter** — the [adapter](adapter.md) criteria are satisfied and evidenced.

## Evidence rule

Architecture vocabulary is a claim about code shape. When using these terms in a plan, issue, PRD, implementation, or review, include the evidence requested by the relevant card. If the evidence is not available yet, keep the status as a candidate or hypothesis.

Use project domain vocabulary from `CONTEXT.md` for names, and these cards for architecture vocabulary.

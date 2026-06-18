# Architecture Language

Shared term cards for engineering skills. Use these cards to keep **module**, **interface**, **seam**, **adapter**, and **deep module** claims concrete.

These files are reference material, not a separate workflow. Load the smallest card needed before making or implementing an architecture claim.

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

## Applying the language

Architecture vocabulary is a claim about code shape. When using these terms in a plan, issue, PRD, implementation, or review, include the evidence requested by the relevant card. If the evidence is not available yet, keep the status as a candidate or hypothesis.

Use project domain vocabulary from `CONTEXT.md` for names, and these cards for architecture vocabulary.

---
name: issue-series-orchestrator
description: Orchestrate sequential GitHub issue implementation through subagents with one issue per commit. Use when the user wants a dispatcher/orchestrator to run an issue series from a YAML manifest while keeping parent context minimal.
---

# Issue Series Orchestrator

Use this skill to execute an issue-series manifest as a dispatcher. The parent agent must stay small: it coordinates subagents, tracks state, and avoids reading long issue/docs content itself.

## Quick start

1. Load the manifest path provided by the user.
2. If subagents are needed, load/use `pi-subagents` and inspect available agents first.
3. `cd` to `repo.cwd` and check `git status --short`.
4. Run the runtime-skill preflight before starting the first source-editing worker.
5. Process `issues.sequence` strictly in order.
6. For each issue: implementation worker → acceptance reviewer/committer → next issue.

See [REFERENCE.md](REFERENCE.md) for subagent prompt templates.

## Parent responsibilities

Keep only this state:
- current issue
- issue start commit SHA (`git rev-parse HEAD` before implementation)
- current status
- commit hash after completion
- next issue
- fix/review cycle count

The parent may run minimal checks:
- `git status --short`
- `git diff --stat`
- `git log -1 --oneline`
- a read-only runtime-skill preflight subagent

The parent should not read long issue bodies, PRDs, docs, or large diffs unless a child is blocked or reports a serious inconsistency.

## Workflow per issue

Skill injection rule:
- `workflow.implementationSkill` is required for source-editing workers: implementation worker and fix worker.
- If the manifest omits it, treat it as `tdd` unless the user explicitly provides another value before execution.
- Always pass it via the subagent runtime `skill` parameter, e.g. `skill: workflow.implementationSkill`.
- Do not merely tell the worker “use TDD” in prose; inject the skill so the worker receives the actual skill instructions.
- Before starting the first source-editing worker, run a read-only smoke-test subagent with the same runtime `skill` override and `output: false`; if it cannot confirm the expected skill content is loaded, stop before launching implementation.
- Implementation and fix workers must fail closed: if the expected implementation skill was not injected at runtime, they stop before editing source files. For the default workflow this means `/skill:tdd` must be loaded.
- Do not treat string vs array syntax (`skill: "tdd"` vs `skill: ["tdd"]`) as a fix for failed injection. If the preflight fails, diagnose subagent skill discovery/configuration.
- `review.reviewerSkill` is for the neutral acceptance reviewer/committer only and must be `review` for this workflow.
- Always pass it via the subagent runtime `skill` parameter, e.g. `skill: review.reviewerSkill`, so `/skill:review` is loaded.
- Never inject `workflow.implementationSkill` into the acceptance reviewer; reviewers use `review.reviewerSkill` (`review`).

Artifact hygiene rule:
- Child output artifacts must not be written under `repo.cwd` because they dirty the issue commit worktree.
- Use `output: false` for implementation/fix/review workers unless an explicit artifact path outside `repo.cwd` is required.
- If an artifact dirties the repo, stop and ask before deleting it.

1. Clean-worktree gate:
   - If manifest requires clean worktree and status is dirty before starting an issue, stop and ask user.

2. Runtime-skill preflight:
   - Resolve `workflow.implementationSkill`; default to `tdd` only if the manifest omits it and the user has not explicitly overridden it.
   - Launch a read-only smoke-test subagent with `skill: workflow.implementationSkill` and `output: false`.
   - Ask it to confirm the expected skill instructions are present in its loaded context.
   - If it reports missing skill content, stop before implementation and ask the user to fix subagent skill discovery/configuration.
   - Repeat this preflight if the implementation skill changes during the series.

3. Start implementation worker:
   - One writer only.
   - Worker reads current issue, manifest references, relevant prior issues/blockers, code, and tests.
   - Launch the worker with the subagent runtime override `skill: workflow.implementationSkill`.
   - Use `output: false` unless an explicit artifact path outside `repo.cwd` is required.
   - Worker follows the injected implementation skill.
   - If the expected skill was not injected, the worker must stop before source edits.
   - Worker implements only the current issue.
   - Worker runs relevant tests.
   - Worker does not commit.

4. Minimal parent check:
   - Inspect worker report.
   - Run `git status --short` and `git diff --stat`.
   - If untracked files are only subagent output artifacts, stop and ask before deleting them; do not continue with a dirty repo.
   - Do not perform detailed review unless needed.

5. Start acceptance reviewer/committer if review is enabled:
   - This is the second neutral instance.
   - It reads the current issue and inspects the actual diff.
   - It may read references only as needed.
   - `review.reviewerSkill` must be `review` for this workflow; launch the reviewer with `skill: review.reviewerSkill` so `/skill:review` is definitely loaded.
   - Use `output: false` unless an explicit artifact path outside `repo.cwd` is required.
   - Pass the issue start commit SHA as the `/skill:review` fixed point, and explicitly tell the reviewer that the artifact under review is the current uncommitted diff from that fixed point.
   - Pass `review.comparisonSources` and `review.mustRejectIf` from the manifest as explicit review criteria.
   - The worker report is only claims to verify, not authoritative truth.
   - It must not edit project source files.
   - If acceptance passes, it performs commit/push/comment according to manifest.
   - If acceptance fails, it returns blockers and does not commit.

6. If acceptance fails:
   - Start a fix worker for the same issue.
   - Fix worker receives blocker report and current issue.
   - Launch the fix worker with the same subagent runtime override `skill: workflow.implementationSkill`.
   - Use `output: false` unless an explicit artifact path outside `repo.cwd` is required.
   - If the expected implementation skill was not injected, the fix worker must stop before source edits.
   - Fix worker edits only within issue scope and does not commit.
   - Resume the same acceptance reviewer when possible; otherwise start a new neutral acceptance reviewer with `skill: review.reviewerSkill` (`review`).
   - Stop after `review.maxFixReviewCycles` or if a product/architecture/scope decision is needed.

7. After commit:
   - Record issue → commit hash.
   - Verify clean worktree.
   - Continue to next issue.

## Stop rules

Stop and ask the user when:
- worktree is dirty before an issue starts
- issue appears blocked
- scope or acceptance criteria are unclear
- architecture/product/API decision is required
- tests remain failing after allowed fix cycles
- acceptance reviewer refuses commit due to real blockers
- runtime-skill preflight fails or implementation/fix worker reports that the expected implementation skill was not injected
- child output artifacts dirty `repo.cwd`
- changes appear to include future issue scope

## Final report

Return a compact table:

| Issue | Status | Commit | Tests | Risks |
|---|---|---|---|---|

Do not paste long worker/reviewer logs unless the user asks.

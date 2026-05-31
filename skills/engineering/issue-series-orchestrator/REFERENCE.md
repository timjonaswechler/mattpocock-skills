# Issue Series Orchestrator Reference

## Runtime-skill preflight

Before launching the first implementation or fix worker, verify that the subagent runtime can actually inject the configured implementation skill. This catches skill discovery/configuration failures before any source-editing worker or output artifact can dirty the target repo.

```ts
subagent({
  agent: "delegate",
  task: `Read-only smoke test. Report whether the expected injected implementation skill is present in your loaded instructions. Expected skill: ${workflow.implementationSkill ?? "tdd"}. Do not edit files. Return injected=yes/no and one sentence of evidence.`,
  skill: workflow.implementationSkill ?? "tdd",
  context: "fresh",
  output: false
})
```

If the smoke test reports `injected=no`, stop. Do not retry by switching from `skill: "tdd"` to `skill: ["tdd"]`; both forms should resolve the same skill. Diagnose subagent skill discovery/configuration instead.

## Implementation worker launch

Resolve `workflow.implementationSkill` before launch. It is required; default to `tdd` unless the user explicitly overrides it. Launch the implementation worker with the runtime skill override so the worker receives the actual skill content, not only prose guidance:

```ts
subagent({
  agent: "worker",
  task: implementationWorkerPrompt,
  skill: workflow.implementationSkill ?? "tdd",
  async: true,
  output: false
})
```

The worker must not be launched for source-editing work without this runtime `skill` parameter. Do not write subagent output artifacts under `repo.cwd`; use `output: false` unless an explicit artifact path outside the target repo is required.

## Implementation worker prompt template

```text
You are the implementation worker for GitHub issue #<ISSUE> in <OWNER/REPO>.

Goal:
Implement only issue #<ISSUE> in <CWD>.

Context to read yourself:
- GitHub issue #<ISSUE>, including body, comments, labels, links, blockers.
- Manifest references: <REFERENCES>.
- Relevant previous issues from this series if they are blockers or completed context.
- Current code and tests touched by the issue.

Runtime skill gate:
- Expected injected implementation skill: <IMPLEMENTATION_SKILL>.
- <IMPLEMENTATION_SKILL> must be `tdd` unless the user explicitly overrides it.
- For the default workflow this is `tdd`, meaning `/skill:tdd` must be loaded in this worker.
- Before editing source files, verify from your loaded instructions/context that the expected skill was actually injected.
- If `/skill:tdd` was not injected for the default workflow, stop and report a blocker instead of implementing.
- If the expected skill was not injected, stop immediately and report:
  - Decision: blocked-missing-implementation-skill
  - Expected skill:
  - No source files edited: yes

Rules:
- Follow the injected implementation skill provided by the parent via subagent runtime override: <IMPLEMENTATION_SKILL>.
- Implement only #<ISSUE>; do not pull in future issue scope.
- There is only one writer: you.
- Do not commit, push, or comment on GitHub.
- If scope, product behavior, API shape, or architecture is unclear, stop and report the blocker instead of guessing.

Validation:
- Run the focused tests needed for #<ISSUE>.
- Run broader tests when the change affects shared runtime behavior.

Report:
- Issue:
- Scope implemented:
- Explicitly not implemented:
- Changed files:
- Tests/commands + results:
- Open risks:
- Blockers/decisions needed:
- Commit-ready: yes/no
```

## Acceptance reviewer/committer launch

Before starting implementation for each issue, record the issue fixed point:

```bash
git rev-parse HEAD
```

When `review.reviewerSkill` is set, it must be `review` for this workflow. Launch the acceptance reviewer with the runtime skill override so `/skill:review` is definitely loaded:

```ts
subagent({
  agent: "worker",
  task: acceptanceReviewerPrompt,
  skill: review.reviewerSkill, // expected: "review"
  async: true,
  output: false
})
```

Do not use `workflow.implementationSkill` for this role.

## Acceptance reviewer/committer prompt template

```text
You are the neutral acceptance reviewer and committer for GitHub issue #<ISSUE> in <OWNER/REPO>.

Goal:
Use the injected `/skill:review` instructions to perform a two-axis review, but adapt the diff target to this pre-commit issue-series workflow. Review the current uncommitted diff against issue #<ISSUE> and the manifest criteria. If and only if acceptance passes, create exactly one commit for this issue, push it if configured, and comment on the GitHub issue if configured.

/skill:review fixed point:
- Fixed point supplied by parent: <ISSUE_START_SHA>.
- Treat this as the "fixed point" required by `/skill:review`.
- Because this workflow reviews before commit, the artifact under review is the current uncommitted diff from that fixed point: `git diff <ISSUE_START_SHA>`.
- Also inspect `git status --short` and staged/unstaged state to ensure the commit can be issue-pure.

Context to read yourself:
- GitHub issue #<ISSUE>, including body, acceptance criteria, comments, links, labels, and blockers.
- Manifest review criteria:
  - comparisonSources: <REVIEW_COMPARISON_SOURCES>
  - mustRejectIf: <REVIEW_MUST_REJECT_IF>
- Manifest scope, non-goals, future issues, and references.
- Current uncommitted git diff and tests evidence.
- Worker report below, as claims to verify against the actual issue/diff/tests, not as truth.

Runtime skill:
- Follow the injected reviewer skill provided by the parent via subagent runtime override: <REVIEWER_SKILL>.
- `<REVIEWER_SKILL>` must be `review`. If `/skill:review` was not injected, stop and report a blocker instead of reviewing.
- Use `/skill:review`'s Standards and Spec axes, but the Spec axis must compare against the GitHub issue plus manifest criteria listed here.

Hard constraints:
- Do not edit project source files.
- Do not fix code yourself.
- Do not commit if acceptance criteria are missing, ambiguous, or unmet; tests are insufficient/failing; scope includes future issues; or the diff is not issue-pure.
- Commit only changes for #<ISSUE>.

Comparison contract:
Evaluate each criterion independently and cite evidence.

Required sources, in order:
1. GitHub issue #<ISSUE>: acceptance criteria, body, comments, links, labels, blockers.
2. Manifest: scope summary, non-goals, future issues, references, review comparison sources, reject rules.
3. Actual uncommitted diff from `<ISSUE_START_SHA>`.
4. Tests and command output.
5. Worker report as claims to verify, not authoritative truth.

Reject if any `review.mustRejectIf` condition is met, especially:
- any acceptance criterion is missing, ambiguous, or unmet
- diff includes scope creep or future issue work
- tests are failing, missing, or irrelevant to the changed behavior
- reviewer would need to edit source to make it acceptable
- staged/unstaged changes cannot form exactly one issue-pure commit

Required output before any commit decision:

| Criterion | Source | Evidence | Result |
|---|---|---|---|
| ... | issue/manifest/diff/tests | file:line, command, or observed output | pass/fail/unclear |

If acceptance fails:
Return blockers in this format and do not commit:
- Decision: rejected-needs-fix-worker OR blocked-needs-user-decision
- Blockers:
- Suggested fix-worker scope:
- Tests to rerun:

If acceptance passes:
- Use the git-commit process.
- Stage only #<ISSUE> changes.
- Create a Conventional Commit including the issue number when configured.
- Push when `remote.pushAfterCommit` is true.
- Comment on GitHub issue when `remote.commentOnIssue` is true with:
  - short summary
  - tests run
  - commit hash

Return:
- Decision: accepted-and-committed
- Commit hash:
- Pushed: yes/no
- Issue comment: yes/no
- Tests verified:
- Risks:

Worker report:
<WORKER_REPORT>
```

## Fix worker launch

Resolve `workflow.implementationSkill` before launch. It is required; default to `tdd` unless the user explicitly overrides it. Launch the fix worker with the same runtime skill override used for the implementation worker:

```ts
subagent({
  agent: "worker",
  task: fixWorkerPrompt,
  skill: workflow.implementationSkill ?? "tdd",
  async: true,
  output: false
})
```

The fix worker must not be launched for source-editing work without this runtime `skill` parameter. Do not write subagent output artifacts under `repo.cwd`; use `output: false` unless an explicit artifact path outside the target repo is required.

## Fix worker prompt template

```text
You are the fix worker for GitHub issue #<ISSUE>.

Goal:
Apply only the fixes required by the neutral acceptance reviewer blockers. Stay inside #<ISSUE> scope.

Read:
- Issue #<ISSUE>.
- Acceptance blocker report.
- Current diff/code/tests.
- Manifest references only as needed.

Runtime skill gate:
- Expected injected implementation skill: <IMPLEMENTATION_SKILL>.
- <IMPLEMENTATION_SKILL> must be `tdd` unless the user explicitly overrides it.
- For the default workflow this is `tdd`, meaning `/skill:tdd` must be loaded in this worker.
- Before editing source files, verify from your loaded instructions/context that the expected skill was actually injected.
- If `/skill:tdd` was not injected for the default workflow, stop and report a blocker instead of implementing.
- If the expected skill was not injected, stop immediately and report:
  - Decision: blocked-missing-implementation-skill
  - Expected skill:
  - No source files edited: yes

Rules:
- Follow the injected implementation skill provided by the parent via subagent runtime override: <IMPLEMENTATION_SKILL>.
- You may edit source/test/docs files as needed for the blockers.
- Do not commit, push, or comment.
- Do not introduce future issue scope.
- Stop if the blocker requires a product/API/architecture decision.

Report:
- Blockers addressed:
- Changed files:
- Tests/commands + results:
- Remaining risks:
- Commit-ready: yes/no
```

## Parent launch notes

- Prefer async subagent launches unless the parent has nothing useful to do.
- Treat `workflow.implementationSkill` as required. Default to `tdd` only when omitted and not explicitly overridden by the user.
- Run the read-only runtime-skill preflight before the first source-editing worker.
- Never launch implementation or fix workers without the runtime `skill` parameter.
- Implementation workers and fix workers must receive `skill: workflow.implementationSkill` in the `subagent(...)` call.
- If the preflight fails or a worker reports `blocked-missing-implementation-skill`, stop orchestration and ask the user; do not continue with prose-only TDD instructions.
- Do not dirty `repo.cwd` with subagent output artifacts. Prefer `output: false`; if artifacts are necessary, use an absolute path outside the target repo.
- Acceptance reviewer must receive `skill: review.reviewerSkill` in the `subagent(...)` call; for this workflow the manifest should set `review.reviewerSkill: review` so `/skill:review` is always used.
- Pass the issue start SHA, `review.comparisonSources`, and `review.mustRejectIf` into the reviewer prompt every time.
- Implementation/fix workers use `workflow.implementationSkill`; reviewers use `review.reviewerSkill` (`review`).
- Keep implementation/fix as the only source-editing roles.
- Acceptance reviewer may run git/gh commands for commit/push/comment but must not source-edit.
- If possible after a fix pass, resume the same acceptance reviewer session so it can reuse context; otherwise launch a fresh neutral reviewer with the updated diff and previous blocker report.

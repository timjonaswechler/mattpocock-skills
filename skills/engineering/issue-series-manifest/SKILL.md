---
name: issue-series-manifest
description: Create reusable YAML manifests for sequential GitHub issue-series orchestration. Use when the user wants to prepare an issue series, convert a handoff/plan into an orchestrator manifest, or define reusable rules for repeated issue implementation workflows.
---

# Issue Series Manifest

Use this skill to turn a handoff, plan, conversation, or GitHub issue chain into a compact YAML manifest that a separate issue-series orchestrator can execute repeatedly.

## Quick start

1. Identify the repo and working directory.
2. Identify the ordered issue sequence.
3. Collect global references and issue dependencies.
4. Ask only for missing workflow policy decisions.
5. Write a manifest under `.pi/issue-series/<name>.yaml` unless the user requests another path.

See [SCHEMA.md](SCHEMA.md) for the manifest fields.

## Information to gather

Required:
- `repo.github`: owner/repo for GitHub operations.
- `repo.cwd`: local working directory.
- `issues.sequence`: issue numbers in strict execution order.
- `references`: files, issues, PRs, and URLs workers should read themselves.

Policy decisions:
- Whether the user explicitly overrides the default implementation skill. Default and required value is `workflow.implementationSkill: tdd`; do not ask about this unless the user signals a different implementation workflow.
- Whether review is required before commit.
- Whether acceptance reviewer also commits.
- Review skill policy: use `review.reviewerSkill: review` so `/skill:review` is always injected into the acceptance reviewer.
- Whether to push after commit.
- Whether to comment on the GitHub issue.
- Stop conditions for dirty worktree, failing tests, unclear scope, blockers, or architecture decisions.

## GitHub evidence collection

If `gh` is available and the user allows GitHub access, use it to inspect issue metadata, body, comments, linked issues/PRs, labels, state, milestones, and blockers. Keep the manifest compact; do not paste long issue bodies into it.

Useful command shape:

```bash
gh issue view <number> --repo <owner/repo> \
  --json number,title,state,labels,body,comments,assignees,milestone,url
```

When linked issues or PRs are mentioned in bodies/comments, add them as references or blockers rather than duplicating their contents.

## Manifest-writing rules

- Store variable project context in the manifest, not in the reusable orchestrator prompt.
- Prefer issue/PR numbers and file paths over copied prose.
- Mark completed predecessor issues in `issues.alreadyDone`.
- Put non-goals and future issues in `scope.nonGoals` or `scope.futureIssues`.
- Set conservative defaults when policy is missing, then ask the user to confirm.
- `workflow.implementationSkill` is required for this workflow. Default it to `tdd`.
- Only set `workflow.implementationSkill` to a non-`tdd` value when the user explicitly requests or confirms that override.
- The value must be a Pi skill name usable as a subagent runtime skill override.
- The orchestrator must inject it into implementation and fix workers via `skill: workflow.implementationSkill`; prose instructions like “use TDD” are insufficient.
- Implementation and fix workers must fail closed: if the expected implementation skill was not injected at runtime, they stop before editing source files.
- `review.reviewerSkill` must be `review` for this workflow unless the user explicitly disables review entirely; the orchestrator injects `/skill:review` only into the acceptance reviewer/committer via `skill: review.reviewerSkill`.
- Add enough `review.comparisonSources` and `review.mustRejectIf` entries for the reviewer to compare the diff against explicit issue, manifest, scope, and test criteria instead of doing a vague general review.

## Default policies

```yaml
workflow:
  # Required. Default implementation skill injected into implementation and fix workers as `skill: tdd`.
  # Change only on explicit user override.
  implementationSkill: tdd
  oneIssuePerCommit: true
  sequentialOnly: true
  requireCleanWorktree: true
  allowParallelImplementation: false
review:
  beforeCommit: true
  acceptanceReviewerCommits: true
  reviewerCanEditSource: false
  # Injected into the acceptance reviewer/committer as `skill: review`.
  reviewerSkill: review
  comparisonSources:
    - githubIssueAcceptanceCriteria
    - githubIssueBodyAndComments
    - manifestScopeAndNonGoals
    - manifestFutureIssues
    - currentUncommittedDiff
    - testsAndCommandOutput
  mustRejectIf:
    - missingOrUnmetAcceptanceCriterion
    - scopeCreepOrFutureIssueWork
    - failingOrInsufficientTests
    - reviewerWouldNeedToEditSource
    - impureIssueCommit
remote:
  pushAfterCommit: true
  commentOnIssue: true
```

## Review with user

After writing the manifest, summarize:
- manifest path
- issue sequence
- references count
- review/commit/push policy
- stop conditions

Ask whether to run the orchestrator with that manifest.

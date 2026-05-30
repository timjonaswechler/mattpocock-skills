# Issue Series Manifest Schema

Recommended path: `.pi/issue-series/<series-name>.yaml`

```yaml
version: 1
name: short-series-name

repo:
  github: owner/repo
  cwd: /absolute/path/to/repo

issues:
  sequence: [101, 102, 103]
  alreadyDone: []
  blockedBy: {}
  # Example:
  # blockedBy:
  #   103: [102]

references:
  githubIssues: []
  githubPRs: []
  files: []
  urls: []

scope:
  summary: "Short description of the series goal"
  nonGoals: []
  futureIssues: []

workflow:
  # Required runtime Pi skill for source-editing workers.
  # Default: tdd. Change only on explicit user override.
  # Injected into implementation and fix workers as `skill: workflow.implementationSkill`.
  implementationSkill: tdd
  oneIssuePerCommit: true
  sequentialOnly: true
  requireCleanWorktree: true
  allowParallelImplementation: false
  planGate: false

review:
  beforeCommit: true
  acceptanceReviewerCommits: true
  reviewerCanEditSource: false
  # Required runtime Pi skill injected into the acceptance reviewer/committer as `skill: review`.
  reviewerSkill: review
  mode: single-neutral
  fixedPoint: issueStartHead
  maxFixReviewCycles: 2
  comparisonSources:
    - githubIssueAcceptanceCriteria
    - githubIssueBodyAndComments
    - githubIssueLinksLabelsAndBlockers
    - manifestScopeAndNonGoals
    - manifestFutureIssues
    - manifestReferences
    - workerReportAsClaimsOnly
    - currentUncommittedDiff
    - testsAndCommandOutput
  mustRejectIf:
    - acceptanceCriteriaMissingOrAmbiguous
    - missingOrUnmetAcceptanceCriterion
    - scopeCreepOrFutureIssueWork
    - failingOrInsufficientTests
    - reviewerWouldNeedToEditSource
    - impureIssueCommit
    - productArchitectureOrApiDecisionNeeded
  blockOn:
    - acceptanceCriteriaMissing
    - scopeCreep
    - failingOrInsufficientTests
    - regressionRisk
    - impureIssueCommit

remote:
  pushAfterCommit: true
  commentOnIssue: true
  commentTemplate: default

commit:
  conventionalCommit: true
  includeIssueNumber: true
  requireScopeCheck: true

stopIf:
  - dirtyWorktree
  - issueBlocked
  - testsFailAfterFixAttempt
  - scopeUnclear
  - architectureDecisionNeeded
  - acceptanceReviewBlocked

report:
  finalTable: true
  includeTests: true
  includeRisks: true
```

## Field notes

- `issues.sequence` is the only execution order the orchestrator should follow.
- `references` are instructions for workers/reviewers to read source material themselves; keep them as pointers.
- `workflow.implementationSkill` is required. Default is `tdd`; use another skill only when the user explicitly overrides the default.
- It is passed to implementation workers and fix workers as the subagent runtime `skill: workflow.implementationSkill`; it is not prose guidance.
- Implementation and fix workers must stop before source edits if the expected skill was not actually injected. With the default manifest, that means `/skill:tdd` must be loaded in those workers.
- `review.reviewerSkill` must be `review` for this workflow and is passed only to the acceptance reviewer/committer as `skill: review.reviewerSkill`; it is not used for implementation or fix workers.
- `review.fixedPoint: issueStartHead` means the orchestrator records `git rev-parse HEAD` before starting each issue and passes that SHA to `/skill:review` as the fixed point while also instructing the reviewer to inspect the current uncommitted diff.
- `review.comparisonSources` names the explicit sources the `/skill:review` reviewer must compare against; keep these as criteria pointers, not copied issue prose.
- `review.mustRejectIf` names blocking acceptance failures the reviewer must enforce before committing.
- `review.acceptanceReviewerCommits: true` means the neutral reviewer is also the commit/push/comment agent when review passes.
- `review.reviewerCanEditSource: false` means the reviewer may run git/gh commands for commit/comment, but must not edit project source files.
- `workflow.planGate: false` means the implementation worker prepares internally and then implements directly unless blocked.
- `maxFixReviewCycles` caps repeated fix-worker → acceptance-review loops per issue.

# Issue Series Manifest Examples

## Runtime issue chain

```yaml
version: 1
name: runtime-core-56-59

repo:
  github: timjonaswechler/TradingBot
  cwd: /Users/tim-jonaswechler/GitHub-Projekte/TradingBot2

issues:
  sequence: [56, 57, 58, 59]
  alreadyDone: [53, 54, 55]

references:
  githubIssues: [31, 34, 41, 43, 52]
  githubPRs: [51]
  files:
    - CONTEXT.md
    - docs/refactor/trading-runtime-refactor-plan.md
    - docs/adr/0002-build-trading-runtime-as-new-crate.md
    - docs/adr/0003-runtime-managed-risk-exits-are-opt-in-hard-exits.md

scope:
  summary: Market State / Market View runtime-core implementation chain.
  nonGoals:
    - Do not start future issues outside the sequence.
  futureIssues: [60, 61, 62, 63, 64, 65]

workflow:
  # Required/default implementation skill. Injected into implementation and fix workers as `skill: tdd`.
  # Change only when the user explicitly overrides the TDD default.
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
  # Injected into the acceptance reviewer/committer as `skill: review`.
  reviewerSkill: review
  mode: single-neutral
  fixedPoint: issueStartHead
  maxFixReviewCycles: 2
  comparisonSources:
    - githubIssueAcceptanceCriteria
    - githubIssueBodyAndComments
    - manifestScopeAndNonGoals
    - manifestFutureIssues
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

remote:
  pushAfterCommit: true
  commentOnIssue: true

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
```

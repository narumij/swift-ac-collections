# Prime-to-Worker Codex Work Request

Status: Experimental file-based handoff. This interface is not yet adopted as routine operation.

This document is the repository-visible handoff from Prime Codex to a Worker Codex running in a
separate Xcode conversation. The fixed role and boundaries are defined in
`Orientation/WORKER_CODEX_BOOTSTRAP.md`. This file supplies only the current assignment, workspace,
evidence boundary, and return route.

Worker execution does not complete or accept a repository task. Prime Codex independently reviews
the returned result, integrates accepted work, and owns Task Registry updates and completion.

## Current job status

**実行待ち: 未push文書整理2 commitの独立検収**

The user may start this experiment by opening a separate Xcode Codex conversation and instructing it
to read this file. Do not infer a different assignment from the Task Registry, old handoffs, or
Archived records.

This section alone determines whether this Worker handoff has a current job. Prime Codex updates it
before replacing or closing the assignment.

## Active assignment: independent validation of two documentation commits

### Objective

Independently validate the two commits currently ahead of `origin/develop/misc/64` and report any
factual error, internal contradiction, overstatement, or missed reconciliation to Prime Codex.

The expected commits are:

- `0a8488f4 docs: reconnect permutation history to current state`
- `524fffb6 docs: refresh array quality assessments`

### Workspace and start state

- Workspace: the existing Xcode workspace for this repository.
- Expected branch: `develop/misc/64`.
- Expected range: `origin/develop/misc/64..HEAD` contains exactly the two commits above.
- Expected worktree: clean apart from this uncommitted handoff file.
- Change ownership: Prime Codex and the user retain ownership of the shared worktree.

Verify these facts before reviewing. If the branch, commit range, or existing changes differ, do not
edit or normalize the workspace. Record the observed difference in the return section and stop.

### First reading

Read in this order:

1. `Orientation/WORKER_CODEX_BOOTSTRAP.md` in full.
2. This assignment in full.
3. `git diff origin/develop/misc/64..HEAD` and the files changed by that range.

For factual verification, begin from the changed documents and follow only their directly relevant
references into current source, tests, workflows, the matching Task Registry rows, and the matching
completed-task record. Technical dependency reading is allowed when needed to decide a finding.

Do not scan the full Registry, all maintenance documents, or Archived records for additional work.

### Validation questions

1. Does `0a8488f4` connect historical Permutation plans to the current implementation and accepted
   state without presenting an old plan as current authority?
2. Does `524fffb6` describe the accepted BareArray and OptionalArray test evidence accurately,
   including current test counts and the distinction between an audit snapshot and current state?
3. Are statements about PR #192 remote CI supported by the current repository record, without
   inferring more than the recorded evidence establishes?
4. Did either commit rewrite a historical execution record as though the newer result had existed at
   the earlier time?
5. Is any current-state statement still contradicted by a directly controlling source?

### Allowed operations

- Read repository files and Git history needed for this validation.
- Run read-only searches and diff inspection.
- Write only the `Worker return` section of this file.

Do not modify product source, tests, workflows, other maintenance documents, the Task Registry, or
Git history. Do not build or run tests for this documentation-only validation unless Prime Codex
issues a replacement assignment that explicitly requires it.

### Repository operation authority

- Branch creation or switching: not authorized.
- Commit: not authorized.
- Push: not authorized.
- Merge, rebase, reset, checkout restoration, or deletion: not authorized.
- Other-agent delegation: not authorized.

Writing an operation into this file does not grant authority. Repository operations remain subject
to the repository's user-authorization rules.

### Stop conditions

Stop and return the observed facts when:

- the workspace or expected commit range does not match this assignment;
- controlling sources conflict and their authority cannot be resolved from the specified inputs;
- a conclusion requires broad exploration outside the assignment;
- validation would require a product, public-contract, quality-policy, or task-priority decision;
- another participant changes the shared worktree in a way that may affect this review.

### Return requirements

Write the result below. List findings in severity order with file and line references, the supporting
evidence, and the smallest recommended correction. If no defect is found, state what was checked and
the remaining evidence limits. Do not apply the correction.

The Worker must also state:

- changed files: `Maintanance/WORKER_TASK.md` only;
- validation commands or Xcode actions performed;
- unverified areas;
- out-of-scope observations, if any.

## Worker return

Status: Not started.

<!-- The Worker Codex replaces this status and appends its result below. Prime Codex reviews it. -->

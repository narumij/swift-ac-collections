# Prime-to-Worker Codex Work Request

Status: Experimental file-based handoff. This interface is not yet adopted as routine operation.

The fixed role and boundaries are defined in `Orientation/WORKER_CODEX_BOOTSTRAP.md`. Worker
execution does not accept or complete the repository task. Prime Codex independently reviews the
return and owns every correction, Registry update, and completion decision.

## Current job status

**受入完了: OptionalArray利用者向け本文の独立読者レビュー**

The user may start this assignment by opening the existing Worker Xcode conversation and saying
`やって`. The Worker must reread this file and execute only the assignment below.

Prime acceptance (2026-10-13): Workerの唯一の`MUST-FIX`をsourceと品質正本へ照合し、
条件付き適合を`Sendable`ではなく`@unchecked Sendable`と明記する必要があると受け入れた。
本文を最小修正し、その他のAPI・座標・所有・寿命・性能・提供境界の独立レビューを受け入れた。

## Active assignment: OptionalArray user-document draft review

### Objective

Read the new OptionalArray user-document draft as an independent first-time reader and compare its
claims with the current public source and the two current quality records. Find factual
disagreements, promises stronger than the evidence, missing constraints that would materially
mislead a user, and explanations or examples likely to create the wrong usage model.

This is a read-only review. Do not rewrite the draft and do not decide its public medium or product
policy.

### Workspace and start state

- Workspace: the existing Xcode workspace for this repository.
- Expected branch: `develop/misc/64`.
- Expected HEAD: `3b343caa` (`Record Claude management evaluation for 2026-10-13`).
- Expected worktree changes before Worker starts:
  - `Maintanance/OptionalArrayModule/UserDocumentationDraft.md` added;
  - `Maintanance/OptionalArrayModule/CurrentQualityAssessment.md` modified;
  - `Maintanance/PROGRESS_OVERVIEW.md` modified;
  - this assignment in `Maintanance/WORKER_TASK.md` modified.
- The commit after the original assignment changes only `Maintanance/CLAUDE_OBSERVATIONS.md` and
  `Maintanance/USER_MANAGEMENT_INTERVIEW_CLAUDE.md`. Prime verified that neither is a review input;
  `3b343caa` is therefore the reauthorized start point.
- Prime Codex and the user retain ownership of the shared worktree.

Verify branch, HEAD, and worktree before reviewing. If another difference exists, record it in the
return section and stop. Commits ahead of the remote are not a stop condition.

### Required reading

Read only these files, in this order:

1. `Orientation/WORKER_CODEX_BOOTSTRAP.md` in full.
2. This assignment in full.
3. `OptionalArrayModule/UserDocumentationDraft.md`.
4. `Sources/OptionalArrayModule/OptionalElementBuffer.swift`.
5. `Sources/OptionalArrayModule/Documentation/Quality-Profile.md`.
6. `OptionalArrayModule/CurrentQualityAssessment.md`.
7. Only the `OPT-059` row in `PROGRESS_OVERVIEW.md`.

Do not scan the repository, Archived records, tests, benchmarks, or Git history. If the listed
sources cannot resolve a claim, classify it as needing evidence rather than widening the search.

### Review questions

Evaluate the draft against these questions:

1. Does every API spelling, signature, coordinate order, ownership statement, complexity statement,
   and availability path agree with the current public source?
2. Does the draft distinguish verified behavior, implementation-derived complexity, and unverified
   Validation or performance claims at least as carefully as the quality records?
3. Could a first-time user mistakenly infer Collection conformance, retained Views, implicit copy,
   thread-safe shared mutation, or guaranteed competitive-programming performance?
4. Do examples teach only current APIs and valid lifetimes?
5. Is a constraint omitted whose absence would materially change correct use?
6. Is any passage technically correct but unnecessarily hard to understand or likely to produce a
   wrong mental model?

Do not treat writing preference alone as a defect. Preserve uncertainty where the source and
quality records do not answer a question.

### Finding classes

Classify each finding as exactly one of:

- `MUST-FIX`: factual error, stale API, unsupported guarantee, unsafe omission, or example that
  teaches invalid use;
- `SHOULD-FIX`: materially confusing wording or structure that is likely to mislead a normal reader;
- `OPTIONAL`: a useful improvement whose absence does not make the draft incorrect or misleading;
- `QUESTION`: the allowed evidence cannot resolve the point or a product decision is required.

For every `MUST-FIX`, `SHOULD-FIX`, or `QUESTION`, give the draft line or heading, the exact claim,
the conflicting or missing evidence, and the smallest correction direction. Do not write replacement
prose. Summarize `OPTIONAL` findings briefly and keep them separate from acceptance blockers.

### Allowed changes

- Only the `Worker return` section of this file.

No source, test, quality record, draft, Registry, or other file may be changed by Worker.

### Validation boundary

No build or test is authorized. This review checks the draft against already recorded source and
quality evidence. Passing prior tests does not establish prose correctness, and textual agreement
does not establish product quality.

### Repository operation authority

- Branch creation or switching: not authorized.
- Commit, push, merge, rebase, reset, restoration, or deletion: not authorized.
- Other-agent delegation: not authorized.

### Stop conditions

Stop and return observed facts if the branch, HEAD, or initial worktree differs beyond the expected
files; another participant changes a review input while it is being read; the review requires broad
repository or Archived exploration; or resolving a finding requires a new product decision.

### Return requirements

Write the result below. Include the start state, checked files, findings grouped by class, an explicit
acceptance recommendation (`accept`, `accept after MUST-FIX`, or `revise and review again`),
limitations, and the exact files changed by Worker. Do not update the Task Registry or accept the
draft.

## Worker return

Status: review completed; awaiting Prime review.

### Start state

- Branch: `develop/misc/64`.
- HEAD: `3b343caa` (`Record Claude management evaluation for 2026-10-13`).
- Observed worktree changes matched the expected set:
  - `Maintanance/OptionalArrayModule/UserDocumentationDraft.md` added;
  - `Maintanance/OptionalArrayModule/CurrentQualityAssessment.md` modified;
  - `Maintanance/PROGRESS_OVERVIEW.md` modified;
  - `Maintanance/WORKER_TASK.md` modified.

### Checked files

- `Maintanance/Orientation/WORKER_CODEX_BOOTSTRAP.md`
- `Maintanance/WORKER_TASK.md`
- `Maintanance/OptionalArrayModule/UserDocumentationDraft.md`
- `Sources/OptionalArrayModule/OptionalElementBuffer.swift`
- `Sources/OptionalArrayModule/Documentation/Quality-Profile.md`
- `Maintanance/OptionalArrayModule/CurrentQualityAssessment.md`
- The `OPT-059` task row in `Maintanance/PROGRESS_OVERVIEW.md`

### Findings

#### MUST-FIX

1. Draft lines 69–70, heading `所有権と要素寿命`.
   - Exact claim: ``Element: Sendable`のとき所有型も`Sendable`である。` The following
     caveat says this does not permit unsynchronized concurrent access and that the semantic guarantee
     for concurrent use is unverified.
   - Conflicting or missing evidence: all four source conformances are explicitly
     `@unchecked Sendable`, for example source line 104 for 1D and lines 222, 340, and 464 for 2D–4D.
     Quality Profile lines 111 and 125 require the `@unchecked Sendable` boundary to remain visible.
     Current Quality Assessment line 48 classifies the conformance's transfer/sharing scope as
     unverified. Omitting `@unchecked` can lead a reader to infer compiler-checked Sendable safety;
     the later concurrency caveat does not identify that the conformance itself is unchecked.
   - Smallest correction direction: identify the conditional conformance as `@unchecked Sendable`
     before the existing caveat, without adding any new concurrency guarantee.

#### SHOULD-FIX

None.

#### OPTIONAL

None. No writing-preference-only changes are needed for acceptance.

#### QUESTION

None.

### Acceptance recommendation

`accept after MUST-FIX`

The API spellings, signatures shown or described, coordinate order, outer-axis `indices`, ownership
model, element-lifetime statements, preconditions, zero-dimension behavior, complexity boundaries,
availability paths, examples, Collection exclusion, removed-View boundary, and competitive-programming
evidence limits otherwise agree with the allowed source and quality records.

### Limitations

- This was a textual review against only the assignment's allowed inputs.
- Tests, benchmarks, package configuration, facade source, Archived records, and Git history were not
  inspected. Their claims were assessed only through the two allowed current quality records.
- No build or test was run, as required by the validation boundary.
- The review does not decide public medium, naming policy, concurrency policy, performance acceptance,
  or task acceptance.

### Files changed by Worker

- `Maintanance/WORKER_TASK.md` — only this `Worker return` section.

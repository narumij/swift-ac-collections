# Prime-to-Worker Codex Work Request — BareArray review history

Status: Experimental file-based handoff. This interface is not yet adopted as routine operation.

The fixed role and boundaries are defined in `Maintanance/Archived/Worker/WORKER_CODEX_BOOTSTRAP.md`. Worker
execution does not accept or complete the repository task. Prime Codex independently reviews the
return and owns every correction, Registry update, and completion decision.

## Current job status

**受入完了: BareArray利用者向け本文の独立読者レビュー**

The user may start this assignment by opening the existing Worker Xcode conversation and saying
`やって`. The Worker must reread this file and execute only the assignment below.

Prime acceptance (2026-10-13): Workerの唯一の`MUST-FIX`をsourceと品質正本へ照合し、
`reference(at:)`のSwift 6.4とApple OS 27以降という両境界を明記する必要があると受け入れた。
本文を最小修正し、同時にWorkerが見つけた脱字を修正。その他のAPI・座標・初期化・所有・
借用寿命・性能・提供境界の独立レビューを受け入れた。

## Active assignment: BareArray user-document draft review

### Objective

Read the new BareArray user-document draft as an independent first-time reader and compare its
claims with the current public source and the two current quality records. Find factual
disagreements, promises stronger than the evidence, missing constraints that would materially
mislead a user, and explanations or examples likely to create the wrong usage model.

Pay particular attention to the distinction between value access and the standard-library
`MutableRef`, the availability of `reference(at:)`, owner-dependent lifetime, exclusive mutable
borrowing, and whether the example teaches compilable valid use.

This is a read-only review. Do not rewrite the draft and do not decide its public medium,
performance acceptance, or compatibility policy.

### Workspace and start state

- Workspace: the existing Xcode workspace for this repository.
- Expected branch: `develop/misc/64`.
- Expected HEAD: `9d264e0b` (`Draft OptionalArray user documentation`).
- Expected worktree changes before Worker starts:
  - `Maintanance/ElementBufferModule/UserDocumentationDraft.md` added;
  - `Maintanance/PROGRESS_OVERVIEW.md` modified;
  - this assignment in `Maintanance/WORKER_TASK.md` modified.
- Prime Codex and the user retain ownership of the shared worktree.

Verify branch, HEAD, and worktree before reviewing. If another difference exists, record it in the
return section and stop. Commits ahead of the remote are not a stop condition.

### Required reading

Read only these files, in this order:

1. `Maintanance/Archived/Worker/WORKER_CODEX_BOOTSTRAP.md` in full.
2. This assignment in full.
3. `ElementBufferModule/UserDocumentationDraft.md`.
4. `Sources/BareArrayModule/ElementBuffer.swift`.
5. `Sources/BareArrayModule/Documentation/Quality-Profile.md`.
6. `ElementBufferModule/CurrentQualityAssessment.md`.
7. Only the `BARE-040` row in `PROGRESS_OVERVIEW.md`.

Do not scan the repository, Archived records, tests, benchmarks, Apple documentation, or Git
history. If the listed sources cannot resolve a claim, classify it as needing evidence rather than
widening the search.

### Review questions

Evaluate the draft against these questions:

1. Does every API spelling, signature, coordinate order, initializer behavior, ownership statement,
   complexity statement, and availability claim agree with the current public source?
2. Is the distinction between `element` / `setElement` and `reference(at:)` technically accurate and
   useful without inventing a performance guarantee?
3. Does the `MutableRef` example respect the mutable owner's lifetime and exclusivity, and does it
   use the standard `value` property?
4. Does the draft distinguish verified behavior, implementation-derived complexity, and unverified
   Validation or external-performance claims at least as carefully as the quality records?
5. Could a first-time user mistakenly infer Collection conformance, implicit copy, retained Views,
   unrestricted availability, thread-safe shared mutation, or guaranteed C/C++-level performance?
6. Is a constraint omitted whose absence would materially change correct use?
7. Is any passage technically correct but likely to produce a wrong mental model?

Do not treat writing preference alone as a defect. Preserve uncertainty where the source and
quality records do not answer a question.

### Finding classes

Classify each finding as exactly one of:

- `MUST-FIX`: factual error, stale API, unsupported guarantee, unsafe omission, or example that
  teaches invalid use;
- `SHOULD-FIX`: materially confusing wording or structure likely to mislead a normal reader;
- `OPTIONAL`: a useful improvement whose absence does not make the draft incorrect or misleading;
- `QUESTION`: the allowed evidence cannot resolve the point or a product decision is required.

For every `MUST-FIX`, `SHOULD-FIX`, or `QUESTION`, give the draft line or heading, the exact claim,
the conflicting or missing evidence, and the smallest correction direction. Do not write replacement
prose. Summarize `OPTIONAL` findings briefly and keep them separate from acceptance blockers.

### Allowed changes

- Only the `Worker return` section of this file.

No source, test, quality record, draft, Registry, or other file may be changed by Worker.

### Validation boundary

No build, test, snippet execution, or documentation search is authorized. This review checks the
draft against already recorded source and quality evidence. If the example's compilability cannot be
established from those inputs, report that limitation instead of executing it.

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
- HEAD: `9d264e0b` (`Draft OptionalArray user documentation`).
- Observed worktree changes matched the expected set:
  - `Maintanance/ElementBufferModule/UserDocumentationDraft.md` added;
  - `Maintanance/PROGRESS_OVERVIEW.md` modified;
  - `Maintanance/WORKER_TASK.md` modified.

### Checked files

- `Maintanance/Archived/Worker/WORKER_CODEX_BOOTSTRAP.md`
- `Maintanance/WORKER_TASK.md`
- `Maintanance/ElementBufferModule/UserDocumentationDraft.md`
- `Sources/BareArrayModule/ElementBuffer.swift`
- `Sources/BareArrayModule/Documentation/Quality-Profile.md`
- `Maintanance/ElementBufferModule/CurrentQualityAssessment.md`
- The `BARE-040` task row in `Maintanance/PROGRESS_OVERVIEW.md`

### Findings

#### MUST-FIX

1. Draft lines 71 and 90, heading ``MutableRef`による借用参照`.
   - Exact claim: line 71 identifies Apple OS 27 or later, while line 90 says only generally that
     `reference(at:)` is available where the standard-library type's conditions are met and that no
     compatibility type is supplied for older OSes or toolchains.
   - Conflicting or missing evidence: source lines 429, 452, 478, and 507 apply
     `@available(anyAppleOS 27.0, *)` to the four overloads. Quality Profile line 22 and Current Quality
     Assessment lines 14–15 and 23–30 identify the borrowed-reference API as Swift 6.4 and Apple OS 27
     dependent. The draft never states the Swift 6.4 threshold, so a reader can reasonably infer that
     satisfying only the Apple OS condition is enough to compile this API.
   - Smallest correction direction: state the Swift 6.4 toolchain requirement explicitly alongside
     the Apple OS 27 availability, while preserving the existing statement that no compatibility type
     is provided. Do not broaden the platform promise beyond the recorded evidence.

#### SHOULD-FIX

None.

#### OPTIONAL

- Draft line 13 contains the apparent typo `最後まbuffer`. Correcting it would improve polish but is
  not needed to repair a technical claim or usage model.

#### QUESTION

None.

### Acceptance recommendation

`accept after MUST-FIX`

Apart from the missing explicit toolchain threshold, the draft agrees with the allowed evidence on
API spellings and signatures, initializer behavior, coordinate order, value access, standard-library
`MutableRef.value`, owner-dependent lifetime, exclusive mutable borrowing, example scope, ownership,
element lifetime, preconditions, zero dimensions, complexity boundaries, package paths, Collection
exclusion, removed Views, and the limits of performance and competitive-programming evidence.

### Limitations

- This was a textual review against only the assignment's allowed inputs.
- The example was not compiled. Its API use and lexical owner/reference ordering agree with the source
  and with the compile-pass and owner-escape evidence recorded in Current Quality Assessment.
- Tests, compiler fixtures, benchmarks, package configuration, facade source, Apple documentation,
  Archived records, and Git history were not inspected.
- No build, test, snippet execution, or documentation search was run, as required by the validation
  boundary.
- The review does not decide public medium, performance acceptance, compatibility policy, naming, or
  task acceptance.

### Files changed by Worker

- `Maintanance/WORKER_TASK.md` — only this `Worker return` section.

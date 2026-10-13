# Codex-to-Claude Work Request

Status: Bounded assignments only. Temporary primary-user-support delegation ended 2026-10-08 by user direction.

Task selection and start authority are defined in the root `CLAUDE.md`. This document records the
current job and bounded-task execution constraints. Codex integrates the results, performs Registry
acceptance and state updates, and owns public-document completion.
Repository evidence establishes factual correctness; product decisions remain with the user.

## Current job status

**実行中: PERM-056 runtime-check Permutation公開表面・共存仕様test**

Codex accepted PERM-055 and independently confirmed the accumulated 40 selected tests in Xcode.
Claude is now assigned only G0 and G5 from `PermutationModule/RuntimeCheckedPermutationTestPlan.md`.
Do not start any other Registry task.

**凍結中: PERM-051 borrowed Span版PermutationのTest as Specification**

- runtime仕様test 25件はCodexが受け入れ、Xcode build-for-testingと対象25件成功を確認した。
- 借用寿命のcompiler診断証拠が未完了のため、task全体は完了扱いにしない。
- ユーザーが明示的に再開するまで着手しない。

この節だけでジョブの有無を判断する。Archived recordsを現行ジョブとして読み替えない。状態が変わった
ときは、assignment本文より先にこの節を更新する。

## Active assignment: PERM-056 public surface, coexistence, and reexport tests

### Objective

Implement the accepted G0 public-surface and G5 coexistence／exposure requirements for the current
runtime-checked `NextPermutations` implementation.

### Inputs

Read only:

- the `PERM-056` Registry row;
- `Maintanance/PermutationModule/RuntimeCheckedPermutationTestPlan.md`;
- `Sources/PermutationModule/NextPermutations.swift` and `GateKeeper.swift`;
- legacy `_0_PublicSurfaceTests.swift` and `_4_CoexistenceTests.swift` under
  `Tests/PermutationTests/NextPermutationsSequence/` only for G0／G5 inputs;
- accepted borrowed coexistence tests only as a test-technique reference, not as the runtime-check
  contract;
- the current package targets and any existing repository-local compiler-surface fixture mechanism
  needed to test negative compile requirements;
- the task-relevant instructions in `Tests/CLAUDE.md` and sections of `Tests/TESTING.md`.

Use the G0／G5 boundaries in the plan. Do not revive retired `Sendable`、value-semantics、COW、
`Equatable`、`Hashable` or presentation guarantees.

### Required implementation

- Add numbered G0 and G5 tests under `Tests/PermutationTests/NextPermutations/`.
- Fix the current public owner and nested View type names and construction through
  `Collection.nextPermutations()` for Array、Range、nonzero-start Slice and non-`Int` indexed input.
- Verify with compiler-backed evidence that direct public initialization remains unavailable, the
  owner is noncopyable, and it does not conform to `Sequence`. Preserve the repository's existing
  fixture style if one exists; do not treat commented-out source as evidence.
- Verify that importing `PermutationModule` and `Algorithms` together is unambiguous and that
  `nextPermutations()` yields only the current order and its lexicographic successors while
  `permutations()` yields every positional ordering.
- Verify that importing `AcCollections` exposes the intended runtime-check entry point without a
  direct `PermutationModule` import.
- Keep AtCoder 2025 compatibility mode outside this evidence path; it has a separate API and tests.

### Boundaries

- Do not modify production source, Quality Profile, Current Quality Assessment, Package.swift, CI,
  Registry, public documentation, or disabled legacy test files.
- Do not change G1、G2、G3、G4.
- Do not decide new public API, `Sendable`, `Equatable`, `Hashable`, description, availability,
  compatibility, or lifetime policy.
- Do not revive COW, persistent-result, iterator-copy, `Sequence`, or borrowed-`Span` requirements.
- If the repository has no durable negative compiler-fixture mechanism, report the exact unmet G0
  checks and stop instead of inventing a claim from runtime reflection or comments.
- If a listed requirement cannot be implemented from the accepted contract, report that exact item
  and stop rather than deciding a new contract.

### Validation and return

- Run the new runtime tests and the already-accepted numbered runtime-check tests in Debug and
  Release. Run compiler fixtures through their actual repository execution path and record both
  expected-success and expected-failure outcomes.
- Report exact files changed, test counts, commands or Xcode actions, and results in
  `Maintanance/PermutationModule/RuntimeCheckedPermutationTestPlan.md` under a `PERM-056 return`
  section.
- Do not mark `PERM-056` complete and do not update Registry. Codex performs acceptance.

## Operating mode: bounded assignments only

Apply the task-selection and start-authority rule in the root `CLAUDE.md`. Codex integrates the
result, performs Registry acceptance and state changes, and owns public-document completion. These
coordination responsibilities do not make Codex's agreement evidence of factual correctness.

The rules below remain as bounded-task execution constraints. They do not grant authority to restart
frozen work or act on behalf of Codex.

Verify the current branch from the repository before editing; do not preserve a branch name here as
current state.

### Communication

- Respond directly when the user selects a Claude task. Codex is the active integrator; durable
  evidence belongs in the selected task's canonical document.
- Default to low-information reports. Give the outcome, any actual problem, and the next user
  decision or action only. Do not proactively explain background, commands, evidence, or every
  consideration; the user will ask when more detail is wanted.
- `完了` alone is preferred for a routine task whose requested outcome and validation are
  unambiguous. Expand without being asked only for a blocker, safety/correctness problem, failed
  validation, irreversible action, or a decision that only the user can make.
- A formal evaluation of the user, or a requested impression record, is a frozen Registry task and
  runs only when the user explicitly asks to record it. Merely discussing an evaluation or impression
  is not a request to append it. Write formal evaluations to `USER_MANAGEMENT_INTERVIEW_CLAUDE.md`
  and requested impressions to `CLAUDE_OBSERVATIONS.md`.
- Claude may still append its own optional, spontaneous observation to `CLAUDE_OBSERVATIONS.md` when
  genuinely useful. Do not manufacture an entry or delay the main task for it.
- If prior intent is unclear, ask the user rather than attributing an unstated decision to Codex.

### Authority

For an explicit user request, you may inspect, edit, build, test, benchmark, and update relevant
documentation within the repository. Use the smallest task boundary that satisfies the request.

The following still require explicit user direction:

- choosing or changing public API, compatibility policy, product positioning, or completion scope;
- restarting any item marked frozen, deferred, optional, or waiting for a user decision;
- changing the Index contract, `Comparable`, facade re-export policy, Permutation compatibility
  mode, or the unsafe-storage/concurrency items currently on hold;
- deleting material code or records;
- commit, push, merge, PR close/reopen, branch creation/deletion/switching, or history rewriting;
- publishing private performance-tuning knowledge.

Codex is the primary owner for public documentation. When public-document work is delegated to
Claude, keep it to explicitly named sections, factual verification, independent review, or a bounded
correction. Do not expand a Compatibility-document request into a four-document audit or rewrite.

When the user explicitly requests a commit, first verify the branch and complete diff. When it is
a good commit boundary, say `コミットおすすめです`. Never infer push permission from commit
permission.

### Performance-sensitive boundaries

- Non-`public` protocol declarations use `@usableFromInline` uniformly.
- Do not add, remove, or move `@inlinable`, and do not convert an existing `@usableFromInline` to
  `@inlinable`, without direct user review.
- Do not change a boundary that deliberately removes generic type variables, including the
  `RawBuffer` / `BufferHeader` family, without direct user review.
- Compile and functional tests do not prove performance neutrality. A performance-sensitive
  access or generic/protocol change is not complete until the relevant performance job is green.
- Keep the general tuning rationale private. Public incident records may describe reproduction and
  bisection, but follow the user's chosen level of detail for the mechanism.

### Task execution

- Establish current state from the Task Registry at the top of `Maintanance/PROGRESS_OVERVIEW.md`.
  After selecting a task, read only the detailed canonical document linked from that row. Do not
  scan all maintenance or Archived documents at session start.
- Read only the task-specific portions of maintenance documents needed for the current request.
  Do not turn backlog discovery into authorization to implement it.
- Preserve unrelated worktree changes. Never reset or discard user work to make a task clean.
- For broad inventories, repetitive cross-checks, or a high-risk conclusion, use an independent
  evidence-oriented second pass where available; otherwise tell the user what could not be
  independently reviewed. Agreement between agents is not evidence by itself.
- For performance work, fix the environment and baseline, reproduce first, and distinguish CI
  history from new local measurements.
- For cross-branch work, identify symbols by branch, path, configuration, and meaning. Verify the
  current branch before editing and again before committing.
- Update the relevant canonical record for durable decisions. Do not expose a private note merely
  to improve agent continuity.
- When actual use reveals a possible improvement to the conversation reference ID rule, Claude may
  append a concrete proposed diff to `Maintanance/CONVERSATION_REFERENCE_IDS.md` under
  `運用中の改訂候補` without waiting for a separate assignment. A proposal does not change the
  active rule; integrate it into the adopted text only after the user approves it or explicitly
  asks Claude to apply it.

### Bounded-task reporting

For a bounded assignment, record durable evidence in the selected task's canonical document and
report the outcome directly to the user. Do not maintain a general repository handoff or independently
curate the overall backlog. Registry acceptance and state changes remain Codex-owned.

If a task reveals a defect or decision point outside its boundary, report and stop. Do not turn the
finding into implementation authority.

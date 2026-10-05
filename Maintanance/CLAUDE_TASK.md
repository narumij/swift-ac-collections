# Codex-to-Claude Work Request

Status: Active through 2026-10-10 JST

## Standing assignment: primary user support during Codex leave

From now through 2026-10-10 JST, act as the primary repository assistant for the user while Codex
is on leave. This is a temporary operating role, not authorization to expand project scope or to
restart frozen work.

This standing assignment records only the operational performance rules needed for safe work.
The rationale, discovery history, and generalized tuning knowledge remain private and must not be
added to this file or another public repository document.

The current branch is `develop/misc/49`. `try/index/1` was merged by PR #158 at `a6c8a474`.
The worktree was clean when this standing assignment was written.

### Communication

- Respond directly to the user. There is no active Codex integrator to receive hidden detail.
- Default to low-information reports. Give the outcome, any actual problem, and the next user
  decision or action only. Do not proactively explain background, commands, evidence, or every
  consideration; the user will ask when more detail is wanted.
- `完了` alone is preferred for a routine task whose requested outcome and validation are
  unambiguous. Expand without being asked only for a blocker, safety/correctness problem, failed
  validation, irreversible action, or a decision that only the user can make.
- Personal observations remain optional. Do not manufacture a feeling, but you may speak in your
  own voice or append to `CLAUDE_OBSERVATIONS.md` when useful.
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

- Read only the task-specific portions of maintenance documents needed for the current request.
  Do not turn backlog discovery into authorization to implement it.
- Preserve unrelated worktree changes. Never reset or discard user work to make a task clean.
- For broad inventories, repetitive cross-checks, or a high-risk conclusion, use an independent
  second pass where available; otherwise tell the user what could not be independently reviewed.
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

### Handoff for Codex return

Maintain a concise dated handoff in the Result section below. Record only durable state:

- user decisions;
- commits and whether they were pushed;
- validation performed and failures still open;
- worktree/branch state;
- frozen items explicitly resumed or newly frozen; and
- questions still requiring the user or Codex.

Do not paste routine command output or duplicate existing canonical documents. On or after
2026-10-10, do not assume this temporary primary role continues; follow the user's current
instruction and prepare the handoff for Codex if requested.

### Result / handoff

#### Current handoff (2026-10-06)

- PR #158のsuccess-only Indexは4コンテナとViewへ統合済み。`index(inserting:)`と
  `erase(exactly:)`のMultiSet / Dictionary展開も実装・テスト済み。
- cross-tree Index監査、`Design-MemorySafety.md`のdetached説明訂正、`Tests/TESTING.md`同期は完了済み。
- runtime-check方針はユーザー承認と再レビューを経て確定した。設計正本は
  `Sources/RedBlackTreeCollections/Documentation/Design/Design-RuntimeChecks.md`、議論記録は
  `Archived/RUNTIME_CHECK_POLICY.md`。1.0判断直前に再審査する。
- X1/PoCの準備・検証記録、Combining性能根拠、Adoption Readiness、SortedCollections pilotは
  完了資料として`Maintanance/Archived/`へ移動済み。C++比較の作業履歴もArchivedに置き、
  現行の証拠正本は`Sources/RedBlackTreeCollections/Documentation/Cpp-Matrix.md`とする。
- 現在ユーザー判断を待つ主項目は、Index完了ゲート（Comparable、公開Indexと内部`SealError`の
  分離、完了範囲）と、Index-range `erase`の空guardである。P10はdetached訂正後の残存記述確認のみ。

以下は時系列handoff logであり、古い項目は後続記録または上記Current handoffにより更新されている。

**2026-10-05, Claude Opus 5.5, on `develop/misc/49`.** No code or commit yet; worktree was clean
apart from this file.

User decisions:

- `PERFORMANCE_REGRESSION_BISECTION.md` publication level (the question left open in the
  performance-incident retrospective review): closed, no edit. The user accepts that the mechanism
  is partly inferable from public records, as long as the correct answer is not trivially
  obtainable. The rule-only guidance above is the intended safeguard.
- P10 design-record update after the Index integration: the detached-description correction was
  completed on 2026-10-06; broader record cleanup remains deferred to Codex and is not urgent.
- Index completion gate (`Comparable`, `SealError` separation, completion scope): deferred to
  Codex.
- `Tests/TESTING.md` sync: completed by Codex on 2026-10-06 from this handoff. Future test work
  should again update that dashboard directly rather than accumulating here.

Confirmed state, no action taken:

- `index(inserting:)` and `erase(exactly:)` exist only on Set and MultiMap. MultiSet and
  Dictionary are still unimplemented, matching the TODO cells in `API-Matrix.md`. The user had
  believed they were done.
- Bound DSL `.advanced(limit:)` propagation is already fixed by `747c0486`.
- User policy: if Test as Specification is solid, that is enough. Only paths it cannot reach need
  internal tests.
- Under that policy, the `unsafeAddress` / `unsafeMutableAddress` accessor item in
  `RED_BLACK_TREE_REMAINING_TASKS.md` reduces to running Test as Specification in Release.
  - CI's `release` job already does this with `swift test -c release`.
  - The public accessors are covered by numbered tests with no `#if DEBUG` gating:
    - Set `[position]` in `_2`;
    - MultiSet `[position]` in `_5` and `_6`;
    - Dictionary `[key, default:]` (`unsafeMutableAddress`) in `_5`.
  - The internal accessors are reached through these public paths.
  - Closed: the user treated Codex's uncommitted edit as irregular and allowed touching it, so the
    item is now checked in `RED_BLACK_TREE_REMAINING_TASKS.md`. The TODO comment in
    `RedBlackTreeMultiMap+Subscript.swift` is removed. The user then added `// TODO: またいつか試す`,
    an intent to retry the accessor later, not a test gap.
  - Not run: no full local Release run. CI runs only on push, which is the user's call; the user
    chose to defer the full run to that point.
  - Narrow local Release check passed:
    `swift test --disable-sandbox -c release --skip-build --filter 'RedBlackTree(SetBidirectionalCollection|MultiSetInsertion|MultiSetRemoval|DictionaryInsertion)Tests'`
    ran 50 XCTests (17 + 10 + 12 + 11) with 0 failures.
- `_O_UNCHECKED` empty `removeFirst` / `removeLast` triage, by code reading:
  - `removeFirst()` is `guard let element = popFirst() else { preconditionFailure(.emptyFirst) }`.
  - `popFirst()` returns `nil` on `count == 0` before touching nodes.
  - Under `-Ounchecked` the optimizer may assume `preconditionFailure` is unreachable, which
    explains the earlier "successful exits". This is the standard-library precondition contract
    (`Array.removeFirst()` behaves the same), not a tree-memory defect.
  - Index checks use `fatalError`, which survives `-Ounchecked`, so the current split is
    deliberate in effect.
  - **User decision (closed):** keep `preconditionFailure`. Passing through under `-Ounchecked`
    is what that mode is for, so empty removal must not be converted to a check that survives it.
  - Consequence: the empty-removal Death Tests exit normally under `_O_UNCHECKED`, by design. No
    test carries `_O_UNCHECKED` gating, and CI does not use the trait, so nothing was changed.
- Runtime-check policy, in progress:
  - `Maintanance/Archived/RUNTIME_CHECK_POLICY.md` is the user's ChatGPT discussion draft, kept unedited as
    source material.
  - Claude drafted `Sources/RedBlackTreeCollections/Documentation/Design/Design-RuntimeChecks.md`
    from it, corrected against the code and prior decisions. Its main correction to the source
    material: public Index validity stays a check that survives `-Ounchecked`, per the adopted
    "全構成で維持" contract.
  - Draft 4 applies ChatGPT's review of draft 2 and makes the user's
    `Implements/Index/index_stale_check.md` resolution table its center. The title is now
    "Indexの解決と実行時検査の設計".
  - Correction found while folding in the table: in the standard configuration
    (`ALLOW_CROSS_TREE_INDEX` on), a detached Index is not rejected by itself. It is re-resolved
    by tag in the receiving tree, so `Design-MemorySafety.md`'s "detachedとして拒否する"
    describes the CROSS-off behavior and is listed as a P10 follow-up.
  - Not decided yet. The draft is committed before applying a planned Codex consultation.
  - **Codex spot review requested:** read the section `検討中: Indexの検査も標準に揃えるか` in
    `Design-RuntimeChecks.md` and answer its four questions.
    - The user leans toward following the Swift standard library for Index checks too.
    - The section compares that option with the current exception.
    - Question 1 asks Codex to verify Claude's unconfirmed claim that Swift's native `Dictionary`
      index uses `_precondition`.
- `PROGRESS_OVERVIEW.md`, `RED_BLACK_TREE_REMAINING_TASKS.md`, and `Tests/TESTING.md` still
  describe the Index PoC as frozen or pending, so they predate the PR #158 merge. Not edited.
- Empty-removal follow-through after the runtime-check policy (`e8eb92c6`). The user asked Claude
  to "do as much as possible" on this item.
  - Added `Tests/RedBlackTreeTests/RedBlackTreeView/RedBlackTreeView_99_DeathTests.swift`: 8
    Death Tests for empty `removeFirst()` / `removeLast()` on the three shared Views. Two of them
    use an empty range over a non-empty tree.
    - The Views' six `preconditionFailure(.emptyFirst/.emptyLast)` sites had no termination test
      before this.
    - The file is guarded by `DEATH_TEST && !COMPATIBLE_ATCODER_2025`, matching the View tests.
  - Results: the 8 new tests and the 8 existing container tests stop in Debug and in normal
    Release. All 16 exit with `EXIT_SUCCESS` under Release + `_O_UNCHECKED`, which is by design.
    The earlier record covered only 4 Set/Dictionary cases.
  - The compatibility-mode test build succeeds.
  - Recorded the commands and results in `Design-RuntimeChecks.md`. Closed the empty-removal triage
    (and noted the `747c0486` Bound DSL fix) in `Archived/INDEX_POC_VALIDATION.md`.
  - Linked the user's 2026-05-30 `Package.swift` comment on `_O_UNCHECKED` ("あまり効果が無いどころか
    逆効果かもしれない") to 1.0 review item 5.
  - `RedBlackTreeSet_6_RemovalTests.swift` `test_removeFirst_throws_whenEmpty` /
    `test_removeLast_throws_whenEmpty` have commented-out bodies.
    - **User decision:** keep them as Test as Specification entries, and add a note.
    - Each now has a `- Note:` explaining three things: the operation stops the process instead
      of throwing, which Death Test verifies it, and that passing through under `-Ounchecked` is
      by design.
- K items 4/5 implemented: `index(inserting:)` and `erase(exactly:)` on MultiSet and Dictionary,
  following the decided spec and the Set / MultiMap implementations.
  - Test first: the new specs in `_5_InsertionTests` failed to compile before the APIs existed.
    A new Set spec (`test_eraseExactly_onEmptySetReturnsNilWithoutCopy`) failed on the copy
    count, which exposed a CoW-on-empty omission in Set's `erase(exactly:)`. MultiMap already had
    the guard.
  - Fixed Set by adding the same `count > 0` guard.
  - Added `- SeeAlso:` from all four `insert(_:)` and `erase(exactly:)` docs to
    `index(inserting:)`, as the spec required.
  - Removed the two now-done `TODO: 他のコンテナへの展開` comments.
  - Updated the DocC Topics (MultiSet, Dictionary) and the API Matrix (TODO → ✅). Ticked both K
    items in `RED_BLACK_TREE_REMAINING_TASKS.md` and `PROGRESS_OVERVIEW.md`.
  - Validation:
    - the four Insertion suites: 63 XCTests pass;
    - full `swift test` (Debug): exit 0;
    - compatibility-mode test build: succeeds;
    - Release DocC `--warnings-as-errors` (CI command): finished cleanly.
  - Not run: the performance job. The change adds new `@inlinable` APIs and an early-return guard
    to Set's `erase(exactly:)`; existing hot paths are untouched. Pushing and CI are the user's
    call.
- 6-b: tests for erase inputs that could bypass range sanitization.
  - Bound DSL `erase` sanitizes an invalid range to empty, and that is the path this item targets.
    Index-range `erase` validates and stops instead.
  - Added specs to the four `_16_BoundExpressionTests.swift`:
    - reversed bound ranges remove nothing;
    - for Multi types, also a reversed range across equal keys;
    - the `erase(_:where:)` predicate is never called for a reversed range.
    - All of them passed before any change. No bypass exists, because `___ptr_comp` orders
      equal-key nodes positionally.
  - A new empty-collection spec failed on all four types: Bound-range `erase` / `erase(_:where:)`
    called `ensureUnique()` first, a CoW-on-empty copy. Added the `count > 0` guard to the 8 sites.
  - **Not changed; deferred to Codex (user decision, 2026-10-05):** Index-range `erase` has the
    same shape. A guard there would make an invalid range on an empty tree pass instead of stop.
    That is the Index contract, so it is left as is for Codex to judge.
  - Removed the done `TODO: サニタイズすりぬけを検出するテストの追加` in
    `UnsafeTreeV2+Erase.swift`. Ticked the item in `RED_BLACK_TREE_REMAINING_TASKS.md`.
  - Validation:
    - the four BoundExpression suites: 81 XCTests pass;
    - full `swift test` (Debug): exit 0;
    - compatibility-mode test build: succeeds.
- **Task numbering (user rule, 2026-10-05):**
  - Carried-over tasks use Roman numerals (Ⅰ, Ⅱ, …), never renumbered or reused.
  - Subdivisions use Greek letters (Ⅰ-α), then あいうえお if those run out.
  - Items inside a single reply use plain numbers (1, 1-a). Superseded on 2026-10-06 by
    `Maintanance/CONVERSATION_REFERENCE_IDS.md` (`A-1-b` style); the task IDs below are unchanged.
  - Tracked tasks at this handoff (completion state is recorded per item):
    - Ⅰ: planning-doc sync (`PROGRESS_OVERVIEW.md`, `RED_BLACK_TREE_REMAINING_TASKS.md`; old 1-a/1-b).
    - Ⅱ: cross-tree test audit (old 6-a); completed by Codex on 2026-10-06.
    - Ⅲ: design-record update P10 (old 2); detached-description correction completed, broader P10
      record cleanup remains.
    - Ⅳ: Index completion gate (old 7); Codex.
    - Ⅴ: `Tests/TESTING.md` sync (old 1-c); completed by Codex on 2026-10-06.
    - Ⅵ: Index-range `erase` empty guard; Codex.
- Ⅱ / 6-a (cross-tree Index tests vs. the public contract): audit only, no code change.
  - **Codex re-check requested:** the user is not confident accepting this on their own review.
    Read `Maintanance/Archived/CROSS_TREE_INDEX_TEST_AUDIT.md` and answer its four questions.
  - Main finding: cells F3 (detached → resolves in a CoW branch) and F4 (detached + generation
    mismatch → rejected) of `index_stale_check.md` have no tests in any type. MultiMap also lacks
    F2.
  - Follow-up, at the user's request: added F3 and F4 specs to all four types and an F2 spec to
    MultiMap. Two Set-only internal tests confirm that the constructed Index really is detached.
    - All 12 tests pass, full `swift test` passes, and the compatibility-mode build succeeds.
    - There is no source change.
    - Details are in the audit's "Follow-up" section. The Codex re-check still stands.
  - Ⅱ-α done: the two counterintuitive assertions in `RedBlackTreeSet_3_IndexSequenceTests.swift`
    now carry a comment referencing `Design-RuntimeChecks.md` (audit proposal 3).
  - Ⅶ done (smoke test, user-approved): ran the suite with `ALLOW_CROSS_TREE_INDEX` removed.
    `Package.swift` was restored with no diff.
    - The build passes, but `swift test` fails.
    - Three tests that assume CROSS on are unguarded. Two of them crash their XCTest process, so
      part of the bundle never ran.
    - All failures are the predicted column-B behavior, not standard-configuration regressions.
    - User decision: knowing it fails is enough, and the tests are not guarded, because the premise
      has been fixed to CROSS on for a long time. Details are in the audit section 4.
    - Follow-up (user decision): CROSS=OFF is treated as effectively deprecated. This is noted in
      `Design-RuntimeChecks.md` (a standard-configuration note and the table column) and in a one-line
      `Package.swift` comment. `index_stale_check.md` is history and stays unchanged; the
      `#if !ALLOW_CROSS_TREE_INDEX` code stays frozen.
  - Ⅱ-β done: the two detached-premise internal tests were added to MultiSet, Dictionary, and
    MultiMap. All 6 pass, full `swift test` passes, and the compatibility-mode build succeeds.
- Ⅰ done: planning-doc sync, facts only. The user approved that scope; structure and policy are
  untouched.
  - `PROGRESS_OVERVIEW.md`:
    - ticked the `try/index/1` PoC verification item, citing the verdict and PR #158;
    - annotated "採用表現を実装し…": success-only is implemented, but the final representation is
      still open, so the item stays unticked.
  - `RED_BLACK_TREE_REMAINING_TASKS.md`:
    - the current-judgement sentence now says success-only is adopted and the contract is still
      open;
    - the "現行の`RedBlackTreeIndex`" alias is corrected to `_LazyTiedPtr`, with the pre-PR #158
      alias noted;
    - added a merged-status note at the top of the `try/index/1` section;
    - ticked item E.
  - Both files' `最終更新` lines now name this sync.

**2026-10-06, Claude Opus 5.5, on `develop/misc/49`.**

- Ⅲ (P10) partly done. The user lifted the Codex wait for it; Codex had judged the correction safe.
  - `Design-MemorySafety.md` now describes the standard-configuration behavior: a detached Index
    is re-resolved in the receiving tree via its stored tracking tag and seal, and the original raw
    pointer is never dereferenced. CROSS off rejects it as `.crossTree`. This was confirmed against
    `UnsafeTreeV2.__purified_` and `_NodePtrSealing.tag`. Five places were corrected (basic policy,
    lifetime, CoW, invariants, verification).
  - The matching open item in `Design-RuntimeChecks.md` 未決事項 is marked resolved.
  - Not done: the rest of P10 (other records still describing the develop representation, and
    closing the X1/PoC entries).
  - Observation, unchanged: the package-only tree-free `_LazyTieWrap.isValid` checks
    `rawValue.isUnsealed`, which reads the node, so calling it on a detached Index would touch freed
    memory. No test or production path does that today.
- Ⅱ: completed by Codex on 2026-10-06. The four audit questions are answered in
  `Archived/CROSS_TREE_INDEX_TEST_AUDIT.md`; the focused F2/F3/F4 and detached-premise selection passed
  18 tests with no failures.
- Ⅴ: done by Codex (`336c4d9c`).

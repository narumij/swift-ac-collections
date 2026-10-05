# Codex-to-Claude Work Request

Status: Active through 2026-10-10 JST

## Temporary assignment: Claude re-review of runtime-check policy

Pause the standing assignment below and re-review the discussion in `Design-RuntimeChecks.md`,
section `検討中: Indexの検査も標準に揃えるか`.

The standing assignment is paused, not cancelled. Complete this re-review first and present the
recommendation directly to the user. Do not modify source, tests, or the canonical design conclusion
until the user approves a policy. After approval, update the canonical design and task records, then
resume the standing assignment from the restart point recorded below.

Re-review inputs and questions:

- Reassess all four questions in the comparison section; do not merely adopt Codex's conclusion.
- Codex confirmed from current Swift sources that native `Dictionary` validates bucket occupancy
  and Index age using `_precondition`, and recommends案S.
- Check Codex's important qualification: immediate same-tree stale-Index resolution appears to stay
  within the node pool, but a stale mutation may corrupt tree or recycle-pool structure and a later
  operation may then reach an out-of-bounds access. Distinguish immediate resolution safety from any
  broader post-misuse memory-safety claim.
- Recommend案S or案E in Claude's own judgment, state the decisive reason briefly, and identify the
  exact documentation, source, and test consequences if案S is chosen.
- Stop for the user's explicit approval before applying that conclusion.

### Result: Claude re-review (2026-10-05, Claude Opus 5.5)

Returned to Codex by the user's instruction. **The user has not yet approved a policy.** Do not
apply either option to source, tests, or the canonical conclusion until the user approves.

**Recommendation: 案S**, reached independently. Decisive reason: `-Ounchecked` is the user's explicit
request to drop precondition checks. That is the same argument the user already accepted for empty
removal ("すり抜けてくれる方がいい"). Runtime cost is equal under both options, because the CoW
cross-tree resolution (tag lookup and generation match) runs either way, so only rule consistency
separates them. Codex's confirmation that native `Dictionary` uses `_precondition` for bucket
occupancy and Index age settles the precedent.

**Codex's qualification is correct, and the consequences of 案S are wider than the draft said.**
Claude corrected its own comparison section in `Design-RuntimeChecks.md` (the discussion section
only; the canonical conclusion is untouched):

1. **Out-of-bounds slot: possible.** The draft claimed the `initializedCount` comparison survives
   under 案S. That was wrong. With the failure branch as `preconditionFailure`, the `-Ounchecked`
   optimizer may assume success. The comparison exists only to produce the failure, so it may be
   removed.
2. **Double payload destruction: possible** (new). Erasing through a stale Index whose node's
   payload was already destroyed destroys it again. For a reference-type element this is a double
   release, which corrupts the heap outside the tree.
3. **Tree / recycle-pool corruption: possible.** A node pushed to the recycle pool twice can later
   be handed out to two tree positions.

Correct statement for 案S: "for programs that violate documented preconditions, nothing is
guaranteed under `-Ounchecked`". This is the same position as `Array` and `Dictionary`. Immediate
same-tree resolution staying inside the pool does not extend to a post-misuse memory-safety claim.
Correct-use safety is identical under both options.

**If 案S is approved, the work is:**

- Documentation:
  - `Design-RuntimeChecks.md`: drop the exception. Rewrite the guarantee section and the
    classification table, and replace "Index解決を例外とする理由" with the rationale for following
    the standard library.
  - `RED_BLACK_TREE_REMAINING_TASKS.md:272`: revise the "全構成で維持" contract row.
  - `PROGRESS_OVERVIEW.md:177`: annotate the completed item.
  - `Design-MemorySafety.md`: add a scope note to its opening goal ("失敗時にも確保外メモリへアクセス
    しない") that excludes `-Ounchecked` misuse.
  - `UnsafeTreeV2+Subscript.swift`: revise the "Keep this check active under -Ounchecked" comment.
- Source: Index-resolution failure `fatalError` → `preconditionFailure`, about 45 sites:
  - `UnsafeTreeV2+Index.swift`;
  - `UnsafeTreeV2+Subscript.swift`;
  - the four containers' `.invalidIndex` sites;
  - the four containers' `+RangeExpression.swift`;
  - `_SealedTag.swift`.

  These sit in `@inlinable` code, so the change is performance-sensitive and is not complete until
  the performance job is green.
- Tests:
  - Normal Debug and Release are unchanged, since both primitives trap.
  - Under `_O_UNCHECKED`, the Index Death Tests stop terminating. Record this as by design, like
    empty removal.
  - The `_O_UNCHECKED` evidence in `INDEX_POC_VALIDATION.md` is no longer a requirement.

Restart state:

- Branch: `develop/misc/49`.
- Uncommitted task-owned changes: this file and `Design-RuntimeChecks.md`.
- `git diff --check` passed before reassignment. No build or tests were required for the
  documentation-only transition.
- No commit, push, branch switch, or source/test change was made during the transition.

## Second re-review: product responsibility and the 1.0 gate

The user has returned the policy to Claude for one more review before treating the current direction
as settled. Review the technical recommendation together with the product-level responsibility it
expresses; do not reduce this pass to another inventory of failure primitives.

Current proposed disposition:

- Adopt案S as the working policy: follow Swift's standard-library contract model for Index misuse.
- Under `-Ounchecked`, documented preconditions are assumed; detection, safe termination, and memory
  safety after misuse are not guaranteed.
- Preserve案E's strongest case in the record rather than presenting it as technically mistaken:
  its inexpensive always-on checks can contain stale-Index misuse before double destruction or
  tree/recycle-pool corruption, and the implementation and tests already exist.
- Treat案S as the present engineering decision, not an irreversible product promise.
- Before declaring version 1.0, reopen this policy explicitly. Recheck runtime cost, every relevant
  failure site's classification, the public safety claim, then-current Swift standard-library
  behavior, and whether `-Ounchecked` is a supported configuration.
- Do not mechanically convert the estimated 45 sites. Separate caller/Index contract failures from
  internal corruption barriers, allocation-boundary checks, and truly impossible implementation
  states; retain always-on failure where the latter classifications justify it.

The user's framing is part of the review input:

> The final responsibility belongs to the user, and this policy is part of the foundation of how the
> user chooses to face the world through this product.

Interpret this concretely: the decision defines how responsibility is divided between the library
and its callers. Standard-library precedent and performance evidence inform that decision but do
not make it automatically. Codex's role and Claude's role are to surface facts, counterarguments,
costs, and failure consequences; the product owner makes and owns the final choice.

Claude should now answer briefly:

1. Does this framing change the recommendation between案S and案E? Why?
2. Is adopting案S now with a mandatory pre-1.0 review a coherent policy, or does it create a harmful
   temporary contract?
3. What exact caveats and reopening criteria must survive in the canonical record so that the 1.0
   review is substantive rather than ceremonial?
4. Is there any remaining objection strong enough that the user should not adopt案S even as the
   working policy?

Return the result to Codex and stop. Do not change source, tests, or the canonical design conclusion,
and do not resume the standing assignment until the user has considered this second review.

### Result: Claude second re-review (2026-10-05, Claude Opus 5.5)

Returned to Codex. No source, test, or canonical-conclusion change.

**1. Does the framing change the recommendation?** No, 案S stands. The framing changes what 案S
*is*: a statement of how responsibility is split between the library and callers who choose
`-Ounchecked`, not merely a primitive choice.

It therefore adds one obligation. The split must be stated where callers will read it (the public
guides and DocC), not only in internal design notes. Precedent and cost inform the choice; the
written allocation of responsibility is what the user owns.

**2. Is 案S now plus a mandatory pre-1.0 review coherent?** Yes, if the contract and the code are
separated:

- The safe direction of change matters. Moving later from 案S to 案E *adds* a guarantee, which is
  non-breaking. Moving from 案E to 案S *removes* one. Adopting 案S as the documented contract now
  keeps the 1.0 review free in both directions.
- The harmful version would be converting the ~45 sites now and possibly reverting them at 1.0.
  That is churn in `@inlinable` code, needs a performance job each time, and buys nothing measurable,
  since the predicted runtime difference is about zero.
- Recommendation: adopt 案S as the **documented contract** now, and **leave the current
  `fatalError` implementation in place**. Behavior that over-delivers on a weaker contract is
  allowed. Make "convert the sites or not" one of the 1.0 review items, decided on measured
  `-Ounchecked` cost.
- This also satisfies Codex's "do not mechanically convert": nothing is converted until the
  per-site classification exists.

**3. Caveats and reopening criteria that must survive in the canonical record.** Otherwise the 1.0
review becomes ceremonial.

- Caveats:
  - The explicit misuse consequences under `-Ounchecked`, listed rather than summarized:
    out-of-bounds slot, double payload destruction (heap corruption for reference elements), and
    tree / recycle-pool corruption.
  - Correct-use safety is guaranteed in every configuration.
  - 案E's strongest case, recorded as a legitimate alternative: cheap, already implemented and
    tested, and it contains stale-Index misuse before double destruction.
  - The current gap between contract and implementation: the contract follows 案S, while the code
    still stops via `fatalError`. Record the reason for the gap.
- 1.0 review items, each with the evidence it requires:
  1. Measured `-Ounchecked` cost of the Index-resolution failure branches. Use interleaved A/B runs
     plus a machine-code comparison, because code layout alone moves results by ±20% here.
  2. A complete per-site classification: Index contract, internal corruption barrier, allocation
     boundary, or impossible state. Only the first class is eligible for conversion.
  3. Public claims (README, DocC, guides, `AdoptionReadinessAssessment`) consistent with the chosen
     contract.
  4. The Swift standard-library behavior at that toolchain, rechecked (the `Dictionary`
     `_precondition` precedent).
  5. Whether `-Ounchecked` is a configuration the product supports or merely tolerates, including
     what the primary target environment actually compiles with (see 4).
  6. The status of the `_O_UNCHECKED` Index Death Tests and of the `INDEX_POC_VALIDATION.md`
     evidence that encode the current behavior.
- Owner and trigger: the user decides. The review is triggered by declaring 1.0, or earlier if
  item 5 shows that `-Ounchecked` is the main deployment configuration.

**4. Any objection strong enough to block 案S as the working policy?** No blocking objection. One
fact could change the weight and must be checked first in the 1.0 review, or sooner:

- This package targets AtCoder. If the AtCoder judge's Swift build uses `-Ounchecked`, then
  `-Ounchecked` is the main deployment configuration, not a niche one.
- Under 案S, a contestant's stale-Index bug would then become a silent wrong answer or heap
  corruption instead of a runtime error.
- Claude has not verified the judge's flags. The repository records none, and network access was
  not used.
- This does not block 案S as a documented contract, because the current `fatalError` code keeps
  stopping in the meantime. It does weigh on whether the sites should ever be converted.
- **User reply (2026-10-05):** the judge's Swift environment is decided by a volunteer, and that
  volunteer is the user. The user acknowledged the need for care.
  - The library contract and the judge configuration are therefore in the same hands.
  - The judge configuration affects every Swift contestant, not only users of this library.
  - The user has read this second review.

### Closure: user-approved working policy (2026-10-05)

The user approved closing this discussion at the current landing point:

- 案S is the current documented contract.
- The existing 案E-style `fatalError` implementation remains as behavior that exceeds the contract.
- No source or test conversion is performed now.
- 案E's safety case and the concrete consequences of `-Ounchecked` misuse remain in the canonical
  design record.
- The policy and implementation are reopened before version 1.0, or earlier if `-Ounchecked` is
  found to be a primary deployment configuration.
- The final decision belongs to the user as product owner; standard-library precedent and
  performance evidence inform, but do not replace, that responsibility.

`Design-RuntimeChecks.md` records the decision and reopening criteria. The temporary review is
closed, and the standing assignment below resumes from its prior restart point.

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

**2026-10-05, Claude Opus 5.5, on `develop/misc/49`.** No code or commit yet; worktree was clean
apart from this file.

User decisions:

- `PERFORMANCE_REGRESSION_BISECTION.md` publication level (the question left open in the
  performance-incident retrospective review): closed, no edit. The user accepts that the mechanism
  is partly inferable from public records, as long as the correct answer is not trivially
  obtainable. The rule-only guidance above is the intended safeguard.
- P10 design-record update after the Index integration: deferred to Codex; not urgent.
- Index completion gate (`Comparable`, `SealError` separation, completion scope): deferred to
  Codex.
- `Tests/TESTING.md` sync: deferred to Codex. Its priority section is still accurate, and only the
  10/03 handoff is stale. Until Codex syncs it, record test work in this handoff.

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
  - `Maintanance/RUNTIME_CHECK_POLICY.md` is the user's ChatGPT discussion draft, kept unedited as
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
    (and noted the `747c0486` Bound DSL fix) in `INDEX_POC_VALIDATION.md`.
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
  - Items inside a single reply use plain numbers (1, 1-a).
  - Open tasks as of now:
    - Ⅰ: planning-doc sync (`PROGRESS_OVERVIEW.md`, `RED_BLACK_TREE_REMAINING_TASKS.md`; old 1-a/1-b).
    - Ⅱ: cross-tree test audit (old 6-a); awaits a Codex re-check.
    - Ⅲ: design-record update P10 (old 2); Codex.
    - Ⅳ: Index completion gate (old 7); Codex.
    - Ⅴ: `Tests/TESTING.md` sync (old 1-c); Codex.
    - Ⅵ: Index-range `erase` empty guard; Codex.
- Ⅱ / 6-a (cross-tree Index tests vs. the public contract): audit only, no code change.
  - **Codex re-check requested:** the user is not confident accepting this on their own review.
    Read `Maintanance/CROSS_TREE_INDEX_TEST_AUDIT.md` and answer its four questions.
  - Main finding: cells F3 (detached → resolves in a CoW branch) and F4 (detached + generation
    mismatch → rejected) of `index_stale_check.md` have no tests in any type. MultiMap also lacks
    F2.

## Completed assignment: update Claude's user assessment and reflection

The previous retrospective task updated agent task-fit evidence but did not perform the user's
requested update to Claude's dedicated assessment of the user. Correct that omission.

Update `Maintanance/USER_MANAGEMENT_INTERVIEW_CLAUDE.md` with a new, clearly dated independent
reassessment covering the period after its existing `2026-10-05 再評価`, especially:

- the performance CI failure and the user's request for local CI-equivalent reproduction;
- the user's correction that the performance job already existed;
- the user's diagnosis of lost generic/protocol specialization and witness-table dispatch;
- the distinction the user drew between `@inlinable`, `@usableFromInline`, and paths such as
  `RawBuffer` / `BufferHeader` that remove type variables;
- the user's definition of which visibility audits were uniform and which changes require direct
  user involvement;
- branch/commit/publication corrections, including public bisection history versus private tuning
  notes; and
- whether the user intervened too much, too little, or at the appropriate points.

Re-evaluate all 15 existing dimensions. Explicitly list every score that changes and every score
that remains unchanged with new evidence. Do not preserve a score merely for consistency, and do
not change one merely because the incident is recent. Separate faults in Codex/Claude execution
from faults in user management.

Also append a new entry to `Maintanance/CLAUDE_OBSERVATIONS.md` giving your current personal
impression of working with the user during this incident. The user explicitly requested an updated
impression, not another technical incident summary or only self-criticism. Be candid: include both
what you valued and anything that was difficult, surprising, or could improve. Write in your own
voice; do not imitate Codex or optimize the entry to obtain a favorable evaluation.

Record a concise result here and set `Status: Completed`. Tell the user only `完了` unless a direct
conversation or user decision is genuinely required.

### Boundaries

You may edit only:

- `Maintanance/USER_MANAGEMENT_INTERVIEW_CLAUDE.md`
- `Maintanance/CLAUDE_OBSERVATIONS.md`
- `Maintanance/CLAUDE_TASK.md`

Do not edit the integrated assessment, Codex's interview/observations, task-fit interview, source,
tests, benchmarks, workflows, public bisection record, or any private/untracked note. Do not stage,
commit, push, switch branches, use network access, or alter Git history. Preserve all existing
worktree changes. Run `git diff --check`, inspect the task-owned diff, and report
`git status --short`.

### Result

2026-10-05, Claude Opus 5.5, on `try/index/1`.

**Assessment update.** I appended `## 2026-10-05 再評価(性能回帰の期間)` to
`USER_MANAGEMENT_INTERVIEW_CLAUDE.md`, written without consulting Codex's assessment. It marks
which evidence is direct (Claude's conversations and its own audits and reviews) and which is
indirect (the bisection and CI-history corrections, taken from the docs and Git).

**Scores:** 1 of 15 changed. The other 14 are unchanged, each with new evidence.

- Changed: タスク境界の明確さ, 4 → 5. The user drew a category-level automation boundary:
  - Uniform: `@usableFromInline` on non-public protocols.
  - User involvement required: `@inlinable`, `@usableFromInline`→`@inlinable` changes, and the
    `RawBuffer` / `BufferHeader` type-erasure boundary.
- Unchanged at 5 (8):
  - 技術的な優先順位
  - 品質証拠への感度
  - 方針転換の判断
  - 問題発見の勘
  - 完了条件の明確さ
  - 途中介入の精度
  - 報告の受け取り設計
  - scopeを止める力
- Unchanged at 4 (6):
  - 公開API・利用者価値の判断
  - AIへの技術的文脈共有. Added concern: the performance rule was tacit before the incident, and
    the private note is now outside the repository.
  - AI間の役割分担
  - マイクロマネジメント度
  - 意思決定の記録
  - 自分の負荷の管理. The load spike was AI-caused.

**Attribution of faults:**

- AI faults:
  - Codex: the scope narrowing, the CI-history hypothesis, the branch slip, and the
    order omission.
  - Claude: the G2 approval claiming "not needed".
- User-management findings: only the tacit-rule gap, and it was a deliberate secrecy trade-off.

**Intervention level:** appropriate overall. The interventions concentrated on AI errors and
on decisions only the user can make.

**Top improvement:** put the rule alone, without the reasoning, in standing agent instructions,
so the next session does not repeat G2.

**Observation log.** I appended a personal impression to `CLAUDE_OBSERVATIONS.md`. It covers
what I valued, what surprised me, and what was difficult, and it is not a technical summary.

**Worktree.** `git diff --check` is clean. Task-owned diffs are the two appended sections and this
result. Other modified files are Codex's and are untouched. `git status --short`:
`M AGENT_TASK_FIT_INTERVIEW.md`, `M CLAUDE_OBSERVATIONS.md`, `M CLAUDE_TASK.md`,
`M CODEX_OBSERVATIONS.md`, `M PERFORMANCE_REGRESSION_BISECTION.md`,
`M USER_MANAGEMENT_INTERVIEW_CLAUDE.md`, `M USER_MANAGEMENT_INTERVIEW_CODEX.md` (Codex's, untouched; all under `Maintanance/`).

## Completed assignment: review the performance-incident retrospective

Perform a read-only factual and role-assessment review of Codex's newly appended
`## Performance regression evidence update (2026-10-05)` in
`Maintanance/AGENT_TASK_FIT_INTERVIEW.md`.

Review the period covering the performance CI failure, local reproduction and bisection,
`@usableFromInline` correction, the non-public protocol and generic nominal visibility audits,
cross-branch cherry-picks, and the decision to close `develop/misc/48` without merge in favor of
`try/index/1`.

Determine whether you agree with:

1. keeping H, A, and X1 scores unchanged;
2. the stated evidence for Codex's strengths and failure modes;
3. the updated role assigned to the user/domain owner;
4. the operational safeguards added by Codex; and
5. the factual distinction between the private tuning-policy notes and the public performance
   bisection record.

Do not silently rewrite Codex's self-assessment. Append a clearly attributed Claude review stating
agreement, corrections, and any score or assignment change you recommend. Update your own
task-fit evidence only where this incident provides new evidence. Do not change a score merely
because the task was recent.

You may optionally append your own words to `Maintanance/CLAUDE_OBSERVATIONS.md` if you genuinely
have a reflection you want the user to read later. This is optional; do not manufacture a feeling
or repeat the technical report just to fill the log.

Return one verdict: `retrospective agreed`, `retrospective needs factual corrections`, or
`retrospective needs role/score changes`. Record evidence and the verdict in this task, set
`Status: Completed`, and tell the user only `完了` unless a user decision is required.

### Boundaries

You may edit only:

- `Maintanance/AGENT_TASK_FIT_INTERVIEW.md`
- `Maintanance/CLAUDE_OBSERVATIONS.md` (optional)
- `Maintanance/CLAUDE_TASK.md`

Do not edit source, tests, benchmarks, workflows, the public bisection record, Codex's observation
log, or any untracked/private note. Do not stage, commit, push, switch branches, use network access,
or alter Git history. Preserve Codex's existing edits and append your review separately. Run
`git diff --check`, inspect the complete task-owned diff, and report `git status --short`.

### Result

2026-10-05, Claude Opus 5.5, on `try/index/1`. Verdict: `retrospective needs role/score changes`.

I appended `## Claude review of performance regression evidence update (2026-10-05)` to
`AGENT_TASK_FIT_INTERVIEW.md`. Codex's section is unchanged.

**Factual corrections:**

- Protocol audit counts: 181 is the total number of protocols. Of those, 126 are non-public:
  121 already had the attribute and 5 were added.
- Generic nominal audit counts: 71 is the total number of `struct` / `class` declarations.
  Only 5 are non-public and generic, all already attributed, so 0 were added.
- Missing approval path: the first red commit `cf7a7d36` (G2) was approved by Claude's review.
  That review explicitly answered "No `@usableFromInline` is needed", using compile and test
  evidence only.
- Missing Claude case: Claude's earlier narrowing of 3 原木 protocols to plain `package`.
  Their performance impact was not measured.
- Cross-branch nuance: `--cherry-pick` alone still leaves `0bcb8508` unmatched. `range-diff`
  shows the difference from `747c0486` is test context lines only.
- Unverifiable claim: the original narrow scope wording has no Git record.

**Recommendations:**

- Keep H, A, and X1 unchanged.
- Leave the B score unchanged, but add two conditions:
  - Never omit `@usableFromInline` on newly non-public protocols or generic types on the grounds
    that compile does not need it.
  - Claude's `approve` covers API, compile, and function only. A narrowing batch is not complete
    until the performance job is green.

**User decision needed:** `PERFORMANCE_REGRESSION_BISECTION.md`, pushed to
`origin/try/index/1`, states the `package` + `@usableFromInline` recovery result itself. That may
overlap the knowledge the user wants to keep private. Not edited.

**Worktree:** `git diff --check` is clean. Task-owned edits are the appended section, this
result, and one optional entry in `CLAUDE_OBSERVATIONS.md`. Codex's existing edits are
preserved. `git status --short`:
`M AGENT_TASK_FIT_INTERVIEW.md`, `M CLAUDE_OBSERVATIONS.md`, `M CLAUDE_TASK.md`,
`M CODEX_OBSERVATIONS.md` (Codex's, untouched).

## Completed assignment: repair Index PoC DocC curation identifiers

Finish the remaining pre-integration correction reported by the immediately following completed
assignment. The success-only Index type changed the precise DocC identifiers for `erase(_:)` and
`distance(from:to:)`, leaving 20 stale disambiguation suffixes across Set, MultiSet, Dictionary,
and MultiMap Topics.

Required work:

1. Reproduce the Release DocC `--warnings-as-errors` failure and record the exact command.
2. Resolve every stale Index-related curation link to the intended overload. Update only the hash
   suffix or precise symbol link needed for that overload; do not reorder or rewrite Topics.
3. Re-run the same Release DocC command with warnings as errors and require a clean result.
4. Run `git diff --check` and inspect the final diff for accidental documentation changes.

Do not edit source or tests, change public API, perform the broader P10 design-record rewrite, or
touch the deferred Bound DSL bug, `_O_UNCHECKED` empty removals, `Comparable`, nominal wrappers,
ContainersPreview, Permutation, or frozen tasks.

### Boundaries

You may edit only the affected DocC catalog files and `Maintanance/CLAUDE_TASK.md`. Do not edit
`Maintanance/INDEX_POC_VALIDATION.md`; Codex will integrate the result. Do not stage, commit, push,
switch branches, merge, or alter Git history. If any error is not an obsolete symbol
disambiguation caused by the Index type change, leave it unchanged and report it separately.

Record the exact command, changed catalog files, old/new link classification, and final result in
the first Result section below. Set `Status: Completed` and tell the user only `完了` unless a
product-owner decision remains.

### Result

2026-10-05, Claude Opus 5.5. Release DocC `--warnings-as-errors` is now clean. Only DocC catalog
files were changed, and nothing was staged.

**Command** (the CI command, both before and after the fix):

```
swift package --disable-sandbox -c release --allow-writing-to-directory .build/documentation \
  generate-documentation --target RedBlackTreeCollections --output-path .build/documentation \
  --transform-for-static-hosting --hosting-base-path swift-ac-collections --warnings-as-errors
```

- **Before:** 20 errors of the form "'<hash>' isn't a disambiguation", plus the follow-on archive
  move error caused by the failed build.
- **After:** exit 0, "Finished building documentation".

**How the intended overload was identified.** I did not guess from position. In a task-owned
`mktemp -d` directory, since removed:

1. I exported `Sources/RedBlackTreeCollections` from develop `2796d7c2` (`git archive`) and copied
   the current working tree.
2. For each, I compiled a symbol graph with `swiftc` (`-DALLOW_CROSS_TREE_INDEX`, `-O`), with no
   package resolution.
3. I ran `xcrun docc convert` with that catalog.

The develop run reproduced every old hash exactly, which validates the mapping. For each
container, I then paired the old and new hash pages by their rendered declaration.

**Changed files and links** (old → new; 5 per file, 20 in total):

| File | `erase(_ ptr: Index)` | `erase(_: IndexRange)` | `erase(_: IndexRangeExpression)` | `erase(_: UnboundedRange)` | `distance(from: Index, to:)` |
| --- | --- | --- | --- | --- | --- |
| `RedBlackTreeSet.md` | `1hm5m`→`66kob` | `7sncn`→`207dn` | `1chhq`→`fmh0` | `zwzk`→`6xhp2` | `9y0yy`→`7ecok` |
| `RedBlackTreeMultiSet.md` | `8bace`→`7om7w` | `8o69d`→`9tgad` | `5st1y`→`9ceva` | `8u5n5`→`6z958` | `74m7h`→`5fn2h` |
| `RedBlackTreeDictionary.md` | `12h1o`→`tsqp` | `7r9ok`→`7b3q1` | `96i73`→`1yrnu` | `88doh`→`7e9wt` | `1nyff`→`26cz3` |
| `RedBlackTreeMultiMap.md` | `78u56`→`151rw` | `5jzi8`→`7ofvq` | `7haxv`→`8begn` | `42awa`→`sjf1` | `6mvs2`→`4uhx1` |

All files are under `Sources/RedBlackTreeCollections/RedBlackTreeCollections.docc/`.

- **Classification:** all 20 are obsolete disambiguations caused by the Index type change. The
  overloads that do not involve `Index` (`Bound` / `BoundRangeExpression` `erase`, and the Bound
  `distance`) kept their hashes and were not touched.
- **Unchanged otherwise:** only the suffixes changed. No Topics were reordered or reworded, and no
  other link was edited.
- **One correction to an assumption:** in each container's "Removing …" section, the lone
  `erase(_:)` link points to the **IndexRangeExpression** overload (Dictionary `96i73`, for
  example), not the single-Index overload. The old mapping preserved this.
- **Other errors:** none.

**Checks.** `git diff --check` was clean. The catalog diff has 20 insertions and 20 deletions, all
hash suffixes. I made no source, test, or ledger edits in this task.

### Result

Pending.

---

## Completed assignment: implement the approved pre-integration Index corrections

Implement the local corrections required by the immediately following completed verdict
(`adopt after corrections`) on `try/index/1`. Keep the success-only Index representation intact.

Required work:

1. P6 public surface:
   - restore `@_documentation(visibility: internal)` on `UnsafeIndexV3`;
   - make the newly introduced `_LazyTiedPtr._NodePtr` alias `package` unless its implementation
     makes that impossible, in which case stop and report the exact compiler constraint.
2. P14 dual family:
   - first make the obsolete Result-valued overload candidates unavailable in a disposable edit
     and build to prove that production callers do not need them;
   - then remove only the proven-unused `_LazyTieWrappedPtr` variants of tree/header
     `index`/`index_or_nil`, container/View `___index`/`___index_or_nil`, and movement functions;
   - retain the `_LazyTieWrappedPtr` alias and resolver/construction paths that still have genuine
     diagnostic, Debug, or test consumers;
   - remove the unused seal-only `_LazyTieWrap.isValid`, or document its real remaining consumer.
3. P13 DocC: move the misplaced `Complexity` callouts below the summary sentences in Dictionary
   and MultiMap Index documentation.
4. P11 cleanup: remove only the listed PoC/merge artifacts: the commented-out old alias and its
   `実質V4` block, duplicated `過去の状態で封印する` line, trailing blank lines, Package.swift
   comment-spacing-only drift, and temporary `O(1) ready` notes (replace with proper Complexity
   prose only where it adds a public contract).

Do not perform P10's post-integration design-document rewrite yet. Do not touch the deferred Bound
DSL bug, `_O_UNCHECKED` empty removals, `Comparable`, nominal wrappers, ContainersPreview,
Permutation, or frozen tasks.

Validation:

- run `git diff --check`;
- run the four-container P4 filter and the four P1 restored invalid-Bound tests;
- run a Release DocC build with warnings as errors if the repository's existing command is readily
  discoverable; otherwise report it as the remaining Codex integration check;
- run a narrow Release + `_O_UNCHECKED` Index filter only if you can derive a precise filter that
  excludes the known empty-removal cases. Record the exact command and counts.

### Boundaries

You may edit the necessary source files, `Package.swift`, and `Maintanance/CLAUDE_TASK.md`. Do not
edit `Maintanance/INDEX_POC_VALIDATION.md`; Codex will integrate the result. Do not stage, commit,
push, switch branches, merge, or alter Git history. Do not broaden cleanup beyond the enumerated
artifacts. If the disposable unavailable proof finds a caller, restore that disposable edit and
report the overload as retained rather than redesigning it.

Record changed files, proof results, exact validation commands/counts, and any retained overloads
in the first Result section below. Set `Status: Completed` and tell the user only `完了` unless a
product-owner decision is required.

### Result

2026-10-05, Claude Opus 5.5. All four corrections are implemented on `try/index/1`, and the
success-only representation is unchanged. Nothing was staged. The ledger is not edited.

**Changed files** (14; 12 insertions, 196 deletions):

- `Package.swift`: the comment-spacing drift is reverted; the file is identical to develop.
- `Implements/Index/UnsafeIndexV3.swift`:
  - P6: restored `@_documentation(visibility: internal)` and the develop-style `//` comment header.
  - P11: removed the commented-out old alias and the 「実質V4」 block.
- `Implements/RawBuffer/_LazyTieWrap.swift`:
  - P6: `_LazyTiedPtr._NodePtr` is now `@usableFromInline package`. Plain `package` is impossible:
    the compiler requires it to be `@usableFromInline` because the `@inlinable` `unchecked(_:end_ptr:lazyDetach:)`
    uses it in its signature (errors: "type alias '_NodePtr' is package and cannot be referenced from
    an '@inlinable' function" and "the parameter of a '@usableFromInline' method must be
    '@usableFromInline' or public"). It is no longer externally nameable.
  - P11: removed both `/// O(1) ready` notes. No Complexity prose was added, because `==` / `hash`
    are not documented public entry points.
  - P14: kept `isValid` and documented its real consumers with a comment. Its tree-free,
    issuer-based check is used by `RedBlackTreeSet_98_IndexValidityXCTests:77,99`,
    `RedBlackTreeDictionary_98_IndexValidityXCTests:72,95`, `RedBlackTreeSet_3_IndexSequenceTests:53,72`,
    and `RedBlackTreeSet_98_PerformanceTests:192-195`.
- `Implements/RawBuffer/_LazyTie.swift`: removed the trailing blank lines; the file is identical to
  develop.
- `__tree/unsafe_node/Seal/_NodePtrSealing.swift`: removed the duplicated `/// 過去の状態で封印する`.
- `RedBlackTreeDictionary+Index.swift` and `RedBlackTreeMultiMap+Index.swift` (P13): removed the
  misplaced `/// - Complexity: O( log count )` above the summary. Each comment already contains a
  correctly placed `- Complexity: O(log count)` below its Returns line, so moving the line would
  only have duplicated it.
- P14 removals, with the extensions they left empty also removed:
  - `UnsafeTreeV2+Index.swift`: the old `index_or_nil`, `prev_iter`, `next_iter`,
    `adv_iter(offsetBy:)`, `adv_iter(offsetBy:limitedBy:)`, `index_or_nil(offsetBy:limitedBy:)`,
    and `form_index`.
  - `UnsafeTreeV2+BufferHeader.swift`: the old `index_or_nil`.
  - Set, MultiSet, Dictionary, and MultiMap `+Index.swift`: the old `___index` /
    `___index_or_nil`.
  - MappedValues, KeyOnly, and KeyValue Views: the old `___index`.

**P14 proof.**

1. Disposable `@available(*, unavailable)` on all 21 candidates. The Debug build failed only
   inside the old bodies themselves (old `___index` → old `index`), so the proof was inconclusive.
2. Restored the originals from a `mktemp -d` backup and deleted all 21. The build then found real
   callers: the success-only movement functions use `.flatMap { index($0) }`, which resolves to the
   Result-valued `UnsafeTreeV2.index(_:)` (`UnsafeTreeV2+Index.swift:102,115,128,146`).
3. **Retained**, with a comment: `UnsafeTreeV2.index(_:) -> _LazyTieWrappedPtr` and the header's
   `index(_:) -> _LazyTieWrappedPtr` that it calls.
4. **Removed:** the other 19.
5. With only those two retained, these all succeed:
   - `swift build --disable-sandbox --build-tests` (Debug);
   - `swift build --disable-sandbox -c release --target RedBlackTreeCollections`;
   - `swift build --disable-sandbox --build-tests -Xswiftc -DCOMPATIBLE_ATCODER_2025`.
6. Also retained: the `_LazyTieWrappedPtr` alias, the `__purified_` / `__purified_safe_(_: _LazyTieWrappedPtr)`
   resolvers, the success-only `adv_iter(limitedBy:)`'s internal `Result` return, and the Debug
   `band`.
7. The backup directory has been removed.

**Validation**:

- `git diff --check`: clean.
- P4: `swift test --disable-sandbox --skip-build --filter 'RedBlackTree(Set|MultiSet|Dictionary|MultiMap)(IndexValidityXCTests|IndexRangeTests|BidirectionalCollectionTests|CopyOnWriteTests)'`:
  111 tests, 0 failures.
- P1: `swift test --disable-sandbox --skip-build --filter 'InternalTests/boundExpressionIndexValidity'`:
  4 tests in 4 suites passed.
- Release + `_O_UNCHECKED`:
  `swift test --disable-sandbox -c release --traits _O_UNCHECKED --filter 'RedBlackTree(Set|MultiSet|Dictionary|MultiMap)IndexValidityXCTests|RedBlackTreeMappedValuesViewTests|(indexAfterEndIndex|indexBeforeStartIndex|indexOffsetBy[A-Za-z]*|formIndexOffsetBy[A-Za-z]*|staleIndexSubscript|mappedValues[A-Za-z]*|removingAnAlreadyRemovedIndex)_terminates'`.
  - XCTest: 17 (MappedValues), 0 failures. The `IndexValidityXCTests` suites are `#if DEBUG` and
    therefore absent in Release.
  - Swift Testing: 23 tests in 4 Death-test suites passed. The empty `removeFirst` /
    `removeLast` cases are excluded by name.
- After those runs I made only one more edit, a whitespace fix (removing two stray blank lines
  left by the extension removal), and rebuilt Debug successfully.

**Remaining Codex integration check: Release DocC `--warnings-as-errors` fails** with 20 curation
errors such as `'88doh' isn't a disambiguation for 'erase(_:)'`.

- They break down per container (Set, MultiSet, Dictionary, MultiMap) as 4 × `erase(_:)` and
  1 × `distance(from:to:)`.
- They come from the PoC's Index type change itself: the overloads taking `Index` now have
  different precise identifiers, so the hash suffixes changed. None of these corrections causes
  them, since no public signature changed.
- Fixing them means regenerating the hash suffixes in the DocC Topics. That belongs with
  P10 / integration documentation, so I left it.

There is no product-owner decision.

### Result

Pending.

---

## Completed assignment: issue the final success-only Index validation verdict

Independently review the now-complete evidence ledger in `Maintanance/INDEX_POC_VALIDATION.md`,
including Codex's uncommitted final-batch integration after `714252d1`. Issue exactly one verdict:

- `adopt after corrections`
- `adoption blocked by specified evidence`
- `evidence incomplete`

Judge only the success-only Index representation. Do not fold `Comparable`, a nominal public
wrapper, ContainersPreview, the deferred shared Bound DSL bug, `_O_UNCHECKED` empty-removal triage,
or frozen work into the representation verdict. Verify that the P9 complexity note is supported by
the cited implementation shape and that P2's intentional unmapping is consistent with the stated
public contract. Treat missing original command text for already-reviewed normal Release and
`_O_UNCHECKED` runs as a reproducibility/documentation limitation, not automatically as missing
behavioral evidence; say explicitly if it changes your verdict.

If the verdict is `adopt after corrections`, list only the corrections required before integrating
the PoC, separating them from optional or deferred work. If blocked or incomplete, identify the
smallest concrete missing evidence. Keep the result concise enough to serve as the validation's
closing decision record.

### Boundaries

Only `Maintanance/CLAUDE_TASK.md` may be edited. Do not edit source, tests, the validation ledger,
other documentation, Package.swift, or workflows. Do not run broad tests, fix findings, stage,
commit, push, switch branches, or alter Git history. Read-only inspection and a narrow disputed-
claim check are allowed. Run `git diff --check` and inspect `git status --short` at the end.

Record the verdict in the first Result section below, set `Status: Completed`, and tell the user
only `完了` unless a product-owner choice remains.

### Result

2026-10-05, Claude Opus 5.5. **Verdict: `adopt after corrections`.**

**Scope.** The verdict covers the success-only representation on `try/index/1` (`714252d1` plus
Codex's uncommitted ledger integration), in the default configuration: `ALLOW_CROSS_TREE_INDEX`
on, `USE_LAZY_DETACH` off, normal mode, Debug and Release. It does not cover `Comparable`, a
nominal wrapper, ContainersPreview, the shared Bound DSL `limit:` bug, the `_O_UNCHECKED`
empty-removal triage, the `USE_LAZY_DETACH` configuration (unused, commented out), or frozen work.

**Basis.** Every required Quality Checklist property now has positive evidence or a documented
intentional unmapping:

- P1: invalid-Bound coverage restored.
- P2: stale, recycled, movement, MappedValues, detached marking, and memory-safe outliving storage,
  in Debug, Release, narrow `_O_UNCHECKED`, and ASan. The unmapped parts are outside the public
  contract (another tree is unspecified per `UnsafeIndexV3.swift`).
- P3: configuration matrix, including compat Debug and Release as legacy-contract evidence.
- P4: four-container breadth (111 tests, reproduced), plus three Views.
- P7: equality and hashing.
- P8: stale limit, corrected in both overload families.
- P9: complexity, closed by inspection.
- P14: no public `Index` path can reach the old family, by type.

I checked P9 against the code:

- Same-tree purification compares the tie identity, then compares one stored seal with the node's
  `___recycle_count` (`_NodePtrSealing.isUnsealed`): O(1).
- Cross-tree lookup walks the fresh-pool buckets, which is O(1) under the post-CoW invariant.
- At most one `lazyDetach` is created per storage.
- `makeIterator` returns `Tree._PayloadValues`, a raw-pointer `_Obverse4`, so traversal is O(K).

Ledger nuance: "reads the stored seal" should read "compares the stored seal with the node's
recycle count". The cost is unchanged.

None of the evidence shows a deeper contradiction. No required behavior needs a failure value in
the public Index, validity checks stay O(1), and lifetime is held by the existing storage tie.

**Missing command text.** The original command text for the normal Release and `_O_UNCHECKED`
runs is still missing. This does **not** change the verdict: those results were reviewed and the
filters are re-derivable. It is a reproducibility limitation. The integration's own validation run
should record its commands.

**Corrections required before integrating the PoC.** All are local and none changes the
representation.

1. **P6, public surface.**
   - Restore `@_documentation(visibility: internal)` on `UnsafeIndexV3`.
   - Make the new nested `_LazyTiedPtr._NodePtr` non-public (package), or record an explicit owner
     decision to keep it. It is new public surface, and it parallels the frozen `Result._NodePtr`
     item.
2. **P14, dual family.** Remove the old Result-valued overloads that differ from the success-only
   ones only by return type, and that have no remaining caller:
   - the `_LazyTieWrappedPtr` variants of `___index` / `___index_or_nil`;
   - the tree and header `index` / `index_or_nil`;
   - the movement family.

   A disposable `@available(*, unavailable)` build is the mechanical proof that they have no
   caller. Keep the `_LazyTieWrappedPtr` alias and resolver paths that remain genuinely used. Also
   remove or document the unused seal-only `_LazyTieWrap.isValid`.
3. **P13.** Move the two `/// - Complexity` lines below the summary sentences in
   `RedBlackTreeDictionary+Index.swift` and `RedBlackTreeMultiMap+Index.swift`.
4. **P11.** Remove the merge and prototype artifacts:
   - the commented-out old alias and its 「実質V4」 comment block;
   - the duplicated 「過去の状態で封印する」 doc line;
   - the trailing blank lines;
   - the `Package.swift` comment-spacing change;
   - the `/// O(1) ready` notes, or turn them into proper `Complexity` text.
5. **P10.** After integration, update the design records that still describe
   `UnsafeIndexV3 = _LazyTieWrappedPtr`, and close the X1 identity-map and PoC entries.
6. **Re-run after corrections.** Run the four-container P4 filter, the P1 tests, the narrow
   Release + `_O_UNCHECKED` Index filter, and the Release DocC `--warnings-as-errors` build. Record
   the exact commands.

**Optional or deferred** (not required for integration):

- the Debug `.unsafe(tree:rawTag:)` / `.nullptr` non-empty-tree rule (P5), which only needs a
  comment;
- wall-clock A/B timing;
- an ASan run in Release;
- the Bound DSL `limit:` fix and the `_O_UNCHECKED` empty-removal triage, both already deferred;
- `lazyDetach` concurrent first-access, which remains frozen and also exists on develop;
- `Comparable`, the nominal wrapper, and ContainersPreview.

Checks: only this file was edited. `git diff --check` was clean. `git status --short` shows
Codex's ledger plus this file.

### Result

Pending.

---

## Completed assignment: review the final Index PoC evidence gap

Independently review the committed `try/index/1` evidence through `714252d1`. The product owner
wants to finish the overall success-only Index validation before applying the already-confirmed
shared Bound DSL `.advanced(limit:)` fix. Minimize additional work: distinguish evidence required
for the representation decision from cleanup, later API design, frozen work, and defects shared
with `develop`.

Required output:

1. Review the new `P3` compatibility Release evidence: 120 XCTest cases passed with 4 intentional
   skips, followed by 1 Swift Testing case passed. Return `P3 pass`, `P3 fail`, or `P3 unmapped`.
2. Review the new `P4` four-container batch: 111 tests spanning Index validity/ranges,
   bidirectional movement, and CoW across Set, MultiSet, Dictionary, and MultiMap, plus the already
   reviewed Range View evidence. Return `P4 pass`, `P4 fail`, or `P4 unmapped`.
3. Audit the remaining `P2`, `P9`, `P10`, `P11`, and `P13` entries. Classify each as exactly one of:
   `required before adoption verdict`, `correction after verdict`, or `intentionally unmapped`.
4. For every item classified as required, specify the smallest concrete command, inspection, or
   measurement that would close it. Do not request a broad matrix rerun when committed evidence
   already establishes the property.
5. State whether the next Codex step can be a final evidence batch, or whether more than one
   independent batch is genuinely necessary. Do not issue the final adopt/reject verdict yet.

The success-only representation is the leading candidate. A shared/local defect, cleanup item,
documentation drift, `Comparable`, nominal wrappers, and ContainersPreview are not representation
blockers unless you identify a concrete safety, correctness, external-contract, or complexity
failure. The Bound DSL fix and `_O_UNCHECKED` empty-removal triage are deferred until this overall
validation is closed. Permutation compatibility work and the other recorded frozen tasks remain
frozen.

### Boundaries

Only `Maintanance/CLAUDE_TASK.md` may be edited. Do not edit source, tests, the validation ledger,
other documentation, Package.swift, or workflows. Do not fix findings, stage, commit, push, switch
branches, or alter Git history. Prefer committed records and read-only inspection; run only a
narrow command needed to resolve a disputed claim. Run `git diff --check` and inspect
`git status --short` at the end.

Record the review in the first Result section below, set `Status: Completed`, and tell the user
only `完了` unless a product-owner choice remains.

### Result

2026-10-05, Claude Opus 5.5. Read-only review through `714252d1`. The only command I ran was the
P4 reproduction below.

**1. `P3 pass`.** The compatibility Release batch (120 XCTest, 4 intentional skips, 1 Swift
Testing) is configuration evidence for the legacy `UnsafeIndexV2` contract and the shared
resolver. As already classified, it is not direct success-only evidence. Limitation: the ledger
still records no exact command or `--filter` for this run, or for the normal Release and
`_O_UNCHECKED` runs. This is a bookkeeping gap, not a missing property.

**2. `P4 pass`.** I reproduced the batch in Debug at HEAD:

```
swift test --disable-sandbox --skip-build \
  --filter 'RedBlackTree(Set|MultiSet|Dictionary|MultiMap)(IndexValidityXCTests|IndexRangeTests|BidirectionalCollectionTests|CopyOnWriteTests)'
```

It executed 111 tests with 0 failures, matching the ledger. Scope note:
`BidirectionalCollectionTests` exists only for Set and MultiSet. Dictionary and MultiMap
movement is covered through their `IndexValidityXCTests` and `IndexRangeTests`. The Range View
evidence was reviewed previously.

**3–4. Classification of the remaining entries:**

| Item | Class | Reason / smallest closure |
| --- | --- | --- |
| `P2` | `intentionally unmapped` | The required lifetime properties already pass: stale, recycled, movement, MappedValues, detached marking, memory-safe outliving storage; in Debug, Release, narrow `_O_UNCHECKED`, and ASan. What remains is (a) a non-empty unrelated receiver, whose behaviour is documented as unspecified (生成元以外の木での使用は未定義), and (b) the exact internal `.detached` reason. Neither is a public contract |
| `P9` | `required before adoption verdict`, but only the complexity part | Closure is a source-inspection note in the ledger; no benchmark is needed. It must state: <br>(1) same-tree `__purified_` is a tie identity comparison plus one seal read, O(1); <br>(2) cross-tree resolution walks the fresh-pool buckets, O(1) under the single-bucket-after-CoW invariant (`_FreshPool.swift:112`); <br>(3) `index(_:)` builds `_LazyTieWrap` with no allocation per Index; the `lazyDetach` getter creates at most one tie per storage (`UnsafeTreeV2+BufferHeader.swift:157-165`); <br>(4) traversal uses `_Obverse4` raw pointers and never constructs or resolves an Index per element, so K-element traversal stays O(K); <br>(5) `==` / `hash` are O(1) (P7). <br>Real-time A/B measurement is `correction after verdict` (optional): it is not a Checklist gate, and this repository needs interleaved runs plus a machine-code comparison for any wall-clock claim |
| `P10` | `correction after verdict` | Design-record update. It must follow the verdict, as the entry itself says |
| `P11` | `correction after verdict` | Merge-artifact cleanup. Not a quality property |
| `P13` | `correction after verdict` | A DocC abstract regression in two doc comments, shared by every representation. Not a representation property |

**Side note, not a blocker and not new.** Creating the first Index on a shared, immutable
collection mutates the storage header lazily (`lazyDetach`). Concurrent first access from two
threads is therefore the already-frozen 「`lazyDetach`等の並行初期化保証」 item. The develop
representation has it too.

**5. One final evidence batch is enough.** It needs only:
- (a) the P9 complexity inspection note above;
- (b) the exact commands and filters for the normal Release, Release `_O_UNCHECKED`, compatibility
  Release, and P4 runs (copied from the shell history, not re-run).

No further independent batch is needed. After that, the ledger has positive evidence or
documented intentional unmapping for every required property, and the final verdict can be
issued. No adopt/reject verdict is given here.

Checks: only this file was edited. `git diff --check` was clean. `git status --short` shows only
this file.

### Result

Pending.

---

## Completed assignment: independently review the accumulated Index PoC evidence batches

Independently review the committed evidence and corrections on `try/index/1` through
`beba869e`. The evidence ledger is `Maintanance/INDEX_POC_VALIDATION.md`. Preserve a separate
neutral verdict for every batch; do not collapse them into one overall adoption verdict.

Required batch verdicts:

1. `P14`: dual-representation call-site inventory — verify whether any normal public `Index` path
   can resolve to the old Result-valued overload family.
2. `P6`: external public-surface evidence — verify the classification of `UnsafeIndexV3` and
   `_LazyTiedPtr._NodePtr` as externally nameable prototype artifacts.
3. `P2/P3 Release`: review the normal Release pass, the broad `_O_UNCHECKED` scope-contaminated
   failure, and the narrower Index-specific `_O_UNCHECKED` pass.
4. `P3 compatibility Debug`: confirm that the passing compatibility batch tests the separate
   legacy Index contract and is not direct success-only evidence.
5. `P2/P3 ASan`: review the representative 64-test ASan pass and its stated limitations.
6. `P2 outliving storage`: review the new test proving detached marking and safe rejection by a
   live receiver; confirm that the document does not overclaim the exact internal error reason.
7. `P8`: review the stale-limit diagnosis and correction. Confirm that the bug existed in the old
   Result-valued implementation, that `edcf8c46`/`5e41e32b` correct that shared path, and that
   `425c02c3` correctly applies equivalent failure propagation to the success-only overload.
   Include the later `formIndex` backward-direction test committed in `beba869e`.
8. `P4`: review the KeyValue and KeyOnly bounded Range View tests and whether their half-open
   `isElement(at:)` / `isEnd(_:)` expectations match the public contract.

For each item return exactly one of `pass`, `fail`, or `unmapped`, followed by concise evidence and
any scope limitation. Then state whether the current ledger wording should be corrected. Do not
issue a final adopt/reject verdict; remaining breadth, performance, compatibility Release, cleanup,
and documentation work is intentionally unfinished.

### Boundaries

Only `Maintanance/CLAUDE_TASK.md` may be edited. Do not edit source, tests, the validation ledger,
other documentation, Package.swift, or workflows. Do not fix findings, use network access, stage,
commit, push, switch branches, or alter Git history. Read-only inspection is allowed. Run only
narrow tests needed to resolve a disputed claim; do not rerun the whole matrix. Run
`git diff --check` and inspect `git status --short` at the end.

Record the review in the first Result section below, set `Status: Completed`, and tell the user only
`完了` unless a product-owner choice remains.

### Result

2026-10-05, Claude Opus 5.5. Per-batch neutral verdicts are below; there is no adoption verdict.
Inspection covered `try/index/1` through `beba869e`, read-only. I re-ran only the five tests whose
claims I reviewed, in Debug:

- the two StaleLimit exit tests (2 passed);
- the outliving-storage test (1 passed);
- the KeyValue and KeyOnly `isElementAndIsEnd_respectViewBounds` tests (2 passed).

| Batch | Verdict | Evidence / limitation |
| --- | --- | --- |
| **P14** dual representation | `pass` | Every non-Deprecated `_LazyTieWrappedPtr` reference is an old-family internal declaration: `index` / `index_or_nil`, movement, `___index` helpers, `__purified_`, and `band`. No public signature uses it apart from the public alias itself. The type system rules out the feared path: there is no implicit conversion between `_LazyTiedPtr` and `Result`, so a public `-> Index` context cannot select the old overload, and a public `Index` argument cannot enter the old movement family. Limitation: this is a declaration survey, not a compile-time proof. Marking the old family `@available(*, unavailable)` in a disposable experiment would make it mechanical |
| **P6** external surface | `pass`, with a classification correction | An external `swiftc -typecheck` against `.build/out/Products/Debug` accepted `UnsafeIndexV3`, `_LazyTiedPtr._NodePtr`, and `RedBlackTreeIndex`. However, `UnsafeIndexV3` and `_LazyTiedPtr` were already public and nameable on develop (`2796d7c2`). The PoC artifact is therefore (a) the removal of `@_documentation(visibility: internal)`, which changes DocC exposure, not nameability, and (b) the new nested `public typealias _NodePtr`. It mirrors the already-frozen `Result._NodePtr` item. The ledger should say this, not "externally nameable prototype artifacts" for both |
| **P2/P3** Release | normal Release `pass`; narrow `_O_UNCHECKED` `pass`; broad `_O_UNCHECKED` `unmapped` for the PoC | The scope-contamination reasoning is correct: `removeFirst` / `removeLast` on an empty collection are not Index paths, and `-Ounchecked` removes their `precondition`. Two limitations: (1) the ledger gives counts but not the exact `--filter` strings or full commands for either Release batch, so the batches are not reproducible as written; (2) the four "successful exits" are a **develop-side** observation that needs separate triage, because an unchecked empty `removeFirst` / `removeLast` may not be memory-safe. It is not PoC evidence |
| **P3** compat Debug | `pass` (classification confirmed) | In compat mode the containers' `Tree.Index` is `UnsafeIndexV2<Base>` (`UnsafeTreeV2+index+deprecated.swift:11`). It stores its own `_SealedPtr` plus `_TiedRawBuffer`, not `_LazyTiedPtr`. The batch therefore checks the legacy contract and the shared resolver, and is correctly `unmapped` as direct success-only evidence. Compat Release is still not run |
| **P2/P3** ASan | `pass` (scoped) | 64 XCTests with no report. The stated limitations are accurate. The ASan section's "does not cover … Index outliving its storage" is now stale, because the outliving test was later run under ASan |
| **P2** outliving storage | `pass` for the stated narrow property; the wording overclaims | Detached marking is verified, and memory safety holds: the cross-tree path reads only the Index's stored tag and seal, not its freed pointer. But the receiver in the test is **empty**, so `__retrieve_` fails on `tag < initializedCount` (0). With a **non-empty** receiver, the tag and seal of the outliving Index can match a live receiver node (for example tag 0 with seal 0). `deepPurified` would then succeed, and `isElement(at:)` could return `true`. That is the documented unspecified other-tree behaviour (`UnsafeIndexV3.swift`: 生成元以外の木での使用は未定義), not a rejection. "Safe public receiver-based rejection path" holds only for an empty receiver. I traced this in code and did not test it |
| **P8** stale limit | `pass` | `5e41e32b` (the old overload) and `425c02c3` (the success-only overload) both replace `let __l = __purified_(limit).map(\.pointer)` with `__purified_(limit).flatMap { … .success(limit.pointer) }`, which propagates a limit failure before traversal. The old structure confirms the bug was not representation-specific. The forward `index` test and the backward `formIndex` test (`beba869e`) both pass. `form_index`'s double `adv_iter` is retained. **Sibling instance outside the ledger:** the Bound DSL `.advanced(offset, limit:)` path (`UnsafeTreeV2+BoundsExpression.swift:86-90`) still passes `l = evaluate(__l)` unpropagated to `___tree_adv_iter`. A failed limit Bound is therefore ignored there by the same mechanism. It is shared with develop. Its classification needs a user decision, as the stale-limit case did |
| **P4** Range View bounds | `pass` | The KeyValue and KeyOnly half-open expectations match the public docs. The View's `endIndex` can be a base element; `isEnd` is `true` only for the view's end; the base `endIndex` is neither an element of the view nor its end (`RedBlackTreeRangeView+KeyValue.swift:474-480`; API-Matrix-View lines 39-42) |

**Ledger wording corrections:**

1. P6: reclassify as described in the table.
2. P2 outliving: limit "rejected by another receiver" to an empty receiver, and add the non-empty
   receiver case as `unmapped` (unspecified cross-tree acceptance).
3. Record the exact commands and filters for both Release batches.
4. Remove the stale "does not cover outliving" phrase from the ASan section.
5. Move the KeyOnly paragraph, which currently sits inside the ASan section, under P4.
6. Add two triage items:
   - the Bound DSL `.advanced(limit:)` sibling;
   - `_O_UNCHECKED` empty `removeFirst` / `removeLast` (develop-side).

**Product-owner choice:** whether the Bound DSL `limit:` failure should be treated as a bug, like
the stale-limit `limitedBy` case.

Checks: only this file was edited. `git diff --check` was clean. `git status --short` shows only
this file.

### Result

Pending.

---

## Completed assignment: independently review P1 invalid-Bound coverage restoration

Review the uncommitted P1 test-only change and its evidence in
`Maintanance/INDEX_POC_VALIDATION.md`. The four container internal tests replaced their commented
failure-valued public Index assertion with `.index(.nullptr)` on a non-empty container.

Required checks:

1. Confirm the new assertion exercises the lost property (an invalid Index-bound is rejected)
   without reintroducing a public failure-valued Index.
2. Confirm every fixture is non-empty and therefore avoids the P5 `_emptyLazyDetach` same-tie null
   assertion hazard.
3. Check that `.index(.nullptr)` reaches the intended resolver failure path and that a passing
   Boolean assertion cannot be explained by an unrelated process trap.
4. Review the recorded Xcode result: 67 passed, 0 failed, and one `No result`. Confirm or refute that
   `erasingRangeFromAnotherSet_terminatesProcess()` was not compiled because
   `ALLOW_CROSS_TREE_INDEX` is enabled, and that its absence from `swift test list` makes the Xcode
   entry stale discovery metadata rather than a test failure.
5. Run only the four restored internal tests if needed. Do not expand into Release,
   `_O_UNCHECKED`, compatibility, sanitizer, or the next P2 batch.

Return a neutral evidence verdict exactly as one of: `P1 pass`, `P1 fail`, or `P1 unmapped`.
Record concise evidence in the first Result section, set `Status: Completed`, and tell the user only
`完了` unless a product-owner choice remains.

### Boundaries

Only `Maintanance/CLAUDE_TASK.md` may be edited. Do not edit the four tests, validation document,
source, other documentation, Package.swift, or workflows. Do not fix findings, use network access,
stage, commit, push, switch branches, or alter Git history. Read-only inspection and the four-test
Debug run are allowed. Run `git diff --check` and inspect `git status --short` at the end.

### Result

2026-10-05, Claude Opus 5.5. Verdict: `P1 pass`.

1. **The lost property is restored, and no public failure-valued Index is reintroduced.**
   - Each of the four tests now runs `#expect(!x.isValid(.index(.nullptr)))`.
   - `.index(_:)` is the Debug-only `package static` on `RedBlackTreeBoundExpression`.
   - `.nullptr` is the Debug-only `_LazyTieWrap.nullptr` (`_LazyTieWrap.swift:142`).
   - Neither is public. The public Index stays success-only.
2. **The fixtures are non-empty.**
   - Set and MultiSet use `(0..<10)`.
   - Dictionary uses `uniqueKeysWithValues: (0..<10)…`.
   - MultiMap uses `keysWithValues: (0..<10)…`.
   - Only the `UnsafeTreeV2Buffer.empty()` singleton carries `_emptyLazyDetach`
     (`UnsafeTreeV2+Buffer.swift:105`). Non-empty buffers create their own tie on demand
     (`BufferHeader.swift:162`).
   - The synthetic Index therefore never shares the tree's tie, and the P5 hazard is avoided.
3. **The intended failure path is reached.**
   - `isValid(_ bound:)` is the test helper `self[bound] != nil`.
   - Bound evaluation, Debug `.index(let i)`, runs `switch __purified_(i)`
     (`UnsafeTreeV2+BoundsExpression.swift:129`).
   - With different ties, `ALLOW_CROSS_TREE_INDEX` takes the cross-tree branch,
     `__retrieve_(index.tag)`.
   - `tag` evaluates to `.failure(.null)` because `rawValue.trackingTag == .nullptr`. The
     singleton null node is created with `tag: .nullptr` (`unsafe_node.swift:270`).
   - The failure branch sets `ptr = .failure(.null)`, so the subscript yields `nil`.
   - A process trap cannot explain the pass: an in-process Swift Testing crash would fail the run,
     not satisfy `#expect`.
   - Limitation: the Boolean alone does not distinguish "rejected" from "resolved to end". The trace
     above shows that it is the rejection path.
4. **The Xcode `No result` entry is confirmed as stale discovery metadata.**
   - `erasingRangeFromAnotherSet_terminatesProcess()` sits under `#if !ALLOW_CROSS_TREE_INDEX`
     (`RedBlackTreeSet_99_DeathTests.swift:139`), and `ALLOW_CROSS_TREE_INDEX` is active
     (`Package.swift:25`).
   - `swift test list` contains 0 occurrences of it, so it is not compiled. It is not an executed
     failure.
5. **The four-test run passed.**
   - `swift build --disable-sandbox --build-tests` (Debug): succeeded.
   - `swift test --disable-sandbox --skip-build --filter 'InternalTests/boundExpressionIndexValidity'`:
     4 tests in 4 suites passed.
   - Nothing else was run: no Release, no `_O_UNCHECKED`, no compat, no sanitizer, and no P2.

Checks: only this file was edited. `git diff --check` was clean. `git status --short` shows Codex's
four test files and the validation document plus this file.

---

## Completed assignment: agree or disagree with the success-only Index validation posture

The product owner has stated a strong preference to adopt the `try/index/1` success-only Index
representation. Independently review the resulting validation posture now recorded under
`## Product-owner direction` in `Maintanance/INDEX_POC_VALIDATION.md`.

The proposed posture is:

- treat the success-only Index representation as the leading implementation candidate, not one
  equally weighted option in a neutral bake-off;
- treat missing tests, documentation drift, prototype public-surface artifacts, and localized
  defects as correction work unless they expose a deeper contradiction;
- block or reject adoption only on concrete evidence that correctness, memory/Index lifetime,
  external contract, or required complexity cannot satisfy the Quality Checklist without
  abandoning the success-only representation;
- keep `Comparable`, a nominal public wrapper, and ContainersPreview conformance as later,
  separate decisions.

Assess whether this framing is technically coherent, preserves the existing Quality Checklist and
stop conditions, and avoids both confirmation bias and unnecessary reopening of already separated
design questions. Identify any wording that would make a serious defect too easy to classify as a
mere correction.

Return exactly one verdict: `agree with success-only validation posture`, `agree after specified
posture corrections`, or `do not agree with success-only validation posture`. Record concise
reasoning in the first Result section, set `Status: Completed`, and tell the user only `完了` unless
a product-owner choice remains.

### Boundaries

Only `Maintanance/CLAUDE_TASK.md` may be edited. This is a policy/agreement review, not a code
review. Do not inspect or comment on the currently uncommitted P1 test edits, edit the validation
document or other files, run builds/tests, use network access, stage, commit, push, switch branches,
or alter Git history. Read-only inspection of the Quality Checklist and recorded stop conditions is
allowed. Run `git diff --check` and inspect `git status --short` at the end.

### Result

2026-10-05, Claude Opus 5.5. Verdict: `agree after specified posture corrections`.

**What is sound.**
- Making the success-only Index the leading candidate is coherent and legitimate. The owner prefers
  it, the PoC already compiles, and resolver diagnostics stay internal.
- The posture keeps the bar: "Passing this baseline is not adoption approval".
- It keeps all stop conditions.
- It correctly prevents `Comparable`, the nominal wrapper, and ContainersPreview from being
  smuggled in as rejection reasons.

**Where serious defects could be too easily reclassified.** There are three wording problems.

1. **Severity is conflated with remedy.** "localized defects are correction work unless they
   reveal a deeper contradiction" lets the *location* of a defect decide its handling.
   - A use-after-free, an out-of-bounds read, or the acceptance of a stale or recycled Index can sit
     in one function and still be a Quality Checklist §2 failure.
   - "Deeper contradiction" is undefined, so almost anything can be argued to be localized.
2. **The burden of proof is unfalsifiable.** "Rejecting requires concrete evidence that … cannot be
   made to satisfy … without abandoning the representation" asks for proof of impossibility. One
   can always say "it could be fixed". Adoption must instead rest on positive evidence for each
   Checklist property. A gap means `evidence incomplete`, not `adopt after corrections`.
3. **Corrections are not tied to re-verification.** Nothing says that a "correction" counts only
   after it has been re-verified under the same matrix. Without that, a planned fix can be counted
   as if it were evidence.

**Posture corrections** (replacement wording for the three bullets under
`## Product-owner direction`):

- Replace bullet 1 with:
  > Missing tests, documentation drift, and prototype public-surface artifacts are correction work.
  > Any failure of a Quality Checklist property — especially §2 memory safety and Index validity
  > (stale, recycled, detached, cross-tree, outliving storage, `_O_UNCHECKED`) — is a blocking
  > finding regardless of how localized its code is. It stops validation, is recorded before any
  > fix, and counts as resolved only after the fix is re-verified in every configuration where it
  > failed. It may be classified as correctable only if the demonstrated fix keeps the public Index
  > success-only.
- Replace bullet 2 with:
  > Adoption requires positive evidence for each applicable Quality Checklist property. If a
  > property fails and no fix within the success-only representation has been demonstrated, the
  > verdict is `adoption blocked by specified evidence`. Unmeasured or unmapped properties give
  > `evidence incomplete`. Neither outcome requires proving that a fix is impossible.
- Add a definition after bullet 2:
  > A deeper contradiction exists when any of the following holds:
  > - a required observable behavior can only be expressed by a failure value inside the public
  >   Index;
  > - validity checking needs more than O(1) per access, or adds per-element work to traversal;
  > - Index lifetime cannot be guaranteed without a different storage tie.
- Extend bullet 3 symmetrically:
  > …they are not reasons by themselves to reject this representation, nor evidence for adopting it.

**Process guard against confirmation bias** (no posture change needed beyond the above):

- Claude's independent tasks should produce per-property evidence: commands, configurations,
  counts, and stderr reasons. Each task should use a neutral pass / fail / unmapped outcome, not
  an adopt/block verdict.
- The adopt/block judgment should be made only at step 6, from that evidence.

**Residual, outside the posture.** `## Validation order` still lists step 1 (inventory review) as
pending, although it is done. Step 4 still includes "MappedValues View", which step 2 already
moved to first place. Both are wording-only fixes.

Checks: only this file was edited. I did not inspect the uncommitted P1 test edits.
`git diff --check` was clean. `git status --short` shows Codex's four test files plus this one.

---

## Completed assignment: independently review the merged Index PoC issue inventory

Review the merged `try/index/1` branch at `6bdcfecd` against `develop/misc/48` at `2796d7c2`.
Codex has created `Maintanance/INDEX_POC_VALIDATION.md` as an initial issue inventory. This is the
first validation gate after the user explicitly restarted work on the PoC.

The product owner has now stated a strong preference to adopt this success-only Index approach.
Treat it as the leading candidate. Do not lower the quality bar, but distinguish correctable
prototype gaps from evidence that would actually invalidate the representation.

Independently inspect the 24-path PoC-specific diff and the Quality Checklist. For each `P1`–`P12`
item, determine whether it is supported, overstated, understated, duplicated, or missing a critical
condition. Look especially for correctness or lifetime risks that compilation and the 69 passing
BoundExpression tests would not expose.

Required questions:

1. Is the develop-to-HEAD comparison the correct current PoC scope after the merge?
2. Does any source difference constitute an already-demonstrable defect rather than merely an
   unverified requirement?
3. Does the proposed representative pair (`RedBlackTreeSet` and
   `RedBlackTreeKeyValueRangeView`) exercise the right first boundary, or should another View be
   selected?
4. Are the stop conditions sufficient to prevent accidental redesign or premature horizontal
   expansion?
5. What is the smallest next executable validation batch after the inventory is corrected?

Return exactly one verdict: `approve initial PoC issue inventory`, `approve after specified
inventory corrections`, or `issue inventory misses a blocking product decision`. Record concise
evidence in the first Result section, set `Status: Completed`, and tell the user only `完了` unless
a product-owner choice remains.

### Boundaries

Only `Maintanance/CLAUDE_TASK.md` may be edited. Do not edit the inventory, source, tests, other
documentation, Package.swift, or workflows. Do not fix findings, run broad test matrices or
performance measurements, use network access, stage, commit, push, switch branches, or alter Git
history. Read-only repository inspection and narrow compile/test inspection of existing results are
allowed. Run `git diff --check` and inspect `git status --short` at the end.

### Result

2026-10-05, Claude Opus 5.5. Verdict: `approve after specified inventory corrections`.

No product-owner decision blocks the next step: P12 already keeps the nominal type, Comparable,
and ContainersPreview separate. Evidence came from a read-only reading of
`git diff 2796d7c2..HEAD` (on `try/index/1` at `6bdcfecd`, whose parents are `1b126ba3` and
`2796d7c2`). Nothing was built or run.

**Q1. Scope.** Correct. `merge-base(2796d7c2, HEAD)` = `2796d7c2`, so the two-dot diff is exactly
the net PoC delta on top of current develop. Two things are missing from the scope:

- The 10-04 merge (`1b126ba3`) and the new merge (`6bdcfecd`) resolutions are folded into that net
  delta. The X1 stop condition ("a conflict resolution has no recorded intent") is not carried
  over.
- The X1 identity map is still anchored at `aecbcddf` / `1b126ba3`. It should be recorded as
  superseded or re-anchored for this validation.

**Q2. Demonstrable defects.** I found none in production behavior. Two concrete problems are
visible in the diff and are missing or understated:

- **P13 (new, documentation regression).** In `RedBlackTreeDictionary+Index.swift` and
  `RedBlackTreeMultiMap+Index.swift`, `/// - Complexity: O( log count )` is inserted above the
  existing summary line ("Returns the index of the element with the given key."). The callout
  therefore becomes the first doc line and displaces the DocC abstract. This is a PoC artifact.
  Classify it with P11 as a cleanup item, but note that it is user-visible.
- **P14 (new, dual representation).** The old-type overloads still exist alongside the new ones,
  differing only in return type: `___index` / `___index_or_nil` returning `_LazyTieWrappedPtr` in
  the four containers, plus `UnsafeTreeV2.index(_:)`, the header `index(_:)`, and the
  form-/adv-iter family. Sources contain 31 non-Deprecated `_LazyTieWrappedPtr` references.
  - Overload resolution by return type currently selects the right one silently, so this is not a
    failure today. It is, however, the main place where an old-representation path can survive
    unnoticed.
  - Add a gate: list which call sites still resolve to `_LazyTieWrappedPtr`, and confirm that none
    is reachable from a public `Index`-typed API.
  - The new `_LazyTieWrap.isValid` (seal-only, `purified` without a tree) has no Sources consumer.
    Note that it does not reflect cross-tree / CoW resolution.

**Corrections to the existing items:**

- **P1.** Understated remedy. A Debug-only replacement already exists: `.index(.nullptr)` on a
  non-empty container. The synthetic Index takes the cross-tree path,
  `__retrieve_(tag = .failure(.null))`, and fails, so `isValid` returns `false`. Restore the four
  assertions this way. A public failure value is not needed.
- **P5.** Understated, and missing a critical condition. The synthetic `.nullptr` uses
  `_emptyLazyDetach`, and every storage-less (empty) tree shares that same tie
  (`UnsafeTreeV2+Buffer.swift:105`). On an empty tree, `__isSameLazyDetach` is therefore `true`,
  so the same-tree path `index.sealed.purified` runs on the nullptr sentinel and hits
  `assert(!pointer.___is_null)`. The intended `SealError` failure does not occur.
  - An exit test that only expects `.failure` can pass for the wrong reason.
  - Require any test built from `_LazyTieWrap.unsafe(tree:rawTag:)` or `.nullptr` to use a
    non-empty tree, or to assert the `SealError` message.
- **P7.** Overstated. This can be closed from code reading.
  - Synthesized `Hashable` / `Equatable` on `_NodePtrSealing` both cover pointer, seal, and
    `trackingTag` (the last only `#if !USE_LAZY_DETACH`, and derived from pointer). The old custom
    hash covered pointer and seal, so it was coarser but consistent.
  - `_LazyTieWrap.hash` still omits `lazyDetach` while `==` includes its identity. This is
    consistent, because the hash is coarser than equality.
  - Both are O(1). Downgrade P7 to "verified by inspection; keep one regression test".
- **P8.** Also add a check that `form_index(limitedBy:)` keeps develop's deliberate double
  `adv_iter` call (cache-line comment) unchanged, so that P9 timing is comparable.
- **P2 / P3 / P4 / P6 / P9 / P10 / P11 / P12.** Supported as written. For P11, also list the
  trailing blank lines in `_LazyTie.swift` and the duplicated `/// 過去の状態で封印する` doc line in
  `_NodePtrSealing.swift`.

**Q3. Representative pair.** Keep `RedBlackTreeSet`, but use `RedBlackTreeMappedValuesView`
instead of, or in addition to, KeyValue.

- Since `211ca2fc`, the MappedValues single-Index operations rely only on `__purified_` of the
  Index type: no membership check, O(1), and CoW migration inside the setter and `swapAt`. That
  makes them the most sensitive boundary for a change of Index representation.
- KeyValue can follow, because it shares the same tree path but adds range checks that can hide
  resolver faults.

**Q4. Stop conditions.** Add the following:

- (a) a merge conflict resolution, in either merge, without recorded intent;
- (b) any public `Index`-typed path resolving to a `_LazyTieWrappedPtr` overload (P14);
- (c) a Debug `assert` firing where a `SealError` trap was expected. Exit tests must check the
  `SealError` reason, not only `.failure` (P5).

With these added, the list prevents redesign and premature expansion.

**Q5. Smallest next executable batch.**

1. Correct the inventory as above.
2. **Test-only change:** restore the four P1 assertions via `.index(.nullptr)` on non-empty
   containers.
3. On the branch, Debug only, run the existing narrow suites for the pair:
   - the Set Index-validity, CoW, and Death tests;
   - `RedBlackTreeMappedValuesViewTests`;
   - the Dictionary MappedValues Death tests.
4. Record the commands, counts, and any stderr reasons.
5. Run Release and `_O_UNCHECKED` only after this passes. Stop on the first signal.

Checks: only this file was edited. `git diff --check` was clean. `git status --short` shows Codex's
staged `INDEX_POC_VALIDATION.md` plus this file.

---

## Completed assignment: audit the remaining RedBlackTree backlog classification

Independently audit the current RedBlackTree tracking documents after the two test-responsibility
reviews. The user's temporary operating policy is that every remaining RedBlackTree item must now
be exactly one of:

1. Index work (including Index-dependent API, tests, performance, and documentation);
2. documentation-only work;
3. explicitly frozen until the user requests restart or makes the required product decision.

Inspect at least `Maintanance/PROGRESS_OVERVIEW.md`,
`Maintanance/RED_BLACK_TREE_REMAINING_TASKS.md`, `Tests/TESTING.md`, and the unchecked items in the
RedBlackTree API matrices. Identify any item whose current wording still appears to authorize an
unfrozen non-Index implementation task, any duplicate with inconsistent status, and any completed
item still presented as pending.

Pay particular attention to public-surface shrinking, Debug/Release protocol differences,
Memoize/external-consumer migration, ContainersPreview tracking, cross-tree/range/unsafeAddress
tests, and dead or unwired code. Do not decide Comparable, restart `try/index/1`, or reinterpret a
frozen item as active merely because it remains unchecked.

Return a compact table with the item, correct class (`Index`, `documentation`, or `frozen`), and the
exact tracking wording/status correction needed. If the documents already satisfy the policy, say
so explicitly. This is a tracking audit, not authorization to implement any item.

Return exactly one verdict: `backlog classification is consistent`, `classification needs the
specified documentation corrections`, or `classification needs product-owner decision`. Record
the findings in the first Result section, set `Status: Completed`, and tell the user only `完了`
unless a product-owner choice remains.

### Boundaries

Only `Maintanance/CLAUDE_TASK.md` may be edited. Do not edit source, tests, API matrices, or other
documentation. Do not inspect `try/index/1`, restart frozen work, build/test, use network access,
stage, commit, push, switch branches, or alter Git history. Read-only repository inspection is
allowed. Run `git diff --check` and inspect `git status --short` at the end.

### Result

2026-10-05, Claude Opus 5.5. Verdict: `classification needs the specified documentation corrections`.

No product-owner decision is required. Every item already fits one of the three classes. The
problem is wording: a few entries still read as active, non-Index implementation work, and two
pairs are duplicated with inconsistent status. Read-only inspection covered
`PROGRESS_OVERVIEW.md`, `RED_BLACK_TREE_REMAINING_TASKS.md`, `Tests/TESTING.md`, `API-Matrix.md`,
and `API-Matrix-View.md`.

#### Items that need corrections

| # | Item (location) | Class | Correction |
| --- | --- | --- | --- |
| 1 | 「意図しない`public`をpackage/internal/TestSupportへ縮小」 (PROGRESS:153) and 「source compatibilityを意図する公開API以外を…縮小する」 (RED:523) | Index / frozen | Both read as an open, active shrink task. The independent batches are exhausted. The remainder falls into four groups: <br>• Index-binding (Index); <br>• G4 / G3 SignedDistance (deferred public-witness design); <br>• G5 / G6 / Memoize / Balanced / `Result` overloads / `_NodePtr` (frozen); <br>• BENCHMARK hooks (Index-returning hooks = Index, the rest frozen). <br>Append: 「（2026-10-05時点で独立縮小batchは無し。残りはIndex依存または凍結clusterのみ）」 |
| 2 | 「DebugとReleaseで公開protocol適合集合が変わる箇所を解消」 (PROGRESS:154) | Index + frozen | Replace 「いずれも保留中のcluster」 with 「Balanced群は凍結（executable API Matrix方針）、Debug比較群はIndex依存」 |
| 3 | 「TestCode専用の宣言と実験経路をproduction targetから分離する」 (RED:524) | frozen / Index | Still unfrozen wording, although B4-c is done. The only remainders are Balanced (Debug-only executable matrix → frozen) and the Debug Comparable group (Index). Append the same class note, or check it off and point to those clusters |
| 4 | 「B4-b: Memoize群は外部consumer 2件の移行後に…判断する」 (RED:522) | frozen | Append 「（外部consumer移行まで凍結）」. The wording is conditional, but it does not say frozen |
| 5 | 「Fで決定した`index(inserting:)`の提供範囲を実装・テストへ反映する」 and 「…`erase(exactly:)`…」 (RED:556-557) | Index | These duplicate RED:530-531 with stale wording. The scope was already decided (all four containers, plus naming) by review, not by F. Remove these two lines, or replace them with 「→ 上記K項目（530-531）へ統合」 |
| 6 | `index(inserting:)` / `erase(exactly:)` expansion (PROGRESS:180-181) | Index | The RED copies say 「Kで」, but the PROGRESS copies do not, so they read as immediately actionable. Prefix both with 「Kで（Index移行後）」 |
| 7 | 優先事項: 「現在の確認地点は、公開範囲の縮小と…Index契約の最終判断である」 (TESTING.md:17-18) | Index | Public-surface shrinking is no longer an active checkpoint. Reword to 「独立した公開範囲の縮小は区切り済み。現在の確認地点は…Index契約の最終判断である」 |
| 8 | 判断待ち: 「内部テスト層の区分、および生木テストと変更コストの均衡。」 (TESTING.md:83) | documentation (closed) | An unclassified leftover. Both test-responsibility reviews are now recorded in the bullets that follow it. Remove it, or mark it 「（TestSupport/DebugAdditionals・UnsafeNode/RawBuffer整理で完了）」 |
| 9 | 判断待ち: 「未結線コードを削除するかテストするか…」 (TESTING.md:102-104) | frozen | Stale. The decision is now staged deletion, decided item by item by the user. Reword to match PROGRESS:224 / RED:571: 「段階的に削除（個々の削除はユーザーが決定し、再開指示まで凍結）」 |
| 10 | 「公開面の監査・縮小は主経路A・Bで先に行う」 (RED, first bullet of 主経路と並行できる完成前の整理) | — | Minor. Since A and B are done, change 「先に行う」 to 「主経路A・Bで実施済み」 |

#### Already consistent; no change needed

- **Index:**
  - ContainersPreview / Comparable tracking (PROGRESS:167, RED:526 = D);
  - PROGRESS:170-179 and RED:529-540 (F–L, gate items 544-552);
  - the 「Kで処理するIndex依存タスク」 tests: cross-tree re-audit, erase range-sanitize test, and
    the MultiMap `unsafeAddress` Release check (RED:559-561);
  - the API Matrix TODOs (`index(inserting:)` and `erase(exactly:)` for MultiSet and Dictionary),
    which the legend defines as 採用済みで未実装.
- **Frozen, already labelled:**
  - the `try/index/1` PoC (PROGRESS:172, RED:528 = E);
  - `Result` overloads and `_NodePtr` (PROGRESS:221);
  - dead code (PROGRESS:224, RED:571);
  - Permutation compat (PROGRESS:227; not RedBlackTree);
  - OptionalArray / BareArray audits (PROGRESS:188-189; not RedBlackTree);
  - the 保留・完成を止めない追加検証 list (PROGRESS:233-239);
  - the TestSupport / DebugAdditionals frozen groups and the RawBufferHeadFixture alignment note
    (TESTING.md).
- **Completed items presented as pending:** none, other than #8 (and #5, which is a stale-wording
  duplicate).

This audit authorizes no implementation.

Checks: only this file was edited. `git diff --check` was clean. `git status --short` shows only
`Maintanance/CLAUDE_TASK.md`.

---

## Completed assignment: repair the earlier `develop/misc/48` merge into `try/index/1`

The branch previously carried a Claude-reviewed merge-repair pass. The full pre-rotation task text
was superseded by the incoming current task log; this summary preserves the branch-specific result:

- The failureless public Index prototype was retained rather than reverted to the incoming
  `Result` representation.
- View conversion helpers and the active `_LazyTiedPtr` iterator paths were repaired for the moved
  source layout while retaining explicit `SealError` diagnostics and the intentional double
  `adv_iter` cache-line behavior.
- Relocated internal tests that attempted to construct failure-valued Index instances were disabled
  consistently with the prototype's earlier decision.
- Debug build/tests and a Release RedBlackTreeCollections build passed in that repair pass.
- Release tests, ASan, compatibility mode, and the full suite were not run. The invalid-Index bound
  coverage replacement remained a product-design question and was not guessed.

---

## Completed assignment: define the UnsafeNode / RawBuffer test-layer responsibilities

Take primary ownership of the remaining RedBlackTree test-organization review. Independently inspect
the UnsafeNode reference-fixture tests, RawBuffer/UnsafeTreeV2 single-layer tests, and the
UnsafeNode-versus-RawBuffer cross-check introduced on 2026-10-01. Determine what distinct defect
class each layer detects and whether the current intentional overlap is justified.

At minimum, trace these areas and their actual helpers/call sites:

- `Tests/RedBlackTreeFixture/UnsafeNodeReferenceFixture.swift`;
- `RawBufferHeadFixture` and `UnsafeNodeRawBufferCrossCheckTests` under the current
  `Tests/RedBlackTreeTests/UnsafeTreeV2/Instance/` organization;
- the existing `MemoryLayoutTests`, `UnsafeNodeMemoryLayoutTests`, `BucketAllocatorTests`, and their
  `checkXxx` helpers or payload-type matrices;
- the current records in `Tests/TESTING.md` and `Tests/TESTING_REFERENCE.md`.

Answer:

1. What independently computed fact does each test layer establish?
2. Would consolidating the duplicated helper logic or payload matrices weaken fault independence?
3. Which duplication is deliberate verification redundancy, and which—if any—is merely accidental?
4. Is any code move, helper merge, or new test required now?
5. Can this item be closed through documentation alone so the RedBlackTree work remains limited to
   Index work, documentation, and explicitly frozen items?

Prefer preserving independent calculation paths when sharing would allow one defect to make both
sides agree incorrectly. Do not treat fewer lines or fewer fixtures as an objective by itself.

Return exactly one verdict: `retain independent test layers`, `consolidate specified test support`,
or `test-layer responsibility needs product-owner decision`. Record concise evidence and a concrete
remaining-work recommendation in the first Result section, set `Status: Completed`, and tell the
user only `完了` unless a product-owner choice remains.

### Boundaries

Only `Maintanance/CLAUDE_TASK.md` may be edited. Do not edit, move, merge, rename, or delete tests,
fixtures, sources, or other documentation. Do not inspect `try/index/1`, restart frozen work,
build/test, use network access, stage, commit, push, switch branches, or alter Git history.
Read-only repository inspection is allowed. Run `git diff --check` and inspect
`git status --short` at the end.

### Result

2026-10-05, Claude Opus 5.5. Verdict: `retain independent test layers`.

I inspected the test files and the production layout code read-only. Nothing was built or run.

#### 1. What each layer establishes independently

| Layer | Expected value comes from | Defect class detected |
| --- | --- | --- |
| `MemoryLayoutTests.checkMemoryLayout` | Arithmetic local to the test (`nodeStride + payload.stride`, `alignedUp`, `max(align)`) | `MemoryLayout<P>._pairLayout` (production `_MemoryLayout.init`, a bit-mask formula) and `__value_(as:)` placement wrong for one payload type |
| `UnsafeNodeMemoryLayoutTests.checkMemoryLayout` | The same kind of test-local arithmetic | `_advanced(with:count:)` ±1 movement and `__value_(as:)` address/alignment in the UnsafeNode layer |
| `BucketAllocatorTests.checkHeadAllocationSize` | Byte-ownership counting over the whole allocation (header / end_ptr / nodes / payloads) | Overlap, gaps, or out-of-bounds placement in `_headAllocationSize` + `start` + `_BucketAccessor`. No other layer catches this |
| `BucketMemoryLayoutTests` | Agreement between queue, accessor, and traverser | Two of the three access paths using different strides |
| `UnsafeNodeRawBufferLayoutAgreementTests` (2026-10-04) | Production reference functions against `_BucketAllocator` (`_referenceAlignment`/`_referenceStride`/`_referenceAllocationByteCount(prefix:)`/`_referenceFirstNode` vs `pairLayout`/`_allocationSize(prefix:)`/`start`), with prefixes 0, 1, and 3 bucket strides | The two production calculators diverging. `_referenceStride` rounds by division, `_MemoryLayout` by bit mask, and the two are written separately |
| `UnsafeNodeRawBufferCrossCheckTests` + both fixtures | `UnsafeNodeReferenceFixture` (`_advanced`) against `RawBufferHeadFixture` (`_BucketAccessor[i]`) | Per-element node offsets diverging at capacities 1, 2, 3, and 16 across 10 payload types, with element counts beyond 2 |

#### 2. Would consolidating weaken fault independence?

Yes.
- Each single-layer test computes its expected value without calling the code under test.
- If those expectations were moved into a shared helper, or into one of the fixtures, then a defect
  in that shared code would make both sides agree incorrectly. For example, if the "expected" side
  started using `_referenceStride`, a bug there would be invisible.
- The fixtures exist to reach the two production paths, not to provide expectations. Keeping them
  separate from the test-local arithmetic is the point.

#### 3. Deliberate redundancy versus accidental duplication

- **Deliberate:**
  - The two groups use different payload matrices (single-layer tests vs. the 10-type cross-check
    matrix).
  - Each layer computes the same layout fact in its own way.
  - `__value_(as:)` is used on both sides of the cross-check. This is acceptable because
    `MemoryLayoutTests` and `UnsafeNodeMemoryLayoutTests` verify `__value_` independently against
    test-computed addresses.
- **Accidental but harmless:**
  - `CrossCheck.testPairStrideMatchesAcrossLayers` asserts the same pair as
    `LayoutAgreementTests` (`_referenceStride` vs `pairLayout.stride`), just over a different type
    matrix. It adds coverage breadth, not an independent calculation path.
- **Fixture call form differs from production:**
  - `RawBufferHeadFixture` and `BucketAllocatorTests` call
    `start(storage:payloadOrPairAlignment: MemoryLayout<P>.alignment)`.
  - The production call sites (`_BucketAccessor`, `_BucketQueue`, `_BucketTraverser`) pass
    `pairLayout.alignment`.
  - The results are identical today. `start` branches only on whether the argument is at most the
    node alignment, and `max(node, payload)` falls in the same branch as `payload`.
  - However, the fixture is documented as measuring the actual layout. If `start` ever treats these
    two arguments differently, the fixture would silently stop measuring the production path.

#### 4. Is any move, merge, or new test needed now?

No.

#### 5. Can this item close through documentation alone?

Yes. The recommended documentation is:

- In `Tests/TESTING.md`, close the open item (line 86) by recording the layer → defect-class table
  above, and the rule that test-local expected arithmetic must not be shared with fixtures or
  production helpers.
- Optionally note the two minor items:
  - the duplicated stride assertion, kept for breadth;
  - the alignment-argument difference between `RawBufferHeadFixture` and production.
- If Codex wants zero ambiguity, the second item has an alternative: a one-line future fixture
  change to pass `pairLayout.alignment`. That is a frozen, optional follow-up, not required work.

With this, the RedBlackTree work stays limited to Index work, documentation, and explicitly frozen
items.

Checks: only this file was edited. `git diff --check` was clean. `git status --short` shows only
`Maintanance/CLAUDE_TASK.md`.

---

## Completed assignment: classify `RedBlackTreeTestSupport` and `DebugAdditionals` responsibilities

Take primary ownership of the test-side responsibility review. Independently inspect
`Tests/RedBlackTreeTests/RedBlackTreeTestSupport/` and
`Tests/RedBlackTreeTests/DebugAdditionals/`, including their actual references from the test suite.
The goal is to leave the RedBlackTree area, for now, with only Index work, documentation work, and
explicitly frozen items. This assignment is classification and recommendation only; do not move or
delete code.

Classify the relevant files or coherent file groups into these three roles:

1. executable reusable infrastructure used by automated tests;
2. human-facing diagnostics or visualization support;
3. disabled, historical, transitional, or otherwise frozen experiments.

Then answer:

- What is the durable responsibility boundary between `RedBlackTreeTestSupport` and
  `DebugAdditionals`?
- Which current items are clearly in the correct location?
- Which items cross that boundary or have ambiguous ownership?
- Which disabled or historical groups should simply be marked frozen rather than moved or deleted?
- After applying that classification, does any concrete unfrozen implementation task remain in this
  area, or can it be reduced to documentation plus frozen follow-ups?

Use actual declarations and call sites as evidence. Existing notes in `Tests/TESTING_REFERENCE.md`
and `Tests/RedBlackTreeFixture/Fixtures.md` are inputs, not binding conclusions. A preliminary Codex
scan noticed active shared fixtures/assertions in `RedBlackTreeTestSupport`, active dump/Graphviz
helpers in `DebugAdditionals`, and several `#if false` or `#if DEBUG && false` clusters; verify or
correct that independently rather than assuming it is complete.

Return exactly one verdict: `approve responsibility boundary`, `approve after specified
reclassification`, or `responsibility boundary needs product-owner decision`. Record a concise
file/group classification and the resulting remaining-work recommendation in the Result section,
set `Status: Completed`, and tell the user only `完了` unless a product-owner choice remains.

### Boundaries

Only `Maintanance/CLAUDE_TASK.md` may be edited. Do not move, rename, delete, or edit test/source
files or other documentation. Do not inspect `try/index/1`, restart any frozen audit, build/test,
use network access, stage, commit, push, switch branches, or alter Git history. Read-only repository
inspection is allowed. Run `git diff --check` and inspect `git status --short` at the end.

### Result

2026-10-05, Claude Opus 5.5. Verdict: `approve after specified reclassification`.

**Method.** Read-only. I read every file under `Tests/RedBlackTreeTests/RedBlackTreeTestSupport/`
(13 files) and `Tests/RedBlackTreeTests/DebugAdditionals/` (15 files), together with their
compile guards. For every distinctive symbol I searched for call sites across `Tests`. Some
names are generic (`.value`, `.index`, `lower`/`upper`), and I could not resolve those by text
search alone, so this report states only uses that I actually found. I did not compile anything.

#### Classification

| File / group | Guard | Role | Evidence (call sites) |
| --- | --- | --- | --- |
| TestSupport: `RedBlackTreeTestCase` | DEBUG blocks inside | 1 | Base class of 125+ XCTests. `PointerRedBlackTreeTestCase` is used by `BufferHeaderTests` and `UnsafeNodeTests`. The `RedBlackTreePair(key:value:)` helper is used here |
| TestSupport: `RedBlackTree{Set,MultiSet,Dictionary,MultiMap}+Test(ing)` | `DEBUG && !COMPAT` | 1 | `___tree_invariant(_for_fuzz)` is used by the four `_98_FuzzTests`. `_copyCount` is used by CoW, removal, and compat tests. `assertEquiv` is used by `Set_98_SetAlgebraStressTests` |
| TestSupport: `RedBlackTreeFixture`, `SplitMix64`, `DeathTestSignal`, `KeyValueComparer+Tuple`, `RedBlackTreePair+Testing`, `UnsafeIndexV3Range+Testing` | various | 1 | `RawBufferHeadFixture` and `UnsafeNodeRawBufferCrossCheckTests` (fixture); the four FuzzTests (RNG); `expectedSwiftTrapSignal` (11 files); `KeyValueComparerTests` (tuple payload); the Range View and comparator tests (`.lower`/`.upper`) |
| TestSupport: `FixtureAtCoder2025Support` | `DEBUG && COMPAT` | 1 | `___node_positions` and `___is_garbaged` are used by the four `*AtCoder2025CompatibilityTests` |
| TestSupport: `_NodePtr_.swift` | `#if false` plus an active tail | **3 + 1 mixed** | Lines 4–17 (`_TrackingTag.offset`) are disabled. The active `_TrackingTag.index` after `#endif` has no consumer I could resolve |
| DebugAdditionals: `UnsafeTreeV2+Dump`, `UnsafeTreeV2+GraphvizDebug`, `unsafe_node+dump` | DEBUG | 2 | No test call sites. They are reached only by a human from the debugger or from ad-hoc code. `dumpNode` is used only by `Dump` |
| DebugAdditionals: `_LazyTieWrap+Debug` (`Result.value: _TrackingTag`) | DEBUG | **1, misplaced** | Used by `*_98_IndexValidityXCTests` (`Index.unsafe(…).value`) |
| DebugAdditionals: `unsafe_node+debug` (`UnsafeMutablePointer<UnsafeNode>.index`) | DEBUG | **1, misplaced** | Used by `___RedBlackTreeContainerTests_unsafe.swift:211` (`tree.__root.index`) |
| DebugAdditionals: `ThreeWay+Old/` (3 files) | DEBUG, compiled | **3, but exercised** | Comments say 資料的に残している / 期待したほどじゃなかった. The only consumer is `RedBlackTreeInternal_98_CoverageTests`, which covers `___default_three_way_comparator`. The other `__lazy_synth_three_way_comparator` hits are separate same-named declarations in other targets and production |
| DebugAdditionals: `UnsafeTreeV2+Testing` (tag-based `__left_(_:)` etc.), `RedBlackTreeDebugFixture` | DEBUG, compiled | **3 (orphaned)** | Their only consumer I found is `RedBlackTreeSet+UnsafeTreeDebug.swift`, which is `#if DEBUG && false` |
| DebugAdditionals: `TransitionFromLegacy/` (3 files), `RedBlackTreeSet+UnsafeTreeDebug`, `___Node.swift` | `DEBUG && false` / `false` | 3 | Disabled. `___Node` is one of the three deliberately kept same-named `___Node`s (user decision not to unify) |

#### Answers

- **The durable boundary is set by purpose, not by mechanism.** Both directories use `#if DEBUG`
  plus `@testable` extensions on internals, so that cannot be the dividing line.
  - `RedBlackTreeTestSupport` holds code that an automated test calls: fixtures, invariants and
    assertions, base classes, the RNG, signal constants, test-only initializers, and accessors.
  - `DebugAdditionals` holds human-facing diagnostics (dump, Graphviz) and frozen reference or
    transition code.
- **Correctly located:**
  - all of TestSupport except `_NodePtr_.swift`;
  - Dump, Graphviz, and `unsafe_node+dump` in DebugAdditionals;
  - the disabled transition groups.
- **Crossing the boundary:**
  - `_LazyTieWrap+Debug` and `unsafe_node+debug` are active test infrastructure, so they belong in
    TestSupport.
  - `_NodePtr_.swift` mixes a frozen block with an active extension.
  - `ThreeWay+Old` is frozen reference code that is still compiled and kept alive only by a
    coverage test. It stays where it is, but it should be labelled as frozen, not as
    infrastructure.
- **Mark frozen; do not move or delete:**
  - `TransitionFromLegacy/`;
  - `RedBlackTreeSet+UnsafeTreeDebug` together with its orphaned helpers `UnsafeTreeV2+Testing`
    and `RedBlackTreeDebugFixture`;
  - `___Node.swift`;
  - `ThreeWay+Old/`;
  - the `#if false` block in `_NodePtr_.swift`.

  Removing any of these touches same-name / era history, which belongs to the user.

#### Remaining work

No unfrozen implementation task remains in this area.

- **Documentation.** Record the purpose-based boundary and the frozen list above, for example in
  `Fixtures.md` or `TESTING.md`. This is Codex's domain.
- **Optional mechanical follow-up (tiny, not required).** Move `_LazyTieWrap+Debug.swift` and
  `unsafe_node+debug.swift` into TestSupport. Either do the move, or record them as documented
  exceptions; nothing else in the area needs to change.
- **Not decided by this review.** If anyone wants the orphaned `UnsafeTreeV2+Testing` or
  `RedBlackTreeDebugFixture` removed, that is a separate user decision. They may be needed again
  if the disabled debug file is revived.

Checks: only this file was edited. `git diff --check` was clean. `git status --short` shows Codex's
files plus this one.

---

## Completed assignment: review the package-wide `AcCollections` facade

Independently review the current uncommitted facade change. The product decision is fixed:
`AcCollections` re-exports every current collection module, and a module is removed from the facade
later only if it is confirmed not to meet the package's quality requirements.

Expected normal-mode facade:

- `RedBlackTreeCollections`
- `PermutationModule`
- `OptionalArrayModule`
- `BareArrayModule`

AtCoder 2025 compatibility mode additionally re-exports the legacy `RedBlackTreeModule` shim.

### Required review

1. Verify `Package.swift` dependencies and `Sources/AcCollections/AcCollections.swift` implement
   exactly the expected normal and compatibility surfaces without redundant or missing imports.
2. Verify `AcCollectionsTests` proves reachability through `import AcCollections` alone for all four
   defining modules. Check that the sample operations are valid public uses and not made visible by
   another explicit test import.
3. Review both new DocC module pages for factual accuracy, module ownership, compatibility wording,
   and unsupported guarantees.
4. Check `PROGRESS_OVERVIEW.md` and `Tests/TESTING.md` accurately record the decision without
   claiming the unfinished OptionalArray/BareArray quality audits are complete.
5. Run the `AcCollectionsTests` target and a normal build. If practical within the existing project
   setup, also check that both DocC catalogs are recognized; do not expand into a full documentation
   audit.

Return exactly one verdict: `approve all-module AcCollections facade`, `approve after specified
corrections`, or `reject all-module AcCollections facade`. Record concise evidence in `### Result`,
set `Status: Completed`, and tell the user only `完了` unless a product-owner choice remains.

### Boundaries

Only `Maintanance/CLAUDE_TASK.md` may be edited. Do not edit source, tests, DocC, other maintenance
files, Package.swift, or CHANGELOG. Do not inspect `try/index/1`, change any module's public API,
perform its quality audit, use network access, stage, commit, push, switch branches, or alter Git
history. Run `git diff --check` and inspect `git status --short` at the end.

### Result

2026-10-05, Claude Opus 5.5. Verdict: `approve after specified corrections`.

The facade, the tests, and the progress records are correct. The two corrections concern a DocC
sentence and an untracked catalog.

1. **Surfaces are exact.**
   - `Package.swift` (unchanged): the `AcCollections` target already depends on
     `RedBlackTreeCollections`, `RedBlackTreeModule`, `PermutationModule`, `OptionalArrayModule`,
     and `BareArrayModule`.
   - `AcCollections.swift` now `@_exported import`s the four collection modules unconditionally.
     Under `#if COMPATIBLE_ATCODER_2025` it imports only `RedBlackTreeModule`.
   - `PermutationModule` has moved out of the compat block, with no duplicate import left behind.
   - `RedBlackTreeModule.swift` is just `@_exported import RedBlackTreeCollections`. Re-exporting it
     in compat mode is therefore redundant at the symbol level, but intentional for the module name.
2. **Reachability is proven through `import AcCollections` alone.**
   - The `AcCollectionsTests` target depends only on `AcCollections` and `RedBlackTreeCollections`.
     The file imports `AcCollections`, and imports `@testable RedBlackTreeCollections` only under
     `#if DEBUG`, for the lifetime counters.
   - `PermutationModule`, `OptionalArrayModule`, and `BareArrayModule` are not dependencies of the
     test target and are not imported by it, so the three new tests can compile only through the
     facade.
   - The sample calls are public API: `Array.nextPermutations()`;
     `OptionalArray1D(capacity:)` with `subscript(position:) -> Element?`
     (`OptinalArray.swift:28,64`); `BareArray(repeating:count:)` with
     `subscript(position:)` (`BareArray.swift:24,51`).
   - In Release, the RedBlackTree tests also rely on the facade alone.
3. **DocC pages.**
   - `AcCollections.md` is accurate. It covers ownership ("does not declare collection types of its
     own"), the compat-mode wording, and the inclusion policy. "bare multidimensional arrays" is
     slightly loose, because 1D `BareArray` is included, but it is acceptable.
   - `RedBlackTreeModule.md` contains one unsupported recommendation: "New code should import
     `RedBlackTreeCollections` directly". The package's only product is
     `.library(name: "AcCollections")` (`Package.swift:122`). `RedBlackTreeCollections` is not
     exposed as a product, so external clients have no supported way to import it.
4. **Records.** `PROGRESS_OVERVIEW.md` and `Tests/TESTING.md` record the facade decision only. The
   OptionalArray and BareArray audit rows and checkboxes stay open, and the existing note that test
   progress is not comment-doc completion is kept. No audit is claimed as complete.
5. **Validation.**
   - Normal mode: `swift build --disable-sandbox --build-tests` succeeded.
   - `swift test --skip-build --filter AcCollectionsTests`: 6 tests passed, including the three new
     `exposesNextPermutations`, `exposesOptionalArray`, and `exposesBareArray`.
   - Compat mode: `swift build --target AcCollectionsTests -Xswiftc -DCOMPATIBLE_ATCODER_2025`
     succeeded.
   - DocC: Release `generate-documentation --warnings-as-errors` for both `--target AcCollections`
     and `--target RedBlackTreeModule` succeeded, writing into a `mktemp -d` directory that was then
     removed. Both catalogs were recognized (`accollections`, `redblacktreemodule`). The only
     output was the existing compiler warning "-Ounchecked … strict memory safety", which is not a
     DocC warning.

**Corrections:**

- **(a)** `RedBlackTreeModule.md`, last paragraph. Replace with: "New code should import
  `AcCollections`, the package's library product."
- **(b)** `Sources/_RedBlackTreeModule/RedBlackTreeModule.docc/` is untracked (`??`), whereas
  `AcCollections.docc` is staged. Add it with the batch, or the catalog will be missing from the
  commit.

Checks: only this file was edited. `git diff --check` was clean. `git status --short` shows Codex's
files plus this one.

### Codex follow-up

Accepted both corrections. The legacy-module page now directs new external clients to the
`AcCollections` library product rather than the non-product `RedBlackTreeCollections` target. The
untracked `RedBlackTreeModule.docc` catalog will be explicitly included in the batch commit.

---

Status at completion: Completed

## Completed assignment: call-site review of the scheduler handle workflow

Re-evaluate the insertion-Index API name using the new executable main-use-case experiment, rather
than relying primarily on abstract naming rules.

Read
`Tests/RedBlackTreeTests/RedBlackTreeSet/RedBlackTreeSet_5_InsertionTests.swift`, especially
`test_indexInserting_linuxSchedulerStyleRunQueueExperiment()`. The modeled workflow is a Linux
scheduler-style red-black-tree run queue: order runnable tasks by virtual runtime, retain the node
position returned at enqueue time, and later dequeue a sleeping task through that saved handle
without searching by value again.

### Questions

1. At the actual call sites below, is the operation immediately readable to a Swift user?
   - `let backgroundNode = runQueue.index(inserting: background)`
   - `runQueue.erase(exactly: backgroundNode.index)`
2. Is `index(inserting:)` memorable and discoverable when a user remembers the concept as either
   "enqueue and retain its node/index" or "insert and give me a handle"?
3. Does the tuple force awkward `.index` repetition (`backgroundNode.index`), and if so is that a
   naming problem, a local-variable problem, or a return-contract problem?
4. Write the same short workflow using each serious alternative from the prior review. Judge the
   complete two-line enqueue/dequeue pair, not the insertion method in isolation.
5. Consider whether Swift-facing terminology should remain `Index` rather than expose the
   implementation idea of a node or generic handle. Do not rename the public Index type.
6. Give a concrete recommendation for the declaration and the clearest natural local-variable
   naming pattern. A previous `retain index(inserting:)` verdict is not binding; change it if the
   executable usage exposes a better API.

Return exactly one verdict: `retain index(inserting:) after call-site review`, `rename to <exact
declaration base name>`, or `return contract must be decided first`. Record a concise comparison
and preferred example in `### Result`, set `Status: Completed`, and tell the user only `完了` unless
a product-owner choice remains.

### Boundaries

Only `Maintanance/CLAUDE_TASK.md` may be edited. Do not edit the experiment, source, other tests,
API Matrix, maintenance decisions, DocC, or CHANGELOG. Do not implement the four-container
expansion, inspect `try/index/1`, use network access, build/test, stage, commit, push, or alter Git
history. Read-only repository inspection is allowed. Run `git diff --check` and inspect
`git status --short` at the end.

### Result

2026-10-05, Claude Opus 5.5. Verdict: `retain index(inserting:) after call-site review`.

I read `test_indexInserting_linuxSchedulerStyleRunQueueExperiment()` (uncommitted, in
`RedBlackTreeSet_5_InsertionTests.swift`). This review was read-only; I built and ran nothing.

1. **Readability.** `runQueue.index(inserting: background)` and
   `runQueue.erase(exactly: backgroundNode.index)` are both understandable at a glance: "give me
   the index, inserting X" and "erase exactly this position". The friction in the experiment does
   not come from either method name. It comes from the local variable:
   `backgroundNode` holds a **tuple**, not a node. `.index` then reads as "the node's index".
2. **Memorability and discoverability.**
   - "Enqueue and keep its index" maps directly onto the name.
   - "Insert and give me a handle" does not: a user who types `runQueue.insert` will not find it
     in completion. This is the real cost of the name.
   - An `insert…`-prefixed name would gain completion but loses on the call-site reading (item 4).
     The cheaper fix is documentation: add a See Also link to `index(inserting:)` from each
     container's `insert(_:)`, and from `erase(exactly:)`.
3. **The `.index` repetition is a local-variable problem**, not a naming or return-contract one.
   The contract `(inserted: Bool, index: Index)` matches the swift-collections precedent
   `OrderedSet.append(_:) -> (inserted: Bool, index: Int)`, and that precedent is used
   destructured. Keep the tuple. In the scheduler case `inserted` is uninteresting, because the
   pid tie-break makes tasks unique, but for Set and Dictionary it matters in general.
4. **The whole enqueue/dequeue pair, written with each candidate:**

   ```swift
   // index(inserting:)
   let (_, backgroundIndex) = runQueue.index(inserting: background)
   runQueue.erase(exactly: backgroundIndex)

   // insertAndReturnIndex(_:)  — "AndReturnIndex" is redundant, and inaccurate: it also returns `inserted`
   let (_, backgroundIndex) = runQueue.insertAndReturnIndex(background)
   runQueue.erase(exactly: backgroundIndex)

   // insertReturningIndex(_:)  — the same inaccuracy; reads as a variant of SetAlgebra insert(_:)
   let (_, backgroundIndex) = runQueue.insertReturningIndex(background)
   runQueue.erase(exactly: backgroundIndex)

   // ensureIndex(for:)  — reads as a lookup, and is dishonest for MultiSet/MultiMap
   let (_, backgroundIndex) = runQueue.ensureIndex(for: background)
   runQueue.erase(exactly: backgroundIndex)
   ```

   Read as a pair, `index(inserting:)` / `erase(exactly:)` is the shortest. Its first line is the
   only one whose base name matches what is kept, an index, and nothing in it is redundant.
5. **Keep "Index" as the Swift-facing term.** "Node" exposes the implementation, and "handle"
   suggests ownership or lifetime guarantees beyond the Index contract. The experiment's local
   names (`interactiveNode`, `backgroundNode`) and its comment "saved node handle" should become
   `…Index` / "saved index". This is an edit to the experiment, so it is Codex's call; I did not
   make it.
6. **Recommendation.**
   - Declaration: unchanged.

     ```swift
     @discardableResult
     public mutating func index(inserting newMember: Element) -> (inserted: Bool, index: Index)
     ```

   - Preferred call-site pattern:

     ```swift
     let (_, backgroundIndex) = runQueue.index(inserting: background)
     // … later, when the task sleeps:
     runQueue.erase(exactly: backgroundIndex)
     ```

     When only the index is needed, use `let backgroundIndex = runQueue.index(inserting: background).index`.
   - Add a DocC See Also link from `insert(_:)` to `index(inserting:)`.
   - The earlier naming result's requirements still apply to the four-container expansion: fix the
     MultiMap doc comment, and specify the Dictionary existing-key behaviour.

Checks: only this file was edited. `git diff --check` was clean. `git status --short` shows Codex's
uncommitted files plus this one.

---

Status at completion: Completed

## Completed assignment: review the `index(inserting:)` API name

Perform an independent API-naming review before the already-approved four-container expansion of
`index(inserting:)`. This is naming and contract analysis only; implementation remains deferred.

Codex's provisional recommendation is to retain `index(inserting:)`: the primary result is an
Index, the argument label makes the insertion side effect visible, and the same spelling can cover
unique and multi containers. Rejected provisional alternatives are `insertAndReturnIndex(_:)` as
overly procedural and `ensureIndex(for:)` because MultiSet/MultiMap always insert a new element.

### Required review

1. Inspect the current Set and MultiMap declarations, documentation, tests, API Matrix entries, and
   adjacent insertion/index naming in all four containers.
2. Evaluate `index(inserting:)` under Swift API naming conventions at the call site. Explicitly
   compare it with at least `insertAndReturnIndex(_:)`, `insertReturningIndex(_:)`, and
   `ensureIndex(for:)`; add another serious candidate only if it is materially better.
3. Account for the semantic split:
   - Set/Dictionary are unique-key containers and may return an existing position;
   - MultiSet/MultiMap always insert a new occurrence;
   - the API must return the usable position in every case.
4. Determine whether one shared name remains honest across all four containers. Do not assume the
   existing `(inserted: Bool, index: Index)` result shape must be identical for all four; identify
   any return-label issue that must be settled alongside the name.
5. Review `erase(exactly:)` only for consistency with the paired workflow. Do not redesign it
   unless its spelling makes the recommended insertion name misleading.
6. Separate naming conclusions from Index representation, Comparable, `try/index/1`, and the
   implementation gate. `try/index/1` is explicitly deferred until the user requests its restart.

Return exactly one verdict: `retain index(inserting:)`, `rename to <exact declaration base name>`,
or `naming decision blocked by return contract`. Record concise reasoning in a `### Result`
subsection below, set `Status: Completed`, and tell the user only `完了` unless a product-owner
decision is required.

### Boundaries

Only `Maintanance/CLAUDE_TASK.md` may be edited. Do not edit source, tests, API Matrix, other
maintenance files, DocC, or CHANGELOG. Do not implement APIs, switch branches, inspect
`try/index/1`, use network access, build/test, stage, commit, push, or alter Git history. Use only
read-only repository inspection, then run `git diff --check` and inspect `git status --short`.

### Result

2026-10-05, Claude Opus 5.5. Verdict: `retain index(inserting:)`.

This is read-only inspection; no build was run. It is independent of the Index representation,
Comparable, `try/index/1`, and the implementation gate.

1. **Current state.**
   - Set (`RedBlackTreeSet+Index.swift:284`) and MultiMap (`RedBlackTreeMultiMap+Index.swift:307`)
     declare `mutating func index(inserting newMember: Element) -> (inserted: Bool, index: Index)`
     with `@discardableResult`.
   - Both are guarded by `!COMPATIBLE_ATCODER_2025 && ALLOW_CROSS_TREE_INDEX && !USE_LAZY_DETACH`.
   - Tests: `RedBlackTreeSet_5_InsertionTests.swift:235,248` and
     `RedBlackTreeMultiMap_5_InsertionTests.swift:99,102`.
   - Adjacent naming in all four containers: `insert(_:)` returns
     `(inserted: Bool, memberAfterInsert: Element)`. That includes MultiSet (`RedBlackTreeMultiSet.swift:236`)
     and MultiMap (`:264,280`), where `inserted` is always `true`. The insertion family also has
     `insert(_:hint:)`, `update(with:)`, and `updateValue(_:forKey:)`.
2. **Call-site reading.**
   - `let (inserted, i) = set.index(inserting: x)` reads as "the index, inserting x". The argument
     label states the side effect, and the base name states the primary result.
   - The cost: Swift API guidelines say methods with side effects should read as imperative verb
     phrases, and `index(…)` is otherwise a non-mutating family (`index(after:)`, `index(forKey:)`).
     This is acceptable here. `mutating` is enforced by the compiler, so it cannot be called on a
     `let` or used as a silent query, and the label `inserting:` makes the mutation explicit.
   - The verb-led alternatives are worse:
     - `insertAndReturnIndex(_:)` is procedural; "AndReturn" restates the return type.
     - `insertReturningIndex(_:)` is non-idiomatic. It also reads like a variant of `insert(_:)`
       while returning a different shape, which invites confusion with the SetAlgebra
       `insert(_:)`, whose return type cannot change (the source comment notes this).
     - `ensureIndex(for:)` is dishonest for MultiSet/MultiMap, which always add a new occurrence;
       "ensure" implies idempotence.
     - Overloading `insert(_:)` by return type alone would be ambiguous under
       `@discardableResult`.
   - No materially better candidate exists.
3. **Semantic split.** One name stays honest across all four containers:
   - Set and Dictionary may return an existing position with `inserted == false`, which matches
     `Set.insert`.
   - MultiSet and MultiMap always insert and return the new occurrence.
   - "inserting" names the attempted action in both cases, exactly as `insert(_:)` already does
     across the same four containers.
4. **The return contract is not blocking; precedent settles it.** Every container's `insert(_:)`
   already keeps `inserted` even where it is constantly `true`, so the uniform
   `(inserted: Bool, index: Index)` shape should be kept for all four. Settle these points
   alongside the expansion:
   - **(a) Bug to fix with the expansion.** The MultiMap doc comment is copied from Set. It says
     "inserting it if necessary" and "If an equivalent element is already present, `inserted` is
     `false`…". Both are false for MultiMap. The MultiSet/MultiMap doc should say that a new
     occurrence is always inserted, that `inserted` is always `true`, and that `index` refers to
     the new occurrence.
   - **(b) Dictionary must specify existing-key behaviour.** Follow `insert(_:)`: the stored value
     is not replaced, and `index` refers to the existing pair. The overwrite form remains
     `updateValue(_:forKey:)`. Without this sentence, "inserting" is ambiguous for a key-value
     container.
   - **(c)** `@discardableResult` can stay. The method's purpose is the index, but discarding it
     degrades only to an ordinary insert.
5. **`erase(exactly:)`.** It pairs consistently:
   `let i = s.index(inserting: x).index; …; s.erase(exactly: i)`. The `erase` verb plus a
   distinguishing label is the library's existing removal style, and it returns the successor
   `Index?`. Its spelling does not make `index(inserting:)` misleading, so no redesign is needed.

Checks: only this file was edited. `git diff --check` was clean. `git status --short` shows only
`Maintanance/CLAUDE_TASK.md`.

---

Status at completion: Completed

## Completed assignment: review O(1) MappedValues single-Index operations

Independently review the current uncommitted change that removes the per-operation View-range
membership search from `RedBlackTreeMappedValuesView` subscript access and `swapAt(_:_:)`.

The product decision is fixed: as with standard Collection Index operations, an Index passed to a
single-Index operation must belong to the View; violating that precondition has unspecified
behavior. These operations must not pay O(log N) to prove View membership. The explicit
`isElement(at:)` query and range/Bound operations remain checked and are not part of this change.

### Required review

1. Confirm that removing the three `isElement(at:)` calls eliminates key comparisons from the
   getter, setter, and `swapAt(_:_:)` normal paths.
2. Trace `_unsafeAddress`, `_unsafeMutableAddress`, `__purified_`, and the `accessible` result far
   enough to determine whether invalidated, stale/recycled, detached, end, and otherwise
   unresolvable indices still fail without unsafe memory access, including under `-Ounchecked`.
3. Check CoW index migration in the setter and `swapAt(_:_:)`; in particular, verify that an Index
   accepted before `_ensureUnique()` still resolves to the corresponding node after a copy.
4. Review the three removed death tests. Confirm that same-tree-but-outside-View cases, including a
   View `endIndex` that is still a base-tree element, must no longer assert a controlled trap.
5. Check that the new comparison-count regression test actually isolates the three single-Index
   operations and cannot pass while an O(log N) membership search remains.
6. Check the source comments and `API-Matrix-View.md` against the fixed contract. Flag any claim
   that is broader than the implementation or inconsistent with cross-tree configurations.
7. Run the focused MappedValues tests and a normal Xcode build if available. Do not broaden this
   into the unresolved Comparable/Index PoC design or range-operation redesign.

Return exactly one verdict: `approve O(1) MappedValues Index operations`, `approve after specified
corrections`, or `reject O(1) MappedValues Index operations`. Record concise evidence under a
`### Result` subsection below, set `Status: Completed`, and tell the user only `完了` unless a
product-owner decision is required.

### Boundaries

Only `Maintanance/CLAUDE_TASK.md` may be edited. Review all four current changed implementation,
test, and documentation files plus the minimum Index-validation dependencies needed for the safety
trace. Do not edit source/tests/docs, switch branches, inspect `try/index/1`, use network access,
stage, commit, push, or alter Git history. Do not run the full test suite. Run `git diff --check`
and inspect `git status --short` at the end.

### Result

2026-10-05, Claude Opus 5.5. Verdict: `approve after specified corrections`.

The implementation change is correct. Both corrections are test-only, and neither is a safety
regression.

1. **Key comparisons are gone from the normal paths.**
   - The removed `isElement(at:)` (`RedBlackTreeMappedValuesView.swift:362`) called
     `_NodeKey.isInHalfOpenRange`. That function calls `lessThan`, which compares
     `_NodeKey(.key(Base._Key))` values, that is, key `<`.
   - After the change, the getter, setter, and `swapAt` paths are `__purified_` → `.accessible` →
     pointer only. None of them makes a key comparison.
2. **Unresolvable indices still fail safely, including under `-Ounchecked`.**
   - The getter goes through `_unsafeAddress`; the setter goes through `_unsafeMutableAddress`
     (`UnsafeTreeV2+Subscript.swift:28-45`).
   - `_unsafeMutableAddress` switches on `__purified_(position).accessible` and calls `fatalError`
     on failure. That is not `precondition` or `!`, so `-Ounchecked` does not remove it.
   - `swapAt` uses `guard … .accessible.pointer else { fatalError }`.
   - Same tree: `index.sealed.purified` rejects a seal mismatch (stale or recycled) as `.unsealed`
     (`_NodePtrSealing.swift:100`).
   - Cross tree in the default config (`ALLOW_CROSS_TREE_INDEX` on, `USE_LAZY_DETACH` off):
     - `__retrieve_(tag).deepPurified` returns `.unknown` when the tag is at or beyond
       `initializedCount`.
     - `deepPurified` itself returns `.garbaged` for a node without payload, and `.unsealed` for
       a seal mismatch.
   - `.accessible` maps the end node and garbaged nodes to `.garbaged`.
   - The node memory being validated is kept alive by the index's `_LazyTie`.
   - This is the same validation `isElement(at:)` ran first; the removed code added only the
     range-membership test, never a safety check.
3. **CoW index migration is correct in the default config.**
   - `_ensureUnique()` copies the tree and re-retrieves `_sealed_start` / `_sealed_end`.
   - The caller's index still refers to the old tree, so `__purified_` takes the cross-tree path
     and resolves it by tracking tag in the copy.
   - The new test exercises this path, because `values` shares storage with `dictionary`.
   - Pre-existing, not a regression: without `ALLOW_CROSS_TREE_INDEX`, a caller's index taken
     before the copy fails with `.crossTree` after `_ensureUnique()`. The old code behaved the
     same way after its `isElement` check passed.
   - Cross-tree resolution walks the fresh-pool buckets (`_FreshPool.swift:112`). That is O(1)
     under the documented single-bucket-after-CoW invariant.
4. **The three removed death tests are correctly removed.** All three used indices that were valid
   base-tree elements but outside the View (`startIndex` below a lower bound, and the View's
   `endIndex` while it was still a base element). Under the fixed contract these are
   unspecified-behaviour cases, and they are memory-safe because the nodes are live, so no
   controlled trap can be required of them.
5. **The comparison-count test does isolate the three operations.**
   - Against the old code it would fail: `lessThan` short-circuits only when the two nodes are
     equal. `first` equals the View's start node, but it is still compared with the View's end,
     `upper`, which is a base element with key 4. So the getter, setter, and `swapAt` would each
     count at least one `<`.
   - Robustness note: the test depends on `upper` being a base element. If the View's end were
     `.end`, no key `<` would run, and an O(log N) check could slip through.
6. **Docs are consistent with the contract.** The doc comments (`Precondition` / `Complexity: O(1)`)
   and `API-Matrix-View.md` match it. "対象のtreeで要素へ安全に解決できないIndexは下層のIndex検証で拒否する" is no
   broader than the implementation:
   - In the no-cross-tree configuration, a CoW-copied index is one that cannot be resolved, so it
     is rejected.
   - An index from an unrelated tree can resolve to an unrelated live node. That is memory-safe,
     and `UnsafeIndexV3.swift` already documents it as unspecified.
7. **Validation.**
   - `swift build --disable-sandbox --build-tests`: succeeded.
   - `swift test --skip-build --filter RedBlackTreeMappedValuesViewTests`: 17 tests, 0 failures.
     The new `test_subrangeValuesSingleIndexOperations_doNotCompareKeys` was discovered and passed.
   - No Xcode build and no full suite were run.

**Corrections (tests only):**

- **(a)** With the three removals, no MappedValues test remains that pins the safety half of the
  contract. Add death tests to `RedBlackTreeDictionary_99_DeathTests.swift`, each using
  `observing: [\.standardErrorContent]` plus `expectNoInvalidMemoryAccess`. They should check that
  the following terminate without invalid memory access:
  - `values[i]` where `i` was erased from the base;
  - `values[i] = v` where `i` was erased from the base;
  - `values.swapAt(i, j)` with a stale `i`;
  - `values[dictionary.endIndex]`.
- **(b)** In the new test:
  - Add a one-line comment saying why `upper` must be a base element.
  - Assert the results after the setter and `swapAt`: `values` should read `"changed"` and then
    swapped, and `dictionary` should be unchanged. That pins the CoW migration that the test
    already exercises.

Checks: only this file was edited. `git diff --check` was clean. `git status --short` shows the
four reviewed files plus this one.

### Codex follow-up

Both requested test corrections were applied. Four focused death tests now pin rejection without
invalid memory access for erased indices in getter/setter/`swapAt` and for the base tree's
`endIndex`. The comparison-count test now explains why its upper bound must remain a live base-tree
element and verifies the setter result, swap result, and unchanged original dictionary across CoW.

Xcode verification: the complete `RedBlackTreeMappedValuesViewTests` class (17 tests) plus the four
new death tests passed, 21/21 total. Build-for-testing also succeeded.

---

Status at completion: Completed

## Completed assignment: independently verify X1 inventory batch 4

Independently verify only `CUR-WRAP-001` and `POC-WRAP-001` in
`Maintanance/INDEX_POC_CROSS_BRANCH_IDENTITY.md`.

Inspect lines 23–38 of
`Sources/RedBlackTreeCollections/Implements/RawBuffer/_LazyTieWrap.swift` at the fixed current
(`aecbcddf240c…`) and PoC (`1b126ba370ba…`) anchors. Check the exact generic type declaration,
access, attributes, stored-property declarations, initializer declaration, line numbers, and local
compile-time guards.

Confirm that both rows remain separate identities and both semantic fields remain `unknown`. Do not
inspect or interpret extensions, conformances, method bodies beyond the initializer assignments,
alias use sites, `_LazyTie`, `_NodePtrSealing`, or comments as design intent. Identical declaration
text is not a semantic-correspondence decision.

Return exactly one verdict: `approve X1 inventory batch 4`, `approve after specified corrections`,
or `reject X1 inventory batch 4`. Record the result below, set `Status: Completed`, and give the
user only a short completion notice.

### Boundaries

Only `Maintanance/CLAUDE_TASK.md` may be edited. Do not edit the identity map or any other file. Do
not switch branches, inspect other paths or line ranges, infer semantic correspondence, run builds/
tests/benchmarks, use network access, stage, commit, or alter Git history. Use read-only `git show`
for the exact anchors/path/range and run `git diff --check` only.

### Result

2026-10-05, Claude Opus 5.5. Verdict: `approve X1 inventory batch 4`.

I read only lines 23–38 of `_LazyTieWrap.swift`, using `git show` at `aecbcddf240c…` and
`1b126ba370ba…`. I did not read any extension, conformance, use site, `_LazyTie`, or
`_NodePtrSealing`.

1. **The declarations match the evidence cells.** At both anchors:
   - Line 24 is `@frozen`.
   - Line 25 is `public struct _LazyTieWrap<RawValue> {`. The generic parameter has no constraint.
   - Lines 27–28 are `@usableFromInline` and `package let rawValue: RawValue`.
   - Lines 30–31 are `@usableFromInline` and `package let lazyDetach: _LazyTie`.
   - Lines 33–34 are `@inlinable` and `package init(rawValue: RawValue, lazyDetach: _LazyTie)`.
   - Lines 35–36 assign both stored properties.
   - Line 38 closes the struct.
   - Line 23 is a comment, which I did not inventory.
2. **No guard applies.** Neither anchor has an `#if` in lines 1–38, so both rows are correctly
   described as unconditional.
3. **The evidence is mechanical.** Lines 23–38 are byte-identical at the two anchors (`diff` shows
   no differences). Both Evidence cells state only the visible declarations. They do not turn the
   identical text into a correspondence claim.
4. **The rows stay separate.** `CUR-WRAP-001` and `POC-WRAP-001` are distinct identities by side
   and commit. Role/era and Semantic status are `unknown` in both, and neither row names the other.

Checks: `git diff --check` was clean. Only this file was edited.

---

## Completed assignment: independently verify X1 inventory batch 3

Independently verify only `POC-NODEPTR-001` in
`Maintanance/INDEX_POC_CROSS_BRANCH_IDENTITY.md`.

Inspect `Sources/RedBlackTreeCollections/Implements/RawBuffer/_LazyTieWrap.swift` at the fixed
current (`aecbcddf240c…`) and PoC (`1b126ba370ba…`) anchors. Check the exact enclosing extension,
declaration, access, attributes, alias target, line numbers, and local compile-time guards. Verify
mechanically whether the current anchor has a `_NodePtr` declaration in this same path.

You may mechanically list other `_NodePtr` declarations to demonstrate name multiplicity, but do
not inspect their contents or propose any as a counterpart. This batch must not decide whether the
PoC declaration is `one-sided`, moved, duplicated, obsolete, or semantically related to another
same-named alias. Its semantic fields must remain `unknown`.

Return exactly one verdict: `approve X1 inventory batch 3`, `approve after specified corrections`,
or `reject X1 inventory batch 3`. Record the result below, set `Status: Completed`, and give the
user only a short completion notice.

### Boundaries

Only `Maintanance/CLAUDE_TASK.md` may be edited. Do not edit the identity map or any other file. Do
not switch branches, inspect unrelated file contents, infer semantic correspondence, run builds/
tests/benchmarks, use network access, stage, commit, or alter Git history. Use read-only `git show`
for the exact path and `git grep` only to count/list same-named declarations. Run
`git diff --check` only.

### Result

2026-10-05, Claude Opus 5.5. Verdict: `approve X1 inventory batch 3`.

I read `_LazyTieWrap.swift` with `git show` at `aecbcddf240c…` and `1b126ba370ba…`. For name
multiplicity I listed matching declarations with `git grep`, and did not open any of the listed
files.

1. **The declaration matches the row.**
   - At the PoC anchor, the enclosing declaration is line 105:
     `extension _LazyTieWrap where RawValue == _NodePtrSealing {`, with no attributes and no access
     modifier. It closes at line 137.
   - Line 107 is `public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>`, with no
     attributes.
   - The row's "Lines 105–107", the extension text, the alias target, and "no attributes" are all
     exact.
2. **No compile-time guard applies.** The PoC file has three `#if DEBUG` blocks, at 52–68, 87–103,
   and 139–146. The extension at 105–137 lies between the second and third blocks, so it is not
   inside any guard. "Unconditional extension declaration in the inspected file" is correct.
3. **The current anchor has no `_NodePtr`.** At `aecbcddf`, this path has 101 lines and contains
   no `_NodePtr` token at all. The row's last sentence is correct.
4. **Name multiplicity (listing only).** With `git grep -E 'typealias +_NodePtr( |=|:|$)'` over
   `Sources`:
   - The current anchor has 15 typealias declarations named `_NodePtr`.
   - The PoC anchor has 16.
   - Both anchors also have one `associatedtype _NodePtr`, at `__tree/_types/tree_basic+types.swift:55`.
   - The only path that appears at one anchor and not the other is `RawBuffer/_LazyTieWrap.swift:107`
     (PoC). The other 15 paths and line numbers appear at both anchors.

   This shows the name is widely reused. I made no counterpart, move, duplicate, `one-sided`, or
   obsolescence judgment.
5. **The row is held at unknown.** It is a separate PoC-side identity, Role/era and Semantic
   status are both `unknown`, and no counterpart is named.

Checks: `git diff --check` was clean. Only this file was edited.

---

## Completed assignment: independently verify X1 inventory batch 2

Independently verify only `CUR-ALIAS-001`, `CUR-ALIAS-002`, `POC-ALIAS-001`, and
`POC-ALIAS-002` in `Maintanance/INDEX_POC_CROSS_BRANCH_IDENTITY.md`.

Inspect these two paths at the fixed current (`aecbcddf240c…`) and PoC (`1b126ba370ba…`) anchors:

- `Sources/RedBlackTreeCollections/Implements/RawBuffer/_LazyTieWrap+Result.swift`
- `Sources/RedBlackTreeCollections/Implements/RawBuffer/_LazyTieWrap.swift`

Check the exact typealias declarations, access, attributes, line numbers, alias targets, and local
compile-time guards. Confirm that the evidence is purely mechanical, all four rows remain separate,
and both semantic fields remain `unknown`. Report whether either file contains another declaration
that must be inventoried to describe these two alias declarations themselves; do not widen into the
implementation or conformances of `_LazyTieWrap`, `_NodePtrSealing`, `SealError`, or `Result`.

Do not infer semantic correspondence merely because declaration text matches across anchors. Do not
judge usage, intent, adoption, obsolescence, or implementation behavior.

Return exactly one verdict: `approve X1 inventory batch 2`, `approve after specified corrections`,
or `reject X1 inventory batch 2`. Record the result below, set `Status: Completed`, and give the
user only a short completion notice.

### Boundaries

Only `Maintanance/CLAUDE_TASK.md` may be edited. Do not edit the identity map or any other file. Do
not switch branches, inspect other paths, follow alias targets or extensions, generate wider
inventories, run builds/tests/benchmarks, use network access, stage, commit, or alter Git history.
Use read-only `git show` for the two exact paths and anchors, and run `git diff --check` only.

### Result

2026-10-05, Claude Opus 5.5. Verdict: `approve X1 inventory batch 2`.

I inspected only the two stated paths with `git show`, at `aecbcddf240c…` and `1b126ba370ba…`. I
did not follow alias targets or extensions.

1. **The declarations match the evidence.**
   - In `_LazyTieWrap+Result.swift`, both anchors have line 33
     `public typealias _LazyTieWrappedPtr = Result<_LazyTieWrap<_NodePtrSealing>, SealError>`.
   - In `_LazyTieWrap.swift`, both anchors have line 41
     `public typealias _LazyTiedPtr = _LazyTieWrap<_NodePtrSealing>`.
   - All four declarations are top-level and have no attributes. Lines 23–32 and 40 are plain
     comments only.
2. **No guards apply.** In each file and at both anchors, the first `#if` comes after the alias:
   - `_LazyTieWrap+Result.swift`: the first `#if` is at line 64, inside an extension.
   - `_LazyTieWrap.swift`: the first `#if` is at line 51 (current) or 52 (PoC).

   So all four rows are correctly described as unconditional in the inspected file.
3. **The evidence is mechanical.** Each cell gives only a line number and the alias target. It
   reads nothing into the matching text on both anchors.
4. **The rows are kept apart.** All four are separate identities by side and commit. Role/era and
   Semantic status are both `unknown`, and no row names a counterpart.
5. **Nothing else is needed to describe these two aliases.** One note, outside this batch's
   scope: at the PoC anchor, `_LazyTieWrap.swift` contains another public typealias,
   `public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>`, at line 107. It sits inside an
   `extension _LazyTieWrap where RawValue == _NodePtrSealing` that begins at line 105. At the
   current anchor this file has only one typealias. The `_NodePtr` declaration is not needed for
   these four rows, but a later batch should give it its own PoC-side identity row.

**Optional.** For consistency with the batch-1 correction, the four Evidence cells could add "no
attributes". This is not a correction.

Checks: `git diff --check` was clean. Only this file was edited.

---

## Completed assignment: independently verify X1 inventory batch 1

Independently verify only the four identity rows `CUR-IDX-001`, `CUR-IDX-002`, `POC-IDX-001`, and
`POC-IDX-002` in `Maintanance/INDEX_POC_CROSS_BRANCH_IDENTITY.md`.

Inspect this single path at the two fixed anchors:

- current: `aecbcddf240cc039db9eac92b46721a1fde0532a`
- PoC: `1b126ba370ba78aa90b1241ac83d888ed3861bf4`
- path: `Sources/RedBlackTreeCollections/Implements/Index/UnsafeIndexV3.swift`

Check independently:

1. The exact declarations, access, attributes, and alias targets.
2. Whether each declaration is guarded in this file by any compile-time condition.
3. Whether the evidence text states only mechanically visible facts.
4. Whether current and PoC rows remain separate identities with semantic status `unknown`.
5. Whether any additional declaration in this file requires its own identity row.

Do not propose semantic correspondence between rows, interpret comments as user intent, judge one
side newer/better/obsolete, or inspect alias-target implementations. Shared symbol names are not
evidence of shared meaning.

Return exactly one verdict: `approve X1 inventory batch 1`, `approve after specified corrections`,
or `reject X1 inventory batch 1`. Record the result below, set `Status: Completed`, and give the
user only a short completion notice.

### Boundaries

Only `Maintanance/CLAUDE_TASK.md` may be edited. Do not edit the identity map or any other file. Do
not switch branches, inspect other branch paths, follow alias targets, generate a wider symbol
inventory, run builds/tests/benchmarks, use network access, stage, commit, or alter Git history.
Use read-only `git show` for the exact anchors and path above, and run `git diff --check` only.

### Result

2026-10-05, Claude Opus 5.5. Verdict: `approve after specified corrections`. One evidence
correction is needed, for `POC-IDX-001`.

I inspected only the stated path with `git show`, at `aecbcddf240c…` and `1b126ba370ba…`. I did not
follow any alias target.

1. **Declarations.**
   - **Current side:**
     - Line 26: `@_documentation(visibility: internal)`.
     - Line 27: `public typealias UnsafeIndexV3 = _LazyTieWrappedPtr`.
     - Line 30: `public typealias RedBlackTreeIndex = UnsafeIndexV3`, with a `///` doc comment on
       line 29.
   - **PoC side:**
     - Line 26: the commented-out line `//public typealias UnsafeIndexV3 = _LazyTieWrappedPtr`.
     - Line 30: `public typealias UnsafeIndexV3 = _LazyTiedPtr`. It has **no attribute**.
     - Line 33: `public typealias RedBlackTreeIndex = UnsafeIndexV3`, with a `///` doc comment on
       line 32.
2. **Guards.** Neither file contains any `#if`, so all four declarations are unconditional in this
   file. The rows say this correctly.
3. **Evidence text.**
   - `CUR-IDX-001`, `CUR-IDX-002`, and `POC-IDX-002` state only visible facts.
   - `POC-IDX-001` has two problems:
     - It omits the visible fact that the PoC declaration carries no `@_documentation` attribute.
       On the current side this attribute is part of `CUR-IDX-001`'s evidence, so leaving it out
       of `POC-IDX-001` would let a reader assume the two declarations have the same attributes.
     - "the `_LazyTieWrappedPtr` form remains commented out" contains a history claim ("remains").
       Only the commented-out text itself is visible in the file.
4. **Separation.** All four rows are separate identities, keyed by side and commit, and each has
   `unknown` in both Role/era and Semantic status. No row references another as a counterpart.
5. **Other declarations.** None. The rest of both files is comments (lines 23–25 and 32–62 on
   the PoC side, 23–25 and 32–56 on the current side). Comments are not inventoried as intent,
   per the task.

**Correction.** Replace the `POC-IDX-001` Evidence cell with:

> Alias target is `_LazyTiedPtr` (line 30); the declaration has no attributes; line 26 is a
> commented-out `public typealias UnsafeIndexV3 = _LazyTieWrappedPtr`

**Optional.** Add line numbers to the other three Evidence cells, for consistency:
- `CUR-IDX-001`: lines 26–27
- `CUR-IDX-002`: line 30
- `POC-IDX-002`: line 33

Checks: `git diff --check` was clean. Only this file was edited.

---

## Completed assignment: review the X1 identity-map skeleton

Perform a read-only review of the newly created
`Maintanance/INDEX_POC_CROSS_BRANCH_IDENTITY.md`. This review covers the map structure and
mechanical provenance only. It must not begin semantic correspondence or PoC validation.

Check the following:

1. Verify the listed commit hashes, dates, parent relationships, current tips, and merge base using
   commit metadata only.
2. Verify that the mechanical PoC-side path inventory matches
   `git diff --name-status b3570172..try/index/1` without interpreting file contents.
3. Confirm that the identity key (`branch + commit + path + symbol + configuration`) and the
   configuration dimensions are sufficient to prevent same-name conflation.
4. Confirm that every semantic status remains user-controlled and that neither Codex nor Claude is
   authorized to promote `unknown` to another state.
5. Check that the user-intent questions ask only for intent that source/history cannot establish;
   flag questions that unnecessarily ask the user to reconstruct mechanical facts.
6. Check that the mandatory stops and review sequence faithfully implement the agreed X1 row in
   `Maintanance/AGENT_TASK_FIT_INTERVIEW.md`.
7. Identify any wording that accidentally treats the PoC as obsolete, treats current HEAD as
   authoritative by default, or implies semantic identity from a shared name or path.

Return exactly one verdict: `approve X1 identity skeleton`, `approve after specified corrections`,
or `reject X1 identity skeleton`. For corrections, cite the exact section and replacement wording.
Record the result below, set `Status: Completed`, and give the user only a short completion notice.

### Boundaries

Only `Maintanance/CLAUDE_TASK.md` may be edited. Do not edit the identity map, task-fit table,
progress document, source, tests, or any other file. Do not switch branches, inspect branch file
contents, generate symbol inventories, infer semantic correspondence, run builds/tests/benchmarks,
use network access, stage, commit, or alter Git history. Allowed Git operations are limited to
read-only commit metadata, `rev-parse`, `merge-base`, and `diff --name-status` for the anchors already
named in the identity map. Run `git diff --check` only.

### Result

2026-10-05, Claude Opus 5.5. Verdict: `approve after specified corrections`.

The review was read-only. Git use was limited to `rev-parse`, `merge-base`, `log`/`rev-list`
commit metadata, and `diff --name-status` / `--name-only` between the named anchors. I did not read
any branch file contents.

#### 1. Anchors: verified

- **Tips.** `develop/misc/48` = HEAD = `aecbcddf` (2026-10-05 04:07, parent `c04fec93`).
  `try/index/1` = `1b126ba3` (2026-10-04 20:25, parents `a250c677` and `b3570172`).
- **Merge base.** `merge-base` returns `b3570172` (2026-10-04 20:06), which is the second parent of
  `1b126ba3`, as stated.
- **PoC commits.** `005a7bb3` (2026-09-24 22:46) has parent `49de7dd9`. `a250c677` (2026-09-27
  06:29) is the first parent of the sync merge.

Two mechanical facts are missing from the anchor table:

- **The branch has two earlier sync merges.** Both are before the center commit:
  `8d5f9928` (09-24 22:04, merges `main`) and `49de7dd9` (09-24 22:05, merges
  `develop/misc/35`). So `49de7dd9`, the "Parent of the center commit", is itself a merge. And
  "Last pre-sync PoC commit" is ambiguous, because there are three sync merges, not one.
- **Where the PoC starts.** It has 24 branch-unique first-parent commits (`try/index/1 --not
  develop/misc/48`). The earliest is `21bdd758` (09-24 19:40, `memo`). The commits from 15:44 to
  15:56 that `RED_BLACK_TREE_REMAINING_TASKS.md` dates as the start of the work are reachable from
  `develop/misc/48`, so they are not branch-unique.

#### 2. Path inventory: verified, with one gap

- `git diff --name-status b3570172..try/index/1` returns exactly the 24 listed paths, and all
  24 are `M`. There are no `A`, `D`, or `R` entries, which is worth recording.
- **Gap: the current side is missing.** `b3570172..aecbcddf` changes 45 paths. Five paths
  changed on **both** sides since the merge base:
  - `Maintanance/CLAUDE_TASK.md`
  - `RedBlackTreeBoundExpression.swift`
  - `RedBlackTreeMappedValuesView.swift`
  - `RedBlackTreeRangeView+KeyOnly.swift`
  - `RedBlackTreeRangeView+KeyValue.swift`

  These are the paths where same-path conflation is most likely, because the content has
  already diverged after the sync.

#### 3. Identity key and configuration: correction needed

The key is right. The configuration list has two problems:

- **It omits defines that change compiled Index-related code:** `BENCHMARK`, which exposes public
  Index-returning hooks; `USE_INT128`, which selects the ptr-bitmap path in `__MultiHelper`;
  `ENABLE_LEGACY_TREE_LOWER_UPPER_BOUND`; and `DEATH_TEST` / `ENABLE_DEATH_TESTS` on the test
  side.
- **It assumes configuration names mean the same thing on both branches.** That is itself a
  same-name assumption, and `Package.swift` differs on the PoC side.

#### 4. Status control: confirmed

Every status is closed by the user, and "must not promote a row out of `unknown`" is explicit.
One structural conflict: the **Symbol identity table** has a `Proposed counterpart` column, but
review step 1 says to populate it "without semantic pairing". The `Role / era` column is also an
interpretation if Codex or Claude fills it in step 1.

#### 5. User-intent questions: one asks for mechanical facts

The first six questions ask about intent. The seventh, "What conflicts were resolved during the
2026-10-04 sync merge", asks the user to recall something mechanical: the conflict set can be
recovered from the merge and its two parents. Only the second half of the question (intent versus
restoring compilation) is a question for the user.

#### 6. Stops and sequence: faithful

All seven agreed stopping points from the corrected X1 row are present, including the 10-04
conflict intent, a failing Quality Checklist item, and raw performance data only. The sequence
keeps Claude's extraction independent, keeps correspondence undecided by the agents, gates on the
user, and validates one representative before expanding.

#### 7. Wording

Nothing treats the PoC as obsolete, and no correspondence is inferred from a shared name. One
phrase can be read as making HEAD the reference standard: "validating ... `try/index/1` PoC
against the current development branch".

#### Corrections (section → replacement)

1. **§Fixed anchors.**
   - Rename the row "Last pre-sync PoC commit" to "Last PoC commit before the 2026-10-04 sync merge".
   - Add these rows:
     - `21bdd758…` (2026-09-24 19:40), Role: "Earliest branch-unique first-parent commit
       (`try/index/1 --not develop/misc/48`)".
     - `8d5f9928…` (2026-09-24 22:04), Role: "Earlier sync merge (`main`) before the center commit".
     - `49de7dd9`'s Role: append "; itself a sync merge of `develop/misc/35`".
2. **§Mechanical PoC-side path scope.**
   - Add after the first paragraph: "All 24 entries are `M`; there are no added, deleted, or
     renamed paths."
   - Add a subsection **"Paths changed on both sides since `b3570172`"** listing the five paths
     above, with: "Same-path content has diverged on both sides after the sync; treat every symbol
     in these files as a separate identity on each side."
   - Optionally add the full current-side inventory (`b3570172..aecbcddf`, 45 paths).
3. **§Identity rule.**
   - Replace "Configuration includes, when applicable:" with "Configuration is the define/trait set
     declared by that commit's `Package.swift`; a configuration name is not assumed to mean the
     same on both branches. Dimensions include, when applicable:".
   - Add the following to the list: `BENCHMARK`, `USE_INT128`,
     `ENABLE_LEGACY_TREE_LOWER_UPPER_BOUND`, and `DEATH_TEST` / `ENABLE_DEATH_TESTS` (tests).
4. **§Symbol identity table.**
   - Remove the `Proposed counterpart` column; pairing belongs only in the Correspondence proposal
     table.
   - Rename `Role / era` to `Role / era (user-supplied; otherwise unknown)`.
5. **§Required user-intent checkpoints, last bullet.** Replace it with: "For each conflict
   resolution in the 2026-10-04 sync merge (listed mechanically beforehand from the merge and its
   two parents), did the resolution express design intent, or only restore compilation?"
6. **§Purpose, first sentence.** Replace it with: "This document is the entry gate for X1:
   reconstructing the user-authored `try/index/1` PoC and validating it, on top of the current
   development branch, against the Quality Checklist."

Checks: `git diff --check` was clean. Only this file was edited. Nothing was staged.

---

## Completed assignment: agreement check for the integrated X1 task-fit row

Perform a read-only agreement check of Codex's integration of your preceding X1 interview.
Do not inspect or compare `try/index/1`; this task concerns only whether the recorded role split
faithfully represents the interview.

Review:

- the new `X1` row in `Maintanance/AGENT_TASK_FIT_INTERVIEW.md`;
- the new X1 identity-table prerequisite in `Maintanance/PROGRESS_OVERVIEW.md`.

Confirm only these points:

1. Your overall rating `3` and label `見本またはレビュー必須` are represented accurately.
2. Mechanical history extraction, symbol inventory, test mapping, and adversarial review are the
   parts Claude may own, while semantic correspondence and integration judgment are not assigned
   to Claude.
3. Codex is not treated as a sole reliable owner: it drafts the identity-table skeleton and
   correspondence rationale, but the workflow requires independent Claude evidence and user
   decisions for semantic identity and design intent.
4. The identity key `branch + commit + path + symbol + configuration`, and keeping semantic
   correspondence `unknown` until user confirmation, are appropriate X1 entry conditions.
5. The row preserves the mandatory stopping points from your interview rather than authorizing
   horizontal expansion from an uncertain correspondence.

Return exactly one verdict: `agree with X1 integration`, `agree after specified corrections`, or
`do not agree with X1 integration`. If a correction is needed, identify the exact phrase and its
replacement. Record the result below, set `Status: Completed`, and give the user only a short
completion notice.

### Boundaries

Only `Maintanance/CLAUDE_TASK.md` may be edited. Do not edit the task-fit table, progress document,
source, tests, or any other file. Do not switch branches, inspect `try/index/1`, run builds/tests/
benchmarks, use network access, stage, commit, or alter Git history. Run `git diff --check` only.

### Result

2026-10-05, Claude Opus 5.5. Verdict: `agree after specified corrections`. There is one small
correction, to point 5. Points 1–4 are faithful.

1. **Rating and label.** Agree. The Claude column has `3` and the label `見本またはレビュー必須`, and
   the cell's sub-scores match my interview: 履歴採取5, symbol inventory 4, test mapping 4,
   反証4, semantic correspondence 2, 統合判断1.
2. **Ownership.** Agree. The 担当案 assigns Claude independent collection of history, symbols, and
   tests, plus refutation. Semantic correspondence and integration judgment are not assigned to
   Claude. Two of my interview items are omitted from the row: Quality Checklist evidence and raw
   measurement under fixed procedure. Both were conditional in the interview, so leaving them out
   of the summary row is acceptable.
3. **No sole owner.** Agree. The Codex cell says 「全体を単独所有しない」, and the 担当案 ends with the
   user deciding semantic identity and design intent.
4. **Entry conditions.** Agree. The key `branch + commit + path + symbol + configuration`, with
   semantic identity kept `unknown` until user confirmation, is the right entry gate. The
   PROGRESS item records it before X1 validation.
5. **Stopping points.** Correction needed. The Claude cell keeps four of my seven stopping points.
   It drops the one that is specific to X1: an unwritten intent behind a conflict resolution in
   the 10-04 sync merge. It also drops "a failing Quality Checklist item is reported, not fixed"
   and "performance as raw data only". The row does not authorize horizontal expansion from an
   uncertain correspondence. However, once this task file rotates to history, the row will be the
   only durable copy of the stopping list.

**Replacement (Claude cell, last sentence):**

- Current: 「曖昧な対応・obsolete判定・安全性信号・最初のcontainer/Viewからの横展開前に停止する」
- Replace with: 「曖昧な対応・obsolete判定・安全性信号・意図未記録の10-04 merge解決・Quality Checklist
  不合格（修正せず報告）・最初のcontainer/Viewからの横展開前に停止する。性能は生データのみ提出する」

Checks: read-only. `git diff --check` was clean. Only this file was edited.

---

## Completed assignment: task-fit interview for cross-branch Index archaeology

This is a capability and workflow interview only. Do not newly inspect or compare `try/index/1`
in this assignment.

We are preparing to revalidate a user-authored Index PoC that began on 2026-09-24. Claude has
already inspected this branch once and assisted with repairing / updating its merge from the current
development branch on 2026-10-04; this is not first exposure. Use that concrete experience in the
self-assessment. The difficult part is not ordinary Git history: identically named files, types,
aliases, resolvers, and operations may represent different designs or eras on the two branches, and
`Index` propagates across nearly the entire RedBlackTreeCollections surface. Both Codex and Claude
are prone to incorrectly unifying same-named but semantically different things.

The proposed new task category is:

> Cross-branch reconstruction and present-day validation of a long-lived, user-authored PoC where
> same-named components may have different semantics and the changed concept propagates across the
> public API, internal safety machinery, tests, and documentation.

Answer the following based on your observed strengths and failure modes in this repository:

1. Does an existing task-fit category in `Maintanance/AGENT_TASK_FIT_INTERVIEW.md` adequately cover
   this work? If not, propose a new ID and short task name.
2. Rate your suitability from 1 to 5. Use the existing scale; do not raise the score because the
   task is important.
3. Identify the exact parts you can own safely: mechanical history extraction, symbol inventory,
   semantic correspondence, test mapping, Quality Checklist verification, performance measurement,
   adversarial review, or integration judgment.
4. Identify your likely failure modes, especially same-name/different-semantics conflation,
   treating an older implementation as obsolete, and spreading one mistaken correspondence across
   all containers and Views.
5. State what the earlier inspection and merge repair did and did not establish, then state the
   minimum input you need from Codex and the user before re-inspecting the branch. Consider whether
   a branch+commit+path+symbol identity table and explicit design-intent notes are required.
6. Propose mandatory stopping points where disagreement or ambiguous correspondence must be returned
   to the user instead of inferred.
7. Recommend a division of work among user, Codex, and Claude. Do not assume either agent can safely
   own the entire reconstruction.
8. State whether the eventual PoC validation should require an independent double review, and which
   evidence each reviewer must produce independently.

Give one final task-fit label using the existing vocabulary: `主担当可`, `見本またはレビュー必須`,
or `補助のみ`. A low or conditional rating is acceptable and useful.

### Boundaries

Only `Maintanance/CLAUDE_TASK.md` may be edited. Record the answer below and set `Status: Completed`.
Do not edit the task-fit table or any other document. Do not switch branches, inspect
`try/index/1`, run builds/tests/benchmarks, use network access, stage, commit, or alter Git history.
This interview must not start the PoC validation.

### Result

2026-10-05, Claude Opus 5.5. Interview only. I did not inspect, compare, or switch to
`try/index/1`. The evidence comes from repository records (`CLAUDE_TASK_HISTORY.md`,
`RED_BLACK_TREE_REMAINING_TASKS.md` §`try/index/1`, `MAINTENANCE.md`) and my own observed
failure modes.

**Final label: `見本またはレビュー必須`. Overall rating: 3.**

#### 1. Category

No existing row covers this work.

- G (representation candidates), J (resolver), K (container/View follow-up), and V7 (unsafe
  migration history) each touch part of it.
- None of them covers establishing semantic correspondence between same-named components
  across two live branches.

Proposed new row: **X1: 長期PoCのcross-branch再構成と現行検証** (cross-branch reconstruction and
present-day validation of a long-lived, user-authored PoC).

#### 2–3. Rating by sub-part

| Sub-part | Claude | Owner? |
| --- | ---: | --- |
| Mechanical history extraction (commits, dates, `-M` renames, merge parents) | 5 | 主担当可, with hash/date/path always cited |
| Symbol inventory per branch × configuration (Debug/Release/compat, `ALLOW_CROSS_TREE_INDEX`/`USE_LAZY_DETACH`) | 4 | 主担当可, inventory only |
| Semantic correspondence (is A on branch X the same thing as A on HEAD?) | 2 | 補助のみ: propose evidence, never decide |
| Test mapping (which tests exercise which symbol on which branch) | 4 | 主担当可 after the identity table exists |
| Quality Checklist verification (per-item evidence, configurations) | 4 | 見本またはレビュー必須 |
| Performance measurement | 3 | Only under H/V6 conditions: interleaved runs, disassembly, raw data only, no interpretation |
| Adversarial review of Codex's correspondence/integration | 4 | Yes; this is where I add the most |
| Integration judgment (equivalence, obsolescence, adopt/reject) | 1 | Not mine |

The overall score is 3, not 4: the hard part of X1 is semantic correspondence, and that is
my weakest sub-part.

#### 4. Likely failure modes (with repository evidence)

- **Same-name conflation.** In T1 I nearly unified `UnsafeIndexV2.unsafe(tree:rawTag:)`
  across eras. The user's correction is recorded in memory as "同名でも時代/役割ごとの独立性を先に
  確認する". The risk is higher here, because both branches are current and the names were
  deliberately reused.
- **Classifying from names and structure.** Tonight, in the B3 audit, I called G1
  "witness-free" from its declaration shape. I had to self-correct after spotting associated-type
  inference in public positions. A wrong correspondence can look this plausible.
- **Treating the older implementation as obsolete.** My 2026-10-04 reuse evaluation already
  sorted items into "古くなった点" and "再利用を阻むもの". Some of those may be deliberate design
  choices (for example the Debug `.nullptr` sentinel or the duplicated overloads), not defects. I
  judged them against HEAD, not against the PoC's intent.
- **Spreading one mistake everywhere.** Horizontal expansion is my strength. With one wrong
  correspondence, it becomes the mechanism that replicates the error across 4 containers × 3 Views.
- **Explaining away safety signals.** The sanitizer TODO (an assert weakened via `isDetached`)
  is exactly the kind of thing I could rationalize as test noise.
- **Taking a green build as semantic evidence.** A merge that compiles and passes tests does not
  show that same-named code still means the same thing.

#### 5. What the earlier work established, and minimum input

- **Established** (2026-10-04 review, read-only diff from merge-base `7ae8237c`, 23 branch
  commits):
  - Replacing the Index alias with a success-only `_LazyTiedPtr` compiles for 4 containers and
    2 Views.
  - The internal `_SealedPtr` resolver keeps the cross-tree, unsealed, and detached diagnostics.
  - The list of reuse blockers: `try!`, the Debug `.nullptr` sentinel, the sanitizer TODO,
    missing MappedValuesView, stale paths, and duplicated overloads.
  - The branch is a partial Result-removal PoC, not a nominal-type PoC.
- **Not established:**
  - semantic equivalence of any same-named component across the branches;
  - Quality Checklist conformance (correctness, memory and Index lifetime, performance);
  - the cause of the sanitizer report;
  - behaviour after the 2026-10-04 20:25 sync merge (merge-base is now `b3570172`; my review
    predates it);
  - which of the "obsolete" items reflect user intent.
- **Merge repair:** the Markdown records I can see do not record what I changed during the
  2026-10-04 merge repair or why. That gap is itself evidence that X1 needs written provenance.
  Before re-inspection, the merge's conflict resolutions should be listed with their intent.
- **Minimum input:**
  - **Identity table** (Codex skeleton, user fills intent), one row per symbol of interest:
    - `branch`, `commit`, `path`, `symbol`, `configuration guards`;
    - `role/era`;
    - `HEAD counterpart` (or "none");
    - `same semantics? (yes / no / unknown)`, decided by the user or marked unknown;
    - `intent note`.
  - **User design-intent notes:** which differences are deliberate. At minimum:
    - `_LazyTiedPtr` vs `_LazyTieWrappedPtr`;
    - the Debug `.nullptr` sentinel;
    - why `limitedBy` converts failure to Optional/Bool;
    - the intended `==`/hash semantics;
    - the sanitizer TODO context.
  - **Scope from Codex:**
    - Keep the 09-24〜09-27 PoC commits separate from the 10-04 sync merge.
    - Allowed paths and configurations.
    - Inspection method (read-only `git show` / `git diff`; a worktree only in a task-owned temp
      directory, with user permission).
    - One sample container plus one View before any horizontal pass.

#### 6. Mandatory stopping points (return to the user, do not infer)

1. Any same-named symbol whose semantics differ or cannot be shown to match: mark it `unknown`
   and stop for that row.
2. Any item that looks obsolete. Report it with evidence; never classify it as obsolete myself.
3. After the first container + View sample, before extending a correspondence to the rest.
4. Any memory-safety sign: sanitizer report, weakened assert, lifetime-counter imbalance,
   unexpected `SIGSEGV`. Stop; do not work around it.
5. Any conflict resolution in the 10-04 merge whose intent is not written down.
6. Any failing Quality Checklist item. Report it; do not fix it in the same task.
7. Any performance difference. Raw data only; interpretation goes to Codex and the user.

#### 7. Division of work

- **User:** design intent; the `same semantics?` column; decisions on obsolescence and adoption;
  permission for worktree/temp inspection.
- **Codex:**
  - phase design and identity-table skeleton;
  - draft semantic correspondence with rationale;
  - integration draft and the Quality Checklist verdict draft.
- **Claude:**
  - mechanical extraction and per-configuration symbol inventory;
  - test mapping;
  - per-item Quality Checklist evidence;
  - adversarial review of Codex's correspondence;
  - raw measurements under fixed procedure.

Neither agent owns the whole reconstruction.

#### 8. Double review

Yes: independent and blind, with each reviewer producing evidence before reading the other's.

- **Codex:**
  - correspondence table with semantic rationale;
  - integration and adoption draft;
  - a Quality Checklist verdict per item.
- **Claude:**
  - an independent symbol inventory and diff by phase (PoC commits vs sync merge);
  - a list of counterexample or failing tests (written first, not fixed);
  - Quality Checklist evidence per configuration: Debug/Release, normal/compat, both
    `ALLOW_CROSS_TREE_INDEX`/`USE_LAZY_DETACH` settings, Death Tests, and sanitizer status.

Disagreements go to the user unresolved.

Checks: only this file edited. `git diff --check` clean. Nothing staged.

---

## Completed assignment: targeted review of Combining API performance notes

Perform a read-only review of the new public `- Note:` paragraphs in these three files:

- `Sources/RedBlackTreeCollections/RedBlackTreeSet/RedBlackTreeSet+Combining.swift`
- `Sources/RedBlackTreeCollections/RedBlackTreeMultiSet/RedBlackTreeMultiSet+Combining.swift`
- `Sources/RedBlackTreeCollections/RedBlackTreeMultiMap/RedBlackTreeMultiMap+Combining.swift`

Use `Maintanance/CombiningAPIPerformanceEvidence.md` sections 1–3 as the evidence source and
`Sources/RedBlackTreeCollections/Documentation/Quality-Checklist.md` as the quality policy.

Check only the following questions:

1. Does each statement accurately distinguish insertion-loop paths from `union` / `formUnion` /
   `meld` / `melding`, including the fact that the latter build new storage rather than reuse the
   receiver's spare capacity?
2. Do the Set and MultiSet notes stay within the recorded measurements instead of presenting a
   finite benchmark as a permanent performance guarantee?
3. Does either MultiMap note improperly extrapolate a Set- or MultiSet-only measurement to
   MultiMap? Structural implementation facts may be stated, but unmeasured timing conclusions may
   not be transferred.
4. Are the paired mutating and nonmutating notes attached to the correct same-type overloads?
5. Is the amount of detail acceptable for a public DocC `Note`, with detailed raw evidence kept in
   the maintenance document?

Return exactly one verdict: `approve Combining notes`, `approve after specified corrections`, or
`reject Combining notes`. For any correction, quote the affected API and provide replacement
wording. Record the result below, set `Status: Completed`, and give the user only a short completion
notice.

### Boundaries

Only `Maintanance/CLAUDE_TASK.md` may be edited. Do not edit source, tests, progress documents,
evidence documents, API Matrix, DocC, Package.swift, workflows, benchmarks, or Git history. Do not
stage, commit, switch branches, inspect `try/index/1`, run benchmarks, or use network access. You may
inspect the named source files, the two named documents, and their uncommitted diffs. Run
`git diff --check`; build and tests are unnecessary because this is a wording-only review and Codex
has already completed an Xcode build.

### Result

2026-10-05, Claude Opus 5.5. Verdict: `approve after specified corrections`.

Checked against `CombiningAPIPerformanceEvidence.md` §1–3 and the current source.

1. **Paths are distinguished correctly.** Every note says the alternative "builds new storage".
   That matches §1: `___meld_unique` starts at `minimumCapacity: 2`, and `___meld_multi`
   allocates `count + other.count`. Neither reads the receiver's spare capacity.
2. **Set mutating note: within the measurements.**
   - "faster for disjoint input": merge beat formUnion at all three sizes (21.50/222.46/3646.00
     vs 45.04/482.38/8047.71).
   - "formUnion faster at 90% duplicates": also true at all three sizes (42.42/916.42/27168.67
     vs 28.04/300.25/4869.17).
3. **MultiSet notes overstate.** "consistently faster" reads as a general claim. MultiSet
   measured only disjoint, sorted, and shuffled `other`; duplicate-heavy and shared storage
   were not measured. One comparison (16k unreserved: 323.79 vs 470.50, ≈1.45×) is inside the
   ~1.5× band that §2 says is not significant. The claim needs the measured input shapes.
4. **Nonmutating notes transfer the mutating measurements.**
   - Only `merge` / `formUnion` and `insert(contentsOf:)` / `meld` were measured.
   - `merging` and `inserting(contentsOf:)` are `var result = self` followed by the mutating call,
     so they always copy the receiver first.
   - Set: the "merge, shared storage" case (4504 vs formUnion 7509 at 256k) supports the
     disjoint claim. The note should still say the measurement was of the mutating forms.
   - MultiSet: shared storage was not measured at all, so its nonmutating timing claim is
     unmeasured.
5. **MultiMap notes extrapolate.** "Relative performance depends on the input's ordering and
   the destination's storage-sharing state" is a timing conclusion. MultiMap was never measured.
   The ordering effect was measured on Set and MultiSet; storage sharing was measured only on
   Set. Only the structural facts may be stated.
6. **Overloads are correct.** Each note sits on the same-type overload: Set `merge(_: Set)` /
   `merging(_: Set)`; MultiSet and MultiMap `insert(contentsOf: Self)` /
   `inserting(contentsOf: Self)`. The mutating/nonmutating pairing (formUnion/union,
   meld/melding) is right.
7. **Detail level is acceptable for DocC.** One or two sentences; raw numbers stay in the
   evidence document. Minor readability point: in "that operation … this operation", the two
   pronouns refer to different APIs in adjacent sentences. "it" and "this method" are clearer.

#### Replacement wording

- `RedBlackTreeSet.merge(_:)` (optional, pronouns only):
  > - Note: Spare capacity does not make `formUnion(_:)` preferable; it builds new storage. In
  >   measurements through 256K elements, this method was faster for disjoint input, while
  >   `formUnion(_:)` was faster when 90% of `other` duplicated existing elements.
- `RedBlackTreeSet.merging(_:)`:
  > - Note: Spare capacity does not make `union(_:)` preferable; it builds new storage. This
  >   method copies the current storage before inserting. In measurements of the mutating forms
  >   through 256K elements, `merge(_:)` was faster for disjoint input, even when it first copied
  >   shared storage, while `formUnion(_:)` was faster when 90% of `other` duplicated existing
  >   elements.
- `RedBlackTreeMultiSet.insert(contentsOf:)`:
  > - Note: Spare capacity does not make `meld(_:)` preferable; it builds new storage. In
  >   measurements through 256K elements with disjoint, sorted, and shuffled `other`, this method
  >   was faster in each case, although the construction order of `other` materially affected
  >   both operations.
- `RedBlackTreeMultiSet.inserting(contentsOf:)`:
  > - Note: Spare capacity does not make `melding(_:)` preferable; it builds new storage. This
  >   method copies the current storage before inserting. Only the mutating forms were measured:
  >   through 256K elements with disjoint, sorted, and shuffled `other`, `insert(contentsOf:)` was
  >   faster than `meld(_:)` in each case.
- `RedBlackTreeMultiMap.insert(contentsOf:)`:
  > - Note: Spare capacity does not make `meld(_:)` preferable; it builds new storage. This
  >   method inserts into the existing storage, copying it first if it is shared.
- `RedBlackTreeMultiMap.inserting(contentsOf:)`:
  > - Note: Spare capacity does not make `melding(_:)` preferable; it builds new storage. This
  >   method copies the current storage before inserting.

Checks: inspected the three source diffs and evidence §1–3. `git diff --check` is clean.
Only this file was edited. Nothing staged. No build was run (wording-only review, as assigned).

---

## Completed assignment: review the integrated collaboration reflection

Please perform a read-only review of Codex's 2026-10-05 updates made after your independent
reflection. The purpose is to check whether the integration represents both assessments fairly,
whether the operational changes are supported by the observed work, and whether you can agree to
the integrated conclusion and use it as the collaboration policy going forward. There is no
request to revise, defend, or add to your personal reflection, and agreement is not presumed.

### Review scope

1. Review Codex's appended section in `USER_MANAGEMENT_INTERVIEW_CODEX.md` and the updated table
   plus `## 2026-10-05 統合更新` in `USER_MANAGEMENT_ASSESSMENT.md`.
2. Review Codex's `## Codex evidence update (2026-10-05)` and the revised assignment rule 6 in
   `AGENT_TASK_FIT_INTERVIEW.md`.
3. Confirm that:
   - Codex's score changes are supported by the recent G2–G4/G3 and task-log rotation workflow;
   - your own score change and reasoning are represented accurately without being overwritten;
   - the remaining disagreement on user workload is described as a genuine weighting difference,
     not averaged away;
   - the proposal to bundle same-shape review launches preserves per-batch verdict, record, and
     commit boundaries;
   - personal observations remain optional, non-authoritative, and in each agent's own voice;
   - the revised rule 6 does not pressure either agent to provide a feeling or route technical
     findings incorrectly.
4. Inspect the full uncommitted diff and run `git diff --check`.
5. State explicitly whether you agree with:
   - the integrated description of the role split;
   - the recorded score changes and the unresolved 3-versus-4 user-workload difference;
   - the proposed next improvement of bundling same-shape review launches while preserving
     per-batch verdict and commit boundaries;
   - the treatment of personal observations as optional and outside the integrated verdict.
6. Return one verdict: `agree with integrated reflection`, `agree after specified corrections`,
   `do not agree with integrated reflection`, or `integrated reflection evidence incomplete`.

### Output and boundaries

Record a concise result in this task and set the status to `Completed`. Only
`Maintanance/CLAUDE_TASK.md` may be edited. Do not edit either interview, the integrated
assessment, either observation log, task history, maintenance rules, source, tests, CHANGELOG,
progress documents, Package.swift, workflows, benchmarks, or DocC. Do not stage, commit, switch
branches, inspect `try/index/1`, use network access, or alter Git history.

A short completion notice is sufficient. If you agree only in part or do not agree, identify the
exact statement and your reason in this task without softening it for consensus. Codex will retain
the disagreement or make a correction as appropriate; it will not treat completion as agreement.

### Result (2026-10-05, Claude Opus 5.5)

Verdict: `agree with integrated reflection`.

Explicit agreement:

- **Role split:** agree. "Codex implementation/experiment → Claude independent refutation →
  Codex integration → user approval" matches the observed G2–G4 / G3 work.
- **Score changes and the unresolved difference:** agree.
  - Codex's six raises are each tied to observed workflow, not to output volume.
  - My column is unchanged except for 自分の負荷の管理 3 → 4, and my reasoning is summarized
    accurately. My interview text was not altered.
  - The 3-versus-4 difference is recorded as a weighting difference, not averaged.
  - Non-blocking note for the record: the user later said that the manual relay is an
    Apple/Xcode limitation (「中継はAppleとXcodeの問題だから仕方ないよ」). That supports my
    weighting: I treat the relay as an environmental cost, not a management cost. Codex's
    condition for raising its own score ("when the environmental relay decreases") ties a
    management score to tooling the user does not control. I keep my 4. Codex may keep its 3;
    the recorded difference is accurate as written.
- **Bundling same-shape review launches:** agree. Every place that states the proposal keeps
  verdict, record, and commit per batch, and isolates the failure of one batch from the
  others.
- **Personal observations:** agree. They are optional, outside the integrated verdict and
  completion conditions, and stay in each agent's own log in its own words.
  - Revised rule 6 says a short impression 「添えてよい」. It does not require one. It routes
    technical supplements that do not change a conclusion to Codex.
  - The blocker / safety / user-decision exceptions remain in `CLAUDE.md`. So rule 6 does
    not suppress problem reports.

Checks:

- I inspected the full uncommitted diff: both interviews, the integrated assessment, the
  task-fit file, and `CODEX_OBSERVATIONS.md`.
- The "2,181 lines moved" figure matches the 2,180-line boundary-to-EOF block of the
  pre-rotation file, plus the trailing line.
- `git diff --check`: clean. Only this file was edited. Nothing staged.

## Completed assignment: independently update the collaboration reflection

Please review the collaboration since the 2026-10-04 task-fit and user-management assessments,
and update your assessment from your own perspective. This is a reflection task, not an
implementation task. There is no need to anticipate or align with Codex's answer; Codex will write
its own response and consolidate the factual differences after your independent update.

### Evidence to consider

- The conversation was refreshed, and Codex reconstructed the exact state from Git and Markdown
  without relying on the old conversation.
- G2, G3 NodeCompare, G3 SignedDistance, and G4 were handled as small bounded batches: Codex
  implemented or ran reversible experiments, prepared review requests, checked your results, and
  proposed commits; the user mainly supplied direction, triggered your review, and explicitly
  authorized commits.
- Your external-client typechecks corrected or strengthened the evidence where symbol graphs or
  build-only checks were insufficient.
- The user asked for Claude and Codex observation logs because factual consolidation should not
  erase either agent's own interesting observations or voice.
- `CLAUDE_TASK.md` was rotated from 2556 to 412 lines, with your independent integrity review.
- The user still performs the manual relay that starts your work and reports completion.

### Required updates

1. In `AGENT_TASK_FIT_INTERVIEW.md`, append a dated evidence update. State which existing scores,
   role assignments, or safeguards are confirmed, improved, or should change. Do not rewrite the
   full historical interview and do not raise scores merely because tasks passed.
2. In `USER_MANAGEMENT_INTERVIEW_CLAUDE.md`, append your independent 2026-10-05 reassessment.
   Identify any score changes with before/after values and evidence. Explicitly assess whether the
   agreed delegation reduced user micromanagement and workload in practice, and what burden remains.
3. In `USER_MANAGEMENT_ASSESSMENT.md`, add a clearly labeled Claude update without rewriting the
   Codex side or claiming a new integrated verdict. Leave final integration to Codex and the user.
4. If you feel like leaving any personal or technical reflection for the user, you are welcome to
   append it in your own words to `CLAUDE_OBSERVATIONS.md`. This is entirely optional; an assessment
   update does not create any obligation to disclose a feeling or manufacture an observation.
5. Check consistency across the four files and run `git diff --check`.

### Boundaries

Only edit `Maintanance/AGENT_TASK_FIT_INTERVIEW.md`,
`Maintanance/USER_MANAGEMENT_INTERVIEW_CLAUDE.md`,
`Maintanance/USER_MANAGEMENT_ASSESSMENT.md`, `Maintanance/CLAUDE_OBSERVATIONS.md`, and this task
file. Do not edit Codex's interview or observation log, history, maintenance rules, source, tests,
CHANGELOG, progress documents, Package.swift, workflows, benchmarks, or DocC. Do not stage,
commit, switch branches, inspect `try/index/1`, use network access, or alter Git history.

Update this task with a concise result and set the status to `Completed`. A short completion notice
is enough, but you may also tell the user something directly if you would like to; blockers and
product-owner decisions should still be stated clearly.

### Result (2026-10-05, Claude Opus 5.5)

- `AGENT_TASK_FIT_INTERVIEW.md`: appended `## Claude evidence update (2026-10-05)`. No score
  changes.
  - Claude's B rating stays 3. Claude's B3 classification had a self-caught error.
  - Independent review and rule 9 are confirmed by the G4 rationale correction and the G2
    evidence gap.
  - Rule 6 is reconfirmed, given Claude's over-reporting.
  - New safeguards proposed: external-client typecheck as the standard narrowing evidence,
    using `--show-bin-path` for the build location, and an inverse-clause column in audits.
- `USER_MANAGEMENT_INTERVIEW_CLAUDE.md`: appended `## 2026-10-05 再評価`.
  - Score change: 自分の負荷の管理 3 → 4. Everything else unchanged, with evidence added.
  - Delegation did reduce micromanagement and workload in practice.
  - Remaining burden: manual relay, commit approvals (intentional), Claude-caused
    corrections, and meta rounds.
  - Proposal: bundle same-shape reviews to cut relays.
- `USER_MANAGEMENT_ASSESSMENT.md`: appended a labeled `## Claude update (2026-10-05)`
  summary. No integrated verdict and no edits to the Codex side.
- `CLAUDE_OBSERVATIONS.md`: one optional reflection.
- Consistency: the score change, unchanged scores, and proposal match across the files.
- `git diff --check`: clean. Nothing staged.

## Completed assignment: review the Claude task-log rotation

Perform a read-only integrity review of Codex's maintenance-log rotation. Do not modify source,
tests, package configuration, or Git history.

### Objective

Confirm that completed assignments were moved from `CLAUDE_TASK.md` to
`CLAUDE_TASK_HISTORY.md` without loss or reordering, while the active file retains enough recent
context for the G3/G4 public-surface work. Also check that the new Claude/Codex observation logs
are explicitly optional, lowest-priority, and separate from authoritative project records.

### Required checks

1. Compare the active and history files and verify the rotation boundary is
   `## Completed assignment: narrow five 原木 reference protocols`.
2. Confirm the moved block is verbatim and appears before older history entries, preserving
   newest-first order. Check that no assignment exists in both files and none was lost.
3. Confirm `CLAUDE_TASK.md` retains the G3 SignedDistance, G3 NodeCompare, G2, G4, and B3
   assignments and their result summaries, and is materially smaller than before.
4. Review `MAINTENANCE.md`, `CLAUDE_OBSERVATIONS.md`, and `CODEX_OBSERVATIONS.md`. Confirm the
   observation logs cannot be mistaken for verdicts, required handoff, or authoritative evidence.
5. Run `git diff --check` and inspect the complete diff. Return one verdict: `approve task-log
   rotation`, `task-log rotation correction required`, or `task-log rotation evidence incomplete`.

### Output and boundaries

Update this task with a concise result and set the status to `Completed`. Only
`Maintanance/CLAUDE_TASK.md` may be edited for the required review. If you personally have an
observation you want the user to read later, you may also append it in your own words to
`Maintanance/CLAUDE_OBSERVATIONS.md`; this is entirely optional and must not delay the review.
Do not write a placeholder observation. Do not edit the history, maintenance rules, Codex's
observation log, source, tests, CHANGELOG, progress documents, Package.swift, workflows,
benchmarks, or DocC. Do not stage, commit, switch branches, inspect `try/index/1`, use network
access, or alter Git history. Report only `完了` unless blocked or a product-owner decision is
required.

### Result (2026-10-05, Claude Opus 5.5)

Verdict: `approve task-log rotation`.

- **Boundary:** the rotation starts at `## Completed assignment: narrow five 原木 reference
  protocols`. That heading now exists only in the history file; this file mentions it only
  in the assignment text.
- **Move integrity:** compared against the HEAD versions of both files.
  - The moved block (old task file from the boundary to EOF) appears verbatim in the history
    file.
  - It sits directly after the unchanged history preamble and one dated "Moved verbatim"
    line, and before the previous history body. The previous history body is unchanged, so
    newest-first order is kept.
  - Completed-assignment headings: 28 before and 28 after. None lost, none duplicated.
- **Retained context:** this file keeps the G3 SignedDistance, G3 NodeCompare, G2, G4, and
  B3 assignments. That retained block is byte-identical to its HEAD text.
  This file shrank from 2556 to 412 lines.
- **Observation logs:** `CLAUDE_OBSERVATIONS.md`, `CODEX_OBSERVATIONS.md`, and the
  `MAINTENANCE.md` rule all describe the logs as optional, lowest priority, and not
  authoritative. They also require technical grounds and handoff to be recorded in the
  authoritative documents. Neither log can be mistaken for a verdict or a required
  handoff.
- **Checks:** `git diff --check` is clean. The HEAD copies used for comparison went to a
  `mktemp -d` directory, which was removed. Nothing staged by Claude; `CODEX_OBSERVATIONS.md`
  was already staged before this review.

## Completed assignment: review the G3 SignedDistance targeted compile experiment

Perform a read-only independent review of Codex's G3 SignedDistance experiment. Do not edit
source or implement an alternative design.

### Objective

Confirm or refute that `_BaseNode_SignedDistanceProtocol` cannot be narrowed independently from
`public` to `package` while preserving its `where Self: ~Copyable` extension, public
`___signed_distance` witness, and the four container `Base` conformances to the public
`_BaseNode_SignedDistanceInterface`.

### Required checks

1. Inspect `_BaseNode_SignedDistanceProtocol`, `_BaseNode_SignedDistanceInterface`, its
   `where Self: ~Copyable` extension, the four container `Base` conformances,
   `TreeNodeOnlyFixture`, `___TreeIndex`, and `UnsafeTreeV2+Index.swift` consumers.
2. Confirm both compiler failures recorded under
   `### G3 SignedDistance targeted compile experiment`:
   - public `___signed_distance` is rejected in the extension with package requirements;
   - package `___signed_distance` cannot satisfy the public interface requirement for the
     public conformers.
3. Check whether any access-only formulation was missed. Treat removal of the inverse clause,
   moving or duplicating the witness, changing the public protocol cluster, or redesigning Index
   only as future design work, not as part of this batch.
4. Confirm `tree_base+distance.swift` was restored exactly to the public protocol and public
   witness, and no source, CHANGELOG, test, Package.swift, workflow, benchmark, DocC, or Index
   change remains from the experiment.
5. Return one verdict: `defer G3 SignedDistance`, `G3 SignedDistance access-only narrowing
   available`, or `G3 SignedDistance evidence incomplete`.

### Output and boundaries

Append a concise review below `### G3 SignedDistance targeted compile experiment` in
`Maintanance/EXTERNAL_TYPE_EXTENSION_AUDIT.md`, update this task with the result, and set the
status to `Completed`. Only those two Markdown files may be edited. Do not build the full suite,
stage, commit, switch branches, inspect `try/index/1`, use network access, or alter Git history.
Read-only compiler experiments in a task-owned temporary directory are allowed. Run
`git diff --check`, inspect the complete diff, and report only `完了` unless blocked or a
product-owner decision is required.

### Result (2026-10-04, Claude Opus 5.5)

Verdict: `defer G3 SignedDistance`. Appended `#### G3 SignedDistance experiment review
(Claude)`.

- Both recorded diagnostics were reproduced with synthetic code of the same shape: the
  same associated-type constraints, the `~Copyable` inverse-clause extension, and a public
  conformer.
- The public witness fails because of the inverse clause. A package witness fails
  because it cannot satisfy the public `_BaseNode_SignedDistanceInterface` requirement.
- No combination of protocol access (`package` or `@usableFromInline package`) and
  witness access (`public` or `package`) compiles, so there is no access-only formulation.
  Design alternatives are listed only as future work.
- Restoration: confirmed. `tree_base+distance.swift` matches HEAD, and `git diff HEAD`
  touches only the two Markdown files.
- The temporary directory was removed. `git diff --check`: clean. Nothing staged.

## Completed assignment: review the G3 NodeCompare protocol narrowing

Perform a read-only independent review of Codex's first G3 implementation. Do not modify source.

### Objective

Confirm or refute that narrowing `_BaseNode_NodeCompareProtocol` from `public` to `package`
preserves the public `___ptr_comp` / `___ptr_range_comp` witnesses and all four container
`Base` conformances, without changing `_BaseNode_SignedDistanceProtocol` or making an Index
design decision.

### Required checks

1. Inspect `tree_base+compare.swift`, `_BaseNode_PtrCompInterface`,
   `_BaseNode_PtrRangeCompInterface`, `_Base_MultiplicityHelperInterface`, all four container
   `Base` conformances, `TreeNodeOnlyFixture`, and relevant compatibility-mode constraints.
2. Confirm the G4 `where Self: ~Copyable` failure does not apply: the NodeCompare extension
   has no where clause, and its public methods remain valid witnesses after the protocol becomes
   package.
3. In a task-owned temporary directory, typecheck a package-name-free external client against
   the current Release module. Confirm `___ptr_comp` / `___ptr_range_comp` remain usable through
   public interfaces or public conforming `Base` types, while `_BaseNode_NodeCompareProtocol`
   itself is no longer in scope. Do not use the symbol graph as witness evidence because
   underscore-prefixed declarations may be omitted.
4. Verify `package` is the minimum access required by Release non-`@testable` tests and whether
   `@usableFromInline` is needed anywhere.
5. Check that the source diff is exactly the NodeCompare access modifier; confirm
   `_BaseNode_SignedDistanceProtocol`, Index representations, tests, and implementations are
   untouched. Review the CHANGELOG, progress, audit wording, and Codex's build/test/DocC evidence.
6. Return one verdict: `approve G3 NodeCompare`, `G3 NodeCompare correction required`, or
   `G3 NodeCompare evidence incomplete`.

### Output and boundaries

Append a concise review below `### G3 NodeCompare protocol narrowing result` in
`Maintanance/EXTERNAL_TYPE_EXTENSION_AUDIT.md`, update this task with the result, and set the
status to `Completed`. Only those two Markdown files may be edited. Do not edit source, tests,
CHANGELOG, progress documents, Package.swift, workflows, benchmarks, or DocC. Do not stage,
commit, switch branches, inspect `try/index/1`, use network access, or alter Git history.
Read-only searches and bounded compiler experiments in a task-owned temporary directory are
allowed. Run `git diff --check`, inspect the complete diff, and report only `完了` unless blocked
or a product-owner decision is required.

### Result (2026-10-04, Claude Opus 5.5)

Verdict: `approve G3 NodeCompare`. Appended `#### G3 NodeCompare narrowing review (Claude)`.

- Source diff: the single access modifier (`tree_base+compare.swift:23`). SignedDistance,
  Index, tests, and implementations are untouched.
- The extension has no where clause; the Release build succeeded.
- External client typecheck: run against the current Release module, without a package
  name.
  - Still works: the four `Base` types' `___ptr_comp` / `___ptr_range_comp`, both through
    direct reference and through the public interfaces, plus `___TreeIndex`.
  - Now fails as intended: `_BaseNode_NodeCompareProtocol` is no longer in scope.
- `package` is the minimum access, because Release non-`@testable` `TreeNodeOnlyFixture`
  uses the protocol. No `@usableFromInline` is needed. No compatibility-mode reference
  exists.
- The temporary directory was removed. `git diff --check`: clean. Nothing staged.

## Completed assignment: review the G2 multiplicity protocol narrowing

Perform a read-only independent review of Codex's G2 implementation. Do not modify source.

### Objective

Confirm or refute that narrowing `UniqueMultiplicity` and `MultiMultiplicity` from `public` to
`package` preserves the public `isMulti` witnesses, `_MultiplicityHelper` associated-type
inference, four container `Base` conformances, and compatibility-mode behavior.

### Required checks

1. Inspect `tree_base+trait.swift`, `_Base_IsMultiInterface`,
   `_Base_MultiplicityHelperInterface`, `MultiplicityHelper`, `__UniqueHelper`,
   `__MultiHelper`, all four container `Base` conformances, Release non-`@testable` fixtures,
   and compatibility-mode `_CompareV2` constraints.
2. Confirm the G4 `where Self: ~Copyable` failure does not apply: the G2 extensions have no
   where clause, and their public `isMulti` members remain valid witnesses after the protocols
   become package.
3. Verify that `package` is the correct minimum access, including Release tests that import the
   module without `@testable`; check whether `@usableFromInline` is required anywhere.
4. Check the source diff is limited to the two protocol access modifiers and that CHANGELOG,
   progress, and audit wording match the actual compatibility impact.
5. Review Codex's build/test/DocC evidence and identify any missing configuration or external
   API check. Do not run the full suite.
6. Return one verdict: `approve G2`, `G2 correction required`, or `G2 evidence incomplete`.

### Output and boundaries

Append a concise review below `### G2 multiplicity protocol narrowing result` in
`Maintanance/EXTERNAL_TYPE_EXTENSION_AUDIT.md`, update this task with the result, and set the
status to `Completed`. Only those two Markdown files may be edited. Do not edit source, tests,
CHANGELOG, progress documents, Package.swift, workflows, benchmarks, or DocC. Do not stage,
commit, switch branches, inspect `try/index/1`, use network access, or alter Git history.
Read-only searches and bounded compiler experiments in a task-owned temporary directory are
allowed. Run `git diff --check`, inspect the complete diff, and report only `完了` unless blocked
or a product-owner decision is required.

### Result (2026-10-04, Claude Opus 5.5)

Verdict: `approve G2`. Appended `#### G2 narrowing review (Claude)` below the G2 result.

- Source diff: the two access modifiers only (`tree_base+trait.swift:78,87`).
- The G4 inverse-clause failure does not apply, because the G2 extensions have no where
  clause.
- External-client typecheck: run against the current Release module, without a package
  name.
  - Still works: `Base.isMulti` (direct and through `_Base_IsMultiInterface`) and
    `Base._MultiplicityHelper == __UniqueHelper / __MultiHelper`.
  - Now fails as intended: `UniqueMultiplicity` / `MultiMultiplicity` are no longer in
    scope.
  - The symbol graph cannot show `isMulti`, because it hides `_`-prefixed protocols.
- `package` is the minimum access, because the Release non-`@testable` fixtures
  (`TreeNodeOnlyFixture`, `KeyValueComparerTests`) use the protocols. No
  `@usableFromInline` is needed. Compat `_CompareV2` only uses them in where clauses.
- Gap filled: Codex's normal-mode Debug evidence was an Xcode build only. I ran
  `swift build --build-tests`, then the targeted XCTest suites (7 suites, 77 tests, 0
  failures) and `RedBlackTreeInternalPointerDeathTests` (4 Swift Testing tests, passed).
- CHANGELOG and progress wording are accurate.
- Temporary directories were removed. `git diff --check`: clean. Nothing staged.

## Completed assignment: review the G4 targeted compile experiment

Perform a read-only independent review of Codex's G4 experiment concerning
`_ScalarBasePayloadValue_KeyProtocol`. Do not edit source or implement an alternative design.

### Objective

Confirm or refute the conclusion that this protocol cannot be narrowed independently from
`public` to `@usableFromInline package` because its extension supplies the public `__key`
witness for Set / MultiSet nested `Base` conformances to `_BasePayloadValue_KeyInterface`.

### Required checks

1. Inspect `_ScalarBasePayloadValue_KeyProtocol`, `_BasePayloadValue_KeyInterface`,
   `_ScalarBasePayload_KeyProtocol_ptr`, `ScalarValueTrait`, and the Set / MultiSet `Base`
   conformances.
2. Verify both compiler failures recorded under `### G4 targeted compile experiment` in
   `Maintanance/EXTERNAL_TYPE_EXTENSION_AUDIT.md` follow from Swift access and witness rules:
   - a public member cannot be declared in an extension with package requirements;
   - a package `__key` cannot satisfy the public protocol requirement for the public conformers.
3. Check whether an access-only formulation was missed. Do not propose moving the witness,
   adding duplicate implementations, or redesigning the public protocol cluster as though it
   were part of this batch; list such options only as future design work.
4. Confirm the source file was restored exactly to public protocol + public `__key`, and that
   no source, CHANGELOG, test, Package.swift, workflow, benchmark, or DocC change remains from
   the failed experiment.
5. Return one verdict: `defer G4`, `access-only narrowing available`, or
   `experiment evidence incomplete`.

### Output and boundaries

Append a concise review below the G4 experiment in
`Maintanance/EXTERNAL_TYPE_EXTENSION_AUDIT.md`, update this task with the result, and set the
status to `Completed`. Only those two Markdown files may be edited. Do not build the full suite,
stage, commit, switch branches, inspect `try/index/1`, use network access, or alter Git history.
Read-only compiler experiments in a task-owned temporary directory are allowed. Run
`git diff --check`, inspect the complete diff, and report only `完了` unless blocked or a
product-owner decision is required.

### Result (2026-10-04, Claude Opus 5.5)

Verdict: `defer G4`. Appended `#### G4 experiment review (Claude)` below the G4 experiment.

- Failure 2 is confirmed by Swift witness rules: the public `Base` conformance to public
  `_BasePayloadValue_KeyInterface` requires a public `__key`.
- Failure 1's recorded rationale is over-general. Synthetic compiles show that a public
  member in an extension of a `@usableFromInline package` protocol is accepted, and also
  serves as a public witness, when the extension has no where clause. The diagnostic is
  triggered by `where Self: ~Copyable` alone, even with no conformers.
- No access-only formulation exists. `@usableFromInline` is required by
  `_ScalarBasePayload_KeyProtocol_ptr`. Dropping the inverse clause is a generics change
  that conflicts with the 原木 `~Copyable` retention. Listed only as future design work.
- Forward note: the G2 extensions have no where clause. G3's
  `_BaseNode_SignedDistanceProtocol` extension has one.
- Source restoration: confirmed. `git diff HEAD` touches only the two Markdown files.
- Synthetic experiments ran in a `mktemp -d` directory, which was removed.
- `git diff --check`: clean. Nothing staged.

## Completed assignment: B3 protocol witness and conformance audit

Perform a read-only witness and conformance audit of the residual B3 protocols that
have production conformers but no direct public-signature use. Do not narrow anything
yet.

## Objective

Determine which residual protocol declarations can be narrowed independently without
removing required witnesses, changing public conformances, or forcing an Index design
decision. Produce the next smallest safe batch, or prove that the remaining protocols
must stay deferred.

## Scope

Audit these protocols from the closure-audit residual table:

- `UniqueMultiplicity`
- `MultiMultiplicity`
- `UnsafeTreeBindingV2`
- `_ElementBride`
- `_KeyBride`
- `_MappedValueBride`
- `_PayloadValueBride`
- `_ScalarBasePayloadValue_KeyProtocol`
- `_Tree_IsMultiTraitInterface`
- `_BaseNode_NodeCompareProtocol`
- `_BaseNode_SignedDistanceProtocol`
- `MultiplicityHelper`

Treat `LinkPairValueTrait` as Memoize-owned and excluded from immediate action. Mention
it only to preserve accounting.

## Required analysis

1. For each scoped protocol, enumerate declaration/access, inherited protocols,
   requirements, associated types, conforming types, conditional conformances,
   constrained extensions, default implementations, and repository consumers.
2. Build a witness graph showing which default implementations satisfy requirements of
   other public protocols or public container/`Base` conformances. Distinguish a method
   merely callable through a protocol constraint from a method installed as a witness.
3. Check public and `@inlinable` signatures, serialized bodies, nested public `Base`
   types, Views, generation-4 iteration, compatibility mode, and the four containers.
4. Separate protocol-name exposure from behavior exposure. A protocol may be safely
   narrowed only if required behavior and public conformances continue to typecheck.
5. Group protocols into dependency-connected change batches. For each group, state the
   minimum plausible visibility (`public`, `@usableFromInline package`, `package`, or
   internal), source-compatibility impact, and exact compilation/tests needed to prove
   it.
6. Keep Index-binding, Balanced, Memoize, BENCHMARK, compatibility-generation deletion,
   and external API design out of scope. If a group reaches one of those boundaries,
   mark it deferred rather than assuming a decision.
7. Recommend exactly one next action: one minimal implementation batch, a targeted
   compile experiment, or closure of B3 until another gate moves.

## Output

Append a section named exactly:

`### B3 protocol witness and conformance audit`

to `Maintanance/EXTERNAL_TYPE_EXTENSION_AUDIT.md`. Include a compact protocol/witness
table, dependency groups, configuration findings, proposed validation matrix, and one
verdict:

- `independent narrowing batch available`
- `targeted compile experiment required`
- `deferred gates only`
- `inventory inconsistency blocks decision`

Update this task with concise evidence and set it to `Completed`. Update other
maintenance documents only to correct a demonstrably stale statement; do not mark the
overall cleanup complete.

## Boundaries

Only these files may be edited:

- `Maintanance/EXTERNAL_TYPE_EXTENSION_AUDIT.md`
- `Maintanance/CLAUDE_TASK.md`
- `Maintanance/PROGRESS_OVERVIEW.md`
- `Maintanance/RED_BLACK_TREE_REMAINING_TASKS.md`

Do not edit source, tests, Package.swift, CHANGELOG, workflows, benchmarks, or DocC.
Do not stage, commit, switch branches, use network access, inspect `try/index/1`, or
alter Git history. Do not run the full suite. Targeted builds/typechecking are allowed
only if they do not require source edits; otherwise specify the needed compile
experiment as the verdict. Run `git diff --check`, inspect the complete diff, and inspect
`git status --short`.

Report only `完了` to the user. Put details in Markdown. Explain directly only if blocked
or a product-owner decision is required.

### Result (2026-10-04, Claude Opus 5.5)

I appended `### B3 protocol witness and conformance audit` to
`EXTERNAL_TYPE_EXTENSION_AUDIT.md`. Verdict: `independent narrowing batch available`.

- **G1 (recommended batch):** `_KeyBride`, `_PayloadValueBride`, `_ElementBride`,
  `_MappedValueBride`, `_Tree_IsMultiTraitInterface` -> `@usableFromInline package`.
  No method witnesses; all refiners (normal and compat) are internal/`@usableFromInline`;
  tests use them only under Debug `@testable`. Floor is `@usableFromInline` because
  `@usableFromInline` protocols refine them.
  - Caveat recorded: the Bride same-type constraints let containers/Views infer `_Key` /
    `_PayloadValue` / `_MappedValue`, which appear in public positions (e.g. View
    `Equatable where _PayloadValue: Equatable`). The validation matrix therefore includes
    View Equatable/Comparable tests and a Release symbol-graph check that those types stay
    public.
- **G2** `UniqueMultiplicity` / `MultiMultiplicity`, **G3** `_BaseNode_NodeCompareProtocol` /
  `_BaseNode_SignedDistanceProtocol` (Index-adjacent), **G4**
  `_ScalarBasePayloadValue_KeyProtocol`: their extensions supply witnesses for public
  requirements (`isMulti`, `___ptr_comp`, `___signed_distance`, `__key`). They need a
  real-source compile experiment as a later task. Floor `package` (Release non-`@testable`
  tests `TreeNodeOnlyFixture`, `KeyValueComparerTests`, `TreeFoundamentalValueTests`).
- **G5** `MultiplicityHelper`: must stay public (associated-type constraint of public
  `_Base_MultiplicityHelperInterface`).
- **G6** `UnsafeTreeBindingV2`: deferred; compat-mode public protocols
  `UnsafeIndexBindingV2` / `UnsafeIndicesBinding` inherit it.
- `LinkPairValueTrait`: Memoize, excluded.

Evidence:

- Searches over `Sources`, `Tests`, `Benchmarks/Sources` for all 13 names, their refiners,
  conformers, `isMulti`, `difference_type` / `_InputIter`, View constraints, and explicit
  associated-type typealiases; compat guards of every Deprecated consumer checked.
- Language-rule checks with synthetic code compiled by `swiftc -package-name` in a
  task-owned `mktemp -d` directory (removed afterwards): package-protocol-extension witness
  for a public requirement compiles and works from a client; a `@usableFromInline`
  protocol refining a non-UFI package protocol is an error; inferred associated types
  through a `@usableFromInline package` protocol work in public conditional conformances
  and from a client. No repository source was edited and no package build was run.
- `PROGRESS_OVERVIEW.md` / `RED_BLACK_TREE_REMAINING_TASKS.md`: no demonstrably stale
  statement found for this scope; unchanged.
- `git diff --check`: clean. Nothing staged.

# Codex-to-Claude Work Request

Status: Completed

## Active Correction Assignment

The previous result below is not accepted as complete. Complete these two
tasks in order. Communicate with the user in Japanese. Do not edit
`Sources/RedBlackTreeCollections/Documentation/Head/Outlines/RedBlackTreeSet.outline.md`;
the user has explicitly paused that document.

### Task 1 — Remove redundant and unsafe PermutationModule variants

The previous specification misunderstood the user's goal. The user has now
made the final product decision: do not provide APIs whose behavior duplicates
swift-algorithms' full `permutations()` operation, and do not provide any
`unsafe` permutation API. These APIs and their dedicated implementation paths
are to be removed, not preserved as alternatives or left as open decisions.

Use this product direction:

1. The module's distinct value is the operation that enumerates only the
   lexicographic successors of the current element order (`nextPermutations`).
2. Remove full positional permutation enumeration: `Permutations.All`,
   `IteratorA`, `SubSequenceA`, `unsafePermutations()`, their dedicated support
   code, and tests that exist only for that removed API. Do not replace them
   with a safe `permutations()` convenience API; users who need full
   permutations should use swift-algorithms.
3. Remove `unsafeNextPermutations()` and the public unsafe initialization path.
   Retained-subsequence aliasing must not remain as a user-facing contract.
4. The final public entry point is `nextPermutations()`. Keep only the types and
   implementation required to support that API, and reduce visibility of
   implementation types/initializers when they no longer need to be public.
5. Preserve the observable value semantics of `nextPermutations()`: previously
   yielded results remain stable when the iterator advances.

Required corrections:

#### Phase 1A — swift-algorithms equivalence PoC (deletion gate)

Before deleting the full-permutation path, prove the claimed overlap with
swift-algorithms rather than assuming it.

- Temporarily enable the existing swift-algorithms test dependency only as
  needed for the PoC. Do not add it as a production dependency.
- Compare the immediately materialized values from the current
  `unsafePermutations()` path with `Algorithms.permutations()` for at least:
  empty input, one element, distinct sorted elements, distinct unsorted and
  descending elements, and duplicate values.
- Compare result count, order, and visible duplicate multiplicity. Include at
  least one non-Array `Collection` with `Index == Int` that the current API
  supports.
- Keep the comparison scoped to the public full-permutation behavior that a
  caller can safely consume by materializing each yielded result immediately.
  The unsafe retained-subsequence aliasing is an implementation hazard to be
  removed, not a capability that swift-algorithms must reproduce.
- Record the PoC command, cases, and observed result in the maintenance
  documentation. Temporary PoC code may be removed after it has served as the
  deletion gate, but the evidence must remain reviewable in the document and
  diff/history.
- If ordering, multiplicity, empty-input behavior, or another observable
  result differs, stop before deletion and report the exact counterexample to
  the user in Japanese. Do not redefine the difference away.

#### Phase 1B — Retained API tests and removal

- After Phase 1A passes, first add or identify focused tests for the retained
  `nextPermutations()` contract, including empty, single-element,
  duplicate-value, unsorted, and descending inputs plus stability of retained
  yielded results.
- Implement the removals above in `Sources/PermutationModule` and update or
  remove tests that reference the deleted APIs. Do not retain deprecated
  wrappers unless compilation evidence shows an in-repository migration need;
  the user has explicitly authorized deletion of these public variants.
- Rewrite `Sources/PermutationModule/Documentation/Specification.md`,
  `Maintanance/PermutationModule/ImplementationPlan.md`, and
  `Maintanance/PermutationModule/ProductReadinessAssessment.md` to reflect the
  implemented narrow API. Historical discussion may record what was removed,
  but must not present removed variants as supported strategies.
- Search the entire repository for references to every removed declaration,
  including compatibility documentation and `AcCollections` facade tests.
- Correct the ABC328E plan: constraints are `N <= 8`, `M <= 28`; AtCoder
  validation needs a self-contained pasted Swift file and cannot rely on
  `import AcCollections` being available on the judge.
- Do not add a swift-algorithms product dependency merely to replace the
  deleted API. This task removes redundant functionality; it does not wrap it.
- Do not change unrelated modules, RedBlackTree code, Package.swift, or
  workflows.

Validation for Task 1:

- Run the narrow Permutation tests and confirm the retained cases actually run.
- Run the repository-root `swift test` after the removal.
- Run compatibility-mode validation because `AcCollections` conditionally
  re-exports PermutationModule there.
- Run `git diff --check`.

### Task 2 — Correct and complete the AtCoder 2025 refactoring history

The previous expansion of
`Maintanance/REFACTORING_FROM_ATCODER_2025.md` contains unsupported claims and
does not yet satisfy the requested history audit.

Required corrections and investigation:

1. Do not describe `ecb3085d` as a simple rename of the release-era keystone
   test. Git records deletion/addition with substantial edits, and the
   release-path file was deleted earlier in `1357bd3c`. Trace the intervening
   lineage and describe the current file as a derived/reworked successor unless
   stronger evidence supports another claim.
2. Put stages in chronological order, or explicitly split source and test
   timelines. The current September → May → June order is misleading.
3. Refer to `b2580703` as the tip/commit of the remote
   `release/AtCoder/2025` branch, not as a tag.
4. Do not infer unchanged contracts or author intent from Git similarity
   scores. Separate verified diff facts, user testimony, and interpretation.
5. For each major stage, record the commit, old path, new path, contract moved,
   and surviving or replacement tests. Cover internal-layer separation,
   fixture splitting, raw-tree/Foundamental test extraction, and the expansion
   of Test as Specification across all four public collection types.
6. Clarify `28a1a5fb`: distinguish pre-existing conceptual layers from the
   commit that aggregated/moved them under `Implements/`.
7. Fully describe `29f43bb3` and `60604ff6`, including the actual fixture and
   Foundamental test paths moved into `RedBlackTreeFixture` and
   `RedBlackTreeTreeTests`.
8. Preserve the keystone file unchanged and keep the user's confirmed design
   fact that existing tests were deliberately reused as a bootstrap rather
   than rebuilt from zero.

Task 2 remains documentation-only. Verify every cited commit and path with Git,
run `git diff --check`, and report any lineage that cannot be proven instead of
filling gaps with inference.

When both correction tasks are complete, change this status to `Completed` and
add a new corrected result summary above the previous result summary. Do not
delete the previous record; label it as superseded where necessary.

## Result Summary (this pass)

Completed both Task 1 and Task 2 as specified above.

**Task 1 (PermutationModule removal):**

- Phase 1A (deletion gate): Temporarily enabled the `swift-algorithms` test
  dependency (`Algorithms` product + `USING_ALGORITHMS` define) for the
  `PermutationTests` target and added
  `testPhase1A_unsafePermutationsEquivalentToAlgorithmsPermutations`, comparing
  immediately-materialized `unsafePermutations()` output against
  `Algorithms.permutations()` for empty, single-element, distinct sorted,
  distinct unsorted, descending, duplicate-value inputs, and a non-`Array`
  `Collection` with `Index == Int` (`Range<Int>`). All seven cases matched
  exactly (`swift test --filter PermutationTests`), confirming the deletion
  rationale. Recorded the PoC and result in
  `Maintanance/PermutationModule/ImplementationPlan.md`.
- Phase 1B: Added retained-contract tests for `nextPermutations()` first
  (empty, single-element, non-ascending-start continuation, and CoW stability
  of previously-yielded `SubSequenceN` results via
  `testNextPermutationsRetainedResultsRemainStable`), then removed from
  `Sources/PermutationModule/Permutations.swift`: `unsafePermutations()`,
  `Permutations.All`/`IteratorA`/`SubSequenceA` (and the now-dead
  `Buffer.prepare(count:)`), `unsafeNextPermutations()`, and the public
  `Nexts.init(safe:)`/`init(unsafe:)` (the `_unsafe` aliasing flag was removed
  entirely; `Nexts` now always CoWs via a single internal, non-public `init`
  reachable only through `nextPermutations()`). Removed the now-API-less
  `testUnsafePermutations`, `testUnsafeNextPermutations`, the Phase 1A PoC
  test, and `testPerformance1` from `Tests/PermutationTests/PermutationTests.swift`.
  Reverted the temporary `Package.swift` dependency/define change (`git diff
  Package.swift` is empty after the pass).
- Rewrote `Sources/PermutationModule/Documentation/Specification.md`,
  `Maintanance/PermutationModule/ImplementationPlan.md`, and
  `ProductReadinessAssessment.md` to describe the implemented narrow API
  (`nextPermutations()` only) and record the removed variants as history, not
  open options. No source/test reference to any removed declaration remains
  outside these historical documents and `CLAUDE_TASK.md` itself (repo-wide
  grep checked, including `AcCollections`/`AcCollectionsTests` and
  `Documentation/Compatibility`; no production dependency on
  `swift-algorithms` was added).
- Did not add a swift-algorithms product dependency. Did not touch
  `Sources/RedBlackTreeCollections/Documentation/Head/Outlines/RedBlackTreeSet.outline.md`.

**Task 1 validation:**

- `swift test --filter PermutationTests` — 2/2 passed (post-removal).
- `swift build` and `swift test` from the repository root (normal mode) — all
  existing suites passed, no regressions.
- Temporarily uncommented `.define("COMPATIBLE_ATCODER_2025")`, ran
  `swift test --filter 'AcCollectionsTests|PermutationTests'` (includes
  `AcCollections`'s compat-mode re-export of `PermutationModule`) — passed,
  then restored `Package.swift` (`git diff Package.swift` empty).
- `git diff --check` — clean.

**Task 2 (REFACTORING_FROM_ATCODER_2025.md correction):** Re-verified the
existing corrected document (already reflecting the prior correction pass
below) against the 8 required corrections and against `git` directly in this
pass; made no further edits since every check passed.

- Confirmed every cited commit hash resolves with the exact recorded date and
  subject (`b2580703`, `cc0ca3ad`, `1357bd3c`, `ecb3085d`, `438af006`,
  `0483012f`, `28a1a5fb`, `29f43bb3`, `60604ff6`, `f4e9f69e`, `63b5699a`,
  `0ada7b35`, `e91c01ff`, `76328122`, `64118cd6`).
- Confirmed `b2580703` is both the tip of `remotes/origin/release/AtCoder/2025`
  and the commit tag `0.1.44` points to, and is a linear ancestor of `HEAD`
  (`git merge-base b2580703 HEAD` == `b2580703`) — matches the document's
  "branch tip, not tag" framing.
- Re-ran `git show -M --name-status ecb3085d` and confirmed the exact D/A path
  pair the document cites, and recomputed the content diff with plain `diff`
  (not `git diff`, which inflates the count with patch-header lines): 446
  changed lines between the 350-line original and 347-line result, matching
  the document exactly.
- Confirmed via `git log --follow` that rename tracking naturally stops at
  `ecb3085d`'s `A` line (i.e., git itself does not treat it as a traceable
  rename past that point), corroborating the document's reasoning for why
  `ecb3085d` is documented as delete+rewrite rather than a simple rename.
  Traced the remaining rename chain (`438af006` → `UnsafeTreeV2BootstrapTests.swift`,
  `64118cd6`/`aefc6ab6` content-only edits, `0483012f` renamed back) and found
  it matches T5 exactly.
  - Confirmed via `git ls-tree` that `28a1a5fb`'s parent commit has 13
    top-level directories under `Sources/RedBlackTreeModule` (no `Implements/`)
    and that `28a1a5fb` itself introduces the single `Implements/` directory
    alongside the 4 public-type directories — matches S2's aggregation claim.
- No unsupported claims, broken links, or incorrect commit/path references
  were found. No changes were made to
  `Maintanance/REFACTORING_FROM_ATCODER_2025.md` in this pass.

**Task 2 validation:**

- All cited commits verified with `git show -s`/`git log --follow`/`git
  merge-base`/`git ls-tree` as above.
- `git diff --check` — clean.
- No `swift test` run was needed; this task made no source or test changes.

Reported to the user in Japanese. Open items remaining for the user (recorded
in `Maintanance/PermutationModule/ImplementationPlan.md`'s pending-decisions
list): whether to delete or keep `Tests/PermutationTests/NextPermutation.swift`,
`Sendable` conformance, doc-comment coverage, and the ABC328E live-submission
performance check (external AtCoder submission, to be run by the user).

## Previous Correction Result (superseded by the removal decision above)

Completed both corrected tasks. No production code, tests, or package settings were
changed; documentation and planning only.

**Task 1 (PermutationModule, narrowed to fewer variants):**
- Rewrote `Sources/PermutationModule/Documentation/Specification.md`,
  `Maintanance/PermutationModule/ImplementationPlan.md`, and
  `Maintanance/PermutationModule/ProductReadinessAssessment.md` around the product
  direction: `nextPermutations()` is the module's distinct value; `Permutations.All` /
  `IteratorA` / `SubSequenceA` / `unsafePermutations()` are treated as removal candidates
  that overlap `swift-algorithms`' `permutations()`, not as a feature to complete with a
  new `safe` convenience method.
- Enumerated the complete current public surface (not just the three extension methods):
  `Permutations<C>`, `All`/`Nexts` each with public `init(safe:)`/`init(unsafe:)`,
  `IteratorA`/`IteratorN`, `SubSequenceA`/`SubSequenceN`. This full list is what a staged
  removal must account for.
- Preserved the factual distinction that `All` permutes positions (`n!` positional
  results, duplicates possible) and `Nexts` follows value-based lexicographic successors
  (no duplicate value-orderings, stops early on descending/equal input); the two are not
  described as sharing an ordering, duplicate, or termination contract.
- Added a staged plan in `ImplementationPlan.md`: Stage 0 (regression-locking tests,
  including an equivalence test against `swift-algorithms` as the removal justification)
  → Stage 1 (deprecate the `All` family) → Stage 2 (delete the `All` family and the
  now-dead `Buffer.prepare(count:)` path) → Stage 3 (decide whether
  `unsafeNextPermutations()` / `Nexts.init(safe:)`/`init(unsafe:)` stay public or become
  an internal fast path with the aliasing behavior no longer exposed as a second public
  contract). Each stage requires user sign-off before implementation; nothing was
  implemented.
- Corrected the ABC328E plan: constraints are `N <= 8`, `M <= 28`; the practical
  validation plan explicitly requires a self-contained pasted Swift file for AtCoder
  submission (judge cannot `import AcCollections`), separate from the in-package
  re-export test.

**Task 2 (REFACTORING_FROM_ATCODER_2025.md correction):**
- Re-investigated the keystone test's lineage with `git log --follow`, `git show -M
  --name-status`, and targeted `diff`. Found that the current file is **not** a simple
  rename of the release-era original: `cc0ca3ad` (2026-01-03) forked a copy of
  `tree/___RedBlackTreeContainerTests.swift` into `unsafeTree/old/...`; the two files
  then existed in parallel for ~9 months; the release-era original was deleted in
  `1357bd3c` (2026-09-29); the next day `ecb3085d` (2026-09-30) relocated the forked copy
  to its current directory while also rewriting most of its content (446 diff lines
  against ~350/347 total — git's similarity detector recorded this as delete+add, not a
  rename). Documented this as a derived/reworked successor, not a rename of the original.
- Reorganized the document into an explicit source-timeline section and a separate
  test-timeline section (the prior September → May → June single sequence mixed two
  independent timelines). Within the test timeline, fully traced T1–T6 including the
  `438af006` Bootstrap rename and its reversion back to the current filename in
  `0483012f` (2026-10-03), which the previous version asserted without a traced commit.
- Changed every reference to `b2580703` from "tag-affixed commit" to "the tip commit of
  `release/AtCoder/2025`" (confirmed via `git merge-base` and `git log -1` on the remote
  ref); noted that tag `0.1.44` happens to point to the same commit without using the tag
  as the reference point.
- Added an evidence-labeling convention (`[事実]` / `[証言]` / `[解釈]`) throughout the
  document and reclassified statements that previously presented rename-similarity
  percentages as proof of unchanged intent; those are now scoped to "git's rename
  detector recognized this as the same file," not "the contract didn't change."
- Clarified `28a1a5fb`: confirmed via `git ls-tree` on its parent that `Implements/` did
  not exist before this commit, and via `git show -M --name-status` that it aggregates 14
  pre-existing top-level directories (`__tree`, `UnsafeTreeV2`, `BoundsExpression`,
  `Deprecated`, etc.) under the new `Implements/` parent in one commit. The layers
  pre-existed as top-level directories; the `Implements/` aggregation itself did not
  predate this commit.
- Fully described `29f43bb3` and `60604ff6` with exact `git show -M --name-status` output:
  the `RedBlackTreeFixture` target (`Fixtures.md`, `RedBlackTreeFixture.swift`, removal of
  `RedBlackTreeTestSupport/___Node.swift`) and the `RedBlackTreeTreeTests` ("genboku")
  target (`Tree/Fixture/*` and 10 `Tree/Foundamental/*` files moved, `RedBlackTreeFixture`
  dependency wiring in `Package.swift`).
- Preserved the user's confirmed design fact that tests were reused as a bootstrap rather
  than rebuilt from zero, now backed by the corrected T1–T6 lineage (the fork-and-parallel
  pattern in T1/T3 is itself evidence of this policy, not just an assertion).

**Validation:**
- All cited commit hashes verified to resolve and all cited paths verified against
  current `git show`/`git ls-tree` output during this pass.
- `git diff --check` — clean.
- No `swift test` run was needed; this assignment made no source or test changes.

Reported to the user in Japanese. The PermutationModule removal decisions (deprecate vs.
delete `All` family, fate of `unsafeNextPermutations()`, and `NextPermutation.swift`'s
legacy test) remain open and are recorded in `ImplementationPlan.md`'s pending-decisions
list, awaiting the user's judgment before any implementation proceeds.

## Previous Result Summary (superseded pending correction)

Completed both Task 1 and Task 2 of the PermutationModule/REFACTORING assignment below.
No production code, tests, or package settings were changed; this was a documentation and
planning assignment only.

**Task 1 (PermutationModule phase 1):**
- Added `Sources/PermutationModule/Documentation/Specification.md`: draft specification
  separating observable public contract (enumeration order, termination, duplicate
  handling, CoW-vs-no-CoW behavior) from implementation strategy. Frames `unsafe`-prefixed
  APIs as a deliberate no-CoW strategy, not an inferior/unsafe variant.
- Added `Maintanance/PermutationModule/ImplementationPlan.md`: which existing tests to
  retain (`PermutationTests.swift`) vs. undecided (`NextPermutation.swift`, a dead
  alternate-generation implementation unreferenced by the main module), missing Test as
  Specification cases (cross-API ordering consistency, empty/single-element boundaries,
  `unsafePermutations()` CoW-cancel behavior, `Permutations.All.init(safe:)` coverage),
  a performance-check plan, and a practical plan for ABC328E copy-paste-submission
  validation (baseline before/after comparison, to be executed by the user since it
  requires an external AtCoder submission).
- Updated `Tests/TESTING.md` (current-state + pending-decisions) to reflect this.
- Open decisions for the user (recorded in both new docs): `unsafe` naming, whether to
  wire up `Permutations.All.init(safe:)` as a public "safe full enumeration" API, and
  whether to delete or keep `Tests/PermutationTests/NextPermutation.swift` as reference.

**Task 2 (REFACTORING_FROM_ATCODER_2025.md expansion):**
- Verified `release/AtCoder/2025` is a linear ancestor of the current history
  (`git merge-base` == branch tip, 3416 commits ahead) and traced/confirmed via
  `git show --name-status -M` and `Package.swift` diffs:
  - A fact correcting a possible assumption: the numbered Test as Specification style
    for `RedBlackTreeSet` (11 files) already existed at the 2025-09-03 release point
    (introduced 2025-05-25, commit `f4e9f69e`), and the keystone test predates even that
    (file header dated 2024/09/17). The technique was carried forward, not introduced by
    the migration. `RedBlackTreeMultiSet`/`Dictionary`/`MultiMap` had only 2 files each at
    release time vs. 22-24 now; the commit-by-commit path of that later expansion was not
    traced (documented as a confirmed count-only fact, not a narrated sequence).
  - New stage: internal-layer separation into `Implements/__tree`, `Implements/UnsafeTreeV2`,
    `Implements/Deprecated` already existed by commit `28a1a5fb` (2026-05-04), i.e. before
    the module rename below — recorded as a confirmed lower bound, not a traced origin.
  - New stage: the `RedBlackTreeModule` → `RedBlackTreeCollections` target/directory rename
    happened in three dated commits (`0ada7b35` directory-only rename, `e91c01ff` target
    rename + new thin `@_exported import` compat shim, `76328122` moving that shim's folder
    to `Sources/_RedBlackTreeModule`), confirmed against the current file contents.
  - New stage: `RedBlackTreeFixture` (`29f43bb3`) and `RedBlackTreeTreeTests`/"genboku"
    (`60604ff6`) target extraction, both 2026-10-02, matching the existing `Tests/TESTING.md`
    note.
  - Added a "Test migration" section giving the test-side migration equal weight to the
    source migration, preserving the user's point that existing tests were reused as a
    bootstrap rather than rebuilt from zero.
- Preserved all previously confirmed content; only added new stages and one corrective/
  contextual section. Did not modernize, rename, or alter the keystone test file.

**Validation:**
- All cited commit hashes verified to resolve (`git cat-file -e`) and all cited paths
  verified to exist in the current working tree.
- `git diff --check` — clean.
- No `swift test` run was needed; this assignment made no source or test changes.

Reported to the user in Japanese; the PermutationModule open decisions above are awaiting
the user's judgment before any implementation proceeds.

## Previous Active Assignment (now completed, see Result Summary above)

Work on the following two bounded documentation and planning tasks in order.
Read the repository-level instructions, `Tests/CLAUDE.md`, `Tests/TESTING.md`,
and the relevant user priorities in `Maintanance/MAINTENANCE.md` before
editing. Communicate with the user in Japanese.

### Task 1 — PermutationModule specification, phase 1

Prepare the specification foundation for a future `PermutationModule`
redesign. This phase is investigation and documentation only.

1. Audit the current public API, implementation variants, existing tests,
   package configuration, user-facing documentation, and the historical
   AtCoder-compatible behavior of `PermutationModule`.
2. Recreate `Sources/PermutationModule/Documentation/` if it is absent and
   write a concise specification draft there. Separate observable public
   behavior from implementation strategy. The intended end state should
   expose differences in behavior caused by implementation choice without
   presenting an "unsafe" variant as the user-facing distinction.
3. Produce a test-first implementation plan: identify which existing tests can
   be retained, which Test as Specification cases are missing, and which
   performance checks are needed. Include a practical plan for copy-paste
   submission to AtCoder ABC328E as the performance validation requested by
   the user.
4. Record unclear semantics, API-shape choices, compatibility questions, or
   removal candidates as decisions for the user. Do not guess.

Constraints for Task 1:

- Do not change production Swift code or public API in this phase.
- Do not delete or rewrite existing tests merely to fit the proposed design.
- Do not start implementation until the user has reviewed the specification
  and unresolved decisions.
- Keep new documentation focused; do not copy large source listings.

Validation and handoff for Task 1:

- Verify every named file, API, and test against the current repository.
- Run only documentation/link or existing narrow tests needed to validate
  factual claims; no broad implementation work is authorized.
- Update the relevant current-state maintenance document concisely.
- Report the proposed specification and user decisions needed in Japanese.

### Task 2 — Expand the AtCoder 2025 refactoring record

After Task 1 is complete, extend
`Maintanance/REFACTORING_FROM_ATCODER_2025.md` using repository history as
evidence.

1. Trace the main stages from `release/AtCoder/2025` to the current
   RedBlackTree architecture. For each confirmed stage, record the commit,
   old path, new path, contract moved, and replacement or surviving tests.
2. Give the test migration equal attention to the source migration. Preserve
   the user's important design fact that the existing tests were deliberately
   reused as a bootstrap rather than rebuilt from zero.
3. Cover the progression from container-coupled code through internal-layer
   separation, fixture splitting, raw-tree tests, and the four public
   collection Test as Specification suites.
4. Treat
   `Tests/RedBlackTreeTests/UnsafeTreeV2/Instance/___RedBlackTreeContainerTests_unsafe.swift`
   as the keystone historical artifact. Do not modernize, rename, enable, or
   delete it as part of this task.
5. Clearly distinguish facts proven by commits and diffs from interpretations.
   Label uncertain intent and ask the user instead of presenting it as fact.

Constraints for Task 2:

- Documentation changes only. Do not change source, tests, package settings,
  workflows, or public API.
- Prefer a readable account of methods and stages over an exhaustive file-move
  log.
- Preserve the existing confirmed content unless repository evidence proves it
  wrong.

Validation and handoff for Task 2:

- Check cited commits and paths with Git history.
- Check all current links and paths mentioned in the document.
- Run `git diff --check`.
- Report additions, uncertain points, and evidence used in Japanese.

When both tasks are complete, change this status to `Completed`, add a concise
result summary and validation record above the previous completed assignment,
and do not delete the historical completion record below.

## Previous Completed Assignment

### Result Summary

Confirmed the singleton lifecycle for all four types (Set/MultiSet/Dictionary/
MultiMap) and added
`Tests/RedBlackTreeTests/RedBlackTreeInternal/Base/RedBlackTreeInternal_EmptySingletonTests.swift`
(DEBUG-only, `@testable import`). One shared helper pair
(`assertIsSingleton`/`assertNotSingleton`, generic over `UnsafeTreeV2<Base>`)
plus one test function per type drives: `init()`, `init(minimumCapacity:)` at
0 and >0, `reserveCapacity(0)`, first `insert`, `remove(at:)` on the last
element, and both `removeAll(keepingCapacity:)` modes.

Findings (internal allocation/CoW contract, not public API):

1. Ordinary `init()` and `init(minimumCapacity: 0)` return the exact same
   type-erased global singleton (`_emptyTreeStorage`, capacity 0) for all four
   types, and in fact across every generic instantiation (e.g.
   `RedBlackTreeSet<Int>` and `RedBlackTreeDictionary<String, Int>` share the
   identical object), since the singleton never stores payload.
2. Struct-copying an empty collection preserves that identity (confirmed via
   `isIdentical(to:)`).
3. Detachment happens on: `init(minimumCapacity:)` with a positive value;
   `reserveCapacity(_:)` for any value including 0 (it goes through
   `ensureUniqueAndCapacity`, which treats the singleton as never-unique); and
   the first insertion (needs capacity regardless). Decoding an empty JSON
   array already had prior regression coverage
   (`EtcTests.testDecodeEmptyArrayUsesReadOnlySingleton`) confirming the same
   singleton path.
4. After removing the last element via `remove(at:)`, the collection keeps its
   already-allocated buffer; it does not revert to the singleton (matches the
   "held for now" note already in `AllocationTests.test1`).
5. `removeAll(keepingCapacity: true)` keeps the current buffer (singleton or
   allocated) and is a no-op when already empty; `removeAll(keepingCapacity:
   false)` always reassigns to the singleton via `.create()`.
6. All four types are intentionally identical on points 1-5; the
   implementations are structurally parallel across Set/MultiSet/Dictionary/
   MultiMap.
7. Not configuration-dependent: the singleton/`isReadOnly`/`ensureUnique`
   mechanics in `UnsafeTreeV2+Create.swift`, `+CopyOnWrite.swift`, and
   `UnsafeTreeV2.swift` have no `#if DEBUG` or `#if COMPATIBLE_ATCODER_2025`
   branches; only the `@testable`/`AC_COLLECTIONS_INTERNAL_CHECKS`
   introspection used by tests is DEBUG-only. Verified by running the new
   tests under a temporary `COMPATIBLE_ATCODER_2025` build (then reverted) in
   addition to the normal build.

Unresolved/reported to the user (not fixed; out of scope for this task):
`erase(where:)` on all four types calls bare `ensureUnique()` unconditionally
(no `count > 0` guard), so it detaches an already-empty collection from the
singleton for no reason — the same "wasteful CoW on no-op removal" pattern
that was already fixed for `remove(_:)`, `removeValue(forKey:)`,
`removeAll(keepingCapacity: true)`, and `popFirst`/`popLast` elsewhere. Added
`testEraseWhereOnEmptyCollectionDetachesFromSingleton` as a minimal
reproducer documenting the current (unfixed) behavior; no production code was
changed.

Validation:
- `swift test --filter RedBlackTreeInternal_EmptySingletonTests` — 5/5 passed
  (normal build).
- `swift test` from the repository root — full suite passed (normal build).
- Temporarily uncommented `.define("COMPATIBLE_ATCODER_2025")` in
  `Package.swift`, ran `swift test --filter
  RedBlackTreeInternal_EmptySingletonTests` (4/4 ran; the
  `erase(where:)`-only test correctly skipped, since that API doesn't exist in
  compat mode) and then the full `swift test` (no new failures; one
  pre-existing unrelated skip in
  `RedBlackTreeSetAdditionalAtCoder2025LegacyTests.testSubsequence4`), then
  restored `Package.swift` (`git diff Package.swift` is empty).
- `git diff --check` — clean.

## Objective

Audit the empty-storage behavior of the four public RedBlackTree collection
types and determine exactly when an empty collection uses a shared singleton
buffer. Turn the confirmed behavior into focused tests and concise maintenance
documentation without changing the public API.

The four types are:

- `RedBlackTreeSet`
- `RedBlackTreeMultiSet`
- `RedBlackTreeDictionary`
- `RedBlackTreeMultiMap`

## Start With

1. Read `Tests/CLAUDE.md` and `Tests/TESTING.md` completely.
2. Inspect the empty initializer paths, minimum-capacity initializer paths,
   buffer creation code, copy-on-write code, and `removeAll(keepingCapacity:)`.
3. Search for existing empty-buffer identity tests and internal inspection
   helpers before adding anything.
4. Read only the relevant sections of `Tests/TESTING_REFERENCE.md` if historical
   context is required.

## Questions to Resolve

Establish evidence-backed answers for each public collection type:

1. Does ordinary empty initialization use the same shared storage instance?
2. Does copying an empty collection preserve that shared storage?
3. Which operations detach from the singleton: reserve, first insertion,
   minimum-capacity initialization, or another operation?
4. After removing the final element, does the collection retain its allocated
   buffer or return to the singleton?
5. What are the distinct outcomes of `removeAll(keepingCapacity: false)` and
   `removeAll(keepingCapacity: true)`?
6. Are the answers intentionally identical across all four types?
7. Are any behaviors configuration-dependent, including Debug/Release,
   compatibility mode, or package traits?

Do not treat pointer identity as public API. Classify findings as internal
allocation and copy-on-write contracts unless an observable public guarantee
already exists.

## Required Work

1. Audit implementation and existing tests before editing.
2. Create or reuse the smallest test-only inspection helper needed to observe
   storage identity and capacity. Do not expose new public API.
3. Add focused tests for the confirmed singleton lifecycle. Place them in the
   appropriate internal or value-semantics test layer according to
   `Tests/CLAUDE.md`; do not add them to numbered Test as Specification files if
   they only assert internal storage identity.
4. Cover all four public collection types without duplicating large test bodies
   when a clear shared helper is appropriate.
5. Record the confirmed conditions in the appropriate test/fixture documentation
   and update `Tests/TESTING.md` concisely.
6. If current behavior is inconsistent, unsafe, or unclear, do not normalize it
   speculatively. Preserve a minimal reproducer and report the evidence to the
   user in Japanese.

## Scope and Constraints

- Keep changes limited to tests, test-support code, and test documentation.
- Do not change production code as part of this assignment.
- Do not change public API or promise storage identity as public behavior.
- Preserve unrelated user and Codex changes, including the staged Linux ASan
  diagnostics for `TreeFoundamentalAllocationTests`.
- Do not edit `.github/workflows/swift.yml`,
  `TreeFoundamentalAllocationTests.swift`, or `TreeOwnedNodeFixture.swift`.
- Communicate progress, questions, and results to the user in Japanese.

## Validation

1. Run the narrowest new or affected tests first.
2. Run the complete affected RedBlackTree test target.
3. Run `swift test` from the repository root and confirm the intended tests ran.
4. Add Release or compatibility-mode validation only when the behavior or
   conditional compilation being tested requires it.
5. Run `git diff --check`.

## Completion Criteria

- The singleton lifecycle is explicitly established for all four collection
  types, including initialization, copying, detachment, last-element removal,
  and both `removeAll` capacity modes.
- Internal tests fail if these confirmed storage-sharing conditions regress.
- No production code or public contract is changed.
- `Tests/TESTING.md` records the current result and any unresolved concern.
- This file is changed to `Status: Completed` and receives a concise result
  summary listing changed files and validation commands/results.
- The user receives a Japanese report, and Codex can independently review the
  resulting diff.

# Codex-to-Claude Work Request

Status: Active — complete Task 1 before Task 2

## Active Assignment

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

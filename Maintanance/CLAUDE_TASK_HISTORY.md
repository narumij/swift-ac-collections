# Codex-to-Claude Work Request History

Completed assignments and result summaries moved verbatim from
`Maintanance/CLAUDE_TASK.md` on 2026-10-03. Entries are kept in their original
order (newest first). Headings such as "Active" or "above" refer to their
position in the original file at the time they were written.

Moved verbatim from `Maintanance/CLAUDE_TASK.md` on 2026-10-05.

## Completed assignment: narrow five 原木 reference protocols

Narrow the five independently actionable 原木 protocols identified by the closure
audit from public API to package implementation surface. Preserve them as porting
reference code; do not delete them.

## Objective

Remove five unused/reference-only protocol names from the external public surface
without changing production behavior, Index design, or the retained 原木 structure.

## Allowed implementation

1. In `Implements/__tree/base/tree_base+interface.swift`, narrow these declarations:
   - `_BaseKey_EquivInterface`
   - `_BaseNode_PtrUniqueCompInterface`
   - `_Base_MultiplicityHelperProtocol`
   Use the minimum package visibility compatible with their `@inlinable` requirements
   and neighboring 原木 declarations. Do not change requirements or bodies.
2. In `Implements/__tree/_types/tree_basic+types.swift`, change `_pointer_type` to
   `@usableFromInline package`; it is inherited by the existing
   `@usableFromInline package` `TreeEndNodeAccessInterface`.
3. In `Implements/__tree/base/tree_base+common.swift`, narrow
   `_BaseNode_KeyProtocol` to package and narrow its default `__get_value(_:)`
   implementation from public to the minimum package visibility needed by same-package
   Debug and Release tests. Preserve `@inlinable`, its requirements, implementation,
   and the comments explaining that it is retained as reference material.
4. Add one concise source-breaking entry to `CHANGELOG.md`.
5. Append exact changes and validation to `EXTERNAL_TYPE_EXTENSION_AUDIT.md`; update
   this task. Update `PROGRESS_OVERVIEW.md` only if an existing checkbox becomes fully
   accurate; do not close the overall public-surface item while the 13-protocol B3
   typecheck audit and deferred gates remain.

## Must preserve

- All five declarations and their semantics as 原木/reference code.
- `_BaseKey_LessThanInterface`, `_BaseNode_PtrCompInterface`,
  `_BaseNode_PtrRangeCompInterface`, `_Base_MultiplicityHelperInterface`,
  `_PointerType`, `_parent_pointer_type`, and `_BaseComparableKey_LessThanProtocol`.
- Both test fixtures using `_BaseNode_KeyProtocol`.
- Index/Comparable/Result, Balanced, Memoize, BENCHMARK, iterator, container, and View
  code.

## Validation

1. Normal mode:
   - Debug `--build-tests`;
   - run `TreeFoundamentalValueTests` and
     `RedBlackTreeInternal_98_CoverageTests`, confirming actual discovery;
   - Release `RedBlackTreeCollections` build;
   - build the relevant test targets in Release if needed to prove package access;
   - Release DocC warnings-as-errors.
2. Compatibility mode: build `RedBlackTreeCollections` and the relevant test target(s)
   with `-Xswiftc -DCOMPATIBLE_ATCODER_2025`.
3. Search the current tree to confirm the five names have no externally required
   public signature and the expected same-package test references remain.
4. Run `git diff --check`, inspect the complete diff, and inspect `git status --short`.

## Boundaries

Do not edit `Package.swift`, workflows, benchmarks, unrelated protocols or tests,
DocC, Index code, or `try/index/1`. Do not stage, commit, switch branches, use network
access, or alter Git history. Keep the source diff to access modifiers/attributes only;
do not reformat the files.

Set this task to `Completed` and report only `完了` to the user. Put details in the
Markdown records. Explain directly only if blocked or a product-owner decision is
required.

### Result (2026-10-04, Claude Opus 5.5)

Source diff is access modifiers/attributes only (3 files, 6 lines changed + 1 attribute
line added). Details are in `EXTERNAL_TYPE_EXTENSION_AUDIT.md`,
`### 原木 reference protocol narrowing result`.

- `_BaseKey_EquivInterface`, `_BaseNode_PtrUniqueCompInterface`,
  `_Base_MultiplicityHelperProtocol`: `public` -> plain `package` (no `@usableFromInline`
  needed; nothing serialized or `@usableFromInline` references them).
- `_pointer_type`: `public` -> `@usableFromInline package`.
- `_BaseNode_KeyProtocol`: `public` -> `package`; default `__get_value(_:)`:
  `@inlinable public static` -> `@inlinable package static`. Comments kept.
- Note: both `_BaseNode_KeyProtocol` fixtures are `#if DEBUG` and use `@testable import`,
  so `internal` would also satisfy current tests; `package` was used as assigned. The
  Release test build therefore does not exercise these fixtures.
- `CHANGELOG.md`: one source-breaking Unreleased / Changed entry.
- `PROGRESS_OVERVIEW.md`: unchanged by this task (no checkbox became fully accurate).

Validation:

- `swift build --disable-sandbox --build-tests`: succeeded.
- `swift test --disable-sandbox --skip-build --filter 'TreeFoundamentalValueTests|RedBlackTreeInternalCoverageTests'`:
  `TreeFoundamentalValueTests` 11 XCTest cases, 0 failures; `RedBlackTreeInternalCoverageTests`
  5 Swift Testing tests (incl. `_BaseNode_KeyProtocolのカバレッジ確保`) passed.
- Release: `--target RedBlackTreeCollections` and `--target RedBlackTreeTreeTests` built.
- CI Release DocC `generate-documentation ... --warnings-as-errors`: succeeded.
- Compatibility mode (`-Xswiftc -DCOMPATIBLE_ATCODER_2025`): `RedBlackTreeTreeTests` and
  `RedBlackTreeTests` targets built.
- Search over `Sources`, `Tests`, `Benchmarks/Sources`: no public signature references the
  five names; only package `TreeEndNodeAccessInterface` inherits `_pointer_type`; test
  references are the two fixtures plus `Fixtures.md`.
- `git diff --check`: clean. Nothing staged.

## Completed assignment: public-surface cleanup closure audit

Perform a read-only closure audit of the remaining RedBlackTreeCollections public
surface after the completed narrowing/isolation batches. Do not implement changes.

## Objective

Determine whether any independently actionable, unintended public declaration remains
outside the already documented deferral clusters. The goal is to decide whether the
public-surface cleanup can reach a clean stopping point before the Index contract is
settled.

## Baseline exclusions

Do not re-propose these as immediate work:

- Index representation and everything classified as Index-binding, including
  `Result` Comparable, `_LazyTieWrap`, `_NodePtrSealing`, `SealError`, raw ranges, and
  Index-returning benchmark hooks;
- Balanced protocols / `freeCapacity`, which intentionally act as an executable API
  matrix and remain coupled to Index/Range and Debug-vs-Release policy;
- Memoize APIs, which wait for the two external consumers to migrate;
- `BENCHMARK`-trait public hooks used by the separate Benchmarks package;
- generation 3 deletion, which requires a separate owner decision;
- already completed ThreeWay, SortedSequence, View `_isIdentical`, Bound fixture,
  deprecated iterator, and iterator-protocol batches.

## Required work

1. Re-run the public declaration/conformance inventory against the current working tree,
   not the pre-cleanup snapshot. Cover public `_` / `__`, `Unsafe*`, public typealiases,
   external-type extensions, conditional conformances, and Debug/Release differences.
2. Reconcile every residual item with `EXTERNAL_TYPE_EXTENSION_AUDIT.md` and
   `RED_BLACK_TREE_REMAINING_TASKS.md` as one of:
   - intended product/API-matrix surface;
   - known deferred cluster listed above;
   - compatibility-only and correctly guarded;
   - independently actionable unintended public surface;
   - documentation/accounting error only.
3. For each independently actionable item, prove repository consumers, external
   exposure, `@inlinable` constraints, configuration behavior, Index dependence, and
   the smallest safe change boundary. Do not classify from naming or reference count
   alone.
4. Verify whether the progress item “DebugとReleaseで公開protocol適合集合が変わる箇所を解消”
   should remain open solely because of intentional/deferred clusters, or whether an
   overlooked independent mismatch remains.
5. Recommend exactly one next action, or explicitly recommend closing the independent
   public-surface-cleanup phase until the Index/owner/external-consumer gates move.

## Output

Append a section named exactly:

`### Public-surface cleanup closure audit`

to `Maintanance/EXTERNAL_TYPE_EXTENSION_AUDIT.md`. Include a compact residual table,
accounting corrections, remaining gates, and one verdict:

- `independent cleanup remains`
- `independent cleanup complete; deferred gates only`
- `inventory inconsistency blocks closure`

Update `PROGRESS_OVERVIEW.md` and `RED_BLACK_TREE_REMAINING_TASKS.md` only if a stale
statement can be corrected without marking deferred work complete. Update this task
with concise evidence and set it to `Completed`.

## Boundaries

Only these files may be edited:

- `Maintanance/EXTERNAL_TYPE_EXTENSION_AUDIT.md`
- `Maintanance/PROGRESS_OVERVIEW.md`
- `Maintanance/RED_BLACK_TREE_REMAINING_TASKS.md`
- `Maintanance/CLAUDE_TASK.md`

Do not edit source, tests, Package.swift, CHANGELOG, workflows, benchmarks, or DocC.
Do not stage, commit, switch branches, use network access, inspect `try/index/1`, or
alter Git history. Do not run the full suite. Use source/configuration searches and
targeted typechecking only if a concrete classification cannot otherwise be resolved.
Run `git diff --check`, inspect the complete diff, and inspect `git status --short`.

Report only `完了` to the user. Put all details in Markdown. Explain directly only if
blocked or a product-owner decision is required.

### Result (2026-10-04, Claude Opus 5.5)

I appended `### Public-surface cleanup closure audit` to
`EXTERNAL_TYPE_EXTENSION_AUDIT.md`. Verdict: `independent cleanup remains`.

- **Inventory:** rebuilt Debug and Release from the current tree and re-extracted the
  symbol graphs. Effectively public symbols are now Debug 889 / Release 819 (Gate A:
  963 / 892). Release has 56 public protocols. All Debug-only differences belong to the
  deferred Balanced and Debug-Comparable clusters; nothing is Release-only.
- **Method for the protocol check:** for every public protocol, I checked whether any
  public signature, generic or extension constraint, or protocol inheritance references
  it, and whether any type conforms to it.
- **Independently actionable:** five 原木 protocols have no public-signature use and no
  production conformer:
  - `_BaseKey_EquivInterface`, `_BaseNode_PtrUniqueCompInterface`, and
    `_Base_MultiplicityHelperProtocol`: zero references anywhere.
  - `_pointer_type`: its only user is a `@usableFromInline package` protocol, so the
    floor is `@usableFromInline package`.
  - `_BaseNode_KeyProtocol`: used only by two same-package test fixtures.
- **Recommended next action:** narrow those five from `public` to `package`, without
  deleting them. Deleting would conflict with the 原木 reference/porting retention
  intent.
- **Left in B3:** 13 protocols that also lack public-signature use but do have
  conformers. Their extensions may supply witnesses for public protocol requirements,
  so they need a typecheck audit before they can be narrowed.
- **Accounting corrections recorded:** the original top table's ThreeWay rows and
  remaining-task lines 103-104 are stale after B4-a.
- **`PROGRESS_OVERVIEW.md`:** annotated the open Debug/Release checkbox to say that only
  the deferred clusters remain. It stays unchecked.
- Validation:
  - The temporary symbol-graph directory was removed.
  - `git diff --check` was clean.
  - `git status --short` shows only `CLAUDE_TASK.md`,
    `EXTERNAL_TYPE_EXTENSION_AUDIT.md`, and `PROGRESS_OVERVIEW.md` modified.

## Completed assignment: isolate obsolete iterator protocol layer

Isolate the obsolete iterator protocol layer to `COMPATIBLE_ATCODER_2025`, following
the completed disposition audit. Preserve generation-4 behavior and compatibility mode.

## Objective

Remove the uninhabited normal-mode public protocols and conditional conformances while
retaining the protocol layer required by deprecated AtCoder-2025 iterators.

## Allowed implementation

1. In `Iterator/UnsafeIterator/UnsafeIterator+Protocol.swift`:
   - put `ObverseIterator`, its default `Reversed` alias, and `ReverseIterator` under
     `#if COMPATIBLE_ATCODER_2025`;
   - remove the normal-mode `UnsafeIteratorProtocol` declaration;
   - preserve normal-mode `UnsafeAssosiatedIterator` exactly, including its spelling.
2. In `UnsafeIterator+Payload.swift`, `UnsafeIterator+Key.swift`,
   `UnsafeIterator+KeyValue.swift`, and `UnsafeIterator+MappedValue.swift`, place only
   the `ObverseIterator` / `ReverseIterator` conditional conformances under
   `COMPATIBLE_ATCODER_2025`. Do not guard or alter the wrapper types or their
   `UnsafeAssosiatedIterator` conformances used by generation 4.
3. In `UnsafeIterator+CopyOnWrite.swift`, remove only its two normal-mode conditional
   conformances to `ObverseIterator` and `ReverseIterator`. Preserve the type,
   `Sendable` conformance, storage/lifetime behavior, and generation-4 path.
4. Add a concise source-breaking normal-mode entry to `CHANGELOG.md`.
5. Append the implementation and exact validation results to
   `Maintanance/EXTERNAL_TYPE_EXTENSION_AUDIT.md`; update this task. Update an existing
   relevant checkbox in `PROGRESS_OVERVIEW.md` only if the wording becomes fully true.

## Must preserve

- `_Obverse4`, `_Reverse4`, `_CopyOnWrite`, `UnsafeAssosiatedIterator`, current
  container/View iterators, and all Index/Range behavior.
- Compatibility generations 1–3, deprecated aliases, wrapper conformances, and
  container `reversed()` return types.
- The four current-API C++ comparison files remain normal-mode-only.
- No decision about Index, Comparable, `Result`, or generation-3 deletion.

## Validation

1. Normal mode:
   - Debug build-tests;
   - targeted Sequence, reversed, RangeView, MappedValuesView, and
     ProtocolConformance tests;
   - Release `RedBlackTreeCollections` build;
   - Release DocC warnings-as-errors.
2. Compatibility mode with `-Xswiftc -DCOMPATIBLE_ATCODER_2025`:
   - build all tests;
   - run all 10 `NaiveIteratorTests`;
   - run the four containers' AtCoder2025 compatibility tests relevant to reversed
     wrappers. Existing Dictionary compatibility tests around reversed keys/values are
     known to exercise the wrapper witness; confirm discovery and execution rather than
     adding a duplicate test unless coverage is actually absent.
3. Search with configuration nesting in mind and confirm `ObverseIterator`,
   `ReverseIterator`, and `UnsafeIteratorProtocol` have no normal-mode declarations or
   references. `UnsafeAssosiatedIterator` must remain in normal mode.
4. Run `git diff --check`, inspect the complete diff and `git status --short`.

## Boundaries

Do not edit `Package.swift`, workflows, benchmarks, unrelated protocols or tests,
generation 1–4 implementations, container APIs, Views, Index code, or `try/index/1`.
Do not stage, commit, switch branches, use network access, or alter Git history. Avoid
whole-file reformatting; keep the source diff structural and minimal.

Set this task to `Completed` and report only `完了` to the user. Put details in the
Markdown records. Explain directly only if blocked or a product-owner decision is
required.

### Result (2026-10-04, Claude Opus 5.5)

All changes are structural and minimal; no existing lines were re-indented.

**Source changes** (under `Implements/Iterator/UnsafeIterator/`)

- `UnsafeIterator+Protocol.swift`:
  - wrapped `ObverseIterator`, its default `Reversed` alias, and `ReverseIterator` in
    `#if COMPATIBLE_ATCODER_2025`;
  - removed the normal-mode `UnsafeIteratorProtocol`;
  - left `UnsafeAssosiatedIterator` unchanged.
- `UnsafeIterator+{Payload,Key,KeyValue,MappedValue}.swift`: wrapped only the
  `ObverseIterator` / `ReverseIterator` conditional conformances in the compat guard.
- `UnsafeIterator+CopyOnWrite.swift`: deleted the two normal-only conditional
  conformances.

**Documentation**

- `CHANGELOG.md`: added an entry marked source-breaking in normal mode.
- `EXTERNAL_TYPE_EXTENSION_AUDIT.md`: appended `### Iterator protocol layer isolation
  result`.
- `PROGRESS_OVERVIEW.md`: left unchanged. No existing checkbox became fully true.

**Normal-mode validation**

- `swift build --disable-sandbox --build-tests`: succeeded.
- `swift test --disable-sandbox --skip-build --filter 'SequenceTests|Reversed|reversed|RangeView|MappedValuesView|ProtocolConformance'`:
  253 XCTest cases passed with 0 failures, plus 4 Swift Testing tests in 1 suite.
- `swift build --disable-sandbox -c release --target RedBlackTreeCollections`:
  succeeded.
- The CI Release DocC command with `--warnings-as-errors`: succeeded.

**Compatibility-mode validation**

- `swift build --disable-sandbox --build-tests -Xswiftc -DCOMPATIBLE_ATCODER_2025`
  (all test targets): succeeded.
- `swift test --disable-sandbox --skip-build --filter 'NaiveIteratorTests|AtCoder2025Compatibility'`:
  all passed with 0 failures:
  - `NaiveIteratorTests`: 10 tests;
  - `DictionaryAtCoder2025CompatibilityTests`: 5 tests;
  - `SetAtCoder2025CompatibilityTests`: 12 tests;
  - `MultiMapAtCoder2025CompatibilityTests`: 1 test.
- `--filter 'RedBlackTreeMultiset.*LegacyTests'`: 10 tests, 1 skipped, 0 failures.
- The reversed-wrapper witness test
  `RedBlackTreeDictionaryEtcAtCoder2025LegacyTests.testKeysAndValuesFunctionStyleReversed`
  was discovered and passed.
- Afterwards normal mode was rebuilt with `--build-tests`, restoring `.build`.

**Other checks**

- A scan that tracks `#if` nesting found 0 references to `ObverseIterator`,
  `ReverseIterator`, or `UnsafeIteratorProtocol` outside the compat guard.
  `UnsafeAssosiatedIterator` remains in normal mode.
- `git diff --check`: clean.
- Nothing was staged.

## Completed assignment: audit iterator protocol layer disposition

Audit the iterator protocol layer left behind after deprecated iterator generations
1–3 were isolated to `COMPATIBLE_ATCODER_2025`. This is a read-only disposition audit;
do not edit source or tests.

## Objective

Determine whether `UnsafeIteratorProtocol`, `ObverseIterator`, `ReverseIterator`, and
their conditional conformances/helpers can be isolated to compatibility mode, narrowed,
or removed from the normal build without affecting generation 4, current containers,
Views, or public iteration behavior.

## Required analysis

1. Enumerate the three protocols, every requirement/default implementation, every
   conforming type, and every generic constraint/reference in Sources, Tests,
   Benchmarks, DocC, and maintenance records.
2. Analyze normal mode and `COMPATIBLE_ATCODER_2025` separately. Verify rather than
   assume whether `_Obverse4`, `_Reverse4`, `_CopyOnWrite`, `_Payload`, `_Key`, and
   `_Value` use or conform to this protocol layer.
3. Separate:
   - protocol declarations and default implementations;
   - compatibility-only conformers and aliases;
   - conditional conformances/helpers that become uninhabited in normal mode;
   - code still required by the current generation-4 path.
4. Check access levels, public signatures, `@inlinable` references, serialized bodies,
   and source-compatibility impact. Underscore-prefixed public declarations still count
   as public surface.
5. Determine the smallest safe implementation batch. Prefer configuration isolation
   over deletion when compatibility mode still needs a declaration.
6. Identify exact tests needed in both modes, including whether the existing 10
   `NaiveIteratorTests` cover the compatibility witnesses sufficiently.
7. Keep this independent of the unresolved public Index/Comparable decision. If any
   proposed change actually depends on that decision, isolate it as a blocker instead
   of assuming an answer.

## Output

Append a section named exactly:

`### Iterator protocol layer disposition audit`

to `Maintanance/EXTERNAL_TYPE_EXTENSION_AUDIT.md`. Include a compact declaration /
reference table, normal-versus-compatibility findings, public-surface impact, proposed
file list, validation matrix, and one verdict:

- `compatibility-only isolation batch`
- `normal-mode narrowing batch`
- `safe removal batch`
- `Index decision required`
- `product-owner decision required`

Update this task with concise evidence and set it to `Completed` when done.

## Boundaries

Only these files may be edited:

- `Maintanance/EXTERNAL_TYPE_EXTENSION_AUDIT.md`
- `Maintanance/CLAUDE_TASK.md`

Do not edit source, tests, Package.swift, CHANGELOG, workflows, benchmarks, or other
documentation. Do not stage or commit, switch branches, use network access, inspect
`try/index/1`, or alter Git history. Do not run the full test suite; searches and
targeted compilation only if needed to resolve a concrete ambiguity are sufficient.
Run `git diff --check` on the two allowed files and inspect the full diff plus
`git status --short`.

Report only `完了` to the user. Put all details in the Markdown record. Explain directly
only if blocked or a product-owner decision is required.

### Result (2026-10-04, Claude Opus 5.5)

I appended `### Iterator protocol layer disposition audit` to
`EXTERNAL_TYPE_EXTENSION_AUDIT.md`. Verdict: `compatibility-only isolation batch`.

- **Normal mode:**
  - `ObverseIterator`, `ReverseIterator`, and the normal-mode `UnsafeIteratorProtocol`
    have no conforming types.
  - The 10 conditional conformances (on `_Payload`, `_Key`, `_KeyValue`, `_MappedValue`,
    and `_CopyOnWrite`) can never be satisfied.
  - Generation 4 (`_Obverse4` / `_Reverse4`) does not adopt these protocols. Normal-mode
    reverse iteration uses `_Reverse4` aliases directly.
  - `.Reversed` is used only by the four containers' compat-only `*+Deprecated.swift`
    files.
- **Compatibility mode:** it still needs `ObverseIterator` / `ReverseIterator` and the
  wrapper conformances. Its `UnsafeIteratorProtocol` is a separate declaration.
- **Required by generation 4:** `UnsafeAssosiatedIterator`. It stays.
- **Proposed batch:**
  - In `UnsafeIterator+Protocol.swift`, guard `ObverseIterator` / `ReverseIterator` with
    compat and drop the normal-mode `UnsafeIteratorProtocol`.
  - In `UnsafeIterator+{Payload,Key,KeyValue,MappedValue}.swift`, guard the conditional
    conformances with compat.
  - In `UnsafeIterator+CopyOnWrite.swift:72-85`, delete the two normal-only conditional
    conformances. They can never be satisfied, and they would no longer compile once the
    protocols are compat-only.
- **Test caveat:** the 10 `NaiveIteratorTests` never call a wrapper's `reversed()`.
  The implementation batch must confirm that some compat test reaches container
  `reversed() -> Tree._PayloadValues.Reversed`, or decide whether to add one.
- **Index dependence:** none.
- Validation:
  - Searches covered all four protocol names, `.Reversed` / `reversed()`, and the
    file-level guards of every deprecated iterator and container file, across `Sources`,
    `Tests`, `Benchmarks/Sources`, and the DocC/documentation Markdown.
  - No build was run.
  - `git diff --check` was clean.
  - `git status --short` shows only the two allowed files modified.

## Completed assignment: isolate deprecated iterator generations 1–3

Isolate deprecated iterator generations 1–3 to `COMPATIBLE_ATCODER_2025` without
deleting any generation or changing compatibility behavior.

## Objective

Remove `_Obverse1...3` and `_Reverse1...3` from the normal-mode compiled/public surface,
while retaining all six implementations and their existing tests in compatibility mode.

## Allowed implementation

1. Wrap each of these six complete files in `#if COMPATIBLE_ATCODER_2025`:
   - `UnsafeIterator+Obverse1.swift`, `Obverse2.swift`, `Obverse3.swift`
   - `UnsafeIterator+Reverse1.swift`, `Reverse2.swift`, `Reverse3.swift`
   under `Sources/RedBlackTreeCollections/Implements/Deprecated/Iterator/`.
2. Within generations 2 and 3, remove only branches that become unreachable because
   the complete file is compatibility-only. Preserve the compatibility branch bodies
   exactly. If removing an inner branch is less safe than retaining it, retain it and
   explain why; isolation is the required outcome, cleanup is secondary.
3. Put all tests in
   `Tests/RedBlackTreeTests/RedBlackTreeInternal/Instance/RedBlackTreeInternal_NaiveIteratorTests.swift`
   under `DEBUG && COMPATIBLE_ATCODER_2025`, retaining all 10 tests. Do not delete or
   rewrite generation 3 tests.
4. Add a concise source-breaking normal-mode isolation entry to `CHANGELOG.md`.
5. Append the implementation result and validation to
   `Maintanance/EXTERNAL_TYPE_EXTENSION_AUDIT.md`; update an existing relevant checkbox
   in `PROGRESS_OVERVIEW.md` only if accurate; update this task.

## Must preserve

- Compatibility mode's generation 1 `unsafeSequence` / `unsafeValues` behavior.
- Compatibility aliases and generation 2 behavior.
- Generation 3 source and its two tests; deletion requires a separate user decision.
- `_Obverse4`, `_Reverse4`, `_CopyOnWrite`, current container/View iterators, Index
  representation, and all iterator protocols.
- Do not act on the side finding about now-uninhabited normal-mode iterator protocols.

## Validation

1. Normal mode: Debug build-tests, relevant sequence/equality/comparison/hash/View tests,
   and Release `RedBlackTreeCollections` build.
2. Compatibility mode: use command-line compiler definition
   `-Xswiftc -DCOMPATIBLE_ATCODER_2025` if it reproduces the package's established mode
   without editing `Package.swift`; otherwise stop and report the exact blocker rather
   than modifying package configuration. Build tests and run the Naive iterator suite,
   confirming all 10 tests are discovered and pass.
3. Run Release DocC warnings-as-errors for normal mode.
4. Search the normal-mode source paths to confirm generations 1–3 are referenced only
   inside compatibility guards.
5. Run `git diff --check`, inspect the full diff and `git status --short`.

## Boundaries

Do not delete generation 3. Do not edit `Package.swift`, workflows, unrelated tests,
benchmarks, iterator protocols, or nondeprecated iterator implementations. Do not stage,
commit, use network access, switch branches, inspect `try/index/1`, or alter Git history.

Set this task to `Completed`, append exact commands and results, and report only `完了`
to the user. Explain directly only if blocked or a product-owner decision is required.

### Result (2026-10-04, Claude Opus 5.5)

Isolation is done. A follow-up by Codex made the current-API C++ comparison tests
normal-mode-only, closing the compatibility-mode validation gap.

**Changes**

- The six files under `Implements/Deprecated/Iterator/` are each wrapped entirely in
  `#if COMPATIBLE_ATCODER_2025`.
- Inside generations 2 and 3 there were six inner `#if COMPATIBLE_ATCODER_2025` /
  `#else` blocks. The compatibility branch bodies are kept. Only the now-unreachable
  `#else` side was removed: the normal-mode `_start` / `_end` and `reversed()`. The
  whitespace-insensitive diff contains only these.
- Generation 3 is kept.
- The Naive iterator tests now sit under `#if DEBUG && COMPATIBLE_ATCODER_2025`, and all
  10 tests are retained.
- Documentation:
  - `CHANGELOG.md`: added an entry marked source-breaking in normal mode;
  - `PROGRESS_OVERVIEW.md`: checked one item;
  - `EXTERNAL_TYPE_EXTENSION_AUDIT.md`: appended `### Deprecated iterator generations 1–3
    isolation result`.

**Normal-mode validation**

- `swift build --disable-sandbox --build-tests`: succeeded.
- `swift test --disable-sandbox --skip-build --filter 'SequenceTests|Equatable|Comparable|Hashable|ProtocolConformance|RangeView|MappedValuesView|NaiveIterator'`:
  256 RedBlackTreeTests and 2 RedBlackTreeTreeTests XCTest cases, plus 1 Swift Testing
  test, all passed with 0 failures. NaiveIteratorTests was absent, as expected.
- `swift build --disable-sandbox -c release --target RedBlackTreeCollections`:
  succeeded.
- The CI Release DocC command with `--warnings-as-errors`: succeeded.
- A scan that tracks `#if` nesting confirmed that every reference to generations 1–3 in
  `Sources` and `Tests` is inside a `COMPATIBLE_ATCODER_2025` guard.

**Compatibility-mode validation**

- `swift build --disable-sandbox --target RedBlackTreeTests -Xswiftc -DCOMPATIBLE_ATCODER_2025`
  succeeded, so the six types and the Naive iterator tests compile in this mode.
- Codex wrapped the four current-API behavior-comparison files in
  `#if !COMPATIBLE_ATCODER_2025`; these tests compare the current Swift API with libc++
  and do not define a legacy compatibility contract.
- `swift build --disable-sandbox --build-tests -Xswiftc -DCOMPATIBLE_ATCODER_2025`
  then succeeded.
- `swift test --disable-sandbox --skip-build -Xswiftc -DCOMPATIBLE_ATCODER_2025
  --filter NaiveIteratorTests` discovered and passed all 10 tests.
- After returning to normal mode, `swift test --disable-sandbox --filter
  CppBehaviorReferenceTests` discovered and passed all 35 C++ comparison tests.

**Other checks**

- `git diff --check`: clean, after removing trailing whitespace from one whitespace-only
  line that re-indentation had produced.
- Nothing was staged.

## Completed assignment: audit deprecated iterator generations 1–3

Perform a read-only disposition audit of deprecated iterator implementations
`_Obverse1` through `_Obverse3` and `_Reverse1` through `_Reverse3` in the default
RedBlackTreeCollections build.

## Objective

Determine why these deprecated iterator generations remain in the normal build and
whether the next safe action is deletion, compatibility-only isolation, TestSupport
relocation, or continued deferral. Do not implement the disposition in this task.

## Required work

1. Enumerate the six types, their files, guards, access levels, stored representations,
   protocol conformances, public/internal members, and all repository references.
2. Identify which iterator generation is used by the four current containers and Views,
   and whether `_Obverse4` / the current reverse path fully supersedes generations 1–3.
3. Check normal mode, `COMPATIBLE_ATCODER_2025`, Debug/Release, tests, documentation,
   and benchmarks separately. Do not infer compatibility use merely from a Deprecated
   directory or filename.
4. Compare observable behavior that might prevent removal: traversal direction,
   start/end handling, stale/sealed pointer behavior, ownership/lifetime, mutation,
   iterator protocol requirements, and complexity.
5. Determine whether any public alias, signature, `@inlinable` body, protocol witness,
   serialized layout, or external compatibility promise still exposes these types.
6. Separate Index-dependent issues from purely dead or compatibility-only code. Do not
   decide the final Index representation.
7. Propose the smallest implementation batch, exact files, required test migration or
   replacement evidence, validation matrix, and source-compatibility impact.

Use `Maintanance/EXTERNAL_TYPE_EXTENSION_AUDIT.md` and
`Maintanance/RED_BLACK_TREE_REMAINING_TASKS.md` as current records. Preserve the user's
existing iterator design intent where source/history in the repository establishes it;
do not classify by reference count alone.

## Output

Append one section named exactly:

`### Deprecated iterator generations 1–3 disposition audit`

to `Maintanance/EXTERNAL_TYPE_EXTENSION_AUDIT.md`. Include a compact type/reference
table, supersession evidence, configuration findings, blockers, recommended batch, and
one verdict:

- `safe independent removal batch`
- `compatibility-only isolation batch`
- `test-support relocation batch`
- `Index decision required`
- `product-owner decision required`

## Boundaries

Only these files may be edited:

- `Maintanance/EXTERNAL_TYPE_EXTENSION_AUDIT.md`
- `Maintanance/CLAUDE_TASK.md`

Do not edit source, tests, Package.swift, documentation, CHANGELOG, workflows, or
benchmarks. Do not run the full suite. Do not stage or commit. Do not use network access,
switch branches, inspect `try/index/1`, or alter Git history.

Re-run searches sufficient to support completeness, run `git diff --check` on the two
allowed files, and inspect their full diff plus `git status --short`. Set the task to
`Completed`, append concise evidence, and report only `完了` to the user. Explain
directly only if blocked or a product-owner decision is required.

### Result (2026-10-04, Claude Opus 5.5)

- I appended `### Deprecated iterator generations 1–3 disposition audit` to
  `EXTERNAL_TYPE_EXTENSION_AUDIT.md`. Verdict: `compatibility-only isolation batch`.
- **Normal mode:** all six types are compiled as public types, yet production does not
  use them. The current containers and Views use `_Obverse4` / `_Reverse4` through
  `_CopyOnWrite`, and the normal-mode `unsafeSequence` / `unsafeValues` return
  `_Obverse4`. The only normal-mode consumer is the Debug test
  `RedBlackTreeInternal_NaiveIteratorTests.swift:17-82` (8 tests).
- **Compatibility mode:**
  - Generation 1 backs compat `unsafeSequence` / `unsafeValues`, which the tree's
    `==`, `<`, hash, filter, and key/value helpers use.
  - Generation 2 backs the compat public aliases `_RemoveAware*` / `TiedIndexing`.
  - Generation 3 is unused in both modes.
- **Recommended batch:**
  - Wrap all six files in `#if COMPATIBLE_ATCODER_2025` and drop the now-dead
    normal-mode `#else` members.
  - Move the normal-mode Naive iterator tests under the same guard, so no coverage is
    lost.
  - Deleting generation 3 is optional and needs approval first, because it removes 2
    tests.
- **Index dependence:** none. Isolating chooses no Index representation.
- **Side finding:** after isolation, `UnsafeIteratorProtocol`, `ObverseIterator`, and
  `ReverseIterator` have no conformers in normal mode. That is for a separate audit.
- Validation:
  - Searches covered `_Obverse/_Reverse 1–3`, `unsafeSequence` / `unsafeValues`,
    `_RemoveTrait` / `_RemoveAware*`, and the iterator protocols, across `Sources`,
    `Tests`, `Benchmarks/Sources`, and repository Markdown.
  - No build or test was run.
  - `git diff --check` was clean.
  - `git status --short` shows only the two allowed files modified.

## Completed assignment: narrow Debug-only Bound fixtures

Narrow the two Debug-only `RedBlackTreeBoundExpression` fixture constructors from
client-visible public API to package-only API, without changing their behavior or the
other Debug-only clusters.

## Objective

Change only `index(_:)` and `debug(_:)` under `#if DEBUG` from
`@inlinable public static` to `@inlinable package static`. Preserve their bodies,
internal enum cases, evaluation behavior, and all callers.

## Allowed changes

- `Sources/RedBlackTreeCollections/Implements/BoundsExpression/RedBlackTreeBoundExpression.swift`
- `CHANGELOG.md`
- the relevant current-state row or note in
  `Maintanance/EXTERNAL_TYPE_EXTENSION_AUDIT.md`
- `Maintanance/PROGRESS_OVERVIEW.md` only if an existing checklist/status statement can
  be accurately advanced without rewriting unrelated history
- `Maintanance/CLAUDE_TASK.md`

The intended source change is exactly the two access modifiers. Tests should not need
editing because every caller belongs to this Swift package and package access is the
required floor for the non-`@testable` numbered specification test.

## Must preserve

- Keep `#if DEBUG`, `@inlinable`, signatures, bodies, `Internal.index` / `.debug`, and
  `UnsafeTreeV2` evaluation unchanged.
- Do not touch the `Balanced*` executable API Matrix, its conformances,
  `freeCapacity`, or `popFirst(_:)` / `popLast(_:)`.
- Do not touch `Result` retroactive conformance, `_LazyTieWrap`, `_NodePtrSealing`,
  `_LazyTie`, public Index representation, Range/View contracts, or compatibility mode.

## Do not

- Do not edit `Package.swift`, workflows, benchmarks, API Matrix documents, or tests.
- Do not perform unrelated cleanup.
- Do not stage or commit files and do not perform branch/history/network operations.
- Do not inspect `try/index/1`.

## Validation

1. Build tests in Debug.
2. Run the numbered Set Bound Expression tests and the four container
   `*_98_InternalTests` that use `.index` / `.debug`; confirm intended tests were
   discovered and executed.
3. Build `RedBlackTreeCollections` in Release.
4. Run the established Release DocC warnings-as-errors command.
5. Run `git diff --check`, inspect the complete diff, and confirm that only allowed
   files changed.

Record the access-floor evidence, exact commands, test discovery/counts, and results.
Set this task to `Completed` and report only `完了` to the user. Explain directly only
if blocked, if an unrelated regression appears, or if a product-owner decision is
required.

### Result (2026-10-04, Claude Opus 5.5)

- Changed `RedBlackTreeBoundExpression.swift:209,214` (`index(_:)`, `debug(_:)`) from
  `@inlinable public static` to `@inlinable package static`. Nothing else in source
  changed.
- Access-floor evidence: `RedBlackTreeSet_16_BoundExpressionTests` imports without
  `@testable` and still compiles unchanged, which requires `package`. The four
  `*_98_InternalTests` use `@testable`.
- Documentation updated:
  - `CHANGELOG.md`: added an Unreleased / Changed entry (Debug-only source break);
  - `PROGRESS_OVERVIEW.md`: added one checked item to the existing public-surface
    checklist;
  - `EXTERNAL_TYPE_EXTENSION_AUDIT.md`: appended `### Bound index / debug implementation
    result`. That file's earlier uncommitted diff is the previous audit section.
- Validation:
  - `swift build --disable-sandbox --build-tests` (Debug): succeeded.
  - `swift test --disable-sandbox --skip-build --filter 'RedBlackTreeSetBoundExpressionTests|InternalTests'`:
    - XCTest: `RedBlackTreeSetBoundExpressionTests`, 27 tests, 0 failures.
    - Swift Testing: `RedBlackTree{Set,MultiSet,Dictionary,MultiMap}InternalTests`,
      4 tests in 4 suites, all passed.
  - `swift build --disable-sandbox -c release --target RedBlackTreeCollections`:
    succeeded.
  - The CI Release DocC `generate-documentation ... --warnings-as-errors` command:
    succeeded.
  - `git diff --check`: clean.
  - Changed files are only the allowed ones: source file, `CHANGELOG.md`, the audit,
    `PROGRESS_OVERVIEW.md`, and this file. Nothing was staged.

## Completed assignment: audit Debug / Release public-surface differences

Perform a read-only decision audit of the Debug-only public surface in
RedBlackTreeCollections, separating work that is safe before the public Index decision
from work that must remain deferred.

## Objective

Produce the next bounded implementation recommendation for eliminating unintended
Debug/Release API differences. Do not change source, tests, access levels, or build
configuration in this task.

## Scope

Audit these known groups as coherent dependency clusters:

1. `BalancedSequence`, `BalancedCollection`, `BalancedMultiCollection`, `BalancedView`,
   `BalancedDynamic`, `BalancedSomething`, their container/View conformances, and
   `RedBlackTreeSet.freeCapacity`.
2. Debug-only `RedBlackTreeBoundExpression.index(_:)` and `.debug(_:)`.
3. Debug-only comparison declarations involving `Result`, `_LazyTieWrap`,
   `_NodePtrSealing`, and their conformances.

Product-owner clarification for cluster 1: the `Balanced*` protocols are an executable,
source-level API Matrix. Their purpose is to make the compiler verify that the intended
container/View API families remain present and mutually aligned. Do not classify them
as unused abstraction merely because production algorithms do not consume them.

Use these records as the starting point:

- `Maintanance/EXTERNAL_TYPE_EXTENSION_AUDIT.md`
- `Maintanance/RED_BLACK_TREE_REMAINING_TASKS.md`
- `Maintanance/PROGRESS_OVERVIEW.md`
- `Tests/TESTING.md`

Inspect relevant production declarations, direct and generic callers, numbered tests,
Debug additionals, compatibility guards, `@inlinable` visibility requirements, and
public signatures. Repository-local evidence only; no network access.

## Required analysis

For each cluster, record:

- exact declarations and guards;
- why it exists and every repository consumer;
- whether it affects observable product semantics or is test/debug instrumentation;
- whether moving it to TestSupport, narrowing it, deleting it, or making it consistent
  across Debug/Release is mechanically possible;
- whether it depends on the unresolved public Index representation, `Index: Comparable`,
  Range/View contracts, compatibility mode, or performance design;
- the smallest independent implementation batch, required files, expected validation,
  and source-compatibility impact.

Do not treat all Debug-only declarations as one batch merely because they share a guard.
In particular:

- Preserve the compile-time API-matrix function of the `Balanced*` cluster. Compare the
  tradeoffs of keeping it Debug-only in production source versus relocating an
  equivalent compile-time contract to test support, but do not recommend deletion
  unless an equally comprehensive compiler-checked replacement is identified.
- Treat `freeCapacity` as part of that executable contract even if it has no runtime
  caller. Determine whether it expresses an intended API requirement or an obsolete
  matrix row; do not infer the answer from reference count alone.
- Do not remove or redesign the retroactive `Result: Comparable` conformance; classify
  it as Index-dependent unless source evidence proves otherwise.
- Do not remove `freeCapacity` independently from the `BalancedDynamic` requirement.
- Do not decide the final public Index representation or Comparable policy.
- Do not turn Debug-only diagnostics into Release product API merely to equalize symbol
  graphs.

## Output

Append one concise section named exactly:

`### Debug / Release public-surface decision audit`

to `Maintanance/EXTERNAL_TYPE_EXTENSION_AUDIT.md`. Include:

1. a dependency table for the three clusters;
2. confirmed independent work, if any;
3. deferred Index/product decisions;
4. one recommended next implementation batch, or an explicit finding that none is safe;
5. one verdict:
   - `independent implementation batch available`
   - `all remaining work is decision-bound`
   - `product-owner decision required`

If an independent batch is recommended, its boundary must compile without changing the
other two clusters.

## Boundaries

The only files this task may edit are:

- `Maintanance/EXTERNAL_TYPE_EXTENSION_AUDIT.md`
- `Maintanance/CLAUDE_TASK.md`

Do not edit source, tests, `Package.swift`, workflows, API matrices, CHANGELOG, or other
management documents. Do not run the full test suite. Do not stage files. Do not commit,
push, pull, merge, rebase, switch branches, inspect `try/index/1`, or alter Git history.

## Validation and handoff

Re-run searches covering every declaration and repository reference used by the
conclusion. Run `git diff --check` on the two allowed files and inspect their complete
diff plus `git status --short`. Tests are not required for this read-only audit.

Set this task to `Completed`, append a concise result and validation evidence below the
assignment, and report only `完了` to the user. Explain directly only if blocked, if a
safety issue is found, or if a product-owner decision is required.

### Result (2026-10-04, Claude Opus 5.5)

I appended `### Debug / Release public-surface decision audit` to
`EXTERNAL_TYPE_EXTENSION_AUDIT.md`. Verdict: `independent implementation batch available`.

- **Cluster 1 (Balanced\* protocols + `freeCapacity`):** moving it to TestSupport is
  mechanically possible, but two decisions block it.
  - The numbered spec test `RedBlackTreeMultiMap_8_RangeViewTests.swift:68-82` uses the
    Debug-only `popFirst(_ k:)` / `popLast(_ k:)`. The TODO in their source says they are
    wrong, so what happens to them is a spec decision.
  - The performance TODO says removing the conformances hurts performance, but the
    conformances exist only in Debug, so they cannot affect Release performance. Removing
    that TODO contradicts the owner's note.
  - Its Index requirement is `Equatable` only, so this cluster does not depend on
    `Comparable`.
- **Cluster 2 (Debug `RedBlackTreeBoundExpression.index(_:)` / `.debug(_:)`):** this is
  the recommended next batch.
  - Change both from `@inlinable public static` to `@inlinable package static` in
    `RedBlackTreeBoundExpression.swift:208-216`.
  - All callers are tests in this package. `RedBlackTreeSet_16_BoundExpressionTests`
    imports without `@testable`, which is why the floor is `package` rather than
    `internal`.
  - No test edits are needed, the other clusters stay untouched, and the Release surface
    does not change.
  - Gate A had listed these two as waiting on the Index contract. I revised that,
    because narrowing access does not fix the Index representation.
- **Cluster 3 (Debug Comparable declarations: `Result` retroactive, `_LazyTieWrap`,
  `_NodePtrSealing`, `_LazyTie`):** deferred until the Comparable policy and Index
  representation are decided. Its consumers are the numbered test
  `RedBlackTreeSet_9_ProtocolConformanceTests:66-71` and `TreeFoundamentalNodeSealingTests`.

Validation:

- Searches covered Balanced\*, `freeCapacity`, `popFirst(k)` / `popLast(k)`,
  bound `.index` / `.debug` forms (explicit and implicit-member), and the Debug
  Comparable declarations plus their users. They ran over `Sources`, `Tests`,
  `Benchmarks/Sources`, and repository Markdown.
- No build or test was run.
- `git diff --check` on both allowed files was clean.
- `git status --short` shows only `Maintanance/CLAUDE_TASK.md` and
  `Maintanance/EXTERNAL_TYPE_EXTENSION_AUDIT.md` modified.

## Completed assignment: narrow View `_isIdentical(to:)`

Narrow the normal-mode View-only `_isIdentical(to:)` hooks from public API to the
minimum visibility required by their public `@inlinable` comparison operators.

## Objective

Remove the three underscored View identity hooks from the client-visible API without
changing View equality, ordering, complexity, compatibility mode, or the four
containers' documented `isTriviallyIdentical(to:)` API.

## Context

- Branch: `develop/misc/48`. The working tree was clean when assigned.
- Codex independently confirmed that normal mode has three relevant declarations:
  KeyOnly Range View, KeyValue Range View, and MappedValues View.
- KeyOnly and KeyValue call the hook from public `@inlinable` `==` / `<`; MappedValues
  has no repository caller. No public protocol requires the hook.
- This batch is independent of the unresolved public Index representation decision.
- The four containers' non-underscored `isTriviallyIdentical(to:)` is intentional,
  documented public API and is not part of this change.

## Allowed changes

1. In these three normal-mode files only, replace `public` on `_isIdentical(to:)` with
   the narrowest compiler-valid visibility required by serialized callers, expected to
   be `@usableFromInline internal`, while preserving `@inlinable` and the implementation:
   - `Sources/RedBlackTreeCollections/RedBlackTreeView/RedBlackTreeRangeView+KeyOnly.swift`
   - `Sources/RedBlackTreeCollections/RedBlackTreeView/RedBlackTreeRangeView+KeyValue.swift`
   - `Sources/RedBlackTreeCollections/RedBlackTreeView/RedBlackTreeMappedValuesView.swift`
2. Update the `_isIdentical(to:)` row in
   `Sources/RedBlackTreeCollections/Documentation/API-Matrix.md` so it records the
   completed narrowing rather than listing it as an unresolved public audit candidate.
3. Add a concise source-breaking public-surface narrowing entry to `CHANGELOG.md`.
4. Append a concise implementation result to
   `Maintanance/EXTERNAL_TYPE_EXTENSION_AUDIT.md`, including exact declarations,
   validation, and the fact that compatibility-mode declarations were untouched.
5. Update this task with the result and validation evidence.

## Must preserve

- Do not change `isTriviallyIdentical(to:)` on Set, MultiSet, Dictionary, or MultiMap.
- Do not change compatibility-mode `_isIdentical` declarations under
  `Implements/Deprecated`.
- Do not change method bodies, equality/ordering semantics, raw range representation,
  Index representation, protocols, or generic constraints.
- Preserve unrelated user changes and existing completed audit records.

## Do not

- Do not perform unrelated cleanup or documentation rewrites.
- Do not edit `Package.swift`, workflows, benchmarks, or tests unless compilation proves
  a narrowly scoped test edit is indispensable; stop and record the reason before doing
  so.
- Do not commit, push, pull, merge, rebase, switch branches, or alter Git history.
- Do not stage files.
- Do not inspect or modify `try/index/1`.

## Validation

Run the narrowest checks first, then confirm the batch across its serialization boundary:

1. Refresh/compile the three changed source files or build `RedBlackTreeCollections` in
   Debug.
2. Run the existing Range View and MappedValues View tests, confirming intended tests
   were actually discovered and executed.
3. Build `RedBlackTreeCollections` in Release.
4. Validate Release DocC with warnings as errors using the repository's established
   command if it is available without changing configuration.
5. Run `git diff --check` and inspect `git status --short` plus the complete diff.

If `@usableFromInline internal` does not compile, do not broaden visibility by guesswork.
Record the compiler evidence and choose only the narrowest visibility demonstrably
required by the public `@inlinable` callers.

## Handoff

Set this task to `Completed`, append a concise result and exact validation commands
below this assignment, and report only `完了` to the user. Put all technical detail in
this Markdown file. Explain directly only if blocked, if an unrelated regression is
found, or if a product-owner decision is required.

### Result (2026-10-04, Claude Opus 5.5)

- Narrowed `public func _isIdentical(to:)` to `internal func` in three files, keeping
  `@inlinable` and the bodies unchanged:
  - `RedBlackTreeView/RedBlackTreeRangeView+KeyOnly.swift:351`
  - `RedBlackTreeView/RedBlackTreeRangeView+KeyValue.swift:422`
  - `RedBlackTreeView/RedBlackTreeMappedValuesView.swift:351`
- Why the access is `@inlinable internal` rather than `@usableFromInline internal`: an
  internal `@inlinable` declaration is already usable from inlinable code, so the public
  `@inlinable` `==` / `<` can still call it, and the Release build compiles. Adding
  `@usableFromInline` would be redundant. No caller elsewhere in the package needs
  `package` access.
- Left unchanged:
  - the compatibility-mode `_isIdentical` declarations under `Implements/Deprecated`;
  - the four containers' `isTriviallyIdentical(to:)`;
  - tests, benchmarks, and `Package.swift`.
- Documentation updated:
  - `Sources/RedBlackTreeCollections/Documentation/API-Matrix.md`: the
    `_isIdentical(to:)` row now records the completed narrowing;
  - `CHANGELOG.md`: added an `Unreleased` / `Changed` entry marked source-breaking;
  - `Maintanance/EXTERNAL_TYPE_EXTENSION_AUDIT.md`: appended
    `### _isIdentical implementation result`.
- Validation:
  - `swift build --disable-sandbox --target RedBlackTreeCollections` (Debug): succeeded.
  - `swift build --disable-sandbox --build-tests` (Debug): succeeded.
  - `swift test --disable-sandbox --skip-build --filter 'RangeView|MappedValuesView'`:
    98 RedBlackTreeTests XCTest cases passed with 0 failures, plus 1 Swift Testing test.
    The discovered suites included KeyOnly, KeyValue, and MappedValues View tests, and
    the Set, MultiSet, Dictionary, and MultiMap Range View tests.
  - `swift build --disable-sandbox -c release --target RedBlackTreeCollections`:
    succeeded.
  - The CI Release DocC command (`swift package --disable-sandbox -c release ...
    generate-documentation --target RedBlackTreeCollections --output-path
    .build/documentation --transform-for-static-hosting --hosting-base-path
    swift-ac-collections --warnings-as-errors`) succeeded. Its output went to the
    existing `.build/documentation` path.
  - `git diff --check`: clean.
  - `git status --short` shows only the seven intended files modified. Nothing was
    staged.

## Completed assignment: review of the RedBlackTree Index decision gate

Perform a read-only review of `### C〜F 調査結果と暫定推奨` in:

- `Maintanance/RED_BLACK_TREE_REMAINING_TASKS.md`

The product owner uses apple/swift-collections' `Sources/ContainersPreview` as the
upstream design reference. We should track and learn from the experimental protocol as
it evolves, permit small disposable compatibility experiments, and avoid finalizing the
production Index representation until the requirements are sufficiently stable. The
current nominal/non-Comparable/non-failure-valued design is a provisional recommendation.

Check specifically:

1. whether all four normal-mode containers and all Range/MappedValues Views can retain
   their documented APIs without `Index: Comparable`;
2. whether any public generic constraint, operator, range expression, benchmark,
   external compatibility surface, or planned conformance actually requires
   `Comparable`;
3. whether removing failure-valued public Index loses any intentional behavior of
   movement, bounds evaluation, stale-index diagnostics, or cross-tree resolution;
4. whether `Equatable` / `Hashable` can honestly remain O(1), including storage identity,
   generation, `endIndex`, and `ALLOW_CROSS_TREE_INDEX` behavior;
5. whether the proposed public/internal boundary is implementable without exposing
   `_LazyTieWrap`, `_NodePtrSealing`, `UnsafeNode`, `SealError`, or `Result` through
   public signatures or `@inlinable` bodies;
6. source-compatibility and migration risks that must be explicit before implementation;
7. whether any work in C〜F remains safe and useful now without prematurely choosing the
   future Container conformance or Index representation;
8. whether the new `Container protocol追跡基準` accurately reflects current upstream,
   especially `Index: Equatable & Hashable` without `Comparable`, and whether span/lifetime
   requirements create a separate blocker for this node-based tree;
9. the existing `try/index/1` preparation implementation, using its merge-base with HEAD
   and only the Index-related diff. Confirm what it already proves, what is obsolete, and
   what blocks reuse on current HEAD. Pay particular attention to `_LazyTiedPtr`, internal
   resolver Results, `try!`, bare `fatalError()`, the Debug `.nullptr` sentinel, the
   sanitizer TODO, and O(1) equality/hash claims. Do not merge or modify that branch.

Do not edit source, tests, access levels, Package.swift, the proposed section, or another
document. Do not implement or benchmark a prototype and do not reopen Memoize/B4 work.
Append only `### Claude review of C〜F Index decision gate` immediately before
`### 主経路のチェックリスト` in the same file. Separate blocking corrections,
non-blocking safeguards, confirmed findings, and give one verdict:

- `tracking boundary is correct`
- `decision boundary needs correction`

Then set this task to Completed, append a concise result below this assignment, and
report only `完了` to the user. All detail belongs in the Markdown record.

### Result (2026-10-04, Claude Opus 5.5)

Appended `### Claude review of C〜F Index decision gate` before `### 主経路のチェックリスト`.
The review was read-only: no build, test, or prototype was run. Upstream evidence came
only from the in-repo checkouts: swift-collections 1.7.0 (`a66de878`, pinned by
`Benchmarks/Package.resolved`) and a 2026-05 snapshot.

Verdict: `decision boundary needs correction`. Blocking corrections:

1. Upstream 1.7.0 `Container.Index` is `Equatable, Comparable, Hashable`, and
   `RangeExpression2` also requires `Comparable`. The 2026-05 snapshot had `Equatable`
   only, so Comparable was added, not removed. Cite a newer upstream commit or correct
   the tracking criteria.
2. Rejecting a stale index before dereference fails under the `_O_UNCHECKED` trait. The
   subscript validates with `precondition` followed by `pointer!`, and `-Ounchecked`
   removes both checks. E's "precondition failure" would carry the same gap into the
   contract.
3. With `ALLOW_CROSS_TREE_INDEX`, an old index still resolves in a CoW copy but compares
   unequal to that copy's indices. F must define `==` as token identity. The hash
   description in C is also inaccurate: it does not include storage identity.
4. `try/index/1` still publicly aliases `_LazyTieWrap`. It is a partial Result-removal
   PoC, not a nominal-type PoC.

Non-blocking points cover:

- compat-mode Comparable;
- the Debug Comparable numbered spec test;
- source-migration items;
- `@frozen` having no effect without library evolution, and `@inlinable` bodies still
  serializing internals;
- HEAD's bare `fatalError()` and the double `adv_iter` call in `form_index`;
- span and lifetime as a separate blocker.

Reuse blockers in `try/index/1`:

- `try!` without diagnostic messages;
- the Debug `.nullptr` sentinel, which reintroduces a failure state;
- an assert weakened around a sanitizer report (suspected early release);
- missing MappedValuesView;
- stale paths and duplicated overloads.

## Completed assignment: adversarial review of Gate B classification draft

Read-only review the new `## Gate B classification draft` in:

- `Maintanance/EXTERNAL_TYPE_EXTENSION_AUDIT.md`

Check whether Codex has classified any declaration as Index-independent when it is
actually required by the current or candidate Index/Range/View surface, or proposed a
batch that cannot compile independently. Focus on B4-a through B4-e, the boundary
between B2 and B3, and the claim that B4-a is the safest first implementation unit.

Use source/reference evidence. Verify especially `@inlinable` / `@usableFromInline`
constraints, public protocol requirements, benchmark target access, production vs
experimental `___meld_unique`, Memoize references, and Debug-only APIs. Do not edit the
draft, source, tests, access levels, or Package.swift; do not run the full suite.

Append only `### Claude review of Gate B draft` after the draft verdict, containing
blocking corrections, non-blocking safeguards, confirmed classifications, and a verdict
on whether B4-a may become the first implementation work order. Then mark this task
Completed and report only `完了` to the user.

### Result (2026-10-04, Claude Opus 5.5)

Appended `### Claude review of Gate B draft` to `EXTERNAL_TYPE_EXTENSION_AUDIT.md`. The
review was read-only: no build or test was run, and no source, test, or `Package.swift`
was edited.

Blocking corrections:

1. B4-d: `freeCapacity` exists only to satisfy the Debug `BalancedDynamic` requirement,
   so it cannot be removed independently. Move it to B5 with the Balanced group.
2. B4-e has two problems:
   - It is not Index-independent: `_Indices.next()` returns `UnsafeIndexV3`, and
     `__raw_find` returns `UnsafeMutablePointer<UnsafeNode>`.
   - The `Benchmarks/` client is a separate package, so it can never use `package` or
     test-support access.
3. B2 and B3 overlap: B3 lists `UnsafeNode` and `_RawRange*`, which are Index layout and
   range storage, and `UnsafeTreeV2.Index` belongs to B2.

Verdict: B4-a may be the first work order, under these conditions:

- the narrowing floor is `@usableFromInline package`, because tests in three targets use
  these declarations directly;
- the order states whether `__eager_compare_result` is included;
- the three test targets are built and run in both Debug and Release;
- the design document and CHANGELOG are synchronized.

B4-b (Memoize) is technically separable but needs a product-owner decision, because it
was published in 0.1.33 as a feature.

## Completed assignment: close RedBlackTree public-surface inventory gate A

Perform the final read-only mechanical extraction for gate A of
`Maintanance/RED_BLACK_TREE_REMAINING_TASKS.md`.

Primary record:

- `Maintanance/EXTERNAL_TYPE_EXTENSION_AUDIT.md`

Inspect `Sources/RedBlackTreeCollections` and enumerate declarations that can affect
clients before Codex classifies or narrows them. Cover at least:

- public members and types whose names begin with `_` or `__`;
- public `Unsafe*`, `SealError`, public typealiases, global functions and operators;
- extensions of standard-library-owned types, including split-line access modifiers;
- public and retroactive protocol conformances;
- declarations exposed through a public typealias or public signature;
- `@frozen`, `@inlinable`, and `@usableFromInline` declarations relevant to client
  compatibility;
- differences under DEBUG / Release, `COMPATIBLE_ATCODER_2025`,
  `ALLOW_CROSS_TREE_INDEX`, `USE_LAZY_DETACH`, and compact metadata branches.

This is inventory only. Do not decide what should remain public, edit source/tests,
move TestCode, run the suite, change access levels, or act on Index-dependent groups.
Do not inspect unrelated module APIs except where `AcCollections` re-exports the
RedBlackTree surface.

Append a bounded `## Gate A final extraction` section to
`EXTERNAL_TYPE_EXTENSION_AUDIT.md`. It must contain:

- newly found omissions with source/line evidence;
- existing rows confirmed complete;
- configuration-only surface differences;
- an explicit list of declarations whose classification must wait for the Index
  contract;
- a verdict: `complete for classification` or `not complete`, with exact blockers.

Do not rewrite the existing audit table. If there are no omissions, say so and record
the extraction method. Then change this task status to `Completed`, append a concise
result here, and report only `完了` to the user.

### Result (2026-10-04, Claude Opus 5.5)

- Appended `## Gate A final extraction` to `EXTERNAL_TYPE_EXTENSION_AUDIT.md`. The
  existing table was not rewritten.
- Method: `swift build --target RedBlackTreeCollections` in Debug and Release, plus
  Debug variants with `-Xswiftc -D{COMPATIBLE_ATCODER_2025,USE_LAZY_DETACH,USE_COMPACT_NODE_METADATA}`.
  The default Debug was rebuilt afterward. Symbol graphs were extracted with
  `swift-symbolgraph-extract -minimum-access-level internal` into a `mktemp -d` directory,
  filtered to effectively public symbols, and the directory was then deleted.
  Disabled `ALLOW_CROSS_TREE_INDEX` and `BENCHMARK` were checked from source only.
- Result: all stdlib-type extension rows were confirmed. The `UnsafeMutablePointer` helper
  row is mostly `package`, not "internal-centred". There are 13 omission groups. The main ones:
  - the Debug `Result: Comparable` is generic over every `Result` whose `Success` and
    `Failure` are `Comparable`;
  - Debug-only public `Balanced*` protocols and container conformances, Debug-only
    `RedBlackTreeSet.freeCapacity`, and `BoundExpression.index`/`.debug`;
  - 60 public protocols (45 underscore-named);
  - `UnsafeTreeV2`/`UnsafeNode` public members;
  - deprecated `_Obverse1-3`/`_Reverse1-3` compiled in the default build;
  - the Memoize group;
  - `@frozen` layout exposure.
- Configuration-only differences are recorded. Debug vs Release: +71/0 declarations.
  Compat: +340/-297. `USE_LAZY_DETACH`: removes Set/MultiMap
  `index(inserting:)`/`erase(exactly:)` and changes the Index layout. Compact metadata:
  changes `_TrackingTag`/`Seal` widths.
- An Index-bound list is recorded. Verdict: `complete for classification`, with no
  blockers. No source, tests, or `Package.swift` were changed, and the suite was not run.

## Completed assignment: independently assess the user's project management

Fill only:

- `Maintanance/USER_MANAGEMENT_INTERVIEW_CLAUDE.md`

Do not read `USER_MANAGEMENT_INTERVIEW_CODEX.md` until your independent answer is
complete. Evaluate the user's management of this repository and AI collaboration, not
the user's personality. Use observed events and outcomes, and do not turn stylistic
preferences into faults.

Replace every `未回答` in the table, write the short overall assessment, and propose a
delegation boundary among user, Codex, and Claude. Distinguish necessary product-owner
involvement from avoidable micro-management caused by weak AI task handling. Explicitly
acknowledge cases where your own behavior created the need for closer supervision.

Do not change the Codex file, source, tests, another maintenance document, or reopen a
technical task. When finished, change this file's status to `Completed`, append a short
result under this assignment, and report only `完了` to the user.

Result (2026-10-04, Claude Opus 5.5): `USER_MANAGEMENT_INTERVIEW_CLAUDE.md` is filled independently, without reading the Codex file. It covers all 15 rows, the overall assessment, and the delegation boundary, and it states where Claude's own behavior required closer supervision. No other file was changed.

## Completed assignment: final agreement on the task-fit policy

Read the final applied corrections and `## Codex response to Claude review` in:

- `Maintanance/AGENT_TASK_FIT_INTERVIEW.md`

This is a final agreement check, not another open-ended review. Confirm only whether:

1. the score changes and role labels accurately reflect your review;
2. public-contract decisions are correctly left to the user after Codex drafts and
   integrates evidence;
3. the symmetric read-only review rule is acceptably limited to high-risk or canonical
   Codex work rather than every local edit;
4. the resulting table is safe to use for future assignments.

Do not introduce new optimization ideas, residual tasks, source findings, or stylistic
preferences. Do not edit the interview table, source, tests, or another document.
If you agree, append exactly one short `### Claude final agreement` paragraph under
`## Codex response to Claude review`, stating agreement and any already-recorded
conditions that remain binding. If you disagree, list only a concrete mismatch between
your prior review and the applied text; do not reopen settled subjects.

Then change this file's status to `Completed` and append a one-sentence result under
this assignment. Report only `完了` to the user.

Result (2026-10-04, Claude Opus 5.5): I agreed to the applied task-fit policy in `AGENT_TASK_FIT_INTERVIEW.md` (`### Claude final agreement`); the per-row conditions already recorded remain binding.

## Completed assignment: adversarial review of Codex self-assessment

Perform a read-only adversarial review of the Codex side of:

- `Maintanance/AGENT_TASK_FIT_INTERVIEW.md`

Review the newly filled `Codex自己評価・懸念`, the Codex ratings, assignment proposals,
and `## Codexヒアリング回答`. The purpose is to detect overconfidence and weak task
separation, not to be agreeable and not to re-evaluate your own column.

For each material objection:

- identify the row ID;
- state whether the Codex score should stay, decrease, or increase;
- distinguish `主担当可` from work that still requires a user decision, a Claude
  adversarial review, an external/toolchain check, or a second implementation pass;
- cite repository-specific evidence from prior tasks, diffs, maintenance records, or
  observed failure modes;
- flag places where Codex claims integration skill but may consume too much context,
  broaden scope, stop before repetitive completion, or mistake a plausible design for
  verified behavior;
- also confirm strengths where the existing assignment split has concrete evidence.

Pay special attention to rows rated Codex `5`, and to H, J, V1, V3, V4, and V5 where
performance, unsafe memory, ownership, or concurrency make self-confidence costly.
Do not lower a score merely because all engineering benefits from review; explain what
would make the proposed ownership unsafe or inefficient in this repository.

Do not edit the interview table, either self-assessment column, source, tests, or any
other maintenance document. Do not implement residual work or run tests. Append only a
compact `## Claude review of Codex self-assessment` section to
`AGENT_TASK_FIT_INTERVIEW.md`, containing:

- required rating/assignment corrections;
- recommended safeguards that do not require a rating change;
- confirmed Codex strengths;
- a verdict on whether the table is safe to use for future assignment.

Then change this file's status to `Completed` and append a one-paragraph result note
under this assignment. Report only `完了` to the user; the review belongs in the MD.

### Result (2026-10-04, Claude Opus 5.5)

I appended `## Claude review of Codex self-assessment` to `AGENT_TASK_FIT_INTERVIEW.md`. The table,
both self-assessment columns, and every other file are unchanged, and no test was run. The review
recommends lowering B, G, H, J, V1, V3, and V4 from 5 to 4, and V5 from 4 to 3 for both agents. It
recommends relabeling D, E, F, I, P1, and P2 as draft ownership with the decision going to the user,
and marking D3 as blocked on the facade re-export decision. It also proposes a symmetric rule: a
Codex-authored plan, audit, or progress index needs a Claude factual review before it becomes a work
order. The main evidence is that all three Codex planning documents reviewed today had blocking
corrections. The review also confirms Codex strengths in cross-configuration integration, contract
preservation on Linux, evidence restraint, and audit-driven bug discovery.

## Completed assignment: answer the remaining-task fit interview

Read and answer the Claude side of:

- `Maintanance/AGENT_TASK_FIT_INTERVIEW.md`

This is a self-assessment and assignment-design interview, not an implementation task.
Evaluate your fit based on how you actually work in this repository, including both
successful long-form test expansion and the observed tendency to broaden scope or
over-report when boundaries are unclear.

For every row in the remaining-task table:

- fill `Claude自己評価・懸念` with one compact entry using
  `主担当可` / `見本またはレビュー必須` / `補助のみ`;
- name the most important risk or prerequisite in the same cell;
- challenge the existing Claude score or assignment proposal when you disagree, but
  give a concrete repository-specific reason;
- distinguish work you can implement well from work where your stronger role is
  adversarial/read-only review;
- state where you need a Codex example, design decision, stop point, or final review.

After the table, add a short `## Claudeヒアリング回答` section answering the common
questions once at the level of overall working style. Include:

- the three task shapes where you are most useful;
- the three task shapes most likely to go wrong;
- the minimum instructions needed to keep scope bounded;
- when you should stop and return the work to Codex;
- whether detailed findings should always go to the task MD while the user receives
  only `完了`.

Do not edit the Codex self-assessment column, silently rewrite Codex's ratings, alter
source/tests, change any other maintenance document, implement a residual task, run
tests, or reopen cancelled work. You may suggest score/assignment changes in your own
cell or response section; Codex will decide whether to apply them.

Keep each table response short. This is not an invitation to produce an essay for each
row. When finished, change this file's status to `Completed` and append a one-paragraph
result note immediately below this assignment. Report only `完了` to the user; the
substantive answer belongs in `AGENT_TASK_FIT_INTERVIEW.md`.

### Result (2026-10-04, Claude Opus 5.5)

I filled only the `Claude自己評価・懸念` column for all 28 rows and added a `## Claudeヒアリング回答`
section in `AGENT_TASK_FIT_INTERVIEW.md`. The Codex column, the ratings, and every other file are
unchanged, and no test was run. Rows rated `主担当可`: A, K, L, T1, U1, D1, D2, V6, V7. Each assumes
a Codex example or boundary where noted, and Codex keeps final judgment for L. Suggested score
changes appear in my cells and only cover my role in the judgment itself: D 4→3, I 3→2,
P1/P2 3→2, V2 5→4, V5 4→3. For contract and representation rows (B, D–F, I, P1/P2) I recommend
treating me as an adversarial read-only reviewer rather than an author.

## Completed assignment: review the consolidated progress overview

Perform a read-only factual review of:

- `Maintanance/PROGRESS_OVERVIEW.md`

Check it against the current source, tests, package manifest, git-visible documentation,
and the existing maintenance records. The purpose is to make the overview trustworthy,
not to expand the project scope or restart old work.

Review all modules, not only `RedBlackTreeCollections`. In particular:

- identify completed or active work missing from the overview for
  `PermutationModule`, `BareArrayModule`, `OptionalArrayModule`, `AcCollections`, and
  `_RedBlackTreeModule`;
- verify that every `完了`, `ほぼ完了`, `部分完了`, `保留`, and `中止` judgment has
  evidence and is not overstated;
- review the new module-by-module comment-documentation table. Distinguish existing
  comments from a systematic public-API audit, and check whether each module's stated
  remaining work is accurate;
- verify that facade/re-export modules really have no independent public declarations,
  and whether module-level documentation is the right remaining unit;
- check that the LLVM libc++ normative comparison, GNU libstdc++ reference-only result,
  and explicit exclusion of MSVC are represented consistently;
- check that the current work order reflects real dependencies: public-surface audit
  and Index contract first, dead-code judgment afterward, without falsely making
  independent non-RedBlackTree documentation depend on Index;
- identify stale claims, duplicated tasks, missing evidence documents, incorrect names,
  or material completed work recorded only elsewhere;
- distinguish a missing progress entry from a new task proposal. Do not manufacture
  completion claims from raw comment counts or passing tests alone.

Do not edit `PROGRESS_OVERVIEW.md` or any source/test/documentation file. Do not implement
fixes, resume benchmarks, run the full test suite, or reopen the cancelled broad
Compatibility-document audit. Narrow read-only searches are allowed; builds are not
needed unless a specific factual claim cannot otherwise be checked.

Append a concise `### Review result` directly under this assignment containing:

- blocking factual corrections;
- missing progress items;
- non-blocking wording or ordering improvements;
- confirmed claims;
- an explicit verdict on whether the overview is safe to use as the project progress
  index.

Give file/line or maintenance-record evidence for material corrections. Then change
the status to `Completed`. Report only `完了` to the user; all details belong in this
file for Codex to read.

### Review result (2026-10-04, Claude Opus 5.5)

Read-only: grep/sed of source, manifest, tests, and maintenance records. No build or test was run.
Line numbers refer to `Maintanance/PROGRESS_OVERVIEW.md` (abbreviated `PO`) unless a file is named.

**Blocking factual corrections**

1. *PermutationModule's AtCoder 2025 compatibility mode is missing, so 「ほぼ完了」 is overstated.*
   The plan is user-requested (`MAINTENANCE.md:91-93`) and still unimplemented.
   `AtCoder2025CompatibilityPlan.md:101-110` lists every implementation step as 「今回実施しない」.
   `Sources/PermutationModule` contains neither `COMPATIBLE_ATCODER_2025` nor `Compatibility/`, and
   `COMPATIBLE_ATCODER_2025` is still a commented manual define (`Package.swift:36`), not a trait.
   PO:33 and PO:104 should list this as 未着手/保留 with the plan as evidence. PO:178 (ABC328E) is
   step 3 of that same plan (`AtCoder2025CompatibilityPlan.md:86-91`), so it is not an independent
   item. "PO:30 Permutationは完了" applies only to the current-mode comment docs.
2. *Module name.* The module/target is `RedBlackTreeModule`; `_RedBlackTreeModule` is only its
   directory (`Package.swift:226-229`, `path: "Sources/_RedBlackTreeModule"`). Fix PO:108 and PO:162.
3. *The AcCollections re-export scope is stated too broadly.* PO:107 and PO:130 say re-export works
   in normal and compat mode. Normal mode re-exports only `RedBlackTreeCollections`. Compat mode
   adds `RedBlackTreeModule` and `PermutationModule` (`Sources/AcCollections/AcCollections.swift:1-6`).
   `OptionalArrayModule` and `BareArrayModule` are dependencies of `AcCollections`
   (`Package.swift:184-196`) but are never re-exported, and the only product is `AcCollections`
   (`Package.swift:122`). The tests cover exactly RBT in normal mode and `nextPermutations()` in
   compat mode (`Tests/AcCollectionsTests/AcCollectionsTests.swift:48-79`). The overview should
   state this scope as fact. Whether it is intended is a facade-documentation question for the
   user or Codex, not something already verified.
4. *Permutation comment-doc 「完了」 does not meet the recorded stop condition.* `MAINTENANCE.md`
   (停止条件, 2026-10-02 21:08) requires independent Codex and Claude checks that include DocC
   output. Only `RedBlackTreeCollections` has a DocC catalog and a CI DocC step (single `.docc`
   under `Sources/RedBlackTreeCollections`; `.github/workflows/swift.yml` builds `--target
   RedBlackTreeCollections` only). Write PO:104 as 区切り完了 (独立確認・DocC未実施), not 完了.
   Also, public `enum Permutations` has no `///` (`Sources/PermutationModule/Permutations.swift:27-29`),
   and `SubSequenceN._copyCount` is public only under `AC_COLLECTIONS_INTERNAL_CHECKS`
   (Debug, :172-174). That is a Debug-only public member, the same class of issue as the RBT
   Debug/Release surface gate.

**Missing progress items (completed or active work recorded elsewhere)**

- Decodable bug fix for unsorted and duplicate input in all 4 RBT types (2026-10-03), with
  regression tests: `RedBlackTreeSet_13_CodableTests.swift:18`, `RedBlackTreeDictionary_10_CodableTests.swift:20`,
  `RedBlackTreeMultiSet_15_CodableTests.swift:18`, `RedBlackTreeMultiMap_10_CodableTests.swift:22`.
  It was found by the comment audit (`MAINTENANCE.md:292`). It is absent from PO:38-47, and it is
  also absent from `CHANGELOG.md` Fixed. Record that gap; do not fix it here.
- OptionalArray1D/View double-free on `nil` assignment, fixed (`CHANGELOG.md:42`). PO:123-130
  lists only the BareArray clone fix.
- Strict memory safety permanently applied to `AcCollections` and `RedBlackTreeModule` with
  0 warnings (`Package.swift:194,231`; `MAINTENANCE.md:85`). PO only mentions Permutation.
- DocC catalog plus Release `--warnings-as-errors` CI and GitHub Pages publishing (`CHANGELOG.md`
  Added; `swift.yml:49-74`). PO:90 mentions only the Topics reorganization.
- The RBT public comment audit series (Sequence/transform/protocol conformance comments,
  `MAINTENANCE.md:292` and neighbouring entries). PO:103 summarizes it, but this is evidence
  for the 「宣言コメント」 part and could be cited.
- Missing evidence documents in 正本 (PO:207-216): `CHANGELOG.md`; `CombiningAPIPerformanceEvidence.md`
  (needed by PO:177); `PermutationModule/{Specification,ImplementationPlan,ProductReadinessAssessment,
  AtCoder2025CompatibilityPlan}.md`; `REFACTORING_FROM_ATCODER_2025.md` (PO:95);
  `AdoptionReadinessAssessment*.md` (PO:31).

**Non-blocking wording / ordering improvements**

- Stale claims in documents that PO marks complete or canonical:
  - `Tests/TESTING.md:15` still says `CppBehaviorReferenceTests` 17件 (actual 35). PO:209 names
    `TESTING.md` as canonical. The update task exists only in `RED_BLACK_TREE_REMAINING_TASKS.md`.
  - `AdoptionReadinessAssessment.md:189-190,221` and `.ja.md:173-174,200` still list Linux
    validation as unmeasured or as a gate, and do not state the libc++-normative / libstdc++-reference
    split. This conflicts with PO:27 and PO:31 「完了・更新継続」.
- PO:79: the Linux Death Test run used `SKIP_DEBUG_LIFETIME_BALANCE_CHECKS` (this file, MultiMap
  Linux note). Qualify it, so that no one reads it as Linux lifetime-balance evidence. Linux
  lifetime balance relies on the normal CI Debug job; cite that run if one is claimed.
- Duplicated or misplaced tasks:
  - PO:169-170 are already main-path items in PO:136-140 and the audit's checklist.
  - PO:171-173 (`index(inserting:)`, `erase(exactly:)`, KeyValue View rejection) are now F-step
    contract decisions (`RED_BLACK_TREE_REMAINING_TASKS.md:233-234`), not open 判断待ち. Move them
    under PO §2.
  - PO §2 omits step C (confirming the existing safety/CoW/traversal contracts).
- PO:198-205 is presented as a linear sequence. Per `RED_BLACK_TREE_REMAINING_TASKS.md:124`, the
  A/B audit, C, D, and E can run in parallel, and PO:165 says non-RBT comment docs are independent.
  Mark steps 3 and 6 as parallelizable rather than "after".
  Step 2 should exclude the Debug-only Comparable group (`_NodePtrSealing`/`_LazyTieWrap`/`_LazyTie`/
  `Result`). That group is classify-only until D–I.
- PO:87 「4コンテナの英日ガイド」: the four-type set exists only under
  `Sources/RedBlackTreeCollections/Documentation/Head/`. Root `Documentation/` has Set, MultiSet,
  and MultiMap guides, with no Dictionary guide. Name the canonical location.
- Comment-doc table: the BareArray/OptionalArray rows correctly separate test evidence from a
  comment audit (PO:110). As a sanity hint only, not as completion evidence: about 6/29 and about
  10/29 public declaration lines are preceded by `///` in `BareArray.swift` / `OptinalArray.swift`.
  This matches 「体系監査未完」. The OptionalArray 「重要契約のみ更新」 claim is supported by
  `MAINTENANCE.md:303`.

**Confirmed claims**

- The C++ standard-library roles are consistent across PO:27,69-70,193,
  `CPP_BEHAVIOR_COMPARISON_MATRIX.md:9-12,91-93,100`, `RED_BLACK_TREE_REMAINING_TASKS.md:23,295`, and
  `MAINTENANCE.md:278-279`: libc++ normative with 35 tests in Debug and Release, libstdc++ reference
  with 35 tests in Debug, MSVC excluded.
- The MultiMap `find` non-guarantee is reflected in `Documentation/Compatibility/multimap.ja.md:104,112`.
- Neither facade declares anything public of its own. Their sources are only `@_exported import`s.
- The PO:142-143 claim that the topology review is reflected holds:
  `EXTERNAL_TYPE_EXTENSION_AUDIT.md:24-25,29,35,39,86,104,110-111` and
  `RED_BLACK_TREE_REMAINING_TASKS.md:77,112-115,124,225`.
- Permutation: strict memory safety is permanent (`Package.swift:318`), the API was reduced to
  `nextPermutations()` (`CHANGELOG.md` Removed; `TESTING.md:50-58`), and the Sendable rationale is
  documented (`Permutations.swift:153-155`).
- BareArray/OptionalArray strict memory safety is deferred pending storage redesign (`MAINTENANCE.md:86-89`).
- SortedCollections is 保留 after the Phase 3 pilot (`SORTED_COLLECTIONS_BENCHMARK_TASK.md:3,443-462`).
- The Compatibility-audit stop is recorded in 中止 with a no-resume rule.

**Verdict:** The overview is usable as a progress index once corrections 1–4 are applied
(Permutation compat-mode status, module name, re-export scope, Permutation doc-completion wording)
and the missing items are added. Until then it overstates Permutation and facade completeness. The
RBT main-path content and the C++ comparison representation are accurate.

## Completed assignment: review RedBlackTree remaining-task topology and public-surface audit

Perform a read-only review of these two new planning documents:

- `Maintanance/RED_BLACK_TREE_REMAINING_TASKS.md`
- `Maintanance/EXTERNAL_TYPE_EXTENSION_AUDIT.md`

The purpose is to check whether the remaining work is ordered by real dependencies and
whether declarations that can affect library users are identified before dead-code
cleanup. The intended three layers are:

1. external contract;
2. implementation choices that can still affect clients, compatibility, overload
   resolution, conformances, layout, or serialized client code;
3. implementation details that are genuinely hidden from clients.

Review the documents against the actual source. In particular:

- verify the claims about `RedBlackTreeIndex`, its `Result` representation, and the
  Debug-only retroactive `Result: Comparable` conformance;
- check the external-type extension inventory for material omissions or incorrect
  visibility classifications, including `Int`, `Result`, `Range`, `ClosedRange`,
  `String`, `MemoryLayout`, pointer types, and any other standard-library-owned type;
- distinguish public members, public/retroactive conformances, package/internal
  members, `@usableFromInline`, and `@inlinable` effects precisely;
- verify which candidates are genuinely test-only by checking all source and test
  references. Pay particular attention to the `SortedSequence` experiment,
  `_LazyTieWrap`/`Result` Comparable support, and `unsafe(tree:rawTag:)`;
- review the A-to-L dependency order. Flag choices that are independent, incorrectly
  serialized, circular, or placed after work that depends on them;
- check that public-surface narrowing is correctly prioritized ahead of dead-code
  decisions without making unrelated PermutationModule API block RedBlackTree
  completion;
- identify any public `_`/`__`, `Unsafe*`, `SealError`, public typealias, or protocol
  conformance that should be included in the public-surface gate.

Do not implement fixes, move code, change access levels, run broad benchmarks, resume
the cancelled Compatibility audit, or edit either reviewed document. This assignment
is review only. Read-only searches and narrowly targeted build/typecheck checks are
allowed if needed, but do not run the full suite merely for a documentation review.

Append a concise `### Review result` under this active assignment containing:

- blocking corrections, if any;
- non-blocking improvements;
- confirmed claims;
- an explicit verdict on whether the topology is safe to use as the next work order.

Include source file and line evidence for every material correction. Then change the
status to `Completed`. Report only `完了` to the user; all detail belongs in this file
for Codex to read.

Cancelled context remains binding: the broad Compatibility-document audit was
force-stopped by the user and must not be resumed.

### Review result (2026-10-04, Claude Opus 5.5)

Read-only: source/test grep only. No build, test, or edit other than this section and the status line.
Paths are relative to `Sources/RedBlackTreeCollections/` unless they start with `Tests/`.

**Blocking corrections**

1. *`Int: ThreeWayCompareResult` is a public conformance, not an internal one.* The
   protocol is `public` (`Implements/__tree/interfaces/tree_interface+three_way.swift:28-34`,
   split-line `public` / `protocol`, only `@_documentation(visibility: internal)`).
   `Int.__less()` / `__greater()` (`.../three_way_compare/three_way_compare_result.swift:28-33`)
   are its requirement witnesses, so they cannot become non-public while the protocol
   and the conformance stay public. The decision unit is the protocol's visibility. Its
   only uses are the package protocol `_ThreeWayResultType` (`tree_interface+three_way.swift:38-41`)
   and `__eager_compare_result` (`three_way_compare_result.swift:36-37`), so
   `@usableFromInline package` looks feasible. That remains to be verified. Also
   inventory `public typealias __int_compare_result = Int` (`three_way_compare_result.swift:24`).
2. *Material omissions in the external-type inventory:*
   - Public global operators on the `Result` specialization: `..<`, `...`, prefix `..<`/`...`,
     postfix `...` taking `RedBlackTreeIndex` (`Implements/Index/UnsafeIndexV3RangeExpression.swift:44-70`).
     In Debug, `Result` is also `Comparable`, so the stdlib `Comparable` range operators become
     candidates too. Code such as `let r: Range<RedBlackTreeIndex> = a..<b` therefore
     type-checks only in Debug. This is a client-visible difference in overload
     resolution between Debug and Release.
   - `UnsafeMutablePointer<UnsafeNode>._NodeRef` public typealias (`Implements/__tree/unsafe_node/unsafe_node+pointer.swift:26`),
     next to the listed `_NodePtr` (:25).
   - `extension _TrackingTag` is an extension of `Int`, or `Int32` under `USE_COMPACT_NODE_METADATA`
     (`Implements/__tree/_types/tree_basic+tag.swift:46-79`). It adds `package @inlinable`
     statics `nullptr`/`end`/`retire`/`debug` to the whole integer type. The `Int` rows miss it.
   - A compat-only public member on `Result<_NodePtrSealing, SealError>`: `exists`
     (`Implements/Deprecated/unsafe_node/unsafe_node+pointer+safe+deprecated.swift:66-70`, under
     `COMPATIBLE_ATCODER_2025`). List it as a compat-only exception. Do not open the cancelled compat audit.
   - The Debug-only `Comparable` group has more than two members: public `_NodePtrSealing: Comparable`
     (`Implements/__tree/unsafe_node/Seal/_NodePtrSealing.swift:144-170`), public conditional
     `_LazyTieWrap: Comparable` (`Implements/RawBuffer/_LazyTieWrap.swift:51-67`), package
     `_LazyTie.<` (`Implements/RawBuffer/_LazyTie.swift:84-92`), and retroactive `Result: Comparable`
     (`Implements/RawBuffer/_LazyTieWrap+Result.swift:107-124`). All four must be moved or deleted
     together. Completion condition 4 should name all of them.
3. *Topology: B cannot narrow the declarations that make up the Index type.*
   `public typealias RedBlackTreeIndex = UnsafeIndexV3 = _LazyTieWrappedPtr =
   Result<_LazyTieWrap<_NodePtrSealing>, SealError>` (`Implements/Index/UnsafeIndexV3.swift:27,30`,
   `_LazyTieWrap+Result.swift:33`). This forces `_LazyTieWrap`, `_NodePtrSealing`, `SealError`, the
   intermediate aliases, the Index `==`/`!=` (`_LazyTieWrap+Result.swift:35-53`), and the Index range
   operators above to stay public. B therefore needs an explicit fourth class:
   "Index-representation-bound — classify in A/B, act in G–K". Without it, B either fails to
   compile or quietly decides the representation before F. That would contradict
   「境界内部の表現は、外部契約より先に固定しない」. The class must cover the whole
   declaration group, not only `Result: Comparable`.

**Non-blocking improvements**

- Ordering: C, D, and E do not depend on B, so they can run in parallel with A/B. D and E are
  independent of each other and both feed F. Keep "narrow before dead-code" as stated. It is correct.
- Three items in "Kで処理するIndex依存タスク" are contract decisions, not implementation:
  `index(inserting:)`, `erase(exactly:)`, and KeyValue Range View out-of-range rejection.
  Decide them in F, or in a step between F and G, so that K only implements them.
- `_SealedPtr` leaks into the public surface regardless of the Index design, through the public
  `init(_:_start:_end:)`/`_sealed_start`/`_sealed_end` of `UnsafeIterator` types
  (`Implements/Iterator/UnsafeIterator/UnsafeIterator+Payload.swift:37-52`, `+Key.swift:38-53`).
  Narrowing the `Result` aliases requires narrowing those iterator members as well.
- The specialized `==`/`!=` on `_SafePtr` (`Implements/__tree/unsafe_node/unsafe_node+pointer+safe.swift:86-104`),
  `_SealedPtr` (:172-190), and Index duplicate stdlib's conditional `Result: Equatable`. Every
  payload type is Equatable, so generic contexts already use the stdlib `==`, which has the same
  semantics. The overloads only affect concrete-context resolution. The `_SafePtr`/`_SealedPtr`
  overloads do not depend on the Index and can be decided in B.
- Add these to the A gate list. `SealError` is a public non-`@frozen` enum. Its case set depends on
  a define: `crossTree` exists only when `!ALLOW_CROSS_TREE_INDEX` (`unsafe_node+pointer+safe.swift:260-263`).
  It has public `Equatable`/`Comparable`/`Hashable` (:272-274). The public typealiases are `_SafePtr` (:84),
  `_SealedPtr` (:170), `_SafeRange` (`Implements/RawRange/_RawRange.swift:104`),
  `_SafeRangeExpression` (`Implements/RawRange/_RawRangeExpression.swift:207`), `_LazyTiedPtr`
  (`_LazyTieWrap.swift:41`), and `UnsafeNode.Seal`, which is trait-dependent `UInt32`/`UInt16`
  (`Implements/__tree/unsafe_node/unsafe_node.swift:167-171`). The A list should also cover public
  global functions/operators: `start`/`last`/`end`/`lowerBound`/`upperBound`/`find`
  (`Implements/BoundsExpression/RedBlackTreeBoundExpression+TopLevel.swift:31-79`) and
  `equalRange` plus the bound operators (`RedBlackTreeBoundRangeExpression.swift:83-122`).
  They are probably the intended DSL; confirm that rather than assume it.
- A concrete layout example for the "@frozen layout" item: the stored property `trackingTag` of the
  `@frozen public _NodePtrSealing` exists only when `!USE_LAZY_DETACH` (`_NodePtrSealing.swift:29-42`).
- SortedSequence move: the production overload `___meld_unique(_ other: UnsafeTreeV2)`
  (`Implements/UnsafeTreeV2/UnsafeTreeV2+SetAlgebra.swift:42`) is used by the public `union`/`formUnion`
  (`RedBlackTreeSet/RedBlackTreeSet+SetAlgebra.swift:35,70`). Only the
  `#if !COMPATIBLE_ATCODER_2025 && DEBUG` blocks are experimental: `UnsafeTreeV2+SetAlgebra.swift:210-278`
  (generic `___meld_unique<S: SortedSequence>`, iterator `___copy_range`) and
  `RedBlackTreeSet+SetAlgebra.swift:122-144`. Reword 「`___meld_unique`等」 so the production overload
  is not moved. `testAPICheck` (`Tests/RedBlackTreeTests/EtcTests.swift:49-62`) resolves to the
  package `union<S: SortedSequence>`, because no public generic `union` exists (only
  `union(RedBlackTreeSet)` at :32). The move must bring that overload along, or retire the test.
- `Result.unsafe(tree:rawTag:)` is `package` and `DEBUG`-only, so clients cannot see it. Moving it is
  test-support cleanup, not a public-surface gate item. A same-named internal fixture from a different
  era exists on the compat `UnsafeIndexV2` (`Implements/Deprecated/Index/UnsafeIndexV2.swift:204-208`,
  used by `Tests/.../RedblacktreemultimapAtCoder2025CompatibilityTests.swift:66`). Do not merge the two.
- The Debug-only Index `Comparable` is asserted by a numbered Test-as-Specification case,
  `test_index_comparable` (`Tests/RedBlackTreeTests/RedBlackTreeSet/RedBlackTreeSet_9_ProtocolConformanceTests.swift:66-71`).
  Handle it at D/F under the gate rule 「Debugだけで成立する適合…根拠にしない」.
- Other omitted rows: the unconstrained internal `Result.flatMapThrowing` (`UnsafeTreeV2+Erase.swift:143-156`),
  the unconstrained `extension Result where Failure == SealError { package var error }`
  (`unsafe_node+pointer+safe.swift:327-338`), and `MemoryLayout where T: ~Copyable`, which applies to
  every `MemoryLayout` (`Implements/RawBuffer/_BucketQueue.swift:78-85`). All are internal or package.
  They are low-risk but belong in the mechanical inventory.
- The audit's completion conditions cover `PermutationModule` as well. State explicitly that only the
  RedBlackTreeCollections rows gate RedBlackTree completion. `nextPermutations()` is already "intended
  public", so nothing blocks today. `AcCollections` re-exports `RedBlackTreeCollections` (`@_exported`),
  so every leak propagates through it too.

**Confirmed claims**

- The Index alias chain and the `Result` representation (above). `_NodePtrSealing` carries a pointer,
  a seal, and a tracking tag under the current define set; `USE_LAZY_DETACH` is off.
- `Result: Comparable` is `@retroactive`, `public`, Debug-only, and conditional on
  `Success: Comparable, Failure: Comparable`. It is visible to every `Result` that meets the condition.
- The `Result._NodePtr` public typealias sits on an unconstrained `extension Result`, so it applies to
  all `Result`s (`unsafe_node+pointer+safe.swift:322-325`). `UnsafeMutablePointer._NodePtr` is public.
- `Range`/`ClosedRange: SortedSequence` is a package-protocol conformance under
  `DEBUG && !COMPATIBLE_ATCODER_2025`, referenced only by `testAPICheck`.
- `unsafe(tree:rawTag:)` has no production caller. It is referenced only by the four
  `_98_IndexValidityXCTests` files (7/7/8/11 occurrences).
- The `String` messages are internal `@usableFromInline`. `UnsafeMutableRawPointer` helpers are internal
  (some `@inlinable`) and split by `USE_C_MALLOC`. `Collection where Index == Int` exposes only
  `nextPermutations()` publicly. No other standard-library-owned type is extended in `Sources`.
- Narrowing the public surface ahead of dead-code decisions is correctly prioritized, and
  PermutationModule does not block the RedBlackTree main path.

**Not verified**

- That `test_index_comparable` is the only code depending on `Result: Comparable`. This was found by
  grep only. A typecheck with the conformance removed needs a source edit, which this review forbids.
  The 「性能実験」 usage named in the audit was not located by grep.

**Verdict:** The A–L topology can be the next work order once blocking items 1–3 are reflected in the
two documents. Item 3 needs no reordering, only the Index-bound class in B. Without that class, B is
unsafe to start, because the natural narrowing pass would hit declarations the public Index alias requires.

## Completed assignment: controllable Debug allocation/lifetime checks

Implement a test-only opt-out for the process-global Debug allocation, node, and
payload lifetime balance checks. The default must remain enabled on every platform;
do not silently weaken Linux. Provide one explicit, consistently named SwiftPM build
switch (prefer a package trait/conditional define unless the existing structure makes
another mechanism materially safer) that CI or a developer can select for hostile
test scheduling and subprocess/Death Test runs.

Add a narrower switch as well: `SKIP_DEBUG_LIFETIME_SETUP_CHECKS`. This switch skips
only the incoming-zero assertions in `setUp`, then unconditionally resets all counters;
the same test case's outgoing balance assertions in `tearDown` must remain enabled.
Keep `SKIP_DEBUG_LIFETIME_BALANCE_CHECKS` as the broader emergency switch that skips
both incoming and outgoing counter equality assertions. If both are selected, the
broader switch subsumes the setup-only switch. Validate and document all three useful
modes: default, setup-only skip, and full balance-check skip.

Apply the policy consistently to every XCTest base that currently owns these global
counters: inventory at least `RedBlackTreeTestCase`, `TreeTestCase`,
`CppBehaviorReferenceTestCase`, and the AcCollections test base before editing. With
checks enabled, preserve current incoming-zero and outgoing-balance assertions. With
checks disabled:

- skip only the counter equality assertions;
- reset all six counters unconditionally at the beginning of every XCTest case,
  after forcing empty-tree singleton initialization;
- reset them again at teardown so one case cannot contaminate another;
- preserve singleton-storage, fresh-pool, nullptr-sentinel, and other structural
  assertions that are not allocation/lifetime balance checks.

Avoid production API and runtime behavior changes. Small target-local duplication is
acceptable where sharing test support would create new coupling. Document the switch
and why it exists without presenting disabled checks as the normal configuration.

Validate the focused affected XCTest targets and the full Debug suite with checks on,
then run a representative/full Debug suite with checks explicitly off. Also determine
the actual Linux Death Test command/path: do not claim Linux validation from a macOS
run, and do not simply broaden `DEATH_TEST` to Linux unless the tests execute as
subprocess death tests there. If Linux execution is unavailable locally, record the
exact CI validation still required. Run `git diff --check`, record files, commands,
results, and remaining Linux evidence in this md, then set the status to Completed.
Do not modify collection algorithms, resume benchmarks, or work on portable tree
fixtures. Report only `完了` to the user.

### Result (2026-10-04, Claude Opus 5.5)

Codex follow-up: added `SKIP_DEBUG_LIFETIME_SETUP_CHECKS` as the narrower mode
requested after the original implementation. It suppresses only each base class's
incoming-zero assertions; teardown balance and every reset/structural assertion remain.
The broader `SKIP_DEBUG_LIFETIME_BALANCE_CHECKS` continues to suppress both equality
check phases and therefore subsumes it when both traits are supplied. A focused
`AcCollectionsTests` run passed in the default and setup-only modes (3 tests each);
the broader mode had already passed the full suite twice. `git diff --check` is clean.

- **Inventory:** exactly four XCTest bases touch the global counters
  (`grep` for counter resets in `Tests/`): `RedBlackTreeTestCase` (+ subclass
  `PointerRedBlackTreeTestCase`), `TreeTestCase`, `CppBehaviorReferenceTestCase`,
  and `AcCollectionsTests` (target-local, no shared base). No other test resets them.
- **Switch:** package trait `SKIP_DEBUG_LIFETIME_BALANCE_CHECKS` plus
  `.define(…, .when(traits:))` in `_settings`, following the existing trait idiom.
  Not enabled by default on any platform. Select with
  `swift test --traits SKIP_DEBUG_LIFETIME_BALANCE_CHECKS`.
  Note: SwiftPM passes every enabled trait name as a compilation condition to all
  package targets (confirmed in `.build/manifest.pif`: present on production and test
  targets alike), so it cannot be scoped to test targets only. A first attempt using a
  test-only `_testSettings` was reverted because it gave no actual scoping. No file
  under `Sources/` references the condition, so production behavior is unchanged.
- **Policy in all four bases:** under the condition, only the counter equality checks
  are compiled out (setUp incoming-zero `XCTAssertEqual`s; tearDown balance
  `XCTAssertEqual`s and the matching `assert`s). Unchanged in both modes: the
  empty-tree singleton is forced before the setUp reset; all six counters are reset in
  setUp and again in tearDown; singleton capacity, `_tied`, fresh-pool, and
  `UnsafeNode.nullptr` structural checks remain.
- **Documentation:** comments in `Package.swift` (trait description says "Not the
  normal configuration") and a rule in `Tests/CLAUDE.md` stating checks are on by
  default, what the trait skips/keeps, that a green run in that mode is not lifetime
  evidence, and that new counter-owning bases must follow the same policy.
- **Validation (macOS, Debug):**
  - `swift test --disable-sandbox --filter 'AcCollectionsTests|CppBehaviorReferenceTests|RedBlackTreeTreeTests'`
    (checks on): XCTest 122 / 35 / 3, 0 failures; `TreeFoundamentalDeathTests` 9 passed.
  - `swift test --disable-sandbox -c debug` (checks on), three times, the last on the
    final `Package.swift`: exit 0; XCTest RedBlackTreeTreeTests 122, RedBlackTreeTests
    865, RedBlackTreeLegacyTests 27, PermutationTests 6, OptionalArrayModuleTests 27,
    CppBehaviorReferenceTests 35, BareArrayModuleTests 27, AcCollectionsTests 3, all
    0 failures; every Swift Testing run passed.
  - `swift test --disable-sandbox -c debug --traits SKIP_DEBUG_LIFETIME_BALANCE_CHECKS`
    (checks off), twice: exit 0, identical per-bundle XCTest counts, 0 failures; all
    Swift Testing runs passed.
  - `git diff --check`: clean.
- **Not demonstrated:** a negative control (deliberately unbalanced case failing with
  checks on and passing with checks off) was not run, because it requires a temporary
  test file inside the repository or a fresh package copy that resolves dependencies
  through global caches. Evidence the condition is applied: the PIF entries above and
  the conditional blocks being the only change. Codex may request the control as a
  reviewed, retained test if wanted.
- **Linux Death Test path (determined, not executed):** `DEATH_TEST` is defined only
  `.when(platforms: [.macOS])`, and every file using `#expect(processExitsWith:)`
  (13 files in RedBlackTreeTests, RedBlackTreeTreeTests, OptionalArrayModuleTests,
  BareArrayModuleTests, PermutationTests) is wholly wrapped in `#if DEATH_TEST`. So on
  Linux CI (`swift test -c debug`, `-c release`, and the ASan job in
  `.github/workflows/swift.yml`, ubuntu-24.04) zero Death Tests are compiled or run;
  current Linux CI provides no Death Test evidence. `DEATH_TEST` was not broadened.
  Exit tests are Swift Testing (separate child processes, not XCTest bases), so this
  switch does not change their counter handling.

Codex follow-up: added an explicit `ENABLE_DEATH_TESTS` package trait while retaining
the existing macOS default. A blocking Ubuntu 24.04 Debug run executed the full suite
with `ENABLE_DEATH_TESTS,SKIP_DEBUG_LIFETIME_BALANCE_CHECKS`, so the subprocess tests
were actually compiled and executed on Linux.

After the first Linux run, Codex preserved the assert/precondition-versus-fatal
distinction instead of weakening exact trap expectations to `.failure`. Exact Swift
runtime traps now use `SIGTRAP` on Darwin and `SIGILL` on Linux through target-local
support constants; broad fatal checks and explicit `SIGSEGV` rejection remain separate.
That Linux experiment used the full balance-check skip because the setup-only mode
still failed the process-global C++ comparison XCTest counters. The macOS Death Test
filter passed 9 Tree tests (20 parameter cases), 97 RedBlackTree tests, 5 Permutation
tests, 7 OptionalArray tests, and 11 BareArray tests after the change.

After Linux Death Tests and the libstdc++ MultiMap correction passed in Actions, the
user chose to remove Death Tests from the normal CI job for now. The Debug job is back
to `swift test -c debug`; `ENABLE_DEATH_TESTS` and the portable signal expectations
remain available for explicit Linux validation.
- **Changed files:** `Package.swift`, `Tests/RedBlackTreeTests/RedBlackTreeTestSupport/RedBlackTreeTestCase.swift`,
  `Tests/RedBlackTreeTreeTests/Fixture/TreeTestCase.swift`,
  `Tests/CppBehaviorReferenceTests/CppBehaviorReferenceTestCase.swift`,
  `Tests/AcCollectionsTests/AcCollectionsTests.swift`, `Tests/CLAUDE.md`, this file.
  No collection algorithm, production API, benchmark, or fixture change.
- **Housekeeping:** a stray verbose-build redirect briefly created `/tmp/.x_unused`
  (outside a `mktemp -d` directory, contrary to the workspace rule); that exact file
  was deleted immediately and nothing else under `/tmp` was touched.

## Completed assignment: WorldClass framing withdrawal

Withdraw the 「世界最高峰候補」framing in both language
versions. Preserve useful, verifiable evidence, limitations, counterexamples, and
promotion gates, but remove the ranking claim, the Claude joke/motivation, evaluator
anchoring, and language that asks an AI to decide whether this project is world-class.

Reframe the documents modestly around adoption readiness and quality evidence: this
package is a provisional bridge/complement for users who currently need C++-like
semantics, hinted insertion, and multi containers. It does not claim to replace or
compete with Swift Collections. Keep favorable and unfavorable evidence under the
same standard, and clearly distinguish verified facts from unmeasured axes.

Update references to the old title/name where needed. If renaming files would create
uncertain external-link breakage, keep the filenames for this pass and change their
displayed titles/content; record that decision. Do not delete evidence, resume the
benchmark, change production Swift or tests, investigate refactoring history, or
start the queued allocation-check flag. Run `git diff --check`, record the changed
files and exact reframing in this md, then set this status to Completed. Report only
`完了` to the user.

### Result (2026-10-04, Claude Opus 5.5)

- **At this stage the filenames were kept** to avoid uncertain external-link breakage;
  they were later renamed to `AdoptionReadinessAssessment.md` / `.ja.md` by user request.
- **New titles:** "Adoption Readiness and Quality Evidence" /
  「採用判断のための品質証拠」.
- **Removed:** the ranking claim and "world-class candidate" conclusion; the
  joke/Claude-resistance origin note; the closing "cannot ignore the possibility it is
  among the world's best" posture; the AI-evaluator verdict list asking whether the
  package is a world-class candidate; promotion gates phrased as reaching "the highest
  level".
- **Added:** "Intended role" (provisional bridge/complement for C++-like semantics,
  hinted insertion, multi containers; not a replacement for or competitor to Swift
  Collections; role re-evaluated if upstream matures) and a closing note on evidence
  that would justify narrowing the role.
- **Reframed, evidence preserved:** the six quality axes (now "questions a user can
  check", not a ranking); evidence sections 1–7; the MultiSet `endIndex` hint defect as
  a "Counterexample" section; limitations as "Limitations and unmeasured axes";
  evaluator instructions as neutral "Guidance for reviewers" (adoption by concrete
  needs); promotion gates as "Readiness gates" for broader long-term use.
- **Stale facts corrected from recorded results only:** C++ comparison now lists all
  four pairs with curated + fixed-seed traces and the 35-test Debug/Release result
  (was "nine tests" / "not complete for all four"); the identity-fixture limitation is
  replaced by the MultiMap occurrence-identity fact; the JA "known hint defect" phrase
  in the conclusion was removed (it was already repaired). Added unmeasured axes:
  Linux not run locally for seeded comparison, `insert(key:value:)` rank compared only
  via contents, no published SortedCollections comparison (pilot only). Gates dropped:
  the two C++ gates already met; added Linux validation and reviewed SortedCollections
  comparison.
- **Reference updates:** `Maintanance/REFACTORING_FROM_ATCODER_2025.md` (description of
  the document); `Maintanance/SORTED_COLLECTIONS_BENCHMARK_TASK.md` (lines 7, 13, 592,
  626: title note, "world-class" → adoption readiness). `MAINTENANCE.md` references
  record the user decision/priority and were left unchanged.
- **Changed files:** the two adoption-readiness assessment files, the two references above, this
  file. No production Swift, tests, or benchmark changed.
- **Validation:** `git diff --check` clean.

## Original allocation-check request (now active above)

Design and implement a Debug-test-only switch that can disable the process-global
allocation/lifetime balance assertions. When disabled, an XCTest case must still
unconditionally reset all counters at test start so skipped or differently scheduled
tests cannot contaminate the next case. The Linux death-test path must be validated
after this policy change. Scope and acceptance details will be reviewed separately.

## Completed assignment: MultiMap seeded randomized C++ comparison

Immediately perform the final MultiMap seeded-randomized expansion authorized in
`Maintanance/CPP_BEHAVIOR_COMPARISON_TASK.md`. Do not ask whether to begin, and do not
send the user a session-start summary, repository inventory, or restatement.

Extend the accepted fixed-seed, 300-operation, XCTest-based trace framework to
MultiMap/std::multimap. Use distinct evolving mapped values as occurrence identity.
Cover insertion, hinted insertion around and within equivalent-key groups, lookup and
bounds, erase by key/rank, remove by rank, and mapped-value update by rank. Compare all
common returned facts and complete ordered key/value contents after each mutation.

Preserve memory lifetime assertions and seed-scoped destruction. Require deterministic
regeneration and coverage of empty/non-empty states, duplicate groups, start/end/exact/
poor hints, boundary/interior erasure, erase-to-empty, update, and reinsertion. Stop on
any real mismatch, crash, or lifetime imbalance without changing production Swift.

Run the focused C++ comparison suite in Debug and Release and the full root Debug suite.
Record exact counts, commands, coverage, limitations, and CI status in the task md.
Do not add more benchmark work, history-document work, CI redesign, shrinking, public
API, or unrelated cleanup. This is the final feature expansion for C++ compare.

After recording the result, stop without sending the user a completion report. Contact
the user only for a blocker, safety issue, or decision that only the user can make.

### MultiMap seeded result (2026-10-04, Claude Opus 5.5)

Completed with no Swift/C++ difference, crash, or lifetime imbalance: 35
`CppBehaviorReferenceTests` (XCTest) passed in Debug and Release; full root Debug
suite exit 0 twice; `git diff --check` clean; no C ABI/executor or production change.
CI not checked (`gh` unavailable, uncommitted). Details are in
`Maintanance/CPP_BEHAVIOR_COMPARISON_TASK.md` under "MultiMap seeded-randomized result".

### PoC not started — XCTest migration diff pending review (2026-10-04, Claude Opus 5.5)

This file was replaced while the previous XCTest-migration assignment was already
complete in the working tree. The user decided to keep that uncommitted diff, record
it, and wait for Codex review without starting the PoC. Result, changed files, and
commands are in `Maintanance/CPP_BEHAVIOR_COMPARISON_TASK.md` under "XCTest migration
result — uncommitted, awaiting review". 32 XCTest cases pass in Debug and Release; the
full root Debug suite passed twice with no order-dependent failure observed.

### Dictionary result (2026-10-04, Claude Opus 5.5)

Status: Completed with no Swift/C++ difference or crash: 32 `CppBehaviorReferenceTests`
passed in Debug and Release, `git diff --check` clean. Same seeds/count; no C ABI or
executor change. Coverage policy, compared facts, changed files, and remaining gaps are
in `Maintanance/CPP_BEHAVIOR_COMPARISON_TASK.md` under "Dictionary seeded-randomized
result".

### MultiSet result (2026-10-04, Claude Opus 5.5)

Completed with no Swift/C++ difference or crash: 29 `CppBehaviorReferenceTests` passed
in Debug and Release, `git diff --check` clean. Same seeds/count as Set; PRNG and
diagnostic extracted to `SeededTraceSupport.swift` without changing Set behavior;
`CPP_MULTISET_OPERATION_FIND` added. Coverage policy, compared facts, changed files,
and remaining gaps are in `Maintanance/CPP_BEHAVIOR_COMPARISON_TASK.md` under
"MultiSet seeded-randomized result".

### Set PoC result (2026-10-04, Claude Opus 5.5)

Completed with no Swift/C++ difference or crash: 26 `CppBehaviorReferenceTests` passed in
Debug and Release, `git diff --check` clean. Details, PRNG/seeds/count, coverage policy,
changed files, and remaining gaps (Set positional erase not in the contract, so not
generated) are in `Maintanance/CPP_BEHAVIOR_COMPARISON_TASK.md` under
"Set seeded-randomized PoC result".

## Previous assignment objective (completed)

Complete the four-container curated C++ comparison by adding one final pair:
`RedBlackTreeMultiMap<Int64, Int64>` and `std::multimap<int64_t, int64_t>`.

The primary question is the observable placement of distinct mapped values inside an
equivalent-key group, especially under hinted insertion. Communicate with the user in
Japanese. Do not commit or push.

## Baseline

Read all committed Set/MultiSet/Dictionary comparison code, the MultiMap public
implementation and Test as Specification, and
`Maintanance/CPP_BEHAVIOR_COMPARISON_TASK.md` before editing.

Run:

```sh
swift test --disable-sandbox --filter CppBehaviorReferenceTests
```

Exactly 13 tests must pass. Stop if the baseline differs.

## Authorized Scope

You may edit only:

- `Sources/CppBehaviorReference/`
- `Tests/CppBehaviorReferenceTests/`
- this file for final status/result
- `Maintanance/CPP_BEHAVIOR_COMPARISON_TASK.md` for verified MultiMap results

Do not edit production Swift, `Package.swift`, `Benchmarks/`, existing Set/MultiSet/
Dictionary tests, randomized tests, workflows, dashboard documents, either
`AdoptionReadinessAssessment` file, or the queued benchmark task.

## Required MultiMap Comparison

Use `Int64` keys and identity-bearing `Int64` mapped values. Keep a separate
`std::multimap<int64_t, int64_t>` executor/observation path while reusing the existing
trace architecture.

Cover at least:

1. insertion of distinct keys and duplicate keys with distinct mapped values;
2. `lowerBound`, `upperBound`, and `equalRange` at before/at/between/after keys;
3. complete ordered key/value contents after every operation;
4. erase by key, including the number removed;
5. erase by a rank selected from current ordered contents, comparing the erased entry
   and the resulting next position only where both APIs expose equivalent facts;
6. update of the mapped value at a selected rank, if it maps directly to assigning
   through a valid `std::multimap` iterator;
7. hinted insertion with:
   - an empty container (`startIndex == endIndex`);
   - exact hints before and after an equivalent-key group;
   - a hint inside an equivalent-key group;
   - deliberately poor but valid hints before and after the group;
   - `startIndex` and `endIndex`;
   - reinsertion after erasure.

For every hinted insert, compare the returned rank and full ordered key/value contents.
The mapped value is the occurrence identity: use distinct values so placement within
an equal-key group is observable. Do not collapse observations to keys only.

Transport positions only as current zero-based ranks and independently resolve them
to Swift indices and C++ iterators immediately before use.

Add a deliberate mismatch test proving the diagnostic includes the container pair,
operation number, input, and both complete observations.

## Semantic discipline

- Determine the Swift API contract from implementation/tests before selecting a C++
  operation. Do not equate APIs by name alone.
- C++ hint validity and Swift hint validity must both be checked for every trace.
- If equivalent-key placement intentionally differs, preserve the smallest trace and
  report the difference; do not sort mapped values or otherwise normalize it away.
- Do not change production Swift to force agreement in this assignment.

## Stop Conditions

- On any semantic difference or crash, minimize and preserve the trace safely, set
  `Status: Blocked`, and stop before a production fix.
- Stop if a public API or Package change is needed.
- Do not expand into random/fuzz traces, performance work, or benchmark conclusions.

## Validation

1. Run narrow new MultiMap comparison tests during development.
2. Run all `CppBehaviorReferenceTests`.
3. Run `git diff --check`.
4. Confirm the changed-file list stays within the authorized scope.

Do not run the full package suite unless the focused build reveals a wider issue.

## Completion Report

Set `Status: Completed` only if the focused suite and `git diff --check` pass. Write
the exact behaviors compared, final test count/result, changed files, and real
limitations/differences into this file for Codex to review. Do not add an
accountability diary or unrelated findings.

Do not send the user a completion report or detailed handoff. Record it in the assigned
Markdown for Codex and stop. Only surface details directly when work is blocked, a
safety issue was found, or an explicit user decision is required.

### Result (2026-10-04, Claude Opus 5.5)

- **Compared** (`RedBlackTreeMultiMap<Int64, Int64>` / `std::multimap<int64_t, int64_t>`,
  distinct mapped values as occurrence identity, full ordered key/value contents
  after every operation):
  - `insert(key:value:)` ↔ `insert({k, v})`: placement after the equivalent group,
    observed through contents (neither result exposes a rank directly).
  - `insert(_:hint:)` ↔ `insert(hint, {k, v})`: returned entry and rank for an empty
    container, exact hints before/after the group, inside the group, poor hints
    before/after, `startIndex`, `endIndex`, poor hints for existing least/greatest
    keys, reinsertion at a vacated position, and reinsertion after erasing the group.
  - `find(_:)` + `count(forKey:)` ↔ `find` + `count`.
  - `lowerBound`/`upperBound` ↔ `lower_bound`/`upper_bound`: entry and rank at
    before/at/between/after keys.
  - `multimap[equalRange(k)]` ↔ `equal_range(k)`: lower/upper rank and entries in order.
  - `eraseMulti(_:)` ↔ `erase(k)`: removed count.
  - `erase(_:)` ↔ `erase(it)`: rank of the returned next position.
  - `remove(at:)` ↔ copy `*it`, then `erase(it)`: erased entry.
  - `updateValue(_:at:)` ↔ copy `it->second`, then `it->second = v`: previous value.
  - Hint/positional ranks are validated on both sides: C++ by range, Swift by range
    plus `isElement(at:)`/`isEnd(_:)` on the resolved index.
- **Result:** 4 new MultiMap tests passed; all `CppBehaviorReferenceTests` 17
  passed (baseline 13). `git diff --check` clean.
- **Changed files:** `Sources/CppBehaviorReference/include/CppBehaviorReference.h`,
  `Sources/CppBehaviorReference/CppBehaviorReference.cpp`,
  `Tests/CppBehaviorReferenceTests/MultiMapBehaviorComparisonTests.swift` (new),
  this file, `Maintanance/CPP_BEHAVIOR_COMPARISON_TASK.md`.
- **Differences/limitations:** No Swift/C++ difference or crash was found, including
  within-group placement. `remove(at:)` and `erase(_:)` each expose only one of the
  erased entry / next position, so each is compared against its C++ counterpart
  for that fact alone.

## Next assignment — credibility-first peer comparison

The next task is `Maintanance/SORTED_COLLECTIONS_BENCHMARK_TASK.md`. The project is
now prioritizing evidence that helps a user or an AI make a defensible adoption
decision over broad feature expansion.

Start with Phase 1 only: audit the existing benchmark, confirm the resolved upstream
version/trait, run the small harness smoke check, and propose a genuinely matched
Set/Dictionary workload matrix. Stop for review before the large measurement run.

Task decisions in this phase follow this order:

1. preserve or improve reproducibility and semantic comparability;
2. seek evidence capable of disproving a favorable claim;
3. record disadvantages, limitations, instability, and unmeasured axes as first-class results;
4. prefer external baselines and independently reviewable artifacts over self-rating;
5. add implementation or benchmark breadth only when it strengthens one of the above.

Do not change production code to improve a result, silently substitute a merely
similar operation, or update either AdoptionReadinessAssessment conclusion from preliminary
measurements. Treat Swift Collections as a respected upstream reference within the
same ecosystem; describe tradeoffs and suitable use cases in neutral language. Frame
this package as a provisional bridge or complement for currently unmet needs, not as
a replacement. Note evidence that would justify narrowing that role in the future.

For this and later assignments, place the detailed completion report in the assigned
Markdown file for Codex and do not send a user-facing completion message. Only a
blocker, safety concern, or decision requiring the user may be surfaced directly.

## History

Earlier assignments and result summaries:
[`CLAUDE_TASK_HISTORY.md`](CLAUDE_TASK_HISTORY.md).

## Previous Completed Result (Permutation benchmark validation / end-to-end / erase(where:) empty CoW)

- Corrected the initial Permutation subscript benchmark methodology and ran
  interleaved unchecked/checked comparisons.
- Found no practical end-to-end overhead attributable to the conventional
  two-comparison bounds check; retained it for clarity. Added Int.min/Int.max
  exit coverage.
- Added a bounded end-to-end permutation benchmark and retained raw evidence.
- Avoided empty-collection CoW in the four owning `erase(where:)`
  implementations and added focused tests.
- Focused normal/Release/compatibility tests, full `swift test`, normal build,
  and `git diff --check` succeeded. Temporary production and manifest edits were
  restored; no commit or push was performed.

## Previous Completed Result (Permutation subscript benchmark / boundary fix / strict re-audit)

- Added deterministic sequential and shuffled public-subscript benchmarks with
  raw before/after data.
- Added exit tests for `endIndex`, `-1`, and `endIndex + 1`; before the fix they
  exited successfully with unspecified reads, and after the fix all terminate
  with SIGTRAP.
- Added a two-comparison precondition only to public
  `SubSequenceN.subscript(position:)` and retained a valid-boundary test.
- Initial microbenchmarks reported material overhead; after-runs varied by
  10–15%, so the result requires the validation assigned above.
- Temporary strict checking remained at 14 unique diagnostics in G2–G6 and
  `Package.swift` was restored. Focused normal, Release, and compatibility tests,
  normal build, and `git diff --check` succeeded.

## Previous Completed Result (API matrix / Permutation strict batch 1 / boundary investigation)

- Reconciled `API-Matrix.md` and `API-Matrix-View.md` with current production
  APIs, including MultiMap mapped-values versus key-value range views.
- Added scoped `unsafe` only to the three expressions in
  `Permutations.Buffer.deinit`; temporary strict checking reduced unique
  diagnostics from 17 to 14, with `Package.swift` restored.
- Characterized public `SubSequenceN` invalid index access in child processes:
  nearby invalid indices returned configuration-dependent garbage and a distant
  index caused SIGSEGV. No misleading death test was retained.
- Normal build, focused normal/compatibility tests, and `git diff --check`
  succeeded. No commit or push was performed.

## Latest Follow-up Assignment (completed)

Complete these three bounded tasks in order. Communicate with the user in
Japanese. Work only inside the repository. Do not edit the paused Set,
Dictionary, or MultiSet outlines. Do not start the deferred C++ comparison
target, change `erase(where:)`, commit, or push.

### Task 1 — Remove the unsupported capacity recommendation

The evidence in `Maintanance/CombiningAPIPerformanceEvidence.md` shows that the
existing “If sufficient space is available” recommendation does not describe
the implementation and is not supported by the measurements.

1. Locate every current public documentation comment that makes this
   recommendation for `union` / `formUnion`, `meld` / `melding`, or the related
   insertion-loop APIs in Set, MultiSet, and MultiMap.
2. Remove the unsupported capacity-based recommendation everywhere it appears.
3. Replace it only with concise, stable facts already guaranteed by the API and
   implementation, such as the documented complexity and whether the operation
   mutates the receiver or returns a new collection. Do not put benchmark
   thresholds, machine-specific timing, speculative allocator explanations, or
   a new universal recommendation into public API comments.
4. Keep Dictionary comments unchanged unless the unsupported sentence actually
   exists there. Do not edit the paused outlines or generated Head drafts.
5. Add or adjust documentation tests only if the repository already has a
   suitable mechanism; do not create a new documentation-test framework.

### Task 2 — Measure the `___meld_unique` capacity asymmetry as a reversible PoC

Determine whether preallocating `count + other.count` in `___meld_unique`, as
`___meld_multi` already does, materially changes Set `union` / `formUnion`
performance.

1. Identify the smallest production-code change needed for a PoC.
2. Run the existing bounded deterministic Set combining benchmarks before and
   after that temporary change, using identical commands and inputs.
3. Validate results and record raw PoC data under a clearly named repository-
   local benchmark results directory.
4. Restore the production source exactly after measuring. This task is evidence
   gathering only; do not leave the optimization applied.
5. Record the patch shape, commands, results, noise limitations, and a clear
   recommendation in `Maintanance/CombiningAPIPerformanceEvidence.md` or a
   concise linked companion note.

Do not broaden the PoC into allocator, tree-layout, or insertion-algorithm
changes.

### Task 3 — Produce an actionable strict-memory-safety plan for PermutationModule

Use the existing 34-diagnostic audit as the starting point. Do not enable
`.strictMemorySafety()` for `PermutationModule` and do not change production
code in this task.

1. Reproduce the diagnostics for `PermutationModule` with a temporary manifest
   edit, then restore `Package.swift` to the stage-1 adopted state.
2. Group diagnostics by declaration and ownership boundary rather than merely
   by compiler message text.
3. For each group, identify the smallest likely remediation (`unsafe`
   declaration/conformance, scoped unsafe use, API redesign, or no safe local
   fix) and explain why.
4. Propose small reviewable implementation batches, with the first batch no
   larger than necessary to validate the approach.
5. Update `Maintanance/StrictMemorySafetyReadiness.md` with the plan, but do not
   add annotations, suppressions, or concurrency changes yet.

Validation and handoff:

- Run only the builds, tests, and bounded benchmarks required for factual
  claims.
- Run `git diff --check` and confirm temporary source/manifest edits are fully
  restored.
- Before marking this assignment completed, move the current completed
  assignment and its result summary into `CLAUDE_TASK_HISTORY.md`. Keep this
  file limited to the newest assignment, newest concise result summary, and the
  history link.
- Do not commit or push.

## Result Summary

Completed Tasks 1–3 in order. Did not edit any outline, start the C++
comparison target, touch `erase(where:)`, or address the other pending
decisions. No commit or push.

**Task 1 (documentation):** Removed all six unsupported
`- Important: If sufficient space (complexity) is available, using … is
recommended.` notes: Set `merge(_: RedBlackTreeSet)` / `merging(_:
RedBlackTreeSet)`, MultiSet `insert(contentsOf: RedBlackTreeSet)` /
`inserting(contentsOf: RedBlackTreeMultiSet)`, MultiMap `insert(contentsOf:)` /
`inserting(contentsOf:)` (`*+Combining.swift`). The remaining comments already
state complexity and non-mutation, so no replacement sentence was added.
Dictionary had no such sentence. No documentation-test mechanism exists, so no
test was added.

**Task 2 (`___meld_unique` PoC):** Temporarily changed the result buffer from
`minimumCapacity: 2` to `count + other.count` (one line), measured the 14
deterministic Set combining cases (7 `formUnion` + 7 `merge` controls) before
and after, twice each with `--cycles 10`, then restored the source exactly
(`git diff` empty; the post-restore release rebuild confirmed the PoC had been
compiled). `formUnion` after/before ratios were 0.96–1.04, inside the
0.97–1.04 range of the unaffected `merge` controls. Recommendation: do not adopt
it for performance; growth appends buckets without moving nodes
(`Design-NodeStorage.md`). Raw data: `Benchmarks/Results/MeldUniqueCapacityPoC/`;
write-up: `CombiningAPIPerformanceEvidence.md` §4.

**Task 3 (PermutationModule plan):** Reproduced the diagnostics with a
temporary manifest edit and then restored the manifest (`git diff Package.swift`
empty). Found 34 warning lines, which are 17 unique diagnostics printed twice;
all are `Buffer`-internal expression warnings, with no conformance, storage, or
public-signature diagnostics. Grouped them into G1–G6 by declaration and
ownership boundary, proposed four batches (batch 1: scoped `unsafe` in `deinit`
only), and recorded the plan in `StrictMemorySafetyReadiness.md` §8. Concerns
for the user: the public `SubSequenceN[position]` reaches an unchecked pointer
subscript (code reading), `copy(newCapacity:)` does not check
`newCapacity >= count`, and `unsafeDowncast` is used on a non-final class.

**Validation:** `swift build` succeeded. In `Benchmarks/`, the run command was
`swift run -c release benchmark run --filter 'RedBlackTreeSet<Int>
(merge|formUnion)(,| with (sorted|shuffled|duplicate-heavy))' --sizes 1k 16k
256k --cycles 10 --mode replace-all Results/MeldUniqueCapacityPoC/<before|after>-run<1|2>.json`;
all post-timing validations passed. `swift build --target PermutationModule` was
run with the temporary setting. `git diff --check` is clean. Only comment
lines changed in Sources, so `swift test` was not run.

## Latest Follow-up Assignment (completed)

Complete these three bounded tasks in order. Communicate with the user in
Japanese. Work only inside the repository, as required by the root `CLAUDE.md`.
Do not edit the paused `RedBlackTreeSet` or `RedBlackTreeDictionary` outlines,
do not start the deferred C++ comparison target, and do not optimize production
meld code or the unrelated `erase(where:)` CoW path. Do not commit or push.

### Task 1 — Validate and harden the new Combining benchmarks

Review the benchmark cases added in
`Benchmarks/Sources/Benchmarks/CombiningAPIBenchmarks.swift` before treating the
recorded measurements as durable evidence.

1. Make shuffled inputs deterministic and reproducible. Do not use an
   unseeded `shuffled()` call in evidence-producing benchmarks.
2. Confirm from the benchmark harness semantics that every measured sample
   starts from the intended collection state. In particular, ensure a mutating
   combining operation is not repeatedly measured against a destination that
   already contains `other`. If necessary, restructure setup/reset without
   timing construction that is meant to remain outside the measured operation.
3. Add lightweight result validation outside the timed region so a benchmark
   cannot silently measure an incorrect or no-op final state.
4. Re-run only the same bounded representative measurement set. Replace the raw
   result files and update `Maintanance/CombiningAPIPerformanceEvidence.md` if
   corrected methodology changes any conclusion.
5. Record the exact repository-local commands. Do not access external result or
   cache directories, and do not expand this into a larger benchmark campaign.

### Task 2 — Enable strict memory safety for the two warning-free facades

Permanently add `.strictMemorySafety()` only to the `AcCollections` and
`RedBlackTreeModule` targets identified as warning-free by
`Maintanance/StrictMemorySafetyReadiness.md`.

1. Make the smallest possible `Package.swift` change.
2. Build each affected target and the complete root package. Run the normal root
   test suite if the build succeeds.
3. Confirm these two targets still emit no strict-memory-safety diagnostics.
4. If either target produces a warning or error, revert that target's setting
   rather than changing production declarations or adding suppressions.
5. Update the readiness document and current maintenance status to distinguish
   this completed first adoption stage from the still-deferred low-level targets.

Do not enable the setting for `PermutationModule`, `BareArrayModule`,
`OptionalArrayModule`, or `RedBlackTreeCollections` in this task.

### Task 3 — Compact the Claude task handoff

`Maintanance/CLAUDE_TASK.md` has accumulated nearly one thousand lines of
completed assignments, which makes every session startup unnecessarily costly.

1. Move the completed assignment text and result summaries into
   `Maintanance/CLAUDE_TASK_HISTORY.md`, preserving their order and factual
   content.
2. Keep this file focused on the current status, active assignment, the latest
   concise result summary, and a link to the history file.
3. Do not rewrite or reinterpret historical decisions while moving them.
4. Keep the resulting active handoff short enough to scan at session startup.

Validation for all three tasks:

- Run the narrow benchmark/build/test commands required by the claims above.
- Run `git diff --check`.
- Confirm `Package.swift` contains the setting only for the two authorized
  facade targets.
- Change this status to `Completed` only when all three tasks are complete and
  add a concise result summary above the archived-history link.

## Result Summary

Completed Tasks 1–3 in order. Did not edit the paused outlines, start the C++
comparison target, or touch production meld / `erase(where:)` code. No commit.

**Task 1 (Combining benchmarks):** Confirmed from
`swift-collections-benchmark`'s `Task.measure` / `Timer._nestedMeasure` that the
setup closure runs once per size and the instance closure once per sample, with
only `timer.measure` timed — so no sample re-measured a destination already
containing `other`. Found a different flaw: the "with sorted/shuffled/
duplicate-heavy other" cases used `var a = base`, sharing storage with the
captured `base`, so insertion-loop timings included an unintended CoW copy.
Every case now builds a fresh destination per sample outside the timed region
(only "shared storage" cases share, intentionally). Shuffles use a fixed-seed
SplitMix64 via `shuffled(using:)`. Each sample validates `count`/`first`/`last`
with `precondition` after timing. Re-ran the same bounded set twice (raw files
hold the second run). Conclusions unchanged; updated tables, sorted/shuffled
ratios (merge ~6.0x, formUnion ~3.4x at 256k), and recorded that identical-code
cases differ ~1.5x at 16k, leaving the MultiSet `insert(contentsOf:)` reserve
effect at 16k (~1.6x) undetermined.

**Task 2 (strict memory safety, stage 1):** Added `.strictMemorySafety()` only
to `AcCollections` and `RedBlackTreeModule`. Verified via `-v` that both
modules compile with `-strict-memory-safety` and emit 0 diagnostics. Updated
`StrictMemorySafetyReadiness.md` (adoption-status table) and
`MAINTENANCE.md` (相談事項); the four low-level targets remain deferred.

**Task 3 (handoff compaction):** Moved all completed assignments and result
summaries verbatim, in order, to `Maintanance/CLAUDE_TASK_HISTORY.md`.

**Validation:**
- `swift build -c release` (in `Benchmarks/`) — succeeded.
- In `Benchmarks/`:
  `swift run -c release benchmark run --filter 'RedBlackTreeSet<Int> (merge|formUnion)' --sizes 1k 16k 256k --cycles 1 --mode replace-all Results/CombiningAPI/results-RedBlackTreeSet-combining.json`
  and
  `swift run -c release benchmark run --filter 'RedBlackTreeMultiSet<Int> (insert\(contentsOf:\)|meld)' --sizes 1k 16k 256k --cycles 1 --mode replace-all Results/CombiningAPI/results-RedBlackTreeMultiSet-combining.json`
  — each run twice, all validations passed.
- `swift build --target RedBlackTreeModule`, `swift build --target AcCollections`
  (forced recompile), `swift build` — succeeded, 0 warnings in the two targets.
- `swift test` (repository root) — all passed, 0 failures.
- `Package.swift` contains `.strictMemorySafety()` only for the two facades
  (the commented placeholder in `RedBlackTreeCollections` is unchanged).
- `git diff --check` — clean.

## Result Summary (three follow-up investigations)

Completed all three tasks in the user-recommended order: Task 3, Task 1, Task 2.
Did not edit the paused RedBlackTreeSet outline or the RedBlackTreeDictionary
outline Codex was concurrently editing, and did not start the deferred C++
comparison target or the unrelated `erase(where:)` CoW issue.

**Task 3 (stale maintenance status reconciliation):** Removed the
`TreeFoundamentalAllocationTests`のASan調査 and `PermutationModule改修管理`
entries from `MAINTENANCE.md`'s `優先事項` and recorded them as completed in
`完了済みの要望`, with a concise cause/result note for the ASan case (root
cause was test-counter contamination from `AcCollectionsTests` lacking
`RedBlackTreeCollections`の寿命カウンタ discipline after
`TreeFoundamentalAllocationTests`'s macOS-only guard was widened to
`#if DEBUG`, not a real memory-safety bug; fixed in commits `c62a633b`/
`9add0d5d`/`8bc7c3ba`/`60efef09`). Confirmed locally
(`swift test --filter TreeFoundamentalAllocationTests` 5/5,
`AcCollectionsTests` 3/3) since this session has no GitHub Actions access.
Confirmed all four Codable non-sorted/duplicate-input regression tests exist
and pass (`RedBlackTreeDictionaryCodableTests`,`RedBlackTreeSetCodableTests`,
`RedBlackTreeMultiSetCodableTests`,`RedBlackTreeMultiMapCodableTests`; 14
tests, 0 failures) — no stale pending item referenced this as missing.
Confirmed `Tests/TESTING.md` already represents the PermutationModule and
`unranged()` removals as completed.

**Task 1 (strictMemorySafety readiness audit):** Temporarily applied
`.strictMemorySafety()` to `RedBlackTreeCollections`, `AcCollections`,
`RedBlackTreeModule`, `PermutationModule`, `OptionalArrayModule`, and
`BareArrayModule`; collected and classified diagnostics by target/file/category
in `Maintanance/StrictMemorySafetyReadiness.md`. All targets built with 0
errors. `AcCollections`と`RedBlackTreeModule`は警告0件で即時適用可能。
`PermutationModule`(34)/`BareArrayModule`(116)/`OptionalArrayModule`(144)/
`RedBlackTreeCollections`(4,948)はいずれも意図的な生ポインタ・手動メモリ管理
コード由来の警告で、機械的に直せる「ふつうの宣言」由来の警告は見つからなかった。
段階的採用順を提案。Restored `Package.swift` exactly
(`git diff Package.swift` empty). No annotations, concurrency semantics, or
diagnostic suppressions were added.

**Task 2 (Combining API evidence gap):** Traced `merge`/`merging`/
`insert(contentsOf:)`/`inserting(contentsOf:)`(O(*n* log(*m+n*)), via
`___insert_range_unique`/`___insert_range_multi`) against `union`/`formUnion`/
`meld`/`melding`(O(*n*+*m*), via `___meld_unique`/`___meld_multi`) for
Set/MultiSet/MultiMap(Dictionaryにはmeld系の代替が存在しない)。Found that
`___meld_unique`(Setのmeld経路)はcapacity 2から都度拡張するのに対し
`___meld_multi`(MultiSet/MultiMap)は`count+other.count`を事前確保する非対称性
を発見。Added 19 Set + 8 MultiSet benchmark cases to
`Benchmarks/Sources/Benchmarks/CombiningAPIBenchmarks.swift`(reusing the
existing `swift-collections-benchmark`harness)and ran a bounded measurement
(sizes 1k/16k/256k, cycles 1, <4s total)。Raw results saved to
`Benchmarks/Results/CombiningAPI/`。Found: (a) `reserveCapacity`has no measurable
effect on either path(meld系は呼び出し元の容量を参照しないため); (b) at
1k–256k the insertion-loop path was consistently faster than the meld path;
(c) `other`'s construction order(sorted literal vs shuffled insertion)caused a
2–6x difference, larger than anything the capacity axis explains; (d) shared
destination storage costs the insertion-loop path an extra CoW copy but does
not affect the meld path. Recorded full evidence, conclusions, and a proposed
conditional-wording direction (not applied to public docs) in
`Maintanance/CombiningAPIPerformanceEvidence.md`, and flagged the
`___meld_unique`missing-upfront-capacity asymmetry as a separate suspected
performance defect for future consideration (not fixed in this task).

**Validation (all three tasks):**
- `swift test --filter TreeFoundamentalAllocationTests` — 5/5 passed.
- `swift test --filter 'RedBlackTreeDictionaryCodableTests|RedBlackTreeSetCodableTests|RedBlackTreeMultiSetCodableTests|RedBlackTreeMultiMapCodableTests'` — 14/14 passed.
- `swift build --target RedBlackTreeCollections` and `swift build`(全ターゲット)with
  `.strictMemorySafety()`temporarily applied — succeeded, 0 errors.
- `swift build -c release`(Benchmarks package, with the new benchmark file) — succeeded.
- `swift run -c release benchmark run`(bounded, sizes 1k/16k/256k, cycles 1) —
  succeeded for Set and MultiSet combining benchmarks.
- `swift test`(repository root, normal mode) — full suite passed, no failures.
- `git diff --check` — clean.
- `git diff Package.swift` — empty (restored).

Reported to the user in Japanese.

## Previous Active Follow-up Assignment (now completed, see Result Summary above)

Complete these three bounded tasks in order. Communicate with the user in
Japanese. Do not edit the paused RedBlackTreeSet outline. Do not start the C++
behavior-comparison target, which the user explicitly deferred.

### Task 1 — Audit readiness for strict memory safety

The user wants to move toward `.strictMemorySafety()`. Perform a readiness
audit only; do not permanently enable the setting in this task.

1. Confirm the exact SwiftPM setting supported by the repository's current
   tools version and toolchain using authoritative documentation/tool output.
2. Temporarily apply it to the smallest relevant target, then to the package
   targets where practical, and collect every compiler diagnostic by target,
   file, and category.
3. Separate diagnostics caused by intentional low-level pointer/storage code
   from ordinary declarations that can be fixed mechanically.
4. Propose a staged adoption order with small reviewable batches. Identify any
   target that can enable the setting immediately without production changes.
5. Restore `Package.swift` exactly before finishing. Record commands, results,
   and recommendations in a concise maintenance document and update
   `Maintanance/MAINTENANCE.md` without claiming adoption is complete.

Do not add annotations, change concurrency semantics, or suppress diagnostics
as part of this audit.

### Task 2 — Resolve the evidence gap behind Combining API recommendations

Investigate the existing documentation recommendation around incremental
insertion versus `union` / `formUnion` / `merge` / `merging` / `meld` /
`melding`. The current "sufficient capacity" wording lacks evidence.

1. Trace the actual implementation paths and documented complexity for the
   corresponding Set, MultiSet, Dictionary, and MultiMap operations.
2. Reuse the benchmark package and existing benchmark conventions. Add only
   focused benchmark cases needed to compare representative input sizes,
   already-sorted versus shuffled input, unique versus duplicate-heavy input,
   reserved versus unreserved destination capacity, and unique versus shared
   storage where applicable.
3. Run a small, reproducible measurement set sufficient to reveal trends; do
   not launch an unbounded benchmark campaign.
4. Record commands, environment, raw result location, and evidence-backed
   conclusions in a concise maintenance document.
5. Do not rewrite the public recommendation yet. If results do not support one
   simple rule, say so and propose accurate conditional wording for user
   review.

Do not optimize production code during this task. Report any suspected
performance defect separately.

### Task 3 — Reconcile stale maintenance status

Review only the current-state sections of `Maintanance/MAINTENANCE.md` and
`Tests/TESTING.md` against the repository and recent completed work.

- Mark the Linux ASan investigation resolved now that CI passes, preserving a
  concise cause/result record rather than deleting the history.
- Confirm the four Codable non-sorted/duplicate-input regression tests and the
  corresponding implementation fix already exist; remove any current pending
  item that still claims this work is missing.
- Confirm the PermutationModule and `unranged()` removals are represented as
  completed, not pending.
- Preserve user-written future requests, the deferred C++ target, open design
  questions, and historical reference logs.
- Keep `Current handoff` within its documented size limit instead of appending
  another long chronology.

Validation for all three tasks:

- Run the narrow builds/tests needed for factual claims.
- Restore every temporary manifest/configuration edit.
- Run `git diff --check`.
- Change this status to `Completed` only after all three tasks are complete and
  add a concise result summary above the earlier completed assignments.

## Previous Result Summary (completed follow-up)

Completed all three tasks below.

**Task 1:** Removed `Tests/PermutationTests/NextPermutation.swift` (test-only
`NextPermutation` protocol, `Array` conformance, `NextPermutationUnsafeHandle`,
and its duplicate algorithm) and the `testPerformance00` test that was its only
caller, from `Tests/PermutationTests/PermutationTests.swift`. Confirmed via
repository-wide grep that nothing else referenced
`NextPermutationUnsafeHandle`, the test-only `NextPermutation` protocol, or
`forEach_nextPermutation`. Updated `Maintanance/PermutationModule/
ImplementationPlan.md`, `ProductReadinessAssessment.md`,
`Sources/PermutationModule/Documentation/Specification.md`, and
`Tests/TESTING.md` to record this as completed rather than a pending decision.

**Task 2:** Added an English doc comment to `nextPermutations()` documenting
the tested contract (current order first, only lexicographic successors
afterward, no duplicate value orderings for equal elements, single-pass
termination for descending/all-equal/single-element/empty input, stability of
previously yielded results, worst-case O(n) per step), and brief doc comments
to `Permutations.Nexts`, `Permutations.IteratorN`, and `Permutations.SubSequenceN`.
No `ManagedBuffer`/implementation detail was added to the public comments.

**Task 3:** Added two `Removed` entries to `CHANGELOG.md`'s `[Unreleased]`
section: the PermutationModule full-permutation/unsafe API removal (leaving
`nextPermutations()` as the sole entry point) and the Range View `unranged()` /
`ScalarBaseInit` / `KeyValueBaseInit` removal. No other section was changed.

**Validation:**
- `swift test --filter PermutationTests` — 2/2 passed (post-removal).
- `swift build` — succeeded with the new doc comments.
- `swift test` from the repository root (normal mode) — full suite passed,
  0 failures across all suites.
- Temporarily uncommented `.define("COMPATIBLE_ATCODER_2025")`, ran
  `swift build` and `swift test --filter 'AcCollectionsTests|PermutationTests'`
  — both succeeded, then restored `Package.swift` (`git diff Package.swift`
  empty).
- Repository-wide grep for `NextPermutationUnsafeHandle`,
  `forEach_nextPermutation`, `testPerformance00`, and the deleted file path —
  only this task file's description and the maintenance docs' historical
  completion notes remain.
- `git diff --check` — clean.

Reported to the user in Japanese.

## Completed Follow-up Assignment

Complete these three bounded tasks in order. Communicate with the user in
Japanese. Do not edit the paused RedBlackTreeSet outline and do not broaden
this work into new PermutationModule features.

### Task 1 — Remove the remaining test-only permutation implementation

The production module now has one implementation path, but
`Tests/PermutationTests/NextPermutation.swift` still contains a separate older
`NextPermutation` protocol, `Array` conformance, unsafe-buffer handle, and
algorithm implementation. The user wants implementation variants reduced.

1. Confirm with a repository-wide search that this file is used only by
   `testPerformance00` in `PermutationTests.swift` and is not a required oracle
   for another test.
2. Remove `Tests/PermutationTests/NextPermutation.swift` and remove
   `testPerformance00` or rewrite no test to depend on a second implementation.
   Do not move the duplicate algorithm elsewhere.
3. Update the Permutation maintenance documents and `Tests/TESTING.md` so this
   is no longer listed as a pending user decision or surviving implementation.
4. Verify no references to `NextPermutationUnsafeHandle`, the test-only
   `NextPermutation` protocol, `forEach_nextPermutation`, or
   `testPerformance00` remain.

### Task 2 — Finish public documentation for the retained API

Update the English documentation comment for `nextPermutations()` and only the
public return types where needed. Document the current tested contract:

- the current ordering is yielded first;
- only lexicographic successors are then yielded;
- equal elements do not create duplicate value orderings;
- descending, all-equal, single-element, and empty inputs each yield the
  current ordering once;
- previously yielded results remain stable as iteration advances;
- one permutation step is worst-case O(n).

Keep implementation details such as `ManagedBuffer` out of the public
contract. Ensure comments are English, match
`Sources/PermutationModule/Documentation/Specification.md`, and do not mention
removed unsafe/full-permutation APIs as current alternatives.

### Task 3 — Record the breaking removals in CHANGELOG

Update only the current `[Unreleased]` section of `CHANGELOG.md`. Under
`Removed`, concisely record:

- removal of the full-permutation and unsafe PermutationModule public APIs,
  leaving `nextPermutations()` as the supported entry point;
- removal of Range View `unranged()` and its single-purpose support protocols.

Describe these as source-breaking public API removals. Do not rewrite prior
release sections and do not turn the maintenance history into changelog prose.

Validation for this assignment:

- Run the narrow Permutation tests and confirm the intended tests ran.
- Run repository-root `swift test`.
- Run compatibility-mode validation for the affected Permutation facade path.
- Search for all removed declarations and stale pending-decision text.
- Run `git diff --check`.
- Change this status to `Completed` only after all three tasks and validations
  complete, then add a concise result summary above the historical material.

## Completed Assignment (Tasks 1–3)

The assignment below is retained as the completed historical request. Its
three tasks have been implemented and validated. Do not edit
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

### Task 3 — Remove `unranged()` and its single-purpose protocols

After Tasks 1 and 2 are complete, implement the user's existing removal request
for the deprecated Range View `unranged()` API.

User authorization is explicit and final. Do not ask whether to defer this
task, do not merely correct the status, and do not leave it under pending
decisions. Start Task 3 now. The assignment is not complete until Task 3 and
its validation are complete.

Required work:

1. Remove `unranged()` from both `RedBlackTreeKeyOnlyRangeView` and
   `RedBlackTreeKeyValueRangeView`.
2. Confirm that `ScalarBaseInit`, `KeyValueBaseInit`, their `_create(_:)`
   requirements, and the four container conformances exist only to support
   `unranged()`. If the repository-wide search confirms that, remove them too.
   If another real use exists, stop and report it instead of deleting the
   protocol blindly.
3. Remove the four public-type tests dedicated only to `unranged()` while
   preserving the surrounding Range View tests.
4. Update `API-Matrix.md`, `API-Matrix-View.md`, `Tests/TESTING.md`, and any
   other current documentation that still presents `unranged()` or these
   protocols as available or pending removal.
5. Search the entire repository after editing. No source, test, or current-doc
   reference to the removed API should remain; historical reference material
   may retain an explicitly historical note.

Validation for Task 3:

- Run the four affected Range View test suites or the narrowest equivalent
  filters and confirm the intended tests ran.
- Run repository-root `swift test`.
- Run compatibility-mode validation if the removed declarations are compiled
  there.
- Run `git diff --check`.

Do not broaden Task 3 into unrelated Range View redesign or cleanup.

When all three tasks are complete, change this status to `Completed` and
add a new corrected result summary above the previous result summary. Do not
delete the previous record; label it as superseded where necessary.

## Result Summary (this pass)

Completed Task 3 (unranged() removal). Tasks 1 and 2 were already complete
from the previous pass (see "Partial Result Summary" below, now superseded by
this heading rename).

**Task 3 (`unranged()` and single-purpose protocol removal):**

- Removed `public func unranged()` from both
  `RedBlackTreeKeyOnlyRangeView` (`RedBlackTreeRangeView+KeyOnly.swift`) and
  `RedBlackTreeKeyValueRangeView` (`RedBlackTreeRangeView+KeyValue.swift`).
- Repository-wide search confirmed `ScalarBaseInit`/`KeyValueBaseInit`, their
  `_create(_:)` requirements, and the four container conformances
  (`RedBlackTreeSet`, `RedBlackTreeMultiSet`, `RedBlackTreeDictionary`,
  `RedBlackTreeMultiMap`) existed only to support `unranged()`; no other call
  site referenced `_create(_:)` or these protocols. Removed both protocols,
  their conformances, and the `_create(_:)` requirement entirely.
- Removed the four public-type tests dedicated only to `unranged()`:
  `testUnrangedReturnsRemainingBaseRangeAfterDrainingWithPopFirst` (Set),
  `test_unranged_returnsRemainingBaseRangeAfterDrainingPartially` (MultiSet and
  Dictionary), `test_unranged_returnsTheCollectionAfterMutatingTheView`
  (MultiMap). The surrounding Range View test suites were preserved and still
  pass (56/56 in the four affected suites).
- Updated `API-Matrix.md` and `API-Matrix-View.md` (removed the `unranged()`
  row and its now-dangling "実験的API" note), `Tests/TESTING.md` (removed the
  `unranged()` pending-decision entry), and `Maintanance/MAINTENANCE.md`
  (moved the user's removal request from "User requests for the next session"
  to "完了済みの要望"). `Tests/TESTING_REFERENCE.md`'s dated historical log
  entry was left as-is per the historical-note allowance.
- Repository-wide grep for `unranged`, `ScalarBaseInit`, `KeyValueBaseInit`
  after editing found no remaining source, test, or current-doc reference;
  only this task file (describing the removal) and the two historical notes
  above remain.

**Task 3 validation:**

- `swift test --filter 'RedBlackTreeSetRangeViewTests|RedBlackTreeMultiSetRangeViewTests|RedBlackTreeDictionaryRangeViewTests|RedBlackTreeMultiMapRangeViewTests'`
  — 56/56 passed.
- `swift test` from the repository root (normal mode) — full suite passed, no
  failures (`grep -c "Test run with" ` all `0 failures`/`passed`).
- Temporarily uncommented `.define("COMPATIBLE_ATCODER_2025")`, ran `swift
  build` and `swift test` — both succeeded (the removed declarations live
  entirely inside `#if !COMPATIBLE_ATCODER_2025` in both source files, so they
  never compiled in compat mode; this run confirms no regression elsewhere),
  then restored `Package.swift` (`git diff Package.swift` empty).
- `git diff --check` — clean.

Note: during this pass, this file's `Status` and Task 3 instructions were
externally edited (by Codex) to explicitly authorize immediate implementation
while validation of Tasks 1/2 was still running in this session. That edit's
content matched what the user had just separately confirmed when asked
directly, so Task 3 proceeded as authorized by the user.

## Partial Result Summary (Tasks 1 and 2 only; Task 3 remains active)

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

# Archived Result — Scratch Hygiene and Permutation Sendable Handoff

Status: Completed (2026-10-03, Claude Opus 5.5)

- Inspected Git status and found no disposable scratch files to remove. No
  task-owned temporary directory was created.
- Added the Permutation Sendable handoff to
  `Maintanance/StrictMemorySafetyReadiness.md`: `Permutations` and `Nexts` were
  classified as mechanical, while `IteratorN` and `SubSequenceN` require an
  ownership decision because they share a mutable CoW `Buffer`.
- Proposed small future batches: sequence surface, final buffer, then
  iterator/subsequence plus a cross-task test.
- Ran `git diff --check`; no commit or push was performed.
# Archived Result — MultiSet C++ Comparison Expansion

Status: Blocked (2026-10-04, Claude Opus 5.5)

- Added deterministic `RedBlackTreeMultiSet`/`std::multiset` comparison for
  insertion, duplicates, bounds, equal ranges, erasure counts, and non-end hints.
- Found a minimal production failure: `insert(10)`, then
  `insert(20, hint: endIndex)` crashes in `__tree_left_rotate` in Debug, while
  `std::multiset` inserts normally.
- Preserved the minimal trace and full end-hint trace as disabled tests; 6 focused
  comparison tests passed and 2 were skipped. Production code was not changed.
- Suspected `__find_leaf` boundary-check divergence from the corresponding libc++
  control flow; handed off for a separate test-first repair.
# Archived Result — MultiSet Hint Boundary Repair

Status: Completed (2026-10-04, Claude Opus 5.5)

- Confirmed `std::multiset` accepts the minimal nonempty `end()` hint trace while
  Swift previously trapped in `__tree_left_rotate`.
- Corrected one multi hinted-leaf boundary condition to match libc++ and the unique
  search path: `__hint == end` became `__prior == __begin_node_`.
- Added process-isolated start/end/empty regressions and enabled both blocked C++
  comparison traces. All 9 comparison tests passed; focused MultiSet/MultiMap and
  raw-tree suites also passed. `git diff --check` passed.
# Archived Result — Dictionary C++ Comparison Expansion

Status: Completed (2026-10-04, Claude Opus 5.5)

- Added deterministic `RedBlackTreeDictionary<Int64, Int64>`/`std::map` comparison
  for insert, hinted insert, update/assign, subscripts, lookup, bounds, equal range,
  erase-by-key, returned facts, ranks, and complete ordered contents.
- Kept insert-preserves-existing semantics separate from update-replaces-existing
  semantics. Documented that the current C++ mode spells out `insert_or_assign`'s
  effect and that `erase(key)` cannot report Swift's removed mapped value.
- Added 4 tests; all 13 root comparison tests passed. `git diff --check` passed.

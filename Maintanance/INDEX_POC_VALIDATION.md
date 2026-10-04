# `try/index/1` validation

Status: Initial issue inventory after merging `develop/misc/48`

## Product-owner direction

The user strongly prefers adopting this success-only Index approach. Validation therefore treats
`try/index/1` as the leading implementation candidate, not as one equally weighted option in a
neutral design bake-off.

- Missing tests, documentation drift, and prototype public-surface artifacts are correction work.
  Any failure of a Quality Checklist property—especially memory safety and Index validity for
  stale, recycled, detached, cross-tree, outliving-storage, and `_O_UNCHECKED` cases—is blocking
  regardless of how localized its code is. Record it before any fix and count it as resolved only
  after re-verification in every configuration where it failed. It is correctable within this
  approach only after a demonstrated fix keeps the public Index success-only.
- Adoption requires positive evidence for every applicable Quality Checklist property. A failing
  property without a demonstrated success-only fix gives `adoption blocked by specified evidence`.
  An unmapped or unmeasured property gives `evidence incomplete`; neither outcome requires proof
  that every possible fix is impossible.
- `Comparable`, a nominal public wrapper, and ContainersPreview conformance remain later decisions;
  they are neither reasons by themselves to reject this representation nor evidence for adopting
  it.

A deeper contradiction exists if a required observable behavior can only be represented by a
failure value inside the public Index, if validity checking needs more than O(1) per access or adds
per-element traversal work, or if Index lifetime cannot be guaranteed with the success-only
representation's storage tie.

## Scope and baseline

This validates the merged branch at `6bdcfecd` against `develop/misc/48` at `2796d7c2`.
The PoC-specific diff is 24 paths, 370 insertions, and 21 deletions. The central change is:

```swift
public typealias UnsafeIndexV3 = _LazyTiedPtr
```

The public Index therefore stores only a successful sealed pointer plus its storage-lifetime tie.
Resolution still returns internal `Result<..., SealError>` values.

Baseline already observed after the merge:

- Xcode build-for-testing succeeds.
- The four BoundExpression suites pass: 69 tests, 0 failures.
- `git diff --check` is clean.

Passing this baseline is not adoption approval. The Quality Checklist requires correctness, memory
and Index lifetime, and performance evidence beyond compilation.

The net two-dot diff is the correct present scope because `2796d7c2` is an ancestor of the merge
commit. It folds in conflict resolutions from both the 2026-10-04 and 2026-10-05 merges; any
resolution without recorded intent remains a stop condition. The older X1 identity map is retained
as history but its snapshot anchors are superseded by the commits above for this validation.

## Initial issue register

| ID | State | Area | Issue / required evidence |
| --- | --- | --- | --- |
| `P1` | pass | Test as Specification | Four internal tests verify Debug `.index(.nullptr)` on non-empty containers without recreating a public failure-valued Index. Codex and Claude confirmed the resolver reaches `.failure(.null)` rather than trapping. |
| `P2` | partial pass; review queued | Index lifetime | Representative stale/recycled/movement/MappedValues paths pass in Debug, Release, a narrowly filtered Release + `_O_UNCHECKED` batch, and Debug ASan. A new test confirms that an Index outliving its storage has a detached tie and is safely rejected by another live receiver under ASan. Direct `.detached` error propagation and full per-property mapping remain. |
| `P3` | partial pass; review queued | Configuration matrix | Debug, Release, representative Release + `_O_UNCHECKED`, Debug `COMPATIBLE_ATCODER_2025`, and representative Debug ASan evidence is recorded below. Compatibility Release remains unmapped. |
| `P4` | unverified | Container/View breadth | Validate `RedBlackTreeSet` and `RedBlackTreeMappedValuesView` first, then KeyValue Range View, the remaining containers, and KeyOnly Range View. MappedValues is the sensitive first View because its single-Index read/modify/swap paths depend directly on O(1) `__purified_` resolution and CoW migration. |
| `P5` | confirmed test hazard | Debug fixture semantics | `_LazyTieWrap.unsafe(tree:rawTag:)` maps every retrieval, seal, or banding failure to synthetic `.nullptr`. On an empty tree, `_emptyLazyDetach` is shared, so same-tie purification can assert on the null pointer instead of producing the intended `SealError`. Synthetic-null tests must use a non-empty tree and verify the error reason, not merely expect process failure. |
| `P6` | confirmed artifacts; review queued | Public surface | External type-checking confirms both `UnsafeIndexV3` and the added `_LazyTiedPtr._NodePtr` are directly nameable after `import RedBlackTreeCollections`. Treat their visibility as prototype public-surface artifacts, not as evidence for or against the success-only representation. |
| `P7` | verified by inspection | Equality / hashing | Synthesized `_NodePtrSealing` equality/hash cover pointer, seal, and (when present) the pointer-derived tracking tag. `_LazyTieWrap` equality additionally checks tie identity while its coarser hash omits it, which is contract-valid. All are O(1). Keep a regression test. |
| `P8` | unverified | Limited movement | `adv_iter(_:offsetBy:limitedBy:)` still returns internal `Result`, while public optional/Bool adapters collapse only `.limit` and trap on other resolver failures. Verify end, stale, recycled, detached, and cross-tree behavior in both movement directions. Confirm that `form_index(limitedBy:)` retains develop's deliberately measured double `adv_iter` call. |
| `P9` | unverified | Performance | Confirm equality and hashing remain O(1), full and range traversal remain O(N), and success-only resolution does not add per-element search or allocation. Preserve raw measurements separately from the design decision. |
| `P10` | documentation | Design records | Several documents still describe the develop representation (`UnsafeIndexV3 = _LazyTieWrappedPtr`) or say the PoC must not be merged wholesale. Update them only after the validation verdict; for now record the branch and commit used as evidence. |
| `P11` | cleanup, non-blocking | Merge artifacts | Remove only after semantic validation: duplicated comments, commented-out old alias, trailing blank lines in `_LazyTie.swift`, duplicated `過去の状態で封印する` documentation, and the `Package.swift` comment-spacing change. These are not quality failures. |
| `P12` | design gate | Adoption boundary | This PoC proves only that a failureless public Index can compile and operate. It does not decide a nominal public Index type, `Comparable`, ContainersPreview adoption, or the final external contract. Keep those decisions separate. |
| `P13` | confirmed documentation regression | Public DocC | Dictionary and MultiMap place the complexity callout before the summary sentence, displacing the DocC abstract. Move it into the existing documentation body during cleanup. |
| `P14` | Codex pass; review queued | Dual representation | Success-only and old Result-returning overload families coexist and often differ only by return type. Initial call-site inventory found no public `Index`-typed path with an old Result context; independent review is queued. The new seal-only `_LazyTieWrap.isValid` has no Sources consumer and is not evidence of tree-aware validity. |

## Validation order

1. The independent initial-inventory review is complete; preserve its corrections as this document
   evolves.
2. Map one representative container (`RedBlackTreeSet`) and the most Index-sensitive View
   (`RedBlackTreeMappedValuesView`) to every applicable Quality Checklist property. Follow with
   `RedBlackTreeKeyValueRangeView`, whose range checks can otherwise hide resolver faults.
3. Run the narrow correctness and lifetime tests in Debug and Release, including
   `_O_UNCHECKED`; stop on any lifetime, stale-Index, sanitizer, or unexpected-crash signal.
4. Expand only confirmed properties to MultiSet, Dictionary, MultiMap, KeyOnly Range View, and
   KeyValue Range View.
5. Run compatibility and sanitizer configurations, then measure the Index hot paths.
6. Produce an `adopt after corrections`, `adoption blocked by specified evidence`, or `evidence
   incomplete` verdict without deciding `Comparable` or the nominal wrapper.

## Stop conditions

- Do not fix a Quality Checklist failure in the same step that discovers it.
- Do not treat a test-only synthetic `.nullptr` as evidence that a public failure-valued Index is
  required.
- Do not broaden from the first container and View until their correspondence and behavior are
  understood.
- Do not interpret a performance delta until raw commands, configuration, and measurements are
  recorded.
- Stop if either merge contains a conflict resolution whose design intent cannot be recovered.
- Stop if a public `Index`-typed path resolves to an old `_LazyTieWrappedPtr` overload.
- Stop if a Debug assertion fires where a specific `SealError` diagnostic was expected.

Each evidence-gathering batch reports neutral `pass`, `fail`, or `unmapped` results with commands,
configurations, counts, and diagnostic reasons. The adoption judgment is made only after the
applicable evidence has been gathered; individual batches do not return an adoption verdict.

## Evidence batches

### P1 — restore invalid-Bound coverage in Debug

Change:

- Restored the invalid Index-bound assertion in the Set, MultiSet, Dictionary, and MultiMap
  `*_98_InternalTests` using `.index(.nullptr)`.
- Every container is non-empty, avoiding the shared `_emptyLazyDetach` assertion hazard recorded
  in P5.

Results:

- Xcode build-for-testing: passed.
- The four restored `boundExpressionIndexValidity()` tests: 4 passed.
- Narrow representative batch (Set Index validity, value semantics, Death tests, MappedValues View,
  and Dictionary MappedValues Death tests): 67 passed, 0 failed, 1 reported as `No result` by Xcode.
- The `No result` entry was
  `erasingRangeFromAnotherSet_terminatesProcess()`. It is guarded by
  `#if !ALLOW_CROSS_TREE_INDEX`, while the active configuration defines `ALLOW_CROSS_TREE_INDEX`.
  `swift test list --disable-sandbox` confirms it is absent from the compiled SwiftPM test list.
  The result is stale Xcode discovery metadata, not an executed failure.
- A first SwiftPM filter attempt used the Xcode identifier form and matched zero tests. It is not
  counted as evidence. The test-list command above was used only to confirm the compile guard.

Batch result: `pass`, independently reviewed by Claude. Release and `_O_UNCHECKED` were
intentionally not started in this batch.

## Deferred Claude review queue

Until 09:00 JST, Codex continues bounded evidence gathering without creating one Claude assignment
per batch. Reviewable findings are accumulated here and will be submitted together afterward while
preserving a separate neutral verdict (`pass`, `fail`, or `unmapped`) for each evidence batch.

Current queue:

- P14 dual-representation call-site inventory.
- P6 external public-surface evidence and artifact classification.
- P2/P3 representative Release and `_O_UNCHECKED` evidence, including the four out-of-scope
  precondition-test failures described below.
- P3 Debug `COMPATIBLE_ATCODER_2025` evidence and its classification as a legacy-Index contract,
  not direct success-only Index evidence.
- P2/P3 representative Debug ASan evidence.
- P2 outliving-storage test and the distinction between receiver-based rejection and direct
  `.detached` error evidence.

P1 was reviewed before the batching window began.

### P14 — dual-representation call-site inventory

Codex's initial inventory separates the remaining old representation into:

- old overload declarations for header/tree `index`, `index_or_nil`, movement, and four-container
  / three-View `___index` helpers;
- old resolver declarations accepting `_LazyTieWrappedPtr`;
- the Result alias and `_LazyTieWrap.band(_:)` construction path;
- Debug-only retroactive `Result: Comparable` and prototype comments.

Every inspected public container movement/search/start/end/insertion/removal API has an explicit
return or parameter context of `Index`, whose current alias is `_LazyTiedPtr`. The same is true of
the BENCHMARK iterator's `next() -> UnsafeIndexV3?`. The build therefore resolves those calls to
the success-only overloads. No non-Deprecated production call site with an explicit
`_LazyTieWrappedPtr` result context was found outside the old overload/resolver layer itself.

Batch result: Codex `pass`; independent review queued. This does not authorize deleting the old
family—the remaining internal diagnostic and experimental consumers must be classified separately.

### P6 — external public-surface check

An external type-check against the current Xcode-built module succeeded for both:

```swift
import RedBlackTreeCollections
let _: UnsafeIndexV3.Type = UnsafeIndexV3.self
let _: _LazyTiedPtr._NodePtr.Type = _LazyTiedPtr._NodePtr.self
```

The same check against an older SwiftPM module artifact did not contain `_NodePtr`; that artifact is
not counted as current evidence. The current `.build/out/Products/Debug` module accepted both names.

Batch result: Codex `pass` for the visibility claim; artifact classification is queued for
independent review. No access level was changed.

### P2/P3 — representative Release configurations

Normal Release, using the representative Set/MatchedValues/Dictionary Death-test filter:

- XCTest: 19 passed (MappedValues View and Set value semantics).
- Swift Testing: 38 passed (Set and Dictionary Death tests).
- Batch result: Codex `pass`.

Release + `_O_UNCHECKED`, initially using the same broad filter:

- XCTest: 19 passed.
- Swift Testing: 34 passed and 4 failed.
- The four failures were Set/Dictionary `removeFirst` / `removeLast` on empty collections. They
  expected `SIGTRAP`, but `-Ounchecked` removes their precondition and the subprocess exited
  successfully.
- These four operations are not Index PoC paths, so this does not establish a success-only Index
  failure. It does establish that the normal-Release Death-test selection cannot be reused
  wholesale as an `_O_UNCHECKED` Index batch.
- No fix was made. The failed batch is retained as `fail (scope contamination)` and is queued for
  independent review. P2 remains unmapped under `_O_UNCHECKED` until a strictly Index-specific
  filter passes or fails.

The follow-up Release + `_O_UNCHECKED` batch filtered only Index movement/lifetime, MappedValues,
and value-semantics names:

- XCTest: 19 passed (MappedValues View and Set value semantics).
- Swift Testing: 22 passed across Set, MultiSet, Dictionary, and MultiMap Index/Death paths.
- Covered stale subscript, stale movement with diagnostic, already-removed Index, before-start,
  after-end, offset and limited offset failures, `formIndex`, and MappedValues erased/end Index
  access.
- Batch result: Codex `pass`; independent review queued.

This is partial P2/P3 evidence. Detached and Index-outliving-storage properties and ASan are still
`unmapped`; compatibility evidence is recorded separately below.

### P3 — Debug `COMPATIBLE_ATCODER_2025`

The compatibility symbol is a manual Swift compiler condition, not a package trait. The initial
`--traits COMPATIBLE_ATCODER_2025` attempt was rejected by SwiftPM and is not counted as evidence.
The established invocation is `-Xswiftc -DCOMPATIBLE_ATCODER_2025`.

Commands:

```text
swift test list --disable-sandbox -Xswiftc -DCOMPATIBLE_ATCODER_2025
swift test --disable-sandbox --skip-build -Xswiftc -DCOMPATIBLE_ATCODER_2025 \
  --filter 'AtCoder2025|CopyOnWriteTests|BidirectionalCollectionTests|IndexRangeTests|SubSequenceTests'
```

Results:

- The compatibility build and test discovery completed successfully.
- XCTest: 164 executed, 4 skipped, 0 failed.
- Swift Testing: the compatibility iterator mutation exit test passed (1 test, 1 suite).
- The selection covers the four containers through compatibility/legacy Index operations, shared
  CoW tests, collection movement/range tests, and subsequence invalidation tests.
- Existing compiler warnings include deprecated compatibility APIs, unreachable statements after
  intentional skips, and unused values. No compile error or test failure occurred.

This configuration deliberately selects `UnsafeIndexV2`/legacy APIs in place of the normal
success-only `Index`. It therefore passes as configuration and compatibility-contract evidence,
but is `unmapped` as direct evidence for the success-only representation's lifetime semantics.
Compatibility Release has not yet been run.

Batch result: Codex `pass` for P3 compatibility Debug; independent classification review queued.

### P2/P3 — representative Debug Address Sanitizer

Command:

```text
swift test --disable-sandbox --sanitize address \
  --filter 'RedBlackTree(SetIndexValidityXCTests|SetValueSemanticsTests|MappedValuesViewTests|DictionaryCopyOnWriteTests|SetCopyOnWriteTests|MultiSetCopyOnWriteTests|MultiMapCopyOnWriteTests)'
```

The ASan build completed and 64 selected XCTest cases passed with no failure or sanitizer report.
The batch covers Set stale/recycled and Range View validity, four-container CoW paths, Set value
semantics, and MappedValues single-Index mutation/swap/erase paths. It does not cover intentional
crash tests, detached Index, or Index outliving its storage.

Batch result: Codex `pass`; independent review queued.

### P2 — Index outliving its storage

No existing normal-mode test explicitly retained a success-only Index after its source collection
and storage were destroyed. Added
`testIndexOutlivingItsStorageIsDetachedAndRejectedByAnotherReceiver()` to the Set Index-validity
suite. An `@inline(never)` helper returns the Index from a local source, after which the test checks:

- the retained Index's lifetime tie is marked detached;
- an empty live receiver returns `false` from both `isElement(at:)` and `isEnd(_:)`;
- the same test passes with Address Sanitizer and emits no sanitizer report.

Normal Debug: 1 passed. Debug ASan: 1 passed.

This proves the storage-deinit marker and a safe public receiver-based rejection path. It does not
prove that a public operation reports the specific internal `.detached` reason: once the source is
gone, resolution necessarily occurs against a different receiver, and the cross-tree retrieval path
may classify the failure differently. Also, `_LazyTiedPtr.isValid` itself checks only its sealed
pointer and has no production Sources consumer; calling it after detachment is not treated as a
supported public lifetime check.

Batch result: Codex `pass` for the stated outliving-storage property; exact error classification is
`unmapped`; independent review queued.

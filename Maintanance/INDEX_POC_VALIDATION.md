# `try/index/1` validation

Status: Initial issue inventory after merging `develop/misc/48`

## Product-owner direction

The user strongly prefers adopting this success-only Index approach. Validation therefore treats
`try/index/1` as the leading implementation candidate, not as one equally weighted option in a
neutral design bake-off.

- Missing tests, documentation drift, prototype public-surface artifacts, and localized defects are
  correction work unless they reveal a deeper contradiction.
- Rejecting the approach requires concrete evidence that its lifetime safety, correctness,
  external contract, or required complexity cannot be made to satisfy the Quality Checklist
  without abandoning the success-only representation.
- `Comparable`, a nominal public wrapper, and ContainersPreview conformance remain later decisions;
  they are not reasons by themselves to reject this representation.

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
| `P1` | confirmed gap | Test as Specification | Four internal tests commented out the failure-valued Index case because such a public Index can no longer be constructed. Restore the property with Debug `.index(.nullptr)` on non-empty containers; do not recreate a public failure-valued Index merely for coverage. |
| `P2` | unverified | Index lifetime | Prove stale, recycled, detached, cross-tree CoW, and Index-outliving-tree behavior for the success-only Index before dereference, including `_O_UNCHECKED`. Existing develop tests are relevant but have not yet been mapped per Quality Checklist item on this merged branch. |
| `P3` | unverified | Configuration matrix | The merged PoC has not yet passed the required Debug/Release, normal/`COMPATIBLE_ATCODER_2025`, ASan, and `_O_UNCHECKED` matrix. The earlier repair pass ran Debug tests and a Release build only. |
| `P4` | unverified | Container/View breadth | Validate `RedBlackTreeSet` and `RedBlackTreeMappedValuesView` first, then KeyValue Range View, the remaining containers, and KeyOnly Range View. MappedValues is the sensitive first View because its single-Index read/modify/swap paths depend directly on O(1) `__purified_` resolution and CoW migration. |
| `P5` | confirmed test hazard | Debug fixture semantics | `_LazyTieWrap.unsafe(tree:rawTag:)` maps every retrieval, seal, or banding failure to synthetic `.nullptr`. On an empty tree, `_emptyLazyDetach` is shared, so same-tie purification can assert on the null pointer instead of producing the intended `SealError`. Synthetic-null tests must use a non-empty tree and verify the error reason, not merely expect process failure. |
| `P6` | review required | Public surface | The PoC removes `@_documentation(visibility: internal)` from `UnsafeIndexV3` and adds a public nested `_NodePtr` alias. Confirm these are prototype artifacts rather than intended public surface. |
| `P7` | verified by inspection | Equality / hashing | Synthesized `_NodePtrSealing` equality/hash cover pointer, seal, and (when present) the pointer-derived tracking tag. `_LazyTieWrap` equality additionally checks tie identity while its coarser hash omits it, which is contract-valid. All are O(1). Keep a regression test. |
| `P8` | unverified | Limited movement | `adv_iter(_:offsetBy:limitedBy:)` still returns internal `Result`, while public optional/Bool adapters collapse only `.limit` and trap on other resolver failures. Verify end, stale, recycled, detached, and cross-tree behavior in both movement directions. Confirm that `form_index(limitedBy:)` retains develop's deliberately measured double `adv_iter` call. |
| `P9` | unverified | Performance | Confirm equality and hashing remain O(1), full and range traversal remain O(N), and success-only resolution does not add per-element search or allocation. Preserve raw measurements separately from the design decision. |
| `P10` | documentation | Design records | Several documents still describe the develop representation (`UnsafeIndexV3 = _LazyTieWrappedPtr`) or say the PoC must not be merged wholesale. Update them only after the validation verdict; for now record the branch and commit used as evidence. |
| `P11` | cleanup, non-blocking | Merge artifacts | Remove only after semantic validation: duplicated comments, commented-out old alias, trailing blank lines in `_LazyTie.swift`, duplicated `過去の状態で封印する` documentation, and the `Package.swift` comment-spacing change. These are not quality failures. |
| `P12` | design gate | Adoption boundary | This PoC proves only that a failureless public Index can compile and operate. It does not decide a nominal public Index type, `Comparable`, ContainersPreview adoption, or the final external contract. Keep those decisions separate. |
| `P13` | confirmed documentation regression | Public DocC | Dictionary and MultiMap place the complexity callout before the summary sentence, displacing the DocC abstract. Move it into the existing documentation body during cleanup. |
| `P14` | review gate | Dual representation | Success-only and old Result-returning overload families coexist and often differ only by return type. Inventory the remaining non-Deprecated `_LazyTieWrappedPtr` call sites and stop if any public `Index`-typed path resolves to the old representation. The new seal-only `_LazyTieWrap.isValid` currently has no Sources consumer and is not evidence of tree-aware validity. |

## Validation order

1. Independently review this issue inventory and correct missing or overstated items.
2. Map one representative container (`RedBlackTreeSet`) and the most Index-sensitive View
   (`RedBlackTreeMappedValuesView`) to every applicable Quality Checklist property. Follow with
   `RedBlackTreeKeyValueRangeView`, whose range checks can otherwise hide resolver faults.
3. Run the narrow correctness and lifetime tests in Debug and Release, including
   `_O_UNCHECKED`; stop on any lifetime, stale-Index, sanitizer, or unexpected-crash signal.
4. Expand only confirmed properties to MultiSet, Dictionary, MultiMap, KeyOnly Range View, and
   MappedValues View.
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

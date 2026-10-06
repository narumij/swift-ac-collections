# Index PoC cross-branch identity map

Status: Archived after PR #158 integrated the validated Index PoC (2026-10-06)

The cross-branch preparation and adoption decision are complete. The resulting validation record is
preserved in `INDEX_POC_VALIDATION.md`. Reopen this identity map only when a concrete historical
merge or identity ambiguity cannot be resolved from the active branch and that validation record.

## Purpose

This document is the entry gate for X1: reconstructing the user-authored `try/index/1` PoC and
validating it, on top of the current development branch, against the Quality Checklist.

The two branches may contain identically named files, types, aliases, functions, and tests that
belong to different designs or eras. A shared name is not evidence of shared identity or semantics.
Every side remains a separate object until the user confirms the intended correspondence.

This document does not decide whether the PoC should be adopted, whether an item is obsolete, or
whether `Index` should conform to `Comparable`.

## Freeze decision (2026-10-05)

The user stopped proactive full-surface inventory because its work and relay cost were too high
relative to immediate implementation value. Preserve this document and the reviewed identities as
diagnostic infrastructure, but do not continue enumerating symbols or requesting Claude reviews.

Resume X1 only when concrete implementation work encounters an ambiguous same-named component,
unwritten merge resolution, failing Quality Checklist item, or another blocker that cannot be
resolved safely from the active branch alone. On resumption, add the minimum rows needed for that
specific blocker; do not restart exhaustive inventory automatically.

## Fixed anchors

| Anchor | Commit | Date | Role |
| --- | --- | --- | --- |
| Current development | `aecbcddf240cc039db9eac92b46721a1fde0532a` | 2026-10-05 | Current `develop/misc/48` state when this map was created |
| Current `try/index/1` tip | `1b126ba370ba78aa90b1241ac83d888ed3861bf4` | 2026-10-04 | PoC branch after the development-branch sync merge |
| Current merge base | `b3570172cb25f70f5937410c34c87da3882b2325` | 2026-10-04 | Second parent of the sync merge; comparison anchor, not the start of the PoC |
| Earliest branch-unique first-parent commit | `21bdd758319c1f86212c20f07de67b6f172304a7` | 2026-09-24 | Earliest commit in `try/index/1 --not develop/misc/48` |
| Earlier `main` sync merge | `8d5f9928a63475145a8b0bdeeb7a8d84bb49b10d` | 2026-09-24 | Sync merge before the center commit |
| PoC center commit | `005a7bb391f0d998b1d21929712866b2bed225f7` | 2026-09-24 | `non Result type index` |
| Last PoC commit before the 2026-10-04 sync merge | `a250c677ab4eea6e511a0f133c0ac8991f6ab9e3` | 2026-09-27 | Last first-parent PoC change before that sync merge |
| Parent of the center commit | `49de7dd95bfa783a850a7a7b5e2ca74593d9367d` | 2026-09-24 | Local before-state for the center commit; itself a sync merge of `develop/misc/35` |

The anchors identify snapshots; they do not imply that same-path content has the same meaning.
The current branch has advanced beyond the merge base, so `merge-base...branch` output must not be
treated as a complete semantic comparison by itself.

## Identity rule

The minimum identity is:

```text
branch + commit + path + symbol + configuration
```

Configuration is the define / trait set declared by that commit's `Package.swift`; a configuration
name is not assumed to mean the same thing on both branches. Dimensions include, when applicable:

- Debug / Release
- normal / `COMPATIBLE_ATCODER_2025`
- `ALLOW_CROSS_TREE_INDEX`
- `USE_LAZY_DETACH`
- `_O_UNCHECKED`
- `BENCHMARK`
- `USE_INT128`
- `ENABLE_LEGACY_TREE_LOWER_UPPER_BOUND`
- `DEATH_TEST` / `ENABLE_DEATH_TESTS` on the test side

Do not shorten an identity to a type or member name in evidence tables.

## Semantic status vocabulary

| Status | Meaning | Who may close it |
| --- | --- | --- |
| `unknown` | No semantic correspondence has been established | User after reviewing evidence and intent |
| `same` | Same intended role and externally relevant meaning | User |
| `changed` | Intentional successor with a changed role or contract | User |
| `independent` | Same or similar name, but not the same design component | User |
| `one-sided` | No counterpart is claimed on the other snapshot | User confirms whether this is intentional |

Codex and Claude may propose evidence but must not promote a row out of `unknown`.

## Symbol identity table

Add one row per symbol and per materially different configuration. Never combine multiple Views or
containers into one row until the first representative container and View have been confirmed.

| ID | Side | Commit | Path | Symbol | Configuration | Role / era (user-supplied; otherwise unknown) | Semantic status | Evidence | User intent |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `CUR-IDX-001` | current | `aecbcddf` | `Sources/RedBlackTreeCollections/Implements/Index/UnsafeIndexV3.swift` | `public typealias UnsafeIndexV3` | Unconditional declaration in the inspected file | `unknown` | `unknown` | Lines 26–27: alias target is `_LazyTieWrappedPtr`; declaration has `@_documentation(visibility: internal)` | Pending |
| `CUR-IDX-002` | current | `aecbcddf` | `Sources/RedBlackTreeCollections/Implements/Index/UnsafeIndexV3.swift` | `public typealias RedBlackTreeIndex` | Unconditional declaration in the inspected file | `unknown` | `unknown` | Line 30: alias target is `UnsafeIndexV3` | Pending |
| `POC-IDX-001` | PoC | `1b126ba3` | `Sources/RedBlackTreeCollections/Implements/Index/UnsafeIndexV3.swift` | `public typealias UnsafeIndexV3` | Unconditional declaration in the inspected file | `unknown` | `unknown` | Line 30: alias target is `_LazyTiedPtr`; the declaration has no attributes; line 26 is a commented-out `public typealias UnsafeIndexV3 = _LazyTieWrappedPtr` | Pending |
| `POC-IDX-002` | PoC | `1b126ba3` | `Sources/RedBlackTreeCollections/Implements/Index/UnsafeIndexV3.swift` | `public typealias RedBlackTreeIndex` | Unconditional declaration in the inspected file | `unknown` | `unknown` | Line 33: alias target is `UnsafeIndexV3` | Pending |
| `CUR-ALIAS-001` | current | `aecbcddf` | `Sources/RedBlackTreeCollections/Implements/RawBuffer/_LazyTieWrap+Result.swift` | `public typealias _LazyTieWrappedPtr` | Unconditional declaration in the inspected file | `unknown` | `unknown` | Line 33: alias target is `Result<_LazyTieWrap<_NodePtrSealing>, SealError>`; no attributes | Pending |
| `CUR-ALIAS-002` | current | `aecbcddf` | `Sources/RedBlackTreeCollections/Implements/RawBuffer/_LazyTieWrap.swift` | `public typealias _LazyTiedPtr` | Unconditional declaration in the inspected file | `unknown` | `unknown` | Line 41: alias target is `_LazyTieWrap<_NodePtrSealing>`; no attributes | Pending |
| `POC-ALIAS-001` | PoC | `1b126ba3` | `Sources/RedBlackTreeCollections/Implements/RawBuffer/_LazyTieWrap+Result.swift` | `public typealias _LazyTieWrappedPtr` | Unconditional declaration in the inspected file | `unknown` | `unknown` | Line 33: alias target is `Result<_LazyTieWrap<_NodePtrSealing>, SealError>`; no attributes | Pending |
| `POC-ALIAS-002` | PoC | `1b126ba3` | `Sources/RedBlackTreeCollections/Implements/RawBuffer/_LazyTieWrap.swift` | `public typealias _LazyTiedPtr` | Unconditional declaration in the inspected file | `unknown` | `unknown` | Line 41: alias target is `_LazyTieWrap<_NodePtrSealing>`; no attributes | Pending |
| `POC-NODEPTR-001` | PoC | `1b126ba3` | `Sources/RedBlackTreeCollections/Implements/RawBuffer/_LazyTieWrap.swift` | `_LazyTieWrap<_NodePtrSealing>._NodePtr` (`public typealias`) | Unconditional extension declaration in the inspected file | `unknown` | `unknown` | Lines 105–107: declared in `extension _LazyTieWrap where RawValue == _NodePtrSealing`; alias target is `UnsafeMutablePointer<UnsafeNode>`; no attributes. The current anchor has no `_NodePtr` declaration in this same path | Pending |
| `CUR-WRAP-001` | current | `aecbcddf` | `Sources/RedBlackTreeCollections/Implements/RawBuffer/_LazyTieWrap.swift` | `public struct _LazyTieWrap<RawValue>` | Unconditional declaration in the inspected file | `unknown` | `unknown` | Lines 24–38: `@frozen public struct`; stored properties are `@usableFromInline package let rawValue: RawValue` and `@usableFromInline package let lazyDetach: _LazyTie`; initializer is `@inlinable package init(rawValue:lazyDetach:)` | Pending |
| `POC-WRAP-001` | PoC | `1b126ba3` | `Sources/RedBlackTreeCollections/Implements/RawBuffer/_LazyTieWrap.swift` | `public struct _LazyTieWrap<RawValue>` | Unconditional declaration in the inspected file | `unknown` | `unknown` | Lines 24–38: `@frozen public struct`; stored properties are `@usableFromInline package let rawValue: RawValue` and `@usableFromInline package let lazyDetach: _LazyTie`; initializer is `@inlinable package init(rawValue:lazyDetach:)` | Pending |

Mechanical name count only: `git grep` finds 15 `_NodePtr` typealias declarations at the current
anchor and 16 at the PoC anchor, plus one `associatedtype _NodePtr` on each side. The only path-level
difference in that declaration list is `POC-NODEPTR-001`. These counts do not establish a
counterpart, move, duplicate, or semantic relationship.

## Correspondence proposal table

This table is populated only after both sides have separate symbol rows. A proposal is not a
decision.

| Current identity ID | PoC identity ID | Proposed relation | Codex rationale | Claude counterevidence | User decision |
| --- | --- | --- | --- | --- | --- |
| — | — | `unknown` | Not started | Not started | Pending |

## Mechanical PoC-side path scope

The following paths differ between merge base `b3570172` and the current `try/index/1` tip. This is
only a path inventory; it does not establish which differences originated in the PoC, survived the
sync merge intentionally, or correspond semantically to current HEAD.

All 24 entries are `M`; there are no added, deleted, or renamed paths.

### Configuration and core Index layers

- `Package.swift`
- `Sources/RedBlackTreeCollections/Implements/BoundsExpression/RedBlackTreeBoundExpression.swift`
- `Sources/RedBlackTreeCollections/Implements/Index/UnsafeIndexV3.swift`
- `Sources/RedBlackTreeCollections/Implements/RawBuffer/_LazyTie.swift`
- `Sources/RedBlackTreeCollections/Implements/RawBuffer/_LazyTieWrap+Result.swift`
- `Sources/RedBlackTreeCollections/Implements/RawBuffer/_LazyTieWrap.swift`
- `Sources/RedBlackTreeCollections/Implements/UnsafeTreeV2/Buffer/UnsafeTreeV2+BufferHeader.swift`
- `Sources/RedBlackTreeCollections/Implements/UnsafeTreeV2/UnsafeTreeV2+Index.swift`
- `Sources/RedBlackTreeCollections/Implements/UnsafeTreeV2/UnsafeTreeV2.swift`
- `Sources/RedBlackTreeCollections/Implements/__tree/unsafe_node/Seal/_NodePtrSealing.swift`

### Containers and Views

- `Sources/RedBlackTreeCollections/RedBlackTreeSet/RedBlackTreeSet+Index.swift`
- `Sources/RedBlackTreeCollections/RedBlackTreeMultiSet/RedBlackTreeMultiSet+Index.swift`
- `Sources/RedBlackTreeCollections/RedBlackTreeDictionary/RedBlackTreeDictionary+Index.swift`
- `Sources/RedBlackTreeCollections/RedBlackTreeMultiMap/RedBlackTreeMultiMap+Index.swift`
- `Sources/RedBlackTreeCollections/RedBlackTreeView/RedBlackTreeRangeView+KeyOnly.swift`
- `Sources/RedBlackTreeCollections/RedBlackTreeView/RedBlackTreeRangeView+KeyValue.swift`
- `Sources/RedBlackTreeCollections/RedBlackTreeView/RedBlackTreeMappedValuesView.swift`

### Tests and task record

- `Tests/RedBlackTreeTests/DebugAdditionals/UnsafeTreeV2+Debug/_LazyTieWrap+Debug.swift`
- `Tests/RedBlackTreeTests/RedBlackTreeInternal/Instance/RedBlackTreeInternal_PurifiedTests.swift`
- `Tests/RedBlackTreeTests/RedBlackTreeSet/RedBlackTreeSet_98_InternalTests.swift`
- `Tests/RedBlackTreeTests/RedBlackTreeMultiSet/RedBlackTreeMultiSet_98_InternalTests.swift`
- `Tests/RedBlackTreeTests/RedBlackTreeDictionary/RedBlackTreeDictionary_98_InternalTests.swift`
- `Tests/RedBlackTreeTests/RedBlackTreeMultiMap/RedBlackTreeMultiMap_98_InternalTests.swift`
- `Maintanance/CLAUDE_TASK.md`

### Paths changed on both sides since `b3570172`

- `Maintanance/CLAUDE_TASK.md`
- `Sources/RedBlackTreeCollections/Implements/BoundsExpression/RedBlackTreeBoundExpression.swift`
- `Sources/RedBlackTreeCollections/RedBlackTreeView/RedBlackTreeMappedValuesView.swift`
- `Sources/RedBlackTreeCollections/RedBlackTreeView/RedBlackTreeRangeView+KeyOnly.swift`
- `Sources/RedBlackTreeCollections/RedBlackTreeView/RedBlackTreeRangeView+KeyValue.swift`

Same-path content has diverged on both sides after the sync; treat every symbol in these files as a
separate identity on each side.

## Required user-intent checkpoints

Evidence must be prepared before asking. The user is not expected to reconstruct implementation
facts from memory, but only the design intent that source and history cannot establish.

- What role was intended for the success-only Index representation?
- Which diagnostics were intentionally kept internal rather than represented by a public failure
  value?
- Was the Debug `.nullptr` representation deliberate, temporary scaffolding, or unresolved?
- Why did `limitedBy` convert resolution failure into optional / Boolean results?
- Which `==` and hashing behavior was intended at the time of the PoC?
- What was known about the sanitizer TODO?
- For each conflict resolution in the 2026-10-04 sync merge (listed mechanically beforehand from
  the merge and its two parents), did the resolution express design intent, or only restore
  compilation?

Answers remain user-authored intent. Codex records them without broadening them by inference.

## Mandatory stops

Stop and report without fixing or extending when:

- a same-named item cannot be shown to correspond;
- an item appears obsolete;
- a 2026-10-04 conflict resolution has no recorded intent;
- a sanitizer, lifetime, stale-Index, or unexpected crash signal appears;
- a Quality Checklist item fails;
- the first representative container and View have not been confirmed before horizontal expansion;
- a performance difference is found (retain raw data; interpretation is separate).

## Planned review sequence

1. Codex populates separate current and PoC symbol identities without semantic pairing.
2. Claude independently extracts history, symbols, guards, and test references.
3. Codex drafts correspondence proposals with evidence.
4. Claude performs an adversarial review without deciding correspondence.
5. The user resolves `unknown` semantic identities and supplies missing intent.
6. One representative container and one View are validated against the Quality Checklist.
7. Only after the checkpoint may the process expand to the remaining containers and Views.

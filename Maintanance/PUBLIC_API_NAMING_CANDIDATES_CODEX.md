# Public API naming candidates — Codex

Status: submitted candidates. This document does not rank or adopt a public API name.

この文書は、0.6および1.0で公開品質としてValidation可能なAPIを三者で議論するための
Codex独立候補を記録する。候補の並び順に順位の意味はない。

目的と品質上の位置づけは、製品コンセプトの正本
[`User/CONCEPT_DEFINITION.md`](User/CONCEPT_DEFINITION.md)と、製品品質要求の正本
[`User/QUALITY_REQUIREMENTS.md`](User/QUALITY_REQUIREMENTS.md)に従う。この候補記録は両正本を
再定義しない。

## Array object names

### `ContiguousElements` / `MemoTable`

- Owning types: unsuffixed 1D, followed by `2D` through `4D`.
- Views: `ContiguousElements1DView` through `3DView` and `MemoTable1DView` through `3DView`.
- Intent: one family names contiguous ownership; the other names the principal memoization use.
- Concern: the first name is long; the second can imply a narrower use or an unstated cache policy.

### `FlatStorage` / `PresenceTable`

- Owning types: unsuffixed 1D, followed by `2D` through `4D`.
- Views: `FlatStorage1DView` through `3DView` and `PresenceTable1DView` through `3DView`.
- Intent: distinguish flattened contiguous storage from independently present or absent slots.
- Concern: `Storage` sounds implementation-facing; `PresenceTable` is precise but unfamiliar.

### `DenseBuffer` / `OptionalBuffer`

- Owning types: unsuffixed 1D, followed by `2D` through `4D`.
- Views: `DenseBuffer1DView` through `3DView` and `OptionalBuffer1DView` through `3DView`.
- Intent: give both families one category while distinguishing always-present and optional positions.
- Concern: `Dense` suggests a sparse counterpart, and `OptionalBuffer` can mean an optional buffer object.

## Array access API

The following are coherent families, not independently interchangeable words.

### `read` / `write` / `mutable`

| Role | Candidate |
| --- | --- |
| Read | `read(at: ...)` |
| Write | `write(_:at: ...)` |
| Mutable reference | `mutable(at: ...)` |
| Mutable reference type | `MutableElement` |

Intent: make the operational distinction at call sites short and explicit.

Concern: `read` and `write` can imply I/O or synchronization. `mutable(at:)` does not itself say that
the returned value is a reference-like projection.

### `value` / `setValue` / `mutableValue`

| Role | Candidate |
| --- | --- |
| Read | `value(at: ...)` |
| Write | `setValue(_:at: ...)` |
| Mutable reference | `mutableValue(at: ...)` |
| Mutable reference type | `MutableValue` |

Intent: describe the semantic value at a coordinate without claiming Collection conformance.

Concern: `value` may understate ownership and element identity, and `MutableValue` may sound like a
copied mutable value rather than a scoped reference.

### `load` / `store` / `elementReference`

| Role | Candidate |
| --- | --- |
| Read | `load(at: ...)` |
| Write | `store(_:at: ...)` |
| Mutable reference | `elementReference(at: ...)` |
| Mutable reference type | `ElementReference` |

Intent: distinguish copied access from explicit reference access and keep the reference role visible.

Concern: `load` and `store` expose a low-level memory vocabulary and may imply atomic or volatile
semantics that the implementation does not provide.

## Other Array public names

Codex has not yet submitted alternatives for initializer labels, `removeAll()`, `indices`, subscript,
coordinate labels, or View operations. Their current spellings are not silently adopted by omission.

## Permutation API

The normal runtime-checked route and the Swift 6.4 borrowed `Span` route are kept visibly paired.

### `lexicographicPermutations` family

| Role | Candidate |
| --- | --- |
| Normal factory | `lexicographicPermutations()` |
| Normal owner/iterator | `LexicographicPermutations` |
| Normal yielded view | `LexicographicPermutation` |
| Borrowed factory | `borrowedLexicographicPermutations()` |
| Borrowed owner/iterator | `BorrowedLexicographicPermutations` |

Intent: state that enumeration begins at the current order and follows lexicographic successors.

Concern: the names are long, and “permutations” can still be read as complete enumeration from the
lexicographically first order.

### `successivePermutations` family

| Role | Candidate |
| --- | --- |
| Normal factory | `successivePermutations()` |
| Normal owner/iterator | `SuccessivePermutations` |
| Normal yielded view | `PermutationView` |
| Borrowed factory | `borrowedSuccessivePermutations()` |
| Borrowed owner/iterator | `BorrowedSuccessivePermutations` |

Intent: emphasize that only the starting order and its successors are produced.

Concern: “successive” does not identify the ordering relation without documentation.

### Current `nextPermutations` family retained as a candidate

| Role | Candidate |
| --- | --- |
| Normal factory | `nextPermutations()` |
| Normal owner/iterator | `NextPermutations` |
| Normal yielded view | `Permutation` |
| Borrowed factory | `borrowedNextPermutations()` |
| Borrowed owner/iterator | `BorrowedNextPermutations` |

Intent: remain close to C++ `next_permutation` and the existing repository vocabulary.

Concern: plural `nextPermutations` can imply a full permutation sequence, and `Borrowed` describes
the yielded lifetime model more directly than the owning iterator itself.

## Unsubmitted public-name areas

Codex has not submitted alternatives for `next()`, `Span`, collection constraints, or standard
collection requirements such as `startIndex`, `endIndex`, and subscript. Omission is not adoption.

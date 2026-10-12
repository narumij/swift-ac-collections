# Public API naming candidates — Codex reconsideration

Status: submitted replacement candidates. This document does not rank or adopt a public API name.

Codex reconsidered its submission on 2026-10-13 at the user's request. Unlike the first submission,
this is not independent of the User and Claude records: Codex had already read them. The replacement
therefore records Codex's own present judgment without claiming an independence that no longer exists.
The earlier Codex submission is withdrawn and must not be added to the ballot as a separate vote.

The proposal follows `User/CONCEPT_DEFINITION.md`, `User/QUALITY_REQUIREMENTS.md`, the current public
declarations, and `ArrayObjectAndAPINamingDraft.md`. It does not decide product inclusion, migration,
deprecation, lifetime policy, or the final public contract.

## A. Array object families

### A-1 `ElementBuffer` / `OptionalElementBuffer`

| Role | Always-initialized family | Presence-tracked family |
| --- | --- | --- |
| 1D owner | `ElementBuffer` | `OptionalElementBuffer` |
| 2D–4D owner | `ElementBuffer2D` … `4D` | `OptionalElementBuffer2D` … `4D` |
| 1D–3D view | `ElementBuffer1DView` … `3DView` | `OptionalElementBuffer1DView` … `3DView` |

Intent: name the owned, fixed-count element storage without claiming ordinary Swift `Array` value
semantics or a cache policy. `Optional` modifies the stored element positions, not the buffer object.

Concern: `Buffer` is low-level vocabulary and does not itself communicate noncopyability, runtime
shape, or the View lifetime boundary. `OptionalElementBuffer` is long.

### A-2 `FixedShapeElements` / `OptionalFixedShapeElements`

| Role | Always-initialized family | Presence-tracked family |
| --- | --- | --- |
| 1D owner | `FixedShapeElements` | `OptionalFixedShapeElements` |
| 2D–4D owner | `FixedShapeElements2D` … `4D` | `OptionalFixedShapeElements2D` … `4D` |
| 1D–3D view | `FixedShapeElements1DView` … `3DView` | `OptionalFixedShapeElements1DView` … `3DView` |

Intent: state the principal semantic distinction from resizable collections: the shape is selected at
initialization and remains fixed, while the contained values may change.

Concern: the names are long, especially with dimension and View suffixes. `FixedShape` can sound
multidimensional when used by the 1D type, and it still does not express noncopyability.

### A-3 retain `BareArray` / normalize to `OptionalArray`

| Role | Always-initialized family | Presence-tracked family |
| --- | --- | --- |
| 1D owner | `BareArray` | `OptionalArray` |
| 2D–4D owner | `BareArray2D` … `4D` | `OptionalArray2D` … `4D` |
| 1D–3D view | `BareArray1DView` … `3DView` | `OptionalArray1DView` … `3DView` |

Intent: preserve the established repository vocabulary and migration path while removing the current
1D suffix asymmetry.

Concern: both names invite comparison with Swift `Array`; `OptionalArray` is easily read as
`Array<Optional<Element>>`, while these owners are noncopyable, fixed-shape types with different
surface semantics. `Bare` requires documentation to explain what is absent.

### Object-family boundary

- Codex does not resubmit `MemoTable`, `OptionalCache`, or another cache-oriented name. The type stores
  presence-tracked elements but does not calculate, memoize, evict, or otherwise implement cache policy.
- Codex does not use `Contiguous` in the preferred new candidates. Contiguity is important, but putting
  it in the public type name turns a representation and performance property into the dominant identity.
- 1D owners are unsuffixed in all three candidates. Dimension suffixes identify only the additional
  coordinate structure. Views keep `1DView` because the yielded lower-dimensional rank must remain visible.
- No object name by itself can communicate the nonescaping or runtime-checked lifetime of a View; that
  contract must remain explicit in the View type and documentation.

## B. Array access API families

### B-1 retain element vocabulary and make mutable reference explicit

| Role | Candidate |
| --- | --- |
| Read | `element(at: ...)` |
| Write | `setElement(_:at: ...)` |
| Mutable reference | `mutableElement(at: ...)` |
| Mutable reference type | `MutableElementReference` |

Intent: keep read and write call sites familiar while making it clear that the third operation returns
a mutable reference-like projection rather than a copied value.

Concern: the longer reference names add ceremony in competitive code. Renaming only `reference(at:)`
creates a small family migration without resolving coordinate-order questions.

### B-2 retain the complete current family

| Role | Candidate |
| --- | --- |
| Read | `element(at: ...)` |
| Write | `setElement(_:at: ...)` |
| Mutable reference | `reference(at: ...)` |
| Mutable reference type | `Reference` |

Intent: preserve source compatibility and the user's established vocabulary.

Concern: `Reference` and `reference(at:)` do not say mutable, scoped, borrowed, or element-specific.
Their meaning depends heavily on documentation and the surrounding owner type.

### Optional-family state operations

Codex separately submits `removeElement(at: ...)` and `removeAllElements()` as naming candidates for
making presence-state transitions explicit. They are not silently added to B-1 or B-2: adding an
operation or retaining `setElement(nil, at:)` is a contract decision, not merely a spelling choice.

The current `removeAll()` remains a candidate for compatibility, but it is easy to read as changing
the count to zero. A name containing `Elements` better signals that the fixed shape remains intact.

### Coordinate and subscript boundary

Codex does not propose new coordinate labels until the canonical coordinate order is decided. The
current `element(at: x, y)` order and chained `[y][x]` order expose opposite directions. Renaming labels
before resolving that contract would hide a semantic decision inside a naming ballot.

## C. Permutation API families

### C-1 retain the `nextPermutations` entry points and rename the yielded runtime view

| Role | Candidate |
| --- | --- |
| Normal factory | `nextPermutations()` |
| Normal owner / iterator | `NextPermutations<Element>` |
| Normal yielded view | `CurrentPermutationView` |
| Borrowed factory | `borrowedNextPermutations()` |
| Borrowed owner / iterator | `BorrowedNextPermutations<Element>` |

Intent: retain the searchable connection to C++ `next_permutation` and existing competitive-programming
vocabulary while making the normal yielded object visibly a view of the iterator's current state.

Concern: `nextPermutations()` can still be read as producing all permutations rather than the current
ordering followed by lexicographic successors. `CurrentPermutationView` is deliberately explicit but long.

### C-2 make the starting boundary explicit

| Role | Candidate |
| --- | --- |
| Normal factory | `permutationsFromCurrentOrder()` |
| Normal owner / iterator | `PermutationsFromCurrentOrder<Element>` |
| Normal yielded view | `CurrentPermutationView` |
| Borrowed factory | `borrowedPermutationsFromCurrentOrder()` |
| Borrowed owner / iterator | `BorrowedPermutationsFromCurrentOrder<Element>` |

Intent: state directly that enumeration does not first sort the input and therefore may produce only a
suffix of lexicographic order.

Concern: the family is too verbose for a competitive-programming API and loses the familiar
`next_permutation` search term. “Order” also needs documentation to mean lexicographic order.

### C-3 distinguish the runtime-checked route instead of the compiler-borrowed route

| Role | Candidate |
| --- | --- |
| Runtime-checked factory | `checkedNextPermutations()` |
| Runtime-checked owner / iterator | `CheckedNextPermutations<Element>` |
| Runtime-checked yielded view | `CurrentPermutationView` |
| Swift 6.4 borrowed factory | `nextPermutations()` |
| Swift 6.4 borrowed owner / iterator | `NextPermutations<Element>` |

Intent: if Swift 6.4+ is the product baseline and the borrowed route is the normal safe route, give the
primary spelling to the compiler-checked lifetime model and name the compatibility mechanism explicitly.

Concern: this changes the meaning of an established spelling and cannot be adopted from naming quality
alone. It requires a product decision about the default route, migration, and source compatibility.

## D. Other public names

- Retain `next()` for both permutation iterators. It describes manual state advancement without falsely
  claiming `Sequence`; documentation must state that `for`-`in` is unavailable.
- Normalize the generic parameter spelling to `Element` for both permutation owners. This is source-level
  declaration clarity, not a distinct user-visible candidate family.
- Retain standard `Collection` requirement names on the yielded runtime view. Renaming `startIndex`,
  `endIndex`, or subscript would mean dropping the conformance rather than improving its vocabulary.
- `OptionalArray.init(capacity:)` should have `init(count:)` as a ballot candidate. Every slot exists at
  initialization and the object does not expose later growth; `capacity` suggests reserved-but-unused room.
- No alternative for `width`, `height`, `depth`, or `size0`…`size3` is submitted until coordinate order
  and dimension semantics are treated as their own contract decision.

## E. Unresolved decisions exposed by the candidates

| Scope | Why naming cannot decide it |
| --- | --- |
| Normal versus borrowed Permutation default | Determines whether C-1 or C-3 can preserve truthful primary names. |
| Canonical multidimensional coordinate order | Must precede coordinate labels and any multi-index subscript family. |
| Optional presence-removal operations | Adding `removeElement` is an API-contract choice, not a synonym-only rename. |
| BareArray product exclusion | Determines whether renaming it creates useful maintained vocabulary or unnecessary migration work. |

These decisions are inputs to later decision tasks. They are not resolved by this candidate submission.

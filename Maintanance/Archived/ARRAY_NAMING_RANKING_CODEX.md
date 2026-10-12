# Array object naming — Codex ranking draft

Status: superseded historical draft. This ranking did not adopt a public name.

The user, Codex, and Claude candidate sets were combined after independent submission. Base names
were ranked separately because the objects have different roles; submitted pairs did not bind the
final pair. Criteria were role accuracy, call-site readability, family coherence, compatibility
cost, and avoidance of unsupported semantic promises.

This draft was later superseded by the `PUBLIC_API_NAMING_BALLOT.md` and independent-scoring workflow.
It must not be used as an accepted ballot, score record, recommendation, or decision.

## Always-initialized contiguous family

| Rank | Base name | Assessment |
| ---: | --- | --- |
| 1 | `BareElements` | Avoids claiming `Collection` semantics and reads as minimally wrapped owned elements. `Bare` still needs explanation. |
| 2 | `ContiguousElements` | Explicit about the core representation and access property, but long and makes contiguity a permanent promise. |
| 3 | `DenseBuffer` | Compact and distinguishes always-present elements from optional slots, but implies a sparse/dense contrast. |
| 4 | `BareArray` | Familiar and migration-free, but suggests ordinary Swift collection and value semantics. |
| 5 | `FlatStorage` | Describes multidimensional flattening, but sounds internal rather than user-facing. |
| 6 | `FixedArray` | Communicates non-resizability, but risks confusion with fixed-size or inline arrays. |
| 7 | `HeapArray` | Describes allocation location without distinguishing it usefully from Swift `Array`. |

## Presence-tracked memoization family

| Rank | Base name | Assessment |
| ---: | --- | --- |
| 1 | `OptionalCache` | Expresses memoization use and unset positions. It may imply automatic computation or eviction, which documentation would need to reject. |
| 2 | `MemoTable` | Reads naturally in dynamic-programming call sites and avoids resemblance to `[Element?]`, but narrows apparent use and may imply policy. |
| 3 | `SlotArray` | Emphasizes independently empty or occupied slots without promising cache behavior; “slot” may evoke sparse/hash storage. |
| 4 | `PresenceTable` | Describes occupancy without promising caching, but is unfamiliar and does not immediately communicate optional access. |
| 5 | `OptionalArray` | Familiar and migration-free, but is easily read as `Array<Optional<Element>>`. |
| 6 | `OptionalBuffer` | Regular beside `DenseBuffer`, but can be parsed as an optional buffer object. |
| 7 | `FixedOptionalArray` | Communicates fixed shape but is long and inherits fixed-size-array ambiguity. |
| 8 | `HeapOptionalArray` | Exposes an implementation fact without explaining the memoization role. |

## Suffix draft

The draft preference was an unsuffixed 1D owning type and `2D` through `4D` suffixes. Derived
non-owning types retained `1DView` through `3DView`, because an unsuffixed `View` does not state
which lower-dimensional result a chained access returns.

## Method-name boundary

No method synonyms were ranked. The sole candidate remained `element(at:)`,
`setElement(_:at:)`, and, for the always-initialized family, `reference(at:)` with `Reference`.

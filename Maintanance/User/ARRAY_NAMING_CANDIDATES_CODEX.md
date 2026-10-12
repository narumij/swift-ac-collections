# Codex independent object-name candidates

Status: submitted without ranking. These are candidates, not recommendations or adopted names.

## Candidate A: `ContiguousElements` / `MemoTable`

| Family | 1D | 2D | 3D | 4D | Derived views |
| --- | --- | --- | --- | --- | --- |
| Bare | `ContiguousElements` | `ContiguousElements2D` | `ContiguousElements3D` | `ContiguousElements4D` | `ContiguousElements1DView` ... `3DView` |
| Optional | `MemoTable` | `MemoTable2D` | `MemoTable3D` | `MemoTable4D` | `MemoTable1DView` ... `3DView` |

`ContiguousElements` names the owned contiguous element region without claiming ordinary `Array`
semantics. `MemoTable` names the principal problem solved by presence-tracked slots. The asymmetry
is intentional: one name describes storage shape, while the other describes use.

Concern: `ContiguousElements` is long in generic signatures, while `MemoTable` may sound limited to
dynamic programming even though the representation is more general.

## Candidate B: `FlatStorage` / `PresenceTable`

| Family | 1D | 2D | 3D | 4D | Derived views |
| --- | --- | --- | --- | --- | --- |
| Bare | `FlatStorage` | `FlatStorage2D` | `FlatStorage3D` | `FlatStorage4D` | `FlatStorage1DView` ... `3DView` |
| Optional | `PresenceTable` | `PresenceTable2D` | `PresenceTable3D` | `PresenceTable4D` | `PresenceTable1DView` ... `3DView` |

`FlatStorage` emphasizes that multidimensional coordinates map onto one contiguous allocation.
`PresenceTable` emphasizes the explicit set/unset state without promising a caching strategy.

Concern: `Storage` can sound like an internal implementation type rather than a user-facing value.
`PresenceTable` is precise but unfamiliar and may not immediately imply optional element access.

## Candidate C: `DenseBuffer` / `OptionalBuffer`

| Family | 1D | 2D | 3D | 4D | Derived views |
| --- | --- | --- | --- | --- | --- |
| Bare | `DenseBuffer` | `DenseBuffer2D` | `DenseBuffer3D` | `DenseBuffer4D` | `DenseBuffer1DView` ... `3DView` |
| Optional | `OptionalBuffer` | `OptionalBuffer2D` | `OptionalBuffer3D` | `OptionalBuffer4D` | `OptionalBuffer1DView` ... `3DView` |

This pair uses a shared `Buffer` category while distinguishing always-initialized dense elements
from independently present optional slots. It produces a regular family and avoids claiming Swift
`Collection` conformance.

Concern: `OptionalBuffer` can be misread as an optional buffer object rather than a buffer whose
individual positions are optional. `DenseBuffer` may suggest a sparse counterpart that does not
exist.

## Suffix observation

All Codex candidates use an unsuffixed 1D owning type and dimension suffixes only for 2D through
4D. The corresponding View retains `1DView` because an unsuffixed `...View` could be confused with
a view preserving arbitrary dimensionality. This is part of each submitted candidate, not a ranked
recommendation.

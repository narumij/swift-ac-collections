# BareArray / OptionalArray object and API naming draft

Status: candidate collection in progress. No public name or API in this document is adopted.

## Purpose

Before fixing benchmark names or switching CI regression workloads, determine the public object
names and element-access API of BareArray and OptionalArray as one public surface.

Object-name exploration and method-name confirmation are deliberately asymmetric:

- Object names are explored independently by the user, Codex, and Claude.
- Method names do not branch into new candidates. The current method family alone is reviewed.

## Process

1. The user, Codex, and Claude each submit object-name candidates independently.
2. Candidate generation ends before any cross-review or ranking begins.
3. The three candidate sets are combined without silently merging distinct meanings.
4. The combined candidates are ranked by role accuracy, call-site readability, family coherence,
   and compatibility cost.
5. The user, Codex, and Claude discuss the ranked result; the user makes the public-name decision.
6. The current method family is confirmed or rejected as one API decision without generating new
   method-name alternatives.
7. Only after those decisions are implementation, Test as Specification, benchmark stabilization,
   baseline merge, and CI registration performed.

Agreement during candidate generation is not a result. Candidate overlap becomes useful evidence
only after the independent submissions are visible and their reasoning can be compared.

## Current public objects

| Role | BareArray family | OptionalArray family |
| --- | --- | --- |
| Owning 1D | `BareArray<Element>` | `OptionalArray1D<Element>` |
| Owning 2D | `BareArray2D<Element>` | `OptionalArray2D<Element>` |
| Owning 3D | `BareArray3D<Element>` | `OptionalArray3D<Element>` |
| Owning 4D | `BareArray4D<Element>` | `OptionalArray4D<Element>` |
| Non-owning 1D | `BareArray1DView<Element>` | `OptionalArray1DView<Element>` |
| Non-owning 2D | `BareArray2DView<Element>` | `OptionalArray2DView<Element>` |
| Non-owning 3D | `BareArray3DView<Element>` | `OptionalArray3DView<Element>` |

The review includes the family base names, dimension suffix convention, and derived View names.
Coordinate labels are recorded as a related naming consequence but do not need to be decided in
the same decision unless ranking reveals that they change the meaning of the object name.

## Sole method-name candidate

| Operation | BareArray | OptionalArray |
| --- | --- | --- |
| Read | `element(at: ...) -> Element` | `element(at: ...) -> Element?` |
| Write | `setElement(_:at: ...)` | `setElement(_:at: ...)` |
| Mutable reference | `reference(at: ...) -> Reference` | not provided |
| Reference type | `typealias Reference = MutableRef<Element>` | not provided |

The method review asks whether this existing family is acceptable as a whole. It does not solicit
synonyms or alternative spellings. Subscript and View deprecation or retention is a consequence to
inventory after the preferred API is fixed, not another method-naming branch.

## Candidate-submission contract

Each participant supplies:

- one or more base-name pairs for the two owning families;
- the intended meaning of each name;
- the 1D through 4D spelling and the corresponding View spelling;
- any reason the two families should intentionally use different suffix conventions;
- obvious compatibility or discoverability concerns.

Candidates are not ranked in the submission. A participant may retain a current name. Claude must
submit its candidates before reading the user or Codex candidate records.

## Ranking criteria

Ranking occurs only after all submissions are present.

1. The name describes the object's actual role rather than merely its implementation.
2. Generic specializations and call sites read naturally.
3. The 1D through 4D family and derived View names remain understandable.
4. The two modules are aligned where their roles match and distinct where their roles differ.
5. Migration and source-compatibility costs are explicit.
6. The name does not promise collection semantics, safety, sparsity, caching policy, or ownership
   behavior that the implementation does not provide.

## Boundaries

- Do not rename production declarations, files, tests, benchmarks, or documentation during review.
- Do not change availability, deprecation, safety, ownership, lifetime, or product-positioning
  policy.
- Do not treat benchmark performance as proof of a preferred spelling.
- Do not begin ranking before all three independent submissions are complete.
- Do not turn reviewer agreement into adoption; the public decision remains with the user.

## Completion condition

The naming work is ready for implementation only after independent candidate collection, combined
ranking, the user's object-name decision, and the current method-family decision are complete.

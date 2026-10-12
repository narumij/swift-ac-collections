# BareArray / OptionalArray object and API naming draft

Status: object-name candidate collection and initial ranking completed; broader public API candidate
collection is in progress. No public name or API in this document is adopted.

## Purpose

Before fixing benchmark names or switching CI regression workloads, determine the public object
names and element-access API of BareArray and OptionalArray as one public surface.

Object names and public API names are explored independently by the user, Codex, and Claude before
cross-review. Current names remain candidates; their presence in production does not adopt them for
0.6 or 1.0.

## Process

1. The user, Codex, and Claude each submit object-name candidates independently.
2. Candidate generation ends before any cross-review or ranking begins.
3. The three candidate sets are combined without silently merging distinct meanings.
4. The combined candidates are ranked by role accuracy, call-site readability, family coherence,
   and compatibility cost.
5. Missing public API candidates are collected independently in the three
   `PUBLIC_API_NAMING_CANDIDATES_*.md` records.
6. The complete candidate set is integrated and scored without adopting a name.
7. The user, Codex, and Claude discuss the scored result; the user makes each public-name decision.
8. Only after those decisions are implementation, Test as Specification, benchmark stabilization,
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

## User-submitted current method-name candidate

| Operation | BareArray | OptionalArray |
| --- | --- | --- |
| Read | `element(at: ...) -> Element` | `element(at: ...) -> Element?` |
| Write | `setElement(_:at: ...)` | `setElement(_:at: ...)` |
| Mutable reference | `reference(at: ...) -> Reference` | not provided |
| Reference type | `typealias Reference = MutableRef<Element>` | not provided |

This table records the user's submitted candidate. It is not the sole candidate: Codex and Claude
submit independent alternatives in their respective `PUBLIC_API_NAMING_CANDIDATES_*.md` records.
Subscript and View deprecation or retention remains a separate contract and product-positioning
question; candidate submission does not decide it.

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
- Do not begin the broader public API scoring before all three independent submissions are complete.
- Do not turn reviewer agreement into adoption; the public decision remains with the user.

## Completion condition

The Array naming work is ready for implementation only after independent candidate collection,
combined scoring and discussion, the user's object-name decision, and the user's access-API decision
are complete.

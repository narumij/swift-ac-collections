# BareArray / OptionalArray object and API naming draft

Status: naming decisions are complete. `Current/PUBLIC_API_NAMING_DECISIONS.md` is authoritative. This
document preserves the deliberation and provides the bounded implementation handoff; it does not
authorize the frozen production rename task by itself.

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
   `Archived/PublicAPINaming/PUBLIC_API_NAMING_CANDIDATES_*.md` records.
6. Codex compiles all distinct candidates into `Archived/PublicAPINaming/PUBLIC_API_NAMING_BALLOT.md`, verifies the ballot's
   completeness and separation, and hands the fixed ballot to the scorers without scoring it.
7. The user, Codex, and Claude independently score the completed ballot in their separate score
   records. The user supplies a 1–10 score only; Codex and Claude also record reasons and concerns.
8. After all three submissions, Codex combines them in `Archived/PublicAPINaming/PUBLIC_API_NAMING_SCORE_REPORT.md` without
   treating totals, averages, or agreement as adoption.
9. The scored result is discussed. The user makes each public-name decision, and the conclusion is
   recorded in `Current/PUBLIC_API_NAMING_DECISIONS.md`.
10. Only after those decisions are implementation, Test as Specification, benchmark stabilization,
   baseline merge, and CI registration performed.

Agreement during candidate generation is not a result. Candidate overlap becomes useful evidence
only after the independent submissions are visible and their reasoning can be compared.

On 2026-10-13, the user asked Codex to replace its first submission after Codex had already read the
other records. The replacement is therefore explicitly review-informed rather than independent. It
replaces the earlier Codex submission instead of adding another participant or vote. Candidate overlap
does not receive ballot weight, and the later three scoring records retain their independent boundary.

## Current public objects

| Role | BareArray family | OptionalArray family |
| --- | --- | --- |
| Owning 1D | `BareArray<Element>` | `OptionalArray1D<Element>` |
| Owning 2D | `BareArray2D<Element>` | `OptionalArray2D<Element>` |
| Owning 3D | `BareArray3D<Element>` | `OptionalArray3D<Element>` |
| Owning 4D | `BareArray4D<Element>` | `OptionalArray4D<Element>` |

The old non-owning View types and chained subscripts were deleted in `2f4e5729`; their names are no
longer decision candidates. The review includes the owner-family base names and dimension suffix
convention. Coordinate methods use the innermost-axis-first order and no longer compete with an
oppositely ordered chained-subscript surface.

## User-submitted current method-name candidate

| Operation | BareArray | OptionalArray |
| --- | --- | --- |
| Read | `element(at: ...) -> Element` | `element(at: ...) -> Element?` |
| Write | `setElement(_:at: ...)` | `setElement(_:at: ...)` |
| Mutable reference | `reference(at: ...) -> Reference` | not provided |
| Reference type | `typealias Reference = MutableRef<Element>` | not provided |

This table records the user's submitted candidate. It is not the sole candidate: Codex and Claude
record alternatives in their respective
`Archived/PublicAPINaming/PUBLIC_API_NAMING_CANDIDATES_*.md` records.
The deleted subscript and View surfaces are not revived by candidate submission.

## Current-surface reconciliation before ballot compilation

The submitted records are preserved as candidate-generation evidence, but they do not yet define a
sound ballot. They mix several independently decidable questions and include candidates whose meaning
requires a contract change rather than a spelling choice.

### Naming-only comparison units

The ballot must separate at least these units:

1. The always-initialized owner-family base name.
2. The presence-tracked owner-family base name.
3. The 1D suffix convention; the current families are asymmetric.
4. Copied value access: `element` / `setElement` versus another naming-only vocabulary.
5. BareArray borrowed mutation: method name, public reference name, concrete `MutableRef` name, and
   its `pointee` property.

Names originally submitted as a pair do not have to be adopted as an inseparable pair. Splitting the
two owner roles prevents a preference about `BareArray` from deciding `OptionalArray`, or vice versa.
It also avoids making a possible future BareArray product-exclusion decision block the maintained
OptionalArray name.

### Contract-dependent submissions

The following are not ordinary spelling candidates and must not be scored against naming-only entries
without a prior contract decision:

- `withMutableValue(at:_:)`, because it replaces the public borrowed-reference model with a closure API.
- `removeElement(at:)`, because it adds an OptionalArray operation rather than renaming one.
- Removing the public reference type, because it changes the exposed access model.
- Excluding BareArray from the product, because that decides whether its renaming has product value.

These remain useful findings but are not ballot entries until their corresponding contract is selected.

### Retired or withdrawn submissions

- All View-name spellings are retired with the deleted View types.
- The multi-index subscript candidate is withdrawn; the subscript surface has been deleted.
- Claude's borrowed-Permutation-as-default candidate was withdrawn by the user's recorded decision and
  is unrelated to the Array ballot.

### Candidate material that remains usable

For owner names, the submitted vocabulary remains available after separating the two roles:

- Always-initialized: `BareElements`, `ElementBuffer`, `FixedShapeElements`, `BareArray`, `FixedArray`,
  and `HeapArray`.
- Presence-tracked: `OptionalCache`, `OptionalElementBuffer`, `OptionalFixedShapeElements`,
  `OptionalArray`, `FixedOptionalArray`, `HeapOptionalArray`, `SlotArray`, and `MemoTable`.

For current operations, `element` / `setElement` and `reference` / `Reference` remain a complete
compatibility candidate. `mutableElement` / `MutableElementReference` remains a naming-only alternative
for the borrowed-reference portion. Claude's `value` / `setValue` vocabulary may be considered
independently of its contract-changing closure proposal; that separation must be explicit in the fixed
ballot rather than inferred from the original bundled submission.

Before ballot compilation, the candidate set must be checked for missing naming-only alternatives and
for misleading promises against the current source and quality profiles. Completion means that every
entry compares one naming decision, not that every submitted phrase is forced onto the ballot.

Codex later added `PresenceBuffer`, `MemoizationTable`, `elementReference`, and direct `MutableRef`
alternatives while reconciling the submissions with the current surface. Those entries are explicitly
marked as review-informed supplements. Their meanings survived independent inspection, but their
eligibility alongside the original submissions was accepted by the user on 2026-10-13. This does not
make the supplements independent submissions and does not adopt them as public names.

### Current semantic screen

The current source and quality profiles support the following cautions when the ballot is compiled.
They are comparison information, not rankings or adoption.

- `BareArray` preserves compatibility but leaves “bare” unexplained. `BareElements` retains the same
  ambiguity while making the type name plural. `ElementBuffer` describes the low-level owner role;
  `FixedShapeElements` describes its invariant but is long. `FixedArray` may imply a type-level count
  or inline storage, and `HeapArray` promotes a representation detail into the product name.
- `OptionalArray` resembles `Array<Optional<Element>>`, although the implementation separately owns a
  presence map and conditionally initialized payload. `OptionalCache` and `MemoTable` express the
  documented memoization use but may imply policy or narrow other uses. `SlotArray` and
  `PresenceBuffer` express the state model; the former is broad and the latter is unfamiliar.
  `MemoizationTable` is explicit about the intended use without claiming eviction.
- `element` / `setElement` matches the current contract and speaks about stored elements. `value` /
  `setValue` is shorter semantically but may make reference-element identity and ownership less clear.
- `reference` / `Reference` is compact but omits mutability and lifetime. `mutableElement` /
  `MutableElementReference` is explicit but long. `elementReference` keeps the projected object visible
  without stating mutability. The existing concrete `MutableRef` is short but abbreviated.
- `pointee` matches pointer vocabulary and the addressor implementation. `value` reads more safely at
  the call site but can sound like a copied value rather than mutable access to owner storage.

No candidate can encode noncopyability, borrowed lifetime, fixed shape, contiguity, memoization use,
and competitive brevity at once. The ballot therefore preserves known tradeoffs rather than treating
the most descriptive or shortest spelling as automatically correct.

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

## IDE-assisted owner rename handoff

The user will perform the owner-type renames with Xcode's symbol-aware rename support. Codex does not
perform a textual bulk replacement. The intended declaration mapping is:

- `BareArray` → `ElementBuffer`
- `BareArray2D` → `ElementBuffer2D`
- `BareArray3D` → `ElementBuffer3D`
- `BareArray4D` → `ElementBuffer4D`
- `OptionalArray1D` → `OptionalElementBuffer`
- `OptionalArray2D` → `OptionalElementBuffer2D`
- `OptionalArray3D` → `OptionalElementBuffer3D`
- `OptionalArray4D` → `OptionalElementBuffer4D`

Rename one owning declaration at a time from its production declaration and let Xcode update indexed
references. Complete one family before the other so a failed rename has a local boundary. Do not use
the rename to change `element(at:)`, `setElement(_:at:)`, `reference(at:)`, or standard
`MutableRef.value`; those decisions are already closed and are not part of the owner rename.

After each family, build for testing before doing residual cleanup. Then inspect unresolved old names
in production, tests, compiler-diagnostic fixtures, benchmarks, package facade tests, and current
public documentation. Benchmark display titles, filenames, and prose may require intentional manual
updates because they are not symbol references. Historical scoring, review, and archived records keep
the names they actually evaluated unless a current-state sentence incorrectly presents them as the
new API.

Final acceptance requires the renamed production surface, Test as Specification, compiler fixtures,
benchmark package, and current documentation to agree. The rename does not begin until the user
explicitly restarts the frozen implementation task.

### Implementation result

On 2026-10-13, the user performed both owner-family renames with Xcode. Codex completed the
non-indexed benchmark, compiler-fixture, display-name, source-path, and current-documentation updates.
The resulting public owner families are `ElementBuffer` through `ElementBuffer4D` and
`OptionalElementBuffer` through `OptionalElementBuffer4D`. Build for Testing, both module suites,
the `AcCollections` facade tests, the borrowed-reference compiler fixtures, and the benchmark package
build succeeded. Historical records retain the names they evaluated.

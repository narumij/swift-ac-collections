# Public API naming score — Codex

Status: completed independently on 2026-10-13. User and Claude score records were not read.

Copy the accepted candidate IDs and concise spellings from `PUBLIC_API_NAMING_BALLOT.md`. Codex
records a whole-number score from 1 through 10, its reason, and any material concern.

Do not read the User or Claude score records before submitting this score record.

Use role accuracy, call-site readability, family coherence, necessary distinction, migration cost,
promise accuracy, and Validation fitness as evaluation lenses. They are not separately summed.

| Candidate ID | Candidate | Codex score (1–10) | Reason | Material concern |
| --- | --- | --- | --- | --- |
| `BO-01` | `BareElements` | 5 | Distinguishes the type from ordinary `Array` semantics. | “Bare” remains unexplained, and a plural owner type reads unusually. |
| `BO-02` | `ElementBuffer` | 8 | Describes owned low-level element storage without promising value semantics. | Does not express fixed multidimensional shape or noncopyability. |
| `BO-03` | `FixedShapeElements` | 7 | Expresses the invariant that dimensions do not resize. | Long, and “shape” is disproportionate for 1D. |
| `BO-04` | `BareArray` | 7 | Familiar, compact, and minimizes migration. | “Bare” is vague and `Array` suggests copyable value semantics. |
| `BO-05` | `FixedArray` | 6 | Compactly communicates non-resizability. | Commonly implies inline storage or a type-level count. |
| `BO-06` | `HeapArray` | 5 | Accurately signals heap-owned storage. | Makes allocation strategy the public role and still suggests Array semantics. |
| `PO-01` | `OptionalCache` | 6 | Connects directly to the principal memoization use. | “Cache” may promise calculation, eviction, or policy the type does not provide. |
| `PO-02` | `OptionalElementBuffer` | 7 | Relates clearly to `ElementBuffer` and signals conditional payload. | Grammar can imply an optional buffer rather than optional positions. |
| `PO-03` | `OptionalFixedShapeElements` | 6 | Combines presence and fixed-shape information. | Too long for routine competitive-programming use. |
| `PO-04` | `OptionalArray` | 6 | Familiar and inexpensive to migrate. | Strongly resembles `Array<Element?>`, which has different storage and semantics. |
| `PO-05` | `FixedOptionalArray` | 5 | Signals fixed extent and optional positions. | Modifier grouping is ambiguous and `FixedArray` carries misleading implications. |
| `PO-06` | `HeapOptionalArray` | 4 | Mentions heap ownership and optional positions. | Long, representation-led, and still resembles an ordinary optional array. |
| `PO-07` | `SlotArray` | 8 | “Slot” naturally describes occupied and unoccupied fixed positions. | May evoke hash-table buckets, pools, or sparse storage. |
| `PO-08` | `MemoTable` | 8 | Compactly describes the primary dynamic-programming use. | Narrows the apparent domain and can imply memoization behavior. |
| `PO-09` | `PresenceBuffer` | 8 | Closely matches the separate presence-map and payload representation. | Unfamiliar vocabulary and less immediately tied to memoization. |
| `PO-10` | `MemoizationTable` | 7 | Explicit and readily understood in the intended use. | Long and narrower than the underlying storage abstraction. |
| `DS-01` | Unsuffixed 1D for both families | 9 | Treats 1D as the natural base and gives both families one predictable rule. | Renames the established `OptionalArray1D`. |
| `DS-02` | Explicit rank for every family | 6 | Makes dimensional rank completely regular and visible. | Adds ceremony to the common case and renames `BareArray`. |
| `DS-03` | Preserve current asymmetry | 4 | Minimizes immediate source migration. | Leaves a family-level naming rule that users cannot predict. |
| `VA-01` | `element` / `setElement` | 9 | Precisely names stored elements and matches the current tested surface. | Verbose at multidimensional call sites. |
| `VA-02` | `value` / `setValue` | 6 | Reads naturally for copied access. | Weakens element identity and can blur value versus referenced owner storage. |
| `BR-01` | `reference` | 7 | Compact and already established in tests and examples. | Omits mutability, element scope, and borrowed lifetime. |
| `BR-02` | `mutableElement` | 8 | Makes mutation and element scope prominent at the call site. | Does not say that the result is reference-like. |
| `BR-03` | `elementReference` | 8 | Clearly separates reference projection from copied element access. | Omits mutability and lifetime. |
| `RT-01` | `Reference` alias backed by `MutableRef` | 6 | Short when nested in owner context and preserves compatibility. | Hides mutability and gives one public concept two names. |
| `RT-02` | `MutableElementReference` | 8 | Accurately names mutability, element scope, and reference behavior. | Long in declarations and competitive use. |
| `RT-03` | `MutableRef` directly | 8 | Keeps one established, compact public type name. | Abbreviation and borrowed lifetime remain implicit. |
| `RP-01` | `pointee` | 8 | Correctly communicates reference-style access and matches pointer vocabulary. | Sounds lower-level and less approachable than the wrapper intends. |
| `RP-02` | `value` | 6 | Reads safely and simply at use sites. | Can be mistaken for a copied value rather than mutable owner storage. |

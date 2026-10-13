# Public API naming ballot

Status: accepted fixed Array naming ballot for independent scoring. The user accepted inclusion of
the explicitly marked review-informed Codex supplements on 2026-10-13. Candidate provenance remains
visible; no candidate is ranked or adopted.

## Purpose

This ballot separates decisions that the original submissions bundled together. A score for one row
must not decide a different public contract or spelling. Deleted View and subscript surfaces,
Permutation names, and API additions are outside this ballot.

## Inputs

- `PUBLIC_API_NAMING_CANDIDATES_USER.md`
- `PUBLIC_API_NAMING_CANDIDATES_CODEX.md`
- `PUBLIC_API_NAMING_CANDIDATES_CLAUDE.md`
- `ArrayObjectAndAPINamingDraft.md`
- current BareArray and OptionalArray production declarations and Quality Profiles

## A. Always-initialized owner base name

The dimensional suffix is scored separately. Spellings below represent the unsuffixed base.

| ID | Candidate | Source | Intended meaning | Known concern |
| --- | --- | --- | --- | --- |
| `BO-01` | `BareElements` | User | Lightweight owned elements without ordinary Array semantics | “Bare” remains unexplained; plural type name is unusual |
| `BO-02` | `ElementBuffer` | Codex | Low-level owned element storage | Does not state fixed shape or noncopyability |
| `BO-03` | `FixedShapeElements` | Codex | Elements whose shape is fixed after initialization | Long; “shape” is heavy for 1D |
| `BO-04` | `BareArray` | Codex, Claude, current | Preserve established competitive-programming vocabulary | “Bare” is vague and `Array` invites value-semantic expectations |
| `BO-05` | `FixedArray` | Claude | Non-resizable array | May imply type-level count or inline storage |
| `BO-06` | `HeapArray` | Claude | Heap-owned contiguous array | Elevates allocation location over the type’s role |

## B. Presence-tracked owner base name

The type owns a presence map and conditionally initialized payload for fixed slots. It is documented
primarily for array-based memoization but does not calculate or evict values.

| ID | Candidate | Source | Intended meaning | Known concern |
| --- | --- | --- | --- | --- |
| `PO-01` | `OptionalCache` | User | Optional storage used as a memoization cache | May imply automatic calculation or cache policy |
| `PO-02` | `OptionalElementBuffer` | Codex | Element buffer whose positions may be unset | Long; “Optional” may modify the buffer rather than its slots |
| `PO-03` | `OptionalFixedShapeElements` | Codex | Fixed-shape positions with optional presence | Very long |
| `PO-04` | `OptionalArray` | Codex, Claude | Preserve current category while normalizing 1D suffix | Resembles `Array<Optional<Element>>` and ordinary Array semantics |
| `PO-05` | `FixedOptionalArray` | Claude | Non-resizable optional-position array | Ambiguous grammar and the same fixed-array implications |
| `PO-06` | `HeapOptionalArray` | Claude | Heap-owned optional-position array | Representation detail dominates; long |
| `PO-07` | `SlotArray` | Claude | Each fixed position is an empty or occupied slot | “Slot” may suggest a hash table, pool, or sparse storage |
| `PO-08` | `MemoTable` | Claude | Table used to store memoized results | May imply a narrower use or unstated memoization behavior |
| `PO-09` | `PresenceBuffer` | Codex supplement | Buffer that separately tracks payload presence | Precise but unfamiliar vocabulary |
| `PO-10` | `MemoizationTable` | Codex supplement | Explicitly state the documented primary use | Long and intentionally narrows apparent use |

## C. One-dimensional suffix convention

This choice applies after selecting each base name.

| ID | Candidate | Representative result | Source | Intended meaning | Known concern |
| --- | --- | --- | --- | --- | --- |
| `DS-01` | Unsuffixed 1D for both families | `Base`, `Base2D`, `Base3D`, `Base4D` | Codex, Claude | Treat 1D as the base case and suffix only additional ranks | Changes current `OptionalArray1D` spelling |
| `DS-02` | Explicit rank for every family | `Base1D`, `Base2D`, `Base3D`, `Base4D` | Claude | Make rank visible and symmetric everywhere | Changes current `BareArray` spelling and adds ceremony to common 1D use |
| `DS-03` | Preserve current asymmetry | `BareArray` / `OptionalArray1D` pattern | Current | Minimize source migration | One family rule cannot predict both 1D names |

## D. Copied value-access vocabulary

Coordinate labels and innermost-axis-first order remain unchanged.

| ID | Read | Write | Source | Intended meaning | Known concern |
| --- | --- | --- | --- | --- | --- |
| `VA-01` | `element(at: ...)` | `setElement(_:at: ...)` | User, Codex, Claude, current | Name the stored element and preserve compatibility | Verbose but explicit |
| `VA-02` | `value(at: ...)` | `setValue(_:at: ...)` | Claude, separated from closure proposal | Describe copied access without claiming Collection conformance | “Value” may understate element identity and reference ownership |

## E. Borrowed mutable-reference method

This section changes spelling only. The current `~Escapable` lifetime and mutable owner-storage
projection remain unchanged. Sections E through G apply only to the BareArray family; OptionalArray
has no corresponding borrowed-reference surface.

| ID | Candidate | Source | Intended meaning | Known concern |
| --- | --- | --- | --- | --- |
| `BR-01` | `reference(at: ...)` | User, Codex, Claude, current | Compact reference-producing operation | Does not state mutable, borrowed, or element-specific |
| `BR-02` | `mutableElement(at: ...)` | Codex | Emphasize mutable access to one element | Does not literally say that the result is reference-like |
| `BR-03` | `elementReference(at: ...)` | Codex supplement | Name the reference projection explicitly | Does not state mutability or lifetime |

## F. Borrowed reference public result name

| ID | Candidate | Source | Intended meaning | Known concern |
| --- | --- | --- | --- | --- |
| `RT-01` | `Reference` alias backed by `MutableRef` | User, Codex, Claude, current | Short contextual spelling at the owner type | Hides mutability and creates two public names |
| `RT-02` | `MutableElementReference` | Codex | Fully describe the mutable element projection | Long for competitive use |
| `RT-03` | `MutableRef` directly | Codex supplement, Claude, current concrete type | Keep one short public name and remove alias ambiguity | Abbreviated and still omits borrowed lifetime |

## G. Borrowed reference value property

| ID | Candidate | Source | Intended meaning | Known concern |
| --- | --- | --- | --- | --- |
| `RP-01` | `pointee` | Current | Match pointer/addressor vocabulary | Sounds unsafe and implementation-oriented |
| `RP-02` | `value` | Claude | Present a safer reference-like abstraction | Can sound like a copied value rather than owner storage |

## Excluded from this naming ballot

| Submission | Reason |
| --- | --- |
| View type spellings | The public View types were deleted |
| Multi-index subscript | The public subscript surface was deleted and the candidate was withdrawn |
| `withMutableValue(at:_:)` | Changes the borrowed-access contract to a closure API |
| `removeElement(at:)` | Adds an operation rather than renaming an existing operation |
| Removing the public reference result | Changes the public access contract |
| BareArray product exclusion | Product-scope decision, not a name |
| Initializer, `removeAll`, `indices`, shape labels | Valid later naming scopes retained in the candidate records; not required to decide owner and element-access names in this ballot |
| Permutation names | Independent module and decision path |

## Compilation verification

| Check | Result | Evidence or remaining work |
| --- | --- | --- |
| Deleted surfaces are excluded. | verified | Current source has no public View or subscript declarations |
| Contract changes are separated from spelling choices. | verified | Closure mutation, operation addition, and product exclusion are listed separately |
| Owner roles are independently selectable. | verified | `BO-*` and `PO-*` are separate sections |
| Suffix, value access, reference method, type, and property are independent. | verified | `DS-*`, `VA-*`, `BR-*`, `RT-*`, and `RP-*` |
| Submitted meanings and known concerns are preserved. | verified | Claude independently traced the submitted candidates; review-informed Codex supplements remain visibly marked |
| Candidate set is complete enough for scoring. | accepted | No missing current-surface naming alternative was found; the user accepted the marked supplements for this scoring round |

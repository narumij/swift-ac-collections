# Public API naming score report

Status: completed integration of the three independent score records on 2026-10-13. No public name
is selected or adopted by this report.

## Purpose and interpretation boundary

This report combines the completed User, Codex, and Claude score records without changing their raw
scores. It exposes strength of preference, disagreement, reasons, concerns, and unresolved product
judgments. It does not select or adopt a public name.

The scorers used the numeric scale differently. The user used 5 as roughly neutral; a score of 1 may
mean either “unclear” or “tends toward rejection.” Codex used 4 through 9 and Claude used 2 through 8.
Therefore a cross-scorer sum, mean, raw spread, or unqualified interpretation of a user's 1 is not a
shared utility measure. Read each score relative to that scorer's alternatives in the same section,
and clarify the meaning of a 1 only where it affects a decision. The spread is retained only as a
locator for visible disagreement, not as a decision rule.

## Combined scores

| Candidate ID | Candidate | User | Codex | Claude | Spread | AI reasons and concerns |
| --- | --- | ---: | ---: | ---: | ---: | --- |
| `BO-01` | `BareElements` | 5 | 5 | 4 | 1 | Avoids ordinary Array semantics, but plural type naming and unexplained “Bare” remain awkward. |
| `BO-02` | `ElementBuffer` | 4 | 8 | 6 | Accurately describes owned low-level storage; fixed shape and noncopyability remain implicit. |
| `BO-03` | `FixedShapeElements` | 4 | 7 | 4 | States the invariant, but is long and “shape” is heavy for 1D. |
| `BO-04` | `BareArray` | 4 | 7 | 7 | Compact and migration-free; `Array` suggests value semantics and “Bare” is vague. |
| `BO-05` | `FixedArray` | 4 | 6 | 5 | Short and non-resizable, but may imply type-level count or inline storage. |
| `BO-06` | `HeapArray` | 1 | 5 | 3 | Names allocation strategy rather than role and does not distinguish it well from ordinary Array. |
| `PO-01` | `OptionalCache` | 5 | 6 | 4 | Fits memoization use, but can promise automatic calculation, eviction, or cache policy. |
| `PO-02` | `OptionalElementBuffer` | 4 | 7 | 5 | Coherent with `ElementBuffer`; grammar can make the whole buffer sound optional. |
| `PO-03` | `OptionalFixedShapeElements` | 4 | 6 | 3 | Descriptively accurate but too long for routine use. |
| `PO-04` | `OptionalArray` | 1 | 6 | 6 | Familiar and migration-friendly, but resembles `Array<Element?>` despite different semantics. |
| `PO-05` | `FixedOptionalArray` | 1 | 5 | 3 | Signals fixed optional positions, but has ambiguous modifier grouping and FixedArray implications. |
| `PO-06` | `HeapOptionalArray` | 1 | 4 | 2 | Long and dominated by a representation detail. |
| `PO-07` | `SlotArray` | 1 | 8 | 6 | Models occupied slots compactly, but can evoke hash tables, pools, or sparse storage. |
| `PO-08` | `MemoTable` | 1 | 8 | 6 | Compactly matches the main use, but narrows the domain and may imply behavior. |
| `PO-09` | `PresenceBuffer` | 1 | 8 | 5 | Matches presence-map storage precisely, but is unfamiliar and weakly signals element storage. |
| `PO-10` | `MemoizationTable` | 3 | 7 | 5 | Explicit and less policy-laden than Cache, but long and intentionally narrow. |
| `DS-01` | Unsuffixed 1D for both families | 1 | 9 | 8 | Gives one predictable base-case rule; requires renaming `OptionalArray1D`. |
| `DS-02` | Explicit rank for every family | 5 | 6 | 5 | Symmetric and explicit, but adds ceremony and renames `BareArray`. |
| `DS-03` | Preserve current asymmetry | 5 | 4 | 3 | Avoids migration but keeps an unpredictable family rule. |
| `VA-01` | `element` / `setElement` | 4 | 9 | 8 | Precisely names stored elements and matches current tests; somewhat verbose. |
| `VA-02` | `value` / `setValue` | 5 | 6 | 5 | Reads naturally for copied access, but can blur element identity and copied versus referenced storage. |
| `BR-01` | `reference` | 5 | 7 | 7 | Compact and established; mutability, element scope, and borrowed lifetime remain implicit. |
| `BR-02` | `mutableElement` | 5 | 8 | 6 | Emphasizes mutation of one element, but not the reference-like result. |
| `BR-03` | `elementReference` | 5 | 8 | 5 | Separates reference projection from copied access, but omits mutability and lifetime. |
| `RT-01` | `Reference` alias backed by `MutableRef` | 1 | 6 | 6 | Short in owner context, but hides mutability and exposes two names for one concept. |
| `RT-02` | `MutableElementReference` | 1 | 8 | 4 | Fully descriptive, but long for declarations and competitive use. |
| `RT-03` | `MutableRef` directly | 4 | 8 | 7 | One compact established name with visible mutability; abbreviation and borrowed lifetime remain implicit. |
| `RP-01` | `pointee` | 4 | 8 | 5 | Honestly signals reference-style storage access, but sounds unsafe and implementation-oriented. |
| `RP-02` | `value` | 4 | 6 | 5 | Approachable and reference-like, but may be mistaken for a copied value. |

Do not use the mean, total, majority, or agreement as an automatic ranking or decision. The user's
scores intentionally require no written justification. Codex and Claude reasons remain evidence for
discussion even when their numerical scores match.

## Agreement and disagreement

| Candidate IDs | Observation | Evidence or reason | Discussion needed |
| --- | --- | --- | --- |
| `BO-01`–`BO-06` | No shared owner-name leader | User's relative leader is `BareElements`; Codex favors `ElementBuffer`; Claude favors current `BareArray` | Decide whether semantic improvement justifies migration and whether “Array” value-semantic expectations are acceptable |
| `PO-01`–`PO-10` | Different relative leaders; low scores need clarification | User's relative leader is `OptionalCache`; Codex favors state-model names; Claude's relative leaders include current `OptionalArray`, `SlotArray`, and `MemoTable`. User scores of 1 may mean unclear or rejection | Decide whether the public name should describe memoization use, storage state, or compatibility, clarifying only viable 1-point candidates |
| `DS-01`–`DS-03` | Apparent user/AI disagreement requiring clarification | User gave unsuffixed 1D a 1 and the other two choices 5; both AIs strongly prefer unsuffixed 1D. The 1 alone does not say whether the proposal was unclear or rejected | Establish what the three rules mean to the user and then decide whether symmetry means adding `1D`, removing it, or preserving current names |
| `VA-01`, `VA-02` | Direct vocabulary disagreement | User slightly prefers `value`; both AIs prefer current `element` because it preserves element identity and existing evidence | Decide whether shorter call-site language outweighs the semantic distinction and migration |
| `BR-01`–`BR-03` | User is indifferent; AIs split | User assigns all three 5; Codex favors explicit alternatives; Claude favors current `reference` | Decide how much mutability and result kind the method itself must state |
| `RT-01`–`RT-03` | Relative convergence on direct `MutableRef` | `RT-03` is the highest result-type score for all three scorers, although absolute scores differ | Confirm whether removing the `Reference` alias is acceptable compatibility cost |
| `RP-01`, `RP-02` | No user or Claude preference | User and Claude tie; Codex prefers `pointee` for reference semantics | Decide whether pointer accuracy or approachable vocabulary matters more |

## Unresolved facts and contract questions

| Candidate IDs | Missing fact or contract | Why scoring cannot resolve it | Required evidence or decision task |
| --- | --- | --- | --- |
| `BO-*` | Whether BareArray remains in the eventual product | A rename has different value if the family is later excluded | Keep the product-scope decision separate; naming can remain provisional until that boundary is known |
| `PO-*` | Whether general storage use or memoization is the intended public identity | Both are compatible with the current mechanism, but they make different promises | User product-positioning decision for the presence-tracked owner |
| `DS-*` | Whether unsuffixed 1D was unclear or rejected, and why | The user's 1 carries either meaning and no reason was required | Explain the concrete resulting names, then ask for the governing naming principle before deciding suffixes |
| `RT-*` | Compatibility policy for removing the `Reference` alias | Scores assess clarity but do not authorize source breakage | User decision on alias retention, deprecation, or direct removal |
| `RP-*` | Desired abstraction level of the safe borrowed wrapper | Both names accurately emphasize different aspects | User decision informed by representative call sites and the intended mental model |

## Decision handoff

The original two decision tasks were too broad for the ballot that resulted. The decisions are now
split so that one answer does not silently decide another spelling.

| Decision scope | Candidate IDs | Material comparison | Remaining uncertainty | Decision task |
| --- | --- | --- | --- | --- |
| Always-initialized owner base | `BO-01`–`BO-06` | Compatibility versus role accuracy and value-semantic expectations | Future product inclusion remains separate | `ARRAY-005` |
| Presence-tracked owner base | `PO-01`–`PO-10` | Memoization use versus storage-state description versus compatibility | Intended public identity | `ARRAY-009` |
| One-dimensional suffix | `DS-01`–`DS-03` | Unsuffixed base, explicit rank, or migration-only asymmetry | User's governing naming principle | `ARRAY-010` |
| Copied value access | `VA-01`, `VA-02` | Stored-element language versus shorter value language | Meaning of “value” for reference elements | `ARRAY-006` |
| Borrowed reference method | `BR-01`–`BR-03` | Compact compatibility versus explicit mutation or reference projection | Which fact belongs in the method name | `ARRAY-011` |
| Borrowed result type | `RT-01`–`RT-03` | Contextual alias, fully explicit type, or direct compact type | Alias compatibility policy | `ARRAY-012` |
| Borrowed result property | `RP-01`, `RP-02` | Pointer/reference accuracy versus approachable vocabulary | Intended wrapper mental model | `ARRAY-013` |

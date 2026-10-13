# Public API naming score — Claude

Status: fixed ballot copied. Scoring has not been started or authorized.

Copy the accepted candidate IDs and concise spellings from `PUBLIC_API_NAMING_BALLOT.md`. Claude
records a whole-number score from 1 through 10, its reason, and any material concern.

Do not read the User or Codex score records before submitting this score record.

Use role accuracy, call-site readability, family coherence, necessary distinction, migration cost,
promise accuracy, and Validation fitness as evaluation lenses. They are not separately summed.

| Candidate ID | Candidate | Claude score (1–10) | Reason | Material concern |
| --- | --- | --- | --- | --- |
| `BO-01` | `BareElements` |  |  |  |
| `BO-02` | `ElementBuffer` |  |  |  |
| `BO-03` | `FixedShapeElements` |  |  |  |
| `BO-04` | `BareArray` |  |  |  |
| `BO-05` | `FixedArray` |  |  |  |
| `BO-06` | `HeapArray` |  |  |  |
| `PO-01` | `OptionalCache` |  |  |  |
| `PO-02` | `OptionalElementBuffer` |  |  |  |
| `PO-03` | `OptionalFixedShapeElements` |  |  |  |
| `PO-04` | `OptionalArray` |  |  |  |
| `PO-05` | `FixedOptionalArray` |  |  |  |
| `PO-06` | `HeapOptionalArray` |  |  |  |
| `PO-07` | `SlotArray` |  |  |  |
| `PO-08` | `MemoTable` |  |  |  |
| `PO-09` | `PresenceBuffer` |  |  |  |
| `PO-10` | `MemoizationTable` |  |  |  |
| `DS-01` | Unsuffixed 1D for both families |  |  |  |
| `DS-02` | Explicit rank for every family |  |  |  |
| `DS-03` | Preserve current asymmetry |  |  |  |
| `VA-01` | `element` / `setElement` |  |  |  |
| `VA-02` | `value` / `setValue` |  |  |  |
| `BR-01` | `reference` |  |  |  |
| `BR-02` | `mutableElement` |  |  |  |
| `BR-03` | `elementReference` |  |  |  |
| `RT-01` | `Reference` alias backed by `MutableRef` |  |  |  |
| `RT-02` | `MutableElementReference` |  |  |  |
| `RT-03` | `MutableRef` directly |  |  |  |
| `RP-01` | `pointee` |  |  |  |
| `RP-02` | `value` |  |  |  |

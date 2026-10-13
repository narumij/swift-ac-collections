# Public API naming score — User

Status: completed independently on 2026-10-13. Codex and Claude scores were not read before submission.

Post-submission scale clarification: 5 was used as a roughly neutral score. A score of 1 may mean
either that the candidate was unclear to the user or that the user tended to want to reject it. The
raw score alone must not distinguish those meanings; ask only where the distinction matters to a
decision.

Copy the accepted candidate IDs and concise spellings from `PUBLIC_API_NAMING_BALLOT.md`. The user
records a whole-number score from 1 through 10. No written reason is required.

Do not read the Codex or Claude score records before submitting this score record.

| Candidate ID | Candidate | User score (1–10) |
| --- | --- | --- |
| `BO-01` | `BareElements` | 5 |
| `BO-02` | `ElementBuffer` | 4 |
| `BO-03` | `FixedShapeElements` | 4 |
| `BO-04` | `BareArray` | 4 |
| `BO-05` | `FixedArray` | 4 |
| `BO-06` | `HeapArray` |1  |
| `PO-01` | `OptionalCache` | 5 |
| `PO-02` | `OptionalElementBuffer` | 4 |
| `PO-03` | `OptionalFixedShapeElements` | 4 |
| `PO-04` | `OptionalArray` | 1 |
| `PO-05` | `FixedOptionalArray` | 1 |
| `PO-06` | `HeapOptionalArray` | 1 |
| `PO-07` | `SlotArray` | 1 |
| `PO-08` | `MemoTable` | 1 |
| `PO-09` | `PresenceBuffer` | 1 |
| `PO-10` | `MemoizationTable` | 3 |
| `DS-01` | Unsuffixed 1D for both families | 1 |
| `DS-02` | Explicit rank for every family |5  |
| `DS-03` | Preserve current asymmetry |5  |
| `VA-01` | `element` / `setElement` | 4 |
| `VA-02` | `value` / `setValue` | 5 |
| `BR-01` | `reference` | 5 |
| `BR-02` | `mutableElement` | 5 |
| `BR-03` | `elementReference` |5 |
| `RT-01` | `Reference` alias backed by `MutableRef` | 1 |
| `RT-02` | `MutableElementReference` |  1|
| `RT-03` | `MutableRef` directly | 4 |
| `RP-01` | `pointee` | 4 |
| `RP-02` | `value` | 4 |

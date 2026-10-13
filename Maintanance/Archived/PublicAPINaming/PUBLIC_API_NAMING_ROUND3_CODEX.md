# Public API naming deliberative score — Codex, round 3

Status: completed on 2026-10-13 after reading the round-2 records and report.

This round scores only the five unresolved finalists and states the product expectation each spelling
creates.

| Candidate ID | Candidate | Round-2 Codex | Round-3 Codex | What this name suggests or promises |
| --- | --- | ---: | ---: | --- |
| `PO-01` | `OptionalCache` | 6 | 7 | A compact, optional-result cache for memoization. It suggests cached state but may also suggest calculation or eviction unless documentation limits that expectation. |
| `PO-02` | `OptionalElementBuffer` | 6 | 5 | A low-level element buffer whose payload may be absent. It coheres with `ElementBuffer`, but the length and modifier attachment make routine use heavier. |
| `PO-10` | `MemoizationTable` | 6 | 6 | A table explicitly intended to store memoized results without necessarily promising eviction. It is accurate for the main use but long and purpose-specific. |
| `RP-01` | `pointee` | 7 | 5 | The projected storage location behind a reference. It accurately denies copy semantics, but the user's explicit dislike shows that pointer vocabulary may leak too much implementation into a safe wrapper. |
| `RP-02` | `value` | 6 | 7 | The value exposed through a reference wrapper. In the established `reference(at:).value` context, the wrapper supplies reference semantics, making the property approachable without necessarily implying an independent copy. |

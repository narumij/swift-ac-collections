# Public API naming deliberative score report — round 3

## TL;DR（人間向け）
Round 3の評価と、標準ライブラリAPIとの関係を受けた対象範囲の訂正を記録します。未解決名の決定はユーザーに残しています。これは当時の協議記録です。


Status: completed on 2026-10-13. This report records the deliberative result and the subsequent
scope correction. The user still adopts each in-scope public name in
`PUBLIC_API_NAMING_DECISIONS.md`.

## Combined result

| Candidate | User | Codex | Claude | Promise identified in round 3 | Result |
| --- | ---: | ---: | ---: | --- | --- |
| `OptionalCache` | 4 | 7 | 5 | A place that stores prior results; may also imply automatic calculation, capacity, or eviction policy | Not selected by deliberation |
| `OptionalElementBuffer` | 5 | 5 | 6 | The ElementBuffer-family owner whose individual elements may be absent | Converged presence-owner candidate |
| `MemoizationTable` | 4 | 6 | 5 | A coordinate-indexed destination for memoized results; purpose-specific and long | Not selected by deliberation |
| `pointee` | 1 | 5 | 4 | A pointer's referenced storage; semantically exact but exposes a low-level, beginner-hostile mental model | Out of scope after correction |
| `value` | 5 | 7 | 6 | The value exposed through `MutableRef`; reference semantics come from the containing type | Out of scope after correction |

## Why the evaluations moved

- `OptionalElementBuffer` became concrete after `ElementBuffer` was adopted. Its length remains a
  cost, but all three participants could identify the same storage model from the family name.
- `OptionalCache` remained readable but makes policy promises the implementation does not fulfill.
- `MemoizationTable` accurately states the main use, but makes a reusable storage mechanism sound
  dedicated to one algorithmic technique.
- The user's objection to `pointee` was not merely aesthetic: pointer terminology communicates a
  low-level model that is especially hostile to beginners.
- Claude revised from `pointee` to `value` after separating owner-level copied access from a property
  already scoped by the `MutableRef` type. Codex made the same revision. In
  `reference(at:).value`, the reference wrapper supplies the non-copying context.

## Scope correction

The borrowed-reference property was mistakenly treated as a project naming decision. Swift's
standard-library `MutableRef` already defines the dereferencing property as `value`; the project
does not own that spelling. The `pointee` / `value` scores remain here as a historical record of
the completed round, but they do not select, confirm, or reject a product API name.

How an earlier-toolchain compatibility implementation relates to the standard-library API is a
separate compatibility and implementation question. This report does not decide it.

## Decision handoff

- Confirm `OptionalElementBuffer`, yielding `OptionalElementBuffer`, `OptionalElementBuffer2D`,
  `OptionalElementBuffer3D`, and `OptionalElementBuffer4D` under the adopted suffix rule.
- No borrowed-reference property decision is handed off from this naming round.

# 名前持ちCodexによる `AGENTS.md` 再現性レビュー統合

## Task

- Registry ID: `OPS-032`
- Type: `DISCOVERY`
- Reviewers: Prime Codex、80ms Codex、V3オーサー、ChatGPT（チャッピー）
- Adoption authority: User

## Objective

4者が別々のreview表で行った再現性reviewを受け取り、Prime Codexが根拠を照合して統合する。
reviewer間の一致を正しさの証明にせず、現行文面、正本、観測事実、ユーザーの言葉、権限境界へ戻って確認する。

各reviewerは事前露出を記録し、他reviewerの回答を見ずに比較前第一稿を固定する。分離できるのは他reviewerの
回答からの影響であり、判断座標や既に受けた露出から独立したreviewではない。このtaskは座標系自体の正しさや、
共通資料に由来する相関した見落としがないことを証明しない。

既存Claudeレビューや主要所見へ露出済みのreviewerによる結果は、非seed再現性ではなく
`露出済みreviewerによる適用確認`として統合する。各所見の一致分類は、reviewer単位の露出記録を優先する。

この文書はreview依頼には使わない。各reviewerへは、その個体専用の一枚だけを渡す。

## Independent review tables

| Reviewer | Task request and return | Status |
| --- | --- | --- |
| Prime Codex | `AGENTS_MD_REVIEW_PRIME.md` | not started |
| 80ms Codex | `AGENTS_MD_REVIEW_80MS.md` | two review-design pre-reviews incorporated; exposed application review not started |
| V3オーサー | `AGENTS_MD_REVIEW_V3_AUTHOR.md` | two review-design pre-reviews incorporated; AGENTS review not started |
| ChatGPT（チャッピー） | `AGENTS_MD_REVIEW_CHATGPT.md` | not received |

## Integration table

4件を受領するまで評価欄を埋めない。

| Ref | `AGENTS.md`の対象 | Prime | 80ms | V3オーサー | ChatGPT | Evidence-based integration |
| --- | --- | --- | --- | --- | --- | --- |
| A | Startup / Orientation request | — | — | — | — | — |
| B | User-facing management boundary | — | — | — | — | — |
| C | SSoT / Agreement / Knowledge and Facts | — | — | — | — | — |
| D | Communication principles | — | — | — | — | — |
| E | Haskell-inspired reasoning | — | — | — | — | — |
| F | Goal relevance and proximity | — | — | — | — | — |
| G | Stable task IDs | — | — | — | — | — |
| H | Repository operation authority | — | — | — | — | — |
| I | Claude pending queue | — | — | — | — | — |
| J | Conversation reference IDs | — | — | — | — | — |
| K | Japanese input confirmations | — | — | — | — | — |
| L | Evaluation and impression records | — | — | — | — | — |
| M | Routine shorthand | — | — | — | — | — |
| N | Ownership boundaries | — | — | — | — | — |
| O | Xcode agent boundary | — | — | — | — | — |
| P | 文書全体 | — | — | — | — | — |

## Prime integration result

- Status: waiting for four reviews.
- Agreements supported by independent evidence:
- Matched findings not seeded by an assignment:
- Matched findings indirectly prompted by the schema or coordinates:
- Matched findings directly disclosed by an assignment or prior exposure:
- Shared assumptions without independent evidence:
- Material disagreements:
- Rules to keep:
- Repository facts to keep explicit:
- Missing state or evidence:
- Candidates to simplify or remove:
- Unknowns:
- User decisions required:
- Recommended next action:

統合時は、各findingの種類（`PRINCIPLE / FACT / STATE / EVIDENCE`）と判定
（`KEEP / SIMPLIFY / CONFLICT / MISSING / UNKNOWN`）を別々に扱う。一節全体の多数決は行わず、
一規則、一主張、一権限境界ごとに根拠と反証を照合する。

統合結果は`AGENTS.md`の変更承認ではない。変更、変更しない判断、または追加調査は別の受入境界とする。

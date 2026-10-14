# AGENTS.md 再現性レビュー — 80ms Codex

## Task

- Registry ID: `OPS-032`
- Reviewer: 80ms Codex
- Type: `DISCOVERY`
- この文書一枚を、このreviewerへのtask依頼兼return表とする。

## What this review can establish

同じ判断座標を渡されたreviewerが、事前露出を記録したうえで、既存Claudeレビューを再参照せずに
現行`AGENTS.md`をどう評価し直すかを記録する。他reviewerの回答からは分離するが、判断座標や既に受けた露出から
独立したreviewではない。

このreviewだけでは、座標系自体の正しさ、他の判断体系に対する優位性、座標系外の問題を十分発見できること、
または共通資料に由来する相関した見落としがないことを証明しない。

このreviewerは既存Claudeレビューと主要所見へ完全に露出済みである。この個体による実施は、
非seed再現性の検証ではなく、`露出済みreviewerによる適用確認`として扱う。

## Prior involvement and exposure

次をPhase 1開始前に記録する。

- 既存reviewへの露出。
- `AGENTS.md`、Orientation、関連規則の執筆・改訂への関与。
- 判断座標の成立への関与。
- 既知の事故や議論への参加。
- 事前に知っていた期待所見。

Known at assignment creation:

- `TASK_REGISTRY_STATE_HISTORY.md`のGit履歴調査と集計を行ったことが、ユーザーから確認されている。
- 既存Claudeレビューを全文読了している。
- ClaudeレビューのG-1〜G-4とR-1〜R-5を認識済みである。
- 採番状態、受入証拠、確定を開け直す条件を重要所見として評価済みである。
- `JUDGMENT_COORDINATES_DRAFT.md`と`JUDGMENT_COORDINATES_BUDDHISM_NOTE.md`を全文読了している。
- このreview表の旧版を評価し、期待される修正を提示する設計reviewを2回実施済みである。

Reviewer record:

- 

## Reproduction inputs

Phase 1開始前に、同じ入力を読んだか後から確認できる値を記録する。hash取得は読み取り操作として行い、
対象fileを変更しない。

- Started at:
- Reviewer/model or surface:
- Conversation context supplied before this task:
- HEAD:
- Worktree changes present at start:
- `AGENTS.md` content hash:
- `JUDGMENT_COORDINATES_DRAFT.md` content hash:
- This review table SHA-256 before Phase 1 response: fileを受け取った直後、reviewerが編集する前のUTF-8 bytesを計算する。値の記入後に完成fileと一致することは要求しない。


## Phase 1: pre-comparison evaluation

### Required reading

1. repository rootの現行`AGENTS.md`（評価対象）。
2. `JUDGMENT_COORDINATES_DRAFT.md`（評価基準）。

Phase 1を固定するまで、次を新たに読まない。

- `AGENTS_MD_COORDINATE_REVIEW.md`。
- 他reviewerのreview表。
- 統合表。

すでに読んでいる内容は忘れたふりをせず、Prior involvement and exposureへ書く。

### Boundary

- `AGENTS.md`、関連資料、Task Registryを変更しない。
- Orientationや草案を採用・失効させない。
- 新しい規則を安心のためだけに追加しない。
- UNKNOWNを推測で閉じない。

### Section index

これはfindingの単位ではなく、確認漏れを防ぐ索引である。期待所見は書かない。

| Ref | `AGENTS.md`の対象 | Checked |
| --- | --- | --- |
| A | Startup / Orientation request | — |
| B | User-facing management boundary | — |
| C | SSoT / Agreement / Knowledge and Facts | — |
| D | Communication principles | — |
| E | Haskell-inspired reasoning | — |
| F | Goal relevance and proximity | — |
| G | Stable task IDs | — |
| H | Repository operation authority | — |
| I | Claude pending queue | — |
| J | Conversation reference IDs | — |
| K | Japanese input confirmations | — |
| L | Evaluation and impression records | — |
| M | Routine shorthand | — |
| N | Ownership boundaries | — |
| O | Xcode agent boundary | — |
| P | 文書全体 | — |

### Finding schema

一つの規則、一つの主張、または一つの権限境界につき一件とする。同じsectionへ複数findingを書いてよい。

種類（複数可）:

- `PRINCIPLE`: 判断原理から導く対象。
- `FACT`: repository固有の事実または権限境界。
- `STATE`: 規則を実行するための永続状態。
- `EVIDENCE`: 主張を成立させる証拠または確定範囲。

判定:

- `KEEP`
- `SIMPLIFY`
- `CONFLICT`
- `MISSING`
- `UNKNOWN`

| Finding | 対象箇所・正確な主張 | 種類 | 判定 | 根拠の種類 | 根拠 | 反証候補 | 影響 | 最小変更方向または非変更理由 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
|  |  |  |  | 観測事実 / 正本の事実 / ユーザーの言葉 / reviewerの推論 |  |  |  |  |

### Reverse trace: coordinates to AGENTS.md

座標系が必要とする要素が`AGENTS.md`のどこで実装されているか、規則化不要か、欠落かを確認する。

| 座標または需要 | 実装箇所 | 規則化不要 / 実装済み / 欠落 / 不明 | 根拠 |
| --- | --- | --- | --- |
| 効果と取消可能性 |  |  |  |
| 持ち主と委任 |  |  |  |
| 知っている範囲と証拠 |  |  |  |
| 需要と目標への寄与 |  |  |  |

固定4行で終えず、座標系から必要な主張を抽出して行を追加する。大分類へ畳んだだけで確認済みにしない。

### Phase 1 conclusion

- Conclusion:
- Recommended changes:
- Reasons to preserve current text:
- Unknowns:

### Phase 1 freeze

- Completed at:
- Declaration: Phase 1をここで固定した / 未完了
- Phase 1 freeze SHA-256:
- Hash rule: UTF-8、改行LF。`## Phase 1: pre-comparison evaluation`の見出しからこのHash rule行までを対象とし、`Phase 1 freeze SHA-256:`の値部分は空文字として正規化する。後続の訂正、Phase 2、Phase 3は対象外。
- 以後Phase 1本文を修正しない。誤りは次の追記欄へ残す。

### Phase 1 corrections after freeze

- 

## Phase 2: provenance and evidence check

Phase 1固定後、必要な論点について次を役割どおりに読む。

- 来歴・導出確認: `EFFECT_GRADIENT_REFERENCE.md`、`MINIMAL_ORIENTATION_DRAFT.md`、`CHANGE_KNOWLEDGE_LAG_DRAFT.md`。
- 補助語彙: `JUDGMENT_COORDINATES_BUDDHISM_NOTE.md`。比喩の一致を規則の証拠にしない。
- 観測事実: 各資料が明示するGit履歴、Registry差分、具体的事故。必要な範囲だけ原資料へ戻る。

記録:

- Phase 1 findings supported:
- Phase 1 findings weakened or contradicted:
- New findings from provenance or observations:
- Claims still lacking independent evidence:
- Important findings for which supporting evidence was searched:
- Important findings for which counterevidence was searched:
- Searches not performed, and why:
- Findings checked one step deeper against Git history or a source diff:
- Corrections to Phase 1（元の記録は残す）:

## Phase 3: comparison with the existing Claude review

Phase 2後に`AGENTS_MD_COORDINATE_REVIEW.md`を再度開いて明示的に照合する。Phase 1と2を書き換えず、次を追記する。

- Matched findings not seeded by the assignment（このreviewerでは、Claudeレビューに存在するfindingは事前開示済みのため原則該当なし）:
- Matched findings indirectly prompted by the schema or coordinates:
- Matched findings directly disclosed by the assignment or prior exposure:
- Findings only in the Claude review:
- Findings only in this review:
- Disagreements and their evidence:
- Whether comparison changes the recommended direction:

一致の分類は次で固定する。

- `MATCH`: 対象となる規則または欠落と、原因の説明が同じ。推奨方向の違いは一致を妨げない。
- `PARTIAL`: 一方が他方を包含する、または対象は同じだが原因の説明が一部だけ一致する。
- `NO_MATCH`: 対象または原因が異なる。単に同じsectionへ言及しただけの場合を含む。
- `NOT_COMPARABLE`: 粒度または証拠範囲が異なり、安全に対応付けられない。

## Review-design pre-review record

- Reviewer: 80ms Codex。
- Subject: このtaskで使用するreview表の旧版2件。
- Incorporation: Prime Codexが指摘を判断し、review表と統合正本へ反映した。
- Scope: review方法の評価であり、`AGENTS.md`本文reviewの完了ではない。

受け入れて反映した指摘:

- 入力となる`AGENTS.md`、座標系、依頼票、開始worktree、reviewer条件を固定・記録する。
- Phase 1の具体例が既知所見をseedしていたため、具体名を除く。
- 一致を直接seed、間接prompt、非seedへ分ける。
- findingの一致、部分一致、不一致、比較不能を事前に定義する。
- 重要findingでは支持証拠と反証証拠の探索、および未実施を区別する。
- この80ms個体は既存Claudeレビューと主要所見へ完全に露出済みであり、非seed reviewerとして扱わない。
- Phase 1 freeze hashは、Phase 1だけを対象に値欄を空文字へ正規化して計算し、自己参照を避ける。

別taskとして扱い、今回へ混ぜなかった提案:

- 座標系なしの自由reviewと、座標系ありreviewを比較する対照実験。

これらに加え、G-1〜G-4、R-1〜R-5と主要所見はPhase 1開始前に80ms Codex自身が既知である。
同じ所見が本文reviewに現れても、非seedの独立発見とは数えない。

## Completion checklist

- [ ] Section indexを全件確認した。
- [ ] 各重要findingに対象箇所と根拠を記録した。
- [ ] 各重要findingについて反証候補を一度探した。
- [ ] 観測事実、正本の事実、ユーザーの言葉、reviewerの推論を分離した。
- [ ] UNKNOWNを無理に閉じていない。
- [ ] 座標系から`AGENTS.md`への逆向き照合を行った。
- [ ] 推奨変更がなくても非変更理由を説明した。
- [ ] Phase 1の完了時刻と固定宣言を記録した。
- [ ] 対象2文書とreview表の入力hash、reviewer条件、開始状態を記録した。
- [ ] Phase 2と3で得た知識をPhase 1へ逆流させていない。
- [ ] 一致を非seed、間接prompt、直接開示に分け、事前定義した基準で照合した。

## Completion

- Status: not started.
- Files changed: this review table only.
- No repository operation is authorized.

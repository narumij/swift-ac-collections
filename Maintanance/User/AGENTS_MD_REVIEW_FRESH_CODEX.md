# AGENTS.md 再現性レビュー — Fresh Codex

## Task

- Registry ID: `OPS-032`
- Reviewer: Fresh Codex
- Type: `DISCOVERY`
- この文書一枚を、このreviewerへのtask依頼兼return表とする。

## What this review can establish

新しいconversationのCodexが、現行`AGENTS.md`と判断座標だけを入力として、既存reviewとの比較前に
どの所見へ到達するかを記録する。

このreviewで確認できるのは、同じ判断座標を渡された未露出reviewerによる所見の再現性である。
座標系自体の正しさ、他の判断体系に対する優位性、座標系外の問題を十分発見できること、または
共通資料に由来する相関した見落としがないことは証明しない。

## Freshness gate

Phase 1の資料を読む前に判定する。次をすべて満たす場合だけ、`FRESH`としてPhase 1へ進む。

- このtaskのために開始された新しいconversationである。
- このconversationへ、既存reviewの本文、要約、結論、主要所見が与えられていない。
- reviewerは、このrepositoryの判断座標、既知事故、または既存reviewの成立過程へ過去に参加していない。
- reviewerは、下記のPhase 3 comparison setをまだ読んでいない。
- repositoryのstartup規則によるTask Registry確認など、避けられない事前露出をすべて記録できる。

一つでも満たさない場合は、他の資料を読まずに`NOT FRESH`として停止する。この個体を露出済みreviewerへ
転用する場合は、別の依頼票で扱い、この表のfresh review結果へ混ぜない。

- Freshness result: `FRESH / NOT FRESH / UNKNOWN`
- Reason:
- Checked at:

## Prior involvement and exposure

Phase 1開始前に、実際に知っていることだけを記録する。何もなければ「なし」と書く。

- 既存reviewへの露出:
- `AGENTS.md`、Orientation、関連規則の執筆・改訂への関与:
- 判断座標の成立への関与:
- 既知の事故や議論への参加:
- 事前に知っていた期待所見:
- Startup時に読んだTask Registryその他の内容:
- このtaskより前にconversationへ与えられた文脈:

## Reproduction inputs

Phase 1開始前に、入力と開始状態を記録する。hash取得は読み取り操作として行い、対象fileを変更しない。

- Started at:
- Reviewer/model or surface:
- HEAD:
- Worktree changes present at start:
- `AGENTS.md` content hash:
- `JUDGMENT_COORDINATES_DRAFT.md` content hash:
- This review table SHA-256 before Phase 1 response: fileを受け取った直後、reviewerが編集する前のUTF-8 bytesを計算する。値の記入後に完成fileと一致することは要求しない。

## Phase 1: fresh evaluation

### Required reading

1. repository rootの現行`AGENTS.md`（評価対象）。
2. `JUDGMENT_COORDINATES_DRAFT.md`（評価基準）。

Phase 1を固定するまで、上記2文書以外の判断座標関連資料、既存review、統合表を新たに読まない。
必要な事実が上記だけでは確定できない場合は、推測で補わず`UNKNOWN`またはPhase 2の確認事項として残す。

### Boundary

- `AGENTS.md`、関連資料、Task Registryを変更しない。
- Orientationや草案を採用・失効させない。
- 新しい規則を安心のためだけに追加しない。
- 観測できる事実を推測で代用しない。
- `UNKNOWN`を無理に閉じない。
- 既存reviewを探したり、ファイル名から内容を推測したりしない。

### Section index

これはfindingの単位ではなく、確認漏れを防ぐ索引である。各sectionを確認して`Checked`へ記録する。

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
- Questions deferred to Phase 2:

### Phase 1 freeze

- Completed at:
- Declaration: Phase 1をここで固定した / 未完了
- Phase 1 freeze SHA-256:
- Hash rule: UTF-8、改行LF。`## Phase 1: fresh evaluation`の見出しからこのHash rule行までを対象とし、`Phase 1 freeze SHA-256:`の値部分は空文字として正規化する。後続の訂正、Phase 2、Phase 3は対象外。
- 以後Phase 1本文を修正しない。誤りは次の追記欄へ残す。

### Phase 1 corrections after freeze

- 

## Phase 2: provenance and evidence check

Phase 1固定後、Phase 1で生じた確認事項に必要な範囲だけ、次を役割どおりに読む。

- 来歴・導出確認: `EFFECT_GRADIENT_REFERENCE.md`、`MINIMAL_ORIENTATION_DRAFT.md`、`CHANGE_KNOWLEDGE_LAG_DRAFT.md`。
- 補助語彙: `JUDGMENT_COORDINATES_BUDDHISM_NOTE.md`。比喩の一致を規則の証拠にしない。
- 観測事実: 各資料が示すGit履歴、Registry差分、具体的事故。重要findingは可能な範囲で原資料へ一段戻る。
- repository固有の事実: Task Registry、選択taskの詳細正本、その他の現行正本。Archived記録は現行権限の根拠にしない。

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

## Phase 2 freeze

- Completed at:
- Declaration: Phase 2をここで固定した / 未完了
- 以後Phase 2本文を修正しない。誤りはPhase 3の比較結果から分離して追記する。

### Phase 2 corrections after freeze

- 

## Phase 3: comparison with existing reviews

Phase 2固定後にだけ、次のcomparison setを読む。未完了の表は未完了として記録し、空欄を所見として扱わない。

- `AGENTS_MD_COORDINATE_REVIEW.md`
- `AGENTS_MD_REVIEW_80MS.md`
- `AGENTS_MD_REVIEW_CHATGPT.md`
- `AGENTS_MD_REVIEW_V3_AUTHOR.md`
- `AGENTS_MD_REVIEW_PRIME.md`
- このtaskに対応する統合表が存在する場合は、その表

Phase 1とPhase 2を書き換えず、finding単位で照合する。

- Matched findings not seeded before Phase 1:
- Matched findings indirectly prompted by the schema or coordinates:
- Matched findings directly disclosed before Phase 1:
- Findings only in existing reviews:
- Findings only in this review:
- Disagreements and their evidence:
- Whether comparison changes the recommended direction:
- Incomplete or non-comparable review files:

一致の分類は次で固定する。

- `MATCH`: 対象となる規則または欠落と、原因の説明が同じ。推奨方向の違いは一致を妨げない。
- `PARTIAL`: 一方が他方を包含する、または対象は同じだが原因の説明が一部だけ一致する。
- `NO_MATCH`: 対象または原因が異なる。単に同じsectionへ言及しただけの場合を含む。
- `NOT_COMPARABLE`: 粒度、証拠範囲、完了状態、または事前露出が異なり、安全に対応付けられない。

各一致について、対応するfinding、分類、seed区分、根拠を記録する。人数や一致数だけを証拠にしない。

## Completion checklist

- [ ] Freshness gateをPhase 1の資料を読む前に判定した。
- [ ] Prior involvement and exposureを具体的事実で記録した。
- [ ] Section indexを全件確認した。
- [ ] 各重要findingに対象箇所と根拠を記録した。
- [ ] 各重要findingについて反証候補を一度探した。
- [ ] 観測事実、正本の事実、ユーザーの言葉、reviewerの推論を分離した。
- [ ] `UNKNOWN`を無理に閉じていない。
- [ ] 座標系から`AGENTS.md`への逆向き照合を行った。
- [ ] 推奨変更がなくても非変更理由を説明した。
- [ ] 対象2文書とreview表の入力hash、reviewer条件、開始状態を記録した。
- [ ] Phase 1とPhase 2の完了時刻と固定宣言を記録した。
- [ ] 後続Phaseで得た知識を前のPhaseへ逆流させていない。
- [ ] 重要findingの支持証拠、反証証拠、未実施の探索を区別した。
- [ ] 一致を非seed、間接prompt、直接開示に分け、事前定義した基準で照合した。
- [ ] 未完了のreview表や比較不能な結果を、一致件数へ含めていない。

## Completion

- Status: not started.
- Files changed: this review table only.
- No repository operation is authorized.

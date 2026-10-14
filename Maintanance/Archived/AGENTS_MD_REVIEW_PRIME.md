# AGENTS.md 再現性レビュー — Prime Codex

## Task

- Registry ID: `OPS-032`
- Reviewer: Prime Codex
- Type: `DISCOVERY`
- この文書一枚を、このreviewerへのtask依頼兼return表とする。

## What this review can establish

同じ判断座標を渡されたreviewerが、事前露出を記録したうえで、既存Claudeレビューを再参照せずに
現行`AGENTS.md`をどう評価し直すかを記録する。他reviewerの回答からは分離するが、判断座標や既に受けた露出から
独立したreviewではない。

このreviewだけでは、座標系自体の正しさ、他の判断体系に対する優位性、座標系外の問題を十分発見できること、
または共通資料に由来する相関した見落としがないことを証明しない。

このreviewerは既存Claudeレビューと主要所見へ完全に露出済みであり、判断座標と関連運用の成立にも
関与している。この個体による実施は、非seed再現性の検証ではなく、
`露出済みreviewerによる自己適用確認`として扱う。

## Prior involvement and exposure

次をPhase 1開始前に記録する。

- 既存reviewへの露出。
- `AGENTS.md`、Orientation、関連規則の執筆・改訂への関与。
- 判断座標の成立への関与。
- 既知の事故や議論への参加。
- 事前に知っていた期待所見。

Known at assignment creation:

- 既存Claudeレビューを読了済み。
- 座標系資料の成立過程と本conversationの議論へ参加済み。
- ClaudeレビューのG-1〜G-4とR-1〜R-5を認識済み。
- 採番状態、受入証拠、確定を開け直す条件を主要所見として認識済み。
- 採番再利用、task差し戻し、および関連する運用議論へ露出済み。
- `AGENTS.md`と関連運用の執筆・改訂・受入に近い立場で関与しており、評価対象に対する自己reviewの性質を持つ。
- 個別review表と統合表の設計および内容へ露出済み。

Reviewer record:

- Prime Codex。既存Claudeレビューと主要所見へ完全に露出済みのため、自己適用確認として実施する。

## Reproduction inputs

Phase 1開始前に、同じ入力を読んだか後から確認できる値を記録する。hash取得は読み取り操作として行い、
対象fileを変更しない。

- Started at: 2026-10-14T17:01:36+0900
- Reviewer/model or surface: Prime Codex / Xcode
- Conversation context supplied before this task: 現conversation全文。既存Claudeレビュー、V3・80msによるreview-design review、判断座標の成立過程を含む。
- HEAD: `4e9c2a3f46d52329391927160b99afb59cdaee90`
- Worktree changes present at start: `AM Maintanance/AGENTS_MD_REVIEW_FRESH_CODEX.md`。他の変更はなし。
- `AGENTS.md` content hash: SHA-256 `9b495bcd38231d44aad3dcd4155101a6f3de8b83ab9362ab03819b47edddcf08`
- `JUDGMENT_COORDINATES_DRAFT.md` content hash: SHA-256 `3ad6cb16e1c182addaf25065379c2d8b65033c9ed89c7b1f87c296a3f3714edc`
- This review table SHA-256 before Phase 1 response: `29187ada4b10be2e2d5ce742ce84c31ee38b199b607b441e79af4a6cc8a3c6c3`。fileを受け取った直後、reviewerが編集する前のUTF-8 bytesを計算した。値の記入後に完成fileと一致することは要求しない。


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
| A | Startup / Orientation request | checked |
| B | User-facing management boundary | checked |
| C | SSoT / Agreement / Knowledge and Facts | checked |
| D | Communication principles | checked |
| E | Haskell-inspired reasoning | checked |
| F | Goal relevance and proximity | checked |
| G | Stable task IDs | checked |
| H | Repository operation authority | checked |
| I | Claude pending queue | checked |
| J | Conversation reference IDs | checked |
| K | Japanese input confirmations | checked |
| L | Evaluation and impression records | checked |
| M | Routine shorthand | checked |
| N | Ownership boundaries | checked |
| O | Xcode agent boundary | checked |
| P | 文書全体 | checked |

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
| P1 | 文書全体は、需要、効果、持ち主、証拠という座標を、startup、権限、関連性、確認、委任停止へ具体化している | PRINCIPLE / FACT | KEEP | reviewerの推論 | 座標系の4問がB・C・F・H・Nへ対応し、固有経路はA・I・J・K・L・Oに分離されている | 固有規則が多すぎれば原理を隠す | 原理だけでは決められないrepository固有の持ち主と経路を失わない | 固有事実を削らず、重複が判明した場合だけ参照へ寄せる |
| G1 | Stable task IDの不変契約はあるが、Archivedを含む使用済みID集合または次番号という永続状態の所在がない | FACT / STATE | MISSING | 正本の事実 / reviewerの推論 | 「Never rename, renumber, or reuse」は契約を定めるが、採番根拠を指していない | Registry外の別機構が正本として存在する可能性 | 見えている現行行から推定すると再利用禁止を実行できない | 契約は維持し、採番状態の唯一の所在を短く参照する |
| M1 | Routineの受入は「acceptance conditionsを満たす」とするが、成立させる主張、証拠、保証範囲の記録条件がない | EVIDENCE | MISSING | reviewerの推論 | test成功、CI成功、レビュー結果は異なる範囲しか確定しない | 詳細正本のacceptance欄が常に十分ならAGENTSでの追加は不要 | 手前の輪の証拠で外側まで完了扱いし得る | Routineに、詳細正本で主張・証拠・保証範囲を確認する一文だけ足す |
| B1 | ユーザー介入は委任を停止し、影響範囲を確認して明示的再許可まで状態変更を止める | PRINCIPLE / FACT | KEEP | 正本の事実 | 委任の取消と介入後の停止条件が明記される | 小さな無関係編集まで全作業停止と読む余地 | 介入で失われた占有を勝手に取り戻さない | `affected work`への限定を維持する |
| B2 | 受入済み・完了済みの確定を開け直す主体、条件、依存先への説明責任が明示されていない | FACT / STATE / EVIDENCE | MISSING | reviewerの推論 | 介入による実行中委任の停止はあるが、共有済み確定の差し戻しは扱わない | Registryや詳細正本に一貫した差し戻し規則がある可能性 | 確定を書き換える効果が依存先へ伝播せず、状態だけ戻り得る | 持ち主による差し戻し、理由・影響・再受入条件の記録先を参照する |
| H1 | repository operationは個別の直前許可を要求する一方、Routineは一回のshorthand内に最大2回のcommitを含む | FACT | CONFLICT | 正本の事実 / reviewerの推論 | Hは各commitごとの直前許可、MはRoutine要求をcommitを含むcycleとして定義する | `ルーティーン`自体を全commitへの個別明示許可と解釈できる可能性 | 許可の個数と時点がreviewerごとに揺れる | Routineがcommitを許可する範囲を明記するか、各commit前の別許可を要求すると明記する |
| O1 | Xcodeで別Codexへ渡すassignmentを`WORKER_TASK.md`へ固定しているが、現在の名前持ちreviewは個別task兼return表を使う | FACT | CONFLICT | 観測事実 / 正本の事実 | Oは「must write ... WORKER_TASK.md」と限定し、現在の認可taskはreviewer別ファイルを指定する | 名前持ちreviewerはWorker Codexではなく、この規則の対象外という読み | 同じ安全なfile handoffがファイル名だけで違反扱いになる | 目的を保ち、Registryが指定した一個体専用のbounded task/return fileも許す |
| C1 | 合意と証拠、knowledgeとfactsを分離し、不足時にUNKNOWNを保つ | PRINCIPLE | KEEP | 正本の事実 | Cは合意を証拠にせず、Dは推論と事実を区別する | 運用schemaがなければ宣言に留まる | 複数reviewerの一致を正しさへ昇格させない | 現文を維持し、具体的schemaはtask側に置く |
| D1 | 内容修正と着手権限を分離する | PRINCIPLE / FACT | KEEP | 正本の事実 | correctionは実行許可を含まないと明記 | 小変更でも確認が増える可能性 | 内容の同意を権限の譲渡と誤認しない | 権限差が結果へ影響する場合に限定する現文を維持 |
| F1 | 需要をtask readinessから分離し、現ゴールへの寄与でLATER/OUTSIDEを除外する | PRINCIPLE / STATE | KEEP | 正本の事実 | proximityは優先順位でなく選択lensと明記 | proximity分類自体が管理負荷になる | readyな不要taskの着手を防ぐ | 数値化せず定性的に使う現文を維持 |

### Reverse trace: coordinates to AGENTS.md

座標系が必要とする要素が`AGENTS.md`のどこで実装されているか、規則化不要か、欠落かを確認する。

| 座標または需要 | 実装箇所 | 規則化不要 / 実装済み / 欠落 / 不明 | 根拠 |
| --- | --- | --- | --- |
| 効果と取消可能性 | Repository operation authority、User-facing management boundary | 実装済み | 履歴・外部操作を個別に扱い、介入後の停止を定める |
| 持ち主と委任 | User-facing management boundary、Ownership boundaries、Claude pending、Xcode agent boundary | 一部衝突 | policyとoperation、Codex・Claude・Workerの持ち物は分かれるが、O1のhandoff file限定が現taskと衝突する |
| 知っている範囲と証拠 | Agreement is not evidence、Knowledge and Facts、Communication principles | 一部欠落 | 原理は実装済み。Routine受入の証拠範囲はM1のとおり不足する |
| 需要と目標への寄与 | Goal relevance and proximity、Routine shorthand | 実装済み | need/proximityをtask選択前に評価する |
| 着手権限 | Communication principles、Stable task IDs、Japanese input confirmations | 実装済み | 内容変更と開始許可を分離し、FROZEN・USER_ONLYの開始条件を固定する |
| 確定を開け直す条件 | User-facing management boundary | 欠落 | 実行中委任の停止はあるが、完了・受入済み状態の差し戻しはB2のとおり未定義 |
| 識別子契約を守る状態 | Stable task IDs | 欠落 | 不変契約はあるが、採番状態の所在はG1のとおり未定義 |
| 純粋な判断と副作用 | Haskell-inspired reasoning、Repository operation authority | 実装済み | 調査・判断とbranch/commit/pushを異なる効果として扱う |

固定4行で終えず、座標系から必要な主張を抽出して行を追加する。大分類へ畳んだだけで確認済みにしない。

### Phase 1 conclusion

- Conclusion: 判断座標の主要部分は現行`AGENTS.md`へ実装されている。主要な不足は原理ではなく、識別子を守る永続状態、受入証拠の保証範囲、確定を開け直す条件である。加えてRoutineのcommit許可とXcode handoff fileに局所的な衝突がある。
- Recommended changes: G1・M1・B2を参照で補い、H1の許可範囲を一意にし、O1を安全性の目的を保った一般形へ直す。KEEP所見の原理や固有事実は削らない。
- Reasons to preserve current text: startup、SSoT、合意と証拠、需要、委任停止、固有handoff経路は、座標系だけから推測できない運用事実を保持している。
- Unknowns: 採番状態の既存正本の有無、各詳細正本のacceptance記述の充足度、Routine発話が複数commitを許可するというユーザー意図、名前持ちCodexがXcode agent boundaryの「another Codex」に含まれるか。

### Phase 1 freeze

- Completed at: 2026-10-14T17:03:30+0900
- Declaration: Phase 1をここで固定した
- Phase 1 freeze SHA-256: `6e5e47239741f330ecf84d8375382901d34d498347dada5e58fb738d622c2a27`
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

- Phase 1 findings supported: G1は`CHANGE_KNOWLEDGE_LAG_DRAFT.md`の履歴調査（別内容への7番号再利用、10件すべてが現行表示上の最大番号+1、最後の番号は記憶だけ）で支持された。B2は座標草案の「確定は捨」と4件のDONE差し戻しで支持された。H1は`ae5d000f`のRoutine導入本文と、V4 playbookの「別途必要な権限を拡張しない」の併存で支持された。O1は現行taskが個別review表を正式なtask兼return表として使う観測で支持された。
- Phase 1 findings weakened or contradicted: M1の証拠確認自体はV4 playbook 7節に「成果物、差分、実行条件、test結果、反証、残る不確実性」と具体化されているため、repository全体での完全な欠落ではない。問題はAGENTS内のRoutineが下位手順を参照せず不完全に重複している点へ狭まる。O1は「名前持ちCodexはWorkerではない」と対象外に読む余地が残り、衝突の確定範囲はUNKNOWNを含む。
- New findings from provenance or observations: `ルーティーン`は当初、ユーザーの一語で検収・commit・次task化を委ねる意図だったという記録がある一方、現行V4 playbookはRoutineがcommit権限を拡張しないとする。H1は単なる文面曖昧さではなく、運用意図と現行規則の差でもある。
- Claims still lacking independent evidence: 名前持ちCodexをXcode agent boundaryの「another Codex」から除外する意図。使用済みID集合または次番号を保持する未発見の正本が存在しないことの完全証明。確定の差し戻しを一貫して処理する別の現行規則の不存在。
- Important findings for which supporting evidence was searched: G1は採番・最後の番号・Git履歴、M1はV4 playbookの受入節、B2は差し戻し事例、H1はRoutine導入commitと現行playbook、O1は現行task構造とWorker文書を確認した。
- Important findings for which counterevidence was searched: M1についてV4 playbookに具体的証拠schemaを発見した。O1についてWorker専用という限定解釈を検討した。H1についてユーザーの一語によるcommit委任記録を確認したが、現行playbookの非拡張規則との優先関係は解消しなかった。
- Searches not performed, and why: 全Archived記録の網羅走査、全taskのacceptance品質の統計、全差し戻し事例の再監査は、今回の文面reviewに対して過剰なので実施しなかった。
- Findings checked one step deeper against Git history or a source diff: H1は`ae5d000f`の`AGENTS.md`導入差分まで確認した。G1とM1/B2は来歴草案が示すcommit・Registry差分調査の要約と現行文面を照合したが、全commitを再集計していない。
- Corrections to Phase 1（元の記録は残す）: M1の判定は「repository全体でMISSING」ではなく、「AGENTSのRoutine記述がV4 playbookの証拠条件を参照せず不完全に重複しているためSIMPLIFY」がより正確。Phase 2の横断検索が`AGENTS_MD_COORDINATE_REVIEW.md`の一致行を表示し、予定より早く既存reviewを再参照した。Phase 1は既に固定済みで変更していないが、Phase 2とPhase 3の時間的分離はこの検索時点で崩れたため、比較証拠の独立性を追加で主張しない。

## Phase 3: comparison with the existing Claude review

Phase 2後に`AGENTS_MD_COORDINATE_REVIEW.md`を再度開いて明示的に照合する。Phase 1と2を書き換えず、次を追記する。

- Matched findings not seeded by the assignment（このreviewerでは、Claudeレビューに存在するfindingは事前開示済みのため原則該当なし）: なし。
- Matched findings indirectly prompted by the schema or coordinates: なし。Claude reviewのfindingはすべてprior exposureによる直接開示として扱う。
- Matched findings directly disclosed by the assignment or prior exposure: G1↔Claude G-1は`MATCH`。B2↔Claude G-4は`MATCH`。M1↔Claude G-2は`PARTIAL`（対象と原因は同じだが、PrimeはV4 playbookの部分実装を確認して欠落範囲を狭めた）。P1/C1/D1/F1↔Claude各節評価・R-1〜R-3は`MATCH`だが、いずれも既知所見の再構成である。
- Findings only in the Claude review: G-3「決断の持ち主はあるが理由がない」。Primeは規則として足り、AGENTSへ理由を増やす必要が薄いというClaude自身の結論に同意し、独立findingにはしなかった。
- Findings only in this review: H1「Routineの一語とcommitごとの直前許可の衝突」。O1「Xcode handoffを`WORKER_TASK.md`へ固定する規則と、正式なreviewer別task/return表の衝突」。
- Disagreements and their evidence: Claude G-2は受入証拠の書き方がないとするが、V4 playbook 7節には成果物・差分・実行条件・test・反証・残余不確実性の照合がある。よってAGENTS単体では不足するもののrepository全体の完全欠落ではなく、`PARTIAL`とした。ClaudeはXcode agent boundaryを単に固有事実としたが、現行の名前持ちreview taskとの整合は評価していないため、O1は矛盾ではなく追加観測である。
- Whether comparison changes the recommended direction: G1とB2の方向は変えない。M1は新規規則追加ではなく、AGENTSのRoutineをV4 playbookへ正しく接続して重複を減らす方向へ狭める。H1とO1は既存Claude reviewにないため、統合時に別findingとして証拠を再確認する。

一致の分類は次で固定する。

- `MATCH`: 対象となる規則または欠落と、原因の説明が同じ。推奨方向の違いは一致を妨げない。
- `PARTIAL`: 一方が他方を包含する、または対象は同じだが原因の説明が一部だけ一致する。
- `NO_MATCH`: 対象または原因が異なる。単に同じsectionへ言及しただけの場合を含む。
- `NOT_COMPARABLE`: 粒度または証拠範囲が異なり、安全に対応付けられない。

## Completion checklist

- [x] Section indexを全件確認した。
- [x] 各重要findingに対象箇所と根拠を記録した。
- [x] 各重要findingについて反証候補を一度探した。
- [x] 観測事実、正本の事実、ユーザーの言葉、reviewerの推論を分離した。
- [x] UNKNOWNを無理に閉じていない。
- [x] 座標系から`AGENTS.md`への逆向き照合を行った。
- [x] 推奨変更がなくても非変更理由を説明した。
- [x] Phase 1の完了時刻と固定宣言を記録した。
- [x] 対象2文書とreview表の入力hash、reviewer条件、開始状態を記録した。
- [x] Phase 2と3で得た知識をPhase 1へ逆流させていない。Phase 2の検索でPhase 3資料の抜粋が早期表示された事実は訂正欄へ記録した。
- [x] 一致を非seed、間接prompt、直接開示に分け、事前定義した基準で照合した。

## Completion

- Status: complete as an exposed-reviewer self-application check.
- Files changed: this review table only.
- No repository operation is authorized.

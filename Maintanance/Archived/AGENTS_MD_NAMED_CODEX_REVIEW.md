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
| Prime Codex | `AGENTS_MD_REVIEW_PRIME.md` | complete; exposed self-application check |
| 80ms Codex | `AGENTS_MD_REVIEW_80MS.md` | complete; exposed application review |
| V3オーサー | `AGENTS_MD_REVIEW_V3_AUTHOR.md` | complete; exposed application review |
| ChatGPT（チャッピー） | `AGENTS_MD_REVIEW_CHATGPT.md` | complete; attached-file review, repository history not independently checked |

## Integration table

4件を受領した。表は節単位の索引であり、最終判断は下のfinding単位の統合を優先する。

| Ref | `AGENTS.md`の対象 | Prime | 80ms | V3オーサー | ChatGPT | Evidence-based integration |
| --- | --- | --- | --- | --- | --- | --- |
| A | Startup / Orientation request | KEEP | KEEP | KEEP | KEEP | Registry-firstと明示orientationを維持 |
| B | User-facing management boundary | KEEP / reopening不足 | KEEP / reopening不足 | KEEP / reopening不足 | KEEP / reopening UNKNOWN | 委任停止は維持。確定を開け直す境界は別finding |
| C | SSoT / Agreement / Knowledge and Facts | KEEP | KEEP | KEEP | KEEP | 合意を証拠にせず、UNKNOWNを残す原理を維持 |
| D | Communication principles | KEEP | KEEP | KEEP | KEEP | 内容修正と着手権限の分離を維持 |
| E | Haskell-inspired reasoning | KEEP | KEEP | KEEP | KEEP | 必要に応じる比喩であり、証拠や権限にしない |
| F | Goal relevance and proximity | KEEP | KEEP | KEEP | KEEP | 需要とpriorityを分ける現文を維持 |
| G | Stable task IDs | state不足 | state不足 | state不足 | state不足 / repo未確認 | 不変契約は維持し、採番状態を別途成立させる |
| H | Repository operation authority | RoutineとCONFLICT | RoutineとCONFLICT | Routineとの関係UNKNOWN | clarity risk | 個別直前許可は維持。Routineとの関係を一意化する |
| I | Claude pending queue | KEEP | KEEP | KEEP | KEEP | 仮置きと正本を分ける固有経路として維持 |
| J | Conversation reference IDs | KEEP | KEEP | KEEP | KEEP | 一時座標と永続IDの分離を維持 |
| K | Japanese input confirmations | KEEP | KEEP | KEEP | KEEP | 入力環境と一行為許可の固有事実として維持 |
| L | Evaluation and impression records | KEEP | KEEP | KEEP | KEEP | 記録先の固有事実として維持 |
| M | Routine shorthand | evidence不足 / commit衝突 | evidence不足 / commit衝突 | evidence不足 / commit UNKNOWN | evidence不足 / clarity risk | V4 playbookの部分実装へ接続し、commit許可を明確化 |
| N | Ownership boundaries | KEEP | KEEP | KEEP | KEEP | 原理から推測できない持ち主の表として維持 |
| O | Xcode agent boundary | handoff path衝突 | KEEP | KEEP | KEEP | Primeだけの追加所見。名前持ちreviewとWorkerの適用範囲を確認 |
| P | 文書全体 | 大半KEEP | 大半KEEP | 大半KEEP | 大半KEEP | 規則の大量追加ではなく、状態・参照・局所衝突を扱う |

## Prime integration result

- Status: complete. 4件を統合したが、全reviewerが既存議論またはClaude reviewへ露出しているため、blindな独立再現とは扱わない。
- Agreements supported by independent evidence: reviewer間の合意自体には独立証拠性がない。採番状態の不足はGit・Registry履歴、受入範囲は`PERM-029`と`OPT-070`、Routineの緊張は現行`AGENTS.md`とV4 playbook本文で別途支持される。
- Matched findings not seeded by an assignment: Routineに含まれる最大2回のcommitと、各commit直前の個別許可の関係が4者で一致した。Claude主要所見にも依頼票の期待結論にもなかった。ただし共通文面を読んだ相関した評価であり、一致だけを証拠にしない。
- Matched findings indirectly prompted by the schema or coordinates: 各節のKEEP評価、需要・効果・持ち主・証拠への対応。座標系の適用再現性は示すが、座標系自体の正しさは示さない。
- Matched findings directly disclosed by an assignment or prior exposure: 採番状態（Claude G-1）、受入証拠の範囲（G-2）、確定を開け直す条件（G-4）、需要段階・介入停止・着手権限（R-1〜R-3）。一致は既知所見の再構成能力として扱う。
- Shared assumptions without independent evidence: 座標系が実際のAI判断を改善すること、採番状態がrepository内のどこにも存在しないこと、確定差し戻しの新規規則が必要であること。
- Material disagreements: 受入証拠はAGENTS単体では不足するがV4 playbookに一部実装済みで、完全欠落ではない。確定の開け直しはPrime・80ms・V3がMISSING寄り、ChatGPTは既存所有規則で足りる可能性を残してUNKNOWN。RoutineはPrime・80msがCONFLICT、V3はUNKNOWN、ChatGPTはclarity risk。Xcode handoff path衝突はPrimeだけの所見。
- Rules to keep: Registry-first、SSoT、合意と証拠の分離、観測してから聞く、内容と着手権限の分離、需要とpriorityの分離、stable ID契約、操作別権限、仮置きqueue、会話ID、日本語入力、評価記録、委任停止、ownership boundary。
- Repository facts to keep explicit: ユーザー・Prime・Claude・Workerの持ち物、repository operationの担当、Xcodeのfile handoff、固有の記録先。これらは座標系から推測しない。
- Missing state or evidence: 使用済みtask IDまたは次番号の永続状態。DONE時の確定主張・証拠範囲・残る保留を辿れる契約は、V4 playbookの既存受入規則へどう接続するかが不足する。
- Candidates to simplify or remove: 原理や固有事実の一括削除候補はない。AGENTSのRoutineをV4 playbookへ参照接続して不完全な重複を減らすこと、Xcode handoffの安全要件を固定ファイル名から分離することは簡素化候補。
- Unknowns: 採番状態の正本配置、既存所有規則だけで確定差し戻しを十分扱えるか、名前持ちCodexがXcode boundaryの`another Codex`に含まれるか。
- User decisions required: (1) `ルーティーン`が列挙されたcommitを許可するか、各commit直前に別許可を要するか。(2) 確定を開け直す条件をAGENTSへ明記するか、既存所有規則から導くか。(3) Xcodeの個別review票をWorker handoffの例外または一般形として認めるか。採番状態の配置場所は、仕組みの設計後にユーザーが決める。
- Recommended next action: AGENTSを直ちに編集しない。三つのユーザー判断を一件ずつ確定し、採番状態と受入記録は既存正本・V4 playbookとの重複を避けて実装taskへ分ける。Fresh Codex票は今回へ混ぜず、座標系の非露出対照実験を行う場合の別task候補として残す。

統合時は、各findingの種類（`PRINCIPLE / FACT / STATE / EVIDENCE`）と判定
（`KEEP / SIMPLIFY / CONFLICT / MISSING / UNKNOWN`）を別々に扱う。一節全体の多数決は行わず、
一規則、一主張、一権限境界ごとに根拠と反証を照合する。

統合結果は`AGENTS.md`の変更承認ではない。変更、変更しない判断、または追加調査は別の受入境界とする。

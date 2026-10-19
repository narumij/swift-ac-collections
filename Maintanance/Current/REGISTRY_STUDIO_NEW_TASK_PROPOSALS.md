# Studioから新規タスク案を追加する

## TL;DR（人間向け）

Studioで正式登録前のタスク案を追加・編集・接続・取消し、保存してAIへ渡す機能の依頼と受入記録。Astra受入では独立検査と操作スモークの成功を確認している。正式採番・正本反映・着手許可は別で、Safari実表示と実ダウンロードは未確認。

2026-10-18 / OPS-081 / Astra, parent OPS-048. Hime implements/verifies; Astra accepts. Based on user requests 「見取り図か独立タスクに限定だけど、新規追加していきたい」「姫に依頼を」. Input follows OPS-080 acceptance commit 73afe42f; record full starting SHA and differences in Return.

<a id="目的確定範囲"></a>
## Purpose and confirmed scope

Let users create general-task proposals in Studio and arrange/discuss them in the independent area or dependency map. These precede formal numbering/registration and do not automatically change existing task meaning or authority.

- 「タスク追加」 accepts a required title and optional note.
- Add independently or select connections for the map, including proposal-to-proposal links. Reuse direction/cycle rejection and unset/awaiting-discussion condition handling.
- Generate provisional IDs in a separate noncolliding namespace from formal task/milestone IDs; retain them through edit/save/load. Do not formally number or update Registry counters.
- Label provisional tasks 「追加案」 and align card/selection/inspector behavior. Permit title/note correction and cancellation without leftover edges.
- Save proposals/connections in result JSON for AI handoff; baseline stays original formal data. Do not invent canonical links.

Exclude new permanent tasks/milestones, broader editing of existing items/conditions, direct server writes to Registry and AI automatic numbering/execution.

<a id="作業内訳と編集範囲"></a>
## Breakdown and editing scope

Write a short implementation breakdown here first. Inspect current save/reload/validation paths and choose a minimal representation documented in README. Support existing JSON without mistaking the new form for old; distinguish schema explicitly if necessary.

Editable: RegistryApp/index.template.html, verify.cjs, bounded save/load/generation consistency changes such as sync.py, README, this breakdown/Return and Evidence/OPS-081/. No actual Registry/Rules/DESIGN/milestones/product changes. Formal numbering/canonical creation belongs to the coordinator when the user hands over JSON.

<a id="取込手順に追加する内容"></a>
## Additions to import procedure

Importing AI recomputes differences from baseline/edit result and separates new proposals, existing changes and deletions. Check duplicates/intent, assign IDs under current numbering rules and create canonicals. Map provisional→formal IDs across all connections together, leaving no unresolved references. Discuss unsettled conditions. Retain mapping in import records to prevent double registration on resend. Unimported proposals are neither formal tasks nor execution permission.

<a id="検証完了条件"></a>
## Verification and completion

- Check independent/map additions, permitted connections to proposals/tasks/milestones, selection and title/note editing.
- Reject provisional-ID duplication, self-links, cycles and missing endpoints. Do not blanket-disable existing fixed-ID/unapproved-formal-task protections to accommodate proposals.
- Save/reload retains provisional IDs/notes/connections/awaiting-discussion state and baseline. Cancellation leaves no remnants. Existing-only JSON still works.
- Update/regeneration must not silently erase unsaved proposals; preserve existing unsaved-change protection.
- Existing verify/sync/--check pass. Run operation smoke and compare output JSON; note Safari nonverification.

Return options/impact and stop if out-of-scope decisions or major migration are needed. No incidental repairs. Record/clean artifacts under COMMONS. Return full input SHA, changes, checks, unknowns and artifacts; organize functional diff/evidence/records for review. No commit/external permission.

Assignment completion hands the output scope to Hime; Astra does not edit it until return.

## 作業内訳（姫記入）

2026-10-18 / 姫・Opus 5.5。入力`73afe42fa`以降。

1. **データ表現**：追加案を`doc.proposals=[{id,title,memo}]`として正式taskとは別の配列で持つ。`doc.tasks`へは入れないので、「task追加・削除は扱わない」検査はそのまま残す。
   - 仮IDは`draft-N`。正式IDは大文字で始まるので名前空間が分かれる。task・到達点との衝突も検査する。
   - 接続は既存の`edges`・`milestoneRelations`に入れ、条件は`相談待ち`で残す。
   - baselineには追加案を入れない。`schemaVersion`は1のまま、`proposals`は任意欄とする。
2. **検査（`check`）**：追加案の形（ID形式・重複・衝突・タイトル必須）を確かめる。追加案を節点に含めたグラフで、参照・自己接続・循環を確かめる。baselineに追加案があれば拒む。
3. **純粋なデータ操作**：`addProposal`・`updateProposal`・`removeProposal`（接続ごと消す）・`addProposalEdge`。`addMilestoneRelation`は追加案も受ける。どれも複製に変更してから`check`を通して返す。
4. **差分**：`delta()`に`proposals`を出す。保存JSONの`changes`に入る。
5. **画面**：
   - 独立タスク欄に「タスク追加」ボタンと入力ダイアログを置く（タイトル・メモ・置き場所：独立／到達点へ／既存taskの前提に）。
   - 追加案は独立欄と見取り図に「追加案」の帯と点線の枠で出し、正本リンクは付けない。
   - 選ぶと専用の編集欄が出る（タイトル・メモ訂正、取消、前提・後続・到達点・STARTの接続）。
6. **検証**：verifyに上の操作の合格・拒否、保存→再読込の往復、取消で残骸がないこと、既存編集だけのJSONの維持を足す。stub DOMでのスモークテスト、sync・`--check`も行う。
7. **README・Return・Evidence**。

範囲外：正式採番、恒久task・到達点の新規作成、既存taskの項目・条件の編集、Registryへの書込み。

## Return（姫記入）

2026-10-18 / 姫・Opus 5.5。入力`73afe42fa4e5dc69565e62ab8c4e3beb78fc0670`（着手時HEAD、差分なし）。

作業ツリーの他者分には触れていない：`Milestones/DESIGN.md`（ユーザー）、`CLAUDE_TASK.md`・Registry・Rules・`TASK_REGISTRY_APP.md`（Astra）。本書は作業内訳とReturnだけを書いた。

**変更**（`index.template.html`・`verify.cjs`・`README.md`。`sync.py`は変更不要だった）：

1. データ表現・検査：上の作業内訳1〜4のとおり。
   - `check`は、追加案を節点に含めたグラフでtask依存・到達点接続を検査する。正式taskの追加を拒む検査、baselineの検査は変えていない。
   - `addMilestoneRelation`は追加案も受ける。
   - つなぎ替えダイアログの候補に追加案を入れた。
2. 画面：
   - 独立タスク欄に「タスク追加」ボタンと案内文を置いた。追加ダイアログ（`proposalDialog`）を足した。
   - 追加案は独立欄・見取り図に「追加案」の帯・点線で出し、正本リンクは付けない。
   - 選ぶと追加案用の編集欄（`proposalEditor`）が出る。タイトル・メモの適用、取消、前提・後続・到達点/STARTの追加と削除ができる。
3. README：
   - 「タスク追加（追加案、OPS-081）」節（データ表現・仮ID・接続・保存・未保存保護）を足した。
   - 「AIがJSONを取り込むとき」に7項目めとして追加案の取込手順を足した（本書の「取込手順に追加する内容」に沿う）。

**検証**：
- `verify.cjs`に追加案の検査を1行足した。
  - 通るもの：独立・到達点・START・task・案同士の接続。
  - 拒むもの：自己接続・循環・存在しない端点・重複・形式違い・既存IDとの衝突・baselineに入れた追加案・正式taskの追加。
  - 往復・取消：保存→再読込が同値、タイトル/メモ訂正、取消で`edges`・`milestoneRelations`がbaselineに戻り`proposals`欄も消える（`delta`は0件）。既存編集だけのJSONは`proposals`を出さない。
- PASS行は24→25（旧verifyも同じ配置で24行）。
- `sync.py`成功、`--check`でずれなし。
- 操作スモークテスト`Evidence/OPS-081/smoke.cjs`：生成された`index.html`の本物のスクリプトを、最小のDOM stubの上で動かした。
  - ダイアログで独立案を追加し、独立欄に出て正本リンクがないことを確かめた。
  - 2件目を未完了のENDへつないで追加し、見取り図に描かれることを確かめた。
  - 編集欄でタイトル・メモを訂正し、案→案の後続線を足した。逆向きは循環として拒否され、データが変わらないことを確かめた。
  - 保存JSON（`changes`に`proposals`、baselineに追加案なし）→読込で同値。両方を取り消して残骸がないことを確かめた。
  - 結果：PASS。
- Safari・実ブラウザでの表示とクリック、実際のダウンロード、点線の見え方は未確認。

**旧Studioとの関係**：追加案に線があるJSONを旧版で開くと、参照先不正として明示的に拒まれる。線のない追加案は旧版では表示されないが、`proposals`欄はそのまま保存される（消えない）。`schemaVersion`は上げていない。

**未確認・残課題**：
- 正式taskの「前提タスク」選択欄には追加案を出していない。追加案の側の「後続」から既存taskへつなぐ。
- 恒久task・到達点の新規作成、既存taskの項目・条件の編集は対象外のまま。

**作業物**：一時ファイルは作っていない。PASS比較用の旧verifyの一時コピーは削除済み。`smoke.cjs`は証拠として残す（再実行：`node Maintanance/Current/Evidence/OPS-081/smoke.cjs`）。

commitはしていない。

<a id="astra受入2026-10-18"></a>
## Astra acceptance (2026-10-18)

Accepted under 「こみっとして、うけいれしてこみっと」. Review HEAD `cf8547b5`; scope is Hime's uncommitted changes and this assignment's registration record. Preserve original Return.

- Compared representation separating proposals from formal tasks, baseline retention, invalid-reference/cycle rejection and connection removal on cancellation against code/tests.
- Independent sync/verify 25 PASS, no bundled documents missing. Operation smoke (independent proposal, END connection, proposals interconnected, edit, save/reload, cancellation) PASS; `--check` matched.
- Initial sync stopped because Astra's preceding Milestones README edit removed a sentence the generator searches as source. Restored compatible original wording and reran successfully; distinguish from Hime's implementation defects.
- Safari display/actual download unverified. Retain the limitation that old Studio cannot display independent proposals; use a compatible Studio. Formal numbering/canonical application/start permission is not part of this feature.
- DONE under user commit permission. No additional assignment.

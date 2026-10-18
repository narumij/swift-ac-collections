# 前提・後続にマイルストーンを選ぶ接続操作

## TL;DR（人間向け）

正式task・追加案の前提と後続へ中間マイルストーンを選べるようにし、矢印方向を保存・再開でも保つ操作を追加した記録。SPIから追加案への接続などを隔離データと独立試験で受け入れ、完了した。実Inboxは変更せず、END・版ゲート等の制限を保持し、Safari実表示は未確認。

2026-10-18 / OPS-084 / parent OPS-048. Astra authored/accepted; Hime implemented/verified.

<a id="目的ユーザー指示"></a>
## Purpose and user instruction

「接続操作で前提も後続もマイルストーンを選べないので、UI追加でも構わないからできるようにするよう姫にいらいしてほしい」. Example: connect the proposal 「SPI登録後のタスク出し」 (note: consider responses to test results as well as badge work) after SPI.

<a id="確定範囲"></a>
## Confirmed scope

- Let formal tasks/proposals select intermediate milestones as prerequisites and successors. Support at least 「SPI → 追加案」 and 「追加案 → 中間マイルストーン」 in the stated directions, with the same operations for existing tasks.
- Extending existing selectors or adding dedicated UI is delegated. Make prerequisite/successor and arrow direction unambiguous; retain direction through add/rewire/remove/save/resume.
- Keep existing formats: edges for task dependencies, milestoneRelations for milestone connections. New/changed conditions remain awaiting discussion; a connection is not automatic start or fulfilled conditions.
- Preserve structural START/END meaning, direct version-gate restrictions and placement-generated backbone. If a displayed gate is selectable, explicitly identify its actual START/END mapping. No backbone editing or blanket removal of restrictions.
- Reject invalid endpoints, self-links, duplicates and cycles without mutating original data. Preserve saved revisions, baseline and user edits.

<a id="編集範囲と手順"></a>
## Editing scope and procedure

RegistryApp/index.template.html, verify.cjs, bounded sync/serve consistency repairs if needed, RegistryApp/README.md, this breakdown/Return and Current/Evidence/OPS-084/. Write a brief breakdown first and inspect starting HEAD/existing differences. No DESIGN, actual Registry/Rules, milestone placement, user's Inbox saves or product changes.

Do not formally number the user's real proposal or apply connections to saved content on their behalf. Verify with equivalent isolated fixtures. No commit/external operations. Completion of this assignment hands the specified scope to Hime; Astra awaits return.

<a id="完了条件"></a>
## Completion conditions

Exercise both directions for existing tasks/proposals and show SPI→proposal in the map. Save/resume must preserve connections/baseline. Existing START/END operations, backbone protection, cycle/invalid rejection and unsaved-input protection must remain intact. Run sync/verify and operation smoke; explicitly note Safari nonverification. Return input SHA, diff, tests, unknowns and artifact handling.

## 作業内訳（姫記入）

2026-10-18 / 姫・Opus 5.5。開始HEAD`a1dae54ff`。既存の未commit差分：DESIGN 2件（ユーザー）、`CLAUDE_TASK.md`・Registry・Rules・本書（Astra）。どれも触らない。

1. **データ操作**：`addMilestoneRelation`に向きの指定を足し、「マイルストーン → task/追加案」（マイルストーンを前提にする）を作れるようにする。
   - 既存の「task → END/中間カード」と「START → task」はそのまま。
   - 前提にできるのは中間カードとSTART。ENDは版ゲートへの集合点、ゲートは骨格なので、前提には選べない（実データの意味を変えない）。
   - 形式は既存の`milestoneRelations`（条件は相談待ち）。重複・循環・不明端点は`check`で拒み、元データは変えない。
2. **画面**：正式taskと追加案の編集欄で、マイルストーンとの接続を向き付きで分けて出す。
   - 「マイルストーン → このタスク（前提）」と「このタスク → マイルストーン（後続）」の2つの欄・ボタンにする。
   - 一覧は矢印で表示し、削除もできる。既存の「到達点へつなぐ」「STARTからつなぐ」の意味は変えない。
3. **見取り図・独立欄**：中間カードから出る線を受けたtaskも、STARTの場合と同じく到達点側（独立欄ではない）として扱う。
4. **検証**：verifyに両方向・拒否・保存往復を足す。stub DOMのスモークで次を確かめる。
   - 追加案「SPI登録後のタスク出し」（メモ付き）をMS-SPIの後ろにつなぎ、見取り図に出ること。
   - 既存taskにも同じ操作ができること。
   - 保存→再開で向きとbaselineが保たれること。
   - 実ユーザーの`Inbox/`は使わない。
5. README・Return・Evidence。

## Return（姫記入）

2026-10-18 / 姫・Opus 5.5。入力`a1dae54ff8a5e8b72b46a218b00c5b85476b03fc`。DESIGN 2件（ユーザー）、`CLAUDE_TASK.md`・Registry・Rules（Astra）には触れていない。実ユーザーの`Inbox/`は使っていない（stubとverifyの合成データだけ）。

**変更**（`index.template.html`・`verify.cjs`・`README.md`）：
1. `addMilestoneRelation(data, taskId, milestoneId, direction)`：`direction='from'`で「マイルストーン → task/追加案」を作る。
   - 前提にできるのは途中のカードとSTART。ENDは前提にすると明示エラー。版ゲートは従来どおり拒否。
   - 既存の「task → END/カード」と「START → task」の動作は変えていない。
2. 正式taskの編集欄：見出しを「このタスクがつながる到達点（このタスク → 到達点）」にした。「マイルストーンの後に続く（マイルストーン → このタスク）」欄を足した（一覧は矢印付きで削除可、途中のカードを選んで「マイルストーンを前提にする」）。START欄はそのまま。
3. 追加案の編集欄：マイルストーンとの接続を矢印付きの一覧1つにまとめた。
   - 「前提：マイルストーン → この案（途中のカードかSTART）」を足した。
   - 「後続：この案 → 到達点（ENDか途中のカード）」は従来の機能。
   - 選択肢から、前提にはEND・ゲートを、後続にはSTART・ゲートを外した。
4. 独立欄の判定と版ごとの表示（`independentGroups`・`versionView`）：これまでSTARTの後だけを到達点側として扱っていた。途中のカードの後に続くタスクも同じ扱いにした。
   - 直さないと、例の「MS-SPI → 追加案」が既定の表示（HEADから）に描かれなかった（スモークで発見）。
   - END・ゲートからの線は従来どおり対象外。
5. READMEに「マイルストーンを前提・後続にする（OPS-084）」節を足した。

**検証**：
- `verify.cjs`に1行（26 PASS、以前は25）：
  - 通るもの：カード→追加案、カード→正式task、task→END（従来）、START→task。
  - 拒むもの（元データは変えない）：END・ゲートを前提、重複、循環（カード→task→カード）、不明task。
  - 保存往復でmilestoneRelations・baselineが保たれる。描画に線が出て、カードの版の表示に残り、配置の幾何検査を通り、カードより右に置かれる。
- `Evidence/OPS-084/smoke.cjs`（最小DOM stub＋fetch stub、既定のHEAD表示）：
  - 追加案「SPI登録後のタスク出し」（メモ「バッジ対応の他に試験結果への対応を検討する」）を作り、`MS-SPI → draft-1`とつないで矢印付きの一覧に出し、見取り図に描かれ、独立欄から外れることを確かめた。
  - 同じ案→ENDの追加、重複の拒否（データ不変）を確かめた。
  - 既存taskへのMS-SPI→task、その逆向き（循環）の拒否（データ不変）を確かめた。
  - 保存→再開で3本の向き・baseline・追加案が保たれ、行の削除で消えて未保存になることを確かめた。
  - 結果：PASS。
- 既存のOPS-082 smoke v2・v3もPASS。`sync.py`成功、`--check`でずれなし。
- Safari・実ブラウザでの表示とクリックは未確認。

**未確認・注意**：
- 正式taskの「マイルストーンを前提にする」欄は途中のカードだけを出す（STARTは既存のSTART欄）。追加案の前提欄はSTARTも含む。どちらも保存されるデータは同じ形。
- 見取り図でカード→タスクの線がどこに描かれるかは、配置の自動計算に任せている（幾何検査は通過）。

**作業物**：一時ファイルなし。

commitはしていない。

<a id="astra受入2026-10-18"></a>
## Astra acceptance (2026-10-18)

Accepted intermediate milestone connections in both directions under the user's acceptance request. Compared code/Return; independent sync/verify 26 PASS, OPS-084 smoke PASS, OPS-082 update-protection smoke v3 PASS, --check matched. Checked SPI→proposal, existing-task connections, direction/baseline across save/resume and rejection of invalid links. Safari display unverified; real user Inbox unchanged. Accepted as WAITING_USER for commit; implementation assignment ended.

User commit instruction on 2026-10-18 resolves commit wait and makes DONE. Acceptance limits/unknowns above remain.

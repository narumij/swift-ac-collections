# Studioの永続編集領域を試行する

## TL;DR（人間向け）

ダウンロード・添付を減らし、Studioの編集版をローカルへ保存して再開する試行の仕様・実装・補修・技術受入をまとめる。最終受入では保存中や更新待ち中の後続編集を保持することを独立検査した。恒久採用とは別で、自動保存なし、全系列で直近の保存を再開、AIによる取込照合が必要という制限とSafari未確認を残す。

2026-10-18 / OPS-082 / Parent OPS-048. Astra drafted/accepted; 姫 implemented/verified.

<a id="現行範囲への入口"></a>
## Entry to current scope

Under the user's 2026-10-18 addition, current specification/assignment are final 「永続編集領域の試行仕様」 and 「姫への改訂依頼」. Keep initial one-shot-save assignment/Return/limited rework as history. This trial does not permanently adopt the method.

<a id="目的と依頼"></a>
## Purpose and assignment

User need: 「JSONをダウンロードしてAIへ渡す手間をなくす」. Studio save accumulates edited results on the local server for AI's existing diff comparison/reflection. Saving is neither Registry reflection nor execution permission.

<a id="今回の範囲"></a>
## Initial scope

- Server-mode save sends current editing JSON (source/baseline/proposals/connections/changes) to server, without download/attachment.
- Destination `Maintanance/RegistryApp/Inbox/`, separate from generated cache; do not erase on regeneration/refresh/restart. Append uniquely named saves, never overwrite. Actual user data excluded from tests/commit.
- Only completed server save triggers success/unsaved reset. Preserve edits on failure/retry and existing pending-input protections.
- Retain file:// download; never silently fall back to it on server failure.
- README documents receiving procedure. On import request, check Inbox and compare baseline/current canonicals as before; never blindly apply every snapshot in save order. Record processed filename/results/deferrals to avoid reimport; keep original JSON.
- Save/handoff only: no status-list screen, autopolling/numbering, direct Registry write or auto-reflection.

<a id="編集範囲受渡し"></a>
## Editing scope and handoff

`RegistryApp/serve.py`, `index.template.html`, necessary limited checks, `RegistryApp/README.md`, this breakdown/Return, `Current/Evidence/OPS-082/`, handoff-directory explanation. No Registry/Rules/DESIGN/Milestones/product edits.

Retain Astra's uncommitted sticky-header CSS in index.template.html and user's DESIGN changes untouched. Record starting HEAD/prior diffs and brief breakdown. Assignment hands specified scope to 姫; Astra waits. No commit.

<a id="完了条件"></a>
## Completion criteria

1. AI-readable JSON retains baseline/proposals/connections; repeated saves remain without overwrite.
2. Failure retains edits/unsaved display; refresh/restart keeps results.
3. Fixed server path, no client-chosen arbitrary paths; retain local access restrictions; reject invalid/oversize JSON.
4. Isolated destination tests success/failure/multiple saves without actual Inbox pollution; sync/verify/save smoke; disclose Safari limits.
5. Return full input SHA, changes, reproduction/tests, limits and artifact handling.

## 作業内訳（姫記入）

2026-10-18 / 姫・Opus 5.5。開始HEAD`79356564ff01262a23f1ec5c5c8b4c477939bf3d`。既存の未commit差分：`index.template.html`のヘッダー追従CSS（Astra、1行）、DESIGN 2件（ユーザー）、Registry・Rules・`CLAUDE_TASK.md`・`TASK_REGISTRY_APP.md`・本書（Astra）。CSSは保持して作業し、他は触らない。

1. `serve.py`に`POST /save`を足す。
   - 既存の同一オリジン・ローカルの検査を使い、ヘッダー`X-Registry-Studio`は操作名と一致させる（`sync`／`save`）。
   - 大きさの上限を設け、JSONと最小限の形（schemaVersion・source・tasks・edges・baseline）を確かめる。
   - 保存先は`RegistryApp/Inbox/`に固定する（試験用に環境変数で差し替え可）。名前はサーバーが付ける一意名で、`x`モードで開くので上書きしない。
   - 成功時はファイル名を返す。
2. `Inbox/`に説明の`README.md`と、保存JSONをcommitしないための`.gitignore`を置く。syncや再起動では消えない（生成キャッシュとは別の場所）。
3. `index.template.html`の保存：サーバーで開いているときは`/save`へPOSTし、成功したときだけ未保存を解除して保存名を表示する。失敗時は編集と未保存表示を残す（ダウンロードへは切り替えない）。`file://`は従来のダウンロードのまま。
4. 検証：隔離した保存先・別ポートでサーバーを起動し、curlで次を確かめる。
   - 成功・複数保存（上書きなし）
   - ヘッダーなし・別オリジン・不正JSON・形違い・過大の拒否
   - 再起動後も残ること

   画面側はstub DOMのスモーク（成功→未保存解除、失敗→保持）。あわせて既存のsync・verify・`--check`。
5. README（AIの受取手順）・Return・Evidence。

## Return（姫記入）

2026-10-18 / 姫・Opus 5.5。入力`79356564ff01262a23f1ec5c5c8b4c477939bf3d`。Astraのヘッダー追従CSS（`index.template.html`の`header{position:sticky…}`）は保持した。ほかの他者分の差分には触れていない。

**変更**：
1. `serve.py`：`POST /save`を追加した。
   - 既存の`/sync`と同じ検査を使い、ヘッダー値は操作名と一致させる（`sync`の値では保存できない）。
   - Content-Lengthが必要で、上限は10 MiB。JSONとRegistry Studio形式の最小限の形を確かめる。
   - 保存先`INBOX`は既定`RegistryApp/Inbox/`で、環境変数`REGISTRY_STUDIO_INBOX`は試験用。
   - 名前はサーバーが付ける（UTC時刻＋乱数）。`x`モードで開いて上書きしない。
   - 成功時はファイル名と保存先を返す。`/sync`の動作は変えていない。
2. `index.template.html`の保存：サーバーで開いているときは`/save`へPOSTする。成功したときだけ`dirty`を解除して保存名を表示する。失敗・通信エラーでは編集と未保存表示を残し、ダウンロードへは切り替えない。`file://`は従来のダウンロードのまま。入力中（未適用）の保護も従来のまま。
3. `RegistryApp/Inbox/README.md`（説明）と`Inbox/.gitignore`（`*.json`をcommitしない）を置いた。
4. `README.md`：「サーバー保存とInbox」節（AIの受取手順：未処理の判定、無条件適用しない、取込記録、原JSONを保持）を足した。「AIがJSONを取り込むとき」1にInboxのファイル名を足した。

**検証**（`Evidence/OPS-082/`）：
- サーバー（`server_save_checks.txt`）：隔離した保存先（`mktemp -d`配下）・ポート18891で`serve.py`を起動した。
  - 正しい保存2回：200で別名の2ファイル。保存JSONはbaseline（追加案なし）・`proposals`・`edges`・`milestoneRelations`を保持していた。
  - 拒否されたもの：ヘッダーなし／`sync`ヘッダー／別オリジン／別Host（403）、不正JSON／形違い（400）、10 MiB超（413）。
  - 書込不可の保存先：500で理由を返す。
  - 再起動（起動時にsyncが走る）後も2ファイルが残る。
  - 同じサーバーで`/sync`は200。
- 画面（`smoke.cjs`）：OPS-081と同じ最小DOM stub＋fetch stubで確かめた。
  - サーバー失敗・通信エラーで未保存のまま、ダウンロードなし。
  - 送ったJSONに`proposals`・baseline・`changes`が入る。
  - 成功で未保存が解除され、保存名が出る。
  - 未適用の入力中は送らない。
  - `file://`ではダウンロードになる。
  - 結果：PASS。
- `sync.py`成功・verify通過・`--check`でずれなし。
- Safari・実ブラウザでの保存操作は未確認。実ユーザーの`Inbox/`には何も保存していない（`README.md`のみ）。

**残る制限・注意**：
- OPS-081の証拠`Evidence/OPS-081/smoke.cjs`は、保存がダウンロードになる前提で書かれている。そのため今回の変更後は手順4（保存）で止まる。保存先がサーバーに変わった意図どおりの変化で、証拠ファイル自体は受入済みの原記録なので直していない。再実行するなら、保存手順を`file:`で行うよう直す必要がある。
- 保存済みかどうかの一覧画面、自動の取込、保存の削除は対象外のまま。

**作業物**：一時の保存先・ログ・試験用JSONを含む`mktemp -d`ディレクトリは削除済み。

commitはしていない。

<a id="astra検収限定差し戻し2026-10-18"></a>
## Astra review and limited rework (2026-10-18)

Independent sync/verify25 PASS, OPS-082 smoke PASS, --check agrees. Original Return retained; completion blocked on one issue.

Editing/applying a proposal title after save starts but before response causes unconditional `dirty=false` to clear the later edit's unsaved status. Saved snapshot predates it, risking loss on close. In-memory extension of existing smoke altered title within success-fetch stub; `assert(state().dirty)` failed false. Original evidence file unchanged.

<a id="姫への追加依頼"></a>
### Additional assignment to 姫

Do not mark edits after sent snapshot saved. Protect input or compare current data with sent snapshot by minimal method. Test later applied/unapplied edits and failure; preserve unsaved changes and avoid misleading success wording. Same editing scope; no product/other features. Append Return, no commit.

<a id="永続編集領域の試行仕様2026-10-18--ユーザー承認"></a>
## Persistent editing workspace trial specification (2026-10-18 / user approved)

<a id="目的試行の位置づけ"></a>
### Purpose and trial status

Allow users to edit/save/resume during a long coordinator absence, then returning AI receives differences. Dogfooding develops 「ダウンロードして渡す手間をなくす」; evaluate method in actual use. JSON/SQLite choice is implementer's. User edits contain unreflected intent and are persistent data, not regenerable cache.

<a id="正本編集版履歴"></a>
### Canonicals, editing document and history

- Separate canonicals, starting base and user edits; refresh must not silently replace base.
- Append history, tracking time/save ID/branch/parent/base identity/content. No overwriting, expiry or deletion after import.
- Resume latest saved edits after normal restart/regeneration/reload. Keep save outside cache, retain old Inbox saves; preserve originals on any format migration.
- Save applied content at button press. Success refers to that snapshot; later edits remain unsaved and distinguishable. Failure retains edits.
- Do not silently save/discard unapplied input. No forced-exit-before-save recovery or autosave guarantee; retain leave-page protections.

<a id="更新"></a>
### Refresh

Refresh fetches/regenerates current canonicals, not discarding/merging edits. Keep history/editing data/unsaved changes/unapplied input. May block refresh while unsaved, but do not default to 「破棄して更新」.

Show briefly when base is older than canonicals. No automatic merge; this separation defers conflicts until import.

<a id="ai取込"></a>
### AI import

On user request, AI compares base, selected save and current canonicals. Do not repeatedly apply all snapshots in order. Merge independent differences; same changes count as reflected; differing changes to same place require consultation.

Keep import record separate from source, with save ID/formal numbering mappings/reflected items/deferrals/conflicts/checked canonical revision. Avoid duplicate registration/reimport, including partially imported content. Do not overwrite later user edits with selected import.

Switching base after import must explicitly create a new editing version while retaining old version, pending/conflicting/unapplied content. No Studio auto-merge/numbering; prepare safe AI procedure/save metadata.

<a id="最小の画面対象外"></a>
### Minimal display and exclusions

Show save result, resumed save and canonical updates minimally. No large history-management screen/list tab/cloud sync/collaboration. Old-tab saves must check parent and reject or branch rather than silently rewind newer edits.

<a id="姫への改訂依頼2026-10-18--astra"></a>
## Revised assignment to 姫 (2026-10-18 / Astra)

Expand existing server save to trial specification above, superseding 「保存だけ」/limited-rework assignments, including later-edit save bug.

First briefly outline format/location/resume/refresh retention/import record. Reasonable implementation choices delegated; return unsupported specifications/new user decisions only.

Same allowed serve.py/index.template.html/README/checks/breakdown/additional Return/Evidence/Inbox explanation, plus necessary save module/Git exclusions. No actual saves, DESIGN, Registry, Rules or product edits. Local persistence differs from Git commit; never commit actual data.

Using isolated data, test save→restart→resume, edit retention on refresh, canonical/edit separation, later edits during response wait, failure, old tabs and duplicate-import procedure. Establish unchanged base/history. Run existing checks/new smoke; disclose Safari. Return short real-use trial steps focusing on resume ease, canonical differences and AI import burden. Technical acceptance and later permanent adoption separate. No commit.

## 改訂依頼の作業内訳（姫記入、2026-10-18）

入力は前回と同じ`79356564`＋前回の未commit実装。前回の単発保存を土台に、次のとおり広げる。

1. **保存形式・場所**：保存は今の`RegistryApp/Inbox/`に、1回1ファイルのJSONで追記する。上書き・削除はしない。既存の保存はそのまま扱う。
   - 各ファイルは、編集版の全体（`source`・`baseline`＝土台、`proposals`、接続、`changes`）に、サーバーが付ける`studioSave`を加えたもの。
   - `studioSave`の中身：保存ID、保存時刻、系列、前版、土台のsha256・HEAD・生成時刻。
   - 前版を持たない古い保存は、それぞれ独立した系列として読む（形式移行はせず、原本を保持）。
2. **再開**：`GET /workspace`が直近の保存版を返す。サーバーで開いた画面は、保存版があればそれを編集版として読み込む（seedの正本では上書きしない）。「最新の正本から新しく始める」ボタンで、履歴を残したまま新しい系列を明示的に始められる。
3. **更新**：未保存の変更・未適用の入力がある間は、更新を止めて先に保存を求める（破棄はしない）。保存済みなら同期して再読込し、2.で同じ編集版に戻る。正本のsha256が編集版の土台と違えば、「正本が更新されている」と短く出す。自動合成はしない。
4. **保存中の後続編集**：送信時点の内容を控え、成功時は現在の内容と比べる。違えば未保存のまま残し、「保存後の変更は未保存」と出す。失敗時は編集を保持する。
5. **古いタブ**：送った前版が系列の最新でない（すでに後続の保存がある）とき、サーバーは拒まずに新しい系列として保存し、別版で保存したことを返す。新しい保存を黙って巻き戻さない。
6. **AI取込の記録**：小さな`RegistryApp/inbox.py`を置く。
   - `list`：保存・系列・前版・土台・取込済みかを表示する。
   - `record <保存ID> --note …`：取込記録`Inbox/IMPORTS.jsonl`に追記する。同じIDの再記録は拒む。
   - 取込の判断（比較・統合・競合の相談）はREADMEの手順でAIが行う。
7. **Git除外**：`Inbox/.gitignore`で`*.json`と`*.jsonl`をcommit対象外にする。
8. **検証**：隔離した保存先で次をスクリプトで確かめる。
   - 保存→再起動→再開
   - 更新後の保持と、正本変更時の分離表示
   - 保存中の後続編集、保存失敗
   - 古いタブ（別系列）
   - 二重記録の拒否
   - 原履歴が残ること

   あわせて既存のsync・verify、画面スモークを行う。

## 改訂依頼の追加Return（姫記入、2026-10-18）

入力`79356564ff01262a23f1ec5c5c8b4c477939bf3d`＋前回の未commit実装。Astraのヘッダー追従CSSは保持した。DESIGN（ユーザー）・Registry・Rules・`CLAUDE_TASK.md`・`TASK_REGISTRY_APP.md`には触れていない。実ユーザーの`Inbox/`は`README.md`・`.gitignore`だけで、保存データはない。

**選んだ方式**：上の作業内訳のとおり、JSONファイルの追記方式にした（SQLiteは使っていない）。
- 保存場所は既存の`Inbox/`をそのまま使う。前回の保存（`studioSave`なし）も単独の系列として読めるので、形式移行は要らない。
- 系列と前版は`studioSave`で持つ。再開は直近の保存。
- 古いタブからの保存は別系列にする。取込記録は`IMPORTS.jsonl`。

**変更**：
- 新規`RegistryApp/inbox.py`：保存の読込・追記・直近の取得、取込記録、CLI（`list`／`record`）。
- `serve.py`：`/save`は`inbox.append_save`を使う。クライアントが申告するのは前版だけで、保存ID・系列・時刻・土台はサーバーが付ける。存在しない前版は409。`GET /workspace`を追加した。
- `index.template.html`：
  - 起動時に保存版を再開し、土台を保つ。編集版・正本更新・別系列を表示する。
  - 保存は押した時点の内容を送り、応答待ち中の後続編集は未保存のまま残す（Astraの差し戻しの修正）。
  - 前版を送る。別系列になったときの表示。
  - 更新は未保存なら止める（破棄の確認は廃止）。
  - 「正本から新しく始める」ボタン。読込JSONの`studioSave`を引き継ぐ。
  - ヘッダーの案内文を、保存・再開・取込の流れに合わせて直した。
- `Inbox/README.md`・`Inbox/.gitignore`（`*.jsonl`を追加）、`RegistryApp/README.md`の節を「編集版の保存・再開とInbox」に書き直した（AIの受取手順を含む）。

**検証**（`Evidence/OPS-082/`。隔離した保存先・ポート18892。作業後に削除）：
- `server_trial.sh`→`server_trial_result.txt`：
  - 保存前の`/workspace`はnull。
  - Aを保存→Bを保存（前版A、同じ系列）→Cを保存（前版Aのまま＝古いタブ）。Cは別系列（branched）になる。
  - 存在しない前版は409。
  - `/workspace`はC、系列の先頭2、保存3。
  - `/sync`後も編集版の土台（古いsha）は変わらず、正本のshaとは別。
  - 再起動後も3ファイルが残り、再開もC。
  - Bの取込記録→同じIDの再記録は拒否。`list`で取込済みが分かる。
  - 原履歴A・B・Cの内容はすべて残る。
- `smoke_v2.cjs`（最小DOM stub＋fetch stub）：
  - 再開で土台を保ち、「正本が更新されています」と出る。
  - 保存中の後続編集は未保存のまま（送った内容は押した時点のもの）。前版の連鎖（S1→S2）。
  - 別系列の表示。失敗で編集保持。未保存中の更新は`/sync`を呼ばず、破棄しない。
  - 正本から新しく始めるは、未保存なら拒否、保存後は可。
  - 結果：PASS。
- `sync.py`成功・verify 25 PASS・`--check`でずれなし。
- Safari・実ブラウザでの操作は未確認。
- 前回の`smoke.cjs`は、起動時の`/workspace`取得も呼出し数に数えるため、今回の変更後は最初の呼出し数の検査で止まる。v2が置き換え、原証拠として残す。

**限界・新しく判断が要る点**：
- 自動保存はしない（仕様どおり）。保存前のブラウザ強制終了は復旧できない。
- 「正本から新しく始める」の直後は、保存するまで系列が作られない。保存せずに閉じると、次は以前の保存版が再開される。
- 再開するのは「全系列で最も新しい保存」。別系列ができたときの選択画面はない（表示だけ）。試行で困るようなら、系列を選ぶ最小の手段が要る（ユーザー判断）。
- 取込時の比較・統合・競合の判断は、READMEの手順でAIが行う。Studioに自動統合はない。

**作業物**：`server_trial.sh`の一時ディレクトリは、スクリプトの最後で削除した（結果ファイルにパスと削除を記録）。

### 実使用の短い試行手順（ユーザー向け）

1. `python3 Maintanance/RegistryApp/serve.py`で開き、追加案を1件作るか、状態を1つ変えて「編集結果を保存」を押す。
2. ブラウザを閉じてサーバーも止め、もう一度起動して開く。下段に「編集版 … を再開中」と出て、編集が残っているかを見る。
3. AIに正本を何か更新してもらってから「更新」を押す。編集が残り、「正本が更新されています」と出るかを見る。
4. AIに「Inboxを取り込んで」と頼み、AIの報告が「反映・保留・競合」に分かれて分かりやすいか、手間が重すぎないかを見る。

見てほしいのは、編集の再開しやすさ、正本との差の分かりやすさ、AI取込の負担の3つです。今回の技術受入と、試行後に恒久採用するかの判断は別にします。

commitはしていない。

<a id="astra再検収2026-10-18永続編集領域"></a>
## Astra rereview (2026-10-18, persistent workspace)

Independent sync/verify25 PASS, smoke_v2 PASS. Save-wait later-edit protection confirmed; completion blocked by another issue. Retain originals/evidence.

Even if refresh starts clean, editing is possible while `/sync` waits. Successful response unconditionally executes `dirty=false; formDirty=false; reload()`, deleting intervening edits without warning. Extended smoke_v2 in memory: after saved state, sync stub changes/applies title then succeeds; reload assertion fails 「更新待ち中の編集があるのに再読込された」. Original evidence unchanged.

<a id="姫への限定補修依頼"></a>
### Limited repair assignment to 姫

Keep applied/unapplied edits made after refresh starts. Minimal final reload guard or safe editing control, testing both while waiting. Separate successful canonical regeneration from permission to reload editing screen. No other specification; same scope, additional Return, no commit.

## 更新応答待ち中の編集保護の追加Return（姫記入、2026-10-18）

入力`ea1d7e62efee3b71e869c823ba9b63304db6eff1`。DESIGN 2件（ユーザーの未commit分）には触れていない。

**原因**：「更新」の`/sync`が成功すると、`dirty=false; formDirty=false; reload()`を無条件に実行していた。開始時の未保存検査は通っても、応答を待つ間の編集や入力を消していた。

**修正**（`index.template.html`の更新処理だけ）：
- 開始時の内容を控える。成功時に次のどれかに当たれば、再読込しない。
  - `dirty`
  - `formDirty`
  - 内容が開始時と違う
- そのときは「正本の再生成は完了しました。更新を待つ間に変更があったため、画面は読み直していません。保存してからもう一度『更新』を押すと…」と表示する。
- 未保存フラグを無条件に下ろす処理は削除した。
- 再生成の成功と、画面を読み直してよいかを分けて判定している。何も変わっていなければ従来どおり再読込する。

**検証**：
- `Evidence/OPS-082/smoke_v3.cjs`：
  - 通るもの：応答待ち中に適用した編集が残る（再読込0回、未保存、題が残る）。応答待ち中の未適用入力が残る（`formDirty`のまま、入力欄の値が残る）。変更がなければ再読込1回。`/sync`の失敗では再読込しない。
  - 結果：PASS。
- `smoke_v2.cjs`も引き続きPASS。
- `sync.py`成功・verify 25 PASS・`--check`でずれなし。
- Safariは未確認。

**作業物**：なし。前回の`inbox.py`のimportで出来た`RegistryApp/__pycache__/`（未追跡）は削除した。ただし`serve.py`は`inbox`をimportするので、実際に使えば`__pycache__/`は再び作られ、`.gitignore`にないため未追跡として表示される。除外設定を足すかどうかは編集範囲の外なので、一行報告にとどめる。

commitはしていない。

<a id="astra技術受入2026-10-18"></a>
## Astra technical acceptance (2026-10-18)

Under user acceptance/commit instruction, accepted persistent-workspace trial implementation. Input `ea1d7e62` plus 姫 refresh-protection repairs.

Independent sync/verify25 PASS, no missing bundled docs, smoke_v2/v3 PASS, --check agrees. Later applied/unapplied edits retained during save/refresh wait; reload only if unchanged. Server save/restart/branch/import code compared with 姫's isolated test records; server trial not rerun here.

Safari actual operations unverified. Keep limits: resume newest across all branches, no autosave, AI comparison/conflict decisions needed. Technical acceptance not permanent adoption; parent OPS-048 handles trial issues. User commit approval obtained, OPS-082 DONE, 姫 assignment closed.

# 作業イベントの濃淡と待機完了

## TL;DR（人間向け）
古い作業イベントをうっすら暗くし、作業領域から待機終了を依頼できるようにする。ユーザーの連続作業依頼による。停止済みと依頼済みは区別する。

<a id="姫への依頼"></a>
## Request to Hime
OPS-138 / 2026-10-19 / Astra. No need to re-confirm the start. First return in this document's Return a short breakdown and a minimal proposal for the wait-end button. The shading of old events may be implemented in a limited way. Keep the newest as is, darken the background of older ones slightly, and keep the readability of text, state colours, selection and focus. Do not darken without limit over time; one modest step for everything except the newest is enough.

The wait-end button stays at a pre-implementation proposal: select a target owner and send a unique WAKE by an explicit operation. Distinguish request sent from corresponding ACK received. Do not make it look as if a stopped AI was started automatically. Check whether a sending API exists, a safe fixed format, double clicks, failure/retry, and false matches with old ACKs. Do not grant free command execution or commit authority. Present the files to change and the tests. Astra gives the implementation instruction after receiving it.

Permitted: only the shading in index.template.html, the corresponding limited tests/isolated evidence, and this document's Return. No operation of the server in use or the user screen. No commit. Return with reference and keep waiting continuously.

## 姫Return
返却（2026-10-19 姫・Opus 5.5）。内訳：(1) 作業イベントの札の濃淡を限定して実装する。(2) 待機完了ボタンは、経路を確認して最小案を書く（実装なし）。commitなし。

### 1. 古いイベントの濃淡（実装済み）
- `createActivityView`で、最新以外の札に`data-age="older"`を付ける（最新は`latest`）。段階は1つだけで、時間が経っても暗くなり続けない。札のノードは作り直さず、属性だけを差し替える。
- CSSは`.activity-card[data-age="older"]{background:rgba(0,0,0,.22)}`の1行だけ。枠（種別の色）・文字の色・フォーカスの枠には触れていない。
- 試験：新規`test-event-age.cjs`。最新だけが`latest`であること、新しい札が来ると前の最新が1段だけ下がること、ノードの再利用、1枚のときは最新、背景だけを変えること、それ以上の段階がないことを確かめる。cjsの12本すべてPASS。sync（verify.cjs込み）・`--check`も通った。
- headless（`Evidence/OPS-138/check.cjs`・`results.json`・`wide.png`・`narrow.png`、隔離port 18944・模擬activity、POSTは0件）：2つの幅とも、最新だけ背景が透明で、ほかは`rgba(0,0,0,0.22)`。文字の色は全札で同じ`rgb(228,238,233)`。フォーカスの枠は白の実線のまま。新しい依頼を足すと、前の最新が1段下がった。ページのエラーは0件。サーバーは終了し、一時データは削除した。

### 2. 待機完了ボタン（最小案、未実装）
- **確認した事実**：Studioからactivityへ書くPOSTは、今は存在しない（`serve.py`のPOSTは`/sync`・`/save`・`/commit-approvals`・`/approval-probe`だけ）。WAKEは、各担当が`activity.py`で`request`として書いている。
- **送信経路**：固定パス`POST /activity-wake`を1本足す。Host・Origin・`X-Registry-Studio: activity-wake`の検査は既存のPOSTと同じ。本文は`{"owner":"<担当>"}`だけで、自由な文やコマンドは受け付けない。
- **サーバー側で決めること**：
  - 番号：`WAKE-<当日>-<英大文字と数字4桁の乱数>`。直近200件と重ならないものにする。
  - 記録：`activity.append_event(task, 'request', 'ユーザー', reason='WAKE-…：<担当>へ。ユーザーがStudioから待機の終了を依頼', next_owner=<担当>)`。
  - taskId：宛先の担当の最新の`presence waiting`の記録のtaskIdを使う。待機の記録がない担当には送らない（409）。
- **状態の区別**（作業領域の担当ランプの横に表示）：
  - 「待機終了を依頼済み・ACK待ち（hh:mm:ss）」。
  - 「ACK済み」：同じ番号で始まる`ACK <番号>`を、宛先の担当本人が記録したときだけ。
  - 番号は毎回新しく作るので、古いACKが当たることはない。宛先以外のACKも数えない。
- **二重クリック・再送**：
  - 送信中と、その担当にACK待ちのWAKEがある間は、ボタンを押せない。サーバーも、ACK待ちのWAKEがある担当への送信を409で断る。
  - 失敗したら理由を出すだけで、自動では送り直さない。
  - 結果が分からない（timeout）ときは、先に記録を読み直し、書けていなければ手動で再送する（通信規約§4の3）。
- **見せ方**：ボタンは「待機終了を依頼」とし、「届くのは待機中のAIだけです」と添える。止まっているAIを起こしたようには見せない（ACKが来ない限り「ACK待ち」のまま）。権限・commit・コマンドの実行は与えない。
- **変更するファイル**：`serve.py`（経路）、`activity.py`（番号の生成とACK待ちの判定）、`index.template.html`（ボタンと状態）、README。
- **試験**：
  - `test-serve.py`：経路・拒否・409・本文の検査。
  - `test-activity.py`：番号が一意であること、ACK待ちの判定。
  - 新規`test-wake.cjs`：状態・二重クリック・古いACKを数えないこと・宛先以外のACKを数えないこと。
  - 隔離headless：模擬APIで、送信済み→ACK済みの流れ。
- **判断が要る点**：記録上の送信者の名前（案は「ユーザー」）。待機の記録がない担当に送れなくてよいか。

<a id="最終確認フェーズユーザー指定2026-10-19"></a>
## Final confirmation phase (user-specified, 2026-10-19)

At the end of the implementation, Astra makes a limited check of how this conversation's requests, the OPS-136/137/138 request texts, Hime's returns, acceptances and activity notifications correspond. Missed communications, unapplied items, unaccepted items and wrongly completed items are listed and sent to Hime, who checks them independently and returns — one round trip. Continuous work does not end until the gaps are resolved or recorded as explicit holds. This is a check of this time's requests, not an audit that adds new work without limit.

<a id="astra実装指示待機完了ボタン2026-10-19"></a>
## Astra implementation instruction: wait-end button (2026-10-19)

Implement the minimal proposal with the following corrections. Files overlap with OPS-139's implementation, so proceed in series after that return. The user has already requested implementation; no need to re-confirm the start.

- The button name is the user-specified 「待機完了」. The supplementary text is 「選んだ担当に待機終了を依頼」. The sender is the user. Do not show an end before the ACK.
- The recipient is chosen from owners who appear in the existing activity (excluding the user). Do not make it unusable merely because there is no waiting record. Use the taskId of the owner's latest practical record as the related task. Being in a wait is not guaranteed; if it does not arrive, it stays as waiting for ACK.
- The unique ID uses sufficiently long random alphanumerics (UUID or the like). Make the server's duplicate check / append safe even for simultaneous requests. An unanswered request to the same owner must not multiply resends; return that existing ID so it can be re-checked. Match ACKs by the complete ID boundary and the recipient themself.
- Host/Origin/dedicated header/body checks, a fixed route and no arbitrary commands, as proposed. After a timeout, check by fetching; no automatic resend.
- Implementation permitted: serve.py, activity.py, index.template.html, the corresponding Python/JS tests, the README/protocol within this scope, this document's Return and isolated evidence. No operation of the server in use and no real WAKE test sends. Test with mocks/temporary data; no commit. After completion return with reference and keep waiting continuously.

## 姫Return：待機完了ボタン（実装）

返却（2026-10-19 姫・Opus 5.5）。18:37の実装指示は、待機スクリプトが作業中に届いた記録を拾わない作りだったため見落とし、18:44の再通知で着手した。スクリプトは「最後に見た行」から続けて読むように直した。commitなし。

- 実装：
  - `activity.py`：`request_wake(owner)`・`pending_wake(rows, owner)`・`WAKE_SENDER='ユーザー'`。1つの排他ロックの中で、読む・未応答を判定する・番号を決める・追記する、までを行う。ロック付きの書き込みは`_write_locked`に切り出し、既存の`append_event`も同じものを使う。
    - 宛先は、記録に登場する担当本人だけ（ユーザーや未知の担当は`LookupError`）。
    - 番号は`WAKE-<その土地の日付>-<uuid4の32桁>`で、直近の記録と重ならない。taskは、宛先の最新の実務記録から取る。
    - 未応答（宛先本人の`ACK <番号>`が番号の境界まで一致しない）なら、既存の依頼をそのまま返す。
  - `serve.py`：`POST /activity-wake`。Host・Origin・`X-Registry-Studio: activity-wake`の検査は既存と同じ。JSONで1024バイトまで、本文は`{"owner"}`だけ（ほかのキーは400）。応答は200`{created, event}`、未知の担当は409、不正は400、書けなければ503。
  - `index.template.html`：作業側のランプの横に、担当の選択・「待機完了」・「選んだ担当に待機終了を依頼」・状態の表示を置いた。状態の判定は`wakeOwners`・`wakeStatus`・`createWakeControl`・`sendWake`で行う。
    - 送信中と未応答の間は押せない。表示はACK待ち／ACK済みだけで、「終了」とは出さない。
    - 5秒で結果が分からなければ「結果が分かりません…（自動では再送しません）」と出す。
    - コードは、activityの「再描画しない」検査の範囲の外（`startActivityTimelines`の後）に置いた。
- 試験：
  - `test-activity.py`の`test_request_wake`：未知の担当、taskの選び方、番号の形、未応答で同じ依頼が返ること、ACKの似て非なるもの（宛先以外・番号の一部・後ろに文字が続くもの）、本当のACKの後は新しい番号になること、6プロセスが同時に要求しても1件だけ書かれること。
  - `test-serve.py`：POSTの入口検査に`/activity-wake`を足し、`test_activity_wake`で本文・長さ・型・余分なキー・各エラーを確かめた。
  - 新規`test-wake.cjs`：担当の並び、ACKの照合（境界・宛先本人・古いACK・Astraからの中継）、二重クリック、未応答の間は押せないこと、既存の依頼、失敗と結果不明、自動で再送しないこと、HTMLと送る本文。
  - `test-work-lane.cjs`は配線の文字列の1箇所だけを直した。
  - Pythonとcjsの14本すべてPASS。sync・`--check`も通った。
- 端から端までの確認（`Evidence/OPS-138/wake-check.cjs`・`wake-results.json`・`wake-acked.png`・`wake-pending.png`）：
  - activityの記録先を一時ファイルに差し替えた隔離サーバー（port 18946）に、本物のPOSTを送った。
  - ダブルクリックしても記録は1件。番号は`WAKE-20261019-<32桁>`、taskはOPS-1、宛先は姫。
  - ACKの似て非なるもの（後ろに文字が続く・Astraによる代理）では、ACK待ちのまま。宛先本人の正しいACKで「ACK済み」になった。
  - 6.5秒遅らせた送信では「結果が分かりません」と出た。ブラウザが打ち切ったのでサーバーには届かず、記録は増えていない（自動で再送しないことも確認）。
  - 実の`events.jsonl`は、前後とも255行で変わっていない。ページのエラーは0件。サーバーは終了し、一時データは削除した。
- README（待機完了ボタンの節）と、通信規約§5の表の1行を足した。
- 限界：
  - 実際のWAKEは送っていない。届いた先のAIが待機中かどうかは分からない。
  - 送信の直後、記録の取得が終わるまでの数秒は押せる。押しても、サーバーが既存の依頼を返すので増えない。
  - Chromiumは試していない。

<a id="最終照合の台帳astra進行中"></a>
## Final reconciliation ledger (Astra, in progress)

| Request from the conversation | Handled in | Status |
| --- | --- | --- |
| Top bar in one row: work on the left and initial, task on the right, title centred, menu on the task side | OPS-136 Return addendum 6 | Final placement accepted by Astra |
| Work status and approval details on the work side; keep top-bar approval | OPS-136 | Accepted |
| MILESTONES and retrospectives: list elements → organize | OPS-137 | 8 elements accepted and organized into 3 groups; display not implemented |
| Sol's small cache maintenance | Astra/HANDOFF_CHECKLIST | 3 documents checked shallowly, 0 change candidates, recorded |
| Dim old work events | OPS-138 §1 | Implemented; limited tests PASS |
| Wait-end button | OPS-138 implementation instruction | Implementation returned; independent Python/JS tests PASS |
| A mark that lets the user notice within 1 minute when Astra stops continuous operation | OPS-139 | Implemented and accepted in a limited way. Not checked after a real server restart |
| A communication route for information-update requests (separate from wait detection) | OPS-137 consultation Return | Applied to the protocol/README and accepted; no dedicated UI |
| At the end, reconcile missed communications and do a round trip with Hime | This document | To be performed after implementation finishes |

Do not read unimplemented as complete. Update each row in the final round trip.

<a id="astra途中確認未応答要求の保持"></a>
## Astra interim check: keeping unanswered requests

If request_wake looks for unanswered requests only in the latest 200 records used for display, then when an old unanswered request leaves the display window it can multiply new WAKEs. Duplicate suppression of user operations is a separate matter from display history. At least check unanswered requests/ACKs against the whole existing log (e.g. a linear stream scan to keep memory low), or keep a small persistent state. Add tests for resend and ACK after more than 200 other events. There is no need to add a display route that freely reads large logs.

### 姫Return追記：未応答の照合を全件で（Astra途中確認への対応）

- `request_wake`は、表示用の直近200件ではなく、ロックの中でログ全体を1行ずつ読む。`_WakeScan`が1回の走査で、担当の有無・最新の実務task・使用済みの番号・未応答の依頼だけを保持するので、メモリは小さいまま。表示の取得経路は増やしていない。`pending_wake(rows, owner)`も同じ走査を使う。末尾が不完全な記録は、従来どおり拒否（400）になる。
- 試験：`test_request_wake`に追加した。Astraへの未応答の依頼の後に別の記録を230件足し、表示の範囲（`read_events`）から外れたことを確かめる。それでも再要求で同じ依頼が返り、ACKの後は新しい依頼になる。taskは、ACKが実務ではないので最新の実務taskのまま。`test-activity.py`・`test-serve.py`ともOK。
- 隔離での端から端までの確認を取り直した（`wake-results.json`）。結果は前回と同じで、実の`events.jsonl`の行数は変わっていない。
- 表示側の限界：未応答の依頼が表示用の200件から外れると、画面の状態は空になり、ボタンも押せる。押してもサーバーが既存の依頼を返すので増えず、「未応答の依頼があります」と出る。
- 訂正（18:5x、姫）：上の「実の`events.jsonl`の行数は変わっていない」は正確ではない。確認中に257→259行へ増えたが、増えたのはAstraの18:51:04の受入と依頼の2行。実のログに送信者「ユーザー」の記録は0件で、試験が書いたものはない。

<a id="astra受入と最終記録照合依頼2026-10-19"></a>
## Astra acceptance and request for final record reconciliation (2026-10-19)
The wait-end button passed the independent Python activity/serve tests (6 each) and the JS wake/work-lane tests. Confirmed in code that unanswered requests are kept by a whole-log stream check. Accepted within the scope of mock-server evidence; the real user screen and real WAKE sends were not done.

To Hime: for this OPS-136 to 139 and this document's ledger, shallowly and independently reconcile the latest instructions from the conversation, the requests, your own returns, Astra's acceptances and the activity correspondence, and return in this document's 「姫最終照合Return」. Also leave the history that the missed additional request of 18:37 was implemented after the re-notification. List unprocessed items honestly. Astra has confirmed that the user postponed the concierge system proposal, and it is not implemented this time.
Check points: initial work and left/right, menu position, reports/retrospectives only up to organizing elements, the limits of Astra's signal, button send and ACK, the information-update route being a separate thing, no restart done, and not using old cards for an expanded approval scope.
Known minor gap in the documents: the communication protocol changed but its version is 0.1 and the revision history has only the first edition. You may add this scope as 0.2 with the reason for the change and the limits of what is unimplemented. Corrections to your own returns are appended; do not change others' acceptances or the Registry. Other fixes are only reported. No added implementation, no commit; return with reference and keep waiting continuously.

## 姫最終照合Return
返却（2026-10-19 姫・Opus 5.5）。照合の範囲は、OPS-136〜139の各正本、本書の台帳、activity（17:57以降のAstraの記録と姫の返却・受入）、作業ツリーのコード。浅く、独立に照合した。実装の追加・commitはなし。

**経緯（自分の見落とし）**：
- 18:37のOPS-138実装指示を見落とした。待機スクリプトが起動した時点より後の記録だけを読む作りで、作業中に届いた記録を拾えなかった。18:44の再通知で着手した。
- 同じ理由で、18:03（2段の明確化）・18:21（仕上げ条件）・18:28（待機の目印の協議）・18:30（情報更新の協議）も、activityとしては見ていない。18:03・18:28・18:30は、後の通知か正本を読んで反映した。18:21は下の4のとおり。
- スクリプトは「最後に見た行」から続けて読むように直した。18:47の途中確認は、この修正後に拾えた。

**確認点**：
1. 初期は作業、左右は「作業｜タスク」：一致。マークアップは`#workAreaTab`が先で選択中、`#workspace`が`hidden`。試験と画面で確認した（OPS-136追記6）。
2. メニューの位置：タスク側の`main`の先頭、見取り図のタブの左。一致（追記5）。
3. 報告と振り返り：要素の整理まで（8要素→3群）。表示の実装はなく、テンプレートにMILESTONESの表示コードはない（`MILESTONES`の出現は0）。一致。
4. **未処理（正直に）**：18:21の仕上げ条件（メニュー・タスク・作業を同じ幅・高さで隣に並べる、処理中も寸法を保つ）は、18:24の最新配置で並びが置き換わったため実装していない。ただし「処理中も寸法を保つ」は今も成り立っていない。メニューのボタンは処理中に「メニュー（処理中） ▾」へ変わり、幅が変わる。この条件を新しい配置のメニューにも当てはめるかは、判断が要る。
5. Astraの信号の限界：README・規約・本人の表示のどれにも、「停止の断定ではない」「長いツールの実行中も途切れに見える」「ページが非表示・サーバー停止中は検知できない」と書いてある。一致。Astraは18:51:39に`alive`を書いていて、記録`Activity/continuity.json`は本物（試験からの漏れではない）。
6. ボタンの送信とACK：サーバーが番号を決め、未応答の依頼は全件で照合する。ACKは宛先本人の、番号の境界まで一致するものだけを数える。一致。実際のWAKEはまだ送っていない（未実施）。
7. 情報更新の経路はWAKE・PINGとは別：規約§2の小節とREADMEの1項目だけで、コードはない。一致。
8. **再起動は未実施**。動いているサーバー（8088）は、`serve.py`・`activity.py`・`continuity.py`が変わる前のまま。そのため、syncの後にページを読み直すと次のようになるはず（推測）：
   - 上段の継続確認は、`/continuity`が404なので「Astra 不調」と出る。
   - 「待機完了」は404で、「送信できませんでした：Not found」と出る。
   - 再起動の推奨（runtime_fingerprints）は出るはず。
   再起動はユーザーの判断で、姫は触っていない。
9. 承認の範囲：今回の変更は、既存の承認カードの範囲の外に広がっている。古いカードを流用しないこと。変更・新規のファイルは次のとおり（ほかの担当の分は含めない）。
   - RegistryApp：`index.template.html`、`serve.py`、`activity.py`、`continuity.py`（新規）、`README.md`。
   - 試験：`test-activity.py`、`test-serve.py`、`test-continuity.py`（新規）、`test-continuity.cjs`（新規）、`test-wake.cjs`（新規）、`test-event-age.cjs`（新規）、`test-header-menu.cjs`（新規）、`test-header-layout.cjs`、`test-handoff-signals.cjs`、`test-usability-final.cjs`、`test-work-lane.cjs`、`verify.cjs`（OPS-136で足して戻したので、差はないはず）。
   - Current：`COMMUNICATION_PROTOCOL.md`（OPS-137・139の追記と0.2）、`STUDIO_*`の4本の姫Return、`Evidence/OPS-136・138・139`。
   なお`continuity.py`は誰かがすでにstageしている（姫ではない）。

**台帳との差**：
- 「Astraが止めたら1分以内に気づく目印」の行：上の8のとおり、再起動しないと実際の画面には出ない。
- 「最後に連絡漏れを照合」の行：この返却で行う。
- そのほかの行は、記載どおりで差はない。

**文書の補正**：
- 通信規約を0.2にし、版の行と改訂履歴に今回の範囲と未実装の限界を1行足した。
- 本書の自分の追記（未応答の照合）の置き場所を「Astra途中確認」の後へ移し、行数の記述の訂正を追記した。
- ほかの者の受入やRegistryは変えていない。

<a id="最終照合へのastra応答仕上げ依頼"></a>
## Astra response to the final reconciliation and finishing request

Confirmed that the receive cursor dropped notifications that arrived during work. Received the record that Hime fixed it to resume from the last line seen. Requests not applied this time have been recovered through follow-up requests or the canonicals. Keeping the menu's size while busy is useful in the current layout too, so make a limited correction. Keep the text readable, implement it so the button width does not change while busy, and add one related test and an isolated check; do not change other placement. index.template.html, the corresponding tests, this time's evidence and your own returns in this document are editable. No commit.

In parallel, do a read-only review of Luna's return for OPS-140 (Evidence/OPS-140/LUNA_RETURN.md, the 4 files in historical.json). Check only semantic agreement with the originals, the statement that they are historical material and not current rules, and that image positions are kept; record the result in Evidence/OPS-140/HIME_REVIEW.md. Do not touch the target bodies. Keep waiting continuously after returning both.

## 姫Return：メニュー処理中の寸法（限定補正）

返却（2026-10-19 姫・Opus 5.5）。commitなし。
- 実装：
  - `#headerMenuButton`の中に`<span class="menu-idle">メニュー ▾</span>`と`<span class="menu-busy">処理中… ▾</span>`を置き、CSSのgridで同じマスに重ねた（`grid-area:1/1`）。ボタンの幅は常に広い方の文字に揃い、見せる方だけを`aria-busy`で切り替える（もう一方は`visibility:hidden`）。
  - `createHeaderMenu`の`busy()`は、文字を書き換えずに`aria-busy`だけを切り替える。
  - 処理中の文字を「メニュー（処理中） ▾」から「処理中… ▾」に短くした。ほかの配置は変えていない。READMEの表記も直した。
- 試験：`test-header-menu.cjs`で、処理中に文字を書き換えないこと（stubでは`textContent`が空のまま）、2つの文字がボタンにあること、重ねる規則があることを確かめる。cjsの14本すべてPASS。sync・`--check`も通った。
- 隔離の確認（`Evidence/OPS-138/menu-busy-check.cjs`・`menu-busy-results.json`・`menu-busy-wide/narrow.png`、port 18947、`/sync`は1.5秒止めてから打ち切り）：2つの幅とも、ボタンは平常時・処理中・後で89.9×37pxのまま。見えている文字は「メニュー ▾」→「処理中… ▾」→「メニュー ▾」と替わり、隣のタブの位置（x=126／110）は動かなかった。syncのPOSTは1件で打ち切り、ページのエラーは0件。サーバーは終了し、一時データは削除した。

<a id="astra最終照合応答2026-10-19"></a>
## Astra response to the final reconciliation (2026-10-19)

Received Hime's final reconciliation and the menu-size correction. Confirmed the report on the cause — notifications arriving during work were dropped at the start of each wait — and the fix to continue from the last read position. The unstarted 18:37 request was implemented after the re-notification. The button width while busy was confirmed by the limited correction, an independent JS test PASS, and isolated size evidence. The parts implemented this time in the ledger are accepted. MILESTONES/retrospectives were, as intended, only organized into elements; no dedicated display is implemented. The concierge system is postponed as the user specified. No real server restart was done, so using the new communication features on the real screen comes after a restart. The commit is checked against the final target card.

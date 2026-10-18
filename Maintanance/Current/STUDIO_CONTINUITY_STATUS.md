# Astraの継続確認表示

## TL;DR（人間向け）
Astraの連続動作確認が途切れたら、トップバーで気づけるようにする。待機開始の古い印を生存証拠にはしない。状態取得は停止判定や自動起動を保証しない。

<a id="正式依頼"></a>
## Formal assignment

OPS-139 / 2026-10-19 / Astra. Start after the OPS-138 implementation stage, under the user's continuous-work authorization.
Use OPS-137 discussion for a small implementation. Write explicit confirmation timestamps to fixed per-owner files, expire after 55 seconds and evaluate elapsed time roughly every second in the display. Distinguish ordinary retrieval failure, expiry, explicit ending and absence of records. Show short upper-area labels such as 「Astra 継続確認」「確認が途切れた」「終了」「未確認」 without confusing approval signal colors/meaning. Server time must not make old records appear fresh.

Astra writes one-shot confirmations at execution milestones and before/after waits. Independent background heartbeat is prohibited because it would falsely indicate continuity after a turn ends. Explain that long tool calls can expire. Indication should appear within one minute while the foreground display/timer/server run; no guarantee under OS suspension or background restrictions. No resident schedule.

Implementation scope: small dedicated CLI/fixed record, safe fixed read route in serve.py, index.template.html display, related tests, bounded README/communication-protocol changes, this Return/isolated evidence. Existing saves/approvals/task meaning unchanged. Test using temporary directories, independent ports and mocked APIs; do not operate the user's active server. No commit. Sequence: breakdown → implementation → expiry-boundary/fetch-failure/stale-response/ended/narrow-width tests → reference-bearing return and continued waiting.

## 姫Return
返却（2026-10-19 姫・Opus 5.5）。内訳：
1. 新規`continuity.py`：担当ごとの確認時刻を1つの固定ファイル`Activity/continuity.json`へ書く（ロックを取り、一時ファイル経由で置き換える）。書けるのは`--state alive|ended`と時刻だけで、担当数に上限を設ける。CLIは単発で、常駐しない。
2. `serve.py`：固定パス`GET /continuity`で`{serverNow, owners}`を返す。読めなければ503。
3. `index.template.html`：上段の左（作業｜タスクの右）に「Astra 継続／途切れ／終了／未確認／不調」を短く出し、詳しい文はtitleに入れる。経過は「サーバー時刻＋取得してからの経過」で1秒ごとに判定し、55秒を超えたら「途切れ」。古い応答は捨てる。未来の時刻は信用せず未確認にする。承認の丸や色は使わず、枠線の種類で区別する。
4. 試験：`test-continuity.py`、`test-serve.py`への追加、新規`test-continuity.cjs`（期限の境界・取得失敗・古い応答・終了・未記録・未来の時刻）、隔離headless（狭い画面を含む）。
5. README、通信規約の今回範囲、本書の結果。

### 結果
- 実装：
  - `continuity.py`（新規）：`mark(owner, state, at)`と`read()`。担当は16人まで、ファイルは16KBまで。ロックを取り、一時ファイルから`os.replace`で置き換える。ほかの担当の記録は残す。CLIは失敗するとexit 1で、成功の表示を出さない。
  - `serve.py`：`GET /continuity`を固定経路の表に足した。返すのは`serverNow`（ミリ秒・UTC）と記録で、読めなければ503`{'error':'Continuity unavailable'}`。`runtime_fingerprints`の対象に`continuity.py`を足した。
  - `index.template.html`：上段の左の`.header-left`の中で、作業｜タスクの後に`#continuity-status`を置いた。判定は`continuityState`・`validateContinuity`・`createContinuityStatus`で行う。経過は「取得時のサーバー時刻＋取得してからの経過−記録の時刻」。遅れて届いた応答と、サーバー時刻が戻った応答は捨てる。未来の時刻（5秒を超える）は未確認とする。取得は5秒ごとでページが非表示の間は止まり、表示の判定は1秒ごと。枠線は、継続が実線、途切れが黄色の点線（太字）、終了が実線、未確認・不調が点々。
- 試験：
  - 新規`test-continuity.py`（6件）：往復、ほかの担当を残すこと、拒否したときに書かないこと、上限、壊れた記録、同時に書くこと、CLI、読み取り経路の200/503/404。
  - `test-serve.py`に`/continuity`の200/503を足した。
  - 新規`test-continuity.cjs`：境界（55000msは継続、55001msは途切れで「56秒前」と出る）、取得し直さなくても経過だけで途切れること、遅れた応答・古いサーバー時刻を捨てること、不調と回復、終了、未確認、未来の時刻、承認の色を使わないこと、配置。
  - PythonとcjsはすべてPASS。sync（verify.cjs込み）・`--check`も通った。
- headless（`Evidence/OPS-139/check.cjs`・`results.json`・画像。隔離port 18945、`/continuity`は模擬で、実記録には触れていない。POSTは0件）：
  - 2つの幅とも、表示は記録なし→未確認、10秒前→継続、50秒前→5.6秒後に途切れ、取得失敗→不調（最後に読めた確認の時刻つき）、回復→継続、ended→終了、未来の時刻→未確認、と変わった。
  - どの場合も、目印は上段の行の中にあり、タイトルにも承認欄にも重ならず、承認の状態は見えたまま。狭い画面ではx=136〜220。ページのエラーは0件。
  - 試験の後に`Activity/`にあるのは`events.jsonl`だけで、実記録は作られていない。
- README（継続確認の目印の節）と、通信規約§5の表の1行を足した。
- 限界：
  - Astraの運用（いつ`alive`を書くか）は、Astraが行う。姫は実際の運用での動作を試していない。
  - ページが非表示のとき・OSが止まっているとき・サーバーが止まっているときは、検知できない。
  - Chromiumは試していない。
- commitなし。

<a id="astra受入2026-10-19"></a>
## Astra acceptance (2026-10-19)

Independently ran six Python tests and JS expiry/failure/stale-response tests; PASS. Wrote own alive record and began operation without a separate-process heartbeat: one-shot updates before/after waits and at milestones. Long tool execution can show interrupted confirmation. Active server was not restarted, so its actual route on the existing screen remains unverified until restart. Acceptance is limited to isolated-screen/mocked-route evidence.

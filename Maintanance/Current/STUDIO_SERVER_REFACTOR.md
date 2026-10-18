# Studioサーバーの限定リファクタリング（OPS-131）

## TL;DR（人間向け）

StudioサーバーのGET/POST入口を短い処理へ分け、外部動作を保った限定リファクタリングの記録。Astraは隔離HTTPを含む20試験を独立実行して受入し、通信規約の確認とWAKEへのACKまで終えた。実サーバーは操作せず、出力欠落時の応答やsave本文読取のtimeout不足は既存の別件として残す。

2026-10-19. User requested server refactoring and continuous work. Parent OPS-048; Astra coordination/acceptance, 姫 implementation.

<a id="依頼"></a>
## Assignment

serve.py is 243 lines; no large split needed. GET routing, POST access checks and sync execution overlap in Handler. Separate short responsibilities so fixed routes/processing are readable. Write a short breakdown in Return then start without reconfirmation.

- Mainly organize within serve.py; no new framework, generic router, DB or endpoint.
- Preserve URLs, statuses, bodies/errors, Host/Origin/X-Registry-Studio checks, save paths, locks/timeouts and startup/restart notices.
- save/approval validation currently differs; do not force common code and change behavior. Report separate defects in Return.
- Allowed: RegistryApp/serve.py, new RegistryApp/test-serve.py, minimal necessary edits to test-activity.py/test-approvals.py/test-work-progress.py, this Return. Do not touch Astra's concurrent README/protocol/Registry edits.
- First freeze existing behavior with tests, then refactor. Cover current routes/rejections, sync success/failure/timeout/concurrency and lock release, save/approval calls. Run related existing checks. Only mocks, isolated HTTP ports and temporary Inbox; no real-server stop/start or actual user/approval data writes.
- Return diff/tests/limits through doc/section/next reference path. As natural OPS-129 observation 3, record operation count/rejections/corrections/burden in one line. No commit. Wait continuously after returning; end with WAKE.

<a id="完了条件"></a>
## Completion criteria

External behavior preserved, HTTP-to-handler flow clearer, limited regressions pass. Close records after Astra acceptance.

## 姫Return

返却（2026-10-19 姫・Opus 5.5、開始HEAD `11422f0bb`＋作業ツリー）。内訳：(1) 新規`test-serve.py`で、隔離HTTPポートに現行の挙動を固定（GETの全経路と403/404/503、POSTの入口検査、syncの成功・失敗・timeout・OSError・同時実行とロック解放・呼出し引数、saveとapprovalの拒否条件・呼出し・応答）。整理前に通ることを確認。(2) `serve.py`の中だけを整理：GETは固定経路表→経路ごとの短い関数、POSTは入口検査→sync・save・approvalの各処理。既存試験が偽のHandlerで`do_GET`を直接呼ぶ形はそのまま通す。(3) 新旧の試験をすべて実行。(4) 差分・試験・限界を書き、参照つきで返却。

- 差分（`serve.py`のみ、+75/−34）：GETは`GET_ROUTES`（固定パス→処理関数）を引いて`reply(*route(path))`。処理は`get_approvals`・`get_activity`・`get_work_progress`・`get_server_status`・`get_workspace`・`get_page`で、それぞれ`reply`の引数を返す。POSTは`POST_ACTIONS`（パス→必要な`X-Registry-Studio`）で、知らないパスは404、`studio_request`（Host・Origin・ヘッダー）が外れれば403、その後`sync`・`save`・`commit_approvals`へ。syncの本体は位置を移しただけで中身は同じ（ロック・timeout 300・例外ごとの応答）。approvalのStore選択は`approval_store`に一本化。save／approvalの入力検査は手を付けていない。URL・status・本文・保存先・起動処理・再起動通知の対象ファイルは不変。
- 試験：新規`test-serve.py`（5件）は隔離ポート（port 0）・一時OUTPUT/Inbox・モックだけで動く。GET全経路の本文とContent-Type・no-store・Content-Length、Host違いの403、クエリや末尾`/`の404、各503。POSTは4経路×Origin/ヘッダー欠落・違い・別経路の値・Host違いの403と、知らないパスの404、いずれも処理を呼ばないこと。syncの成功・失敗（500）・timeout（504）・OSError（500）・同時実行の409・各場合のロック解放・呼出し引数。saveの411/413/400/409/500と`studioSave`の扱い・保存先表示。approvalの400/411/413（重複Content-Length・途中で切れた本文を含む）・409/400/503と、経路ごとに正しいStoreだけを呼ぶこと。整理**前**のコードで5件OKを確認してから整理し、整理後も5件OK。既存`test-activity.py`・`test-approvals.py`・`test-work-progress.py`も変更なしでOK。わざと壊した版2つ（ヘッダー検査を外す・ロックを解放しない）はどちらも落ちることを確認して戻した。
- 限界：`OUTPUT`のファイルが無いときの例外（応答なしで接続が閉じる）は現行のまま固定していない。HTTP/1.0やkeep-alive、5秒の本文読み取り timeout の実時間は試していない。実サーバーの起動・停止はしていない（`main`は未変更）。`serve.py`が変わったので、使用中のサーバーは「再起動推奨」を出すはず（仕様どおり）。
- 別件の報告（直していない）：saveは本文の読み取りに timeout がなく、Content-Lengthより短い本文で接続を開いたままにされると、そのスレッドが待ち続ける（approvalは5秒）。また Content-Length `-1` は save では413、approvalでは411になる。どちらも現状差として試験に固定した。
- commitなし。
- OPS-129観察3回目：操作1回で通過、拒否・訂正0。見出しが短い`姫Return`でも一意なので問題なし。負担は初回と同じで、見出しを確かめる手間だけ（event id `7f5cf22ebcbd4d97910298174df34e4f`）。


<a id="追加の限定確認ops-130ops-129"></a>
## Additional limited check (OPS-130 / OPS-129)

Server return received; Astra checking. In parallel, read initial COMMUNICATION_PROTOCOL.md and briefly check discrepancies with this operation or omissions in manual/probe routes. No more code. Edit only final 「姫規約確認Return」. Add one line for OPS-129 observation 3 operation count/rejections/corrections/burden (not yet recorded in the previous return). Use reference-bearing return, then wait.

## 姫規約確認Return

返却（2026-10-19 姫・Opus 5.5）。COMMUNICATION_PROTOCOL.md 0.1を、今日の姫の実際の操作（OPS-129・131の返却、待機、WAKE）と照合した。コード変更なし。

1. **§3「正本に保存してから通知」に姫が2回反した。** OPS-129の初回とOPS-131で、return通知の**後に**観察の一行をReturnへ追記した。OPS-131ではAstraが追記前に読んだため「未記載」となった（追記は02:20頃、event `7f5cf22e…`の後）。規約側は正しい。足りないのは、通知後の追記を相手にどう知らせるかという点で、今は再通知するかどうかが決まっていない。案として、§3に「通知後に参照先へ足した場合は、追加の記録で知らせる」を一行足す。以後、姫は観察まで書き終えてから送る。
2. **§6の疎通番号に書式の条件が抜けている。** Studioが疎通として扱う送信は、`PING-YYYYMMDD-X`の直後に`：`か`:`があるものだけ（`isProbeEvent`）。コロンがないと、ただの言及として扱われて実務の扱いになる。その結果、作業レーンの「現在」や相手のランプが変わる。ACKも`ACK <番号>`で始める必要がある。省力側の手順にこの2点と、どのevent種別で送るか（今は`work`）を書くとよい。
3. **待機開始は担当者単位なのに、記録はtask単位でしか書けない。** §2の「対象の仕事」に合わせて、`--presence waiting`にも何かのtask IDを付けている。たとえばOPS-129の受入後の待機をOPS-129で記録した。表の待機開始の行に「task IDは便宜で、待機は本人単位」と注記するか、待つ対象の書き方を決めるとよい。
4. **WAKEの記録種別が書かれていない。** 実際のWAKEは`request`種別で、reasonに`WAKE-…：`を入れて送られている。ACKは`work`で、`--presence ended`を付けている。§2の表か§5に現状として一行あると、手動側でも同じ形を作れる。
5. **AIどうしの手動経路は、実質ユーザーの仲介だけ。** 連続待機中の受け手が見ているのはactivityだけで、相手の会話に直接は書けない。§1の「通常の会話で相手へ渡す」は、AIどうしでは§6の「ユーザー仲介で成立」と同じになる。§1にもそう明記すると誤解がない。なお、ユーザーが発言すると姫の待機は止まる。
6. 食い違いがなかった点：受信ACKは着手ではない、返却は受入ではない、再依頼は前の完了を持ち越さない、沈黙から終了を推定しない、の4点は今日の運用と一致する。§5の表も現状どおり。

OPS-129観察3回目は、§1の`姫Return`末尾に追記済み（操作1回、拒否・訂正0、負担は見出しの確認だけ）。追記が通知より後になった点は上の1のとおり。


<a id="astra受入2026-10-19"></a>
## Astra acceptance (2026-10-19)

Compared serve.py diff: separated fixed GET handlers, POST access checks and sync while preserving save/approval validation/responses. Independently ran isolated HTTP 5, activity 5, approvals 8 and work-progress 2 tests (20 total): pass. No real-server operations.

Keep missing-output response and missing save-read timeout as existing separate issues; no change in this behavior-preserving task. Negative Content-Length status difference is compatibility behavior, not a defect just because it differs.

Reflected five protocol-review points. Actual misordering from post-notification observation edits prompted a procedure to notify important additions/corrections. Explicitly stated current manual Xcode-to-Xcode route uses user mediation.

Confirmed 姫 ACK for WAKE-20261019-E (2026-10-18T17:23:29Z); continuous waiting ended.

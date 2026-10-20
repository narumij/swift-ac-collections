# Studio画面と共通サービスの分離：作業内訳（OPS-192）

## TL;DR
画面の開発・停止でAI間の連絡まで止まらないようにしたい。DBと更新経路の一元化を保ち、画面サーバーと共通サービスの寿命を分ける。まず姫が段階2〜5の作業内訳を返し、Astraが検収してユーザーと範囲を合わせる。今回は実装前の調査だけ。

## 全体像と現在の境界
1. 受入済みパッチの統合：OPS-191で完了。
2. 分離境界と作業内訳を決める。
3. 連絡・承認を起点に共通サービスを抽出する。
4. Studio画面をその利用側へ接続する。
5. 画面停止・再起動中のCLI連絡と承認照会、画面復帰を試験する。
6. 本番切替は別の区切り。起動・切戻し手順を用意してから扱う。
7. Registry・判断DB等の更新経路の一元化は後続として扱い、今回ひとまとめに移行しない。

ユーザー指定：段階2〜5は内訳を先に確認し、その後、姫との限定した作業・返却の往復で進める。品質不足はAstraが肩代わりして補修せず、未達を明示して返す。役割名を品質保証としない。

## Assignment to Hime
DISCOVERY only, under OPS-048. Prepare a concise, evidence-based work breakdown for stages 2–5 above. Do not implement yet. The shared working tree will be committed before dispatch; the dispatch identifies that base.

Purpose: keep CLI communication and approval queries working while the Studio UI server is stopped or under development. Preserve one authoritative store/write route per concern; do not introduce duplicate writers or forked stores. Do not claim the current Registry CLI is already routed through the web service.

Return:
1. A small boundary map grounded in current files/routes: UI, letters/approvals, Registry/decision writes, saves/refresh. Identify existing shared-process dependencies.
2. A recommended minimal split and per-round breakdown for stages 2–5: files, outcome, acceptance test, dependency and rough size. Prefer a few bounded rounds. Avoid speculative redesign/options lists.
3. Tests proving UI stop/restart does not stop CLI send/receive/reply and approval queries, and that restored UI reads the same records. State where failure/retry and exclusive writing need verification. Existing accepted tests may be reused; identify actual gaps.
4. What remains for production cutover/rollback and later Registry/decision integration. Only genuine unresolved policy choices go to the user; verify checkable facts yourself.

Acceptance gate: each claim must have enough evidence to check cheaply. Material missing facts, contradictory scope, or untested claims presented as complete will be returned for your correction; Astra will not finish missing research for acceptance. A limit does not turn an unmet requirement into completion. Keep the reply short; put supporting details in this document.

Allowed shared edits: this Return section and Evidence/OPS-192/ only. Read code and run bounded read-only investigation; no implementation changes, live store mutations, user's server control, stash or commits. No phase 3–5 execution until the breakdown is reviewed and the user confirms its scope. Return on the same DB letter, then remain available for feedback.

## Return（姫記入）
Returned (Hime, 2026-10-20; letter LTR-20261020-9FE8ADAB…). Discovery only, at base `b2c380288`, read-only; no implementation. The details and evidence (line references) are in `Evidence/OPS-192/BREAKDOWN.md`.

1. **Boundary.** One process (`serve.py`, 8088) is the only opener of the letters/PING/approvals DB (`approvals.sqlite3`). That is a written rule, and grep finds no other non-test opener. `comm.py` and `approvals.py` write only over HTTP. So stopping the UI stops CLI letters and approvals; this was observed today around 14:40, when the OPS-191 letter could not be sent. Activity and continuity are written by their CLIs directly, behind fcntl locks. Registry V3 and the decision DB are written by their CLIs directly and are not routed through the web service. Saves and refresh (`/save`, `/workspace`, `/sync`) are UI-only.
2. **Split.** Move only letters, PING and approvals into a records service that becomes the sole opener of the same single DB. The UI forwards those routes to it and never opens the DB. Three rounds:
   - R1: extract `records_service.py`, standalone, with serve.py behaviour unchanged.
   - R2: an explicit `--records-url` relay in serve.py.
   - R3: two-process stop/restart tests.
   The files, acceptance tests and sizes per round are in the evidence table.
3. **Tests.** With the UI stopped, CLI send/receive/return, PING/ACK and approvals add/list still work. The restarted UI shows those records; this reuses the OPS-187/188 drivers. With the service stopped, the CLI reports not-sent and the page shows stale-and-disabled; both recover. The gaps that need verification, which have no test today:
   - a second service on the same DB must refuse (single writer, needs a lock);
   - the UI must open no DB;
   - relay failures must keep the 409/timeout/unknown distinction;
   - the unknown-response resend of `comm.py letter send`, which prints no operation ID (CP-006).
4. **Remains.**
   - The one user choice: the service port, and who starts and stops it. The recommendation is to keep the UI on 8088, put the service on a new fixed port, and move the CLI default there.
   - Rollback is to start `serve.py` without `--records-url`. It uses the same single DB, so nothing is migrated.
   - Later and out of this split: Registry V3 and decision-DB writes, and activity/continuity writes, including the UI's `/activity-wake`.

No shared edits beyond this section and `Evidence/OPS-192/`. No live store mutation; the only live action was receiving and starting this letter through the running server.

## Acceptance（Astra記入）
2026-10-20 初回は未受入。3区切りの構成とHTTP経路の説明は採用候補。次の不足を姫に返し、実装は未許可。
1. 切戻しは旗を外すだけでは閉じない。共通サービスの停止・同一DB所有権の解放とCLI接続先の復元を含む必要がある。現在のstudio_client.pyはREGISTRY_STUDIO_URL/DEFAULT_URLで接続先を選ぶ。
2. 一プロセス互換経路と単独サービスが同じDBを開ける設計なので、両経路にまたがる排他の範囲・取得解放・起動衝突試験を内訳へ明記する。新サービス同士だけの検査では足りない。
3. 中継先での接続前失敗と送信後の結果不明を、画面までどう保つかを内訳へ明記する。UI側で元のOrigin検証を保つことも必要。
実装ではなく内訳の補正依頼。既存環境変数で試験できるため、本番port選択と起動担当を今回の調査の停止条件にしない。本番切替時に扱う。CP-006の独立修正は自動追加しない。

## 受領遅延の確認（ユーザー追加）
今回の依頼はサーバー送信記録05:58:12.589998Z、本人受領05:59:25.080573Zで約72秒差。DBの遅延と断定しない。姫の待機・照会タイミング、検知とreceiveの実行タイミングを確認し、連絡DB/監視経路に原因があれば修正対象へ。人間の追加中継を前提にしない。

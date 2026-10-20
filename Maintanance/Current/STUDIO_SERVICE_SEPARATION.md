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

### Response to review round 1 (Hime, 2026-10-20; letter LTR-20261020-E9929557…)
The original return above is kept as it was. Details are in `Evidence/OPS-192/BREAKDOWN.md` 「補正1回目」, sections A–E.

- **A. Rollback.** It now has three parts:
  1. Stop the service, which releases the DB owner lock.
  2. Start `serve.py` embedded (without `--records-url`), which takes the lock again.
  3. Restore the CLI destination: revert `DEFAULT_URL` or unset `REGISTRY_STUDIO_URL`.

  `studio_client` has only these two selectors (grep). R3 adds a rollback test: env-free `comm.py` and `approvals.py` reach the embedded server and return the same records. Port and operator choice are left to cutover.
- **B. Lock.**
  - Scope: a per-DB-file fcntl lock (`<db>.owner.lock`) for `approvals.sqlite3` and `probe.sqlite3`. Both move to the service, so the UI opens no DB.
  - Acquire: the standalone service takes it before binding; embedded `serve.py` takes it before sync and bind. A process that cannot take it exits 1 without doing anything. `--records-url` mode never takes it.
  - Release: only at process exit, including a crash.
  - It is taken at the entry points only, not in `Store`, so the existing tests are unaffected.
  - R1 collision tests on one temp DB: service/service, service then embedded, embedded then service (the second always refuses and writes no bytes); service with `--records-url` (both run); and restart after stopping the first, including a kill.
- **C. Relay outcomes.**
  - The UI keeps its own `studio_request` check (local, its own Origin, the `X-Registry-Studio` value) first. On failure it returns 403 and contacts nothing. Only after that check does it rewrite Host/Origin for the service.
  - Outcomes reaching the page: connection failure → 503 `outcome: not-sent`; sent but no or broken answer → 504 `outcome: unknown`; any service answer → passed through byte for byte. The approvals controller already holds stale and disabled, then re-reads; only its unknown wording changes.
  - R2 tests: wrong Origin gives 403 with no service connection; a stopped service gives 503 and an unchanged DB; a peer that accepts then closes gives 504; a normal answer is byte-equal.
- **D. The 72 s receipt.** Not a system defect. The DB records give:
  - sent 05:58:12.590Z;
  - waiting started 05:58:47Z (activity line 547; before that I was answering in conversation and not watching);
  - detected 05:58:48Z (wait output);
  - received 05:59:25.081Z, after about 37 s of reading the body, Registry row, base and document.

  No DB latency is visible. The poll interval while waiting is 5 s; the correction letter was detected 4 s after it was sent. The fix is in my procedure: receive right after reading the body revision, and do the Registry/document checks at start. No system change, so no test.
- **E. The revision-after-return gap.** Reproduced: my watch, running from 06:00:52Z, did not report the 06:03:13 request v2 and fired only on the new letter at 06:05:35.

  Proposed fix (not implemented): `inbox` also returns returned letters that have a request revision recorded after the last effective `returned` event, flagged `revisedAfterReturn: true`. `watch` then reports `['revision']` unchanged.

  Minimal test: send → receive → start → return → sender revises; the letter is in `inbox`, and watch reports it once. A returned letter without a revision stays out, and so does a closed one. This is separate from D.

The CP-006 fix was not added.

### Response to review round 2 (Hime, 2026-10-20; letter LTR-20261020-FBDD4946…)
Rounds 1 and 2 above are kept as written. Details are in `Evidence/OPS-192/BREAKDOWN.md` 「補正2回目」.

The disposable prototype is `prototype.py`, with its output in `prototype-output.txt`. It runs the real `Store` on a temp DB and the real `comm.watch_command`, with only `studio_client.get` routed in-process.

1. **Rollback, conditional.**
   - If cutover changed `DEFAULT_URL`: revert it to 8088, and unset `REGISTRY_STUDIO_URL` wherever it was set.
   - If it only set `REGISTRY_STUDIO_URL`: unset it in every environment that set it, including AI shells and wait scripts.
   - If the service took 8088 and the UI moved: the CLI is unchanged.
   - In every case, first stop the service and confirm the lock is free; the embedded `serve.py` must be able to take it. The rollback test is that env-free `comm.py` and `approvals.py` reach the embedded server.
2. **Ordering.** `letter_events.sequence` and `letter_texts.sequence` are separate AUTOINCREMENT counters in two tables (schema checked). The round-1 comparison was wrong and is withdrawn. The new proposal compares no sequences.
3. **Watch, actual behaviour.** `watch_command` replaces `seen` with the current inbox, so a letter that leaves is forgotten. Observed:
   - Current inbox: a request revision after return gives exit 3, which is the gap.
   - Proposed inbox with the current watch: re-entry is reported as `['new']`, not `revision`. My round-1 claim was wrong.
   - Watch that keeps the signatures of letters that left: `['state','revision']`.

   Proposal: keep those signatures.
4. **Closing the cycle.** Every reply text (return or reply revision) names the request revision it answers, `answers_revision`.
   - It is required, never defaulted to the latest, and must be between 1 and the current request revision. It is stored in a new `letter_texts` column; the append-only triggers are unchanged.
   - Pending means: state returned, and the latest request revision is greater than every `answers_revision`. Legacy NULL counts as the revision read at receipt.
   - `inbox` includes pending letters, flagged `revisedAfterReply`.
   - An unrelated typo fix that answers v1 keeps the letter pending. Observed: pending True after the typo fix, False after answering v2.
   - CLI: `--answers N` on return and on reply revise.
   - The minimal tests are listed in the evidence (§4).

Not implemented in shared code. No live changes and no commit.
- 一時作業物: `/var/folders/x9/2p70phpx3_xdvwx9s6gp35rm0000gn/T/OPS-192.a0JlY2XbbO`・姫・2026-10-20・一時DBでwatchと通知の述語を再現する使い捨ての試作・状態「削除済み（2026-10-20、試作と出力をEvidence/OPS-192へ写したあと削除）」

## Acceptance（Astra記入）
2026-10-20 初回は未受入。3区切りの構成とHTTP経路の説明は採用候補。次の不足を姫に返し、実装は未許可。
1. 切戻しは旗を外すだけでは閉じない。共通サービスの停止・同一DB所有権の解放とCLI接続先の復元を含む必要がある。現在のstudio_client.pyはREGISTRY_STUDIO_URL/DEFAULT_URLで接続先を選ぶ。
2. 一プロセス互換経路と単独サービスが同じDBを開ける設計なので、両経路にまたがる排他の範囲・取得解放・起動衝突試験を内訳へ明記する。新サービス同士だけの検査では足りない。
3. 中継先での接続前失敗と送信後の結果不明を、画面までどう保つかを内訳へ明記する。UI側で元のOrigin検証を保つことも必要。
実装ではなく内訳の補正依頼。既存環境変数で試験できるため、本番port選択と起動担当を今回の調査の停止条件にしない。本番切替時に扱う。CP-006の独立修正は自動追加しない。

## 受領遅延の確認（ユーザー追加）
今回の依頼はサーバー送信記録05:58:12.589998Z、本人受領05:59:25.080573Zで約72秒差。DBの遅延と断定しない。姫の待機・照会タイミング、検知とreceiveの実行タイミングを確認し、連絡DB/監視経路に原因があれば修正対象へ。人間の追加中継を前提にしない。

## 返答後改訂の配送漏れ（Astra確認）
初回返答後に同じ連絡のrequest revision 2で補正依頼したが、studio_store.pyのreviseはstateを変更せず、inboxはOPEN_FOR_RECIPIENT（sent/received/started/withdrawn）のみを返す。returned状態の改訂はwatchから見えない。初回の72秒とは別の、再現可能な配送経路の穴。初回連絡を未受入の記録付きで閉じ、補正依頼を別連絡として発行する。重複実行ではなく配送先の明示的な切替。恒久修正は今回の内訳で候補と最小試験を確認する。

## 検収2（Astra）
補正A〜Cは方向として改善。未受入の残点：Aの「環境変数を消す」はDEFAULT_URLも変更した場合に旧接続先へ戻らないため条件別に訂正。Eのeventとtextのsequenceは別系列であり、その数値を直接比較する設計は不可。watchは受信箱から消えたIDをseenから除くため再登場はnewになり得る。返答改訂後に未処理表示が解消する条件も必要。姫に小さな隔離再現で往復全体を確認して訂正するよう返す。共有実装変更は許可しない。
受領遅延は姫の操作説明では待機前と読解時間。DB遅延がないことの一般保証とはしない。

## 検収結論（Astra、2026-10-20）
分離の作業内訳（R1共通サービス抽出・R2画面中継・R3停止/再起動/切戻し試験）をDISCOVERY成果として受入。実装や本番切替の受入ではない。ユーザーにこの3区切りを提示し、範囲確認までは実装を開始しない。
通知漏れは実コードと隔離再現で確認。姫のprototypeをAstraも再実行し、現行watchの検知漏れと再登場newを確認した（[ログ](Evidence/OPS-192/astra-prototype.txt)）。提案部分はインプロセス模擬であり、answers_revisionのDB移行・既存返答の扱い・通知保持の採用や実装を保証しない。分離と別の修正候補に残す。初回受領72秒は担当の説明に基づく内訳で、通信遅延なしの一般保証ではない。
一時作業物：Astraの再現用/tmp/astra-ops192-*、2026-10-20作成・ログ保存後削除済み。実サーバーへの変更なし。

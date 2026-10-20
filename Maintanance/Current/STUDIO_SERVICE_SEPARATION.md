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
未返却。

## Acceptance（Astra記入）
未検収。

# 承認操作の実接続試験とパッチ（OPS-188）

## TL;DR
OPS-186の次の1件。実サーバー・一時DB・実ブラウザで、表示した承認依頼だけが承認され、その結果が画面と記録に一致することを試験にする。姫が必要最小限の修正と試験をパッチ返却する。本番反映・Git commitはしない。

## Assignment to Hime
User-authorized EXECUTION. Start this one bounded assignment. Communication DB is the dispatch/receipt/return route; this document is the detailed scope. No duplicate file-route dispatch.

Work breakdown:
1. Map current approval UI controls to the real server operations and records.
2. Write and run a focused Test as Spec through a real isolated server, disposable approval DB and headless browser. Use actual UI clicks, actual server responses and record readback; do not mock the approval endpoints.
3. Fix only a demonstrated violation of the following promises and return a small patch.

Acceptance promises:
- A pending request created through the existing supported route appears with its identity and scope; individually approving it changes that request alone. An unrelated pending request remains pending.
- Bulk approval operates on the IDs/revisions represented by the displayed snapshot. A request introduced after that snapshot is not silently included. Control the race deterministically; retain real HTTP and store operations.
- After the UI action, actual stored state/history and refreshed UI agree on which requests were approved. Approval alone neither claims/consumes the request nor creates a Git commit.
- Show a focused negative control: breaking the relevant target/connection makes the test fail. Snapshot equivalence alone is insufficient.
- Provide a repeatable command and distinguish passed, failed and unrun checks. Missing acceptance is unfinished, not completed-with-Limits.

Boundaries:
Use a scratch copy at an exact base SHA, test-only port and disposable stores/output/Inbox/tools records. Never use port 8088, mutate live DBs, control the user's server, approve live requests, or apply changes to shared implementation. Explicit permission is granted for test-only simulated user approval clicks and headless browser/server execution. No real Git commit or claim/finish exercise is needed. Do not use stash. The OPS-187 patch is not integrated: reuse its test approach if helpful, but declare any patch dependency explicitly rather than silently assuming it exists. V3 mode is preferred when cheaply runnable; report the exact startup mode and any limitations without claiming broader coverage.
Scope is the approval UI/poller, existing approval server/store routes and focused test harness as needed for these promises. No auth redesign, expiry policy, claim-token recovery, generalized test framework, or withdrawn OPS-183/184 work. Those are separate candidates. Do not impose a test-count target.

Delivery:
Return changes.patch, base SHA, SHA-256, file breakdown, test command/results and remaining gaps. Check application on a clean scratch copy of the base. Evidence directory `Maintanance/Current/Evidence/OPS-188/` and this Return section are the only shared editable scope. Send a concise returned event through the same communication-DB letter; details stay here. No commit or production integration. Reference any cache used in one line (none is acceptable).

## Return（姫記入）
Returned (Hime, 2026-10-20; letter LTR-20261020-7BCC2E89… received and started).

Every promise holds at the base, so no implementation change was needed. The patch adds the test only.

- Base: `e1d7f8f5efce656698878cddbcc5679f0953bbe5`, in a disposable clone.
- Patch: `Evidence/OPS-188/changes.patch`, sha256 `499115342311c74f040a98477305970a1aec68f5fbaea40d900e1c7ddc737ecf`.
  - Two new files, no implementation change:
    - `RegistryApp/test-approvals-e2e.py` (142 lines)
    - `RegistryApp/approvals_e2e.cjs` (102 lines)
  - It applies cleanly to an export of the base (`patch -p1 --dry-run`).
  - It is independent of the OPS-187 patch: it reuses the approach, not the files.
- What the test checks, against a real `serve.py` on port 0 with a temporary approvals DB, Inbox, output and tools record. Requests A and B are added through `approvals.py add`, which goes over HTTP to the server. In headless WebKit the test then checks:
  - A's 詳細 names A's ID, its revision and its scope as text.
  - Clicking A's 承認 POSTs only A at revision 1. The store then has A approved and B pending, and the page shows the same.
  - C is added. Once B and C are displayed, the page's next GET is held: delayed, never answered by the test. D is added on the server, and 表示中の未承認2件を承認 is clicked.
    - The POST names exactly B and C with their displayed revisions.
    - The store then has A, B and C approved and D pending.
    - After the page's own next poll, the page agrees with the store.
  - The history of A, B and C is only `add` and `approve`: no commitSha, no claimHead. HEAD is unchanged.
  - No request goes to another origin, the live-store paths are never sent, and there are no page errors.
- Command, from the repository root: `python3 -B Maintanance/RegistryApp/test-approvals-e2e.py -v`.
- Passed:
  - 3 of 3 runs on base + patch (about 12.7 s each).
  - Existing tests on base + patch: `test-approvals.py` OK and `test-approvals.cjs` PASS.
- Failed as intended (negative controls):
  - (a) The page's card 承認 sends every pending request: fails at the individual POST.
  - (b) The server approves every pending request: fails, because B gets approved.
  - (c) The server includes other pending requests only for a bulk approval: fails, because D gets approved. The message is the driver's wait timeout for D 承認待ち.
- Not run: the full RegistryApp and V3 suites.
- Startup mode and limitations:
  - The server runs in the default (Markdown) mode. V3 is not cheaply runnable from a clean checkout, for the OPS-187 reason: OPS-047 names the git-ignored `Cache/Astra/AI_GATE.md`. The approval routes and the page are the same in both modes.
  - WebKit only. The global Playwright path is fixed.
  - Cancel, claim and finish are out of scope.
  - The race is controlled by holding one GET. A request added during a POST was not exercised.
- Referenced caches: the live `RegistryApp/local-tools.json` was read once, read-only, for the marked path, which the clone run passed as `REGISTRY_STUDIO_MARKED`. No other cache was used.
- 一時作業物: `/var/folders/x9/2p70phpx3_xdvwx9s6gp35rm0000gn/T/OPS-188.fChl4qn4iQ`・姫・2026-10-20・base `e1d7f8f5e`の使い捨てclone、試験用のDB・Inbox・出力・tools記録・ブラウザの作業・状態「削除済み（2026-10-20、証拠をEvidence/OPS-188へ写したあと削除。残ったprocessなし）」
- No commit and no production integration.

## Acceptance（Astra記入）
2026-10-20：パッチ成果を受入。本体適用・commitは未実施。
- base e1d7f8f5eの独立cloneでSHA-256一致、git apply --check成功。適用後の実接続試験1件成功（12.269秒）。ログ：Evidence/OPS-188/astra-acceptance.txt。
- コードを精読。個別Aのみ、一括B/Cのみ、表示snapshot後に追加したDはpendingを維持することを実HTTP・サーバー記録・ページ表示で照合している。履歴はadd/approveのみ、HEADも不変。
- 姫の否定対照結果は提出記録として確認。Astra側の否定対照再実行はしていない。
- 旧Markdown起動・WebKitの限定合格。V3起動、cancel/claim/finishは未検証。DOMのclick()で操作するため、物理ポインターの到達性・重なり・視覚的使いやすさを保証しない。取得後の描画待ちに固定300msがあり、将来の試験安定性改善候補だが今回の成功を全環境保証に広げない。
- OPS-188のパッチ納品・検収は完了。OPS-186は継続。試験2ファイルのみで実装修正なし。取り込みは別操作。
- 独立検証の一時cloneはログ保存後に削除。試験プロセスはcleanupで終了。

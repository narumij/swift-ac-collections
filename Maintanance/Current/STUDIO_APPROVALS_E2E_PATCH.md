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
未返却。

## Acceptance（Astra記入）
未検収。

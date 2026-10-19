# 連絡の実接続試験と修正パッチ（OPS-187）

## TL;DR
姫への正式依頼。連絡が実サーバーから画面へ届き、本文を読めて、本人の受領が表示へ反映される一巡をTest as Specにする。必要な修正だけをパッチで返す。本番投入やcommitはしない。親は[OPS-186](STUDIO_TEST_AS_SPEC_QUALITY.md)。

## Assignment to Hime — file route, 2026-10-20
User-authorized EXECUTION, DIRECT to the Studio quality goal. Start this one assignment; no additional approval round is needed for the stated scope. Return here; do not revive old OPS-183/184 assignments.

### Small work breakdown
1. Identify the existing letter-reading UI and server routes and encode the promises below as tests.
2. Run the real Studio server with disposable stores and a real headless browser. Exercise the actual page, polling and payloads. Do not mock away letter requests or substitute handwritten server responses.
3. Fix only failures of these promises, rerun focused checks, and return a small applicable patch.

### Promises / acceptance
- Sending a uniquely identifiable letter through the real server API makes that letter appear in the actual work-page letter list; selecting it shows its exact subject/body and correct sender/recipient.
- Viewing/listing does not acknowledge receipt. An explicit receive by the intended recipient through the existing API/CLI records receipt; subsequent actual UI refresh/poll shows the corresponding receipt timestamp/status. No new receive button is required.
- Displayed send/receipt information agrees with the real server records; tests do not use handwritten JSON as the integration oracle.
- Tests fail when the relevant connection is broken (one focused negative control suffices); baseline snapshots alone are not acceptance evidence.
- The test is repeatable from the documented command. Distinguish passed, failed, not run, and remaining limitations. An unmet acceptance promise is unfinished, not completed-with-Limits.

### Bounds and patch delivery
Use a separate scratch copy of the exact Git base with a disposable DB, Inbox, output/cache and tool-state paths and a test-only port. Headless browser and test server startup are authorized. Do not alter/start/stop the user's live server, use port 8088, mutate live stores, or apply the patch to the shared implementation. Do not use stash to manufacture a clean base. Preserve others' uncommitted work; record the precise base SHA and any unavoidable prerequisite separately.
Implementation scope: existing letter server/CLI, work-page letter view/poller and focused test harness only when needed for the above promises. No approval feature work, redesign, broad refactor, auth policy change, or revival of withdrawn member/activity integration. If a new user policy is truly needed, return the narrow issue; checkable facts and implementation choices are your work.
Place `changes.patch` and concise test evidence under `Maintanance/Current/Evidence/OPS-187/`; verify the patch applies to its stated base in the scratch copy. No commit or production integration. Your editable shared scope is this document's Return section and that evidence directory. This file route is the current assignment; no duplicate communication-DB dispatch.

## Return（姫記入）
未返却。Include base SHA, patch path/hash, changed-file breakdown, exact test command/results, remaining gaps, and one line identifying referenced caches (none/unknown acceptable). Keep the return concise; evidence belongs in the evidence directory.

## Acceptance（Astra記入）
未検収。

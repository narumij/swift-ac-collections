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
Returned (Hime, 2026-10-20). All five promises pass at the base; no implementation change was needed, so the patch adds the test only.
- Base: `689ba68f9e1be76f09034f36c33af731deb25523`, in a disposable clone.
- Patch: `Evidence/OPS-187/changes.patch`, sha256 `5e640c4f030f78ce9bedf583503a725f18c1fce43bd46bc33ace81c6e8165720`. It adds two new files and changes no implementation:
  - `RegistryApp/test-letters-e2e.py` (134 lines)
  - `RegistryApp/letters_e2e.cjs` (80 lines)
  - Applies cleanly to an export of the base (`patch -p1 --dry-run`). `git apply --check` could not be run here because the environment's hook timed out.
- What the test does: it starts a real `serve.py` on port 0 with a temporary letters DB, Inbox, output and tools record. Through the real `comm.py` it sets the senders and sends a letter with a unique multi-line body. The real page in headless WebKit then:
  - shows the letter in `#letters-list` through its own poller;
  - shows the exact body in the detail, including markup and CRLF.
  The test then checks that:
  - the server holds only the `sent` event after viewing;
  - after `comm.py letter receive --revision 1`, the page's own poll shows state 受領 and 受領日時 equal to the server's `receivedAt`;
  - 送信日時 equals the server's `sentAt`.
  The expected times are formatted in the browser from the server's own record, never from a fixture. The test also checks GET only, no other origins, no page errors, and that the live-store paths are never sent: `/activity-*`, `/continuity`, `/approval-probe` and `/work-progress` are aborted before sending.
- Command, from the repository root: `python3 -B Maintanance/RegistryApp/test-letters-e2e.py -v`.
- Results:
  - Passed: 3 of 3 runs on base + patch, about 7 s each.
  - Negative controls, both failed as intended at the receipt step:
    - (a) the page ignores `receivedAt`
    - (b) the server brief returns no `receivedAt`
  - Existing tests pass on base + patch: `test-studio-letters.py` 25 OK, `test-view-model-letters.cjs` PASS.
  - Not run: the full RegistryApp and V3 suites.
- Remaining gaps:
  - The test runs the server in the default (Markdown) mode. V3 mode cannot start from a clean checkout of the base: the Registry row OPS-047 names `Maintanance/Cache/Astra/AI_GATE.md`, which is git-ignored, and V3 sync refuses missing documents. The letter routes and the page code are the same in both modes. This prerequisite affects production restarts from a fresh checkout; it is reported here, not fixed.
  - In a clone without `local-tools.json`, sync needs `REGISTRY_STUDIO_MARKED`. The live record is copied read-only when present.
  - WebKit only. Letters have no subject field, so "subject/body" is checked as task, sender → recipient and the exact body.
- Referenced caches: the live `RegistryApp/local-tools.json` was read once to find the marked path (read-only). The live `Cache/Astra/AI_GATE.md` was identified as missing from the clone (`git check-ignore`) and was not copied.
- 一時作業物: `/var/folders/x9/2p70phpx3_xdvwx9s6gp35rm0000gn/T/OPS-187.goA6zDDM2P`・姫・2026-10-20・base `689ba68f9`の使い捨てclone、試験用のDB・Inbox・出力・tools記録・ブラウザの作業・状態「削除済み（2026-10-20、証拠をEvidence/OPS-187へ写したあと削除。残ったprocessなし）」
- No commit and no production integration.

## Acceptance（Astra記入）
2026-10-20：パッチ成果を受入。本番への適用・commitは未実施。
- 基準689ba68f9の別の一時コピーでSHA-256一致、git apply --check成功、パッチ適用後の試験1件成功（8.057秒）。独立実行ログはEvidence/OPS-187/astra-acceptance.txt。
- 試験コードを確認。実CLI→実HTTP→実DB→実ページのpoll→本文表示→本人受領→表示更新を通す。閲覧が受領を作らないこと、本文・送受信者・時刻も検査する。姫の否定対照ログも確認したが、Astra側で否定対照の再実行はしていない。
- 件名フィールドは存在しないためtask・送受信者・本文を対象とした。新しい件名機能は追加しない。
- 旧Markdown起動モードでの限定合格。V3での起動・作業ページ全体・承認の品質は保証しない。V3クリーンコピーの参照文書不足は後続候補であり、今回の連絡経路の試験追加から分ける。
- Playwrightのローカル固定パスという実行環境条件がある。汎用CI対応は今回の完了条件ではない。
- 実装修正なし。納品パッチは新しい試験2ファイルのみ。OPS-187はパッチ納品・検収まで完了、OPS-186は継続。
- Astra一時コピー：/tmp/astra-ops187-zb26g8fn。実行後processは試験のcleanupで終了。ログを保存して一時コピーを削除する。

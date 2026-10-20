# 起動失敗時の保全と再起動通知の試験・修正（OPS-189）

## TL;DR
OPS-186の次の1件。使用中ポートで二重起動を試みても配信中ファイルを変えず、連絡DBコード変更時には再起動おすすめが届くことを確かめる。疑いを再現し、必要最小限の修正を試験付きパッチで返す。本番適用・commitはしない。

## Assignment to Hime
User-authorized EXECUTION, dispatched through the communication DB. Start this bounded task and return through the same letter. Input: STARTUP_REFRESH_TESTS_CLOSE_READING.md, sections 1 and 3. Treat reported defects as hypotheses to reproduce.

Work breakdown:
1. In a disposable checkout, encode the two promises below as failing tests where the base violates them.
2. Make only the necessary startup/runtime-fingerprint fixes.
3. Run focused regression and a negative control, then deliver an applicable patch.

Acceptance:
- With a test port already occupied, launching the real server against a pre-existing isolated output fails without changing the contents of index.html, registry.json or the tools record. Assert preserved bytes, not just an error message. No live ports or files are involved.
- Normal startup still serves a valid page. If generation fails after acquiring any socket, the process exits and releases that socket; never serve incomplete output. Verify these paths with a bounded real-process test.
- Editing studio_store.py in the scratch copy after server startup makes real /server-status report restartRecommended and the actual page show its restart recommendation. Verify the unchanged baseline too; do not mock runtime_status to establish the result.
- Tests detect breaking the added protection. Distinguish reproducible defects, test gaps and explicit compatibility choices. Keep evidence and commands reproducible.

Bounds:
Use an exact recorded Git base in a separate scratch copy. Disposable stores, Inbox, output, tools and test-only ports; real headless browser allowed. No port 8088, live DB mutation, user's server control, shared implementation edits, stash or commit. Do not change the default/legacy-mode policy. Atomic /sync publication, timeout recovery and missing-document policy are later work, not this task. Do not integrate OPS-187/188 patches implicitly: state any dependency explicitly; prefer an independent patch.
Editable code in scratch: serve.py runtime/startup and narrowly necessary existing helpers plus focused tests. No generalized module discovery framework or broad refactor. Existing UI behavior should suffice; if a UI repair is necessary, restrict it to the existing restart notice.
Delivery: changes.patch with exact base/hash, changed-file breakdown, test commands/results and limitations. Check application in a clean copy of the base. Only this Return section and `Maintanance/Current/Evidence/OPS-189/` may be edited in the shared checkout. A concise returned event belongs in the same DB letter. No new approval request is needed for the stated test scope; unresolved product policy is returned separately, not invented.

## Return（姫記入）
未返却。

## Acceptance（Astra記入）
未検収。

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
Returned (Hime, 2026-10-20; letter LTR-20261020-231CA787… received and started).

Both reported defects reproduced at the base and are fixed.
- **Occupied port:** the base ran sync before binding, so a launch on a used port rewrote `index.html`, `registry.json` and the tools record, then failed.
- **Restart notice:** `studio_store.py` was not watched, so editing it did not recommend a restart.

Base: `e1d7f8f5efce656698878cddbcc5679f0953bbe5`, in a disposable clone.

Patch: `Evidence/OPS-189/changes.patch`, sha256 `c34b15d96667b94ded720801da402d66bccb37c6f231905765dba6213e5f3c76`. It applies cleanly to an export of the base (`patch -p1 --dry-run`) and does not depend on the OPS-187/188 patches.

Files:
- `serve.py` (+13 −3):
  - `main` takes the port before sync. A used port exits 1 with "nothing was generated".
  - A failed sync closes the socket and exits non-zero, as before. Nothing is served before sync completes.
  - `studio_store.py` is added to `runtime_fingerprints`.
  - No policy change: the default mode, `--v3-*` and `--output` are unchanged.
- `test-startup-safety.py` (new, 5 tests). Each run uses a private copy of the Maintanance tree and its own output, tools record, DB and Inbox, so editing `studio_store.py` never touches the checkout. All servers are real processes on test-only ports.
  1. Occupied port: the pre-existing bytes of the three files are kept, and nothing is generated.
  2. Normal startup serves the page that `sync.py` generated.
  3. A sync failure exits non-zero, serves nothing, keeps the previous output, and leaves the port bindable again.
  4. Editing `studio_store.py` after startup: the real `/server-status` changes from false to true with `['studio_store.py']`. The real page's `#serverRestartNotice` changes from hidden to shown, triggered by the page's own focus check (it also checks every 30 s).
  5. Every module of RegistryApp that serve retains is fingerprinted.
- `startup_notice_e2e.cjs` (new): the WebKit driver for test 4.

Command, from the repository root: `python3 -B Maintanance/RegistryApp/test-startup-safety.py -v`. In a clone without `local-tools.json`, set `REGISTRY_STUDIO_MARKED`.

Results:
- **Base:** `base-before-fix3.txt` — 1 and 4 fail, plus 5 (the module test), as the defects predict. 2 and 3 pass.
  - On the base, 3 passes trivially, because no socket existed yet when sync failed.
  - `base-before-fix.txt` and `base-before-fix2.txt` are earlier harness errors (an incomplete copied tree, and a JSON placeholder that crashed sync), kept for traceability.
- **Fixed:** 3 of 3 runs, 5/5 OK.
- **Negative controls on the fixed code:**
  - Sync before bind: test 1 fails.
  - `studio_store.py` unwatched: tests 4 and 5 fail.
- **Existing tests:**
  - `test-serve.py`: 6 OK.
  - `v3/test_serve_v3_mode.py`: 11 OK, 1 FAIL (`test_isolated_launch`). It fails identically at the base (`base-v3-isolated-launch.txt`): a clean clone lacks the git-ignored `Cache/Astra/AI_GATE.md` (the OPS-187 finding). It is not caused by this patch.
- Not run: the other suites.

Distinctions:
- Reproduced defects: the occupied-port rewrite, and the unwatched `studio_store.py`.
- Test gaps closed: the real-process occupied port, the real-process restart notice, and the coverage of the module list.
- Not provable here: an explicit `server_close()` on failure is not distinguishable from process exit, because the OS frees the socket either way. Clients that connect during generation wait, and are dropped if it fails; this was not exercised.

Found, not fixed (out of scope):
- `sync.py` crashes (KeyError in `diff`) when a previous `registry.json` is valid JSON of another shape. An unreadable one is handled.

Referenced caches: the live `RegistryApp/local-tools.json` was read once, read-only, for the node and marked paths. No other cache was used.

- 一時作業物: `/var/folders/x9/2p70phpx3_xdvwx9s6gp35rm0000gn/T/OPS-189.UZC2VcgDnC`・姫・2026-10-20・base `e1d7f8f5e`の使い捨てclone、試験用の出力・tools記録・コピーしたサーバー・ブラウザの作業・状態「削除済み（2026-10-20、証拠をEvidence/OPS-189へ写したあと削除。残ったprocessなし）」
- No commit and no production integration.

## Acceptance（Astra記入）
2026-10-20：限定パッチ成果を受入。本体適用・commit・本番再起動は未実施。
- base e1d7f8f5eの独立cloneでパッチSHA-256一致、git apply --check成功。適用後、新規5件（4.997秒）・既存test-serve.pyの6件（3.155秒）が成功。ログはEvidence/OPS-189/astra-acceptance.txt。
- 実装差分を確認。bindを生成前に移し、生成例外時にsocketを閉じる。studio_store.pyをfingerprintへ追加。既存の起動モード方針は変更しない。
- 実プロセスで使用中ポートの出力bytes保全、正常配信、生成失敗後の終了とポート解放を確認。実HTTPとWebKitで変更前後の再起動通知も確認した。
- 姫のbase失敗・否定対照・V3試験の記録を確認。Astra側ではそれらを再実行していない。V3のクリーンcloneでAI_GATE.mdが欠ける既存失敗は残り、V3全体合格とは扱わない。
- scope外の/sync公開途中・中断回復・別shapeのregistry.json、生成中の接続待ちは未解決。今回のパッチの保証に含めない。
- 独立検証コピーはログ保存後削除。試験プロセスはcleanupで終了。OPS-189はパッチ納品と検収まで完了、親OPS-186は継続。

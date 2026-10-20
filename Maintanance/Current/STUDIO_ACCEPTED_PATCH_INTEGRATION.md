# 受入済みStudioパッチの統合（OPS-191）

## TL;DR
OPS-187（連絡試験）・188（承認試験）・189（起動修正と試験）は検収済みだが、本体には未適用。3件を同じ基準へ統合し、通常の試験として実行できるパッチを返す。新機能・別件修正・本番操作・commitは含まない。

## Assignment to Hime
User-authorized EXECUTION under OPS-186. Communication DB is the dispatch/receipt/return route. Start this one assignment.

Base: 01e8254a490dbe3faaeb4eb74ded4ff5f6d183f0. In a disposable checkout, apply the accepted patches at Current/Evidence/OPS-187/changes.patch, OPS-188/changes.patch and OPS-189/changes.patch. Their acceptance records define the accepted scope. No shared implementation edits.

Work breakdown and acceptance:
1. Check hashes from the respective returns and apply all three patches to this base. Resolve only mechanical conflicts necessary for integration; report any semantic conflict before changing the accepted behavior.
2. Run the three new suites together on the combined result (letters, approvals, startup safety). Run test-serve.py, test-studio-letters.py, test-view-model-letters.cjs and test-approvals.py/cjs as the focused regression set. Report failures honestly; no full-suite requirement.
3. Add a short README section with the exact commands, required runtime, isolation and known limits. No new test runner/framework or large refactor. Tests must live at their normal RegistryApp paths in the delivered patch, not only as evidence.
4. Return one combined changes.patch applicable to the stated clean base, with SHA-256, file breakdown, commands/results and unresolved gaps. The implementation delta remains OPS-189's startup/fingerprint fix; other changes are accepted tests and their usage documentation.

Use only disposable stores, Inbox, generated output/tools records, a separate scratch copy and test-only ports. Headless browser/server execution is authorized. Never port 8088, live DB writes, user's server control, stash, Git commit or production deployment. Legacy/WebKit limitations and the known V3 missing AI_GATE.md failure remain documented; do not repair those or expand to /sync publication/recovery in this assignment. If a required existing test fails, establish whether it fails on the base and return the evidence rather than rescuing unrelated code.

The only editable shared scope is this Return section and `Maintanance/Current/Evidence/OPS-191/`. Return via the same DB letter, concise summary plus this canonical reference. No extra decision request for already authorized integration steps.

## Return（姫記入）
Returned (Hime, 2026-10-20; letter LTR-20261020-DB9235AD…, the re-sent one, received and started).

- Base: `01e8254a490dbe3faaeb4eb74ded4ff5f6d183f0`, in a disposable clone.
- Inputs: the three patch hashes match the returns. OPS-187 `5e640c4f…`, OPS-188 `49911534…` and OPS-189 `c34b15d9…` applied in that order with `patch -p1`. No conflicts, mechanical or semantic: the three patches share no file. Each adds its own files, and only OPS-189 changes `serve.py`.
- Combined patch: `Evidence/OPS-191/changes.patch`, sha256 `8ef8de8cfea36cd6bfe57d9049c01fe47dde54da07b4c3ebe2b0f471d69bdea0`. It applies cleanly to an export of the base (`patch -p1 --dry-run`). It touches 8 files under `Maintanance/RegistryApp/`, +734 −3:
  - Implementation, unchanged from OPS-189: `serve.py` (+13 −3).
  - Accepted tests at their normal paths:
    - `test-letters-e2e.py` and `letters_e2e.cjs`
    - `test-approvals-e2e.py` and `approvals_e2e.cjs`
    - `test-startup-safety.py` and `startup_notice_e2e.cjs`
  - Usage: `README.md` (+26), a new section 「実サーバー・実ブラウザの試験（OPS-187〜189）」 under 検証範囲. It gives the three commands, the runtime needed (node, global Playwright WebKit, node/marked for sync, git), the isolation, and the known limits: default mode only, V3 blocked by the missing `AI_GATE.md`, WebKit only, DOM `click()`, cancel/claim/finish out of scope, and the race made by holding one GET.
- Results on base + patch (logs in `Evidence/OPS-191/`, command `run.sh`). All pass:
  - New suites:
    - `test-letters-e2e.py`: 1 OK
    - `test-approvals-e2e.py`: 1 OK
    - `test-startup-safety.py`: 5 OK
  - Regression set:
    - `test-serve.py`: OK
    - `test-studio-letters.py`: OK
    - `test-view-model-letters.cjs`: PASS
    - `test-approvals.py`: OK
    - `test-approvals.cjs`: PASS
  - Not run: the other RegistryApp suites and the V3 suites.
  - In the clone, marked was given through `REGISTRY_STUDIO_MARKED`.
- Unresolved gaps: those already recorded and not repaired here — V3 startup from a clean checkout (`AI_GATE.md`), WebKit only, and `/sync` publication and recovery.
- Referenced caches: the live `RegistryApp/local-tools.json` was read once, read-only, for the marked path. No other cache was used.
- 一時作業物: `/var/folders/x9/2p70phpx3_xdvwx9s6gp35rm0000gn/T/OPS-191.ChRKgTrqRk`・姫・2026-10-20・base `01e8254a4`の使い捨てclone、試験用の出力・tools記録・DB・Inbox・ブラウザの作業・状態「削除済み（2026-10-20、証拠をEvidence/OPS-191へ写したあと削除。残ったprocessなし）」
- No commit and no production integration.

## Acceptance（Astra記入）
2026-10-20 受入。SHA-256を照合し、指定baseへの適用を独立確認。新規3 suiteと指定の回帰5 suiteは全て成功（[独立検証ログ](Evidence/OPS-191/astra-acceptance.txt)）。serve.pyの差分は受入済み起動修正で、追加の実装修正なし。ユーザーの「パッチ適用」に基づき作業ツリーへ適用した。実行中の本番サーバーは再起動していない。V3・他browser・/sync回復等への保証は拡張しない。

一時作業物: Astraの独立検証clone `/tmp/astra-ops191-z1jf1tju`（realpath `/private/tmp/astra-ops191-z1jf1tju`）、2026-10-20作成。ログ保存後に削除済み。保持条件なし。

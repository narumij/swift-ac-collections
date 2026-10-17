# ASan strip_envの固定版検証案

> **確定範囲（2026-10-17、OPS-066試行）** 受入済み：固定版`81204d22`・記載macOS環境での既定条件とstrip_env=0の比較（既定条件は3対象とも失敗、strip_env=0ではProbe 3件・DeathTests 213件・内部カバレッジ5件が成功、Codex受入）。証拠：返却commit `46d50288`、受入commit `7a092b72`、`Evidence/RBT-049/`。未確認：この固定版比較のLinux実施・他toolchain・全体suite・リリース可否。この調査の受入には製品・Tests・CIへの適用判断を含まない。Linux候補CIへの別途追加と成功報告は本書末尾に記録済み。次の確認点：Linux候補CIの成功報告はQUALITY-002側でrun URL・対象SHAの保存待ち（本書末尾の節）。状態の正本はRegistry。

RBT-049 / 作成Astra / 2026-10-16。2026-10-17ユーザーの「RBT-049をひめに依頼して」によりACTIVE。調査Claude（姫）、受入・統合Codex。

入力はASAN_DEATH_TEST_INVESTIGATION.mdの追加受入とCP-20261016-014の原報告・ログ。
次の品質検証で対象commitとSwift版・OS・環境変数・traitを固定し、隔離環境で既定条件とstrip_env=0を比較する。最小Probeの検出器負例、DeathTests、RedBlackTreeInternalCoverageTestsの順に検証範囲を明示し、完全ログと終了statusを保存する。全体suiteは所要時間・対象を決めてから扱う。

製品・Tests・CIは変更しない。Linuxへの効果は別環境で確認するまで主張しない。compiler-rtのstrip_env実装も原因説明を確定する際に照合する。完了は固定版で成立・不成立・未検証が区別された調査結果の受入。CI適用は後続判断。0.6.0の新しい必須ゲートにはしない。

## Assignment to Claude — 2026-10-17

The user selected this task explicitly. This bounded discovery validates the existing
strip_env evidence; it does not authorize adopting a workaround.

### Fixed inputs and scope

- Pin the repository input to `81204d22` (full SHA to be recorded in Return). Existing uncommitted queue reconciliation is unrelated and must be preserved.
- Read the additional acceptance in `ASAN_DEATH_TEST_INVESTIGATION.md`, CP-20261016-014 in `../Archived/CLAUDE_PENDING_TASKS_RECONCILED_2026-10-16_4.md`, and the linked original report, Probe, and logs under `Evidence/ASAN-strip-env-2026-10-16/`.
- Follow `Tests/CLAUDE.md`, the relevant test workflow, and COMMONS temporary-work rules. Use an isolated copy/build directory; do not modify or clean shared build output.
- On the available macOS environment, record full commit SHA, Swift/Xcode and OS versions, architecture, runtime path/version where identifiable, exact commands, relevant environment variables, and selected test traits. Hold inputs constant between default ASan settings and `ASAN_OPTIONS=strip_env=0`; record any other required options explicitly.
- Compare the minimal Probe first, including normal exit, trap, and the intentional ASan memory-error detector control. Then compare DeathTests and RedBlackTreeInternalCoverageTests at the pinned revision. Preserve complete stdout/stderr, exit status, test/issue counts, and any timeout. A passing test command alone does not establish that the detector control detected the intended error.
- Inspect the matching compiler-rt strip_env implementation when establishing the mechanism. Record source URL/revision and correspondence to the installed runtime; if correspondence cannot be established, distinguish source-based inference from confirmed behavior.
- Do not run the full suite or provision another platform. Linux effectiveness remains unverified. Do not change products, existing Tests, Package.swift, CI, trait definitions, or release gates. At execution time, select the traits required to exercise the intended tests (including ENABLE_DEATH_TESTS where needed), record them, and keep the same selection for both comparison conditions.

### Editable output and stopping conditions

You may append only to the Return section below and create task evidence under
`Maintanance/Current/Evidence/RBT-049/` (README, exact commands, Probe fixture if needed,
complete logs and exit statuses). Root CLAUDE.md's optional observations delegation remains effective.
Do not edit Registry, this assignment, prior evidence, or another task's return.
No commit, branch, push, GitHub operation, CI run, or Studio regeneration is delegated.

If a required environment/input is unavailable, detection is invalid, or proceeding needs
an implementation/policy change, preserve the completed evidence and return the blocker;
do not substitute a different revision or broaden the work. Distinguish failure from
unavailable or unverified cases. Do not infer product-wide ASan success or release readiness.

Return: fixed inputs and environment, changed files, exact commands and evidence links,
per-case comparison (default vs strip_env=0), detector-control validity, confirmed mechanism
and remaining uncertainty, applicability limits, blockers, and work completion/scope release.
Acceptance requires results reproducible from the saved evidence with established,
failed, and unverified claims separated. The coordinator performs acceptance and Registry updates.

The assignment and inputs are fixed on handoff. Claude owns only the specified output
scope until Return; the coordinator will not edit it while the work is in progress.

## Return

### Claude return (2026-10-17, 姫)

**Fixed inputs and environment.** Repository `81204d227e14710c5e1732afcf421b4252899e79` (git worktree in an isolated `mktemp` directory, own `.build`). macOS 27.0.1 (26A434), arm64, Xcode 27.0 (27A266a), Apple Swift 6.4 (swiftlang-6.4.0.34.1, clang-2100.3.34.1). ASan runtime inserted by `swift test`: `…/XcodeDefault.xctoolchain/usr/lib/swift/clang/lib/darwin/libclang_rt.asan_osx_dynamic.dylib` (symlink to `…/usr/lib/clang/21/lib/darwin/`), SHA-256 `3a2b9562…7579bd7`. Shell started with `ASAN_OPTIONS` and `DYLD_INSERT_LIBRARIES` unset. Traits: the default set, no `--traits` (on macOS `DEATH_TEST` is defined by the platform condition in Package.swift). Only `ASAN_OPTIONS=strip_env=0` differs between the conditions; the repository runs share one build (`--skip-build`).

**Changed files.** Only new evidence under `Evidence/RBT-049/` and this Return. No product, Tests, Package.swift, CI, Registry or other-task edits. No commit.

**Exact commands and evidence.** `Evidence/RBT-049/commands.sh`, `environment.txt`, `logs/` (each log: command on line 1, `exit=` last).

**Per-case comparison (default → strip_env=0).**

| Case | default | strip_env=0 |
| --- | --- | --- |
| Probe (3 tests) | exit 1. cleanChild and trapChild get SIGABRT; overflow control fails (no ASan report). Variable at suite init `<unset>` | exit 0. 3 passed. Variable = ASan dylib path |
| DeathTests (213 tests, 20 suites) | exit 1. 360 issues, 269 of them SIGABRT | exit 0. 213 passed |
| RedBlackTreeInternalCoverageTests (5 tests, 1 suite) | exit 1. 1 issue: `_TrackingTagSealing.sealのカバレッジ確保` expected SIGTRAP, got SIGABRT | exit 0. 5 passed |

The DeathTests figures match the 2026-10-16 working-copy run exactly (213 / 360 / 269). The pinned revision now replaces that unrecorded working copy.

**Detector-control validity.**
- Established for strip_env=0: in a child process, the intentional heap-buffer-overflow was reported (`AddressSanitizer: heap-buffer-overflow`), and the repository test binary links `@rpath/libclang_rt.asan_osx_dynamic.dylib` (39 `__asan_` imports). So the passing strip_env=0 runs are ASan-instrumented, not silently uninstrumented.
- Under the default settings the control is invalid by construction (the child aborts before it can detect anything).

**Mechanism.**
- Confirmed by runtime behaviour: with the default setting, the parent's `DYLD_INSERT_LIBRARIES` no longer contains the runtime at suite init. A child started from it prints `ERROR: Interceptors are not working. This may be because AddressSanitizer is loaded too late…` and `"interceptors not installed" && 0`, then aborts with SIGABRT. This was seen in 2 Probe lines and 182 DeathTests lines, and in none of the strip_env=0 logs.
- Source correspondence: in llvm/llvm-project `50b1c281`, `InitializePlatformEarly()` calls `VerifyInterceptorsWorking()` (which raises the `RAW_CHECK` above) and then `StripEnv()`. `StripEnv()` removes the runtime from `DYLD_INSERT_LIBRARIES` unless `strip_env` is false, and the flag is declared `COMMON_FLAG(bool, strip_env, true, …)`. Excerpts are in `compiler-rt-excerpts.txt`.
- The installed runtime contains the same flag help text and the same error strings. It is an Apple build from internal sources (`clang_compiler_rt`, clang-2100.3.34.1), so the exact source revision is not established. The match is by identical strings and behaviour, not by revision.

**Remaining uncertainty and limits.**
- RedBlackTreeInternalCoverageTests does not capture child stderr, so there the interceptor error is inferred (consistent SIGABRT), not observed.
- Not verified: Linux (the mechanism is the macOS DYLD path), other Swift or Xcode versions, the full suite under ASan, the non-native build system, and CI.
- Product-wide ASan success or release readiness is not claimed. Adopting `strip_env=0` in local scripts or CI remains a separate decision.

**Blockers.** None.

**Work completion / scope release.** Done. The temporary worktree and directory were removed; a pre-existing unrelated prunable worktree under `/private/tmp` was left untouched. Output scope released to the coordinator.

## Codex受入（2026-10-17）

ユーザーの受入処理依頼に基づき、Claude原Returnを保持して保存証拠を照合した。RBT-049の固定版・限定調査を受入、DONEとする。製品・Tests・CIへの適用判断は含まない。

- 固定入力81204d227e14710c5e1732afcf421b4252899e79、環境記録、実行コマンド、Probe、ビルドと6本の比較ログを確認。固定版Package.swiftではmacOSでDEATH_TESTが有効となるため、追加traitなしの選択と整合する。既存Probe.swiftとの一致も確認した。
- ログ末尾の終了statusと集計は、Probeが既定exit=1・3 issues／strip_env=0でexit=0・3件成功、DeathTestsが既定exit=1・213件360 issues／strip_env=0でexit=0・213件成功、内部カバレッジが既定exit=1・5件1 issue／strip_env=0でexit=0・5件成功。ASanビルドはexit=0。
- Probeの負例は子プロセスのstderrにheap-buffer-overflowが含まれることをassertする。strip_env=0でこのassertを含む3件が成功し、既定ではassert失敗・interceptorエラーを確認した。成功時の子stderr全文はログに出力されないため、検出確認の証拠は保存Probeのassertと成功結果であり、生のASan診断全文を保存したとはしない。環境記録のASanリンク情報はClaudeの採取証拠として扱う。
- 原Returnの「Interceptors are not working」の出現行数は補正する。保存ログを文字列で数えるとProbe既定1行、DeathTests既定91行、strip_env=0はともに0行。原文の2行・182行は採用しない。DeathTestsのSIGABRTは単純な行数とは区別し、issue記録を単位に扱う。件数の補正は比較結果を変えない。
- compiler-rt保存抜粋ではstrip_env既定trueとDYLD_INSERT_LIBRARIESからruntimeを除く処理が示される。Apple実装と公開ソースの厳密な版対応は未確定のまま。内部カバレッジの子stderrに基づく原因確定も行わない。

今回の受入では試験やネットワーク取得を再実行していない。受入範囲は保存証拠による固定版・記載macOS環境での比較調査。Linux、他toolchain、全体suite、CI成功、製品全体のASan合格、リリース可否は未検証。strip_env=0の恒久採用は別判断であり、後続実装や新規taskを開始しない。commit・Studio再生成は行っていない。

## Linux候補CIへの別経路の追加（2026-10-17 / Astra）

CP-20261017-006をQUALITY-002へ統合。ユーザーの明示依頼で8631a031がcandidate.ymlへLinux ASan＋Death Test jobを追加し、reportの合否にも接続した。ユーザーは本会話で/test releaseのASan成功を報告し、Testing Library 6.4.1、x86_64-unknown-linux-gnu、218件21suite成功のログ抜粋とworkflow全文を提示。workflowの--sanitize address、ENABLE_DEATH_TESTS、対象filterをAstraが確認した。strip_env=0は設定されていない。

成功報告と提示資料を受け入れる。GitHub run URL・対象SHA・完全artifactとの紐付けは未保存で、再現可能なCI証拠としての完成はQUALITY-002に残す。「Linuxでは常に対処不要」と一般化しない。RBT-049の固定macOS調査のDONE範囲は変更しない。既に明示されたjob追加を再び採用未承認に戻さず、RELEASE-085の新たな必須判断にも加えない。

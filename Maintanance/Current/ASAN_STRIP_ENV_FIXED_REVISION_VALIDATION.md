# ASan strip_envの固定版検証案

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

Awaiting Claude.

# 浅い点検（参照パス・commit hash）— `Maintanance/Current/`全72文書

2026-10-17 / 姫（Opus 5.5）/ 入力版 `d6e6fab6`。ユーザー「現在のものの全体についてチェックが浅いものだけやって、深いものはあとまわしに」。CP-20261017-013の第1区切り。

「浅い」＝読まずに機械的に確かめられる点検事実。今回は(1)文書が参照するパスが今あるか、(2)引用されたcommit hashがこのrepositoryにあるか、の2種類。中身の主張（API・挙動・CI結果など）は「深い」として後回し。

## 1. 参照パス

Markdownリンクと、`Maintanance/` `Sources/` `Tests/` `Benchmarks/` `.github/` `Documentation/` `../`で始まるバッククォート内のパスを機械抽出（72文書）。見つからなかった23件を、別の基準・行番号付き・gitの履歴で仕分けた。

| 仕分け | 件数 | 文書と参照 | 扱い |
| --- | --- | --- | --- |
| 実在（基準・行番号の違いだけ） | 4 | AI_TECHNICAL_ORIENTATION（`../Package.swift`・`../README.ja.md`はrepository根基準なら実在）、MAINTENANCE_HEALTH_CHECK（`…/BareArray/README.md:22`・`…/NextPermutationModule.md:42`） | 問題なし |
| 改名・移動で古い | 4 | AtCoder2025CompatibilityPlan（`Sources/PermutationModule/NextPermutations.swift`・`…/Compatibility/AtCoder2025/`）、EXTERNAL_TYPE_EXTENSION_AUDIT（`Sources/PermutationModule/NextPermutations.swift`）。いずれも`1f87e37a`（2026-10-15）で`Sources/NextPermutationModule/`へ移動 | 修正案（下の追記） |
| 改名・移動で古い（作業中の文書） | 2 | MAPPED_VALUES_VIEW_CONTRACT_DECISION（RBT-026 ACTIVE）のリンク`DOCUMENTATION_MILESTONES.md`はCurrentに存在したことがない（現行は`../MILESTONES.md`か`../Milestones/`と推定、未確認）。StrictMemorySafetyReadiness（RBT-007 ACTIVE）の`Tests/PermutationTests/PermutationDeathTests.swift`は`5efc1a9c`（PERM-012、2026-10-07）で削除 | 作業中なので追記しない。担当へ返す |
| 時点の記録（当時は実在） | 10 | MAINTENANCE_HEALTH_CHECK_2026-10-16（9件：旧`MAINTENANCE.md`・`PROGRESS_OVERVIEW.md`・`QUALITY_REQUIREMENTS.md`・`Tests/TESTING.md`・旧Permutation移行文書など）、OPS-072正本の試行記録（旧パスを例として引用） | 問題なし（日付つきsnapshotの記述は当時の事実） |
| 生成物の移動 | 3 | REGISTRY_STUDIO_MILESTONE_CONNECT・TASK_REGISTRY_LAYOUT_ADVICEの`RegistryApp/index.html`・`registry.json`は`bbddb7ff`で`index.template.html`と`Cache/RegistryStudio/`（生成先）へ | 記録としては問題なし。手順として読む人向けには注記があるとよい（深い方へ） |
| 未作成（提案・予定のまま） | 3 | RELEASE_CANDIDATE_BASELINE_INVESTIGATIONの`Benchmarks/Libraries/CI-baseline-new-tasks.txt`・`Benchmarks/Scripts/filter_library_for_baseline.py`（調査時の提案）、RELEASE_SHAPING_WORKER_REQUEST_DRAFTの`Maintanance/User/…`（完成後の移動先） | 提案・予定が実施されたかは深い方へ |

## 2. commit hash

バッククォート内の7〜40桁の16進（数字と英字を両方含むもの）97件を`git cat-file`で照合。80件はcommitとして存在。残り17件はすべてcommit以外だった：ファイルのSHA-256先頭（MAINTENANCE_HEALTH_CHECKの11件、GATE_DECISION_DIGEST_PROPOSAL、TASK_REGISTRY_APP_CLAUDE_ADVICE）、gitのblob（HIST_002_EXPLORATIONの3件）、外部repositoryの版（ASAN_STRIP_ENV…の`50b1c281`はllvm-project）。**存在しないcommitを指す記述は0件。**

## 3. 追記した文書（追記範囲：OPS-072の立案）

- `AtCoder2025CompatibilityPlan.md`（PERM-079はWAITING_USERで作業中でない）
- `EXTERNAL_TYPE_EXTENSION_AUDIT.md`（Registryに紐づくtaskなし）

追記しなかった：作業中（ACTIVEで担当あり）のRBT-026・RBT-007の文書。上表の内容を担当へ返す。

## 4. 後回し（深い点検）

読む・動かす・判断が要るもの。順番の目安はDONEのtaskの文書から。

- 主張が実装と合っているか：PUBLIC_API_NAMING_DECISIONS、RED_BLACK_TREE_OUTLINE_AUDIT、MEMOIZE_DEPENDENCY_INVESTIGATION、INDEX_UPDATE_FAILURE_COW_*（RBT-047/048）
- 性能・ベンチマーク：PERMUTATION_PERFORMANCE_GAP_REVIEW（今日の計測で更新できる見込み）、BENCHMARK_*、PERFORMANCE_CI_CHANGE_GUIDE
- CI・リリース：RELEASE_CANDIDATE_*（提案ファイルが実施されたか）、RELEASE_CI_RECOVERY、DOCUMENTATION_CI_PLAN
- 予定の移動：RELEASE_SHAPING_WORKER_REQUEST_DRAFT（完成したか）
- 手順文書の生成物移動の注記：REGISTRY_STUDIO_*、TASK_REGISTRY_*
- 作業中の文書（RBT-026・RBT-007）の参照修正：担当の判断

所要：ツール呼び出し約10回。

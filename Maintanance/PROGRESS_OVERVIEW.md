# 開発・メンテナンス進捗一覧

最終更新: 2026-10-07 / Codex

この文書のTask Registryを、CodexとClaudeが作業を再開するときの唯一の入口とする。まずRegistry
だけを読み、選択したtask行が示す詳細正本だけを追加で読む。2026-10-07までの完了チェック、判断待ち、
旧サマリーは`Archived/PROGRESS_OVERVIEW_HISTORY_2026-10-07.md`へ移した。

## Task Registry

**現在の律速:** 外部（`swift-collections` ContainersPreviewの`Container.Index`要件）。
Index契約と関連taskは、この外部条件が安定するまで最終確定できない。

| ID | 状態 | 担当 | 項目 | 再開・完了条件 | 詳細正本 |
| --- | --- | --- | --- | --- | --- |
| `RBT-001` | `WAITING_EXTERNAL` | User / Codex | Index完了ゲート | 公開Index表現・完了範囲と`Comparable`採否を確定し、Index契約全体を閉じる | `RED_BLACK_TREE_REMAINING_TASKS.md` |
| `RBT-010` | `WAITING_EXTERNAL` | User / Codex | Index完了ゲートのうち公開Index表現と完了範囲 | Container要件の安定後、公開Indexと内部`SealError`の分離、1.0での完了範囲を決定 | `RED_BLACK_TREE_REMAINING_TASKS.md` |
| `RBT-011` | `WAITING_EXTERNAL` | User / Codex | Indexの`Comparable`採否 | `swift-collections`の要件が安定または正式化した後、互換性を再評価して決定 | `RED_BLACK_TREE_REMAINING_TASKS.md` |
| `RBT-002` | `DONE` | User / Codex / Claude | Index-range `erase`の空guard | 2026-10-06、範囲検査を維持して空での不要なCoWを回避（`11817dfe`） | `RED_BLACK_TREE_REMAINING_TASKS.md` |
| `DOC-001` | `DONE` | Codex / Claude | P10残存記述確認 | 2026-10-06、監査と必要箇所の同期を完了（`9b0f42d5`） | `MAINTENANCE.md` |
| `GRAPH-001` | `ACTIVE` | Claude | Claude用task graph DBの独立試験 | 現行Registryとのready判定一致を確認しながら試験運用を継続 | `TASK_GRAPH_DB_EXPERIMENT.md` |
| `GRAPH-002` | `FROZEN` | Codex | Codex用task graph DBの独立試験 | Codexのcontext reset後、ユーザーが明示的に再開 | `TASK_GRAPH_DB_EXPERIMENT.md` |
| `GRAPH-003` | `EXCLUDED` | — | 二つのtask graph DBの統合議論 | 2026-10-07、統合方針をdrop。再開候補にしない | `TASK_GRAPH_DB_EXPERIMENT.md` |
| `GRAPH-004` | `ACTIVE` | Claude | AIとgraph DBによるsmell（code / test / task）の独立試験 | 専用ノートをClaudeが自由編集し、観測・仮説・反証・再利用可能な判断基準を継続記録 | `AI_GRAPH_SMELL_NOTES.md` |
| `GRAPH-005` | `ACTIVE` | Codex / Claude | ClaudeとCodexのgraph DB交流会 | 合意した共有面で観測、問い、反証、試したい見方を交換。tracked MDを強制せず、統合や正本化を目的にしない | `TASK_GRAPH_DB_EXPERIMENT.md` |
| `EVAL-001` | `FROZEN` | Claude | Claudeによる正式なユーザー評価・依頼された感想の記録 | ユーザーが記録を明示的に依頼した時だけ再開し、記録後は再び凍結。Claude自身の任意observation追記は妨げない | `USER_MANAGEMENT_INTERVIEW_CLAUDE.md` / `CLAUDE_OBSERVATIONS.md` |
| `RBT-003` | `DONE` | Codex / Claude | `Result`のpublic比較overloadとpublic `_NodePtr` | 2026-10-07、公開面縮小と検証を完了。performance job成功を確認 | `EXTERNAL_TYPE_EXTENSION_AUDIT.md` |
| `RBT-012` | `FROZEN` | Claude | Swift 6.4 `-O`のCoW誤コンパイルに対する値セマンティクスのTest as Spec拡充 | 1.0判断の直前に再開。4型の値セマンティクス仕様（`_15_ValueSemanticsTests`等）へ「コピー後に元の側をクロージャ内で変更しても、コピーは変わらない」をReleaseで追加し、当たれば回避策を相談。発見と最小再現はPermutationの`ensureUnique()`のTODO（2026-10-07） | `Tests/RedBlackTreeTests/` |
| `RBT-004` | `FROZEN` | Codex | Debug限定Comparable群・Balanced群 | Index契約またはexecutable API Matrix方針の確定後 | `EXTERNAL_TYPE_EXTENSION_AUDIT.md` |
| `RBT-005` | `FROZEN` | Codex | Memoize群の公開終了／正式API化 | 外部consumer 2件の移行後 | `EXTERNAL_TYPE_EXTENSION_AUDIT.md` |
| `RBT-006` | `FROZEN` | User / Codex | 未結線コードの個別削除 | ユーザーが対象を個別指定 | `RED_BLACK_TREE_REMAINING_TASKS.md` |
| `TEST-001` | `FROZEN` | User / Codex | 無効化・歴史的テストコードの処遇 | ユーザーが対象を個別指定 | `Tests/TESTING.md` |
| `TEST-002` | `FROZEN` | Codex | stride assertion／fixture alignmentの任意改善 | 実害または明示的な再開指示 | `Tests/TESTING.md` |
| `PERM-001` | `FROZEN` | Codex | AtCoder 2025互換mode | ユーザーが明示的に再開 | `PermutationModule/AtCoder2025CompatibilityPlan.md` |
| `PERM-002` | `USER_ONLY` | User | ABC328E実提出確認 | ユーザーが手作業で実施 | `PermutationModule/ImplementationPlan.md` |
| `PERM-003` | `DONE` | Claude | 現行Permutation契約の基準固定 | 2026-10-07、削除済みAPIの非露出をcompile時に固定し、重複要素・非Array入力のtestを追加 | `PermutationModule/AtCoder2025CompatibilityPlan.md` |
| `PERM-011` | `DONE` | Claude | Permutation公開型の改名 | 2026-10-07、`NextPermutationsSequence`/`.Iterator`/`.Permutation`へ改名し`Permutations`名前空間を廃止（source-breaking、ユーザー承認済み） | `Tests/PermutationTests/NextPermutationsSequence/` |
| `PERM-012` | `DONE` | Claude | Permutation仕様のTest as Specification化 | 2026-10-07、仕様をテストの連番fileへ移し、`Specification.md`を削除（ユーザー判断）。テストで表せない約束はソースのドキュメントコメントへ | `Tests/PermutationTests/NextPermutationsSequence/` |
| `PERM-013` | `FROZEN` | User / Claude | Permutation性能のCIベース比較 | 作業の区切りでユーザーが再開。Claudeが`Benchmarks/Libraries/CI.json`へPermutationの計測を追加し、ユーザーのpush後にperformance jobのベース比較で`@inline(__always)`全削除（`0ef177d3`）以降の影響を確認 | `Sources/PermutationModule/Documentation/QualityAssessment-ISO25010.md` |
| `PERM-004` | `FROZEN` | Codex | AtCoder 2025互換ソースの隔離 | 基準版を専用fileへ配置し、通常版と排他的にcompileできる状態にする | `PermutationModule/AtCoder2025CompatibilityPlan.md` |
| `PERM-005` | `FROZEN` | Codex | Permutation互換traitのPackage設定 | 互換defineをtraitへ接続し、traitなしを通常版の既定にする | `PermutationModule/AtCoder2025CompatibilityPlan.md` |
| `PERM-006` | `FROZEN` | Codex | 互換modeのTest as Specification | 列挙順・重複・safe CoW・unsafe aliasing・境界を基準refに対して固定 | `PermutationModule/AtCoder2025CompatibilityPlan.md` |
| `PERM-007` | `FROZEN` | Codex | 両modeのAcCollections再公開検証 | 通常・互換の期待APIをAcCollections経由でcompile・test | `PermutationModule/AtCoder2025CompatibilityPlan.md` |
| `PERM-008` | `FROZEN` | Codex | Permutation互換CIの分離 | 通常版と互換版を別jobとして表示し、結果を混在させない | `PermutationModule/AtCoder2025CompatibilityPlan.md` |
| `PERM-009` | `FROZEN` | Codex | AtCoder単一file生成とローカル検証 | 互換版から自己完結fileを生成し、ABC328E相当入力で検証 | `PermutationModule/AtCoder2025CompatibilityPlan.md` |
| `PERM-010` | `FROZEN` | Codex | Permutation互換mode文書同期 | 通常APIと互換APIを混同せず、trait・制限・検証方法を文書化 | `PermutationModule/AtCoder2025CompatibilityPlan.md` |
| `OPT-001` | `FROZEN` | Codex | OptionalArrayの体系監査・名称再検討 | ユーザーが明示的に再開 | `Tests/TESTING.md` |
| `BARE-001` | `FROZEN` | Codex | BareArrayの体系監査・名称再検討 | ユーザーが明示的に再開 | `Tests/TESTING.md` |
| `ARRAY-001` | `FROZEN` | User / Codex | BareArray／OptionalArrayのstorage再設計とstrict恒久適用 | 公開unsafe境界を決定して再開 | `StrictMemorySafetyReadiness.md` |
| `RBT-007` | `FROZEN` | User / Codex | RedBlackTreeCollectionsのstrict memory safety全面適用 | ユーザーが段階3を承認 | `StrictMemorySafetyReadiness.md` |
| `BENCH-001` | `FROZEN` | Codex | SortedCollectionsとのpublishableな大規模比較 | ユーザーが明示的に再開 | `Archived/SORTED_COLLECTIONS_BENCHMARK_TASK.md` |
| `TEST-003` | `FROZEN` | Codex | randomized trace失敗時の自動縮小 | 実害または明示的な再開指示 | `Sources/RedBlackTreeCollections/Documentation/Cpp-Matrix.md` |
| `RBT-008` | `FROZEN` | User / Codex | `lazyDetach`等の並行初期化保証 | concurrency契約を扱う明示的な再開指示 | `RED_BLACK_TREE_REMAINING_TASKS.md` |
| `PERF-001` | `FROZEN` | Codex | Swift更新後のCoWコード生成再計測 | Swift更新または明示的な再計測指示 | `PERFORMANCE_REGRESSION_BISECTION.md` |
| `HIST-001` | `FROZEN` | Codex | unsafe移行史の追加調査 | ユーザーが明示的に再開 | `REFACTORING_FROM_ATCODER_2025.md` |
| `TEST-004` | `FROZEN` | Codex | 原木Fixtureの追加portable化 | 実害または明示的な再開指示 | `Tests/TESTING.md` |
| `RBT-009` | `FROZEN` | User / Codex | runtime-check実装の再審査 | 1.0判断直前、または`-Ounchecked`が主要構成と判明 | `Sources/RedBlackTreeCollections/Documentation/Design/Design-RuntimeChecks.md` |
| `QUALITY-001` | `FROZEN` | User / Codex | 汎用基盤ライブラリとしての1.0採用品質ゲート | Index契約確定後、ユーザーが明示的に再開 | `Sources/RedBlackTreeCollections/Documentation/Quality-Checklist.md` |
| `CPP-001` | `DONE` | Codex / Claude | C++挙動比較 | 比較契約または対象環境を変更する場合だけ更新 | `Sources/RedBlackTreeCollections/Documentation/Cpp-Matrix.md` |
| `CPP-002` | `EXCLUDED` | — | MSVC STLとのC++挙動比較 | 現行計画では実施しない | `Sources/RedBlackTreeCollections/Documentation/Cpp-Matrix.md` |

## Task precedence

| 後続task | 前提task | 制約 |
| --- | --- | --- |
| `RBT-001` | `RBT-010` | 前提taskの完了後に後続taskを完了できる |
| `RBT-001` | `RBT-011` | 前提taskの完了後に後続taskを完了できる |
| `QUALITY-001` | `RBT-001` | 前提taskの完了後に着手候補にできる |
| `PERM-004` | `PERM-003` | 前提taskの完了後に着手できる |
| `PERM-005` | `PERM-004` | 前提taskの完了後に着手できる |
| `PERM-006` | `PERM-005` | 前提taskの完了後に着手できる |
| `PERM-007` | `PERM-006` | 前提taskの完了後に着手できる |
| `PERM-008` | `PERM-006` | 前提taskの完了後に着手できる |
| `PERM-009` | `PERM-007` | 前提taskの完了後に着手できる |
| `PERM-010` | `PERM-007` | 前提taskの完了後に着手できる |
| `PERM-010` | `PERM-008` | 前提taskの完了後に着手できる |
| `PERM-010` | `PERM-009` | 前提taskの完了後に着手できる |
| `PERM-001` | `PERM-010` | 前提taskの完了後に後続taskを完了できる |

## Registry rules

- 状態は`ACTIVE`、`WAITING_USER`、`WAITING_EXTERNAL`、`FROZEN`、`USER_ONLY`、`EXCLUDED`、`DONE`、`ARCHIVED`のいずれかとする。
- `FROZEN`は明示的な再開指示なしに着手しない。
- `USER_ONLY`はユーザー専任とし、AIは着手、代行、催促を行わない。
- `WAITING_EXTERNAL`は外部条件が解消するまで着手可能とみなさない。
- Task precedenceには内部task間の必須AND前提だけを記録する。
- Task Registryの確定更新はCodexが担当する。
- 優先順位は、ユーザーの最新指示、Task Registry、詳細正本、Archivedと過去ログの順とする。

## Current summary

- RedBlackTreeの実装、正当性検証、主要な公開面整理は完了済み。
- RedBlackTreeの主な残件は、外部要件待ちのIndex `Comparable`判断と、その結論に基づく最終文書同期。
- Permutationは現行契約の基準固定を独立した先頭taskとし、互換mode作業はその後に凍結されている。
- Claudeのtask graph DB試験とsmell知見試験が進行中。

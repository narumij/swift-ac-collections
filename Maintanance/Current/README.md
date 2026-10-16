# 現行メンテナンス資料

`Maintanance/`直下に散在していた、現在も正本・運用資料・未完taskの確認先として有効な横断文書をまとめる。
各taskの状態、担当、依存関係、再開条件は、本folderではなく
[`ProgressV2/TASK_REGISTRY_V2.md`](../ProgressV2/TASK_REGISTRY_V2.md)を正本とする。

| 分野 | 文書 |
| --- | --- |
| benchmark | [`BENCHMARK_USAGE_GUIDE.md`](BENCHMARK_USAGE_GUIDE.md) / [`PERFORMANCE_CI_CHANGE_GUIDE.md`](PERFORMANCE_CI_CHANGE_GUIDE.md) |
| 公開文書 | [`DOCUMENTATION_CI_PLAN.md`](DOCUMENTATION_CI_PLAN.md) |
| API・実装境界 | [`PUBLIC_API_NAMING_DECISIONS.md`](PUBLIC_API_NAMING_DECISIONS.md) / [`EXTERNAL_TYPE_EXTENSION_AUDIT.md`](EXTERNAL_TYPE_EXTENSION_AUDIT.md) / [`StrictMemorySafetyReadiness.md`](StrictMemorySafetyReadiness.md) |
| 技術orientation | [`AI_TECHNICAL_ORIENTATION.md`](AI_TECHNICAL_ORIENTATION.md) |
| 品質 | [`QUALITY_REQUIREMENTS.md`](../Quality/QUALITY_REQUIREMENTS.md) / [`QUALITY_REQUIREMENTS_REFERENCE.md`](../Quality/QUALITY_REQUIREMENTS_REFERENCE.md) / [`QUALITY_ASSESSMENT_INVENTORY.md`](../Quality/0.6.0-1/QUALITY_ASSESSMENT_INVENTORY.md) |
| release | [`RELEASE_0_6_0.md`](../Milestones/Archived/RELEASE_0_6_0.md) |

完了済みの実行記録、失効した旧進捗、未採用の草案は、このfolderへ含めず`Archived/`へ整理した。
`Maintanance/`直下の協働入口・観察・評価文書と[`DOCUMENT.md`](../DOCUMENT.md)も、明示された配置を維持する。

完了した[Permutation移行の依頼・返却・受入記録](../Archived/PermutationMigration_2026-10-16/README.md)は履歴へ移した。後段の方針を含む[移行計画](PERMUTATION_MODULE_MIGRATION_PLAN.md)は現行に残す。

比較演算類とBalanced系は[経緯](RED_BLACK_TREE_COMPARISON_DECLARATIONS_CONTEXT.md)と[保存意図](RED_BLACK_TREE_BALANCED_DESIGN_INTENT.md)を別に保持する。旧ユーザー判断の案内2件は[今回の圧縮記録](../Archived/TASK_REGISTRY_AFTER_USER_RECLASSIFICATION_2026-10-16.md)に従い履歴へ移した。Memoizeの現行正本は[依存調査](MEMOIZE_DEPENDENCY_INVESTIGATION.md)。

互換ブランチの将来統合は[AtCoder 2025互換計画](AtCoder2025CompatibilityPlan.md)を参照する。[benchmark名移行の旧工程資料](BENCHMARK_TASK_NAME_MIGRATION.md)は[現行の移行正本](PERMUTATION_BENCHMARK_TITLE_MIGRATION.md)の補助資料として保持する。配置変更によって旧工程を現行条件へ戻さない。

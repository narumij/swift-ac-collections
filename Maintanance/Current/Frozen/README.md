# 凍結taskの棚卸し入口

凍結した仕事と判断を、ユーザーが見返すためのフォルダ。Archivedとは異なり現行の記録を置く。状態・担当・依存関係・再開条件の正本は[Task Registry](../../ProgressV2/TASK_REGISTRY_V2.md)。フォルダへの出し入れだけでは状態を変えない。

2026-10-16時点の凍結4件を収録。並行初期化保証以外の3件は、Registryの記載と既存資料への参照を置いた最小限の正本であり、新たな判断や調査結果ではない。既存の共有正本は移動せず、仕様・品質判断の正本性も維持する。

| ID | 正本 |
| --- | --- |
| RBT-004 | [残存するDebug限定Comparable群・Balanced群](RBT-004_FROZEN_TASK.md) |
| RBT-005 | [Memoize群の公開終了／正式API化](RBT-005_FROZEN_TASK.md) |
| RBT-008 | [`lazyDetach`等の並行初期化保証](LAZY_INITIALIZATION_FREEZE_DECISION.md) |
| PERM-063 | [[EXECUTION] Permutation benchmark task名移行互換の先行導入](PERM-063_FROZEN_TASK.md) |

[今回の棚卸し結果](../FROZEN_TASK_RECONCILIATION_2026-10-16.md)も参照できる。

PERM-051はユーザー判断で品質側へ移行済みとして除外。[除外記録と旧正本](../../Archived/PERM-051_EXCLUDED_2026-10-16.md)を保存した。

PERM-043・044も次回品質評価へ集約して除外。[除外記録と旧正本](../../Archived/PERM-043_044_EXCLUDED_2026-10-16.md)を保存した。

PERM-060はユーザー指示で[バグ調査](../PERMUTATION_SEQUENCE_INVALID_VIEW_ISSUE.md)へ復帰した。

PERM-064はユーザー指示で[表示名移行課題](../PERMUTATION_BENCHMARK_TITLE_MIGRATION.md)へ復帰。PERM-063の凍結と先行依存は維持する。

OPT-064は品質側へ移行して除外。[旧正本と判断](../../Archived/OPT-064_EXCLUDED_2026-10-16.md)を保存した。

RBT-026は[姫との議論を経て決める契約判断](../MAPPED_VALUES_VIEW_CONTRACT_DECISION.md)として復帰した。

RBT-035は[ユーザー専任の実施判断](../RED_BLACK_TREE_TUNING_RESEARCH_DECISION.md)へ整理した。

RELEASE-080はユーザーの解決確認と追跡不要の指示によりEXCLUDED。[解決記録](../../Archived/RELEASE-080_RESOLVED_2026-10-16.md)。

リリース開始ゲート2件は版別正本へ集約してEXCLUDED、SPI実行2件は依存条件で待つACTIVEへ変更。[マイルストーン管理](../../MILESTONES.md)を参照。

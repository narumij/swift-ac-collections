# 凍結一覧の圧縮前記録

2026-10-16、元文書Maintanance/Current/Frozen/README.md。本文は履歴。相対リンクのみ補正。

# 凍結taskの棚卸し入口

凍結した仕事と判断を、ユーザーが見返すためのフォルダ。Archivedとは異なり現行の記録を置く。状態・担当・依存関係・再開条件の正本は[Task Registry](../ProgressV2/TASK_REGISTRY_V2.md)。フォルダへの出し入れだけでは状態を変えない。

2026-10-16時点の凍結1件を収録。現在残るのは並行初期化保証の意図的な凍結判断。既存の共有正本は移動せず、仕様・品質判断の正本性も維持する。

| ID | 正本 |
| --- | --- |
| RBT-008 | [`lazyDetach`等の並行初期化保証](../Current/Frozen/LAZY_INITIALIZATION_FREEZE_DECISION.md) |

[今回の棚卸し結果](FROZEN_TASK_RECONCILIATION_2026-10-16.md)も参照できる。

PERM-051はユーザー判断で品質側へ移行済みとして除外。[除外記録と旧正本](PERM-051_EXCLUDED_2026-10-16.md)を保存した。

PERM-043・044も次回品質評価へ集約して除外。[除外記録と旧正本](PERM-043_044_EXCLUDED_2026-10-16.md)を保存した。

PERM-060はユーザー指示で[バグ調査](../Current/PERMUTATION_SEQUENCE_INVALID_VIEW_ISSUE.md)へ復帰した。

PERM-064はユーザー指示で[表示名移行課題](../Current/PERMUTATION_BENCHMARK_TITLE_MIGRATION.md)へ復帰。PERM-063の凍結と先行依存は維持する。

OPT-064は品質側へ移行して除外。[旧正本と判断](OPT-064_EXCLUDED_2026-10-16.md)を保存した。

RBT-026は[姫との議論を経て決める契約判断](../Current/MAPPED_VALUES_VIEW_CONTRACT_DECISION.md)として復帰した。

RBT-035は[ユーザー専任の実施判断](../Current/RED_BLACK_TREE_TUNING_RESEARCH_DECISION.md)へ整理した。

RELEASE-080はユーザーの解決確認と追跡不要の指示によりEXCLUDED。[解決記録](RELEASE-080_RESOLVED_2026-10-16.md)。

リリース開始ゲート2件は版別正本へ集約してEXCLUDED、SPI実行2件は依存条件で待つACTIVEへ変更。[マイルストーン管理](../MILESTONES.md)を参照。

PERM-063はEXCLUDEDとし、必要な互換工程をPERM-064へ統合。[記録](PERM-063_EXCLUDED_2026-10-16.md)。

RBT-004は[ユーザー専任の判断](RED_BLACK_TREE_COMPARISON_USER_DECISION_RETIRED_2026-10-16.md)へ変更した。

RBT-005は[Memoize群のユーザー判断](MEMOIZE_USER_DECISION_RETIRED_2026-10-16.md)へ変更した。

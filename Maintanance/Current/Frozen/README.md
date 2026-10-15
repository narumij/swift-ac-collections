# 凍結taskの棚卸し入口

凍結した仕事と判断を、ユーザーが見返すためのフォルダ。Archivedとは異なり現行の記録を置く。状態・担当・依存関係・再開条件の正本は[Task Registry](../../ProgressV2/TASK_REGISTRY_V2.md)。フォルダへの出し入れだけでは状態を変えない。

2026-10-16時点の凍結17件を収録。並行初期化保証以外の16件は、Registryの記載と既存資料への参照を置いた最小限の正本であり、新たな判断や調査結果ではない。既存の共有正本は移動せず、仕様・品質判断の正本性も維持する。

| ID | 正本 |
| --- | --- |
| RELEASE-080 | [[DISCOVERY] PRコメント起動CIのbaseline失敗調査と疎通確認](RELEASE-080_FROZEN_TASK.md) |
| DOC-026 | [[EXECUTION] Swift Package Indexへのpackage登録](DOC-026_FROZEN_TASK.md) |
| DOC-027 | [[EXECUTION] Swift Package Index公開導線のREADME・Pages反映](DOC-027_FROZEN_TASK.md) |
| RELEASE-007 | [[DECISION] 0.6.0の到達範囲とrelease検討開始](RELEASE-007_FROZEN_TASK.md) |
| RELEASE-079 | [[DECISION] 0.7.0の到達範囲とrelease検討開始](RELEASE-079_FROZEN_TASK.md) |
| RBT-035 | [[DISCOVERY] RedBlackTreeチューニングの落ち穂拾い](RBT-035_FROZEN_TASK.md) |
| RBT-026 | [[DECISION] Mapped Values ViewのO(1)範囲契約再検討](RBT-026_FROZEN_TASK.md) |
| RBT-004 | [残存するDebug限定Comparable群・Balanced群](RBT-004_FROZEN_TASK.md) |
| RBT-005 | [Memoize群の公開終了／正式API化](RBT-005_FROZEN_TASK.md) |
| RBT-008 | [`lazyDetach`等の並行初期化保証](LAZY_INITIALIZATION_FREEZE_DECISION.md) |
| PERM-063 | [[EXECUTION] Permutation benchmark task名移行互換の先行導入](PERM-063_FROZEN_TASK.md) |
| PERM-064 | [[EXECUTION] Permutation benchmark表示名の現行型名への移行](PERM-064_FROZEN_TASK.md) |
| PERM-043 | [[DECISION] C++標準に匹敵すると判定する性能比の上限](PERM-043_FROZEN_TASK.md) |
| PERM-044 | [[EXECUTION] Permutation外部性能アセスメントの実測・判定](PERM-044_FROZEN_TASK.md) |
| PERM-051 | [[EXECUTION] borrowed Span版PermutationのTest as Specification](PERM-051_FROZEN_TASK.md) |
| PERM-060 | [[DECISION] NextPermutationsのSequence表面を製品候補として検討するか](PERM-060_FROZEN_TASK.md) |
| OPT-064 | [[EXECUTION] OptionalElementBuffer一般利用理解Validation試行](OPT-064_FROZEN_TASK.md) |

[今回の棚卸し結果](../FROZEN_TASK_RECONCILIATION_2026-10-16.md)も参照できる。

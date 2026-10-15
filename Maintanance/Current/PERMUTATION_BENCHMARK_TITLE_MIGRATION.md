# Permutation benchmark表示名の移行

2026-10-16、Astra記録。PERM-064。

## 現在の扱い

ユーザーが「未解決で気になってたから復活」と指示したため、ACTIVEへ戻した。実装は未着手。状態と依存の正本は[Task Registry](../ProgressV2/TASK_REGISTRY_V2.md)。

## 対象と完了条件

benchmark sourceに残る旧内部型名を含む4 titleと、CI libraryの登録2件を、現行の名称決定と整合する表示名へ移行する。具体的な移行先は実行前に照合・確定し、旧計画のNextPermutationsSequence.Permutationを無条件に用いない。

先行するPERM-063のworkflow互換処理がmainへmergeされ、remote performance CIがgreenとなるまで、title変更は開始しない。PERM-063自身の凍結は今回解除していない。PERM-064の再開指示を重ねて求める必要はないが、依存条件の充足とは区別する。

変更後はtask列挙、base/currentの測定・比較、remote performance CIのgreenを確認して受け入れる。workload、測定範囲、反復数、閾値は変更しない。公開契約等の新しい判断が必要になった場合は分離して返す。

## 参照先

- [二段階の移行計画](../PermutationModule/BENCHMARK_TASK_NAME_MIGRATION.md)
- [性能CI変更手順](PERFORMANCE_CI_CHANGE_GUIDE.md)
- [benchmark source](../../Benchmarks/Sources/Benchmarks/PermutationBenchmarks.swift)
- [CI登録](../../Benchmarks/Libraries/CI.json)
- [復帰前の原文](../Archived/PERM-064_BEFORE_REACTIVATION_2026-10-16.md)

# Permutation benchmark表示名の移行

## TL;DR（人間向け）

Permutationのbenchmarkに残る旧表示名を直す仕事です。ただの名前置換ではなく、CIが旧結果と新結果を比較できる状態を先に整えます。

互換対応のmain反映とremote CI成功を確認してからtitleを変更します。実装は未着手で、測定内容や性能閾値は変えません。

<!-- OPS-133: 2026-10-19 / Astra。本文を読む入口。決定・状態の正本を置き換えない。本文の結論や境界を変えたときに一緒に見直す。 -->


2026-10-16、Astra記録。PERM-064。

## 現在の扱い

ユーザーが「未解決で気になってたから復活」と指示したため、ACTIVEへ戻した。実装は未着手。状態と依存の正本は[Task Registry](../ProgressV2/TASK_REGISTRY_V2.md)。

## 対象と完了条件

benchmark sourceに残る旧内部型名を含む4 titleと、CI libraryの登録2件を、現行の名称決定と整合する表示名へ移行する。具体的な移行先は実行前に照合・確定し、旧計画のNextPermutationsSequence.Permutationを無条件に用いない。

2026-10-16、ユーザー指示でPERM-063を独立taskとして除外し、必要な互換工程を本taskへ統合した。旧taskの再開や完了は要求しない。実行時に現行workflowの互換対応を確認し、必要な入力変換・結果名正規化を先行して整える。その変更がmainへmergeされ、remote performance CIがgreenになるまでtitle変更は開始しない。既に成立する互換処理は重複実装せず、証拠を接続する。

この二段階は一つのtask内の工程として追跡し、互換処理とtitle変更のcommit・merge境界を保つ。今回の整理は実装・CI起動・mergeの実行ではない。[統合前記録](../Archived/PERM-063_EXCLUDED_2026-10-16.md)を保存した。

変更後はtask列挙、base/currentの測定・比較、remote performance CIのgreenを確認して受け入れる。workload、測定範囲、反復数、閾値は変更しない。公開契約等の新しい判断が必要になった場合は分離して返す。

## 参照先

- [二段階の移行計画](BENCHMARK_TASK_NAME_MIGRATION.md)
- [性能CI変更手順](PERFORMANCE_CI_CHANGE_GUIDE.md)
- [benchmark source](../../Benchmarks/Sources/Benchmarks/PermutationBenchmarks.swift)
- [CI登録](../../Benchmarks/Libraries/CI.json)
- [復帰前の原文](../Archived/PERM-064_BEFORE_REACTIVATION_2026-10-16.md)

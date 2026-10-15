# PERM-063 — [EXECUTION] Permutation benchmark task名移行互換の先行導入

記録者：Astra。作成日：2026-10-16。

この文書は、この凍結taskの棚卸しと今後の判断記録の正本。既存の仕様・品質判断は下記資料を参照し、ここで置き換えない。状態・担当・依存関係・再開条件の正本は[Task Registry](../../ProgressV2/TASK_REGISTRY_V2.md)。今回の作成は再開を意味しない。

## 現在記録されている内容

2026-10-16のRegistryから転記：

ユーザーの明示再開後、CI登録中の旧`Permutations.SubSequenceN` 2 taskを現行`NextPermutationsSequence.Permutation`名へ対応付けるbaseline入力・結果名正規化をworkflowへ先に追加し、remote performance CIのgreenを確認

## 凍結判断の補足

このtask専用の追加説明は未記入。上記にない凍結理由やユーザー判断を推測で補わない。記録の空欄は、判断が存在しなかったことを意味しない。

## 既存資料

- [Maintanance/PermutationModule/BENCHMARK_TASK_NAME_MIGRATION.md](../../PermutationModule/BENCHMARK_TASK_NAME_MIGRATION.md)
- [Maintanance/Current/PERFORMANCE_CI_CHANGE_GUIDE.md](../PERFORMANCE_CI_CHANGE_GUIDE.md)
- [.github/workflows/ci.yml](../../../.github/workflows/ci.yml)

## 今後の判断記録

未記入。棚卸しで確認できた判断と根拠をここへ追記する。

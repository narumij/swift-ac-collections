# PERM-064 復帰前記録

2026-10-16、Astra。ユーザーの明示指示でACTIVEへ復帰。以下は履歴であり、現行の再開条件ではない。相対リンクのみ補正した。

| `PERM-064` | `FROZEN` | Codex | [EXECUTION] Permutation benchmark表示名の現行型名への移行 | 後段のbenchmark名整理として凍結を維持。ユーザーの明示再開とPERM-063の先行merge・green確認後、確定した移行先表示名へsourceの4 titleとCI登録2件を変更し、task列挙・base/current比較・remote performance CIのgreenを確認する。旧計画の型名をそのまま移行先にしない | `Maintanance/Current/Frozen/PERM-064_FROZEN_TASK.md`。既存資料：`Maintanance/PermutationModule/BENCHMARK_TASK_NAME_MIGRATION.md` / `Benchmarks/Sources/Benchmarks/PermutationBenchmarks.swift` / `Benchmarks/Libraries/CI.json` |

# PERM-064 — [EXECUTION] Permutation benchmark表示名の現行型名への移行

記録者：Astra。作成日：2026-10-16。

この文書は、この凍結taskの棚卸しと今後の判断記録の正本。既存の仕様・品質判断は下記資料を参照し、ここで置き換えない。状態・担当・依存関係・再開条件の正本は[Task Registry](../ProgressV2/TASK_REGISTRY_V2.md)。今回の作成は再開を意味しない。

## 整理前の記録（2026-10-16、履歴）

2026-10-16のRegistryから転記：

`PERM-063`のmerge後、benchmark sourceの旧内部型名を含む4 titleとCI library登録2件を`NextPermutationsSequence.Permutation`へ変更し、task列挙、base / current比較、remote performance CIのgreenを確認

## 凍結判断の補足

このtask専用の追加説明は未記入。上記にない凍結理由やユーザー判断を推測で補わない。記録の空欄は、判断が存在しなかったことを意味しない。

## 既存資料

- [Maintanance/PermutationModule/BENCHMARK_TASK_NAME_MIGRATION.md](../PermutationModule/BENCHMARK_TASK_NAME_MIGRATION.md)
- [Benchmarks/Sources/Benchmarks/PermutationBenchmarks.swift](../../Benchmarks/Sources/Benchmarks/PermutationBenchmarks.swift)
- [Benchmarks/Libraries/CI.json](../../Benchmarks/Libraries/CI.json)

## 今後の判断記録

未記入。棚卸しで確認できた判断と根拠をここへ追記する。

## 2026-10-16 の整理

後段のbenchmark名整理として凍結を維持。ユーザーの明示再開とPERM-063の先行merge・green確認後、確定した移行先表示名へsourceの4 titleとCI登録2件を変更し、task列挙・base/current比較・remote performance CIのgreenを確認する。旧計画の型名をそのまま移行先にしない。

当時の旧facade削除PR待ちは現行条件として使わない。現行のbenchmark titleが旧名のままであることを確認した。今回実装・CI実行・mergeはしていない。最新の具体化方針は[移行資料](../PermutationModule/BENCHMARK_TASK_NAME_MIGRATION.md)の冒頭を参照する。

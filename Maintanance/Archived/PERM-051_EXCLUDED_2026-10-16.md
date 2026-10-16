# PERM-051 除外記録

2026-10-16、Astra記録。ユーザーが「品質側に移行してるからいらない」と判断したため、独立taskをEXCLUDEDとして残作業から外した。品質側の論点は[仕様レビュー](../Quality/0.6.0-1/PERMUTATION_TEST_AS_SPEC_REVIEW.md)を参照する。fixture整備を完了した意味ではなく、旧taskの再開を要求しない。新規の重複taskは作らない。

## 除外前のRegistry行

| `PERM-051` | `FROZEN` | Claude | [EXECUTION] borrowed Span版PermutationのTest as Specification | runtime仕様test 25件を受け入れ、2026-10-13にも対象25件成功を再確認。一時clientによるcompile-pass／compile-fail結果は返却記録にあるが、repository内の再実行可能なfixtureではないため、ユーザーの明示的な再開まで残作業を凍結 | `Maintanance/Current/Frozen/PERM-051_FROZEN_TASK.md`。既存資料：`Maintanance/PermutationModule/BorrowedPermutationTestPlan.md` / `Sources/PermutationModule/BorrowedNextPermutations.swift` / `Tests/PermutationTests/BorrowedNextPermutations/` |

## 凍結正本の保存

元文書：`Maintanance/Current/Frozen/PERM-051_FROZEN_TASK.md`。以下は除外前の履歴であり、現在の着手条件としては使わない。相対リンクのみ保存先に合わせた。

# PERM-051 — [EXECUTION] borrowed Span版PermutationのTest as Specification

記録者：Astra。作成日：2026-10-16。

この文書は、この凍結taskの棚卸しと今後の判断記録の正本。既存の仕様・品質判断は下記資料を参照し、ここで置き換えない。状態・担当・依存関係・再開条件の正本は[Task Registry](../ProgressV2/TASK_REGISTRY_V2.md)。今回の作成は再開を意味しない。

## 現在記録されている内容

2026-10-16のRegistryから転記：

runtime仕様test 25件を受け入れ、2026-10-13にも対象25件成功を再確認。一時clientによるcompile-pass／compile-fail結果は返却記録にあるが、repository内の再実行可能なfixtureではないため、ユーザーの明示的な再開まで残作業を凍結

## 凍結判断の補足

このtask専用の追加説明は未記入。上記にない凍結理由やユーザー判断を推測で補わない。記録の空欄は、判断が存在しなかったことを意味しない。

## 既存資料

- [Maintanance/PermutationModule/BorrowedPermutationTestPlan.md](../Quality/0.6.0-1/PermutationModule/BorrowedPermutationTestPlan.md)
- `Sources/PermutationModule/BorrowedNextPermutations.swift`（Registry記載の参照先。現位置は未確認）
- [Tests/PermutationTests/BorrowedNextPermutations/](../../Tests/PermutationTests/BorrowedNextPermutations)

## 今後の判断記録

未記入。棚卸しで確認できた判断と根拠をここへ追記する。

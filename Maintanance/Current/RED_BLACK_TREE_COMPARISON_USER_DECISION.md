# 残存比較宣言とBalanced群のユーザー判断

2026-10-16、Astra記録。RBT-004。

## 扱い

ユーザーが「ユーザー判断にしようかな。AIに話通じなくてつらかったやつ」と述べたため、Codex担当の凍結taskからUSER_ONLYの判断課題へ変更した。ユーザーが残存比較宣言とBalanced群の扱いを決める。AIは判断を先取りせず、実装・削除・委任・催促を行わない。明示的に頼まれた資料整理のみ補助する。

## 既存の論点

既存記録ではDebug限定`Result: Comparable`はユーザー介入で削除済み。残る`_LazyTieWrap`・`_NodePtrSealing`・`_LazyTie`の比較宣言とBalanced群を対象とする。今回その扱いを決めたり、現行実装を再検証したりしていない。

RBT-011のIndexのComparable採否を入力にする既存依存は維持する。前提が整ってもAIへの実行委任にならない。現在の状態・依存は[Task Registry](../ProgressV2/TASK_REGISTRY_V2.md)を参照する。

## 判断記録

未記入。ユーザーの決定と対象範囲を記録し、実行が必要なら別途委任された範囲へ具体化する。

## 資料

- [既存監査](EXTERNAL_TYPE_EXTENSION_AUDIT.md)
- [変更前の原文](../Archived/RBT-004_BEFORE_USER_DECISION_2026-10-16.md)

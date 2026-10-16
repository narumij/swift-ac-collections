# Mapped Values Viewの範囲契約の判断

2026-10-16、Astra記録。RBT-026。

## 現在の依頼

ユーザーが、姫と議論して決めたい課題として復帰を指示した。ACTIVEのDECISIONとして扱う。AstraとClaude（姫）が判断材料と意見を整理し、最終判断をユーザーへ返す。状態・担当・依存関係の正本は[Task Registry](../ProgressV2/TASK_REGISTRY_V2.md)。今回の記録時点では、姫への正式発注・議論・契約変更は未実施。

## 決めること

Mapped Values Viewの範囲について、O(1)と呼び出し側事前条件による現行契約を維持するか。

既存taskに記録された論点は、View外でもbase treeでは有効なIndexを黙って読み書きし得ること。現行API・実装と照合し、具体的な成立条件を確かめてから判断する。現時点で製品の不具合や契約変更を確定しない。

## 議論に用意する材料

- RBT-014の現行API照合結果と、該当Viewの読み書き・範囲外Indexの具体例。
- 利用者が満たす必要のある事前条件と、誤用時の現行動作。
- 現行契約を維持する場合の説明・検査、および契約を変える場合の選択肢と性能・互換性への影響。

Astraと姫の意見は根拠とともに区別して残す。意見の一致だけを検証やユーザー判断の代わりにしない。必要な調査や実験の範囲は議論の準備時に具体化する。

## 完了と境界

RBT-014による判断材料の充足という先行依存は維持する。材料と両者の意見を提示し、ユーザーの判断・理由・適用範囲をこの正本へ記録して判断taskを閉じる。実装や公開契約文書への反映が必要なら、判断に従った後続作業として分ける。

## 参照

- [ViewのAPI Matrix](../../Sources/RedBlackTreeCollections/Documentation/API-Matrix-View.md)
- [API Matrix](../../Sources/RedBlackTreeCollections/Documentation/API-Matrix.md)
- [復帰前の記録](../Archived/RBT-026_BEFORE_REACTIVATION_2026-10-16.md)

## 議論とユーザー判断

未記入。

## 文書マイルストーンへの接続（2026-10-16）

旧RBT-014はユーザー指示で[文書マイルストーン](DOCUMENTATION_MILESTONES.md)へ移行した。関連する現行API照合が判断材料として必要な点は維持する。旧taskの整理を照合完了とせず、文書整備全体の達成待ちにも広げない。

# PermutationModule公開API名称 Round 4入力

## 状態

Round 3と同じ4候補を同じ採点方式で再評価するための共通入力。Round 4では、点数だけでは残らない理由を
候補ごとの自由記述欄へ補う。候補集合、判断単位、採点尺度は変更しない。

## 対象

| 対象surface | 候補シンボル | Candidate ID |
| --- | --- | --- |
| Module名 | `PermutationModule` | `MN-01` |
| Module名 | `NextPermutationModule` | `MN-03` |
| 通常版一時view | `Permutation` | `NV-01` |
| 通常版一時view | `CurrentPermutation` | `NV-03` |

事実関係とRound 3までの対立は`PERMUTATION_PUBLIC_API_NAMING_SCORE_ROUND3_REPORT.md`を共通入力とする。

## Round 4の回答方法

- 各候補へ従来と同じ`1`〜`9`の点を付ける。
- 各候補の自由記述欄へ、点数の理由、反証への反応、残る懸念、判断に必要な補足を必要な範囲で記す。
- 採用、不採用、順位、一候補への絞り込みは回答要件にしない。
- 新しい候補や契約変更が必要だと考えた場合は、採点へ混ぜず自由記述欄で別論点と明示する。
- 回答は評価材料であり、公開名の決定ではない。AI回答の一致や多数はユーザー判断を置き換えない。

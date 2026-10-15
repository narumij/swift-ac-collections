# PermutationModule公開API名称 Round 4入力

## 状態

Round 3後も残るmodule名と通常版一時viewの価値判断について、最終決定者へ渡す比較材料を自由記述で補う。
候補の採用、不採用、順位、点数、一つへの絞り込みは回答者へ要求しない。

## 対象

| 判断群 | 候補 |
| --- | --- |
| Module名 | `PermutationModule` / `NextPermutationModule` |
| 通常版一時view | `Permutation` / `CurrentPermutation` |

事実関係とRound 3までの対立は`PERMUTATION_PUBLIC_API_NAMING_SCORE_ROUND3_REPORT.md`を共通入力とする。

## 自由記述で扱うこと

判断群ごとに、答えられる範囲で次を記す。

- 現在の利用者にとって重く見るべき性質と、その理由
- 各候補が利用者へ伝えること、伝えず文書へ残すこと
- Round 3統合報告にある理由・反証への賛同、異論、補足
- どちらを採っても残る問題と、名称以外で必要な補完
- 最終決定者が選ぶ際に区別すべき判断軸
- 追加の事実確認が必要なら、その問いと決定への影響

すべてを埋める必要はない。新しい候補、契約変更、rename実装案を混ぜず、見つけた場合は別論点として明示する。

## 境界

- 回答は評価材料であり、公開名の決定ではない。
- AI回答の一致や多数は、ユーザー判断を置き換えない。
- Userの記述も、この文書だけでは最終決定として扱わない。
- production、test、DocC、決定正本、Registryを回答者が変更しない。

# PermutationModule公開API名称 Round 3統合報告

## 状態

2026-10-15のUser・姫・V3によるRound 3を、現在記入されている範囲で統合した判断材料。採用判断ではない。
三者とも4候補の採点を完了した。依頼時に設けた選好欄は採点から候補選択へ踏み込むため完了条件から除外した。
姫とV3の記入済み選好は、それぞれの評価意見として保存するが、採用判断や必須回答として扱わない。

## Score matrix

| 対象 | シンボル | ID | User R2→R3 | 姫 R2→R3 | V3 R2→R3 |
| --- | --- | --- | --- | --- | --- |
| Module | `PermutationModule` | `MN-01` | 3→2 | 6→5 | 8→8 |
| Module | `NextPermutationModule` | `MN-03` | 5→5 | 7→7 | 7→7 |
| 通常view | `Permutation` | `NV-01` | 5→5 | 6→7 | 6→6 |
| 通常view | `CurrentPermutation` | `NV-03` | 5→5 | 6→5 | 8→8 |

点数は各回答者の尺度内の動きを示す。合計・平均による採用判断には使わない。

## Module名

Userの点数は`NextPermutationModule`が`PermutationModule`を上回った。
姫は現在の中心機能、暫定確定した入口・ownerとの語幹、全順列APIとの区別を重視した。
V3は将来scope、既存module体系、rename便益の小ささを重視した。

残る対立は、現在の中心機能をmodule名へ載せるか、将来を含む総称と既存名を保つかである。
互換modeの`unsafePermutations()`まで含めると`NextPermutationModule`はmodule全体を完全には表さず、
一方で通常の公開入口は`nextPermutations()`へ既に寄っている。

## 通常版一時view

Userは両候補を同点とした。姫は`Permutation`について、短さ、現行互換、
`NextPermutations.Permutation`としての読みやすさを重視した。V3は`CurrentPermutation`について、
独立所有値という誤読を型名で減らすことを重視した。

どちらの名前も、次の`next()`で失効する具体的な境界を名前だけでは表せない。したがって対立は、
短さ・互換性を取るか、現在bufferに属することを型名へ載せるかであり、DocCとprecondition messageはどちらでも必要になる。

## 最終判断へ渡すもの

- Module名: Userの点数上は`NextPermutationModule`が優位。採用判断はまだ行っていない。
- 通常版一時view: Userは同点で、AI二者が重視した価値も分かれた。ユーザー判断が必要。
- 姫とV3の回答は、いずれも採用、rename、公開契約変更を行っていない。
- 三者のRound 3採点は完了した。自由記述による追加比較を別roundで行う場合も、候補選択を回答者へ要求しない。

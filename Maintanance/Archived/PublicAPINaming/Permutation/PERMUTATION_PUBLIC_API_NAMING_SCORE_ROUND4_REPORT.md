# PermutationModule公開API名称 Round 4統合報告

## 状態

2026-10-15のUser・姫・V3によるRound 4を統合した最終判断材料。三者とも同じ4候補を再採点し、姫とV3は候補ごとの理由・懸念を記録した。
Userは点数を更新し、自由記述は空欄のまま完了確認を記した。採用、rename、公開契約変更は行っていない。

## Score matrix

| 対象 | シンボル | ID | User R3→R4 | 姫 R3→R4 | V3 R3→R4 |
| --- | --- | --- | --- | --- | --- |
| Module | `PermutationModule` | `MN-01` | 2→2 | 5→5 | 8→8 |
| Module | `NextPermutationModule` | `MN-03` | 5→5 | 7→7 | 7→7 |
| 通常view | `Permutation` | `NV-01` | 5→5 | 7→7 | 6→6 |
| 通常view | `CurrentPermutation` | `NV-03` | 5→4 | 5→5 | 8→8 |

点数は各回答者の尺度内の評価を示す。合計、平均、二者の同方向を採用判断には使わない。

## Module名

Userと姫の尺度では`NextPermutationModule`が上、V3の尺度では`PermutationModule`が上で、Round 3から順位は変わらなかった。

- `NextPermutationModule`: 現在の中心入口`nextPermutations()`とowner`NextPermutations`に語幹がそろい、全順列APIとの区別が明確になる。
- `PermutationModule`: 現行互換でrenameを要さず、将来のPermutation APIや互換modeの`unsafePermutations()`まで収容できる広さがある。
- module名は通常の`AcCollections`経由のcall siteには現れにくいため、変更による日常的な便益も影響も限定的という見方で三者は概ね一致した。ただし、外部からの直接import可否は今回確認していない。
- `NextPermutationModule`は現在の通常APIを正確に表す一方、互換modeの全順列と将来scopeには狭い。`PermutationModule`は広い一方、現在の機能と全順列APIの区別を文書へ委ねる。
- 改名する場合に旧module名の互換targetを残すかは、名称選択とは別の移行判断として残る。赤黒木には旧module名を互換targetに残した履歴があるが、その方式を今回採用したことにはならない。

## 通常版一時view

UserはRound 4で`CurrentPermutation`を5から4へ下げ、`Permutation`を5に維持した。姫は`Permutation`を上、V3は`CurrentPermutation`を上とし、AI二者の対立は維持された。

- `Permutation`: `NextPermutations.Permutation`として短く、現行互換で、通常の推論されるcall siteでも自然である。
- `CurrentPermutation`: ownerの現在bufferに属する状態であることを型名に載せ、独立所有値という初期誤読を減らす可能性がある。
- どちらも一時viewであることや次の`next()`で失効する具体的な境界までは表さない。DocC、保存時の`Array` copy案内、失効時のprecondition messageはどちらでも必要になる。
- 最終的な対立は、短さ・現行互換を取るか、限定的でも一時性の手掛かりを型名へ増やすかである。

## 最終判断へ渡すもの

- Module名: User自身の点数は`NextPermutationModule`が上。現在の語幹一致と、広い将来scope・互換mode・移行コストのどちらを重く見るかをユーザーが決める。
- 通常版一時view: User自身のRound 4点は`Permutation`が1点上。名称だけでは寿命契約を完結できない前提で、短さ・互換性と補助的な誤読防止のどちらを重く見るかをユーザーが決める。
- moduleを改名する場合は、旧名の互換targetを残すか、破壊的変更として置換するかを別途明示する必要がある。
- 三者採点と統合は完了した。公開名の採用、互換方針、実装影響の決定は`PERM-070`に残る。

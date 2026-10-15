# PermutationModule公開API名称比較 — V3 Round 4

## 状態

Round 4回答者: V3（Codex）。共通入力は`PERMUTATION_PUBLIC_API_NAMING_ROUND4_INPUT.md`。
Round 3の採点形式を保ち、候補ごとの自由記述欄を追加した。2026-10-15回答済み。

## Round 4比較表

| 対象surface | 候補シンボル | Candidate ID | Round 3 | Round 4（1〜9） | 自由記述 |
| --- | --- | --- | --- | --- | --- |
| Module名 | `PermutationModule` | `MN-01` | 8 | 8 | 通常は`AcCollections`経由で利用され、module名がcall siteへ出る頻度は低い。現在機能との語幹一致より、Permutation APIを収容できる境界、既存module体系、rename不要を重く見る。swift-algorithmsの全順列APIと領域が重なって見える点はDocCで区別が必要 |
| Module名 | `NextPermutationModule` | `MN-03` | 7 | 7 | 現在の中心機能、入口・ownerの語幹、C++の検索語とは明確に揃う。一方、互換modeの`unsafePermutations()`を同じmoduleへ置く現状や将来scopeには狭く、target・import・DocC URLを変える費用に対して直接利用時の便益が限定的 |
| 通常版一時view | `Permutation` | `NV-01` | 6 | 6 | `NextPermutations.Permutation`として短く自然で現行互換。単独では保存可能な所有値と誤読しやすく、一時view、次の`next()`での失効、保存時の`Array` copyをDocCと診断へ委ねる |
| 通常版一時view | `CurrentPermutation` | `NV-03` | 8 | 8 | ownerの現在bufferに属する状態だと型名から少し推測しやすく、独立所有値という初期誤読を減らす。ただし`Current`だけではview性や具体的失効境界を示せず、DocCと診断は引き続き必要 |

## 完了確認

- [x] 4候補を再評価した。
- [x] 各候補の点数を記入した。
- [x] 自由記述は、点数だけでは残らない理由や懸念がある候補について記入した。
- [x] 採用・rename・公開契約変更を行っていない。

# PermutationModule公開API名称比較 — V3 Round 3

## 状態

Round 3回答者: V3（Codex）。共通入力は`PERMUTATION_PUBLIC_API_NAMING_ROUND3_INPUT.md`。
Round 1・2を保持した比較用。2026-10-15回答済み。選好欄と判断群別回答は依頼時に越権して設けた欄であり、採点の完了条件には用いない。記入済み内容はV3自身の評価意見として保存する。

## Round 3比較表

| 対象surface | 候補シンボル | Candidate ID | Round 2 | Round 3（1〜9） | この判断群で選好するか | 選好・不採用の決め手 |
| --- | --- | --- | --- | --- | --- | --- |
| Module名 | `PermutationModule` | `MN-01` | 8 | 8 | はい | moduleは通常`AcCollections`経由で隠れ、現在機能へ狭めるrename便益より将来scopeと既存体系を優先する |
| Module名 | `NextPermutationModule` | `MN-03` | 7 | 7 | いいえ | 入口との語幹整合と検索性は認めるが、その便益は`nextPermutations()`自体ですでに得られる |
| 通常版一時view | `Permutation` | `NV-01` | 6 | 6 | いいえ | 最短で自然だが、独立所有値に見えるという今回の型固有の誤読を残す |
| 通常版一時view | `CurrentPermutation` | `NV-03` | 8 | 8 | はい | 順列一件という意味を保ちつつ、ownerの現在bufferに属する状態だと示せる |

## 判断群ごとの回答

| 判断群 | 選好するCandidate ID | 最終判断へ渡す理由 | 残る留保 |
| --- | --- | --- | --- |
| Module名 | `MN-01` | module名では将来の総称とpackage体系を保つ | 現在機能の検索性は入口名と文書へ委ねる |
| 通常版一時view | `NV-03` | 所有値誤読を減らしながら順列性を保持する | 具体的失効境界は引き続き文書が必要 |

## 完了確認

- [x] 4候補を再評価した。
- [x] 選好欄は採点の完了条件に含めない。記入内容は評価意見として保存した。
- [x] 採用・rename・公開契約変更を行っていない。

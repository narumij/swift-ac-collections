# PermutationModule公開API名称比較 — 姫 Round 3

## 状態

Round 3回答者: 姫（Claude）。共通入力は`PERMUTATION_PUBLIC_API_NAMING_ROUND3_INPUT.md`。
Round 1・2を保持した比較用。2026-10-15回答・受入済み。選好欄と判断群別回答は依頼時に越権して設けた欄であり、採点の完了条件には用いない。記入済み内容は姫自身の評価意見として保存する。

## Round 3比較表

| 対象surface | 候補シンボル | Candidate ID | Round 2 | Round 3（1〜9） | この判断群で選好するか | 選好・不採用の決め手 |
| --- | --- | --- | --- | --- | --- | --- |
| Module名 | `PermutationModule` | `MN-01` | 6 | 5 | 選好しない | 将来のPermutation総称として保つ利点は、現時点で予定された別のPermutation APIがなく、仮定に依存する。全順列はswift-algorithmsの`permutations()`が担い、このmoduleの役割は`next_permutation`系に定まっている。暫定確定した入口`nextPermutations()`・owner`NextPermutations`と語幹が揃わない |
| Module名 | `NextPermutationModule` | `MN-03` | 7 | 7 | 選好する | module・入口・ownerが同じ`NextPermutation`の語幹になり、C++の`next_permutation`から検索でき、swift-algorithmsの全順列と名前で区別できる。Permutationは破壊的変更を許す整理中のmoduleで、利用者は通常`AcCollections`からimportするため、rename費用は限られる |
| 通常版一時view | `Permutation` | `NV-01` | 6 | 7 | 選好する | owner`NextPermutations`配下で`NextPermutations.Permutation`と読め、最短で現行互換。通常のcall siteは`while let permutation = p.next()`で型名を書かない。`CurrentPermutation`にしても失効条件は文書に頼るため、長さを足す見返りが小さい |
| 通常版一時view | `CurrentPermutation` | `NV-03` | 6 | 5 | 選好しない | ownerの現在bufferとの関係は型名に出るが、viewであることも、次の`next()`で失効することも示せない。一時性の説明はどちらの候補でもDocCと失効時のprecondition messageに頼ることになり、その差のために名前を長くする理由が弱い |

## 判断群ごとの回答

| 判断群 | 選好するCandidate ID | 最終判断へ渡す理由 | 残る留保 |
| --- | --- | --- | --- |
| Module名 | `MN-03` | 現在のmoduleの中心機能（`next_permutation`系）と、暫定確定した入口・ownerの語幹にそろえる。全順列APIとの区別が名前で付く | 互換mode（`COMPATIBLE_ATCODER_2025`）では同じmoduleに全順列の`unsafePermutations()`もあり、名前と完全には一致しない。将来`next_permutation`系以外を加えるなら、再度のrenameか別moduleが要る。target・import・DocC URLのrename費用が残る |
| 通常版一時view | `NV-01` | 最短で現行互換、call siteの読みが自然。一時性はどちらの候補でも文書に頼り、`Current`を足しても失効条件までは伝わらない | 型名で一時性を伝えることを優先するなら`NV-03`が残る唯一の候補になる。`NV-01`を選ぶ場合、DocCと失効時のprecondition message（現行は"Permutation view is no longer valid"）で「view」であることを明示し続ける必要がある |

## 完了確認

- 4候補を再評価した。
- 選好欄は採点の完了条件に含めない。記入内容は評価意見として保存した。
- 採用・rename・公開契約変更を行っていない。

# PermutationModule公開API名称採点 — 姫 Round 2

## 状態

Round 2採点者: 姫（Claude）。共通入力は`PERMUTATION_PUBLIC_API_NAMING_ROUND2_INPUT.md`。
Round 1の他者理由を読んだ後の再評価であり、初回票は上書きしない。採点は採用判断ではない。

## Round 2採点表

| 対象surface | 候補シンボル | Candidate ID | Round 1 | Round 2（1〜9） | 維持・変更の理由 | 他者理由への賛同・反証 |
| --- | --- | --- | --- | --- | --- | --- |
| Module名 | `PermutationModule` | `MN-01` | 8 | 6 | 8→6。ユーザーが暫定確定した入口`nextPermutations()`と語幹がそろわないこと、ユーザーが挙げたswift-algorithmsとの重なり（`PermutationModule`が順列一般、つまり`permutations()`と同じ領域に見える）を重く見直した。PermutationModuleは破壊的変更を許す整理中のmoduleなので、rename費用でRound 1ほど加点しない | Userの「swift-algorithmとのかぶり」に賛同する。V3の「互換性重視なら有力」は認めるが、利用者は通常`AcCollections`からimportし、module名の互換費用は小さい |
| Module名 | `NextPermutationModule` | `MN-03` | 4 | 7 | 4→7。入口`nextPermutations()`の暫定確定で、moduleと入口の語幹が一致する利点が確定した。C++の`next_permutation`から検索でき、swift-algorithmsの全列挙とも名前で区別できる | V3の「`NE-01`との語幹整合が強い」に賛同する。単数`Next`と複数結果の関係は、入口の綴りがすでに同じ問題を持つため、module名だけの追加費用にはならない |
| 通常版owner | `NextPermutations` | `NO-01` | 7 | 8 | 7→8。borrowed ownerが`BorrowedNextPermutations`に暫定確定したため、通常版`NextPermutations`との対が「`Borrowed`の有無だけ」になり、予測可能性が最も高い | Round 1の反証（複数形が`Sequence`に見える）は残るが、`BO-01`も同じ形なので、片方だけ変えると対応がかえって崩れる。V3の「`NE-01`との整合は最良」に賛同する |
| 通常版owner | `NextPermutationCursor` | `NO-06` | 5 | 3 | 5→3。`BO-01`の暫定確定で、通常版だけ`Cursor`にすると`BorrowedNextPermutations`と`NextPermutationCursor`の対応が崩れる。入口との語幹ずれも残る（姫提出） | Userの「`Cursor`は意味的にSwift側で凍結されている印象」は、Swift標準に定着した語ではないという点で賛同する（凍結の経緯は未確認）。V3の「状態機械を簡潔に表す」は認めるが、family対応の損失の方が大きい |
| 通常版一時view | `Permutation` | `NV-01` | 6 | 6 | 維持。owner`NextPermutations`配下で`NextPermutations.Permutation`と読め、`while let permutation = p.next()`とも自然につながる。型名を書く場面は少ない | V3の「互換維持以外は`NV-03`に劣る」には一部賛同するが、一時性はどの候補でも文書に頼る（Round 2入力の注記）ため、差は小さいとみる |
| 通常版一時view | `View` | `NV-02` | 6 | 5 | 6→5。最も相性のよかったowner`NO-06`の配下（`NextPermutationCursor.View`）を下げたため。`NextPermutations.View`では「次の順列たちのview」と読め、順列一件の窓であることが伝わりにくい（姫提出） | V3の「`NO-06`配下なら明瞭」に賛同する。その前提が崩れたので点を下げた |
| 通常版一時view | `CurrentPermutation` | `NV-03` | 5 | 6 | 5→6。owner`NextPermutations`が「今の位置を持つ」状態なので、`NextPermutations.CurrentPermutation`は一時性と順列性を両立し、長さも許容範囲と見直した | V3の「意味と長さの均衡が良い」に賛同する。ただし`Current`だけでは失効条件を示さず、`NV-01`との差は文書の書き方次第で、決定的ではない |
| 補助宣言名 | `Value` | `GP-01` | 6 | 5 | 6→5。Round 1の主な支持理由（nested `Permutation`の`Element`と衝突しない）が、下記の確認で決定的ではなくなったため | V3の「実装都合を優先」に対し、その実装都合は回避できる見込みが立った。Userの「どっちでもいい」も踏まえ、強く推す理由が残らない |
| 補助宣言名 | `Element` | `GP-02` | 5 | 7 | 5→7。一時directoryで、generic parameterを`Element`にした非コピーownerのnested `RandomAccessCollection`が、typealiasを書かずにcompileでき、`Permutation.Element`が外側の`Element`に解決することを確かめた（Swift 6.4、最小の試験codeで、実sourceの`@inlinable`等を含む確認ではない）（姫提出） | V3の「実装可能なら一貫性が高い」に賛同する。Round 1の反証（衝突回避が未確認）は、最小構成では解消した。実sourceでの確認はrename実装時に要る |

## 完了確認

- 全9候補を再採点した。
- Round 1からの変化または維持理由を記録した。
- 採用・rename・公開契約変更を行っていない。

# PermutationModule公開API名称比較 — 姫 Round 4

## 状態

Round 4回答者: 姫（Claude）。共通入力は`PERMUTATION_PUBLIC_API_NAMING_ROUND4_INPUT.md`。
Round 3の採点形式を保ち、候補ごとの自由記述欄を追加した。まだ回答を開始していない。

## Round 4比較表

| 対象surface | 候補シンボル | Candidate ID | Round 3 | Round 4（1〜9） | 自由記述 |
| --- | --- | --- | --- | --- | --- |
| Module名 | `PermutationModule` | `MN-01` | 5 | 5 | Round 3から維持。補足の事実が二つある。(1) package productは`AcCollections`だけで、利用者のcall siteにmodule名はほとんど現れない。module名が見えるのは主にDocCのURL・見出しとCIの文書target一覧である（外部から`import PermutationModule`できるかは未確認）。そのため、維持でも改名でも利用者のsourceへの影響は小さい。(2) 「他moduleの`〜Module`形式とそろう」という支持理由について、赤黒木の本体moduleは`RedBlackTreeCollections`で、`〜Module`は四つ中三つに留まる。同じpackageで`RedBlackTreeModule`から`RedBlackTreeCollections`へ改名し、旧名を互換targetとして残した前例がある。形式の統一はこの候補の決め手になりにくい。将来の総称を保つ利点は、予定された別APIがない現時点では仮定に依存する |
| Module名 | `NextPermutationModule` | `MN-03` | 7 | 7 | Round 3から維持。入口`nextPermutations()`・owner`NextPermutations`と語幹がそろい、swift-algorithmsの全順列（`permutations()`）と名前で区別できる。上の(1)のとおりcall siteへの影響は小さく、費用は主にDocC URL・CI一覧・文書内の表記に限られる。残る懸念は二つ。互換modeでは同じmoduleに全順列の`unsafePermutations()`があり、名前と中身が完全には一致しない。将来`next_permutation`系以外を加えると、名前が狭くなる。別論点：改名する場合、旧名を互換用に残すかは赤黒木の前例を参考に別途判断が要る（候補・契約の変更ではなく移行方法の論点） |
| 通常版一時view | `Permutation` | `NV-01` | 7 | 7 | Round 3から維持。V3の「独立所有値という誤読を型名で減らす」には一部賛同するが、利用者が型名を目にするのは主にDocCと型推論の結果表示で、通常のcall siteは`while let permutation = p.next()`である。誤読が起きる場面（viewを保存して後で読む）を止めているのは、型名ではなく失効時のprecondition（現行の文言は"Permutation view is no longer valid"）である。短さと現行互換を優先する。残る懸念：DocCと失効の文言で「view」であることを示し続ける必要がある |
| 通常版一時view | `CurrentPermutation` | `NV-03` | 5 | 5 | Round 3から維持。ownerの現在bufferに属することが型名に出るのは確かな利点で、V3の重視点は理解できる。ただ`Current`は時間的な位置を示すだけで、viewであること、次の`next()`で失効することまでは伝えず、DocCとpreconditionの補完は`NV-01`と同じだけ要る。その差に対して名前が長くなる点を重く見た。Userが両候補を同点としている以上、決め手は「型名で一時性の手掛かりを出す価値をどれだけ重く見るか」の一点になると考える |

## 完了確認

- 4候補を再評価した。
- 各候補の点数を記入した。
- 自由記述は、点数だけでは残らない理由や懸念がある候補について記入した。
- 採用・rename・公開契約変更を行っていない。

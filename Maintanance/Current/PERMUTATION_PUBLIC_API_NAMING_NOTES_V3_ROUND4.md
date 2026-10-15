# PermutationModule公開API名称 — V3 Round 4自由記述

共通入力: `PERMUTATION_PUBLIC_API_NAMING_ROUND4_INPUT.md`

## Module名

### 自由記述

現在の利用者に直接見えるのは通常`AcCollections`のimportと`nextPermutations()`であり、module名をcall siteで読む頻度は低い。そのためmodule名には、現在の一機能との語幹一致より、package内で何を収容する境界かを示す役割を重く見ている。`PermutationModule`は将来scopeと既存体系を保つが、swift-algorithmsの全順列APIと領域が重なって見える。`NextPermutationModule`は現在の中心機能と検索語を明確にする一方、互換modeの`unsafePermutations()`や将来の別方式を収める名前としては狭い。

Round 3で姫が示した「現時点で予定された別APIがない以上、将来scopeは仮定に依存する」という反証は妥当である。対して、module renameは公開入口名の改善とは異なり、利用場面で得られる便益が小さく、target・import・DocC URL・package設定へ影響する。この変更費用を負うなら、利用者がmoduleを直接選ぶ場面で実際に誤解が減ることを根拠にしたい。

どちらを採っても、後続順列だけを列挙する契約と、現在の並びを最初に返す契約はmodule名だけでは説明できない。入口DocCによる補完は残る。

### 追加で確認したい事実・残る論点

最終判断では、moduleを直接import・依存指定する利用者がどの程度いるかと、互換modeの`unsafePermutations()`を今後も同じmoduleへ保持するかを分けて考えるとよい。前者はrename便益、後者は名前とscopeの一致に影響する。ただし、追加調査がなくても「現在機能への明確さ」と「収容境界・互換性」のどちらを優先するかという判断自体は可能である。

## 通常版一時view

### 自由記述

一時viewの型名は通常call siteで明示されにくいが、型を参照する利用者や診断・DocCでは所有関係の理解に効く。`Permutation`は`NextPermutations.Permutation`として短く自然で、現行互換である。一方、単独で見たときは保存可能な独立値と誤読されやすい。`CurrentPermutation`はownerの現在bufferに属する状態であることを少し強く示すが、viewであること、次の`next()`で失効すること、保存には`Array`へのcopyが必要なことまでは示さない。

したがって、名前だけで安全性を完成させる比較ではない。`Current`が減らせるのは「独立所有値」という初期誤読の一部であり、具体的な寿命はどちらでもDocCとprecondition messageが担う。長さとrename費用に対して、この初期誤読の低減をどれだけ評価するかが判断軸になる。

どちらの場合も、module入口と型DocCで一時view、単一buffer、次の`next()`での失効、保存時のcopyを一貫して示す必要がある。

### 追加で確認したい事実・残る論点

追加の事実確認をするなら、型名が利用者コードや生成DocCで現れる主要箇所を比較すると、`Current`の説明効果と冗長さを実物で判断しやすい。ただし、具体的失効条件を型名だけで表せない点は確認結果によらず残る。

## 境界確認

- この記述は採用、不採用、順位、点数、一つへの絞り込みを必須としない。
- AIの評価意見はユーザーの最終決定を置き換えない。

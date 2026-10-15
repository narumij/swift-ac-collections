# PermutationModule公開API名称 Round 2入力

## 状態

Round 1後も判断が分かれた4項目だけを再評価するための共通入力。Round 1の票は上書きしない。
通常入口、borrowed入口、borrowed ownerはユーザー暫定確定済みのため対象外とする。

## Module名

| ID | シンボル | Round 1で支持された理由 | Round 1で示された反証 |
| --- | --- | --- | --- |
| `MN-01` | `PermutationModule` | 短い。他moduleの形式と整合。通常は`AcCollections`経由で、module名に細部を載せる必要が薄い。rename不要で将来scopeを保てる | 現行機能の`next_permutation`性が出ず、Userはswift-algorithmsとの重なりを懸念 |
| `MN-03` | `NextPermutationModule` | C++の`next_permutation`との対応、検索性、`nextPermutations()`との語幹整合 | module名の利用場面に比べrename費用が大きい。単数`Next`と複数結果の関係、将来scopeの狭さ |

## 通常版owner

| ID | シンボル | Round 1で支持された理由 | Round 1で示された反証 |
| --- | --- | --- | --- |
| `NO-01` | `NextPermutations` | 入口から型名を予測でき、短く現行互換 | 複数形が値の集合や`Sequence`に見える |
| `NO-06` | `NextPermutationCursor` | 一つの状態を手動で進める非`Sequence` ownerだと表す | 入口との語幹ずれ。`Cursor`がSwiftで非標準または意味的に凍結された印象を持たれる |

## 通常版一時view

| ID | シンボル | Round 1で支持された理由 | Round 1で示された反証 |
| --- | --- | --- | --- |
| `NV-01` | `Permutation` | 短く、返されたものが順列だと自然に読める | 独立所有値に見え、次の`next()`で失効する一時性を隠す |
| `NV-02` | `View` | owner storageへの窓であることをpackage内語彙で示す | 単独では順列であることが消え、具体的失効条件までは示さない |
| `NV-03` | `CurrentPermutation` | 現在状態と順列性を両立し、長さも抑える | `Current`だけではviewであることや失効条件を特定できない |

どの候補も具体的な失効境界は文書を必要とする。

## Generic parameter

| ID | シンボル | Round 1で支持された理由 | Round 1で示された反証 |
| --- | --- | --- | --- |
| `GP-01` | `Value` | 現行実績があり、nested `Permutation.Element`との名前衝突を避ける | borrowed ownerの`Element`と揃わず、DocC・診断で対応しにくい |
| `GP-02` | `Element` | 両ownerの公開宣言・DocC・診断を統一する | nested Collectionの`Element`との衝突を避ける実装可能性が未確認 |

## Round 2の記録方法

- 各判断群の候補を`1`〜`9`で再採点する。
- Round 1から点または見解が変わった場合は、その理由を明記する。
- 他者理由への賛同・反証を記録し、平均や多数決による採用は行わない。

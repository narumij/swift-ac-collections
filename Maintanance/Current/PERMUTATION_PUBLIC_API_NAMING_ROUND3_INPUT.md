# PermutationModule公開API名称 Round 3入力

## 状態

Round 2後も未決の2判断・4候補を最終比較するための共通入力。Round 1・2の票を上書きしない。
通常入口、通常owner、borrowed入口、borrowed owner、generic parameterはユーザー暫定確定済み。

## Module名

| ID | シンボル | Round 2で残った支持理由 | Round 2で残った反証 |
| --- | --- | --- | --- |
| `MN-01` | `PermutationModule` | 他moduleの`〜Module`形式、rename不要、将来のPermutation APIを収容できる総称 | Userはswift-algorithmsとの領域の重なりを感じる。暫定確定した入口`nextPermutations()`と語幹が揃わない |
| `MN-03` | `NextPermutationModule` | User選好。C++の`next_permutation`との検索性、全順列APIとの区別、入口との語幹整合 | module名を現在機能へ狭める。直接利用場面が少なくrename便益が小さい可能性。単数名と複数結果の説明が要る |

判断軸は、moduleを将来のPermutation総称として保つか、現在の中心機能へ明確に寄せるかである。

## 通常版一時view

| ID | シンボル | Round 2で残った支持理由 | Round 2で残った反証 |
| --- | --- | --- | --- |
| `NV-01` | `Permutation` | 最短でcall siteが自然。現行互換。`NextPermutations.Permutation`として順列一件だと読める | 独立所有値に見え、現在bufferへの一時viewであることを型名に載せない |
| `NV-03` | `CurrentPermutation` | 順列性を保ちながら、ownerの現在bufferとの関係を型名へ載せる | 長くなる。`Current`だけではview・具体的失効条件を示せず、結局文書が要る |

どちらも具体的な失効境界は文書を必要とする。判断軸は、短さ・互換性と、型名での現在性のどちらを
優先するかである。

## Round 3の回答方法

- 各候補へ`1`〜`9`の点を付ける。
- 各判断群で一つを「選好」として明示する。同点でも、最終決定へ渡すならどちらかを選ぶ。
- 選好理由と、選ばなかった候補を退ける決め手を記録する。
- Userの回答は判断材料であると同時に、明示があれば最終決定になりうる。AI二者の選好は決定ではない。

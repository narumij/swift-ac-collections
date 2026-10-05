# Indexの解決と実行時検査の設計

> 状態: ドラフト4(2026-10-05 / Claude Opus 5.5)。確定候補。レビューを経て確定する。
> 基礎資料:
> - `Maintanance/RUNTIME_CHECK_POLICY.md`(Swift標準ライブラリの検査モデルの調査)
> - `Implements/Index/index_stale_check.md`(構成と状態ごとのIndex解決表。ユーザー作成)

## 中心となる考え方

Swift標準ライブラリと同じ契約モデルを基本とする。

例外は、再利用されるnodeの同一性を持つIndexを、内部nodeへ解決する境界だけである。
ここだけは常時検査する。

## この文書の目的

- Indexを内部nodeへ解決するとき、どの状態を受け入れ、どの状態を拒否するかを記録する。
- 各検査を、どの種類の検査として実装するかの基準を記録する。
- 特に、`-Ounchecked`で検査が外れたときに何を保証するかを定める。

個々の判断をその都度行わず、この基準から導けるようにする。

## Indexの解決

### 標準構成

標準構成は`ALLOW_CROSS_TREE_INDEX`が有効、`USE_LAZY_DETACH`が無効である。
`USE_LAZY_DETACH`はdeprecatedであり、この文書では扱わない。

`ALLOW_CROSS_TREE_INDEX`は、CoWで分岐したコレクション間でIndexを使えるようにするために用いる。
CoWで分岐した木は、Indexの解決では「別の木」として扱われる。

### 解決の手順

解決は`__purified_`で行う。

1. Indexが保持するtieと、受け取り側の木のtieが同一かを比べる。
   - これは拒否の条件ではなく、経路の選択である。
2. 同一なら、同じ木の経路に入る。Indexが保持するsealと、nodeの現在の世代を比べる。
3. 異なれば、別の木の経路に入る。
   - Indexのtagから、受け取り側の木のnodeを引き直す。
   - tagは`initializedCount`未満であることを先に確かめる。確保外のslotは引かない。
   - 引き直したnodeの世代を、Indexが保持する世代と照合する。
   - この経路はIndexが保持するtagとsealだけを読み、元の木のpointerを読まない。

### 状態ごとの結果

`o`は解決できる、`x`は拒否する、`-`は起こらないことを表す。

| Indexの状態 | 同じ木 | 別の木(標準構成) | 別の木(`ALLOW_CROSS_TREE_INDEX`無効) |
| --- | :---: | :---: | :---: |
| 健全 | o | o | x |
| 世代違い | x | x | x |
| detached | - | o | x |
| detached + 世代違い | - | x | x |

- **世代違い:** 対応するnodeが削除され、そのslotが再利用されている。
  - 別の木の経路では、受け取り側の木のnodeと照合する。CoWで分岐した相手の変更は、
    このIndexの有効性に影響しない。
- **detached:** Indexの由来する木のstorageが、すでに解放されている。
  - 生存中の木のtieはdetachedにならないので、同じ木の経路では起こらない。
  - 標準構成では、detachedであること自体は拒否の理由にならない。元のpointerを読まず、
    tagで受け取り側の木から引き直すからである。
  - そのため、元の木より長生きしたIndexも、CoWで分岐した木では引き続き使える。

### CoWで分岐した木と無関係な木

- CoWで分岐した木でのIndexの利用は、標準構成で保証する。
- 無関係なコレクションから取得したIndexの利用は事前条件違反であり、検出は保証しない。
- 表で「別の木」が`o`でも、無関係なコレクションでの動作を保証するものではない。
  - tagと世代が偶然一致すれば、無関係な木の別の要素へ解決し得る。
  - ただし、その場合も確保外のslotは引かず、元の木のpointerも読まない。

## 前提: Swiftの検査プリミティブ

| プリミティブ | `-Onone` | `-O` | `-Ounchecked` |
| --- | --- | --- | --- |
| `assert` | 検査する | 検査しない | 検査せず、成立を仮定してよい |
| `precondition` / `preconditionFailure` | 検査する | 検査する | 検査せず、成立を仮定してよい |
| `fatalError` | 停止する | 停止する | 停止する |

標準ライブラリも、`Array`の範囲検査や`Collection`のIndex検査を`-Ounchecked`では保証しない。
出典と詳細は基礎資料にある。

## 保証の範囲

- **事前条件を満たす利用:** 文書化された事前条件を満たす利用について、`-Ounchecked`でも、
  ライブラリ内部のunsafe実装がout-of-bounds accessやuse-after-free等のmemory-unsafeな
  動作を引き起こさないことを、設計上の保証対象とする。
- **事前条件を破る利用:** 原則として、`-Ounchecked`での安全性は保証しない。
  標準ライブラリと同じ契約モデルである。
- **例外:** Index解決の安全性だけは、`-Ounchecked`でも保つ。
  理由は「Index解決を例外とする理由」に記す。

## 分類と使い分け

表の「検査の種類」は方針であり、括弧内は現在の実装手段である。将来、専用のhelperへ
置き換えても方針は変わらない。

| 分類 | 検査の種類 | `-Ounchecked`で | 現行コードの例 |
| --- | --- | --- | --- |
| 呼び出し側の契約 | 契約検査(`precondition`) | 外れる | 空での`removeFirst` / `removeLast`、`endIndex`の参照、範囲初期化の型制約 |
| Index解決の安全性 | 常時検査(現在は`fatalError`) | 残る | 「状態ごとの結果」で`x`となるIndexの拒否、IndexRangeによる削除の範囲検証 |
| 無関係な木のIndex | 事前条件違反。検出は保証しない | — | 「CoWで分岐した木と無関係な木」 |
| 内部の不変条件 | 開発時検査(`assert`、DEBUG専用の検証) | 外れる | 赤黒木の構造検査、`isUnique()`の確認 |
| 内部破損の防壁 | 常時検査(現在は`fatalError`) | 残る | 範囲削除中のpayload有無の確認 |
| 資源の上限・到達不能 | 常時検査(現在は`fatalError`) | 残る | アラインメント異常、compact metadataの上限 |

### 呼び出し側の契約

呼び出し側が公開APIで確かめられる条件は、契約検査にする。
空かどうかは`isEmpty`で、`endIndex`かどうかは比較で確かめられる。

`-Ounchecked`でこの検査が外れるのは、そのモードの目的どおりである。
常時検査へ変えてはならない(2026-10-05ユーザー決定)。

### Index解決の安全性

この分類は、IndexがAPI上で意味的に正しいかを常時検査するものではない。
Indexを内部nodeへ解決するとき、拒否すべきhandleからunsafe accessへ進まないことだけを保証する。

そのため、次の扱いは互いに矛盾しない。

- `endIndex`の参照: 呼び出し側の契約
- 無関係な木のIndex: 事前条件違反で、検出は保証しない
- CoWで分岐した木のIndex: 正式に解決する

「状態ごとの結果」で`x`となる場合は、常時検査で停止する。

`precondition`の後の強制アンラップを、安全性の防壁として扱ってはならない。
`-Ounchecked`では、nilに対する強制アンラップが安全な停止を提供することを前提にできない。

この契約は`Maintanance/RED_BLACK_TREE_REMAINING_TASKS.md`で「全構成で維持」として採用済みである。
実装上の注記は`UnsafeTreeV2+Subscript.swift`の`_unsafeMutableAddress`にある。

### 内部の不変条件

赤黒木の構造的な不変条件は、毎操作で検証すると性能特性を壊す。
開発時検査にとどめる。

### 内部破損の防壁

内部破損があれば直ちに確保外アクセスへ進む境界では、安価な検査を常時検査として
残してよい。採用はホットパスの費用と照らして個別に判断する。

防壁として採用する検査は、次をどちらも満たすものに限る。

- 検査そのものが、確保外のメモリへのアクセスを必要としない。
- 危険なpointer解決やdereferenceより前に実行できる。

unsafeなdereferenceの後に結果を確かめても、防壁にはならない。
別の木の経路で、tagを引く前に`initializedCount`と比べるのは、この規則に沿った例である。

このライブラリのnodeは、個別に解放されずrecycle poolへ戻る。木が存続している間、pool内の
nodeのheaderは確保済みの領域にある。範囲削除中のpayload有無の確認が防壁として成立するのは、
この前提で読むheaderが確保内にあるからである。この前提が変わる場合は、防壁を見直す。

## Index解決を例外とする理由

Swift標準ライブラリの`Array`のIndexは、offsetである。

```text
Array:  Index ──> offset
RBT:    Index ──> identity / generation ──> 再利用されるslot ──> node
```

このライブラリのIndexはnodeの同一性を指し、そのslotは削除後に再利用される。検査が外れると、
古いIndexが別の要素を黙って読む。利用者が気づきにくい失敗である。

有効性の検査はseal比較とtie同一性の比較であり、O(1)で済む。
費用が小さく、失敗が静かに広がるため、標準ライブラリより強い保証を例外として持つ。

## `-Ounchecked`での挙動とテスト

- 空の削除のDeath Testは、`_O_UNCHECKED`では停止せずに終わる。これは仕様どおりである。
- Index解決の安全性に関するテストは、`_O_UNCHECKED`でも成功しなければならない。
- CIは`_O_UNCHECKED` traitを使わない。この構成の確認は、必要時に範囲を絞って行う。

## 未決事項

- `Design-MemorySafety.md`は、木が解放された後のIndexを「detachedとして拒否する」と書いている。
  - これは`ALLOW_CROSS_TREE_INDEX`無効時の挙動であり、標準構成の表と食い違う。
  - Index統合後の設計文書の更新(P10)で揃える。
- `_MemoryLayout.swift`の`precondition(count <= maximumCount)`と、`unsafe_node+pointer.swift`
  の`precondition(prefix >= 0)` / `precondition(capacity >= 0)`は、確保サイズの計算に関わる。
  - 呼び出し側の契約か、内部破損の防壁かを確認する。
  - 後者なら常時検査へ変えるかを判断する。
- `UnsafeTreeV2+InsertRange.swift`の重複キーによる停止は、現在`fatalError`である。
  - 標準ライブラリの`Dictionary(uniqueKeysWithValues:)`は、文書に「Precondition: The sequence
    must not have duplicate keys.」と明記している。
  - 呼び出し側の契約に当たるので、契約検査へ寄せる根拠は強い。
  - 寄せる前に、`-Ounchecked`で重複キーが通ったとき木がmemory-unsafeにならないかを確認する。
- `UnsafeTreeV2+Erase.swift`の`fatalError(.outOfBounds)`は、エラー種別が合っていないと
  コメントされている。分類は内部破損の防壁でよいかを確認する。
- 4型の`+RangeExpression.swift`は`fatalError("\(error)")`で停止する。
  - Index解決の安全性の分類に入る。
  - メッセージを他の箇所と揃えるかは別途判断する。
- 未結線の`Message.keyMismatch` / `outOfRange`は削除待ちとして凍結中であり、この文書の対象外とする。

## 関連文書

- `Design-MemorySafety.md`: Indexの世代、storage同一性、detached検出の仕組み
- `Quality-Checklist.md`: `-Ounchecked`を通常の品質保証と区別する方針
- `Maintanance/RUNTIME_CHECK_POLICY.md`: 標準ライブラリの検査モデルの調査
- `Implements/Index/index_stale_check.md`: 構成と状態ごとのIndex解決表

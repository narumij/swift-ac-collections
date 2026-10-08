<!-- API名をSwift Coreチーム相当の品質にすることは不可能なので、なるべく引用する方針 -->
# 現行APIマトリクス

この文書は、通常構成の `RedBlackTreeCollections` が提供する現行APIを、4種類の
コンテナで横断的に確認するための開発者向け一覧である。

- ✅: 利用できる
- —: 利用できない
- △: 同じ目的の型固有APIを利用する
- TODO: 採用済みで未実装
- 検討: 採用するか未決定

`COMPATIBLE_ATCODER_2025`、Deprecated API、旧Slice APIは対象外とする。
同じ意味を持つジェネリック版やRange種別ごとのオーバーロードは、原則として
1行へまとめる。

## 型と生成

| API名 | Set | MultiSet | MultiMap | Dictionary | おおよその機能 |
| --- | :---: | :---: | :---: | :---: | --- |
| `init()` | ✅ | ✅ | ✅ | ✅ | 空のコンテナを生成する |
| `init(minimumCapacity:)` | ✅ | ✅ | ✅ | ✅ | 最低容量を指定して生成する |
| `init(_ sequence:)` | ✅ | ✅ | — | — | 要素列から生成する |
| `init(_ range:)` | ✅ | ✅ | — | — | Rangeの要素から生成する |
| `init(keysWithValues:)` | — | — | ✅ | — | `(Key, Value)` の列からMultiMapを生成する |
| `init(uniqueKeysWithValues:)` | — | — | — | ✅ | 一意なキーと値の列からDictionaryを生成する |
| `init(_:uniquingKeysWith:)` | — | — | — | ✅ | 重複キーをクロージャで統合してDictionaryを生成する |
| `init(grouping:by:)` (`Value == [S.Element]`) | — | — | — | ✅ | 要素列をキーでグループ化し、キーごとに要素の配列を値とするDictionaryを生成する |
| `init(grouping:by:)` (`Value == S.Element`) | — | — | ✅ | — | 各要素にキーを割り当て、要素ごとに1ペアを保持するMultiMapを生成する |
| `init(arrayLiteral:)` | ✅ | ✅ | ✅ | ✅ | 配列リテラルから生成する |
| `init(dictionaryLiteral:)` | — | — | ✅ | ✅ | Dictionaryリテラルから生成する |
| `reserveCapacity(_:)` | ✅ | ✅ | ✅ | ✅ | 最低容量を予約する |
| `capacity` | ✅ | ✅ | ✅ | ✅ | 現在の格納容量を返す |

## 基本状態と参照

| API名 | Set | MultiSet | MultiMap | Dictionary | おおよその機能 |
| --- | :---: | :---: | :---: | :---: | --- |
| `isEmpty` | ✅ | ✅ | ✅ | ✅ | 要素が空かを返す |
| `count` | ✅ | ✅ | ✅ | ✅ | 全要素数を返す |
| `count(of:)` | ✅ | ✅ | — | — | 指定要素の個数を返す。Setでは0または1 |
| `count(forKey:)` | — | — | ✅ | ✅ | 指定キーの要素数を返す。Dictionaryでは0または1 |
| `contains(_:)` | ✅ | ✅ | — | — | 指定要素が存在するかを返す |
| `contains(key:)` | — | — | ✅ | ✅ | 指定キーが存在するかを返す |
| `first` | ✅ | ✅ | ✅ | ✅ | 最小位置の要素を返す |
| `last` | ✅ | ✅ | ✅ | ✅ | 最大位置の要素を返す |
| `min()` | ✅ | ✅ | ✅ | ✅ | 最小要素を返す |
| `max()` | ✅ | ✅ | ✅ | ✅ | 最大要素を返す |
| `first(where:)` | ✅ | ✅ | ✅ | ✅ | 条件を満たす最初の要素を返す |
| `subscript(position:)` | ✅ | ✅ | ✅ | ✅ | Index位置の要素を参照する(読み取り専用) |
| `subscript(key:) -> Value?` | — | — | — | ✅ | キーに対応する値を参照・更新する。`nil` 代入で削除する |
| `subscript(key:default:) -> Value` | — | — | — | ✅ | キーに対応する値を参照・更新し、存在しない場合は既定値を使う |
| `subscript(key:) -> Values` | — | — | ✅ | — | キーに対応する全mapped valueの `RedBlackTreeMappedValuesView` を返す。View経由の削除は対応するペアを削除する |
| `subscript(mappedValueAt:)` | — | — | 検討 | — | Index位置の要素を返す |
| `values(forKey:)` | — | — | — | — | 現行APIなし。`subscript(key:)` が返すMappedValues Viewを使う |
| `keys` | — | — | ✅ | ✅ | キーだけを遅延走査するSequenceを返す |
| `values` | — | — | ✅ | ✅ | 全mapped valueを参照・更新する `RedBlackTreeMappedValuesView` を返す |

## Indexと探索

| API名 | Set | MultiSet | MultiMap | Dictionary | おおよその機能 |
| --- | :---: | :---: | :---: | :---: | --- |
| `startIndex` | ✅ | ✅ | ✅ | ✅ | 先頭Indexを返す |
| `endIndex` | ✅ | ✅ | ✅ | ✅ | 終端Indexを返す |
| `isElement(at:)` | ✅ | ✅ | ✅ | ✅ | Indexが現在アクセス可能な要素を指すか判定する |
| `isEnd(_:)` | ✅ | ✅ | ✅ | ✅ | Indexがこのコンテナの有効な終端か判定する |
| `firstIndex(of:)` | ✅ | ✅ | ✅ | ✅ | 要素またはキーに対応する最初のIndexを返す |
| `index(forKey:)` | — | — | — | ✅ | キーに対応するIndexを返す |
| `find(_:)` | ✅ | ✅ | ✅ | ✅ | 要素またはキーの検索位置を返す |
| `lowerBound(_:)` | ✅ | ✅ | ✅ | ✅ | 要素またはキー以上となる最初のIndexを返す |
| `upperBound(_:)` | ✅ | ✅ | ✅ | ✅ | 要素またはキーより大きい最初のIndexを返す |
| `equalRange(_:)` | ✅ | ✅ | ✅ | ✅ | 等値要素を表す解決済みIndex範囲を返す |
| `index(after:)` / `formIndex(after:)` | ✅ | ✅ | ✅ | ✅ | 次のIndexへ進める |
| `index(before:)` / `formIndex(before:)` | ✅ | ✅ | ✅ | ✅ | 前のIndexへ戻す |
| `index(_:offsetBy:)` / `formIndex(_:offsetBy:)` | ✅ | ✅ | ✅ | ✅ | 指定距離だけIndexを移動する |
| `index(_:offsetBy:limitedBy:)` / `formIndex(_:offsetBy:limitedBy:)` | ✅ | ✅ | ✅ | ✅ | 制限位置を越えない範囲でIndexを移動する |
| `distance(from:to:)` | ✅ | ✅ | ✅ | ✅ | 2つのIndex間の距離を返す |

`isElement(at:)` は `endIndex` に `false`、`isEnd(_:)` は有効な `endIndex` に
`true` を返す。公開APIとしての `isValid` は提供しない。

## Index RangeとBound

| API名 | Set | MultiSet | MultiMap | Dictionary | おおよその機能 |
| --- | :---: | :---: | :---: | :---: | --- |
| `IndexRange` | ✅ | ✅ | ✅ | ✅ | 解決済みの半開Index範囲を表す |
| `IndexRangeExpression` | ✅ | ✅ | ✅ | ✅ | Index演算子から作る範囲式を表す |
| `Bound` | ✅ | ✅ | ✅ | ✅ | 値またはキーを基準に単一位置を表す |
| `BoundRangeExpression` | ✅ | ✅ | ✅ | ✅ | 値またはキーを基準に範囲を表す |
| `containsSubrange(_:)` | ✅ | ✅ | ✅ | ✅ | Index範囲がコンテナ内に収まり、順序も正しいか判定する |
| `subscript(IndexRange)` | ✅ | ✅ | ✅ | ✅ | Index範囲のRange Viewを返す |
| `subscript(IndexRangeExpression)` | ✅ | ✅ | ✅ | ✅ | Index範囲式を解決してRange Viewを返す |
| `subscript(UnboundedRange)` | ✅ | ✅ | ✅ | ✅ | 全範囲のRange Viewを返す |
| `erase(IndexRange…)` | ✅ | ✅ | ✅ | ✅ | Index範囲の要素を削除し、後続Indexを返す |
| `erase(IndexRange…, where:)` | ✅ | ✅ | ✅ | ✅ | Index範囲内で条件を満たす要素を削除する |
| `subscript(Bound) -> Element?` | ✅ | ✅ | ✅ | ✅ | Boundを解決し、要素または `nil` を返す |
| `erase(Bound)` | ✅ | ✅ | ✅ | ✅ | Boundで指定した要素を削除する |
| `subscript(BoundRangeExpression)` | ✅ | ✅ | ✅ | ✅ | Bound範囲をRange Viewへ評価する。不成立時は空Viewになる |
| `erase(BoundRangeExpression)` | ✅ | ✅ | ✅ | ✅ | Bound範囲を評価して削除する |
| `erase(BoundRangeExpression, where:)` | ✅ | ✅ | ✅ | ✅ | Bound範囲内で条件を満たす要素を削除する |
| `distance(from: Bound, to: Bound)` | ✅ | ✅ | ✅ | ✅ | 2つのBound間の距離を返す |

Index Rangeの不正は安全な操作では拒否される。一方、Boundは失敗を値で表現し、
単一Boundは `nil`、Bound範囲は空Viewになる。

## 挿入と更新

| API名 | Set | MultiSet | MultiMap | Dictionary | おおよその機能 |
| --- | :---: | :---: | :---: | :---: | --- |
| `insert(_:)` | ✅ | ✅ | ✅ | ✅ | 要素を挿入する |
| `insert(_:hint:)` | ✅ | ✅ | ✅ | ✅ | ヒントを用いて要素を挿入する。Set/Dictionaryは `(inserted:, indexAfterInsert:)`、Multi系は挿入位置のIndexを返す |
| `insert(key:value:)` | — | — | ✅ | ✅ | キーと値を挿入する |
| `insert(key:value:hint:)` | — | — | 検討 | ✅ | ヒントを用いてキーと値を挿入する |
| `update(_:hint:)` | ✅ | — | — | ✅ | ヒントを用いて挿入、または既存要素を置換し、旧要素を返す。新規挿入時は `nil` |
| `update(with:)` | ✅ | — | — | — | Set要素を挿入または置換し、旧要素を返す |
| `update(_:at:)` | — | ✅ | — | — | Index位置の要素を等価な要素で置換し、旧要素を返す。無効Indexまたは非等価時は `nil` |
| `updateValue(_:at:)` | — | — | ✅ | — | Index位置の値を更新し、旧値を返す。無効Indexでは `nil` |
| `updateValue(_:forKey:)` | — | — | — | ✅ | キーの値を更新または挿入し、旧値を返す |
| `updateValue(_:forKey:hint:)` | — | — | — | ✅ | ヒントを用いてキーの値を更新または挿入し、旧値を返す |
| `index(inserting:)` | ✅ | ✅ | ✅ | ✅ | 挿入し、挿入位置のIndexを返す |
| `insert(contentsOf:)` | — | ✅ | ✅ | — | 別コンテナまたはSequenceの内容を追加する |
| `inserting(contentsOf:)` | — | ✅ | ✅ | — | 内容を追加した新しい値を返す |
| `merge(_:)` | ✅ | — | — | — | Set、MultiSet、またはSequenceの要素を統合する |
| `merging(_:)` | ✅ | — | — | — | 統合した新しいSetを返す |
| `merge(_:uniquingKeysWith:)` | — | — | — | ✅ | Dictionaryまたはキー値列を統合し、重複キーをクロージャで解決する |
| `merging(_:uniquingKeysWith:)` | — | — | — | ✅ | 統合した新しいDictionaryを返す |
| `meld(_:)` | — | ✅ | ✅ | — | 同種コンテナを構造的に結合する。Multi系では重複を保持する |
| `melding(_:)` | — | ✅ | ✅ | — | 結合した新しい値を返す。Multi系では重複を保持する |

## 削除

| API名 | Set | MultiSet | MultiMap | Dictionary | おおよその機能 |
| --- | :---: | :---: | :---: | :---: | --- |
| `popFirst()` / `popLast()` | ✅ | ✅ | ✅ | ✅ | 端の要素をOptionalで取り出す |
| `removeFirst()` / `removeLast()` | ✅ | ✅ | ✅ | ✅ | 端の要素を取り出す。空の場合は失敗する |
| `remove(_:)` | ✅ | — | — | — | Setから指定要素を削除する |
| `remove(at:)` | ✅ | ✅ | ✅ | ✅ | Index位置の要素を削除して返す |
| `removeValue(forKey:)` | — | — | — | ✅ | キーに対応する値を削除する |
| `removeAll(keepingCapacity:)` | ✅ | ✅ | ✅ | ✅ | 全要素を削除する |
| `erase(_ index:)` | ✅ | ✅ | ✅ | ✅ | Index位置を削除し、後続Indexを返す |
| `erase(where:)` | ✅ | ✅ | ✅ | ✅ | 条件を満たす全要素を削除する |
| `eraseUnique(_:)` | — | ✅ | ✅ | — | 値またはキーに対応する1要素を削除する |
| `eraseMulti(_:)` | — | ✅ | ✅ | — | 値またはキーに対応する全要素を削除し、件数を返す |
| `erase(exactly:)` | ✅ | ✅ | ✅ | ✅ | Indexが現在利用可能なら要素を削除し、後続Indexを返す |

remove 系は Swift 標準APIとの整合を優先する。
erase 系は本ライブラリ固有のIndex・Range・複数要素削除を扱う。

## 走査、変換、比較

| API名 | Set | MultiSet | MultiMap | Dictionary | おおよその機能 |
| --- | :---: | :---: | :---: | :---: | --- |
| `makeIterator()` | ✅ | ✅ | ✅ | ✅ | 昇順Iteratorを生成する |
| `forEach(_:)` | ✅ | ✅ | ✅ | ✅ | 各要素を昇順に処理する |
| `filter(_:)` | ✅ | ✅ | ✅ | ✅ | 条件を満たす要素から同種コンテナを生成する |
| `sorted()` | ✅ | ✅ | ✅ | ✅ | 昇順配列を返す |
| `reversed()` | ✅ | ✅ | ✅ | ✅ | 逆順の列または配列を返す |
| `mapValues(_:)` | — | — | ✅ | ✅ | 値を変換し、キー構造を保つMapを返す |
| `compactMapValues(_:)` | — | — | ✅ | ✅ | 値をOptional変換し、`nil` の要素を除く |
| `elementsEqual(_:)` | ✅ | ✅ | ✅ | ✅ | 同じ順序の要素列か比較する |
| `lexicographicallyPrecedes(_:)` | ✅ | ✅ | ✅ | ✅ | 辞書式順序を比較する |
| `==` | ✅ | ✅ | ✅ | ✅ | 内容が等しいか比較する |
| `<` | ✅ | ✅ | ✅ | ✅ | 辞書式順序を比較する |
| `hash(into:)` | ✅ | ✅ | ✅ | ✅ | 内容をHasherへ供給する |
| `encode(to:)` / `init(from:)` | ✅ | ✅ | ✅ | ✅ | Codable形式へ変換する |
| `description` / `debugDescription` | ✅ | ✅ | ✅ | ✅ | 表示用文字列を返す |
| `customMirror` | ✅ | ✅ | ✅ | ✅ | デバッグ用Mirrorを返す |
| `isTriviallyIdentical(to:)` | ✅ | ✅ | ✅ | ✅ | 同一ストレージを共有しているか高速判定する |

## 集合演算

| API名 | Set | MultiSet | MultiMap | Dictionary | おおよその機能 |
| --- | :---: | :---: | :---: | :---: | --- |
| `union(_:)` / `formUnion(_:)` | ✅ | ✅ | — | — | 和集合を生成、または自身を更新する |
| `intersection(_:)` / `formIntersection(_:)` | ✅ | ✅ | — | — | 積集合を生成、または自身を更新する |
| `difference(_:)` / `formDifference(_:)` | ✅ | ✅ | — | — | 差集合を生成、または自身を更新する |
| `symmetricDifference(_:)` / `formSymmetricDifference(_:)` | ✅ | ✅ | — | — | 対称差を生成、または自身を更新する |

MultiSetの集合演算は重複数を考慮する。Setの演算と同じ名前でも、個数に関する
意味を確認して変更すること。

## 標準プロトコル適合

独自プロトコルは含めない。`Collection` と `BidirectionalCollection` は通常構成では
意図的に適合していない。

| 標準プロトコル | Set | MultiSet | MultiMap | Dictionary | 適合条件・備考 |
| --- | :---: | :---: | :---: | :---: | --- |
| `Sequence` | ✅ | ✅ | ✅ | ✅ | 昇順に要素を走査する |
| `Collection` | — | — | — | — | Index比較コストを反復へ持ち込まないため非適合 |
| `BidirectionalCollection` | — | — | — | — | 同上。前後移動用の独自Index APIは提供する |
| `SetAlgebra` | ✅ | — | — | — | Setのみ。MultiSetの重複数の意味は標準プロトコルに一致しない |
| `Equatable` | ✅ | ✅ | ✅ | ✅ | MultiMapとDictionaryは `Value: Equatable` |
| `Comparable` | ✅ | ✅ | ✅ | ✅ | MultiMapとDictionaryは `Value: Comparable` |
| `Hashable` | ✅ | ✅ | ✅ | ✅ | Set系は `Element: Hashable`、Map系は `Key: Hashable, Value: Hashable` |
| `Encodable` | ✅ | ✅ | ✅ | ✅ | Set系は `Element: Encodable`、Map系は `Key` と `Value` が `Encodable` |
| `Decodable` | ✅ | ✅ | ✅ | ✅ | Set系は `Element: Decodable`、Map系は `Key` と `Value` が `Decodable` |
| `Sendable` | ✅ | ✅ | ✅ | ✅ | 要素型が `Sendable` の場合の `@unchecked Sendable` 適合 |
| `ExpressibleByArrayLiteral` | ✅ | ✅ | ✅ | ✅ | Map系の要素は `(Key, Value)` |
| `ExpressibleByDictionaryLiteral` | — | — | ✅ | ✅ | MultiMapも同一キーを含むリテラルを受け取れる |
| `CustomStringConvertible` | ✅ | ✅ | ✅ | ✅ | `description` を提供する |
| `CustomDebugStringConvertible` | ✅ | ✅ | ✅ | ✅ | `debugDescription` を提供する |
| `CustomReflectable` | ✅ | ✅ | ✅ | ✅ | `customMirror` を提供する |

## Range View

Range系subscript(`IndexRange`、`IndexRangeExpression`、`UnboundedRange`、
`BoundRangeExpression`)は、SetとMultiSetでは `RedBlackTreeKeyOnlyRangeView`、
MultiMapとDictionaryでは `RedBlackTreeKeyValueRangeView` を返す。
MultiMapの `subscript(key:)` とMap系の `values` が返す
`RedBlackTreeMappedValuesView` はRange Viewではなく、mapped valueを要素とする
別のViewである(`API-Matrix-View.md` 参照)。

| API名 | Set | MultiSet | MultiMap | Dictionary | おおよその機能 |
| --- | :---: | :---: | :---: | :---: | --- |
| `startIndex` / `endIndex` | ✅ | ✅ | ✅ | ✅ | View固有の半開範囲境界を返す |
| `isElement(at:)` | ✅ | ✅ | ✅ | ✅ | IndexがView内の要素を指すか判定する |
| `isEnd(_:)` | ✅ | ✅ | ✅ | ✅ | IndexがView固有の終端か判定する |
| `isEmpty` / `count` | ✅ | ✅ | ✅ | ✅ | Viewの空判定または要素数を返す |
| `first` / `last` | ✅ | ✅ | ✅ | ✅ | Viewの端の要素を返す |
| `makeIterator()` | ✅ | ✅ | ✅ | ✅ | View内を昇順に走査する |
| `sorted()` / `reversed()` | ✅ | ✅ | ✅ | ✅ | Viewの要素を配列として返す |
| `keys` / `values` | — | — | ✅ | ✅ | KeyValue Viewのキーまたは値を走査する |
| `popFirst()` / `popLast()` | ✅ | ✅ | ✅ | ✅ | View端の要素をOptionalで削除する |
| `removeFirst()` / `removeLast()` | ✅ | ✅ | ✅ | ✅ | View端の要素を削除する |
| `erase()` | ✅ | ✅ | ✅ | ✅ | View全体を削除する |
| `erase(where:)` | ✅ | ✅ | ✅ | ✅ | View内で条件を満たす要素を削除する |
| `elementsEqual(_:)` | ✅ | ✅ | ✅ | ✅ | Viewと別Sequenceの要素を比較する |
| `lexicographicallyPrecedes(_:)` | ✅ | ✅ | ✅ | ✅ | Viewを辞書式比較する |
| `==` / `<` | ✅ | ✅ | ✅ | ✅ | View同士を比較する |

Viewの `endIndex` は基底コンテナ内の要素を指す場合がある。このため、Viewに対する
判定では `base.isElement(at:)` ではなく、必ず `view.isElement(at:)` と
`view.isEnd(_:)` を使い分ける。

## 公開面の監査候補

以下は宣言上 `public` だが、先頭が `_` であり、製品利用者向けAPIとして扱うかを
リリース前に確認すべき項目である。

| API名 | 現在の用途 |
| --- | --- |
| `_Key`, `_MappedValue`, `_PayloadValue` | 内部ジェネリック制約とpayload表現 |
| `__raw_find(_:)`, `__raw_end` | raw pointerを扱う内部フック。Setのみ、`BENCHMARK` trait有効時だけ公開される |

これらを製品APIとしない場合は、`package` または `internal` へ狭められるか、
`@usableFromInline` で十分かをABI公開前に確認する。

`_isIdentical(to:)`は監査を完了し、Range View・MappedValues Viewの
`@inlinable internal`な最適化hookへ縮小済みである。View同士の`==` / `<`の結果と
計算量には影響しない。

`_create(_:)` は削除済み。`___erase(_:)` と `_unsafe` / `_checked` ラベルの
subscriptは `COMPATIBLE_ATCODER_2025` 構成でのみ公開され、通常構成には存在しない。

## 更新ルール

公開APIを追加、削除、改名した場合は、同じ変更でこの表も更新する。
特に次の変更は意味論の差が見えにくいため、行を統合せず明示する。

- SetとMultiSetで重複数の扱いが異なるAPI
- DictionaryとMultiMapでキーの一意性が異なるAPI
- コンテナ全体とRange Viewで終端の意味が異なるAPI
- Index RangeとBound Rangeで不正入力時の挙動が異なるAPI

# 赤黒木4型アウトライン照合結果

2026-10-16、Astra。DOC-033。基準HEAD `1dc613ff`。Swift 6.4、macOS、通常構成（COMPATIBLE_ATCODER_2025無効）。

## 本文へ渡す結論

4型の見出しを維持して技術条件を補正。Setだけ生成・容量・Viewの独立節がないことを不足と断定せず、既存節で説明する。RBT-026の将来判断を先取りしない。スニペットの構成・掲載数は固定。

| 観点 | 確認事項 | 根拠（Sources/RedBlackTreeCollections以下） |
| --- | --- | --- |
| Index / CoW | 操作先の世代・削除状態で有効性が決まる。無関係なindexの誤用検出は保証しない | Documentation/API-Matrix.md、Documentation/Design/Design-CopyOnWrite.md |
| View | 同じindex型でも範囲はView固有。直接subscript変更と独立変数変更を区別 | Documentation/API-Matrix-View.md、RedBlackTreeMultiMap/RedBlackTreeMultiMap+Subscript.swift |
| Dictionary | defaultの読み取りは挿入しない。mergeのcombineは既存値・入力値の順 | RedBlackTreeDictionaryの+Subscript.swift、+Combining.swift |
| MultiSet | updateは旧値 == 新値のみ。unionは多重度加算、SetAlgebra非適合 | RedBlackTreeMultiSet.swift、+SetAlgebra.swift |
| MultiMap | key subscriptはMappedValuesView、pair範囲はindex range subscript。hintには順序条件がある | RedBlackTreeMultiMap.swift、+Subscript.swift |
| 結合 | insert系・Dictionary mergeは O(n log(m+n))、meld系は新しい木を構築して O(n+m) | 各型+Combining.swift、Implements/UnsafeTreeV2/+InsertRange・+SetAlgebra |
| 変換 | filter / mapValues / compactMapValuesは O(n)、クロージャコストは別 | Implements/UnsafeTreeV2/+Sequence・+KeyValue |
| コスト条件 | CoW複製、比較・要素操作は別途。複製は削除履歴も保持するため現在countだけの断定を避ける | Design-CopyOnWrite.md、Buffer実装 |

## 検証

[証拠フォルダ](Evidence/DOC-033-2026-10-16/)。

- 最初のSwiftPM実行は入れ子sandboxで失敗。製品テスト失敗ではない。
- `swift test --disable-sandbox --skip-update --filter 'RedBlackTree(Set|MultiSet|Dictionary|MultiMap).*(Initialization|Insertion|InsertContentsOf|Bound|ValueSemantics|RangeView|SetAlgebra|IndexValidity)|.*MappedValuesView'`：XCTest 400件、Swift Testing 16件、失敗0。全製品テストではない。
- 日英本文のSwiftブロック86個中、宣言・型制約断片8個を除く78個をcompile/run成功。文脈依存例には検証側でmap/key/indexを補った。manifestと実行出力を保存。全コメント期待値の自動assertではない。
- View検証例はswap、独立View変更が元に反映されないこと、直接subscript削除をpreconditionで確認。公開例の追加にはしない。
- MultiSetの旧 `remove(3)` を `eraseUnique(3)` に訂正。日英本文・公開型コメントへ同期。
- MultiMapの旧pair View説明と `map[key].values.swapAt` を訂正。pair走査例は `map[map.equalRange(key)]` に訂正。
- BoundのprintコメントはOptionalを返すことが分かる形に訂正。
- 本文ごとのコードフェンス数は変更前と同じ（snippet-counts.json）。掲載数維持は本文完成の証明ではない。

## DOC-034への引継ぎ

旧本文にはアウトラインと違う構成、本文と型コメント素材の併記があり、Dictionary日本語稿には英語素材が残る。技術訂正を本文完成とは扱わない。確定事項の文章化、日英・公開コメント同期、最終横断を続ける。DOC-037のユーザー受入前にDOC-035へ進まない。

# リポジトリ公開APIコードスニペット候補アンケート第2弾 — Codex回答

共通設問は`PUBLIC_API_CODE_SNIPPET_SURVEY_2.md`を正本とする。このfileをCodexの書き込み先とする。

## 回答状態

2026-10-10、Codex回答確定。

## TOP10

### 1. RedBlackTree各collectionの境界式subscript

- symbol: `subscript(bounds: BoundRangeExpression) -> View`
- 利用者の疑問: `lowerBound(_:)`、`upperBound(_:)`、`equalRange(_:)`をどのように組み合わせて、
  key基準の範囲を得るのか。
- 示すべき最小の振る舞い: `RedBlackTreeMultiSet`に重複値を入れ、
  `tree[lowerBound(2)..<upperBound(4)]`と`tree[equalRange(2)]`の要素列を示す。
- 理由: 標準の値Rangeと似た記法だが、端点はtree上で評価される独自の境界式である。個々の型や
  operatorの文章を読むより、生成からsubscript適用までを一つの式で見せる効果が大きい。

### 2. `RedBlackTreeMultiMap.subscript(key:) -> Values`

- 利用者の疑問: 同じkeyの複数valueをどう取得し、そのView経由の変更が元のmultimapへどう反映されるか。
- 示すべき最小の振る舞い: 同一keyへ複数valueを挿入し、`map[key]`を列挙してからView内の一件を
  削除し、元のmultimapにも対応するpairがなくなったことを示す。
- 理由: 戻り値は配列copyではなく可変Viewであり、読み取りだけの例や型説明だけでは所有関係を
  誤認しやすい。

### 3. `RedBlackTreeDictionary.subscript(_:default:)`

- 利用者の疑問: 存在しないkeyを読むだけの場合と、`+=`などでsubscript越しに変更する場合で、
  default値が辞書へ挿入されるか。
- 示すべき最小の振る舞い: 空の辞書で読み取り後はkeyが存在しないこと、
  `dictionary["a", default: 0] += 1`後は値が挿入されることを対比する。
- 理由: 「readは挿入しないがmodifyは挿入する」という二相の契約は重要で、短い前後比較が文章より明瞭。

### 4. `RedBlackTreeMultiSet.subscript(_ element:) -> View`

- 利用者の疑問: 値を渡すsubscriptが単一要素を返すのか、等価な全要素の範囲を返すのか。
- 示すべき最小の振る舞い: 重複する値を含むmultisetで`set[2]`を列挙し、Viewから一件を削除した後の
  `count(of: 2)`を示す。
- 理由: 通常のcollection subscriptとは意味が異なり、重複数と可変Viewの両方を一例で理解できる。

### 5. `Collection.nextPermutations()`

- 利用者の疑問: 全順列を返すのか、現在の並びから辞書順で後に続く順列だけを返すのか。
- 示すべき最小の振る舞い: `[2, 1, 3]`から開始し、得られる後続4件を`map(Array.init)`で示す。
- 理由: 一般的な`permutations()`と名前が近い一方、開始位置と列挙範囲が異なるため、出力列の例が
  最短の説明になる。

### 6. `OptionalArray1D.subscript(_:)`

- 利用者の疑問: 未設定slotへの値設定、上書き、`nil`代入による解除をどう書くか。
- 示すべき最小の振る舞い: 初期`nil`、値代入、読み出し、`nil`代入後の再確認を一続きで示す。
- 理由: Optionalを格納する通常の配列というより、slotの要素寿命を開始・終了するAPIであることが
  使用例から直感的に分かる。

### 7. `BareArray2D.init(repeating:width:height:)`と連鎖subscript

- 利用者の疑問: `width`と`height`の軸順、および2次元要素の読み書き記法。
- 示すべき最小の振る舞い: `width: 3, height: 2`の非対称shapeを作り、`array[y][x]`の端へ代入して読む。
- 理由: 外側subscriptが1D Viewを返す設計と軸順を、単一の非対称例で同時に示せる。

### 8. `RedBlackTreeDictionary.insert(key:value:)`

- 利用者の疑問: 既存keyを渡したときvalueが置換されるのか、戻り値の
  `memberAfterInsert`には新旧どちらが入るのか。
- 示すべき最小の振る舞い: 同じkeyを異なるvalueで2回insertし、2回目の`inserted == false`と、
  既存pairが保持されることを示した上で`updateValue(_:forKey:)`と役割を対比する。
- 理由: Swift標準Dictionaryの更新subscriptに慣れた利用者ほど、insert-onlyの契約を取り違えやすい。

### 9. `RedBlackTreeMultiSet.melding(_:)`／`RedBlackTreeMultiMap.melding(_:)`

- 利用者の疑問: `inserting(contentsOf:)`との違いと、重複要素・重複keyがどう保持されるか。
- 示すべき最小の振る舞い: 重複を含む二つのcollectionをmeldingし、全occurrenceが順序付きで残る結果を
  示す。同じ例の元値が変更されないことも確認する。
- 理由: `union`やDictionaryの`merge`を連想しやすい名前だが、multi collectionの重複保持を含む結果は
  具体例がないと予測しにくい。

### 10. `NextPermutationsSequence.makeIterator()`

- 利用者の疑問: 途中まで進めたiteratorをcopyした後、二つを独立して進められるか。
- 示すべき最小の振る舞い: 1回進めたiteratorをcopyし、双方の次値が同じで、その後も片方の進行が
  もう片方へ影響しないことを示す。
- 理由: iteratorの値semanticsは重要な公開契約だが、通常の`for`文スニペットでは観測できない。

## 圏外メモ

- 同じRange／View構文を持つRedBlackTreeの4 collectionは、利用目的が共通なので一候補へまとめた。
- `BareArray3D`／`4D`と`OptionalArray2D`／`3D`／`4D`は、軸順の例を追加する価値はあるが、TOP10では
  2D BareArrayと1D OptionalArrayの基本操作を優先した。
- `isTriviallyIdentical(to:)`にはすでに短いコード例があり、新規スニペット候補の優先度を下げた。
- deprecated API、AtCoder 2025互換mode、benchmark・debug用の公開memberは候補から除外した。

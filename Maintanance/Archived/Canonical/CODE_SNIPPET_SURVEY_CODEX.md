# コードスニペット候補アンケート — Codex回答

## 境界

共通の設問と対象範囲は`CODE_SNIPPET_SURVEY.md`を正本とする。回答確定までは
`CODE_SNIPPET_SURVEY_CLAUDE.md`を読まない。このfileだけをCodexの回答書き込み先とする。

## 回答状態

2026-10-10、Codex回答確定。Claude回答は未読。

## TOP10

### 1. `Collection.nextPermutations()`

- 利用者の疑問: 全順列を返すのか、現在の並び以後だけを返すのか。
- 最小の振る舞い: `[2, 1, 3]`から開始し、辞書順の後続4件だけを`map(Array.init)`で得る。
- 理由: `swift-algorithms`の`permutations()`と名前が近く、文章だけより出力列の対比が早い。

### 2. `OptionalArray1D.subscript(_:)`

- 利用者の疑問: 未設定、値の設定、上書き、`nil`による解除をどう書くか。
- 最小の振る舞い: 初期値`nil`、値代入、読み出し、`nil`代入後の再確認を一続きで示す。
- 理由: Optionalを返すだけの配列ではなく、slotの構築・破棄を兼ねるAPIであることが使用例で伝わる。

### 3. `OptionalArray2D.subscript(_:)`

- 利用者の疑問: 軸順と、`array[y][x] = value`による連鎖書き込みの形。
- 最小の振る舞い: 非対称shapeを作り、`array[1][2]`へ設定して同じ位置から読む。
- 理由: 返り値が非所有Viewであることと、外側subscriptへViewを代入するAPIではないことを一例で示せる。

### 4. `BareArray2D.init(repeating:width:height:)`

- 利用者の疑問: `width`と`height`の軸順、作成直後のアクセス方法。
- 最小の振る舞い: `width: 3, height: 2`で作り、`array[y][x]`の端を読み書きする。
- 理由: 多次元型の最初の入口であり、非対称shapeの例が軸の取り違えを防ぐ。

### 5. `BareArray.init(count:_:)`

- 利用者の疑問: closureが何回・どの順で呼ばれ、添字を受け取らないclosureで異なる値を作れるか。
- 最小の振る舞い: 外部counterを使って`[0, 1, 2]`を生成し、count 0では呼ばれないことも示す。
- 理由: `Array.init(unsafeUninitializedCapacity:)`等と違い、closureの戻り値を逐次格納する独自形だから。

### 6. `OptionalArray3D.removeAll()`

- 利用者の疑問: shapeやcapacityも消えるのか、同じ位置を再利用できるのか。
- 最小の振る舞い: 複数slotへ設定し、`removeAll()`後に`nil`を確認し、同じ添字へ再設定する。
- 理由: 「全削除」がstorage解放やshape変更を意味しないことは、前後のコードが最も明確に示す。

### 7. `BareArray4D.init(repeating:size0:size1:size2:size3:)`

- 利用者の疑問: `size0`〜`size3`と`array[w][z][y][x]`の対応。
- 最小の振る舞い: 全軸の長さが異なるshapeを作り、`array[w][z][y][x]`の端へ代入する。
- 理由: 数字名の次元は2D・3Dより軸を誤認しやすく、具体例の効果が大きい。

### 8. `OptionalArray4D.init(size0:size1:size2:size3:)`

- 利用者の疑問: 4Dの軸順と、全slotが未設定で始まること。
- 最小の振る舞い: 非対称shapeで初期`nil`を確認し、`array[w][z][y][x]`へ値を設定する。
- 理由: BareArray4Dと似たshape APIだが初期化済み要素を持たないため、別の例が必要。

### 9. `NextPermutationsSequence.makeIterator()`

- 利用者の疑問: iteratorをコピーした後、両方を独立して進められるか。
- 最小の振る舞い: 1回進めたiteratorをコピーし、双方の次値が同じになることを示す。
- 理由: 値semanticsは重要な公開契約だが、通常の`for`文例では観察できない。

### 10. `NextPermutationsSequence.Permutation.subscript(_:)`

- 利用者の疑問: source collectionのIndex型を引き継ぐのか、結果を後から安定して読めるか。
- 最小の振る舞い: 非0始まりのsourceから得た結果を保持し、`startIndex == 0`と要素アクセスを示す。
- 理由: 戻り値は`Array`ではなく独自RandomAccessCollectionであり、添字契約を例で補う価値がある。

## 圏外メモ

- `BareArray3D`／`OptionalArray3D`のinitializerとsubscriptは2D例から自然に一般化できるため、次元違いだけで重複させなかった。
- `Permutation`の`==`、`hash(into:)`、`description`は標準protocolの期待に沿い、専用スニペットの優先度は低い。
- View型のsubscriptは所有型の連鎖subscript例に現れるため、View単独の保持例は寿命誤用を誘発しやすく圏外とした。

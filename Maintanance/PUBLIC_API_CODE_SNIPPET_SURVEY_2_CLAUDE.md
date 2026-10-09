# リポジトリ公開APIコードスニペット候補アンケート第2弾 — Claude回答

共通設問は`PUBLIC_API_CODE_SNIPPET_SURVEY_2.md`を正本とする。このfileをClaudeの書き込み先とする。

## 回答状態

2026-10-10 Claude回答完了。`PUBLIC_API_CODE_SNIPPET_SURVEY_2_CODEX.md`は読んでいない。
対象は`AcCollections`が再exportする公開API（RedBlackTreeCollections、PermutationModule、
OptionalArrayModule、BareArrayModule）。互換mode、`Deprecated/`配下、公開終了予定のMemoize
（`RBT-005`）は外した。判断は公開宣言と現在のコメントドックによる。

## TOP10

### 1. `RedBlackTreeSet.subscript(bound:)`と`RedBlackTreeBoundExpression.lessThan(_:)`／`greaterThan(_:)`等

- 利用者の疑問: 「`x`未満の最大」「`x`より大きい最小」を1行で取るにはどう書くのか。無いときはどうなるのか。
- 示す最小の振る舞い: `[1, 3, 5]`で`set[.lessThan(3)] == 1`、`set[.greaterThan(5)] == nil`、
  `set[.lessThanOrEqual(3)] == 3`。
- 既存説明の不足: `lessThan`系4種のコメントは1行だけで、該当がないときの扱いが書かれていない。
  型コメントの例は`lowerBound`/`upperBound`/`find`しか扱っていない。競技プログラミングで最も多い
  近傍の問い合わせなので、見せる効果が一番大きい。

### 2. `RedBlackTreeSet`（型コメントの既存例）

- 利用者の疑問: 型コメントの例をそのまま写して動くのか。
- 示す最小の振る舞い: 現在の名前で書いた`set[.start.advanced(by: 1)]`と`set.erase(.lowerBound(4) ..< .end)`。
- 既存説明の不足: 既存例は`.start.advance(by: 1)`と`.endIndex`を使っているが、公開宣言にあるのは
  `advanced(by:limit:)`と`.end`である。2026-10-10、一時clientで既存例をコンパイルし、
  `.endIndex`は「has no member 'endIndex'」、`.advance(by:)`は診断生成失敗のエラーになることを確認した。
  現在の名前に直した例は通り、`Optional(3)`と`[1, 3]`を出力した。`RedBlackTreeMultiSet`と`RedBlackTreeMultiMap`の型コメント、
  `Documentation/Head/RedBlackTreeSet*.md`にも同じ記述がある。追加というより、既存のスニペットの差し替え候補。

### 3. `RedBlackTreeMultiSet.eraseUnique(_:)`と`eraseMulti(_:)`

- 利用者の疑問: C++の`ms.erase(ms.find(x))`（1個だけ消す）と`ms.erase(x)`（全部消す）はどちらに当たるのか。
- 示す最小の振る舞い: `[1, 1, 2]`に`eraseUnique(1)`で`[1, 2]`、`eraseMulti(1)`で`[2]`になり、
  返り値がそれぞれ`true`と`2`であること。
- 既存説明の不足: 説明自体は正しいが、C++から来た利用者が最もやらかす「全部消してしまう」誤用は、
  並べた例で一目で防げる。

### 4. `OptionalArray1D.subscript(position:) -> Element?`

- 利用者の疑問: メモ化再帰で「未計算」をどう判定し、どう書き込むのか。
- 示す最小の振る舞い: `if let v = memo[i] { return v }`、計算後に`memo[i] = r`。番兵値が要らないこと。
- 既存説明の不足: get/set/`nil`代入の意味論は正確だが、型の存在理由であるメモ化の定型が文章からは
  組み立てにくい（第1弾の1位と同じ判断）。

### 5. `RedBlackTreeBoundExpression.advanced(by:limit:)`、`before`、`after`

- 利用者の疑問: `lowerBound(x)`から2つ先を取るには。範囲外に出たらどうなるのか。`limit`は何か。
- 示す最小の振る舞い: `set[.lowerBound(3).advanced(by: 1)]`で次の要素、`set[.start.before]`の結果、
  `limit`を指定したときに止まる位置。
- 既存説明の不足: 「Fails if it goes past the start or past-the-end」とだけあり、failしたとき
  `nil`になるのか停止するのかが利用者には分からない。`limit`引数には説明がない。

### 6. `RedBlackTreeSet.subscript(bounds:)`／`erase(_ bounds:)`（`[l, r)`の個数と削除）

- 利用者の疑問: `l`以上`r`未満の要素数や、その範囲の一括削除をどう書くのか。
- 示す最小の振る舞い: `set[.lowerBound(l) ..< .lowerBound(r)].count`と`set.erase(.lowerBound(l) ..< .lowerBound(r))`。
- 既存説明の不足: 範囲の書き方は`BoundRangeExpression`のtypealiasのコメントにだけ例があり、
  利用者が引くsubscriptやeraseの側には例がない。個数がO(k)かどうかという性能上の疑問にも、
  例の脇で答えられる。

### 7. `Collection.nextPermutations()`

- 利用者の疑問: 全順列を列挙するにはどうするのか。重複要素はどうなるのか。
- 示す最小の振る舞い: 未sortでは後続しか出ないこと、`sorted()`してから呼ぶと全順列になること、
  `[1, 1, 2]`で重複する並びが出ないこと。
- 既存説明の不足: 箇条書きは正しいが、`sorted()`を先に呼ぶ定型が明示されていない（第1弾と同じ判断）。

### 8. `BareArray`（型、`~Copyable`の扱い）

- 利用者の疑問: `Array`と同じ感覚で、再帰関数から使ったり代入したりできるのか。
- 示す最小の振る舞い: ローカル関数からcaptureして読み書きする形、または`inout`で渡す形。
  `let b = a`がcopyではなくmoveになること。
- 既存説明の不足: 「要素を所有し」とだけあり、`~Copyable`による書き方の制約に触れていない。
  最初に詰まるのはコンパイルエラーの側で、例でしか救えない。OptionalArray系も同じ制約を持つので、
  代表として1件にまとめた。

### 9. `RedBlackTreeMultiMap.subscript(key:) -> Values`

- 利用者の疑問: 同じキーに紐づく値を全部取り出すには。そこから値を消すと本体はどうなるのか。
- 示す最小の振る舞い: `for v in map[k]`で挿入順に値を読み、view経由の削除で本体からも対応する組が消えること。
- 既存説明の不足: 「mutable view」「removing values through the view removes pairs」とあるが、
  viewという返り値の型は戻り値を見ただけでは使い方が想像しにくい。`Dictionary`の`subscript`と
  形が似ているぶん、`Value?`ではないことを例で示す価値がある。

### 10. `RedBlackTreeSet.index(inserting:)`と`erase(exactly:)`

- 利用者の疑問: 挿入時に得たindexを持っておき、後で安全に消せるのか。その間に他の要素を消していても大丈夫か。
- 示す最小の振る舞い: `let (_, i) = set.index(inserting: x)`、別要素の削除を挟んでから`set.erase(exactly: i)`、
  既に消えたindexなら`nil`が返ること。
- 既存説明の不足: 二つのAPIは`SeeAlso`でつながっているだけで、「保持したindexを後で消す」という
  使い道が示されていない。C++の`iterator`を保持する書き方に慣れた利用者向けの見せ場。

## 圏外のメモ

- `RedBlackTreeDictionary.subscript(_:default:)`: 標準`Dictionary`と同じ形なので推測が効く。
  読み取りでは挿入しないという差分だけなら、文章で足りる。
- `insert(_:hint:)`: 誤ったhintでも結果は変わらないと明記済みで、例による上積みは小さい。
- `RedBlackTreeSet.upperBound(_:)`のコメント例: `Set`なのに重複を含む`[1, 3, 5, 5, 7, 9]`を使っている。
  スニペット追加の候補ではないが、文書の手直し対象として気づいたので記録する。

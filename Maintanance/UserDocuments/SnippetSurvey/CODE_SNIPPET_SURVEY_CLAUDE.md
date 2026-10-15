# コードスニペット候補アンケート — Claude回答

## 境界

共通の設問と対象範囲は`CODE_SNIPPET_SURVEY.md`を正本とする。回答確定までは
`CODE_SNIPPET_SURVEY_CODEX.md`を読まない。このfileだけをClaudeの回答書き込み先とする。

## 回答状態

2026-10-10 Claude回答確定。`CODE_SNIPPET_SURVEY_CODEX.md`は読んでいない。
根拠はHEADの`BareArray.swift`、`OptinalArray.swift`、`Permutations.swift`の公開宣言とdocコメント。
スニペットは公開APIの利用者向けなので、利用者が目にする宣言とコメントだけで判断した。

## TOP10

### 1. `OptionalArray1D.subscript(position:) -> Element?`

- 利用者の疑問: 未設定のslotを読むと何が返るのか。`nil`を代入すると何が起きるのか。
- 示す最小の振る舞い: 作成直後の`a[0] == nil`、`a[0] = 5`の後は`5`、`a[0] = nil`で再び`nil`。
- 既存説明の不足: 三つの状態遷移は文章で正しく書かれているが、`Element?`を返すsubscriptの読み書きは
  3行の例のほうが速く伝わる。
- 2026-10-10訂正: 当初はメモ化再帰の定型（`if let`で返し、計算後に書き込む）を示すとしていた。
  ユーザー指摘により撤回する。その定型はマクロが展開するコードで、型のコメントで教える内容ではない。
  スニペットはAPI自身の振る舞いだけを示す。順位は据え置く。

### 2. `BareArray2D.subscript(position:)`（連鎖subscript `dp[y][x]`）

- 利用者の疑問: `dp[i][j] += 1`は書けるのか。どちらの添字が`width`なのか。
- 示す最小の振る舞い: `init(repeating: 0, width: W, height: H)`で作り、`dp[y][x]`で読み書きし、
  変更が配列本体へ反映されること。
- 既存説明の不足: 「setterは連鎖要素書き込みのwriteback専用」「別Viewの代入は契約違反」という説明が
  先に目に入り、普通の`dp[y][x] = v`が書けるのか逆に不安になる。初期化の引数順（width, height）と
  添字順（y, x）が逆なのも、文章より例のほうが一瞬で伝わる。

### 3. `BareArray`（型、`~Copyable`の扱い）

- 利用者の疑問: `Array`と同じ感覚で関数へ渡したり、変数へ代入したりできるのか。
- 示す最小の振る舞い: 再帰関数へ`inout`または`borrowing`で渡す形と、`let b = a`がcopyではなく
  moveになり`a`が使えなくなること。
- 既存説明の不足: 「要素を所有し」とだけあり、`~Copyable`による書き方の制約に触れていない。
  競技プログラミング利用者が最初に詰まるのはコンパイルエラーの側で、ここは例でしか救えない。

### 4. `Collection.nextPermutations()`

- 利用者の疑問: 全順列を列挙するにはどうするのか。重複要素があるとどうなるのか。
- 示す最小の振る舞い: 未sortの`[2, 1, 3]`は後続しか出ないこと、`sorted()`してから呼ぶと全順列になること、
  `[1, 1, 2]`では重複する並びが出ないこと。
- 既存説明の不足: 箇条書きで正しく説明されているが、`sorted()`を先に呼ぶ定型が明示されていない。
  C++の`next_permutation`経験者でも、最初の1件が現在順である点で取り違えやすい。

### 5. `OptionalArray2D.subscript(position:)`（`memo[y][x]`）

- 利用者の疑問: 2次元のメモで`memo[y][x] = nil`や`if let`が連鎖subscriptを通しても働くのか。
- 示す最小の振る舞い: `memo[y][x]`の`nil`判定と代入、および`memo[y][x] = nil`で未設定へ戻ること。
- 既存説明の不足: #2と同じ連鎖パターンだが、Optionalの書き戻しがView越しに働くかどうかは別の疑問で、
  BareArray2Dの例からは推測できない。次元違いの重複ではなく、意味論の違いとして別枠にした。

### 6. `OptionalArray1D.removeAll()`

- 利用者の疑問: 複数テストケースでメモを使い回せるのか。再確保が要るのか。
- 示す最小の振る舞い: `let memo = OptionalArray1D<Int>(capacity: n)`のまま、ケースごとに`removeAll()`して
  再利用でき、全slotが`nil`へ戻ること。
- 既存説明の不足: `mutating`でなく`let`のまま呼べる点が宣言を読まないと分からない。
  storageを保持するという性能上の利点も、例があると採用理由として伝わる。

### 7. `NextPermutationsSequence.Permutation`（zero-based index）

- 利用者の疑問: `ArraySlice`から作った順列でも、元の添字で読むのか。
- 示す最小の振る舞い: `a[2...].nextPermutations()`から得た`p`で`p[0]`が先頭要素になり、`p.startIndex == 0`
  であること。
- 既存説明の不足: 「source collectionの添字型・開始位置とは独立」と書いてあるが、slice由来の添字ずれは
  Swiftでよくある落とし穴なので、誤用防止としては例のほうが強い。

### 8. `BareArray.init(count:_:)`

- 利用者の疑問: クロージャで入力を読み込んで初期化できるのか。呼ばれる順番は保証されるのか。
- 示す最小の振る舞い: `BareArray(count: n) { Int(readLine()!)! }`が添字順に呼ばれ、`count == 0`では
  呼ばれないこと。
- 既存説明の不足: 呼出し順は書いてあるが、それが「標準入力の読み込みに使える」という利用法に結びついていない。
  採用判断の材料として効く。

### 9. `BareArray4D.init(repeating:size0:size1:size2:size3:)`

- 利用者の疑問: `size0`〜`size3`のどれが`a[w][z][y][x]`のどの添字なのか。
- 示す最小の振る舞い: `size0`が最内軸で最後の添字`x`、`size3`が最外軸で最初の添字`w`になること。
- 既存説明の不足: #2と同じ軸順の問題だが、4Dだけは引数名が`width`系でなく`size0`〜`size3`になり、
  対応を取り違えやすい。2D/3Dの例から類推できないので、次元違いの重複として残した。

### 10. `NextPermutationsSequence.Iterator.next()`

- 利用者の疑問: 条件を満たした時点で列挙を打ち切れるのか。取り出した順列を保存しておいて大丈夫か。
- 示す最小の振る舞い: `while let p = it.next()`で途中`break`し、保存済みの`p`が後続の`next()`で
  変わらないこと。
- 既存説明の不足: 値の安定性は型コメントに書かれているが、「保存してよい」という利用者の言葉に
  なっていない。`for`ではなく手動iteratorを使う場面の例がない。

## 圏外だが候補にした理由のメモ

- `BareArray2DView`等のsetter: 「別Viewの代入は契約違反」は誤用防止の例になりうる。ただし、普通の利用者は
  まず踏まないので#2の中で触れれば足りると判断した。
- `Permutation`の`==`/`hash(into:)`/`description`: 標準的な適合で、例による上積みは小さい。
- `indices`各種: 名前どおりで、疑問が生じにくい。

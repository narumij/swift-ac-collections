# Array系object名 Claude独立候補（ARRAY-003）

2026-10-12 Claude（Opus 5.5）提出。`ARRAY_NAMING_CANDIDATES_CODEX.md`、`ARRAY_NAMING_CANDIDATES_USER.md`、
会話上のユーザー候補、過去の命名レビュー文書は読んでいない。入力は`ArrayObjectAndAPINamingDraft.md`と
現行の`Sources/BareArrayModule/BareArray.swift`、`Sources/OptionalArrayModule/OptinalArray.swift`だけ。
候補は順位付けしない（並び順に意味はない）。

## 前提として読み取った役割

- 両familyとも、要素数（shape）が作成時に決まり以後変わらない、heap上の連続storageを**所有**する型。
  `~Copyable`で、代入はcopyではなくmove。`Collection`には適合しない。
- BareArray: 各位置が常に初期化済みの要素を持つ。
- OptionalArray: 各位置（slot）が「未設定」か「要素を1つ所有」のどちらか。`nil`代入で未設定へ戻る。
- View: 所有配列の連続領域を指す非所有の参照。寿命を延ばさない。`array[y][x]`の連鎖書き込みに使う。
- 現行名の非対称: 1D所有型だけ`BareArray`（suffixなし）と`OptionalArray1D`（suffixあり）で揃っていない。

## 候補

### C-1 現行名を維持: `BareArray` / `OptionalArray`

- 意味: 「飾りのない（Collection適合などを持たない）配列」と「slotが空でありうる配列」。
- 1D〜4D: 現行のまま（`BareArray`, `BareArray2D`〜`4D` / `OptionalArray1D`〜`4D`）。
  ただし1Dのsuffixは次のどちらかに揃える案を併記する。
  - C-1a: 両方suffixなし（`BareArray` / `OptionalArray`、2D以降に`2D`〜`4D`）。
  - C-1b: 両方suffixあり（`BareArray1D` / `OptionalArray1D`）。
- View: `BareArray1DView`〜`3DView` / `OptionalArray1DView`〜`3DView`（現行どおり）。
- 懸念: 「Bare」が何を省いたのか（Collection適合、bounds以外の機能、copy可能性）は名前から読めない。
  `OptionalArray`は`[Element?]`（`Array<Optional<Element>>`）と読まれ、所有・固定長・`~Copyable`が伝わらない。
  移行費用はゼロ（C-1a／C-1bでは片方の1D名だけ変更）。

### C-2 固定長を前面に: `FixedArray` / `FixedOptionalArray`

- 意味: 作成時に要素数が決まり、伸縮しない所有配列。
- 1D〜4D: `FixedArray` / `FixedArray2D`〜`4D`、`FixedOptionalArray` / `FixedOptionalArray2D`〜`4D`
  （1Dはsuffixなしで揃える）。
- View: `FixedArray1DView`〜`3DView` / `FixedOptionalArray1DView`〜`3DView`。
- 懸念: 標準ライブラリの`InlineArray`（要素数が型に入るinline storage）や「fixed-size array」の議論と
  混同されうる。こちらは要素数が実行時に決まりheapに置く。`FixedOptionalArray`は長い。

### C-3 storage位置を前面に: `HeapArray` / `HeapOptionalArray`

- 意味: heap上の連続storageを所有する配列。`InlineArray`との対比が名前で付く。
- 1D〜4D: `HeapArray` / `HeapArray2D`〜`4D`、`HeapOptionalArray` / `HeapOptionalArray2D`〜`4D`。
- View: `HeapArray1DView`〜`3DView` / `HeapOptionalArray1DView`〜`3DView`。
- 懸念: 実装（置き場所）を名前にしており、ranking基準1（役割を表す）に弱い。`Array`自身もheapに置くので、
  差が「heapであること」ではない点が伝わりにくい。

### C-4 OptionalArrayを「slot」として別名にする: `BareArray` / `SlotArray`

- 意味: OptionalArray側の本質は「各位置が空か1要素を持つslot」であることだと読む。
  `Optional`という型名を借りず、空slotを持つ固定長配列であることを名前にする。
- 1D〜4D: `BareArray` / `BareArray2D`〜`4D`、`SlotArray` / `SlotArray2D`〜`4D`。
- View: `BareArray1DView`〜`3DView` / `SlotArray1DView`〜`3DView`。
- 両familyでbase名をあえて揃えない理由: 「常に初期化済み」と「空でありうる」は役割が違い、
  ranking基準4（役割が違うところは区別する）に沿う。
- 懸念: 「slot」はhash tableやobject poolの語としても使われ、疎（sparse）な構造を連想させうる
  （基準6）。実際は密なstorageで、全slot分を確保する。

### C-5 用途（表）を前面に: `BareArray` / `MemoTable`

- 意味: OptionalArrayの主用途が配列ベースのメモ化であることを名前にする（型コメントも「メモ化用配列」）。
- 1D〜4D: `MemoTable` / `MemoTable2D`〜`4D`。
- View: `MemoTable1DView`〜`3DView`（またはrowを表す`MemoTableRow`等。View名の再設計になるので参考扱い）。
- 懸念: 「memo」はcaching policy（自動の計算・追い出し）を約束するように読まれうる（基準6）。
  実際は値を置くだけで、計算もevictionもしない。メモ化以外の用途（未訪問判定など）では名前が合わない。

## family横断の論点（候補に付随する観察）

- **1Dのsuffix:** 現行の非対称は、どの候補を選んでも揃える方向で決める必要がある。
  1Dをsuffixなしにすると`Array`と同じ読み味になり、suffixありにすると2D〜4Dとの規則性が上がる。
- **View名:** `View`は非所有であることを示すが、寿命を延ばさないこと（ownerより先に使い終える必要）は
  伝わらない。Swiftの`Span`系の名前は、compilerが寿命を検査する型を連想させるので、
  寿命検査のない現行Viewに付けるのは避けたほうがよいと考える（候補には入れていない）。
- **swift-collectionsとの関係（記憶ベース、未確認）:** swift-collectionsには`~Copyable`要素向けの
  `RigidArray`（容量固定）や`UniqueArray`があったはずで、同時importや検索で混同されうる。
  `Rigid`／`Unique`を含む名前は候補から外した。事実確認が要る。
- **座標ラベル:** `element(at: x, y)`は最内軸から、連鎖subscriptは`[y][x]`と最外軸から並ぶ。
  object名の決定とは独立だが、どの名前でも利用者の誤読点として残る。

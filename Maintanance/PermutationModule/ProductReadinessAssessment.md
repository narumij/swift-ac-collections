# PermutationModule 製品化判断のための所見(改訂版)

この文書は、`PermutationModule`を実験的ユーティリティから製品相当の公開APIへ引き上げられるかを
判断するための調査結果をまとめたもの。コード・テストへの変更はこの時点では行っていない。
意思決定はユーザーが行い、この文書はそのための材料に留める。

**改訂の経緯**: 前回のドラフトは「`All`系に対応する安全な便利メソッドが欠けている」ことを
非対称・不備として扱い、追加で埋める方向の検討項目としていた。しかしユーザーの意図は
逆で、`All`系自体を実装・APIバリアントとして削減することにある。本書はこの前提で
所見を書き直す。

## 存在理由(`release/AtCoder/2025`ブランチのREADME.mdより)

現在作業中のブランチの`README.md`/`README.ja.md`には`PermutationModule`の記載が無いが、
`remotes/origin/release/AtCoder/2025`の`README.md`には由来が明記されている。

- ABC328Eという問題(制約`N <= 8`, `M <= 28`)で、C++の解説コードが全探索的に見えたため
  「組み合わせを力尽くで計算できる」と誤解していた期間があった。実際は辞書順の変化だけを
  行う`next_permutation`の挙動により組み合わせ数が減っていたために計算可能だった、
  という誤解だった。
- この誤解を追いかける過程で「オーバーヘッドが少ない実装」を追求し、結果として軽量な実装が
  生まれた。
- `unsafePermutations`/`unsafeNextPermutations`は「おまけ」として位置付けられ、
  「コピーオンライトをキャンセルして行わない動作」であることが明記されている
  (CoWを省く設計は不備ではなく、AtCoder提出コードのような使い捨てコンテキストでの
  オーバーヘッド最小化という明確な狙いに基づく)。

つまりこのモジュールは「漫然とした実験」ではなく、特定の問題(ABC328E)から生まれた
具体的な存在理由を持つ。**この存在理由の中心は「辞書順で次を1つ求める」操作
(`next_permutation`相当)であり、「全順列を列挙する」操作(`All`)は、その過程で
派生的に実装されたものであって、モジュールの中心的な価値ではない。** 下記の
「散らかっている」状態は、目的の不明確さではなく実装・整理の債務として見るのが妥当に見える。

## 現在の公開API

主な入口は`Collection where Index == Int`への3つの拡張メソッド。ただし、これらに加えて
`Permutations`のネスト型(`All`/`Nexts`とその`init(safe:)`/`init(unsafe:)`、
`IteratorA`/`IteratorN`、`SubSequenceA`/`SubSequenceN`)もすべてpublicであり、利用者が
直接初期化・参照できる(完全な一覧は`Maintanance/PermutationModule/ImplementationPlan.md`
を参照)。

| API | 返す型 | CoW | 用途 | 製品化方針上の位置付け |
| --- | --- | --- | --- | --- |
| `nextPermutations()` | `Permutations<Self>.Nexts`(`_unsafe = false`) | あり | C++の`next_permutation`相当を辞書順で1つずつ | モジュールの中心的価値。維持 |
| `unsafeNextPermutations()` | `Permutations<Self>.Nexts`(`_unsafe = true`) | なし | 同上、高速だが結果を即座に消費する前提 | 公開を続けるか内部化するかは論点 |
| `unsafePermutations()` | `Permutations<Self>.All`(`_unsafe = true`) | なし | 全順列を辞書順で列挙 | `swift-algorithms`の`permutations()`と重複。削除候補 |

## 発見した非対称・未結線(削減方針での再評価)

- `Permutations.All`にはpublicな`init(safe:)`と、それに対応する`IteratorA.ensureUnique()`が
  実装されているため直接利用できるが、これを呼び出すCollection拡張
  (`permutations()`のような「安全な全列挙」の便利メソッド)が存在しない。
  **前回の所見はこれを「便利メソッドを追加して埋めるべき非対称」として扱ったが、
  ユーザーの意図を踏まえると逆の結論になる**: `All`系統自体が`swift-algorithms`の
  `permutations()`と機能的に重複しており、むしろ`init(safe:)`を含む`All`系全体を
  削除候補として扱うべきである。
  `swift test --enable-code-coverage --filter PermutationTests`で確認したところ、
  `Permutations.All.init(safe:)`・`IteratorA.ensureUnique()`は実行回数0(カバレッジ上も
  未到達)であり、現状これらを使う既存の利用コードが本リポジトリ内に無いことも
  削除の障害が少ないことを示している。
- `Tests/PermutationTests/NextPermutation.swift`に、Sources側の`NextPermutationProtocol`と
  ほぼ同一のアルゴリズム(`nextPermutation`/`reverse(subrange:)`、コメントの参照元URLも同じ)が、
  `ManagedBuffer`ではなく`UnsafeMutableBufferPointer`を直接使う別実装として残っている。
  `Array: NextPermutation`という独自protocol適合経由で`array.nextPermutation()`という
  直接APIを提供する、Sources側とは別世代の設計の名残と見られる。現在はテストターゲット内に
  閉じていて、本体の`PermutationModule`からは参照されていない(重複・死んでいる実装)。
  この実装は`Nexts`系(辞書順の次を1つ求める)アルゴリズムの参考実装であり、`All`系の
  削減計画とは独立した判断事項として扱う。
- ファイル先頭(`Permutations.swift:1`)に「模索の痕跡がのこっていて散らかっているので、
  要点に沿って整理しなおすか、廃止するか、いずれかを次回ジャッジ更新までに行うこと」という
  TODOが既に存在し、上記の状態を作者自身も把握している。**この記述は「整理」と「廃止」を
  並列の選択肢として挙げており、バリアント削減(廃止を含む整理)という今回の方向性と
  矛盾しない。**

## カバレッジ

`Sources/PermutationModule/`全体で、行94.30%・リージョン89.09%・関数96.83%
(`swift test --enable-code-coverage --filter PermutationTests` + `llvm-cov report`)。
未到達は上記の`All.init(safe:)`経路が主要因であり、これは「テストが足りない」というより
「削除候補の経路が元々呼ばれていない」ことの傍証として読む方が、今回の方針とは整合する。

## 安全性・使い勝手の注意点

- `unsafePermutations()`/`unsafeNextPermutations()`がCoWを行わないのは、上記のとおり
  オーバーヘッド最小化という明確な意図に基づく設計であり、不備ではない。ただし
  `PermutationTests.testUnsafeNextPermutations`のコメントが示すとおり、
  「単にmapしただけではコピーが行われず、原本への参照だけが返る」という直感に反する挙動があり
  (同一バッファを指す結果を複数回評価すると全て最終状態になる)、この設計意図と挙動の対応は
  現在テストのコメントにしか書かれていない。**この非直感的な挙動を安全版/無CoW版という
  2つの公開APIの差として利用者に説明し続けるのではなく、低オーバーヘッド経路を内部実装に
  留めてこの挙動自体を公開契約として露出させない、という方向で解消できないかを
  `ImplementationPlan.md`段階3で検討する。**
- `BareArray`/`OptionalArray`と異なり、`Permutations`関連の型に`Sendable`適合の宣言が無い。
- 公開メソッド3つに対して、計算量・CoW契約・事前条件(空コレクション等)を説明する
  コメントドック(`///`)が無い(`Collection`拡張部分に実装コメントのみ)。

## 既存テストで押さえられている点

- 比較上同値の2要素(`[0,0]`)と辞書順最後(`[4,3,2,1]`)が1回で終了することは
  `testNextPermutations`/`testUnsafeNextPermutations`で確認済み。空と単一要素は未確認。
- 3つの便利APIはそれぞれリテラルの期待値で確認されている。`#if USING_ALGORITHMS`の
  `testExample0`は`swift-algorithms`自身の出力をリテラルと比較しており、本モジュールとの
  直接差分比較ではない。また`USING_ALGORITHMS`は現在のPackage.swiftで有効化されていない。
  `All`系を削除候補として扱う以上、この直接比較テストを恒常化すること自体が削除判断の
  裏付けとして重要になる(`ImplementationPlan.md`段階0参照)。

## 製品化にあたって要ると思われる検討項目(所見・未着手)

1. `release/AtCoder/2025`のREADME.mdにある由来・説明を、現行ブランチの利用者向け文書へ
   どう反映するか(そのまま移植するか、現行APIに合わせて書き直すか)。
2. `Permutations.All`系(`unsafePermutations()`・`init(safe:)`/`init(unsafe:)`・
   `IteratorA`・`SubSequenceA`)を削除するか、deprecation期間を設けるか、その猶予期間
   (前回の所見にあった「便利メソッドを追加するか」という論点は、バリアント削減の方針に
   伴い取り下げる)。
3. `unsafeNextPermutations()`系を公開APIとして残すか、内部実装専用にするか。
4. `Tests/PermutationTests/NextPermutation.swift`の旧実装をどう扱うか(削除／参考実装として残す)。
5. `Sendable`適合の要否。
6. 公開APIへのコメントドック(計算量・CoW契約・事前条件)の整備。

この文書はコード変更を含まない調査結果のみ。対応方針はユーザーの判断を待つ。

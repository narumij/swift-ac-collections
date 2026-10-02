# PermutationModule 段階的削減計画(フェーズ1・改訂版)

本書は `Maintanance/PermutationModule/ProductReadinessAssessment.md`(調査所見)と
`Sources/PermutationModule/Documentation/Specification.md`(仕様ドラフト)を前提に、
公開APIとその実装バリアントを**削減する**方向で今後の作業を計画する。この時点で
コード・テストへの変更は行っていない。着手順・要否の最終判断はユーザーが行う。

**改訂の経緯**: 前回のドラフトは「`Permutations.All.init(safe:)`に対応する便利メソッドを
追加するか」という、バリアントを増やす方向の論点を中心に据えていたが、これはユーザーの
意図(バリアント削減)と逆だった。本書は`All`系を削除候補として扱う計画に全面的に
書き直す。

## 削減後に目指す最終形(論点であり、まだ決定事項ではない)

- 公開APIは `nextPermutations()` 一本(または、低オーバーヘッド経路を維持する必要が
  あるならその内部実装)に収束させる。
- `Permutations.All` / `IteratorA` / `SubSequenceA` / `unsafePermutations()` は削除する。
  全順列が必要な利用者には `swift-algorithms` の `permutations()` を案内する。
- `unsafeNextPermutations()` および `Permutations.Nexts.init(safe:)` /
  `init(unsafe:)` を公開APIとして残すかどうかは未決定。残す場合も、CoWの有無を
  「2つの正当な戦略」として利用者に選ばせる現状の説明ではなく、低オーバーヘッド経路は
  内部実装の最適化として扱い、公開契約としてのエイリアシング挙動は表に出さない方向を
  検討する。

## 現在のpublicな型・初期化子の完全な一覧(ソース互換性の検討対象)

削減を計画する前提として、現在publicな全ての型・初期化子を漏れなく列挙する
(`Specification.md`の「公開APIの現状」節と対応)。

| 分類 | 対象 | `All`系か`Nexts`系か |
| --- | --- | --- |
| Collection拡張メソッド | `nextPermutations()` | Nexts |
| Collection拡張メソッド | `unsafeNextPermutations()` | Nexts |
| Collection拡張メソッド | `unsafePermutations()` | All |
| 列挙体 | `Permutations<C>` | 共通の名前空間 |
| 構造体+2つのinit | `Permutations.All`, `.init(safe:)`, `.init(unsafe:)` | All |
| 構造体+2つのinit | `Permutations.Nexts`, `.init(safe:)`, `.init(unsafe:)` | Nexts |
| イテレータ型 | `Permutations.IteratorA` | All |
| イテレータ型 | `Permutations.IteratorN` | Nexts |
| 要素型 | `Permutations.SubSequenceA` | All |
| 要素型 | `Permutations.SubSequenceN` | Nexts |

`All`系を削除すると、上表の6項目(`unsafePermutations()`、`Permutations.All`とその2つの
init、`IteratorA`、`SubSequenceA`)が公開APIから失われる。この削除は**ソース破壊的変更**
であり、これらの型・initを直接名指しして使っている既存コード(本リポジトリ内では
`Tests/PermutationTests/PermutationTests.swift`の`testUnsafePermutations`が該当)を
修正する必要がある。影響範囲が本リポジトリ内に閉じているか、外部利用者を想定するかは
ユーザーに確認が必要な点として残す。

## 既存テストの扱い

| ファイル | 扱い | 理由 |
| --- | --- | --- |
| `Tests/PermutationTests/PermutationTests.swift` | 維持、ただし`All`削除時に`testUnsafePermutations`の扱いを決める必要あり | `testUnsafePermutations`は`unsafePermutations()`専用のテストであり、`All`削除と同時に削除するか、`swift-algorithms`の`permutations()`と本モジュールの出力を比較する退行検出用テストへ置き換えるかが論点。後者であれば`#if USING_ALGORITHMS`を外した恒常的な比較テストとして残せる |
| `Tests/PermutationTests/NextPermutation.swift` | 削除せず現状保持、扱いはユーザー判断待ち | `Array: NextPermutation` という独自protocol経由の別世代実装。本体からは未参照(`ProductReadinessAssessment.md` 既出)。`Nexts`系アルゴリズムの比較対象として参考実装の価値があるため、`All`系の削除計画とは独立した判断事項として残す |

`Tests/CLAUDE.md` の番号付けルール(`_98_` 実装・coverage、`_97_` 未分類、
`_99_DeathTests` 事前条件)は、RedBlackTree側の慣例であり、PermutationModuleには
まだ適用されていない。再設計時にPermutationTests側へ同様のファイル分割を導入するか
どうかは、本フェーズの範囲外の実装判断としてここに記録するに留める。

## 段階的削減計画(ユーザー承認待ち、未実施)

削除は不可逆な公開API変更を含むため、各段階の終わりでユーザーに実施の可否を確認する。

### 段階0: 退行検出の土台(削除に先立つテスト追加)

実装の削除を始める前に、現状の挙動を固定するテストを追加する。

1. `nextPermutations()` / `unsafeNextPermutations()` の空コレクション・単一要素での
   境界挙動(1回で終了するか、クラッシュしないか)を固定する。
2. `unsafePermutations()` の出力が `swift-algorithms` の `permutations()` の出力と
   (順序はともかく集合として)一致することを固定する。これは「削除しても
   `swift-algorithms`で代替可能」という削除根拠そのものを検証するテストであり、
   削除判断の前提条件として扱う。
3. `nextPermutations()`(CoWあり)が、保持した結果を書き換えないことを直接固定する
   (現状`unsafeNextPermutations()`側の「収束する」非直感的挙動はテスト済みだが、
   CoWあり版が「収束しない」ことの direct な確認は無い)。

### 段階1: `All`系の非推奨化

1. `unsafePermutations()`、`Permutations.All`、`Permutations.All.init(safe:)` /
   `init(unsafe:)`、`IteratorA`、`SubSequenceA` に `@available(*, deprecated, message:
   "swift-algorithms の permutations() を使用してください")` を付与する(具体的な
   deprecation メッセージ文言はユーザー確認の上で確定する)。
2. `testUnsafePermutations` を、段階0で追加した`swift-algorithms`比較テストへ段階的に
   置き換える。
3. このフェーズでは削除は行わず、警告のみとする。

### 段階2: `All`系の削除

1. 段階1のdeprecation期間(期間の長さ・リリース区切りの考え方はユーザー判断待ち)を
   経て、`unsafePermutations()`・`Permutations.All`・関連init・`IteratorA`・
   `SubSequenceA`を削除する。
2. `Permutations.Buffer`の`prepare(count:)`(`Int`要素用、`All`の位置インデックス列の
   初期化専用)が`All`削除後に未参照となるかを確認し、未参照であれば併せて削除する。
   `Buffer`クラス自体は`Nexts`系(`Buffer<Element>`)が使い続けるため存続する。

### 段階3: `Nexts`系・`unsafe`系の最終整理(論点、方針未決定)

1. `unsafeNextPermutations()` と `Permutations.Nexts.init(unsafe:)` を公開APIとして
   残すか、内部実装専用(`internal`化、または`nextPermutations()`内部が暗黙に高速経路を
   選ぶ設計)にするかを決定する。後者を選ぶ場合、利用者からは常に`nextPermutations()`
   のみが見え、CoWの有無という実装選択が公開契約として露出しなくなる。
2. 1の決定に応じて、`IteratorN`・`SubSequenceN`・`Nexts.init(safe:)`/`init(unsafe:)`の
   公開範囲を見直す。
3. いずれの場合も、ABC328Eのような使い捨てコンテキストでの低オーバーヘッド性能は
   維持する前提とする(`ProductReadinessAssessment.md`の存在理由を参照)。

## パフォーマンス検証の計画

既存の `#if ENABLE_PERFORMANCE_TESTING` ブロック(`testPerformance00`/`testPerformance1`、
および `USING_ALGORITHMS` 時の `testPerformance0`)は、段階1・2で`unsafePermutations()`を
扱う`testPerformance1`の扱いを合わせて見直す必要がある(削除対象のAPIを測り続けるのは
整合しないため、削除確定後は性能比較の主眼を`nextPermutations()`系に移す)。

- `nextPermutations()`(CoWあり版)のオーバーヘッドを、現行の `unsafeNextPermutations()`
  と同条件で比較するベンチマークが無い。段階3の決定内容にかかわらず、この比較は
  退行防止のために追加する価値がある。
- 現行ベンチマークは `0..<9`(DEBUG)/`0..<10`(RELEASE)の範囲固定。ABC328Eは
  `N <= 8`, `M <= 28`で、問題では最大 `28 choose 7` の辺選択を扱うため、単純な
  `n!` ベンチマークとは別に実問題コードで確認する。

## ABC328E 実提出による性能検証の実務計画

`ProductReadinessAssessment.md` に記録の通り、本モジュールの存在理由はABC328Eでの
実行時間問題である。制約は `N <= 8`, `M <= 28`。削減計画全体(段階0〜3)の退行防止には、
ベンチマーク数値だけでなく**実際のAtCoder提出**で確認することが望ましい。

1. 現行の `COMPATIBLE_ATCODER_2025` 実装とABC328Eの解法を、外部packageの
   `import AcCollections`に依存しないAtCoder提出用の単一Swiftファイルへまとめる。
   AtCoderの判定環境は本パッケージを参照できないため、package内で再公開されることの
   テストと、AtCoderへコピー&ペーストできる自己完結ファイルであることは、別の検証
   として扱う。
2. 削減作業前(現行コード)での提出結果(AC/TLE、実行時間)を記録し、ベースラインとする。
3. 各段階(特に段階2の`All`削除、段階3の`unsafe`系整理)の後、同一の提出コードで
   再提出し、実行時間が悪化していないことを確認する。公開API名や戻り値の型を
   変更する場合は、提出コード側の書き換えが必要になる点を先に明記し、どこまでの
   API変更なら許容するかをユーザーに確認する。
4. 提出は外部サービス(AtCoder)への投稿を伴うため、実行はユーザー自身が行う前提とし、
   Claude/Codexはコード準備とベースライン記録までを担当する。

## 着手順序の提案(ユーザー確認待ち)

1. `Specification.md`・本書の削減方針(`All`系削除、`unsafe`系の内部化方針)について
   ユーザー決定を得る。
2. 決定に基づき、段階0の退行検出テストを先に追加し、現行実装に対してすべてパスする
   ことを確認する。
3. 段階1(deprecation)→段階2(削除)→段階3(`unsafe`系整理)の順に、各段階の終わりに
   ユーザーへ実施可否を確認しながら進める。
4. 各段階でABC328Eベースラインとの比較を行う。

## 保留中の判断(ユーザー確認が必要)

- `All`系(`unsafePermutations()`・`Permutations.All`・関連init・`IteratorA`・
  `SubSequenceA`)を削除するか、deprecationに留めるか、また削除する場合の猶予期間。
- `unsafeNextPermutations()` / `Permutations.Nexts.init(safe:)` / `init(unsafe:)` を
  公開APIとして残すか、内部実装専用にするか。
- `Tests/PermutationTests/NextPermutation.swift` を削除/参考実装として残すかの決定。
- PermutationTestsへ `_98_`/`_97_`/`_99_` 相当のファイル分割を導入するか否か。

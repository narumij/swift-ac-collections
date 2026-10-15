# テスト再建の記録 — 事実と証拠

2026-10-16 / Claude（姫、Opus 5.5）。説明の正本は[本紙](README.md)。本書は、本紙の説明が依拠する事実・件数・commitの正本とする。

ラベルの意味は[AtCoder 2025からのリファクタリング記録の別紙](../RefactoringFromAtCoder2025/EVIDENCE.md)に合わせる。

- **[事実]** git履歴・保存されたファイル・実行結果から再確認できること。
- **[記録]** 当時の作業文書に書かれていること。書かれた内容が正しかったかまでは再検証していない。
- **[解釈]** 事実と記録から導いた読み方。

## 1. 件数の系列

### 1.1 番号付き仕様テストの宣言数

データは[`numbered-spec-declarations.csv`](Data/numbered-spec-declarations.csv)、図は[SVG](Images/numbered-spec-declarations.svg)・[PNG](Images/numbered-spec-declarations.png)。

数え方：

| 項目 | 定義 |
| --- | --- |
| 対象ファイル | `Tests/RedBlackTreeTests/RedBlackTree{Set,MultiSet,Dictionary,MultiMap,View}/`の`RedBlackTree<型>_<番号>_*.swift`。`_97`〜`_99`（一時・内部・Death Test）は除く |
| 宣言 | 行頭の`func test…`とSwift Testingの`@Test`を各1件 |
| 観測点 | 指定日の23:59:59 JSTまでの最後のcommit（`git rev-list -1 --before`） |
| 含まないもの | `#if`による構成差、parameterized testの展開、実行の成否 |

**[事実]** 主な値：

| 地点 | Set | MultiSet | Dictionary | MultiMap | 共通View |
| --- | ---: | ---: | ---: | ---: | ---: |
| `b2580703`（2025-09-03、AtCoder 2025基点） | 119（11 files） | 21（2） | 13（2） | 11（2） | 0 |
| `7341cadc`（2026-09-25） | 124（12） | 33（3） | 25（3） | 22（3） | 0 |
| `41b3953d`（2026-09-29） | 212（18） | 115（16） | 101（15） | 109（16） | 0 |
| `c08af11f`（2026-10-01） | 213 | 119 | 108 | 115 | 28（3） |
| `ee258340`（2026-10-07） | 240 | 150（17） | 140 | 136 | 38 |
| `6be79ddb`（2026-10-16） | 248 | 160 | 154 | 147 | 41 |

**[事実]** 2026-10-07から10-13までの5地点は、5系列とも同じ値だった。

### 1.2 repository全体の宣言数と実行数

**[事実]** 同じ宣言の数え方（`Tests/**/*.swift`の`func test…`と`@Test`）で、`165c81aa`は1739件になった。既存の[`repository-test-counts.csv`](../RefactoringFromAtCoder2025/Data/repository-test-counts.csv)の`165c81aa`の総宣言数1739と一致する。同じ方法で数えた`6be79ddb`は1893件だった。

**[事実]** 2026-10-16 04:15 JST、macOS・Apple Swift 6.4（swiftlang-6.4.0.34.1）で`swift test`（Debug）を実行した。失敗0件で、8 XCTest targetのXCTest 1329件とSwift Testing 223件が実行された。

| target | XCTest |
| --- | ---: |
| RedBlackTreeTests | 986 |
| RedBlackTreeTreeTests | 121 |
| PermutationTests | 63 |
| OptionalElementBufferModuleTests | 49 |
| ElementBufferModuleTests | 43 |
| CppBehaviorReferenceTests | 35 |
| RedBlackTreeLegacyTests | 27 |
| AcCollectionsTests | 5 |

**[事実]** 同日、RedBlackTreeTestsはReleaseでXCTest 834件・Swift Testing 120件が成功した。互換mode（`COMPATIBLE_ATCODER_2025`）ではtest buildだけを確認した。Linuxはこの記録では未確認。

## 2. 3型への横展開（2026-09-27〜29）

**[事実]** MultiSet・Dictionary・MultiMapの番号付き仕様ファイルは、`28fd8eee`（09-27 16:53）から`663b3a14`（09-29 22:56）までの一連のcommitで追加された。commit messageの多くは「refactoring tests?」で、作者はいずれもnarumijである。

**[事実]** 4型の共通XCTest基底`RedBlackTreeTestCase`（`Tests/RedBlackTreeTests/RedBlackTreeTestSupport/RedBlackTreeTestCase.swift`）は`b52872b1`（09-29）で追加された。

**[記録]** [`TESTING_REFERENCE.md`](../Archived/TestDashboard/TESTING_REFERENCE.md)には、次の記述がある。

- 横展開はAPI Matrixと照らし合わせて過不足を見ること（同書65行付近）。
- 4型の横展開（ValueSemantics、LazySequence、IntegerElement・Key、`_99_DeathTests`の境界trap）を完了したこと（同書408行付近）。
- 最後に作業したモデルがClaude（Sonnet 5）だったこと（同書420行付近）。
- 2026-10-01 07:07 JSTに、CodexがTest as Specificationの横展開をレビューし、Index世代検証とRange ViewのCoW後のIndex寿命について横展開の漏れを指摘したこと（同書421〜423行付近）。

**[解釈]** 横展開の実作業はClaude、点検はCodex、commitはユーザーという分担だったと読める。ただし、各commitの作業者を個別には確認していない。

## 3. 検証の基盤

| 日付 | commit | 事実 |
| --- | --- | --- |
| 2026-10-01 | — | **[記録]** Xcode MCPの`RunAllTests`が、数百件を実行しないまま「0 failed」を返す挙動をClaudeが確認した。全体の合否は`swift test`を正とする運用になった（`TESTING_REFERENCE.md`57・428行付近） |
| 2026-10-02 | `29f43bb3` | **[事実]** 共有fixtureの独立target`Tests/RedBlackTreeFixture/`を追加 |
| 2026-10-02 | `60604ff6` | **[事実]** 原木層専用の`Tests/RedBlackTreeTreeTests/`を追加 |
| 2026-10-04 | `c93a5942` | **[事実]** C++の挙動と比較する`Tests/CppBehaviorReferenceTests/`を追加。2026-10-16時点で35件 |
| 2026-10-04 | `6224c878` | **[事実]** Death Testの停止signalを`expectedSwiftTrapSignal`（DarwinはSIGTRAP、LinuxはSIGILL）へ完全一致させる仕組みを追加 |
| 2026-10-04 | `41bac022` | **[事実]** 寿命カウンタの一致検査だけを外す診断用trait`SKIP_DEBUG_LIFETIME_BALANCE_CHECKS`を`Package.swift`へ追加 |
| 2026-10-13 | `9ff39f85` / `4ac88c8c` | **[事実]** compiler fixture `BareArrayMutableRefLifetime`と`PermutationPublicSurface`を追加 |
| 2026-10-15 | `427b155a` | **[事実]** compiler fixture `OptionalElementBufferPublicSurface`を追加。期待する診断の件数と全error件数の一致まで照合する |

## 4. テストと同じcommitで直った製品の不具合

**[事実]** 下の8件は、いずれも製品sourceの修正と、そのcommitで追加・変更したtestを含む。
「テストが先に失敗した」ことまでcommit単位で確かめたのは、本文や記録に書かれている行だけである。

| 日付 | commit | 対象 | 内容 | 根拠 |
| --- | --- | --- | --- | --- |
| 2026-09-30 | `e5785ea8` | MultiMap | `index(inserting:)`が`__insert_unique`を呼び、重複keyを挿入しなかった。`__insert_multi`へ修正 | **[事実]** diff。**[記録]** `TESTING_REFERENCE.md`398行付近 |
| 2026-10-01 | `9f1bfa90` | Dictionary ほか | 空のときに`removeAll(keepingCapacity:)`などが無駄なCoWを起こす | **[事実]** diff（`keepCapacity && __tree_.count > 0`）。**[記録]** 同書416・420行付近（CoW-on-emptyの横展開修正） |
| 2026-10-02 | `0fbb2133` | Dictionary | 参照型Valueで`dictionary[key] = nil`が値を二重に解放する | **[事実]** diffのコメント（2026-10-03発見、`.move()`を読み取りへ変更）と、`RedBlackTreeDictionary_6_RemovalTests.swift`・`RedBlackTreeSet_15_ValueSemanticsTests.swift`の変更 |
| 2026-10-07 | `4eae63f9` | Permutation | `ManagedBuffer`のheaderを手で破棄し、二重破棄していた | **[事実]** commit本文：Debug専用のheader probeで破棄回数を観測し、追加した内部testが修正前にcrashした |
| 2026-10-08 | `89a93f9d` | OptionalArray（現OptionalElementBuffer） | 3D Viewのplane strideの誤り | **[事実]** commitとtest変更 |
| 2026-10-08 | `244c6083` | OptionalArray | 体積0のshapeでのindex計算の誤り | **[事実]** commitとtest変更 |
| 2026-10-10 | `a7663bbb` | Permutation | iteratorのcopyが独立しない（Swift 6.4 Release） | **[事実]** commitとtest変更 |
| 2026-10-15 | `31aa2f07` | 4型の範囲`erase(_:where:)` | predicateのエラーを返さずtrapする。範囲検査用の`catch { fatalError }`が利用者のエラーまで捕まえていた | **[事実]** RBT-042でClaudeが一時probeで再現し、AstraがSetを含む4型を修正。修正前に失敗し修正後に成功する回帰テスト8件（各型の`_99_DeathTests.swift`）を追加 |

## 5. レビューと補完の往復（2026-10-15〜16）

**[事実]** 公開4型について、Astraが静的レビューで課題を出し、Claudeがtestへ反映し、Astraが独立に再実行して受け入れた。経緯の正本は[`RED_BLACK_TREE_TEST_AS_SPEC_REVIEW.md`](../Quality/0.6.0-1/RED_BLACK_TREE_TEST_AS_SPEC_REVIEW.md)、依頼と返却の原文は[`CLAUDE_TASK.md`](../CLAUDE_TASK.md)と各履歴である。

| 段階 | Registry ID | 指摘・反映 |
| --- | --- | --- |
| 初回横断 | RBT-036 | 型別レビューへ渡す見取り図 |
| 型別レビュー | RBT-037〜040 | Set S1〜S4、MultiSet M1〜M5、Dictionary D1〜D6、MultiMap MM1〜MM4 |
| 型別補完 | RBT-042〜045 | 上記19件を反映。S2の作業中に4.の`31aa2f07`の不具合を発見 |
| 最終横断 | RBT-041 | X1（SetのBound公開動作がDebug限定）・X2（共通View三種の例外経路）。重複keyでの`.lessThanOrEqual(k)`がどの値を指すかは、DSL.mdの定義どおり規定しないと整理 |
| 追加補完 | RBT-046 | X1・X2を反映 |

**[事実]** 補完を通して、4型のBound公開動作はRelease実行のclass（`RedBlackTree<型>BoundPublicBehaviorTests`）へ分かれた。Debug専用の内部観測（test supportの`isValid`、`_copyCount`など）は元の条件のまま残っている。

## 6. 図の作成方法

**[事実]** 宣言数はshellで数え、SVGはPythonで書き出した。PNGはmacOSの`qlmanage`で描画し、`sips`で横長に切り出した。どちらもrepositoryへ道具として追加していない。

**[事実]** 色は作図skillの標準パレットの分類色を、1番から5番まで固定の順に使った。この環境にNode.jsがなく、パレット検証scriptは実行していない。黄色とマゼンタは明るい背景とのコントラストが低いので、凡例を兼ねた直接ラベルとCSVを付けた。

## 7. この記録で言えないこと

- 宣言数は、検査の強さ、契約のcoverage、実行の成否を表さない。
- 4.の表は、この期間にtestと一緒に直った不具合のうち、commit message・本文・作業記録から確かめた分である。網羅した一覧ではない。
- 2025-09-03から2026-09-20までの間は観測点を置いていない。この間の谷と回復は[AtCoder 2025の記録](../RefactoringFromAtCoder2025/README.md)が扱う。

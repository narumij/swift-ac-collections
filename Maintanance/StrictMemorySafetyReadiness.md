<!-- Codex/Claude作業メモ -->

# `.strictMemorySafety()` 採用レディネス調査 (CLAUDE_TASK.md Task 1)

> 状態(2026-10-06): `AcCollections`、`RedBlackTreeModule`、`PermutationModule`への採用は完了。
> `BareArrayModule`、`OptionalArrayModule`、`RedBlackTreeCollections`への全面適用は保留中で、
> 明示的な再開判断なしに次段階へ進めない。

`.strictMemorySafety()`を各ターゲットへ一時的に適用して診断を収集した初回調査と、
その後の段階的な対応結果を記録する。§1〜§7の初回調査ではproduction codeを変更せず、
`Package.swift`も調査後に復元した。後続の対応ではproduction codeを変更し、下表の
「採用済み」ターゲットへ`.strictMemorySafety()`を恒久適用している。

## 採用状況(2026-10-03 JST 更新)

| 段階 | ターゲット | 状態 |
| --- | --- | --- |
| 第1段階 | `AcCollections`、`RedBlackTreeModule` | **採用済み**(`Package.swift`に恒久適用) |
| 第2段階 | `PermutationModule` | **採用済み**。全診断を局所unsafe境界へ整理し、警告0件(§8) |
| 第2段階 | `BareArrayModule`、`OptionalArrayModule` | 未採用(保留) |
| 第3段階 | `RedBlackTreeCollections` | 未採用(保留) |

第1段階の検証:

- `Package.swift`の差分は2ターゲットへの`.strictMemorySafety()`追加のみ。
  `AcCollections`は`_settings + [.strictMemorySafety()]`、`swiftSettings`の
  無かった`RedBlackTreeModule`には`[.strictMemorySafety()]`を追加した。
- 両ターゲットのソースのタイムスタンプを更新して再コンパイルし、
  `swift build --target AcCollections -v`で両モジュールのコンパイルに
  `-strict-memory-safety`が渡ることを確認。再コンパイル時の警告・エラーは0件。
- `swift build --target RedBlackTreeModule`、`swift build --target AcCollections`、
  `swift build`(パッケージ全体): 成功。
- `swift test`(リポジトリルート、通常モード): 全件成功(XCTest 141サマリ行すべて
  0 failures、Swift Testingすべてpassed)。

以下の§1〜§7は第1段階採用前の調査記録である。

## 1. 設定の確認

- `static func strictMemorySafety(_ condition: BuildSettingCondition? = nil) -> SwiftSetting`
  はPackageDescription 6.2以降で利用可能(Apple Developer Documentationで確認)。
- 本パッケージの`swift-tools-version: 6.2`はこれを満たす。
- ツールチェーン: `swift-driver version: 1.168.6 Apple Swift version 6.4
  (swiftlang-6.4.0.34.1 clang-2100.3.34.1)` / `arm64-apple-macosx27.0.0`。
- `Package.swift`の`RedBlackTreeCollections`ターゲットには
  `// .strictMemorySafety()`というコメントアウト済みプレースホルダーが既に存在
  していた(数ヶ月前のコミットから存在、未適用のまま)。

## 2. 手順と検証コマンド

1. `RedBlackTreeCollections`へ最初に適用し、単体ビルド(`swift build --target
   RedBlackTreeCollections`)で診断を収集。
2. 続いて`AcCollections`、`RedBlackTreeModule`(`Sources/_RedBlackTreeModule`の
   facade)、`OptionalArrayModule`、`BareArrayModule`、`PermutationModule`の
   各ターゲットにも追加し、`swift build`でパッケージ全体をビルド。
3. 診断をターゲット・ファイル・カテゴリ別に集計。
4. `git checkout -- Package.swift`で復元し、`git diff Package.swift`が空である
   ことを確認。

テストターゲット(`*Tests`)へは適用していない(本番コードのみ対象)。

## 3. 結果: ターゲット別診断件数

| ターゲット | 警告件数 | エラー件数 | 備考 |
| --- | --- | --- | --- |
| `AcCollections`(facade) | **0** | 0 | `@_exported import`のみで構成。即時適用可能 |
| `RedBlackTreeModule`(`_RedBlackTreeModule`互換shim) | **0** | 0 | 即時適用可能 |
| `PermutationModule` | 34 | 0 | 全件`Permutations.swift`、`ManagedBuffer`ベースの手動メモリ実装由来。2026-10-03の再現では一意な診断は17件(ログ上は各2回出力され34行)、§8参照 |
| `BareArrayModule` | 116 | 0 | 手動メモリ管理モジュール(名称の通り低レベルポインタ操作が本体) |
| `OptionalArrayModule` | 144 | 0 | 同上 |
| `RedBlackTreeCollections` | 4,948 | 0 | 赤黒木の生ポインタ実装本体。最大のターゲット |

全ターゲットでエラーは0件(ビルドは全て成功)。警告のみ。

## 4. 診断カテゴリの分類

`RedBlackTreeCollections`の4,948件の内訳(カテゴリ別、上位):

| カテゴリ | 件数 |
| --- | --- |
| `expression uses unsafe constructs but is not marked with 'unsafe'` | 9,548(1警告が複数行のnoteを伴うため警告行数と一致しない。実警告数は上表の集計値) |
| `conformance of 'UnsafeIterator...' to protocol '_NodePtrType' involves unsafe code` | 124 |
| その他`conformance of '...'`系(View/Tree型の`_NodePtrType`適合) | 約100 |
| `struct '...' has storage involving unsafe types`(`UnsafeNode`/`Header`/`Template`/`Null`等) | 約20 |

ディレクトリ別では`Implements/UnsafeTreeV2`(1,178件)と`Implements/__tree/unsafe_tree`
(1,046件)が最多で、赤黒木の生ポインタ実装(`UnsafeMutablePointer<UnsafeNode>`を
直接保持・比較・演算する層)に集中している。これは意図された低レベル実装であり、
`Design-MemorySafety.md`で既に文書化されている設計上の判断である。

## 5. 診断の分離: 意図的な低レベル実装 vs 機械的に直せるもの

- **意図的な低レベル実装由来(修正しない)**: `RedBlackTreeCollections`の
  `Implements/UnsafeTreeV2`、`Implements/__tree/unsafe_node`、
  `Implements/__tree/unsafe_tree`、`Implements/RawBuffer`配下。生ポインタの
  直接比較・加算・ストレージ保持が本質的な実装手段であり、`@unsafe`注釈を
  機械的に付けるだけでは設計の見通しを改善しない。`BareArrayModule`/
  `OptionalArrayModule`/`PermutationModule`の警告も同様に、`UnsafeMutablePointer`/
  `ManagedBuffer`を直接操作する手動メモリ管理が本体のため、同じ分類に属する。
- **機械的に直せる可能性がある宣言**: 本調査では、上記以外の「ふつうの宣言」
  (たとえば`Unsafe`型を一切含まない公開APIシグネチャに対する警告)は
  見つからなかった。`RedBlackTreeCollections`の全警告は、生ポインタ型
  (`UnsafeMutablePointer<UnsafeNode>`等)を直接保持・参照するコードに起因する。

## 6. 段階的採用の提案

1. **即時適用可能(production code変更なし)**: `AcCollections`、
   `RedBlackTreeModule`。警告0件のため、`Package.swift`への追加だけで
   採用できる。→ 2026-10-03 採用済み(冒頭「採用状況」参照)。
2. **第2段階(手動メモリ管理の低レベルモジュール)**: `PermutationModule`
   (34件)→`BareArrayModule`(116件)→`OptionalArrayModule`(144件)の順。
   件数が少ない順に、各警告が妥当な`unsafe`マーキングで解消できるか個別に
   判断する。これらは比較的独立した小モジュールのため、1モジュールずつ
   レビュー・適用できる。
3. **第3段階(`RedBlackTreeCollections`本体)**: 4,948件は規模が大きく、
   `Design-MemorySafety.md`が既に整理している責務分離(`UnsafeNode`/
   `UnsafeTreeV2`/Public型)に沿って、内部層ごとに`@unsafe`適合・注釈を
   計画的に追加する大規模タスクになる。本調査の範囲では、レディネス確認
   (ビルドが成功しエラーが出ないこと)のみを確認し、注釈追加の実作業は
   別タスクとして提案する。

## 7. 検証結果

- `swift build --target RedBlackTreeCollections`(`.strictMemorySafety()`
  一時適用): 成功、警告4,948件、エラー0件。
- `swift build`(全ターゲットへ適用、パッケージ全体): 成功
  (`Build complete!`)、エラー0件。
- `git checkout -- Package.swift`後、`git diff Package.swift`は空
  (復元確認済み)。
- 本調査はビルド診断の収集のみで、`swift test`は実行していない
  (production codeの変更がないため)。

## 8. `PermutationModule` 実装結果(2026-10-03、全バッチ完了)

G1〜G6をproduction codeへ適用し、`Package.swift`へ`.strictMemorySafety()`を恒久適用した。

### 再現手順と結果

1. `Package.swift`の`PermutationModule`ターゲットを一時的に
   `swiftSettings: _settings + [.strictMemorySafety()]`へ変更。
2. `touch Sources/PermutationModule/*.swift` の後
   `swift build --target PermutationModule` を実行し、ANSI色を除去して集計。
3. `Package.swift`を元の1行へ戻し、`git diff Package.swift`が空であることを確認
   (第1段階の採用状態のまま)。

結果: 警告34行、エラー0件。ただし**全17箇所が同一内容で2回ずつ出力されており、
一意な診断は17件**である(§3の34件も同じ二重計上だった可能性が高い)。
全件`Permutations.swift`の`expression uses unsafe constructs but is not marked
with 'unsafe'`で、`NextPermutationProtocol.swift`は0件。§4に見られた
`conformance ... involves unsafe code`や`has storage involving unsafe types`は
発生しておらず、公開APIシグネチャにunsafe型は現れない。全診断が`@usableFromInline`
の内部クラス`Permutations.Buffer`(`ManagedBuffer<Header, Element>`)の内側に閉じる。

### 宣言・所有境界ごとの分類

| # | 宣言(行) | 件数 | 所有境界・前提となる不変条件 | 最小と思われる対処 |
| --- | --- | --- | --- | --- |
| G1 | `Buffer.deinit`(120–122) | 3 | Bufferが自身のheaderと先頭`header.count`個の初期化済み要素を所有する | scoped `unsafe`。`withUnsafeMutablePointers`のクロージャ内で完結し、ポインタは外へ出ない。破棄は所有者自身の責務で安全な代替APIはない |
| G2 | `__header_ptr` / `__storage_ptr`(171, 177) | 4 | **`withUnsafe…`のクロージャからポインタを外へ持ち出している**。Bufferが生存している間は記憶域が動かないという`ManagedBuffer`の性質に依存 | `__header_ptr`: 削除して`ManagedBuffer.header`(安全なプロパティ。`copy`/`prepare`では既に使用)へ置換(内部API再設計)。`__storage_ptr`: 安全な代替がない(`_modify`はクロージャ内から`yield`できない)ため`@unsafe`宣言にし、用途を添字へ限定 |
| G3 | `isEmpty`/`endIndex`(185, 191)、`subscript`のget/`_modify`(213, 215) | 4 | G2の利用側。添字は範囲チェックなしのポインタ添字 | 185/191はG2の`header`置換で警告ごと消える。213/215はG2を`@unsafe`にしたうえでscoped `unsafe`(呼び出し中は`self`が生存することが根拠) |
| G4 | `create(withCapacity:)`の`unsafeDowncast`(229) | 1 | `Permutations.Buffer<Element>.create`が実際に`Buffer`のインスタンスを返すこと。クラスが`final`でないため、`Self`がサブクラスなら前提が崩れる(現状サブクラスなし) | scoped `unsafe`。安全な代替の`as! Self`は動的検査が入るため性能確認が必要。前提を型で保証したいなら`final class`化(別バッチ) |
| G5 | `copy(newCapacity:)`の要素コピー(250–252) | 3 | `count <= newCapacity`。**引数`newCapacity`に`count`未満を渡すと範囲外書き込みになるが検査がない**(現呼び出し元は`copy()`の1箇所のみで常に`nil`) | scoped `unsafe`。前提はprecondition追加か、未使用引数`newCapacity`の削除で閉じる(後者は内部API再設計) |
| G6 | `prepare(source:)`の要素初期化(277, 279) | 2 | `source`を列挙した要素数が`source.count`と一致すること(`Collection`の契約) | scoped `unsafe`。範囲検査付きの代替として`UnsafeMutableBufferPointer.initialize(fromContentsOf:)`があるが、その場合もbuffer pointerの生成自体にscoped `unsafe`が必要 |

`@unsafe`を付ける公開型・conformanceはなく、局所的に安全な修正が存在しない
グループもない(G2の`__storage_ptr`だけは`@unsafe`宣言が必要)。

### 実装バッチ案(各バッチ後に通常/`COMPATIBLE_ATCODER_2025`で`swift test`)

1. **完了 — バッチ1(方式の検証、最小)**: G1の`deinit`だけにscoped `unsafe`を付け、
   一時適用ビルドで警告が17→14件に減ること、`unsafe`式がtools-version 6.2で
   問題なくビルドできることを確認する。`.strictMemorySafety()`はまだ恒久適用しない。
2. **完了 — バッチ2(G2+G3、内部API再設計)**: `__header_ptr`を`header`へ置換して削除し、
   `__storage_ptr`を`@unsafe`化、添字2箇所にscoped `unsafe`。`@inline(__always)`の
   ホットパスを変えるため、Release計測で性能が劣化しないことを確認する
   (公開添字の要素アクセスは`Benchmarks/Sources/Benchmarks/PermutationBenchmarks.swift`で
   計測できる。`nextPermutation`自体のベンチマークはまだ無い)。
3. **完了 — バッチ3(G4〜G6)**: G4〜G6をscoped `unsafe`で明示。G4はSendable対応時に
   `Buffer`を`final`化済み。G5は`capacity >= count`のpreconditionを追加してからコピーする。
4. **完了 — バッチ4(恒久適用)**: 警告0件を確認し、`PermutationModule`へ
   `.strictMemorySafety()`を追加した。

### 全バッチ完了結果(2026-10-03)

- G2/G3: `__header_ptr`を削除し、安全な`ManagedBuffer.header`へ置換。要素ポインタを返す
  `__storage_ptr`だけを`@unsafe`とし、get/modifyの利用箇所をscoped `unsafe`に限定した。
- G4〜G6: downcast、buffer間コピー、sourceからの初期化をそれぞれscoped `unsafe`で明示。
- strict設定下のXcode Build for Testingで`PermutationModule`の警告・エラー0件。
- strict設定下でPermutationの通常テスト6件がすべて成功。

### バッチ1 実施結果(2026-10-03)

- 変更: `Permutations.Buffer.deinit`の3式(`withUnsafeMutablePointers`呼び出しと
  クロージャ内の`deinitialize`2つ)へscoped `unsafe`を付与。外側の`unsafe`は
  クロージャ本体へ及ばないため、3箇所それぞれに必要だった。
- 一時適用ビルド(§8の再現手順と同じ): 一意な診断が**17→14件**。消えたのは
  120:7、121:9、122:9の3件のみで、残り14件はG2〜G6の行と一致。新しい種類の
  警告・エラー(`unsafe`の不要指摘を含む)は出なかった。`unsafe`式は
  tools-version 6.2でそのままビルドできた。
- `Package.swift`は元に戻した(`git diff Package.swift`は空)。
- 検証: 通常構成で`swift build`成功、`swift test --filter
  PermutationTests.PermutationTests`で2件成功。`COMPATIBLE_ATCODER_2025`を一時的に
  有効にして`swift test --filter 'PermutationTests|AcCollectionsTests'`を実行し、
  PermutationTests 2件・AcCollectionsTests 4件が成功。定義を元に戻したあとも
  通常ビルドが成功した。

### 境界修正後の再監査(2026-10-03)

- 公開`SubSequenceN.subscript(position:)`へ範囲`precondition`を追加した後、§8の
  再現手順で一時適用ビルドを再実行した。一意な診断は**14件のまま**で、新しい種類の
  診断はない。追加した`precondition`の行からは診断が出ていない。
- 残り14件はG2〜G6のままで、行番号だけが1行ずつ後ろへずれた: G2 172・178(各2件)、
  G3 186・192・214・216、G4 230、G5 251–253、G6 278・280。
- `Package.swift`は`git checkout -- Package.swift`で元に戻した(`git diff Package.swift`は空)。

### 計画で見つけた懸念(ユーザー判断事項、今回は未変更)

- **公開APIの範囲外アクセス(2026-10-03 修正済み)**: 公開添字へ範囲`precondition`を
  追加し、`Tests/PermutationTests/PermutationDeathTests.swift`で`endIndex`・`-1`・
  `endIndex + 1`がSIGTRAPで停止することを固定した。計測値は
  `PermutationModule/ProductReadinessAssessment.md`の「公開添字の境界チェックと計測」。
  以下は修正前の記録。
  `SubSequenceN.subscript(position:)`(公開)は
  `Buffer`の範囲チェックのないポインタ添字(G3、213行)へ直結しており、範囲外の
  `position`で範囲外メモリを読む(コード読解による。未定義動作のため実行確認はしていない)。
  `RandomAccessCollection`としては範囲外はtrapが期待される。strict memory safetyの
  警告解消とは独立した論点で、修正するならDeath Testを先に追加する。
  - **実測(2026-10-03、Task 3)**: Swift Testingのexit test(子プロセス)内だけで
    `[1, 2, 3].nextPermutations()`の最初の要素へアクセスした。テストランナー本体では
    範囲外アクセスをしていない。一時テストファイルは記録後に削除した。

    | position | Debug(各10回) | Release(各10回) |
    | --- | --- | --- |
    | `endIndex`(3) | 正常終了、値`0` | 正常終了、値`1` |
    | `-1` | 正常終了、値`0` | 正常終了、値`0` |
    | `endIndex + 1` | 正常終了、値`0` | 正常終了、値`0` |
    | `1 << 40`(各3回) | `SIGSEGV` | `SIGSEGV` |

    公開`Index == Int`なので、負値・`endIndex`超過は公開APIだけで作れる。調査時点では
    近傍の範囲外が構成依存の不定値を返し、遠方はSIGSEGVになっていた。
  - **修正済み(2026-10-03)**: 公開層の`SubSequenceN.subscript(position:)`へ
    `precondition(position >= startIndex && position < endIndex, "Index out of range")`
    を追加した。内部の`Buffer`添字と順列生成アルゴリズムは変更していない。
    `endIndex`、`-1`、`endIndex + 1`、`Int.min`、`Int.max`が通常のprecondition失敗に
    なることをexit testで固定した。性能再検証では実用的なend-to-end overheadは
    観測されず、明瞭な2比較の実装を維持している。
- G5の`newCapacity < count`の未検査(現状は到達経路なし)。
- G4の非`final`クラスに対する`unsafeDowncast`(現状はサブクラスなし)。

## 9. `PermutationModule` の `Sendable` 対応(2026-10-03)

ユーザー決定: Swift 6+の`Sendable`対応は必須。所有権監査と段階実装を完了した。

| 公開型 | 保持するもの | 区分 |
| --- | --- | --- |
| `Permutations<C>` (caseなしenum) | なし | 対応済み: `Sendable` |
| `Nexts` | `source: C` | 対応済み: `Sendable where C: Sendable` |
| `IteratorN` | `Buffer<C.Element>`(参照)+ `Bool` 2個 | 対応済み: `@unchecked Sendable where C.Element: Sendable` |
| `SubSequenceN` | `Buffer<C.Element>`(参照、`let`) | 対応済み: `@unchecked Sendable where C.Element: Sendable` |

`@unchecked`の根拠: `Buffer` は可変の`ManagedBuffer`サブクラスで、
最初の `next()` が返す `SubSequenceN` と `IteratorN` は同じバッファを共有する。変更前に
`isKnownUniquelyReferenced`でコピーするCoWが唯一の変更経路である。`SubSequenceN`は
読み取り専用であり、共有中のiteratorは次の変更前にdetachする。`Buffer`を`final`にして
未知のsubclassによる変更経路も閉じた。コンパイラはこのCoW不変条件を証明できないため
2型に限って`@unchecked`を用いる。`C`自体は保持しないので、条件は
`C.Element: Sendable`で足りる。`Header`は内部用で`Int`のみ。

実装バッチ案(各バッチ後に通常/`COMPATIBLE_ATCODER_2025` で対象テスト):

1. **実施済み**: `Permutations`と`Nexts`へ`Sendable`を追加し、ジェネリックな
   `requireSendable<T: Sendable>`によるコンパイル時チェックを追加。
2. **実施済み**: `Buffer`を`final`にし、未知のsubclassによる変更経路を閉じた。
3. **実施済み**: `IteratorN`/`SubSequenceN`へCoWを根拠とした
   `@unchecked Sendable where C.Element: Sendable`を追加。取得済みの`SubSequenceN`を
   detached taskへ送って読む間にiteratorを進めても値が変わらないこと、および同じ
   iteratorから作った2つのcopyを別taskで同時に最後まで進めても独立することをテストした。

## 保留事項

- `RedBlackTreeCollections`本体への実際の注釈付け作業は本タスクの範囲外。
  ユーザーが段階2・3の着手順を承認した後、別タスクとして計画する。
- 診断メッセージの正確なカウントはビルドログの行パターンマッチングに依存して
  いるため、Swiftコンパイラの出力形式が変わった場合は再集計が必要。

## 10. `BareArrayModule` 段階対応(2026-10-03、バッチ4実施済み)

`.strictMemorySafety()`を一時適用してXcodeで再コンパイルした。従来の116件は重複を
含むログ行数で、ファイル位置とメッセージで一意化すると約64箇所だった。公開所有型4、
非所有View型3の生ポインタstorage、確保・初期化・添字・clone・破棄に集中している。

バッチ1では、所有型`BareArray`/`BareArray2D`/`BareArray3D`/`BareArray4D`の`deinit`だけを
対象にした。各型が自分で確保した初期化済み要素の`deinitialize`とstorageの`deallocate`を
scoped `unsafe`で明示した。公開API、layout、添字経路、Viewには変更を加えていない。

- strict設定下のBuild for Testing: 成功。
- 一意な診断: 約64→54箇所。
- 参照要素の破棄・上書きに関する対象テスト4件: すべて成功。
- `BareArrayModule`の`.strictMemorySafety()`は調査後に外し、未採用のままとした。

次のバッチは所有型の確保・初期化とcloneを先に扱い、公開型storageに対する`@unsafe`の
設計判断、および非所有Viewの境界は別バッチに分ける。

バッチ2では、所有型4つの初期化済み要素への書き込みとclone時のbufferコピー、および
生ポインタを受け取る内部initializerの呼び出しをscoped `unsafe`で明示した。確保操作の
`allocate`はstrict有効時だけunsafe診断の対象になり、未採用構成で先に注釈すると
`No unsafe operations occur`警告になるため、恒久適用と同時に扱う項目として残した。

- strict設定下の一意な診断: 54→38箇所。
- 通常構成のBuild for Testing: 成功、コード診断0件。
- 所有型4つの初期化・clone・参照要素寿命に関する対象テスト12件: すべて成功。
- 一時的なBareArray strict設定は再び外し、`Package.swift`を採用前の状態へ戻した。

次は所有型からViewを作るpointer arithmeticと、非所有Viewの内部initializer・添字を
一つの境界として整理する。公開型そのものへの`@unsafe`付与とstrict恒久適用は最後に行う。

バッチ3では、所有型から非所有Viewを作るpointer arithmetic、Viewの内部pointer
initializer、View添字のpointer返却をscoped `unsafe`または`@unsafe` initializerとして
整理した。strict設定下の一意な診断は38→28箇所。Viewの共有・変更・範囲外停止に関する
対象テスト10件が成功した。

バッチ4では、所有型4つの内部pointer initializerと1D添字のpointer返却を同様に整理した。
strict設定下の一意な診断は28→22箇所。clone、1D変更、Death Testの対象7件が成功した。

残る22箇所は、所有型4・View型3の「unsafe型をstorageに持つ」診断とそのstorage代入、
およびstrict有効時だけunsafe扱いになる8回の`allocate`である。payload propertyだけへ
`@unsafe`を付けるPoCでは診断は減らず、型全体への`@unsafe`が必要だった。これは公開型の
利用者へunsafe要求を伝播させるAPI上の判断になるため、恒久適用前にユーザー確認が必要。
PoCのproperty注釈と一時的なPackage設定は復元済み。

現時点の推奨は、警告を消すためだけに公開7型を`@unsafe`へ変更しないこと。Appleの
strict memory safety設定はunsafe構造を安全化するものではなく、`unsafe`/`@unsafe`で
監査境界を明示する機能である。現在の公開initializerと範囲検査付きsubscriptまでunsafe
利用として呼び出し側へ伝播させるのは、診断の実態より広すぎる。恒久適用するなら、
生ポインタを公開値型のstorageから隔離できる所有storage設計を別途検討し、性能・Viewの
寿命・競技プログラミング向け単一ファイル性を再検証する。現構造のままでは22件を既知の
監査対象として残し、`BareArrayModule`のstrict設定は無効のままとする。

## 11. `OptionalArrayModule` 段階対応(2026-10-03、バッチ4実施済み)

`.strictMemorySafety()`を一時適用してXcodeで再コンパイルした。従来の144件は重複を
含むログ行数で、ファイル位置とメッセージで一意化すると82箇所だった。所有型4つの
`hasPayload`／`payload`、確保・初期化・添字・`removeAll`・破棄と、非所有Viewの
ポインタ操作に集中している。

バッチ1では、所有型`OptionalArray1D`／`OptionalArray2D`／`OptionalArray3D`／
`OptionalArray4D`の`deinit`だけを対象にした。各型が所有する初期化済みpayloadの判定と
破棄、payloadおよび初期化フラグ領域の破棄・解放を、20個のscoped `unsafe`式として
明示した。公開API、layout、添字、Viewには変更を加えていない。

- strict設定下のBuild for Testing: 成功。
- 一意な診断: **82→62箇所**。減少数は追加したscoped `unsafe` 20個と一致。
- 通常構成のビルド: 成功。
- 参照要素の上書き、View経由の上書き、`removeAll`、所有配列の`deinit`に関する
  対象テスト4件: すべて成功。
- `OptionalArrayModule`の`.strictMemorySafety()`は調査後に外し、未採用のままとした。

公開型のunsafe storage診断は`BareArrayModule`と同様に、呼び出し側へunsafe要求を
伝播させず隔離できる設計を確認してから恒久適用を判断する。

バッチ2では、所有型4つの`removeAll`と、要素を直接取得・変更する
`OptionalArray1D.subscript`をscoped `unsafe`で明示した。2D〜4Dのsubscriptは
非所有Viewを作る境界なので、このバッチには含めていない。

- strict設定下の一意な診断: **62→44箇所**。減少した18件は`removeAll` 12件と
  1D subscript 6件に一致。
- 通常構成のビルド: 成功。
- `OptionalArrayTests` 23件（全次元の設定・取得・`removeAll`・View共有・参照要素寿命）:
  すべて成功。
- 一時的なOptionalArray strict設定は再び外し、`Package.swift`を採用前の状態へ戻した。

バッチ3では、所有型4つのinitializerにある初期化フラグ領域の`initialize`をscoped
`unsafe`で明示した。通常構成でも追加警告は発生しないことを先に確認した。

- strict設定下の一意な診断: **44→40箇所**。
- 通常構成のビルドと`OptionalArrayTests` 23件: すべて成功。
- initializerに残る8件は2ポインタ×4型の`allocate`。これはstrict無効時にはunsafe操作
  として扱われず、先にscoped `unsafe`を付けると不要なunsafe警告になり得るため、
  strict恒久適用と同じバッチへ保留する。
- 一時的なOptionalArray strict設定は外し、`Package.swift`を採用前の状態へ戻した。

バッチ4では、所有型2D〜4DからViewを作るpointer arithmetic、非所有View 3型の
内部pointer initializer、View間のsubscript、1D Viewの要素取得・変更をscoped
`unsafe`または`@unsafe` initializerとして整理した。あわせて1D所有型の内部
`description`に残っていた読み取り2件も局所化した。

- strict設定下の一意な診断: **40→23→21箇所**。View境界で17件、`description`で
  2件減少した。
- 通常構成のビルド: 成功。
- `OptionalArrayTests` 23件と`OptionalArrayDeathTests` 7件: 全30件成功。
- 一時的なOptionalArray strict設定は外し、`Package.swift`を採用前の状態へ戻した。

残る21箇所は、所有型4・View型3の「unsafe型をstorageに持つ」診断7件、Viewの
pointer initializerでそのstorageへ代入する診断6件、strict有効時だけunsafe扱いになる
`allocate` 8件である。局所的なポインタ操作はすべて監査境界へ整理できたが、残件を
消すには公開7型への`@unsafe`伝播、または生ポインタstorageの隔離設計が必要になる。
`BareArrayModule`と同じ理由で、警告を消すためだけに公開型を`@unsafe`へ変更せず、
`OptionalArrayModule`のstrict設定は無効のままとする。

`ARRAY-001`は、storage再設計、View寿命、公開unsafe境界、strict恒久適用を現在の粒度のまま実行するtaskではない。
ユーザードキュメント作業後、再開時点で得られている公開契約、品質評価、task分解方式を入力に、BareArrayと
OptionalArrayそれぞれの事実確認、一判断ごとの`DECISION`、判断済み方針の`EXECUTION`へ分解する。
将来の方が適切な境界を見つけられる可能性を残すため、現時点では子taskを先行登録しない。

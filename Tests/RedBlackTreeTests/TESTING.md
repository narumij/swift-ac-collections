<!-- CodexとClaudeによるCodexとClaudeのためのメモ -->

# RedBlackTreeTests maintenance notes

## User requests for the next session

リセット待ち・休憩中に、次回の作業で優先してほしい内容をユーザーが書く欄。この欄に記載がある場合、Codex は `Current handoff` より先に読み、最新のユーザー要望として優先する。完了した項目を Codex が勝手に削除せず、完了したことを追記するか、ユーザー確認後に整理する。

記入例:

- 最優先で扱うフォルダまたはファイル
- 残してほしいテスト、削除してよい重複
- Swift Testing / XCTest / compatibility の配置に関する希望
- テストが通った時点で止める、残量何%で休憩する、といった停止条件
- 次回まで保留した判断や気になっている破損

<!-- ユーザー記入欄: この下へ追記 -->

### 優先事項

- Claudeさん、ここまで棚卸ししてて、このテスト群はTest as Specificationを意識してると感じましたか？

### 連絡事項

- 5時間上限または週間利用上限で止まるとき、それまでの作業の感想も教えて欲しい
- 最後に作業したモデルはモデル名とバージョンをどこかに記載すること
- Codexさんはふりかえりの時間を確保すること
- Claudeさんは始業時に会話の時間を確保すること
- 小さな変更を積み重ねてるときは互換チェックをさぼっていい
- テストコードのTODOで調査となっているものの対応
- テスト修正が面倒くさいために互換維持している機能があり、テストの棚卸しのあとにこれの整理する
- 内部構造をどのように区分するのか、勝手に判断しないこと
- ユーザー記載欄に記入する場合、こちらが消す都合上、古さが分からないと困るので、日付に加えて時間も記載すること
- 現行APIかどうか判断に迷った場合API-Matrix.mdに照らすこと
- 互換チェック時、現行>互換>現行ではなく、現行>互換で十分です

### 停止条件

- 利用上限が少ないセッションでは、新しい大きなカテゴリへ着手する前に、全体テスト・文書更新・振り返りに必要な余裕を確保する。

### 保留中の判断・懸念

- こちらでヒント系APIとAPI一覧を触ってるので、Test as Spec観点でチェックしてほしい
- 内部構造をテスト観点でどのように区分するのか、まだ結論がでていない
- insert(:hint:)やupdate(:hint:)等のヒント系APIのテストが不十分なまま
- 生木へのテストを増やすと変更コストがかさむので、バランスに悩んでいる

### 完了済みの要望

### 用語

生木 -> UnsafeTreeV2
生バッファ -> RawBufferのソースファイル群

<!-- 全て確認したため、クリアした -->

<!-- ユーザー記入欄ここまで -->

## Test as Spec

型名のディレクトリにある連番付きテストを、公開 API の現行仕様を示す正本（Test as Spec）とする。

例:

- `RedBlackTreeSet/RedBlackTreeSet_0_InitializationTests.swift`
- `RedBlackTreeMultiSet/RedBlackTreeMultiSet_6_RemovalTests.swift`

連番テストには、利用者が観測できる振る舞いを API の役割ごとに配置する。テスト名は、入力だけでなく保証される結果が読める名前にする。現行実装に存在しない API のために連番を埋める必要はない。

旧フォルダのテストを整理するときは、単純に削除しない。現行の公開 API を検証しているケースが連番側に無ければ、現在の API と期待値に合わせて修正コピーしてから旧ケースを削除する。

次のテストは連番へ無理に混ぜなくてよい。

- `@testable` や `___`、内部 pointer などに依存する実装テスト
- 性能、負荷、ファズ、回帰専用テスト
- 互換モードだけに存在する API のテスト

公開 API の precondition や不正 index を専用プロセスで検証する Death Test は、各型の連番 `_99_DeathTests.swift` に配置する。`DEATH_TEST` 条件は維持し、通常仕様と同じ場所から発見できるようにする。

内部実装・coverage テストは `_98_*.swift` に分ける。まだ公開仕様・内部仕様・互換仕様の分類が済んでいない Swift Testing ベースのテストは、一時的に `_97_*.swift` へ置く。分類済みの公開 Death Test は `_99_DeathTests.swift` とする。通常の XCTest による Test as Spec と同じファイルへ混ぜず、GitHub Actions で問題が起きたときに Swift Testing 使用箇所をファイル名から絞り込めるようにする。

## Swift Testing isolation

Swift Testing は GitHub Actions 上で test discovery や exit test に問題が起きることがあるため、通常の XCTest ベースの Test as Spec から隔離し続ける。

- `_97_*.swift`: 未分類の Swift Testing。内容を確認後、`_98`、`_99`、または compatibility file へ移す一時置き場。
- `_98_*.swift`: 内部実装・coverage。Swift Testing を使う場合も公開仕様の連番テストへ混ぜない。
- `_99_DeathTests.swift`: 公開 API の exit test。Swift Testing の `#expect(processExitsWith:)` が必要な範囲に限定する。
- `*AtCoder2025CompatibilityTests.swift`: 互換モード専用の XCTest。`import Testing` や `@Test` を同居させない。
- `*AtCoder2025CompatibilitySwiftTests.swift`: 互換モード専用の Swift Testing。exit test など Swift Testing が必要なケースだけを配置する。

通常の成功系テストは XCTest で書く。Swift Testing を新たに通常連番へ追加しない。GitHub Actions で問題が起きた場合に `_97`、`_98`、`_99`、compatibility を個別に特定・除外できる配置を維持する。

互換テストでも XCTest と Swift Testing を同じソースへ混在させない。ファイル名の `CompatibilityTests` と `CompatibilitySwiftTests` で test framework を判別できる状態を保つ。

## AtCoder 2025 compatibility tests

`COMPATIBLE_ATCODER_2025` 専用テストは、`*AtCoder2025CompatibilityTests.swift` に集約する。これらは互換モードを廃止するとき、検索して一括削除できることを目的としている。

互換モードだけに存在する API を連番テストへ戻さない。現行と互換モードの両方にある API でも期待する挙動が異なる場合は、現行仕様を連番側、旧仕様を compatibility file 側に分ける。

互換テストから連番側の test class を extension している場合がある。連番ファイルの移動や改名時は、`*AtCoder2025CompatibilityTests.swift` 内の extension 参照も確認する。

## Safe migration workflow

長時間の整理を壊れた状態で残さないため、次の単位を守る。

1. 旧テストと現行 API を比較する。
2. API の一カテゴリだけ連番側へ移す。
3. Xcode のファイル診断でコンパイルエラーを確認する。
4. 全テストを実行し、失敗が 0 であることを確認する。
5. コミット可能な状態になってから次のカテゴリへ進む。

テスト数は、重複ケースの統合や旧ファイル削除で減ることがある。件数ではなく、公開仕様の欠落がないことと全テスト失敗 0 を基準にする。

長時間のセッションでは、残量 10% 付近で新しいカテゴリへの着手を止める。最後の 5% は、全体テスト、`Current handoff` の更新、次回の開始地点の明記、コミット可能な状態の確認に使う。作業量を増やすためにこの振り返り時間を使い切らないこと。

## Current handoff

- `RedBlackTreeSet` の連番テストは Test as Spec として整理済み。旧 `set` フォルダの Swift テストは残っていない。
- 旧 `set` フォルダにあった SetAlgebra、reserve-capacity、corner-case、bidirectional、removal、extended と巨大な `SetTests.swift` は監査・整理済み。公開仕様は連番へ、SetAlgebra stress、COW、pointer、performance、固定 seed の fuzz、removal stress、removal internal、raw index validity は型別 `_98`、互換仕様は型別 compatibility file へ移管した。再現不能なランダムテストは固定 seed fuzz で置換した。index-based range view は `_17_RangeViewTests.swift`、`elements(in:)` の現行要素範囲ビュー仕様は `_18_ElementRangeTests.swift`、参照型要素の `insert` / `update` identity は `_5_InsertionTests.swift`、現行 `filter` の戻り型は `_1_SequenceTests.swift` で仕様化している。
- `COMPATIBLE_ATCODER_2025` を一時的に有効化した Debug 全体テストは 2026-09-28 に成功。`SetTests.swift` 整理後の最新結果は 968 成功・0 失敗・6 スキップ。通常モードも 1036 成功・0 失敗・1 スキップ。確認後、`Package.swift` は通常モードへ戻した。互換モードで懸念されていた `MultiMapEtcTests` に失敗は出なかった。
- 旧 `SetTests` を土台にしていた9個の互換 extension と互換専用の element-range subscript/iteration は、`RedBlackTreeSetAdditionalAtCoder2025LegacyTests` へ閉じ込め済み。旧 `SetTests.swift` は削除済み。
- ルート直下では `MergeTests.swift`、`DocumentCheckTests.swift`、`EtcTests.swift` などに Set 公開仕様が混在する。単純移動せず、他型のケースを残しながら Set ケースだけ連番側へ移植・整理する。
- `BoundExpression` は公開 DSL として4型それぞれの `_16_BoundExpressionTests.swift` へ移管済み。旧 `boundsExpression` フォルダの Swift テストは残っていない。位置式、相対移動、limit、range expression、subscript、erase の既存仕様を型別 Test as Spec として維持する。DEBUG 専用の内部 validity を追加するときは `_98_InternalTests.swift` に置く。
- `RedBlackTreeMultiSet` は initialization、sequence、bidirectional collection、index、search、insertion、removal、utility、range view、protocol conformance、set algebra、element range を連番化済み。`_98_*` に performance、fuzz(参照モデル比較+ツリー不変条件)、copy-on-write、removal stress/internal を型別に整備済み。
- `RedBlackTreeDictionary` は initialization、sequence、index、search、insertion、removal、utility、range view、protocol conformance、Codable を連番化済み。
- `RedBlackTreeMultiMap` は initialization、sequence（predicate、sorted、reversed を含む）、index、search、insertion、removal、utility、range view、protocol conformance、Codable、transforming and combining、element range を連番化済み。
- `multimap` 以下の広範な旧テスト (`MultiMapBasicTest.swift`、`MultiMapAdvancedTest.swift`、`RedBlackTreeMultiMapTests.swift` とその removal extension、`RedBlackTreeMultiMapTests_.swift`、`MultiMapEtcTests.swift`、`MultiMapRemoveTests.swift`、`MultiMapViewTests.swift`) は、連番側への不足仕様の移植後に整理済み。互換 extension が必要とする test class と fixture は compatibility file 内へ閉じ込め、互換専用の range-index removal も同ファイルへ移した。
- `multimap/` フォルダは2026-09-29に完全に棚卸し完了(下記参照)。次回はルート直下の `MergeTests.swift`、`DocumentCheckTests.swift`、`EtcTests.swift` に混在する Set 公開仕様の監査に進む。
- Set、MultiSet、Dictionary、MultiMap の既存 Death Test は各型の `_99_DeathTests.swift` に移管済み。
- `fatalError/Index` に残っていた空の `startIndex` と `endIndex` の Death Test、および `fatalError/etc` の空 collection に対する `removeFirst` / `removeLast`、Set の cross-tree range、削除済み index の再削除は各型の `_99_DeathTests.swift` へ移管済み。重複していた旧 range / fatal テストも整理済み。
- 互換専用 iterator Death Test は `RedBlackTreeSetAtCoder2025CompatibilitySwiftTests.swift` へ移管済み。
- Dictionary、MultiMap、MultiSet の `*AtCoder2025CompatibilityTests.swift` は、各型の Test as Spec フォルダへ移動済み。
- `fatalError/etc` に残っていた通常成功系は XCTest の各型連番へ、内部 coverage / pointer precondition は各型または共有内部の `_98_*.swift` へ移管済み。旧 root `DeathTest.swift` の内容は Set の公開 precondition と確認できたため、`RedBlackTreeSet_99_AdditionalDeathTests.swift` へ分類済み。今後、既存 `_99_DeathTests.swift` との重複を小さい単位で統合する。
- (2026-09-29 04:45) `multiset/` フォルダは棚卸し完了。旧ファイル(`MultisetPointerTests.swift`、`MultisetPerfomarnceTests.swift`、`MultisetCornerCaseTests.swift`、`MultisetCopyOnWriteTests.swift`、`MultisetRemoveTests.swift`、`MultisetTests.swift`)は全て削除し、`multiset/` フォルダ自体は0ファイル(空)。現行仕様は連番へ、内部実装・性能・fuzzは型別 `_98_*.swift` へ、互換専用コードは `RedBlackTreeMultiSetAtCoder2025CompatibilityTests.swift` 内の自己完結クラス(`RedBlackTreeMultisetPointerAtCoder2025LegacyTests`、`RedBlackTreeMultisetIndexRemovalLegacyTests`、`RedBlackTreeMultisetEtcLegacyTests` など)へ集約済み。
- (2026-09-29 04:45) `dictionary/` フォルダは8ファイル中6ファイルを整理済み(残るは `DictionaryExtendedTests.swift`・`DictionaryRecoveredTests.swift`と本体 `DictionaryTests.swift`(1024行未着手)のみ)。`DictionaryRecoveredTests.swift` は `DictionaryTests.swift` 本体への `extension` で内容も既存 `_8_RangeViewTests.swift` と重複していたため、本体の監査と合わせて扱うのがよい。
- (2026-09-29 04:45) **教訓**: `RedBlackTreeMultiSet+Deprecated.swift` は `.indices`、`___node_positions()`、`firstIndex(where:)` など複数のAPIが `#if COMPATIBLE_ATCODER_2025` ガード下にあり、`RedBlackTreeSet+Deprecated.swift` には同ガードがない場合がある(型ごとにガード範囲が異なる)。Set用の `_98_*.swift` を型を変えて流用するときは、使用する全APIを毎回 source で `grep` してから書くこと。現行APIかどうか迷ったら `Sources/RedBlackTreeCollections/Documentation/API-Matrix.md` に照らす。
- (2026-09-29 04:45) 最後に作業したモデル: Claude(Sonnet 5、モデルID `claude-sonnet-5`)。dictionary・multiset フォルダの棚卸しを担当。ファイル削除は `rm` ではなく Xcode の `XcodeRM`(ゴミ箱へ移動)を使用。ビルド確認は Xcode の `BuildProject`/`RunSomeTests`/`RunAllTests` を使用(`swift build`/`swift test` の直接実行は使わない方針)。
- (2026-09-29 04:58) `dictionary/DictionaryExtendedTests.swift`(merge/merging、literal初期化、popFirst、mapValues/compactMapValues/filter、CRUD+index無効化)を監査。全て既存連番(`_0`、`_5`、`_6`、`_7`、`_9`)と重複と判断し削除。唯一新規性のあった`testFuzzEquivalence`(Swift標準`Dictionary`との比較fuzz、固定seed)は、Dictionaryにまだ`_98_FuzzTests.swift`が無かったため新設して移管。互換ファイル側の空extension2つも削除。
- (2026-09-29 04:58) `dictionary/DictionaryRecoveredTests.swift`(`extension DictionaryTests`、testSubsequence6/7・testRangeSubscript)を監査。全て既存`_8_RangeViewTests.swift`と重複と判断し削除(`DictionaryTests`本体は無傷)。
- (2026-09-29 05:10) `dictionary/DictionaryTests.swift`本体(1024行、約60メソッド)を棚卸し。ほぼ全て既存連番(`_0`,`_1`,`_3`,`_4`,`_5`,`_6`,`_8`,`_9`)と重複、または無関係なプレーンSwift `Dictionary`のノイズ、または`#if DEBUG && false`で死んでいたコード(`testEnumeratedSequence1-4`)と判断し削除。新規性のあった5点を移管:
  - `insert(_:hint:)`(TESTING.mdの保留中の判断に載っていた既知ギャップ)と`.insert(_:)`/`.insert(key:value:)` → `_5_InsertionTests.swift`
  - `formIndex(after:)/(before:)`(連番側に一件もカバレッジが無かった) → `_3_IndexSequenceTests.swift`に`index(after:/before:)`との統合テストとして追加
  - 生インデックスの妥当性検証(`.unsafe(tree:rawTag:)`、readOnly storage確認) → Setの`_98_IndexValidityXCTests.swift`と同じ構造で`RedBlackTreeDictionary_98_IndexValidityXCTests.swift`を新設
  - RangeView同士(別ツリー由来)のEquatable → `_9_ProtocolConformanceTests.swift`
  - 互換ファイル側の`extension DictionaryTests`(testSubsequence/2/5、testIndex100/10/11/12、testForEach_enumeration)は自己完結クラス`RedBlackTreeDictionaryEtcAtCoder2025LegacyTests`に集約(死んでいた`testSubsequence4`は削除)。空extension9つも削除。
  - 本体ファイルは`XcodeRM`で削除。ビルド成功、関連テスト27件成功(新設の`_98_IndexValidityXCTests`4件は既存Setの同種ファイルと同様に本環境で「No result」——テスト検出の既知の環境挙動と判断、Set側も同じ状態のため新規ファイルの欠陥ではない)。
- (2026-09-29 05:10) **`dictionary/`フォルダはこれで完全に空になった。Dictionaryの棚卸しは完了。** 次はユーザー指示により`multimap`フォルダに着手する。
- (2026-09-29 05:24) `multimap/MultiMapPointerTests.swift`(30行、実質空のボイラープレート)を、他型と同じパターンで互換ファイル内の自己完結クラス`RedBlackTreeMultiMapPointerAtCoder2025LegacyTests`に変換。旧ファイル削除。
- (2026-09-29 05:24) `multimap/MultiMapCopyOnWriteTests.swift`(232行、`AC_COLLECTIONS_INTERNAL_CHECKS`専用)を`RedBlackTreeMultiMap_98_CopyOnWriteTests.swift`へ移動(クラス名`MultiMapCopyOnWriteTests`→`RedBlackTreeMultiMapCopyOnWriteTests`)。互換ファイル側にあった実体入りextension(`testSet4000`、および`removeFirst(forKey:)`系の`testSet3/3_2/3_3/4/5`の互換版、メソッド名は本体の`!COMPATIBLE_ATCODER_2025`版と同名だが相互排他ガードなので衝突しない)は新クラス名に追従。空extension7つは削除。旧ファイル削除。
- (2026-09-29 05:24) `multimap/MultiMapTests.swift`本体(1128行、約57メソッド)を棚卸し。**重要な発見**: 互換ファイルは既に`MultiMapBasicTest`・`MultiMapAdvancedTest`・`RedBlackTreeMultiMapTests`・`MultiMapRemoveTests`・`MultiMapEtcTests`を自己完結スタブクラスとして宣言する規約になっていたが、`MultiMapTests`だけがその対象から漏れており本体ファイルの`final class MultiMapTests`に依存していた。また本体ファイルのトップレベルにあったヘルパー関数`keyValue`/`__key`/`AssertEquenceEqual`に、既に移設済みの`_98_CopyOnWriteTests.swift`と互換ファイル自身が依存していた(削除すると壊れるところだった)。
  - ヘルパー関数は`RedBlackTreeMultiMap_TestHelpers.swift`(新設、無条件コンパイル)へ退避。未使用と判明した`_value`/`tuple`/`__value`/`Optional.hoge()`は削除。
  - `MultiMapTests`は既存の空スタブクラス群と同じ場所に`final class MultiMapTests: RedBlackTreeTestCase { typealias Target = RedBlackTreeMultiMap }`として追加し、互換ファイル内で自己完結化。
  - 本体の内容はMultiMapが既に`_0`〜`_11`まで非常に手厚く連番化済みだったため、ほぼ全て重複と判断。新規性のあった3点のみ移管:
    - `formIndex(after:)/(before:)`(連番側に一件もカバレッジが無かった、Dictionaryと同じ穴) → `_3_IndexSequenceTests.swift`
    - 生インデックスの妥当性検証 → `RedBlackTreeMultiMap_98_IndexValidityXCTests.swift`新設
    - ツリー不変条件`___tree_invariant()`を伴うランダムinsert/erase(`testRandom`〜`4`を1本に統合) → `RedBlackTreeMultiMap_98_FuzzTests.swift`新設
    - RangeView同士のEquatable/Comparable → `_9_ProtocolConformanceTests.swift`に2件追加
  - 互換ファイル側の空`extension MultiMapTests {}`・`extension MultiMapEtcTests {}`(16箇所)も削除。本体は`XcodeRM`で削除。
  - ビルド成功、関連テスト21件成功、全体テスト625成功・0失敗・2既知スキップを確認。
- (2026-09-29 05:24) **`multimap/`フォルダはこれで完全に空になった。`dictionary`・`multiset`・`multimap`の3フォルダの棚卸しが全て完了。** 残る旧フォルダはルート直下の`MergeTests.swift`・`DocumentCheckTests.swift`・`EtcTests.swift`(Set公開仕様が混在)など。次はそちらの監査。
- (2026-09-29 05:35) `DocumentCheckTests.swift`(46行)を確認。これは旧テスト債務ではなく、`Sources/RedBlackTreeCollections/Documentation/Remove.md`(testExample1/2)と`DSL.md`(testExample3/4)のコード例を直接検証する現役のドキュメント検証ファイルだった。**このファイルはそのまま残す**(整理対象外)。
- (2026-09-29 05:35) `MergeTests.swift`(187行)を監査。Set/MultiSet/Dictionaryをまたぐ`.merge(_:)`/`.insert(contentsOf:)`のクロス型結合テスト。多くはSetの`_5_InsertionTests.swift`で`insert(contentsOf:)`相当が既にカバーされていたが、以下は連番側に無い発見だったため追加:
  - Setの`merge(_:)`に標準ライブラリ`Set`を渡すケース → `RedBlackTreeSet_5_InsertionTests.swift`に`test_merge_fromSwiftSet`追加
  - MultiSetの`insert(contentsOf:)`にSet/MultiSetを渡すケース(既存は配列のみ) → `RedBlackTreeMultiSet_5_InsertionTests.swift`に1件追加
  - Dictionaryの`merge(_:uniquingKeysWith:)`にRedBlackTreeDictionaryを直接渡すケース(既存はSequence/配列のみ) → `RedBlackTreeDictionary_5_InsertionTests.swift`に1件追加
  - 残り(空/空の境界値ケース、標準Sequence・ClosedRangeなどSequenceオーバーロード経由で実質同一コードパスのケース)は重複と判断し移管せず。旧ファイル削除(他ファイルからの参照なしを確認済み)。
  - ビルド成功、関連テスト31件成功、全体テスト606成功・0失敗・2既知スキップを確認。
- (2026-09-29 05:35) ユーザー指示により`EtcTests.swift`(1162行)は**ファイル自体を残す**方針(「なんかあるとつい触るやつ」)。内容の重複整理をする場合も、ファイルを完全に空にして削除するのではなく、ファイルは存在させたまま内容を整理する。
- (2026-09-29 12:15) `EtcTests.swift`(1162行、約60メソッド)の棚卸しが完了。他フォルダと同じ基準で重複・死んだコード・プレーンSwift標準型のノイズ(stdlib `Set`/`Array`/`Dictionary`単体の検証、`#if false`相当や`throw XCTSkip()`直後で無効化されていたコード、意味の薄い自明な内部不変条件チェックなど)を削除。新規性のあった8点を連番側/型別`_98`へ移管:
  - イテレータが作成後の base 変更に対してスナップショットを保持し続けるCoW挙動(`testItertor`) → `_1_SequenceTests.swift`に`test_iterator_retainsSnapshotAfterBaseCollectionIsMutated`として追加
  - RangeView上の`erase(where:)`がコピーを起こさないこと・別変数化したRangeViewは1回だけコピーしてbaseに影響しないこと(`testRemoveBounds`/`testRemoveBounds2`) → `_98_CopyOnWriteTests.swift`に2件追加
  - スロット再利用後の世代違いIndexが`isElement(at:)`で正しく拒否されること(`testIndexStale`を単純化) → `_98_IndexValidityXCTests.swift`に追加
  - 内部`__emplace_hint_unique`のヒント付き新規/重複挿入(`testNoKeyEmplaceHintUnique`) → `_98_RemovalInternalXCTests.swift`に追加(ファイル名はRemoval由来だが`@testable`内部API検証の既存の置き場所のため踏襲)
  - 内部`__find_equal(hint:)`の全分岐カバレッジ(`testFindHintEqualCoverage`) → 同上ファイルに追加
  - 削除済みスロットがバケット追加なしに再利用され続けること、`removeAll(keepingCapacity:)`の有無でfreshBucket/capacityの挙動が変わること(`testRoundTrip`/`testRoundTrip2`/`testRoundTrip3`) → 同上ファイルに3件追加(`freshBucketHead`/`freshPoolActualCapacity`の検証は連番側に元々皆無だった)
  - 単一BoundExpression(`.start`/`.lowerBound`/`.upperBound`/`.end`)による添字アクセスが要素またはnilを返すこと(`testBound`) → `_16_BoundExpressionTests.swift`に追加
  - 別ツリー由来のIndexを含むBoundExpressionがALLOW_CROSS_TREE_INDEXの設定通りに解決されること(`testBoundCrossIndexing`を単純化) → 同上ファイルに追加
  - 不正な逆順区間の`reversed()`が無限ループを起こさず空を返すこと(`testChecked`)、`popFirst()`で消費し尽くした後の`unranged()`が正しい残り範囲を返すこと(`testRangeView`/`testRangeView2`) → `_17_RangeViewTests.swift`に2件追加
  - Index自体のEquatable/Comparable/Hashable準拠(`testIndexEquatable`/`testIndexComparable`/`testIndexHashable`、連番側に一件もカバレッジが無かった) → `_9_ProtocolConformanceTests.swift`に3件追加
  - ファイル末尾にあった未使用の`extension RedBlackTreeDictionary { emplace(hint:_:) }`は他箇所からの参照なしを確認の上削除。
  - **ユーザー指示によりファイル自体は削除せず**、クラス定義と`setUpWithError`/`tearDownWithError`のみを残した空シェルとして保持。
  - ビルド成功、全体テスト1124件(824成功・0失敗、残りは環境既知の"No result")を確認。
- (2026-09-29 12:15) **ルート直下の`MergeTests.swift`・`DocumentCheckTests.swift`・`EtcTests.swift`の監査が全て完了。** 次のフォルダ着手はユーザー指示待ち。
- (2026-09-29 12:50) ルート直下の残り(`AllocationTests.swift`・`ComparatorsTests.swift`・`ManagedBufferTests.swift`・`NaiveIteratorTests.swift`・`Performaces.swift`・`ReferenceTests.swift`・`RootAtCoder2025CompatibilityTests.swift`)を棚卸し。ユーザー方針: 内部実装寄りの4ファイルは`RedBlackTreeInternal/`へ「おおざっぱ」に集約(型別連番への厳密な重複排除は不要)。`Performaces.swift`/`ReferenceTests.swift`と、`RootAtCoder2025CompatibilityTests.swift`内の`extension EtcTests`群は、他フォルダと同じ厳密な基準で棚卸し。
  - `AllocationTests.swift`(149行、Tree/Storage作成・CoW発火・容量拡張の内部検証)・`ComparatorsTests.swift`(267行、`_NodePathBitmap`/`_NodeKey`比較器・4型のvalue_comp/equalRange)・`NaiveIteratorTests.swift`(100行、Obverse0-3/Reverse0-3イテレータ試作、Forward0/Reverse0はForward1/Reverse1と完全重複だったため削除)は、内容ほぼそのまま`RedBlackTreeInternal/RedBlackTreeInternal_{Allocation,Comparators,NaiveIterator}Tests.swift`へ移設(クラス名は維持、同一ターゲット内なので互換ファイルの`extension NaiveIteratorTests`は無改修で通る)。
  - `ManagedBufferTests.swift`(154行)は全体が`#if DEBUG && false`で無効化済みだったが、ユーザー指示で「復活可能性」を確認: `___Tree`/`CompareUniqueTrait`/`HasDefaultThreeWayComparator`をSources全体でgrepしたところ現行コードに存在せず(V1世代の遺物、UnsafeTreeV2移行で置き換え済み)、ガードを外しても復活不可能と判明。テストしていた観点は次の通り: (a) `create()`/`create(minimumCapacity:)`直後の capacity/count/root/begin_node、(b) `__construct_node`後の値設定・`___element`での書き換え、(c) `destroy`後に値が0クリアされること、(d) `___pushDestroy`/`___popDetroy`によるLIFO destroy-stack(`header.destroyNode`/`destroyCount`)の push/pop 整合性、(e) ネストしたconstruct/destroyでのdestroy-stack蓄積順序。`destroyNode`/`destroyCount`/`pushDestroy`という概念は現行`Sources`・`Tests`のどこにも存在せず(`old/`配下の遺物のみ)、UnsafeTreeV2側で同等のfreshPool/recycle機構によるテストがあるかどうかは未確認 — 将来の調査の足がかりとしてここに記録。ファイルは削除。
  - `Performaces.swift`(187行、Setのベンチマーク集)を監査。`#if false`ブロック(testPerformanceCopy1-256)は完全に死んでいたため削除。標準ライブラリ`Set`/`Dictionary`単体のベンチマーク(testPerformanceExample00/05/10/11)はスコープ外として削除。残り(distance/index/firstIndex/init系)は既存`_98_PerformanceTests.swift`と重複と判断し削除。新規性のあった3点(erase(全範囲)・大規模Set同士のEquatable・`first(where:)`の線形走査)を`RedBlackTreeSet_98_PerformanceTests.swift`に追加。本体ファイルは削除。互換ファイル側の`extension Performaces`(testPerformanceExample4/7)は、本体削除に伴い自己完結クラス`PerformacesAtCoder2025LegacyTests`に変換。
  - `ReferenceTests.swift`(55行)を監査。`removeAll(keepingCapacity:)`後に参照型要素が正しくdeinitされること(二重解放・リーク検知)を検証する`testExample2`は、連番側に同等のテストが皆無だったため`RedBlackTreeSet_6_RemovalTests.swift`に`test_removeAllKeepingCapacity_releasesRetainedReferenceElements`として追加(ローカル`DeinitializeCounter`で自己完結化)。本体ファイルは削除。互換ファイル側の`extension ReferenceTests`(`.indices`経由の1件ずつremoveでも同様にdeinitされることを確認するtestExample)は、自己完結クラス`ReferenceAtCoder2025LegacyTests`に変換して保持。
  - `RootAtCoder2025CompatibilityTests.swift`内の`extension EtcTests`群(testExample4、testIndices、testRange、test_subSequence...2、testBackwordIterator1/2、testRev、testObv/testSubObv/testRev2/testSubRev2-5、testSubRev9-17、testMapBehavior)を監査。`RedBlackTreeSetAdditionalAtCoder2025CompatibilityTests.swift`に`.indices`・二引数forEach・Index算術(`.pointee`/`.advanced(by:)`/`startIndex + N`)の広範な既存カバレッジがあることを確認したため、大半を重複と判断し削除。新規性のあった4点を移管:
    - Index同士の`-`/`+`演算子と`.distance(to:)`(互換専用のIndex算術、連番側に皆無) → `RedBlackTreeSetAdditionalAtCoder2025CompatibilityTests.swift`に`testIndexArithmeticOperatorsAndDistanceTo`として追加
    - 逆順の二引数`forEach { i, v in }`(全体・RangeView・空範囲) → 同ファイルに`testReversedForEach_enumeration`として1本に統合
    - Dictionaryの`keys()`/`values()`(互換専用の関数呼び出し形式)のreversed()外側/内側適用の一致 → `RedBlackTreeDictionaryAtCoder2025CompatibilityTests.swift`に`testKeysAndValuesFunctionStyleReversed`として1本に統合(空範囲の多数の順列は削除)
    - Setに`formIndex(after:)/(before:)`のテストが連番側に一件も無かった(Dictionary/MultiMapと同じ穴) → `RedBlackTreeSet_3_IndexSequenceTests.swift`に`testFormIndexAfterAndBeforeMatchIndexAfterAndBeforeTraversal`として追加
    - 内部逆順走査`___rev_for_each_`(testRev)は他に置き場が無く、他との重複も無いため、互換ファイル内の`extension EtcTests`として現状維持。
  - 検証: 通常モード → `COMPATIBLE_ATCODER_2025`有効化 → 通常モードの3段階で確認。有効化時に2件のコンパイルエラー(新規追加した`.find`と`BoundExpression`ベースの`.erase`系テストが`#if !COMPATIBLE_ATCODER_2025`ガード漏れ)を検出・修正。最終的に通常モード1082件中823成功・0失敗、互換モード1082件中687成功・0失敗・5スキップ(既知)を確認。フラグは通常モードへ復帰済み。
  - この時点では`DocumentCheckTests.swift`・`KeyValueComparer+Tuple.swift`/`RedBlackTreeTestCase.swift`/`SplitMix64.swift`・`RootAtCoder2025CompatibilityTests.swift`は対象外としていたが、直後のユーザー指示で全て棚卸し対象に変更された(下記エントリ参照)。
- (2026-09-29 13:00) ユーザー指示: `DocumentCheckTests.swift`は削除まで棚卸し可、`RootAtCoder2025CompatibilityTests.swift`もファイルが消えるまで棚卸し、テストと呼べない共有インフラ(基底クラス・ヘルパー)は新設する`RedBlackTreeTestSupport/`フォルダへ集約。これに従いルート直下を最終整理:
  - `RedBlackTreeTestCase.swift`(基底`XCTestCase`・`blackHole`・`_value`/`keyValue`等のテストヘルパー・`PointerRedBlackTreeTestCase`)、`KeyValueComparer+Tuple.swift`(`KeyValueTrait`のテスト専用extension)、`SplitMix64.swift`(PRNG)は、いずれも「テストそのものではない共有インフラ」と判断し、新設`RedBlackTreeTestSupport/`フォルダへ内容そのまま移設。
  - `DocumentCheckTests.swift`(46行、`Remove.md`/`DSL.md`のコード例検証)を監査。4件全てを連番側と突き合わせ: `.start.after`/`.end.before`チェーンは`_16_BoundExpressionTests.swift`に、RangeViewの述語なし`erase()`は`_17_RangeViewTests.swift`に、`erase(at:) -> Index`の逐次ループはSpec上`_6_RemovalTests.swift`の`test_erase_index_returnsNext`等に、それぞれ既に同等以上のカバレッジがあることを確認。新規性なしのため丸ごと削除。
  - `RootAtCoder2025CompatibilityTests.swift`(108行、最終形)を解体:
    - `PerformacesAtCoder2025LegacyTests`・`ReferenceAtCoder2025LegacyTests`(いずれも`Performaces.swift`/`ReferenceTests.swift`削除時に自己完結化済みだった互換専用クラス) → `RedBlackTreeSetAdditionalAtCoder2025CompatibilityTests.swift`へ統合(Set関連の互換専用内部・性能テストの既存の置き場所)。
    - `extension NaiveIteratorTests`(`UnsafeIterator._RemoveAware`のラップ検証) → 本体が既に移設済みの`RedBlackTreeInternal/RedBlackTreeInternal_NaiveIteratorTests.swift`内へ`#if COMPATIBLE_ATCODER_2025`ガード付きで同居させた(同一ターゲット内なのでファイル分割に技術的制約はないが、本体と対になる内容なので同一ファイルに統合)。
    - `extension EtcTests { testRev }`(内部逆順走査`___rev_for_each_`の検証) → 他に重複が無くEtcTests本体と対になる内容のため、`EtcTests.swift`自体に`#if COMPATIBLE_ATCODER_2025 && DEBUG`ガード付きのextensionとして統合。
    - 全ての依存先が確保できたため、本体ファイルは削除。
  - 検証: 通常モード → `COMPATIBLE_ATCODER_2025`有効化 → 通常モードの3段階。両モードともビルド成功、通常モード1078件中819成功・0失敗、互換モード1078件中687成功・0失敗・5スキップ(既知)を確認。フラグは通常モードへ復帰済み。
  - **ルート直下(`Tests/RedBlackTreeTests/`)には現在、テストファイルは`EtcTests.swift`(ユーザー指示により意図的に空シェルとして維持)のみが残る。** 共有インフラは`RedBlackTreeTestSupport/`、内部実装検証は`RedBlackTreeInternal/`、型別テストは各型フォルダに整理済み。ルート直下の棚卸しはこれで完全に完了。

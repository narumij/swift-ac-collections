> [!NOTE]
> これは2026-10-03時点の旧 `TESTING.md` を保存した参照資料です。
> 通常の開始時には通読せず、現在情報は `Tests/TESTING.md` を参照してください。
> 新しい引き継ぎや作業ログをこのファイルへ追記しないでください。
> 2026-10-06に`Tests/Archived/`へ移動しました。

<!-- CodexとClaudeによるCodexとClaudeのためのメモ -->

# Tests maintenance notes

現在の記載内容は主に `RedBlackTreeTests` を対象にしている。将来的に他のテストターゲット
(`BareArrayModuleTests`/`OptionalArrayModuleTests`/`PermutationTests`等)も対象に含める
想定で、2026-10-01に配置場所を `Tests/RedBlackTreeTests/TESTING.md` から `Tests/TESTING.md`
へ移動した(相談事項「この文書の配置場所をTests直下に切り替えたい」に対応)。

## User requests for the next session

リセット待ち・休憩中に、次回の作業で優先してほしい内容をユーザーが書く欄。この欄に記載がある場合、Codex及びClaude は `Current handoff` より先に読み、最新のユーザー要望として優先する。完了した項目を CodexやClaude が勝手に削除せず、完了したことを追記するか、ユーザー確認後に整理する。

記入例:

- 最優先で扱うフォルダまたはファイル
- 残してほしいテスト、削除してよい重複
- Swift Testing / XCTest / compatibility の配置に関する希望
- テストが通った時点で止める、残量何%で休憩する、といった停止条件
- 次回まで保留した判断や気になっている破損

<!-- ユーザー記入欄: この下へ追記 -->

### ビジョン

- 作業都合で書き散らかしたテストコードをAI達に整理整頓してもらう日常にしたい
- AI達が追加したテストコードで仕様不備やバグが発見できるとなおよい

### 優先事項
(完了したらClaudeやCodexが完了済みの要望に移動してください）

- 2026-10-02 21:04 JST ユーザー要望（Claude優先）: 赤黒木の整理待ちや手空きのときは、赤黒木以外の`OptionalArrayModule`、`BareArrayModule`、`PermutationModule`、および`AcCollections`公開facadeのテストレビューを自発的に進める。「既存テストが成功する」だけで完了とせず、公開API一覧と実装を基準に、正常系・空・下限/上限・不正Index・参照型の寿命とCoW・Sendable/Codable・Debug/Release差・Death Testの不足を棚卸しする。見つけた仕様疑問や実装懸念は推測で修正せず本ユーザー記入欄の`保留中の判断・懸念`へ追記し、仕様が確定できる不足はTest as Specificationとして補う。そのターンでコード修正まで依頼されていない場合は、先にレビュー結果と優先順位を残す
- メイン担当は定期的にこの文書確認する癖をつけること
- この文書を正しく保つため、ClaudeさんやCodexの作業成果を加味してClaudeさんやCodexさんが都度更新すること（毎回）
- Fixtureの変化を把握し、Fixture.mdに反映すること(Claude)(毎回)

### 相談事項

- Current handoffが膨大になってきました。直近の作業と、現在の状況ぐらいでいいのではないでしょうか？
- テストを軸としたコードメンテはそのうち他のターゲットも対象になるので、この文書の配置場所をTests直下に切り替えたい(Claude優先) → 2026-10-01 Claudeが`Tests/TESTING.md`へ移動済み。他の参照(CI workflow・README等)は`grep`で確認したが本文書への既存参照は無く、リンク切れは発生していない。内容は未改訂(タイトル直下に移動の経緯のみ追記)。完了済みの要望へ移動してよいか確認願います。

### 連絡事項

- ABC, convenience, memoizeは温存
- 実験的なテストコード書く場合、人もAIもまずEtcTests.swiftまたはDeathTest.swiftに書くこと
- 5時間上限または週間利用上限で止まるとき、それまでの作業の感想も教えて欲しい
- 最後に作業したモデルはモデル名とバージョンをどこかに記載すること
- Codexさんはふりかえりの時間を確保すること
- Claudeさんは始業時に会話の時間を確保すること
- 小さな変更を積み重ねてるときは互換チェックをさぼっていい
- 2026-10-01: XcodeのMCP `RunAllTests`が、実際には数百件のテスト(例: `BufferHeaderTests`等)を実行せず"No result"のまま"0 failed"と返す不具合を確認。全体テストの合否判定は`swift test`(CLIコマンド)を正とすること。カバレッジの精査も`swift test --enable-code-coverage`+`xcrun llvm-cov show/report`の方が信頼できる
- 内部構造をどのように区分するのか、勝手に判断しないこと
- ユーザー記載欄に記入する場合、こちらが消す都合上、古さが分からないと困るので、日付に加えて時間も記載すること
- 現行APIかどうか判断に迷った場合API-Matrix.md及びAPI-Matrix-View.mdに照らすこと
- カバレッジが落ちてきてるので横展開と合わせてカバレッジ改善（90%目安)
- Test as Specで一応の品質は保てるが、言語や環境の挙動変更による影響やマジックナンバー等の取り扱いミスを検出できるようにする必要もある
- RedBlackTreeTestSupportとDebugAdditionalsの責務境界は`Tests/TESTING.md`に確定済み。
  自動テスト用基盤と人間向け診断・凍結コードを目的で分け、既存2ファイルだけを配置例外とする。
- 横展開の過不足についてはSources/RedBlackTreeCollections/Documentation/API-Matrix.mdと照らし合わせること
- Test as SpecについてはSources/RedBlackTreeCollections/Documentation/Quality-Checklist.mdと照らし合わせること
- テストコード生成時はTests/RedBlackTreeTests/Fixtures.mdを参照し、フィードバックすること
- 内部テストをどのように整理するかについては引き続き検討中
- 原木のテストはやれるだけやって構わない
- 生バッファのテストもやれるだけやって構わない
- Current handoffの年代順ログが膨大になってきたのでそのうち手動で消します。消されてもこまらないよう準備してください

### 停止条件

- 2026-10-02 21:06 JST ユーザー要望: テストメンテナンス全体を完了扱いにする最上位条件は、CodexとClaudeがそれぞれ独立に内容をダブルチェックして双方がOKと判断し、その確認結果にユーザーが納得していること。一方のAIの完了申告、テス失敗0、またはカバレッジ数値だけで全体完了としない。個別カテゴリは区切りとして完了記録してよいが、独立確認とユーザー確認が済むまで再レビュー可能な状態を保つ
- Codexの場合、利用上限が少ないセッションでは、新しい大きなカテゴリへ着手する前に、全体テスト・文書更新・振り返りに必要な余裕を確保する。

### 保留中の判断・懸念

- 内部構造をテスト観点でどのように区分するのか、まだ結論がでていない
- 生木へのテストを増やすと変更コストがかさむので、バランスに悩んでいる
- `Tree/Fixture/UnsafeNodeReferenceFixture.swift`・`UnsafeTreeV2/Instance/RawBufferHeadFixture.swift`・`UnsafeNodeRawBufferCrossCheckTests.swift`(2026-10-01新設)は、`MemoryLayoutTests`/`UnsafeNodeMemoryLayoutTests`/`BucketAllocatorTests`の既存`checkXxx`ヘルパー・payload型リストと意図的に重複している。ユーザー方針「一旦多重化して、あとで整理しましょう」により統合はまだ行っていない
  - 2026-10-03 Claude (Sonnet 5)調査: 行数は`UnsafeNodeReferenceFixture.swift`47行・`RawBufferHeadFixture.swift`51行・`UnsafeNodeRawBufferCrossCheckTests.swift`105行(計203行)、既存側は`MemoryLayoutTests.swift`112行・`UnsafeNodeMemoryLayoutTests.swift`143行・`BucketAllocatorTests.swift`452行(計707行、6ファイル合計910行)。実態は「コードの重複」ではなく「関心の重複」で、各ファイルが検証する層が異なる: 既存3ファイルはそれぞれ単一の層(`UnsafeNode`参照計算のみ/`UnsafeNode`のpayload込み計算のみ/`_BucketAllocator`の確保サイズのみ)を単独で検証するのに対し、新設側は`UnsafeNodeReferenceFixture`(参照計算)と`RawBufferHeadFixture`(`_BucketAllocator`/`_Bucket`経由の実計算)の両方を同時に構築し、pairStride・各要素のノード/payloadオフセットが2つの独立した計算経路で一致することを横断検証する(既存側にはこの層横断の一致確認が無い)。そのため新設側は既存側の単純な重複ではなく、既存側が検証していない「2層の整合性」を追加している。統合する場合は、既存3ファイルの単層検証をどちらのFixtureに寄せるか(または両方残すか)がユーザー判断待ち。

- 2026-10-02 00:15 JST: `unranged()`はユーザーより「廃止検討中」と判明(`API-Matrix.md`の該当行へ「廃止検討中」を追記済み)。今回MultiSet/Dictionaryの`_8_RangeViewTests.swift`へ追加した`test_unranged_returnsRemainingBaseRangeAfterDrainingPartially`(Set/MultiMap側の既存テストと同種)は、現行APIである間は妥当なTest as Specとして残すが、`unranged()`自体が廃止される場合は4型分(Set/MultiSet/MultiMap/Dictionary)のテストもまとめて削除対象になる

### 完了済みの要望
(ユーザーが確認したら各項目を削除します)

- 2026-10-03 Claude (Sonnet 5): 2026-10-02 16:24 JST保留事項・2026-10-01 07:11 JST登録課題2点目(MultiMapのhint付きinsertが同値キー群内の順序に与える影響が未確定)に対応。ユーザー指示「C++にならう」を受けて実機調査した結果、`__emplace_hint_multi`/`__find_leaf`は元々LLVM libc++の`std::multimap`/`std::multiset`のhint挿入アルゴリズムを直接移植したもので、**hintが有効(隣接)な場合はhintが示す位置そのものへ挿入する**ことを確認した(`EtcTests.swift`での実験: `[(1,a),(1,b),(1,c)]`に"b"を指すhintで(1,"X")を挿入すると`[(1,a),(1,X),(1,b),(1,c)]`になり、末尾ではなく途中に入る)。これはC++の`std::multimap::insert(hint, value)`と同じ挙動で、通常の`insert(_:)`(常に同値キー群の末尾へ追加)とは異なる。MultiMap・MultiSetそれぞれの`_5_InsertionTests.swift`へ`test_insertWithHint_placesNewPairAtHintPositionWithinEquivalentKeyGroup`/`test_insertWithHint_placesNewMemberAtHintPositionWithinEquivalentGroup`を追加し、この挙動をTest as Specとして固定した。全体テスト0失敗。
  - **Codexへの引き継ぎ**: `RedBlackTreeMultiMap.insert(_:hint:)`と`RedBlackTreeMultiSet.insert(_:hint:)`の現行`///`コメントには「An incorrect hint doesn't change the result; it can only affect performance.」とあるが、これは同値キー/要素群内の順序に関しては**事実と異なる**(上記テストの通り、hintは順序に影響する)。コメントの表現修正はDocC領域のためClaudeからは行わず、今回追加したテストを根拠にCodex側で修正願います。

- 2026-10-03 Claude (Sonnet 5): 優先事項(Claude優先)「赤黒木が手空きのときはOptionalArray/BareArray/PermutationModule/AcCollectionsのテストレビューを進める」に対応し、`OptionalArrayModuleTests`を「Test as Specとして十分か(=Codexがこれを基にコメントドックを書けるか)」の観点でレビューした。発見した問題と対応:
  - **テストファイル全体が`#if DEBUG`+`@testable import`で囲われており、Releaseビルドでは実質0件テストだった**。使用APIは全て`public`で`@testable`が元々不要だったため、`import OptionalArrayModule`に変更して`#if DEBUG`も撤去。これにより副次的に**`OptionalArray1DView`/`2DView`/`3DView`の`indices`プロパティに`public`が付いていない**実バグが露出(コンパイルエラーとして発覚)。`BareArrayModule`側は同じ`indices`が全部`public`済みだったため、こちらだけの漏れと判明。両方修正し、`swift build`/`swift test`をDebug/Release両方で確認した。
  - `Package.swift`の`OptionalArrayModuleTests`に`swiftSettings: _settings`を追加し`DEATH_TEST`を配線(`BareArrayModuleTests`と同じ対応)。`OptionalArrayDeathTests.swift`を新設し、`OptionalArray1D`本体と`2D`/`3D`/`4D`経由の各Viewで、負インデックス・上限超過の読み書きが正しくトラップすることを検証(7件、Debug/Release両方で成功)。
  - 参照型要素のライフタイムは従来`OptionalArray1D`の直接subscriptしか検証されていなかった。`OptionalArray1DView`(別実装の`.move()`パターン)経由の上書き・nil代入・親配列`removeAll()`、および`OptionalArray2D`/`3D`自身の`removeAll()`・スコープ外deinitを`DeinitializeCounter`類似パターンで追加検証(新規バグなし)。
  - 全体テスト0失敗(`swift test`/`swift test -c release`)。`PermutationModule`はユーザー方針で対象外(構造判断が先のため)、`AcCollections`facadeのレビューは未着手。
- 2026-10-03 00:40 JST Codex (GPT-5): 4型の`customMirror`についてCodex・Claudeの独立レビューとユーザー確認が完了。追加済みTest as Specificationにより、display style、ラベルなしの子、Set系の要素型、Dictionary系の`(key:value:)`tuple、multi型の重複する各出現、空時の子0件を固定した。MultiSetの`.set`、MultiMapの`.dictionary`は最も近い既存display styleとして維持し、子の順序は公開仕様に含めない。

### 内部区分

(テスト用区分であり、ソースのフォルダレイアウトを規定するものではない）

#### `__tree`移植層

`Sources/RedBlackTreeCollections/Implements/__tree`に配置されているもの

#### `__tree`基本層

`__tree`移植層のうち、
Fixture構成にAllocationInterfaceとDellocationInterfaceのメソッドが不要なもの、
かつUnsafeMutablePointerが不要なもの

#### `__tree`応用層

`__tree`移植層のうち、
Fixture構成にAllocationInterfaceとDellocationInterfaceのメソッドがが必要となるもの
かつUnsafeMutablePointerが不要なもの

#### 生ポ層(仮名)

`Sources/RedBlackTreeCollections/Implements/__tree`のうち、
実際の挙動を実現しているもの。
現在はUnsafeMutablePointerをベースにしている

#### 生メモリ層(仮名)

生メモリ操作を伴うもののうち、`__tree`移植層に含まれないもの

#### 生バッファ層(仮名)

生メモリ層のうち、木の生メモリを管理するもの

#### 生木層(仮名)

生メモリ層のうち、木を形成しているFacade及びその内部のもの

#### (なんかいい名前ください)層(仮名)

IndexやRangeやIteratorの内部に該当するもの

#### View層（外部）(仮名)

MutableSubrangeを実現しているもの

#### 4型層（外部）(仮名)

Set,MultiSet,MultiMap,Dictionary

<!-- TBD -->

### 用語

原木 -> `__tree`
生木 -> UnsafeTreeV2
生バッファ -> RawBufferのソースファイル群
材木 -> 4型

<!-- ユーザー記入欄ここまで -->

## Test as Specification

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

### テストの観点チェックリスト

テストを書く/レビューするときに意識する「観点」を、見つかった都度一行で追記する。

- 参照型要素のライフタイム(二重解放・リーク): `DeinitializeCounter`パターン(class+static count)で検証
- CoW分岐後は片方から削除してもインスタンスは解放されない(もう片方がまだ参照): 期待値を間違えやすい

### メモリリーク・二重解放の確認方法

参照型要素(`class`)を保持させたときの過剰解放(二重解放)・リークは、`swift test`実行だけでは
検出されない(値型要素だけのテストでは症状が出ない)。`DeinitializeCounter`パターンで明示的に
検証する。

```swift
final class DeinitializeCounter {
  nonisolated(unsafe) static var count = 0
  init() { Self.count += 1 }
  deinit { Self.count -= 1 }
}

var container = RedBlackTreeDictionary<Int, DeinitializeCounter>(
  uniqueKeysWithValues: (0..<4).map { ($0, DeinitializeCounter()) })
XCTAssertEqual(DeinitializeCounter.count, 4)

// 検証したい操作(削除・上書き・CoW分岐・subscript代入など)
_ = container.popFirst()

XCTAssertEqual(DeinitializeCounter.count, 3)
```

- `XCTAssertEqual(count, 期待値)`を完全一致で書く。期待値より少なければ過剰解放(または
  二重解放でクラッシュ)、多ければリークとして、どちら方向に崩れても検出できる。
  「片方だけ見て片方を見落とす」設計にはしない。
- CoW分岐がある操作では、分岐後も両コピーが同じインスタンスを参照し続ける間は解放され
  ないので、期待値は「両コピーが破棄された後」まで含めて計算する([[テストの観点チェック
  リスト]]のCoW項目も参照)。
- 比較・ソート用に値が必要な場合は`Comparable`適合させた`DeinitializeCounter`を使う
  (`num`プロパティ等で比較、`init`/`deinit`でのcount操作は共通)。
- 参考実装: `RedBlackTreeSet_6_RemovalTests.swift`・`RedBlackTreeDictionary_6_RemovalTests.swift`・
  `RedBlackTreeMultiSet_6_RemovalTests.swift`・`RedBlackTreeMultiMap_6_RemovalTests.swift`・
  `RedBlackTreeSet_15_ValueSemanticsTests.swift`(CoW版)・`BareArrayTests.swift`/
  `OptionalArrayTests.swift`(配列モジュール版)。
- CIの`address-sanitizer`ジョブ(`.github/workflows/swift.yml`)は`ASAN_OPTIONS: detect_leaks=0`
  でリーク検出を無効化している(Swiftランタイム側のグローバルキャッシュ等での誤検出を避ける
  ため)。つまりASanは二重解放・use-after-freeは検出できるが、リークの検出手段としては
  機能していない。リークの検出は実質的にこの`DeinitializeCounter`パターンに依存している。

### 旧フォルダ監査時の内部/外部トリアージ

旧フォルダのファイルを1つずつ判定するときは、まず次の3種類に分ける。

- **外部テスト**: `@testable import` を使わず公開 API のみで検証しているテスト。他フォルダと同じ厳密さで連番側/型別 `_98_*` と重複確認し、新規性があれば移植する。
- **テストサポート**: `func test...` を1件も持たず、`isValid`/`_copyCount`/`___tree_invariant` のようなテスト専用 extension、フィクスチャ、アサーションヘルパーだけのファイル。`RedBlackTreeTestSupport/` へ内容そのまま移設する（型別に分ける必要はない）。紛らわしい `...Tests.swift` という名前がついている場合は `...Support.swift` などへ改称してよい。
- **内部向けテスト**: `@testable import` を使い `___` 接頭辞の内部 API や生ポインタを直接検証しているテスト。ユーザーから明示的な指示がない限り後回しにする。複数型にまたがる internal 実装テストを整理する場合は `RedBlackTreeInternal/` へ集約してよいが、型別連番と同じ厳密な重複排除までは求められていない（「おおざっぱ」で足りる）。

`#if DEBUG && false` や `#if false` で無効化されたコードは、削除前に依存する型・API が現行 `Sources` に残っているか `grep` で確認する。残っていなければ「復活不可能」と判断してよいが、削除前にどんな観点を検証していたかを `Current handoff` へ要約してから削除する（残っていれば別ファイルへ移設のうえ復活を検討する）。似た名前のテストが `unsafeTree/`・`old/` 配下に現役で存在する場合は、旧版が既に移植済みの遺物である可能性を確認してから削除する。

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

## 原木カバレッジの測定

原木カバレッジは、専用ターゲット`Tests/RedBlackTreeTreeTests/`のテストだけを実行し、集計対象を
`Sources/RedBlackTreeCollections/Implements/__tree`だけに限定した値とする。リポジトリルートで
次を実行する。

```sh
swift test --disable-sandbox --enable-code-coverage --filter RedBlackTreeTreeTests
```

実行ログ末尾で、通常XCTest 122件とSwift TestingのDeath Test 28 casesが成功したことを確認する。
Xcode MCPの`RunAllTests`には実行漏れを成功扱いする
既知の問題があるため、この測定ではCLIの`swift test`を正とする。この環境ではSwiftPMの入れ子sandboxを
避けるため`--disable-sandbox`も必要。

テスト成功後、次のコマンドで原木だけのファイル別・合計カバレッジを表示する。

SwiftPMがexportしたcoverage JSONの場所自体は、次で取得できる。

```sh
swift test --disable-sandbox --show-codecov-path
```

ただし、このパッケージには複数のtest productがある。2026-10-02の実測では、返された単一JSON
`swift-ac-collections.json`には最後に処理された`BareArrayModuleTests`側の3ファイルしか含まれず、
`RedBlackTreeTests`の原木ソースは含まれなかった。JSONを使う場合は最初に`.data[0].files[].filename`
を確認すること。原木測定では、対象test bundleを明示できる次の`llvm-cov report`を正とする。

```sh
xcrun llvm-cov report \
  .build/out/Products/Debug/RedBlackTreeTreeTests.xctest/Contents/MacOS/RedBlackTreeTreeTests \
  -instr-profile=.build/out/Products/Debug/codecov/default.profdata \
  -ignore-filename-regex='Tests/' \
  Sources/RedBlackTreeCollections/Implements/__tree
```

未到達行を調べる場合は`report`を`show`へ替え、末尾へ対象ファイルを指定する。

Swift Testingの`#expect(processExitsWith:)`は停止契約の検証に使える。現行のSwiftPM CLI測定では、
SIGTRAPで停止する子プロセスの当該行は`default.profdata`へ加算されず、
`.build/out/Products/Debug/codecov/`に残る`*.profraw`を手動でmergeしても結果は変わらなかった。
そのためCLIの原木行カバレッジではDeath Testの成功を別の指標として扱う。Xcodeのcoverage表示で
assert行が実行済みになる場合は、それを停止経路の到達確認として併用してよい。

### Claudeによる原木完了確認手順

Codexが原木カバレッジ作業を完了扱いにした後、Claudeは次を独立に確認する。過去ログの数値を
転記するだけでなく、現在のworktreeで再実行すること。

1. `git diff --check`が成功することを確認する。
2. `swift test --disable-sandbox --enable-code-coverage --filter RedBlackTreeTreeTests`を実行する。
   通常XCTest 122件と`TreeFoundamentalDeathTests`が失敗0であることを確認する。Swift Testingの
   parameterized testはトップレベル件数とは別に20 casesを持つため、詳細ログも確認する。
3. 上記の`xcrun llvm-cov report`で原木だけを集計する。2026-10-02 14:00 JST時点の基準値は
   98.34%(2009/2043行、未達34行、5ファイル)。値が変わった場合は改善・退行のどちらかを
   ファイル別に説明する。
4. Xcodeで`TreeFoundamentalDeathTests`の9 test declarationsを実行し、parameterized case込みで
   28件成功すること、および対象assert/fatal行がcoverage画面で塗られることを確認する。
5. CLI未達34行の内訳を`llvm-cov show`と`llvm-cov export`で再確認する。現時点では33行が
   Death Test対象(`unsafe_node+pointer+compare` 9、free pointer algorithm 5、protocol algorithm 15、
   `_SealedTag` 4)、残りは`unsafe_tree+find.swift`にある同名2メソッドの末尾で、CLIでは
   source mapping上1行として集計される。通常実行可能な
   未テスト経路が新たに見つかった場合は
   完了とせずテストを追加する。
6. Sourcesをcoverage表示だけのために変更していないこと、Death Testが通常テストと別ファイルに
   保たれていること、range専用`___emplace_hint_right`を汎用経路で使っていないこと、主fixtureの
   `~Copyable`およびstatic/Base・Baseなしinstance比較注入の両経路が維持されていることを確認する。

完了判定は「CLI表示100%」だけを条件にしない。通常到達可能な行がCLIで実行済み、停止経路が
Death Test成功かつXcodeで到達確認済み、残りが上記同名2メソッド末尾のsource mappingだけなら、
原木テストは実質100%として完了確認してよい。

```sh
xcrun llvm-cov show \
  .build/out/Products/Debug/RedBlackTreeTreeTests.xctest/Contents/MacOS/RedBlackTreeTreeTests \
  -instr-profile=.build/out/Products/Debug/codecov/default.profdata \
  Sources/RedBlackTreeCollections/Implements/__tree/unsafe_tree/unsafe_tree+find.swift
```

`.build`の構成やSwiftPMの出力先が変わった場合は、`default.profdata`と
`RedBlackTreeTreeTests.xctest/Contents/MacOS/RedBlackTreeTreeTests`の実在パスを確認して読み替える。

## 原木fixtureとnoncopyable対応

原木fixtureは、将来`__tree`でnoncopyable要素を扱う可能性を妨げない形で保守する。Claude・Codexを
含む作業者は、コンパイルを通す目的でfixtureやpayloadへ安易に`Copyable`制約を追加しない。

- fixture自身の`~Copyable`適合を維持する。コピーが必要に見える場合は、先に所有権と借用範囲を見直す。
- payloadを読み出してコピーすることを前提にせず、生メモリ上でのinitialize・borrow・deinitializeを基本とする。
- `~Copyable`な値をtuple、配列、escaping closureなど、暗黙のコピーや寿命延長を要求する場所へ退避しない。
- 生メモリの所有権はfixtureへ集約し、初期化済みのNodeとpayloadだけを各一回deinitializeしてから解放する。
- Node/payloadのalignment、stride、先頭Node、必要byte数は`UnsafeNode`の参照レイアウトAPIを使い、
  fixture側へ同じ計算式を複製しない。
- テスト専用protocol適合を追加するときも、値返却によるpayloadコピーが本質でない場合は、ポインタまたは
  借用アクセスで検証できないかを先に検討する。
- 現在のpayload型が`Copyable`であることだけを理由に、将来noncopyable payloadでは成立しないAPIを
  fixtureの標準操作として固定しない。

一時的に`Copyable`が必要なテストを追加する場合は、その制約がテスト対象の仕様なのか、テスト実装上の
都合なのかをコメントで区別する。後者の場合はfixture全体へ制約を波及させず、対象テストまたは補助型へ
局所化する。

## Safe migration workflow

長時間の整理を壊れた状態で残さないため、次の単位を守る。

1. 旧テストと現行 API を比較する。
2. API の一カテゴリだけ連番側へ移す。
3. Xcode のファイル診断でコンパイルエラーを確認する。
4. 全テストを実行し、失敗が 0 であることを確認する。
5. コミット可能な状態になってから次のカテゴリへ進む。

テスト数は、重複ケースの統合や旧ファイル削除で減ることがある。件数ではなく、公開仕様の欠落がないことと全テスト失敗 0 を基準にする。

互換ファイル(`*AtCoder2025CompatibilityTests.swift`)側の内容に変更が及ぶ場合は、`Package.swift` の `COMPATIBLE_ATCODER_2025` を一時的に有効化してビルド・テストを確認する。確認順は 通常モード → 互換モード有効化 → 通常モードへ復帰 の3段階で十分（互換確認後に再度全テストを流す必要はない）。小さな変更を積み重ねているだけのときはこの互換確認を省略してよい。

長時間のセッションでは、残量 10% 付近で新しいカテゴリへの着手を止める。最後の 5% は、全体テスト、`Current handoff` の更新、次回の開始地点の明記、コミット可能な状態の確認に使う。作業量を増やすためにこの振り返り時間を使い切らないこと。

## Current handoff

- 2026-10-03 00:32 JST Codex (GPT-5): Claude作業後の4マトリクス（現行/AtCoder 2025互換 × Debug/Release）について、各セルで`swift build --disable-sandbox`と`swift test --disable-sandbox`を実行した。初回は、追加された`EtcTests.testDecodeEmptyArrayUsesReadOnlySingleton`がReleaseではinternal `isReadOnly`へアクセスできず、互換Debugでは4型が`Decodable`非適合でテストターゲットのコンパイルに失敗した。内部実装の副次確認というテスト目的に合わせて`#if DEBUG && !COMPATIBLE_ATCODER_2025`へ限定し、再確認後は4セルすべてビルド・全テスト成功。互換フラグは確認後に元の無効状態へ戻した。既存のdeprecated API使用等の警告は残るが、新規エラーはない。

### 整理状況サマリー
(このサブセクションはスナップショットとして毎回上書きしてよい。詳細な経緯は下の年代順ログを参照)

- **Test as Spec 整理**: Set・MultiSet・Dictionary・MultiMap は型別フォルダで連番 Test as Spec 化が完了。`RedBlackTreeView/`(`RedBlackTreeMappedValuesView`・`RedBlackTreeKeyValueRangeView`・`RedBlackTreeKeyOnlyRangeView`)も同様に連番整理済み。`BoundExpression` も4型とも `_16_BoundExpressionTests.swift` へ移管済み。
- **原木層**: 2026-10-02にCodexが専用`RedBlackTreeTreeTests`ターゲットへ分離を完了。`Fixture/TreeNodeOnlyFixture.swift`・`TreeOwnedNodeFixture`(いずれも`~Copyable`維持)で実ポインタ直接検証を行い、static/Base比較注入とBaseなしインスタンス比較注入の二経路を両立させている。通常XCTest 119件・Death Test 26 casesが全成功。行カバレッジは段階的に67.98%→97.98%まで積み上げ、debug assert群の`#if false`化による対象行数の見直し後は98.34%(2009/2043行)。残る未達行はDeath Testで到達させる停止経路と、閉じ括弧等のsource mapping表示制約のみで、通常到達可能な行の塗り漏れは無いと確認済み(Codexのregion全件監査+2026-10-02 05:00 JST Claudeの独立確認手順の両方で裏取り済み)。共有`UnsafeNodeReferenceFixture`は独立`RedBlackTreeFixture`ターゲットへ移動。2026-10-03にユーザーの目視確認も完了し、**本項目は完了ステージ**(詳細な増分ログはここで圧縮済み、経緯が必要な場合はgit historyを参照)。原木作業は当面Codexが継続担当、別担当が触れる場合もrange専用APIの前提・`~Copyable` fixture・比較注入の二経路維持に注意すること。
- **カバレッジ**: 2026-10-01時点で`Sources/RedBlackTreeCollections`全体は`swift test --enable-code-coverage`+`llvm-cov`基準で約90%。残る未カバー行の大半は「未結線/削除判断待ちコード」に集約されている(次項)。
- **未結線・削除判断待ちコード一覧**(いずれもSources内で呼び出しゼロと確認済み。削除するかテストを書くかはユーザー判断待ち):
  - `Implements/Iterator/UnsafeIterator/UnsafeIterator+Reverse4.swift`(`_Reverse4`)、および同系列の`UnsafeIterator+CopyOnWrite.swift`の`reversed()`/`init(_source:tree:)`・`+KeyValue.swift`の`keys()`/`values()`
  - `Implements/UnsafeTreeV2/UnsafeTreeV2+Update.swift`(`swap_key`/`swap_mapped_value`)
  - `Implements/Misc/Message.swift`の`outOfRange`/`keyMismatch`
  - `UnsafeTreeV2+BufferHeader.swift`の`payloadLayout`/`__root_ptr()`
  - `RawRange/UnsafeTreeV2+RawRange.swift`の`contains(range:pointer:)`(3オーバーロード)
  - `tree_basic+tag.swift`の`_TrackingTag.retire`
- **直近の主要な修正**(2026-10-01): `RedBlackTreeMultiMap.index(inserting:)`が`__insert_unique`を誤って呼んでいた実バグを修正。「削除系メソッドは空/未発見でもトラップせずに無駄なCoWを起こしてはいけない」という原則の横展開で、`erase(exactly:)`・両View系列・4型`popFirst`/`popLast`等・`removeAll(keepingCapacity:)`の計10箇所超を修正。
- **UnsafeNode(原木) vs RawBuffer クロスチェック**(2026-10-01、2026-10-02配置更新、2026-10-05責務確定): `UnsafeNode._advanced(with:count:)`と`_BucketAllocator`/`_Bucket`が同じメモリ配置を導くことを検証。双方から使う`UnsafeNodeReferenceFixture`は共有`RedBlackTreeFixture/UnsafeNodeReferenceFixture.swift`へ、RawBuffer側の`RawBufferHeadFixture`とクロスチェック本体は`RedBlackTreeTests/UnsafeTreeV2/Instance/`へ配置している。単層テストの期待値算術とfixtureを共有するとfault independenceを失うため、既存helper・payload matrixとの重複は意図的に維持する。層ごとの検出対象は`Tests/TESTING.md`に記録した。
- **ツール注記**: XcodeのMCP `RunAllTests`が実行漏れを"0 failed"と誤表示する不具合を確認済み。全体テストの合否は`swift test`(CLI)、カバレッジは`swift test --enable-code-coverage`+`xcrun llvm-cov`を正とする。

### 年代順ログ
- Set・MultiSet・Dictionary・MultiMap の旧フォルダ(`set`/`multiset`/`dictionary`/`multimap`/ルート直下の雑多ファイル)は棚卸しが完了し、現行仕様は型別連番、内部実装・性能・fuzzは型別`_98_*.swift`、互換仕様は型別compatibility fileへ移管済み。旧フォルダ・旧ファイルは残っていない。
- `RedBlackTreeInternal/`・`unsafeTree/`配下は「実際に使っているFixture種別」(Synthetic/Base/Instance)でサブフォルダ分け済み。
- `Legacy/`は`ArrayBased/`(V0の純粋ジェネリック`_NodePtr`アルゴリズム+`_TrackingTag`結線、「配列だけで赤黒木が動く証拠」)・`ArrayBased/ThreeWay/`・`ArrayBasedFixture/`(V0 Fixture+テスト)の構成で確定済み。内部で分類はしてよいが、公開API境界には染み出させない制約は継続する。
- 現行`UnsafeTreeV2`/`RedBlackTreeSet`向けの人間用デバッグ支援(dump/Graphviz)はLegacyではなくトップレベル`DebugAdditionals/`が最終的な置き場所。自動テストから呼ぶTesting拡張は原則`RedBlackTreeTestSupport/`とし、既存の配置例外は`Tests/TESTING.md`に記録する。
- `RedBlackTreeView/`フォルダを新設し、`RedBlackTreeMappedValuesView`・`RedBlackTreeKeyValueRangeView`等Dictionary/MultiMap共有View型も連番Test as Spec化済み。
- 4型横展開(ValueSemantics/LazySequenceTests/IntegerElement・KeyTests/`_99_DeathTests`境界trap)完了。`_98_RemovalInternalXCTests`(4型共有の生実装のため複製見送り)・`_98_SetAlgebraStressTests`(マルチセット多重度は別設計が必要なため見送り)は意図的な対象外として確定。
- `EtcTests.swift`はユーザー方針で削除せず残置(「なんかあるとつい触るやつ」)。内容整理する場合もファイル自体は残すこと。
- **教訓**: 型別`_98_*.swift`を流用する際、`#if COMPATIBLE_ATCODER_2025`等のAPIガード範囲は型ごとに異なる場合があるので、使用する全APIを毎回sourceでgrepしてから書くこと。
- **教訓**: `_TrackingTag`の`.nullptr`/`.end`は実ノードに対応しないセンチネル値なので、`__retrieve_`等で無条件に実ポインタへ解決してはいけない(Bootstrap復旧時に`try!`クラッシュとして発覚、`___resolve_`で解決済み)。
- ArrayBased版(`Legacy/ArrayBasedFixture/TreeTests.swift`)とBootstrap版(現`___RedBlackTreeContainerTests_unsafe.swift`)は最初から別物として並行開発されており、統合は不要と判明(git historyで確認済み)。
- `ManagedBufferTests.swift`(destroy-stack機構のテスト)は依存する`___Tree`/`CompareUniqueTrait`等がSourcesに現存せず復活不可能と判明、削除済み。UnsafeTreeV2側の同等機構(freshPool/recycle)のテスト充足度は未確認のまま。

- (2026-10-01、使用量77%で区切り) 長いセッションでの作業まとめ。`TreeNodeOnlyFixture`(旧`TreeFoundamentalFixture`)を使った原木層の直接テストを継続し、`tree_base+compare.swift`(`__UniqueHelper`/`__MultiHelper`)向けに`TreeFoundamentalMultiplicityTests.swift`を新設。その後`RedBlackTreeMultiMap+Index.swift`のカバレッジ調査で**実バグ**を発見: `index(inserting:)`が`__insert_unique`を呼んでおり、MultiMapなのに既存キーへの挿入を拒否していた(ユーザー確認の上`__insert_multi`へ修正)。
  - この過程で「削除系メソッドは、空/未発見でもトラップせずに無駄なCoWを起こしてはいけない(トラップするかCoWしないかのどちらか)」という設計原則をユーザーと確認し、同種の実バグを横展開で発見・修正: `RedBlackTreeMultiMap.erase(exactly:)`、両View系列(`RedBlackTreeMappedValuesView`/`RedBlackTreeRangeView+KeyValue`/`+KeyOnly`)の`popFirst`/`popLast`/`erase()`/`erase(where:)`、4型(Set/MultiSet/Dictionary/MultiMap)の`popFirst`/`popLast`/`Set.remove(_:)`/`Dictionary.removeValue(forKey:)`/`removeAll(keepingCapacity: true)`。全て`_copyCount`(`AC_COLLECTIONS_INTERNAL_CHECKS`、Package.swiftで`.when(configuration: .debug)`済み)で実測してから修正(ユーザー指示でテストファースト)。`swift build/test -c release`でも健全性を確認済み。
  - 副産物として2つの重要な発見: (1) **XcodeのMCP `RunAllTests`が数百件のテストを実際には実行せず"0 failed"と誤表示する不具合**を確認(`BufferHeaderTests`等の該当クラスがコンソールログに一切出現しないことで確定)。以後、全体の合否は`swift test`(CLI)を正とすること。(2) `llvm-cov`で厳密に再集計した結果、旧punch-listの`unsafe_node+pointer+compare.swift`/`UnsafeTreeV2+RawRange.swift`/`UnsafeTreeV2+BufferHeader.swift`は実際には(USE_INT128無効時の`___ptr_bitmap_128()`、呼び出しゼロの`contains(range:pointer:)`・`payloadLayout`・`__root_ptr()`などの死んでいるコードを除き)既に100%近い。イテレータ合成レイヤー(`UnsafeIterator+CopyOnWrite.swift`の`reversed()`/`init(_source:tree:)`、`+KeyValue.swift`の`keys()`/`values()`)も同様に、既知の未結線`_Reverse4`系機能と同じ系列の未使用コードと判明。
  - **次回への引き継ぎ**: (a) `payloadLayout`/`__root_ptr()`(BufferHeader)・`contains(range:pointer:)`(RawRange)・イテレータ合成レイヤーの`reversed()`/`keys()`/`values()`は、いずれも`_Reverse4`/`UnsafeTreeV2+Update.swift`と同じ「未結線コードを削除するかどうか」の保留事項に合流させてよい。(b) `_TrackingTag.retire`(却下済み設計のなごり、呼び出しゼロ)も同様。(c) カバレッジの精査は今後`xcrun llvm-cov report/show`(`swift test --enable-code-coverage`が必要)を使うこと、Xcodeの`RunAllTests`の数字は信用しないこと。(d) `removeAll(keepingCapacity:)`以外のVoid返却系(`erase(where:)`等)にも同種のCoW問題が残っていないかは4型本体では確認済みだが、他のView系列では未確認。
  - **方針変更の注記**: 2026-09-29時点の連絡事項は「ビルド確認はXcodeの`BuildProject`/`RunSomeTests`/`RunAllTests`を使用し`swift build`/`swift test`の直接実行は使わない」だったが、今回`RunAllTests`の"0 failed"誤表示(上記(1))を発見したため、本セッションでは全体テストの合否判定とカバレッジ精査に限り`swift test`/`swift build -c release`をCLIで直接実行した。個別ファイルのビルド確認・特定テストクラスの実行は引き続きXcode側(`BuildProject`/`RunSomeTests`)を使用。次回以降もこの併用方針(全体の合否は`swift test`、個別の反復作業はXcode MCP)で良いか、ユーザー確認を推奨。
- 最後に作業したモデル: Claude(Sonnet 5、モデルID `claude-sonnet-5`)。原木層テスト拡充・CoW-on-empty系バグの横展開修正・カバレッジ精査方法の見直しを担当。
- (2026-10-01 07:07 JST) CodexによるTest as Specification横展開レビュー。`API-Matrix.md`・`API-Matrix-View.md`・`Quality-Checklist.md`と、Set/MultiSet/Dictionary/MultiMapおよび共有Viewの現行テストを照合した。今回はレビューのみで、コード・テスト・文書正本の修正およびテスト実行はしていない。
  - **優先度高: Index世代検証の横展開漏れ**。slot削除・再利用後に古いIndexを拒否する`testStaleIndexAfterSlotRecycledWithNewGenerationIsRejected`はSet/MultiSetにあるが、Dictionary/MultiMapには無い。`Quality-Checklist.md`が保証対象とする「recycleされた同一slotを古い世代のIndexが新しい要素として指さない」に直接対応するため、KeyValue系2型にも追加候補。
  - **Range ViewのCoW後Index寿命の横展開漏れ**。コピーしたRange Viewの片方をCoW変異しても発行元側のIndex判定へ影響しないこと、および最初の変更だけCoWが発生する連続変異で削除Indexを拒否することは、SetのKeyOnly Range Viewにのみ明示的テストがある。共有実装を考慮して4型へ機械的に複製する必要はないが、少なくとも重複要素を持つKeyOnly側(MultiSet)とKeyValue Range View側(DictionaryまたはMultiMap)を各1系列ずつ追加する候補。
  - **現行APIだが明示的な仕様テストが見つからないもの**。`elementsEqual(_:)`と`lexicographicallyPrecedes(_:)`は`API-Matrix.md`上で4型およびRange Viewの現行APIだが、型別Test as Specから直接呼ぶテストが見つからない。MultiMapのテストヘルパーが標準Sequenceの`elementsEqual(_:by:)`を利用するだけで、当該APIの仕様テストにはなっていない。KeyOnly/KeyValueの各コンテナと各Range Viewについて、等値・辞書式大小・共通prefix後の長さ違いを代表検証する候補。
  - **API正本との同期漏れ候補**。`erase(exactly:)`はSetとMultiMapのテストで現に使用されている一方、`API-Matrix.md`ではMultiMapがまだ`TODO`表記。まず実装状況を確認してマトリクスを同期し、MultiSet/Dictionaryへの採用・実装・テスト横展開はその結果に従う。これは直ちに4型へテストを複製する案件ではない。
  - 既に概ね横展開済みと確認した領域: `insert(_:hint:)`、値セマンティクス、Lazy Sequence、整数幅境界、Codable、`CustomReflectable`、`Comparable`、`Hashable`、`Sendable`、`isTriviallyIdentical(to:)`、Index offset/limitedBy/formIndex、`containsSubrange`、Bound Expression、CoW、fuzz、性能、削除stress。Setだけに残る旧SubSequence系は、現行APIマトリクスで4型とも`Collection`非適合のため横展開対象外。
  - 推奨着手順: (1) Dictionary/MultiMapのslot再利用後Index拒否、(2) KeyValue Range ViewのCoW・Index寿命、(3) MultiSet Range ViewのCoW・Index寿命、(4) `elementsEqual`/`lexicographicallyPrecedes`、(5) `erase(exactly:)`とAPIマトリクスの同期。
  - ユーザー確認: 「全体テストの合否判定はXcode MCPではなく`swift test`を正とする」はClaudeが2026-10-01に確認したMCP挙動を受けて採った暫定運用であり、ユーザーの恒久方針とは確定していない。以後はClaudeの判断として区別し、必要ならユーザーと検証手段を相談する。
- (2026-10-01 07:11 JST) ユーザー指示により、QA実現度レビューから次の2点を明示的な未完了課題として登録する。
  1. **4型のランダム試験を「参照モデル比較＋操作ごとの赤黒木不変条件確認」の組にする**。現状はSet/Dictionaryが参照モデル比較のみ、MultiMapが不変条件確認のみ、MultiSetだけが両方を持つ。各型の意味に合う参照モデルを用い、固定seedで再現可能な操作列の各段階に`___tree_invariant()`相当の確認を結び付ける。4型すべてで両側を満たした時点を完了条件とする。
  2. **Index世代・Range ViewのCoW寿命検証をKeyValue系まで横展開する**。まずDictionary/MultiMapへ「slot削除・再利用後も古いIndexを拒否する」テストを追加する。加えて、コピーしたKeyValue Range Viewの片方をCoW変異した場合の発行元側Index、CoW後の変更対象側Index、連続変異で削除されたIndexの扱いを明示する。共有実装のため両型への機械的複製は必須とせず、DictionaryまたはMultiMapの代表テストでKeyValue Viewの仕様を固定し、必要に応じてもう一方へ展開する。KeyOnly側のMultiSetについても、重複要素固有の差がないかを確認して追加要否を判断する。
- 最後に作業したモデル: Codex (GPT-5)。Test as Specificationの4型・View横展開漏れレビューと、その結果の記録を担当。
- (2026-10-01 07:13 JST) 日英ペアの公開ドキュメントを照合。Set/MultiSetは見出し構成が同期済みだったが、`Documentation/RedBlackTreeMultiMap.ja.md`の`### Swapping Values`節が英語版に未反映と判明。`Documentation/RedBlackTreeMultiMap.md`へ、KeyValue Range Viewの`values`から得る変更可能な`RedBlackTreeMappedValuesView`、`swapAt(_:_:)`の使用例、値だけが交換されキー順・木上の位置は変わらないという説明を英訳して追加した。コード変更なしのためテストは実行していない。
- 最後に作業したモデル: Codex (GPT-5)。日英ドキュメント差分の確認とMultiMap英語版の同期を担当。
- (2026-10-01 07:16 JST) `CHANGELOG.md`を更新。当初0.4.4タグを起点に全差分を再要約したが、ユーザー指摘により基準が広すぎたと訂正。`CHANGELOG.md`の最終更新コミット`fe770ba8`(2026-09-30 11:28 JST)を特定し、そこからHEADまでの差分だけを再調査した。既存Unreleased項目は保持し、以後に追加された原木層fixture/tests・RawRangeExpression/KeyOnly Range Viewテスト、内部protocolの`~Copyable`対応、raw tree直接検証構造、MultiMapの`index(inserting:)`重複キー修正、空削除時の不要CoW修正、fixture sentinelクラッシュ修正、置換済みUnsafeNodeデバッグ重複実装の削除、およびMultiMap日英ドキュメント同期を追記した。文書変更のみのためテストは実行していない。
- 最後に作業したモデル: Codex (GPT-5)。CHANGELOG最終更新コミット以降の履歴監査とUnreleased追記を担当。
- (2026-10-01 07:17 JST) ユーザー再判断により、`CHANGELOG.md`のUnreleasedは最終更新コミット以降だけに限定した版ではなく、リリースタグ`0.4.4`以降の全体差分をまとめた広い版を採用。公開API・View・Bounds/Index・内部実装・Test as Specification再編・内部テスト・不具合修正・削除整理をAdded/Changed/Fixed/Removedへ再反映した。
- 最後に作業したモデル: Codex (GPT-5)。CHANGELOGの集計基準を0.4.4以降へ戻す修正を担当。
- (2026-10-01 07:19 JST) Codexレビューで指摘したAPI正本の同期漏れを修正。`API-Matrix.md`の`erase(exactly:)`について、実装・テスト済みのMultiMap欄を`TODO`から`✅`へ変更した。MultiSet/Dictionaryは未実装のため`TODO`を維持。文書のみの変更なのでテストは実行していない。
- 最後に作業したモデル: Codex (GPT-5)。`erase(exactly:)`のAPIマトリクス同期を担当。

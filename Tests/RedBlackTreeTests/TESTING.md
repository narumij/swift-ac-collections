<!-- CodexとClaudeによるCodexとClaudeのためのメモ -->

# RedBlackTreeTests maintenance notes

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

- この文書を正しく保つため、ClaudeさんやCodexの作業成果を加味してClaudeさんやCodexさんが都度更新すること（毎回）
- しょぼい系（凡ミス）みつけてくれてありがとう
- リミットだったのでこちらでテスト回しました
- Releaseビルドで400近いコンパイルエラーがでてて、Claudeを呪いました

### 相談事項

- Hands offが膨大になってきました。直近の作業と、現在の状況ぐらいでいいのではないでしょうか？

### 連絡事項

- ABC, convenience, memoizeは温存
- 実験的なテストコード書く場合、人もAIもまずEtcTests.swiftまたはDeathTest.swiftに書くこと
- 5時間上限または週間利用上限で止まるとき、それまでの作業の感想も教えて欲しい
- 最後に作業したモデルはモデル名とバージョンをどこかに記載すること
- Codexさんはふりかえりの時間を確保すること
- Claudeさんは始業時に会話の時間を確保すること
- 小さな変更を積み重ねてるときは互換チェックをさぼっていい
- 内部構造をどのように区分するのか、勝手に判断しないこと
- ユーザー記載欄に記入する場合、こちらが消す都合上、古さが分からないと困るので、日付に加えて時間も記載すること
- 現行APIかどうか判断に迷った場合API-Matrix.md及びAPI-Matrix-View.mdに照らすこと
- カバレッジが落ちてきてるので横展開と合わせてカバレッジ改善（90%目安)
- Test as Specで一応の品質は保てるが、言語や環境の挙動変更による影響やマジックナンバー等の取り扱いミスを検出できるようにする必要もある
- RedBlackTreeTestSupportとDebugAdditionalsは役割がかぶってるので、再度整理が必要
- 横展開の過不足についてはSources/RedBlackTreeCollections/Documentation/API-Matrix.mdと照らし合わせること
- Test as SpecについてはSources/RedBlackTreeCollections/Documentation/Quality-Checklist.mdと照らし合わせること
- テストコード生成時はTests/RedBlackTreeTests/Fixtures.mdを参照し、フィードバックすること
- 内部テストをどのように整理するかについては引き続き検討中
- 原木のテストはやれるだけやって構わない
- 生バッファのテストもやれるだけやって構わない

### 停止条件

- Codexの場合、利用上限が少ないセッションでは、新しい大きなカテゴリへ着手する前に、全体テスト・文書更新・振り返りに必要な余裕を確保する。

### 保留中の判断・懸念

- こちらでヒント系APIとAPI一覧を触ってるので、Test as Spec観点でチェックしてほしい
- 内部構造をテスト観点でどのように区分するのか、まだ結論がでていない
- insert(:hint:)やupdate(:hint:)等のヒント系APIのテストが不十分なまま（解決済みであれば完了済み要望に記載願い）
- 生木へのテストを増やすと変更コストがかさむので、バランスに悩んでいる
- 「空チェック前のensureUnique()が無駄なCoWを起こす」問題は、`RedBlackTreeMultiMap.erase(exactly:)`・`RedBlackTreeMappedValuesView`の`popFirst`/`popLast`/`erase()`/`erase(where:)`・4型の`popFirst`/`popLast`/`Set.remove(_:)`/`Dictionary.removeValue(forKey:)`まで2026-10-01に修正済み。残る未調査範囲: `RedBlackTreeRangeView+KeyValue`/`+KeyOnly`等の他View、`removeAll(keepingCapacity:)`・`erase(where:)`・`erase(_:)`(4型本体、Void返却/強制アンラップでnilの概念がない系)
- `RedBlackTreeMappedValuesView._isdentical(to:)`はSources内で呼び出しゼロ(`Equatable`適合なし)。削除するかテストを書くかはユーザー判断待ち

### 完了済みの要望
(ユーザーが確認したら各項目を削除します)

- 2026-10-01 06:35 Claude: ユーザー許可の上、「空チェック前のensureUnique()が無駄なCoWを起こす」問題を4型の`popFirst`/`popLast`(Set/MultiSet/Dictionary/MultiMap)・`Set.remove(_:)`・`Dictionary.removeValue(forKey:)`の合計9箇所に一括適用(`remove(at:)`は無効インデックスでトラップするため対象外、既に安全)。各型の`_6_RemovalTests.swift`に`_copyCount`実測テストを追加。`AC_COLLECTIONS_INTERNAL_CHECKS`はPackage.swiftで`.when(configuration: .debug)`指定済みのため、テスト側の`#if AC_COLLECTIONS_INTERNAL_CHECKS`だけで十分(別途`#if DEBUG`は不要、ユーザー確認済み)。ユーザー指示で`swift build -c release`・`swift test -c release`も実行、673 tests / 0 failuresでReleaseビルドも健全と確認。`swift test`(Debug)全体で871 tests / 0 failures。
- 2026-10-01 06:15 Claude: ユーザー許可の上、`RedBlackTreeMappedValuesView.swift`の`popFirst`/`popLast`/`erase()`/`erase(where:)`にも`erase(exactly:)`と同種の修正を適用。`_ensureUnique()`を呼ぶ前に`_raw_range`で空判定し、空なら即`nil`/no-opで返すことで、空の共有シングルトンバッファからの無駄な退避コピーを回避。`removeFirst`/`removeLast`は自前の`_ensureUnique()`呼び出しが`popFirst`/`popLast`委譲後は完全に冗長だったため削除(トラップ経路は変化なし)。`swapAt`と`subscript.set`は「該当インデックスが無ければ元々トラップする」経路のため対象外(ユーザーの「トラップするかCoWしないかどちらか」の原則を既に満たす)。`RedBlackTreeView_0_MappedValuesViewTests.swift`に`test_valuesRemovalMethods_onEmptyView_doNotTriggerCopyOnWrite()`を追加し`_copyCount`が0のまま保たれることを実測。`swift test`全体で867 tests / 0 failures。
- 2026-10-01 06:00 Claude: `RedBlackTreeMappedValuesView.swift`(89%)を調査。既存の`RedBlackTreeView_0_MappedValuesViewTests.swift`が`swapAt`/subscript/`count`/`first`/`last`/`popFirst`/`popLast`/`removeFirst`/`removeLast`/`erase()`/`erase(where:)`/`isElement`/`isEnd`/`Sequence`(`Array(dictionary.values)`)まで広く踏んでいた。唯一`_isdentical(to:)`だけがSources内で呼び出しゼロ(この型に`Equatable`適合が無く`==`からも呼ばれていない)と確認、死んでいるコードと判断してテストは追加しない。また、この調査中に`popFirst`/`popLast`/`erase()`/`erase(where:)`/`removeFirst`/`removeLast`/`swapAt`が`_ensureUnique()`を空チェックより前に呼んでおり、`RedBlackTreeMultiMap.erase(exactly:)`で見つけた「トラップしないのに無駄なCoW」と同種の問題を抱えている可能性がある(保留中の判断・懸念に追記済み、今回は対象外)。コード変更なしのためfull suite再実行は不要。
- 2026-10-01 05:50 Claude: ユーザー指摘「削除系は、トラップするかCoWしないかのどちらかであるべき」を`erase(exactly:)`で実測・確認。空のMultiMapに対する`erase(exactly:)`はトラップせず`nil`を返す一方、`_copyCount`が0→1(`ensureUnique()`を無条件で先頭に呼んでいたのが原因。空コレクションは共有される`_emptyTreeStorage`シングルトンを指すため`isUnique()`が常にfalseになり、毎回退避コピーが走っていた)になる「悪い組み合わせ」だったことを`swift test --filter`で実測して確認。ユーザー許可の上、`RedBlackTreeMultiMap+Index.swift`の`erase(exactly:)`に`guard __tree_.count > 0 else { return nil }`を`ensureUnique()`より前段に追加して修正(非空時の挙動・ポインタ再解決順序は変更なし)。既存テストを`_copyCount`の実測アサーションに更新。`swift test`全体で866 tests / 0 failures。Xcodeの通常テストアクションは`AC_COLLECTIONS_INTERNAL_CHECKS`を有効化しない(Release相当)らしく、`_copyCount`系の検証は`swift test`側で行う必要があると判明(ユーザー確認済み: 「デバッグビルドしかしてないから」)。他の削除系API(`popFirst`/`removeValue(forKey:)`/`remove(at:)`等)や他3型に同種の問題がある可能性は未調査(今回はユーザー指示で対象外、保留事項に追加)。
- 2026-10-01 05:40 Claude: ユーザー要望で`erase(exactly:)`の追加テスト。空のMultiMapに対して`startIndex`/`endIndex`(空の場合は同一)で呼んでもトラップせず`nil`を返す性質を`test_eraseExactly_onEmptyMapReturnsNilWithoutTrapping()`として`_5_InsertionTests.swift`に追加。対象テストクラス9件全てpass。
- 2026-10-01 05:30 Claude: `RedBlackTreeMultiMap+Index.swift`(76%)のカバレッジ調査中に実バグを発見・修正。`index(inserting:)`が`__insert_unique`を呼んでおり、MultiMapなのに既存キーへの挿入を拒否してSetのような一意挿入として振る舞っていた(テストが皆無だったため気づきにくかった)。ユーザーに確認の上、`__insert_multi`へ修正(戻り値も`_NodePtr`単体になったため`inserted`は常に`true`に変更)。`_5_InsertionTests.swift`に`test_indexInserting_allowsDuplicateKeysAndErasesByIndex()`を追加し、重複キーが正しく挿入され`erase(exactly:)`で個別削除できることを検証。対象テストクラスは8件全てpass。フルスイートは今回`RunAllTests`の集計表示が507件"No result"になったが、コンソールログを直接確認したところ実際には全スイート(Death Testsを含む)が最後まで実行されて`** TEST FINISHED **`に到達し、"failures"や"TEST FAILED"の文字列はゼロだったため、MCPツール側の集計表示の不具合と判断(実害なし)。
- 2026-09-30 22:30 Claude: `RedBlackTreeDictionary.swift`(84%)を調査。`count(forKey:)`が全テストファイルを通して一度も呼ばれていなかったため、`_4_SearchTests.swift`に`test_countForKey_isOneWhenPresentAndZeroWhenMissing()`を追加(ユニークキーなので存在時1・不在時0を検証)。`erase(where:)`は`grep`で見つけにくかった(`dictionary.erase { ... }`のtrailing closure形で`_6_RemovalTests.swift`に既存)ため誤検出、実際は既にテスト済みと判明。full suite 1005 passed / 0 failed。
- 2026-09-30 22:20 Claude: `Implements/UnsafeTreeV2/UnsafeTreeV2+KeyValue.swift`(75%)を調査。`subscript(key:)`(35-73行目)には「ダミー実装らしい、つかっちゃだめっぽい」というコメントがあるが、実際は`RedBlackTreeDictionary.subscript(key:)._modify`が`yield &__tree_[key]`経由で常時使っているため、このコメントは古い/誤りと判明(コメント自体は今回変更せず、要望欄で報告のみ)。既存テストで唯一踏んでいなかったのは`dictionary[存在しないkey] = nil`の無害な空振り分岐(`subscript(key:)._modify`のfound=false&&value=nil、NOP)だったため、`RedBlackTreeDictionary_5_InsertionTests.swift`に`test_keySubscript_assigningNilToMissingKeyIsANoOp()`を1件追加。`lookup`/`mappedValuePtr(for:default:)`/`___mapValues`/`___compactMapValues`は既存の`_7_UtilityTests.swift`等で生きている経路が確認済みのため追加テストは不要と判断。full suite 1004 passed / 0 failed。
- 2026-09-30 22:10 Claude: `Implements/RawRange/_RawRangeExpression.swift`(77%)向けに新規テストファイル`RedBlackTreeInternal_RawRangeExpressionTests.swift`を追加。`Bound=Int`の純粋なロジック(`==`/`!=`全ケース総当たり・`map`・`relative(start:end:bound:through:)`の6ケース・`sequence`/`traverse`のResultリフト成功失敗分岐)を実木なしで検証、21テスト全てpass。`_start`/`_end<Base>(_:)`は実木の`__begin_node_`/`__end_node`を返すだけの一行実装で、4型のrange系APIから常時経由済みのため対象外とした。full suite 1003 passed / 0 failed。
- 2026-09-30 22:00 Claude: `Implements/__tree/base/tree_base+compare.swift`(`__UniqueHelper`/`__MultiHelper`)向けに新規テストファイル`TreeFoundamentalMultiplicityTests.swift`を追加。既存の`SetBaseTests`/`MultiSetBaseTests`は`___ptr_range_comp`の成功ケースしか踏んでおらず、`___ptr_comp`本体・失敗分岐・重複キー時の`___ptr_comp_multi`タイブレークが未検証だったのを補った。`TreeNodeOnlyFixture.UniqueSealKey`/`.MultiSealKey`(以前ユーザーが追加した未使用ヘルパー)に`_BaseNode_NodeCompareProtocol`適合を追加して直接叩けるようにした。同一ノード同値判定・end境界・キー順序・半開/閉区間の上下端・多重コンテナの同値キー時の木構造タイブレーク(bitmap経由)まで15テスト追加、全てpass。full suite 982 passed / 0 failed(他はNo result、失敗なし)。`USE_INT128`分岐は既定で無効のため対象外。
- 2026-09-30 21:42 Claude: `Implements/Misc/Message.swift`(30%)を調査。10個のメッセージ定数のうち8個(`garbagedIndex`/`invalidIndex`/`outOfBounds`/`emptyFirst`/`emptyLast`/`duplicateValue`/`alignnment`/`treeMissmatch`)は`fatalError`/`preconditionFailure`経由で生きているが、実行するには対応するpreconditionを踏んでクラッシュさせる必要があり、既に確認済みの「assert/precondition部分はデステストするしかない」方針の対象。残り2個(`outOfRange`/`keyMismatch`)はSources内呼び出しゼロで、`keyMismatch`は本体が`"TODO"`のダミー実装。この30%は現状のテスト方針(通常テストの範囲)での実質上限と判断し、通常テストは追加しない。`outOfRange`/`keyMismatch`の削除是非はユーザー判断待ちとして保留に追加。
- 2026-09-30 21:35 Claude: `unsafe_tree+types.swift`(55.00%, 33/60)を調査。`grep`でSources全体の呼び出し元を洗った結果、この不変条件が判明: 生コードは常に`_NodeRef`を`.pointee`で`_NodePtr`に変換してから各アクセサを呼んでおり、`_NodeRef`版オーバーロード(`__payload_ptr`/`__payload_`/`__key_ptr`/`__key_`/`__mapped_value_ptr`/`__mapped_value_`の全`_NodeRef`版)は一つも直接呼ばれていない。加えて`__payload_buffer`(両オーバーロード)と`__element__ptr`も呼び出しゼロ。`_NodePtr`版オーバーロード(スカラー`__key_ptr`/`__key_`は`RedBlackTreeMultiSet.update(at:)`経由、他は各4型経由)は既存の`_5_InsertionTests.swift`等で実動作確認済みのため、生きているコードはこれ以上テストで踏めない。ペア版`__key_ptr`(`_NodePtr`)の唯一の呼び出し元は`UnsafeTreeV2+Update.swift`の`swap_key`で、これは行461の未着手機能疑いと同一の保留事項に接続する。以上より、この55%は生きているコードの実質上限と判断し、`TreeNodeOnlyFixture`用の追加テストは書かず現状のまま次の候補へ進む。full suite再実行は不要(コード変更なし)。
- 2026-09-30 21:19 Claude: 新規テストファイル`TreeFoundamentalSafePtrTests.swift`を追加し、`unsafe_node+pointer+safe.swift`(`_SafePtr`/`_SealedPtr`/`SealError`/`errorMessage`)を100% (113/113)に。全体Sourcesカバレッジは90.43%→90.73%。
  - `_SafePtr.___is_end`の`.failure`分岐(常にfalse)、`_SealedPtr`の`!=`(前回`==`しか踏んでいなかった)、`errorMessage`(ドキュメント化された8ケース・未ドキュメントの4ケースのdefaultフォールバック・`SealError`以外の`Error`型を渡した場合のフォールバック)を追加。`TreeNodeOnlyFixture`を薦めて使ったが、ほとんどはFixture無しでも書けるくらい単純なテストだった。
  - full suite 967 passed / 0 failed。
- 2026-09-30 21:12 Claude: ユーザーによる`TreeFoundamentalFixture`→`TreeNodeOnlyFixture`へのリネーム(`Tests/RedBlackTreeTests/Tree/Fixture/`へ移設)と、`PointerKey`/`TrackingTagKey`/`UniqueSealKey`/`MultiSealKey`という`_NodeKey<Base>`用キー戦略型の追加を確認。`TreeFoundamentalTests.swift`/`TreeFoundamentalSealTests.swift`は既に追従済みだったため、コメント中に残っていた旧名2箇所のみ`TreeNodeOnlyFixture`に修正。ビルド成功、23テストとも変化なくpass(full suite 960 passed / 0 failed)。`PointerKey`/`TrackingTagKey`/`MultiSealKey`は現時点で未使用のヘルパーで、ユーザーからは「必要になったら使えばいい」との方針を確認。

### 内部区分

(テスト用区分であり、ソースのフォルダレイアウトを規定するものではない）

- `__tree`移植層
`Sources/RedBlackTreeCollections/Implements/__tree`に配置されているもの

- `__tree`基本層

`__tree`移植層のうち、
Fixture構成にAllocationInterfaceとDellocationInterfaceのメソッドが不要なもの、
かつUnsafeMutablePointerが不要なもの

- `__tree`応用層

`__tree`移植層のうち、
Fixture構成にAllocationInterfaceとDellocationInterfaceのメソッドがが必要となるもの
かつUnsafeMutablePointerが不要なもの

- 生ポ層(仮名)

`Sources/RedBlackTreeCollections/Implements/__tree`のうち、
実際の挙動を実現しているもの。
現在はUnsafeMutablePointerをベースにしている

- 生メモリ層(仮名)

生メモリ操作を伴うもののうち、`__tree`移植層に含まれないもの

- 生バッファ層(仮名)

生メモリ層のうち、木の生メモリを管理するもの

- 生木層(仮名)

生メモリ層のうち、木を形成しているFacade及びその内部のもの

- (なんかいい名前ください)層(仮名)

IndexやRangeやIteratorの内部に該当するもの

- View層（外部）(仮名)

MutableSubrangeを実現しているもの

- 4型層（外部）(仮名)

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
- (2026-09-29 13:01) `RedBlackTreeTestUtil/`は英語として据わりが悪いとのユーザー相談を受け、`RedBlackTreeTestSupport/`へ改名(`XcodeMV`でリネーム、中身は変更なし)。TESTING.md内の参照も追従。
- (2026-09-29 13:10) ユーザー指示: ABC/convenience/memoizeフォルダは当面ノータッチ。`base/`を糸口に、内部向けテスト(`@testable`依存の低レベル実装テスト)は後回しにしつつ、「外部テストっぽいやつ」(公開APIを検証している実テスト)と「テストサポートっぽいやつ」(テスト本体を持たない共有ヘルパー/フィクスチャ)を棚卸し・再配置。
  - `base/`(`SetBaseTests.swift`・`MultiSetBaseTests.swift`)を確認したところ、`SUT.___ptr_range_comp`等の内部API直叩きのみで公開仕様もサポートコードも無い純粋な内部向けテストだったため、今回は不問(後回し)。
  - `fixture/`(7ファイル、641行)を確認したところ、実質的に実テスト(`func test...`)を1件も持たない共有サポートコード群だったため、`RedBlackTreeTestSupport/`へ内容そのまま全量移設し、`fixture/`フォルダ自体を削除:
    - `RedBlackTreeFixture.swift`(`RedBlackTreeDebugFixture`/`RedBlackTreeFixture`プロトコルと`assertEquiv`等のアサーションヘルパー)
    - `RedBlackTreeSet+Testing.swift`・`RedBlackTreeDictionary+Test.swift`・`RedBlackTreeMultiMap+Test.swift`・`RedBlackTreeMultiSet+Test.swift`(各型の`isValid`/`_copyCount`/`___tree_invariant`/`_withSealed`等、連番テストが多用するテスト専用extension群)
    - `UnsafeIndexV3Range+Testing.swift`(互換維持用の内部extension)
    - `FixtureAtCoder2025CompatibilityTests.swift`は名前に反して実テストが無くpackage内部extension(`___is_garbaged`/`___node_positions()`)のみだったため、紛らわしい`Tests`という名前を外して`FixtureAtCoder2025Support.swift`に改称の上で移設。
  - `foundamental/`(`KeyValueComparerTests.swift`/`KeyValueComparerTests2.swift`)を確認したところ、`KeyValueTrait`の`value_comp`デフォルト実装を独自フィクスチャ型で検証する内部向けテストだったため、今回は不問(後回し)。
  - `mini/`(`MiniStorageTests.swift`/`mini-storage.swift`)を確認したところ、SIMDベースの試作`RedBlackTree4`ごと`#if false`で無効化された完全な死んだ実験コードで、型自体も現行`Sources`に存在しない遺物と判明。外部テストにもサポートにも該当しないため今回は対象外とし、現状のまま保持(将来判断のためコメントのみ残す)。
  - `sealed/`(4ファイル、343行)を確認: `PurifiedTests.swift`(`@testable`・`_NodePtrSealing`/`SealError`直叩き)は内部向けテストのため不問(後回し)。残り3ファイルは`@testable`を使わず公開API(`isElement(at:)`・`isValid`・deprecated `isValid(index:)`)のみで検証する外部テストだったため棚卸し:
    - `SealedTests2.swift`(Set本体、コピー後の片方をCoW変異させた際のIndex有効性)の新規性のある2件を`RedBlackTreeSet_3_IndexSequenceTests.swift`に`testIndexValidityAgainstOriginIsUnaffectedByCopyThenMutateCoW`/`testIndexValidityAfterConsecutiveMutationsWithOnlyFirstTriggeringCoW`として追加(3件目の`testSomething2`は既存の`testIsElementAndIsEndRejectStaleIndex`と同義のため削除)。
    - `SealedTests3.swift`(RangeView版の同内容)の新規性のある2件を`RedBlackTreeSet_98_IndexValidityXCTests.swift`に追加(3件目も同様に重複のため削除)。
    - `SealedAtCoder2025CompatibilityTests.swift`(互換専用、deprecated `isValid(index:)`と`===`によるIndex同一性比較・`.pointee`を使う版)は自己完結クラス`RedBlackTreeSetSealedAtCoder2025LegacyTests`として`RedBlackTreeSetAdditionalAtCoder2025CompatibilityTests.swift`へ統合。末尾の空`testPerformanceExample`スタブは削除。
    - 旧3ファイルは削除、`PurifiedTests.swift`は`sealed/`にそのまま残置。
  - 検証: 通常モード → `COMPATIBLE_ATCODER_2025`有効化 → 通常モードの3段階、両モードともビルド成功。通常モード1075件中817成功・0失敗、互換モード1075件中687成功・0失敗・5スキップ(既知)を確認。フラグは通常モードへ復帰済み。
  - **`fixture/`フォルダは完全に空になり削除。`sealed/`は`PurifiedTests.swift`(内部向け、後回し)のみ残る。** `base/`・`foundamental/`・`mini/`は内部向け/死んだコードのため今回は不問。次はユーザー指示待ち。
- (2026-09-29 13:15) ユーザー指示で`tree/`フォルダを棚卸し(5ファイル、509行)。
  - `_NodeRef.swift`(`_PointerIndexRef.index`)・`_NodePtr_.swift`(`_TrackingTag.index`)・`RedBlackTreePair+Testiing.swift`(`RedBlackTreePair`のテスト用便宜イニシャライザ)は、いずれも実テストを持たない共有サポートコードと確認したため`RedBlackTreeTestSupport/`へ移設(最後のファイルは`Testiing`という綴りミスも`Testing`に修正)。
  - `RedBlackTreeSet+ArrayTreeDebug.swift`(`#if DEBUG && false`で全体無効化、`__nodes`/`___elements`/`__root(_:)`等のデバッグ用アクセサ)と`___RedBlackTreeContainerTests.swift`(同じく`#if DEBUG && false`、337行)を精査。前者が使う`___Node`/`Tree.Header._header`は現行`Sources`に存在せず復活不可能と判明。さらに後者は、クラス名・メソッド名(`testRootInvaliant`/`testFixtures`/`testMin`/`testMax`/`testRotate`/`testBalancing0`/`testRemove3`/`testRemove2`/`testRemove7`/`testFindEqual0`/`testFindEqual1`/`testInsert0`)が完全に一致する`unsafeTree/old/___RedBlackTreeContainerTests_unsafe.swift`(`#if DEBUG`で現役、同じ「結構ディープな内容なので温存する必要がある」というコメント付き)へ、UnsafeTreeV2世代へ移植済みで現役稼働していることを確認。つまり`tree/`側は移植前の遺物であり、内容は既に後継ファイルで生きているため、削除しても実質的な損失がないと判断し削除。
  - `tree/`フォルダは完全に空になったため削除。
  - 検証: 通常モード → `COMPATIBLE_ATCODER_2025`有効化 → 通常モードの3段階、両モードともビルド成功。通常モード/互換モードとも1075件中0失敗(通常817成功、互換687成功・5スキップ既知)を確認。フラグは通常モードへ復帰済み。
  - **`tree/`フォルダは完全に棚卸し完了・削除。** 現役の後継(`unsafeTree/old/___RedBlackTreeContainerTests_unsafe.swift`)は内部向けテストのため今回は不問(後回し)。次はユーザー指示待ち。
- (2026-09-29 17:00) ユーザー指示(優先事項)により、この文書自体の規定(`## Test as Specification`以降)をここまでの作業成果に合わせて更新:
  - `## Test as Specification` に「旧フォルダ監査時の内部/外部トリアージ」節を新設。外部テスト(`@testable`不使用、公開APIのみ)/テストサポート(実テストを持たない共有extension・フィクスチャ)/内部向けテスト(`@testable`+`___`内部API直叩き)の3分類と、それぞれの行き先(型別連番、`RedBlackTreeTestSupport/`、`RedBlackTreeInternal/`または後回し)を明文化。`#if DEBUG && false`等の死んだコードは削除前に依存APIの現存確認と`Current handoff`への要約を必須とする運用も追記(ManagedBufferTests.swift・mini-storage.swift・ArrayTreeDebug.swiftの3件で実際に踏んだ手順)。
  - `## Safe migration workflow` に互換モード確認の手順(通常→互換→通常の3段階、互換後の再確認は不要、小変更の積み重ね時は省略可)を追記。ユーザーの連絡事項に既にあった内容をルール本文にも反映し、ユーザー記入欄が将来整理されても手順が失われないようにした。
  - ユーザー記入欄(`内部区分`等の新設タクソノミー)はユーザー専用領域のため今回は変更していない。
- (2026-09-29 17:05) ユーザー指示によりルート直下`old/`の棚卸しに着手。当初「テストメソッドが1つも無い死んだ足場コード」と誤判定して報告したが、`grep`で`unsafeTree/old/TreeFixtures.swift`が`old/`の各プロトコル(`TreeAlgorithmBaseProtocol_std`・`FindEqualProtocol_std`・`InsertUniqueProtocol_std`等)を実際に採用しており、その`TreeFixture`/`TreeFixtureBase`を土台に`unsafeTree/old/TreeTests.swift`(7クラス)・`NodeFlagTests.swift`・`___RedBlackTreeContainerTests_unsafe.swift`が現役稼働していることが判明し、ユーザーへ訂正済み。**教訓**: `#if DEBUG && false`と違い、単に`#if DEBUG`なだけのファイルは「そのフォルダ内にテストメソッドがあるか」だけでは死活判定できない。他フォルダからの`grep`によるクロス参照確認が必須。
  - `old/`(26ファイル、`_TrackingTag`ベースの安全な参照実装で、ユーザー新設タクソノミーの「`__tree`基本層」にほぼ一致)と`unsafeTree/old/`(7ファイル、その実装を使う現役内部テスト+フィクスチャ)は密結合と判明したため、ユーザー指示で新設`Legacy/`フォルダへ両方をサブフォルダごと移設して集約: `Legacy/old/`・`Legacy/unsafeTree-old/`(`XcodeMV`でディレクトリごと移動、中身は無改変)。`unsafeTree/`本体(`old`抜き)は温存方針どおり無傷。
  - 検証: 通常モードのみ(内容変更なし・互換コード不関与のため互換モード確認は省略)。ビルド成功、全体テスト1073件818成功・0失敗(残りは環境既知の"No result")を確認。
  - **`Tests/RedBlackTreeTests/old/`は消滅し`Legacy/old/`へ、`unsafeTree/old/`は消滅し`Legacy/unsafeTree-old/`へ移設。** 中身の棚卸し(重複排除・`__tree`基本層としての活用可否検討)はユーザーの指示で保留、将来「`__tree`基本層のテスト再構築」を議論する際にまとめて着手する。
- (2026-09-29 17:06) ユーザー指示で`foundamental/`フォルダを棚卸し。`KeyValueComparerTests.swift`/`KeyValueComparerTests2.swift`(いずれも`@testable`不使用、`KeyValueTrait`/`UniqueMultiplicity`/`_UnsafeNodePtrType`に独自フィクスチャで直接準拠し、`value_comp`のデフォルト実装が`_Key: Comparable`に正しく委譲することを検証)を精査。`old/`の教訓を踏まえ、他フォルダからの参照有無を`grep`で確認済み(参照なし、密結合ではない)。
  - 2ファイルはほぼ同一のテスト(`testExample`)で、`_Key`を独自struct(`internalKey: Int`をラップ)にするか`Int`そのものにするかの違いのみ。より一般的な検証(`_Key`が`Comparable`準拠の任意型であっても`value_comp`が委譲経由で動くこと)ができている前者を残し、後者は劣化版の重複と判断し削除。
  - RedBlackTreeSet等4型の公開APIを検証する連番テストとは異なり、4型共通の基盤である`KeyValueTrait`のデフォルト実装そのものを検証する内容のため、型別連番ではなく`RedBlackTreeInternal/RedBlackTreeInternal_KeyValueComparerTests.swift`へ移設。
  - `foundamental/`フォルダは完全に空になったため削除。
  - 検証: 通常モードのみ(互換コード不関与のため省略)。ビルド成功、全体テスト1072件817成功・0失敗を確認。
  - **`foundamental/`フォルダの棚卸しはこれで完了。**
- (2026-09-29 17:13) ユーザー指示: `convenience/`フォルダは整理(重複排除)ではなく、通常/互換モードの二重化が壊れている箇所の修正を希望。調査したところ、`ConvenienceTests2.swift`(`#if !COMPATIBLE_ATCODER_2025`限定、`set[.lessThan(x)]`等のsubscript版API)と`ConvenienceAtCoder2025CompatibilityTests.swift`内の`extension ConvenienceTests`(`#if COMPATIBLE_ATCODER_2025`限定、`set.lessThan(x)`等のメソッド呼び出し版API)が、本来同一シナリオの通常/互換ペアであるにもかかわらず**別クラス**(`ConvenienceTests2` vs `ConvenienceTests`)に分裂していたため、他型のファイルと同じ「同一クラス名を互換ファイル側からextension」規約に反していた。
  - `ConvenienceTests2`の5メソッド(`test_set_LT_GT`/`test_set_LE_GE`/`test_Multiset_LT_GT`/`test_Multiset_LE_GE`/`testRedBlackTreeConveniences`、いずれも`#if !COMPATIBLE_ATCODER_2025`)を`ConvenienceTests.swift`本体の`ConvenienceTests`クラスへ統合。`ConvenienceTests2.swift`は削除。
  - これにより`ConvenienceTests`は、通常モードでは統合した5メソッド(subscript版API)、互換モードでは互換ファイル側の同名5メソッド+`testEnumerate`(メソッド呼び出し版API)が有効になる、正しい二重化構造になった(相互排他ガードのため名前衝突なし)。
  - ついでに互換ファイル末尾にあった完全に空の`extension ConvenienceTests {}`を2つ削除(中身の無い残骸)。
  - 検証: 通常モード→互換モード→通常モードの3段階。両モードビルド成功。互換モードで`ConvenienceTests`単体を実行し18件全成功(統合した5件が正しく互換版APIで動作することを確認)。全体テストも互換モード1067件686成功・0失敗・5スキップ(既知)を確認。フラグは通常モードへ復帰済み。
  - `Elements.swift`・`RedBlackTreeSet+Convenience.swift`・`RedBlackTreeMultiset+Convenience.swift`(いずれもテストではなく`lessThan`/`greaterThan`/`elements(in:)`等の便利APIをテストターゲット内で試験的に生やしているソース、コメントに「盆栽対象」とあり)は今回のスコープ外のため無変更。
  - **`convenience/`フォルダの二重化修正はこれで完了。**
- (2026-09-29 17:16) ユーザー相談: `base/`(`SetBaseTests.swift`/`MultiSetBaseTests.swift`、`@testable`で`Base`型の内部API`___ptr_range_comp`/`__element_`を直接検証)をどうするか。他フォルダからの参照なしを確認済み。Set/MultiSetの2つのみでDictionary/MultiMap版が無い(4型横展開の欠落)ことを踏まえ、「今回は現状の2ファイルを`RedBlackTreeInternal/`へ移設するに留め、Dictionary/MultiMap版の新規拡張は余裕がある時に別途行う」で合意。
  - `SetBaseTests.swift`→`RedBlackTreeInternal_SetBaseTests.swift`、`MultiSetBaseTests.swift`→`RedBlackTreeInternal_MultiSetBaseTests.swift`として`RedBlackTreeInternal/`へ移設(内容無改変)。`base/`フォルダは空になり削除。
  - **保留事項に追加**: `Base.___ptr_range_comp`/`__element_`の内部検証がDictionary/MultiMapに存在しない(4型横展開の欠落の一例)。着手時は`RedBlackTreeInternal_SetBaseTests.swift`を土台に、Dictionary/MultiMap版の`___ptr_range_comp`/`__element_`検証を追加する。
  - 検証: 通常モードのみ(内容変更なし、互換コード不関与のため省略)。ビルド成功、全体テスト1067件817成功・0失敗を確認。
  - **`base/`フォルダの棚卸しはこれで完了。**
- (2026-09-29 17:20) `sealed/`フォルダの最後の残置ファイル`PurifiedTests.swift`(内部向け、`@testable`で`__purified_`/sealing機構を検証)を再監査。`old/`の教訓を踏まえ、他ファイルからの参照有無(`grep`で無し)と依存型`_LazyTieWrap`/`_NodePtrSealing`/`SealError`が現行Sourcesに健在であることを再確認した上で、`RedBlackTreeInternal_PurifiedTests.swift`として`RedBlackTreeInternal/`へ移設(内容無改変)。`sealed/`フォルダは完全に空になり削除。
  - 検証: 通常モードのみ(内容変更なし、互換コード不関与のため省略)。ビルド成功、全体テスト1067件817成功・0失敗を確認。
  - **`sealed/`フォルダの棚卸しはこれで完全に完了。** 次は`unsafeTree/`(`Legacy/unsafeTree-old/`を除く現役14ファイル)の作戦会議。
- (2026-09-29 17:20) `unsafeTree/`(現役14ファイル、`@testable`で生バッファ/生ポインタ/メモリレイアウトを検証)の作戦会議。ユーザー新設タクソノミーはまだ「認識合わせ」段階で具体案は無いとのことで、提案した「現状維持しつつ対応表だけ作る」案も含め保留に決定。ユーザー指示で代わりに「4型の横展開」(Set/MultiSet/Dictionary/MultiMapの連番ファイル群を横断し、片方の型にだけあるテストケースを洗い出す)に着手。規模が大きいため複数セッションに跨る前提で、**hands-off・厚めの裁量で継続**することで合意。
  - 4型の連番ファイル一覧を突き合わせ、`_98`内部/性能系の欠落を優先して着手(公開API層の欠落は後回し):
    - **Dictionaryに`_98_CopyOnWriteTests`が丸ごと欠落** → `RedBlackTreeDictionary_98_CopyOnWriteTests.swift`新設。MultiMap版を土台に、`dict[key]=value`/`removeValue(forKey:)`ベースのtestDict1〜6・testDict3000を追加。通常・互換モード双方で単体7件成功を確認。
    - **Dictionary/MultiMapに`_98_PerformanceTests`が丸ごと欠落** → 両方新設。Setの`_98_PerformanceTests.swift`(distance/index/firstIndex/init/erase全範囲/Equatable/first(where:)の12種)を土台に、Dictionary版は`firstIndex(of:)`、MultiMap版は同じく`firstIndex(of:)`+`keysWithValues:`で移植。**教訓**: `ENABLE_PERFORMANCE_TESTING`は`.when(configuration: .release)`でしか有効化されずCIでも通常exerciseされないため、コンパイル確認には`Package.swift`冒頭の`defines`配列にある同名フラグのコメントアウトを一時的に外してビルドする必要がある(`COMPATIBLE_ATCODER_2025`と同じ「一時有効化→確認→復帰」の手順)。この過程で`Legacy/unsafeTree-old/___RedBlackTreeContainerTests_unsafe.swift`に`ENABLE_PERFORMANCE_TESTING`有効時のみ顕在化する既存バグ(`fixtureEmpty`が見つからない、340行目付近)を発見したが、`Legacy/`は今回のスコープ外のため修正はせず記録のみ。新設2ファイル自体は`XcodeRefreshCodeIssuesInFile`で問題無しを確認。
    - **Dictionary/MultiMapに`_98_RemovalStressTests`が丸ごと欠落** → 両方新設。MultiSetの`_98_RemovalStressTests.swift`(全要素反復削除・ElementRange反復削除・実体化ElementRange反復削除・境界値網羅の4種)を土台に、Dictionary版は`removeValue(forKey:)`、MultiMap版は`eraseMulti(key)`で移植。MultiMapの初期化イニシャライザは`multiKeysWithValues:`ではなく`keysWithValues:`が正しいラベルだったため、コンパイルエラーから発覚し修正(`multiKeysWithValues:`は`FixtureAtCoder2025Support.swift`にある互換用の別名イニシャライザ経由でのみ通る名称で、直接は使えない)。両ファイルとも単体4件成功を確認(`#if !COMPATIBLE_ATCODER_2025`で全体ガードのため互換モード確認は不要)。
    - **MultiSetに`_98_IndexValidityXCTests`が欠落** → 新設。Set/Dictionary版を土台に、`testEmptyArrayLiteralUsesReadOnlyStorage`/`testUnsafeRawIndicesAreValidOnlyForLiveNodes`/`testElementRangeRejectsRawIndicesOutsideItsBounds`/`testStaleIndexAfterSlotRecycledWithNewGenerationIsRejected`の4件を移植(`eraseMulti`使用)。単体4件成功を確認(`#if DEBUG && !COMPATIBLE_ATCODER_2025`で全体ガードのため互換モード確認は不要)。
  - 検証: 全体テスト1116件836成功・0失敗(残りは環境既知の"No result"、新設の`ENABLE_PERFORMANCE_TESTING`配下テストも同様に非実行)を確認。フラグは通常モードへ復帰済み。
  - **残る欠落(次回以降)**:
    - `_98`層: MultiSetの`IndexValidityXCTests`は今回埋めたが、Set固有の`PointerTests`/`RemovalInternalXCTests`(内部hint系API)は他3型に無い(Set固有の内容かどうか要検討)。
    - 公開API層(_0〜_18相当): `BidirectionalCollectionTests`がDictionary/MultiMapに無い、`ValueSemanticsTests`がSet以外に無い、`LazySequenceTests`がSet以外に無い、`IntegerElement/KeyTests`がSet/Dictionary以外に無い、`ProtocolConformanceMoreTests`がSet以外に無い。これらは着手前に「本当に4型で意味のある仕様か」の判断が必要(例えばSetAlgebraはDictionary/MultiMapに元々適用外)。
- (2026-09-29 17:40) 上記のうち`BidirectionalCollectionTests`の欠落を一部解消。Dictionary/MultiMapの`_3_IndexSequenceTests.swift`は`distance`/`index(after:/before:)`/`formIndex(after:/before:)`の基本部分は既にあったが、Setの`_2_BidirectionalCollectionTests.swift`にある`index(_:offsetBy:)`/`index(_:offsetBy:limitedBy:)`/`formIndex(_:offsetBy:)`/`formIndex(_:offsetBy:limitedBy:)`の4種が両方に無かった(互換ファイル側にしか無かった)ため、両ファイルに追加。互換ガード外(常時コンパイル)のため通常・互換モード両方で単体20件成功(新規8件含む)を確認。全体テスト1124件844成功・0失敗。
  - Setの`_2_BidirectionalCollectionTests.swift`にはさらに`test_subscript_rangeAccess`と10種のSubSequence特化ナビゲーション(`test_subSequence_*`)があり、Dictionary/MultiMapには未移植。次回はここから続ける。
  - `ValueSemanticsTests`/`LazySequenceTests`/`ProtocolConformanceMoreTests`(SetのみExist)は未着手。
- (2026-09-29 22:14) ユーザーからユーザー記入欄に新規相談: `RedBlackTreeInternal/`を大分類として維持しつつ、中分類を「実際に使っているFixtureの種類」で切るのはどうか、小分類はClaudeに一任、との提案。9ファイルの実装を確認し3系統に分類できることを確認・提案・合意:
  - `Synthetic/`(実コレクション型と無関係な、テスト専用のプロトコル準拠ダミー構造体を使うもの): `_98_CoverageTests`・`_98_PointerDeathTests`・`KeyValueComparerTests`
  - `Base/`(`RedBlackTreeXXX<T>.Base`/`.Tree`等、trait準拠の静的メソッド層を直接使うもの): `AllocationTests`・`ComparatorsTests`・`SetBaseTests`・`MultiSetBaseTests`
  - `Instance/`(実際の`RedBlackTreeXXX<T>`インスタンスを使うもの): `NaiveIteratorTests`・`PurifiedTests`
  - まだ未確定の`__tree`基本層/応用層/生ポ層等のタクソノミー(TBD)とは別軸のため、それらの名前は借りず独立させた。9ファイルとも`XcodeMV`で該当サブフォルダへ移動(中身は無改変)。
  - 検証: 通常モードのみ(内容変更なし、互換コード不関与のため省略)。ビルド成功、全体テスト1124件844成功・0失敗(移設前と完全一致)を確認。
  - この後の方針はユーザーから「unsafeTreeでも4型横展開でもまかせる、困ったら相談して」とhands-off裁量を得たため、4型横展開(公開API層の`BidirectionalCollectionTests`のSubSequenceナビゲーション部分)を継続する。
- (2026-09-29 22:22) 前回エントリの「10種のSubSequence特化ナビゲーションが未移植」は過大評価だったため訂正: Setの`_2_BidirectionalCollectionTests.swift`を全文確認したところ、`test_subSequence_forEach`/`test_subSequence_makeIterator`の2件のみ無条件(常時コンパイル)で、残り8件(`test_subSequence_index_count`等)は全て`#if COMPATIBLE_ATCODER_2025`限定だった。さらにDictionaryの`RedBlackTreeDictionaryAtCoder2025CompatibilityTests.swift`には既に`testSubsequence`/`testSubsequence2`/`testSubsequence5`/`testIndex100`/`testIndex10`/`testIndex11`/`testIndex12`という互換専用の自己完結クラスが存在し、この8件相当は実質カバー済みと判断。したがって本当に移植が必要なのは`test_subscript_rangeAccess`/`test_subSequence_forEach`/`test_subSequence_makeIterator`の3件のみで、後者2件はDictionary/MultiMapの`_8_RangeViewTests.swift`と重複する可能性が高い(未確定、次回以降に精査)。
- (2026-09-29 22:22) `ValueSemanticsTests`(SetのみExistだった欠落)を解消。MultiSet/Dictionary/MultiMapに`_13_ValueSemanticsTests.swift`を新設(Setは`_15_`だが、番号は型ごとに独立でよい前例に従い、3型とも`_13_`が空き番号だったためこちらを採用)。Setの`RedBlackTreeSet_15_ValueSemanticsTests.swift`の`test_copyOnWrite_mutatingCopyPreservesOriginal`を土台に型ごとのAPIで移植:
  - MultiSet版: `copy.insert(99)` + 削除は`eraseMulti(2)`(`#if !COMPATIBLE_ATCODER_2025`限定と判明したため`#if COMPATIBLE_ATCODER_2025`側で`copy.removeAll(2)`に分岐)。
  - Dictionary版: `copy[99] = "z"` + `copy.removeValue(forKey: 2)`(いずれも無条件API、ガード不要)。
  - MultiMap版: `copy.insert(key: 99, value: "z")`(無条件) + 削除は`eraseMulti(2)`(`#if !COMPATIBLE_ATCODER_2025`限定と判明、compat側は`removeAll(forKey:)`(`RedBlackTreeMultiMap+Deprecated.swift`)に分岐)。
  - 検証: 通常モードでビルド成功・3クラス単体3件成功 → `COMPATIBLE_ATCODER_2025`有効化でビルド成功・同3件成功(MultiSet/MultiMapの互換分岐を確認) → 通常モードへ復帰しビルド成功。全体テスト1127件847成功・0失敗(移設前844成功+新設3件、残りは環境既知の"No result")を確認。
  - **残る欠落(次回以降)**: `LazySequenceTests`/`ProtocolConformanceMoreTests`(SetのみExist)、`IntegerElement/KeyTests`(Set/Dictionaryのみ、MultiSet/MultiMapに無い)、Set固有`_98_PointerTests`/`_98_RemovalInternalXCTests`が他3型に無い件(Set固有かどうか要検討)、`BidirectionalCollectionTests`の残り3件(`test_subscript_rangeAccess`/`test_subSequence_forEach`/`test_subSequence_makeIterator`、Dictionary/MultiMapの`_8_RangeViewTests.swift`との重複要精査)。
- (2026-09-29 22:35) ユーザーから「セッションを使い切るまで横展開を続けてよい、終わったら相談」と継続のhands-off許可を得たため続行。`ProtocolConformanceMoreTests`(SetのみExist)を精査したところ、内容(`CustomReflectable`/`isTriviallyIdentical`/`Comparable`/`Hashable`/`Sendable`)は他3型では`_9_ProtocolConformanceTests.swift`に統合済みで実質カバー済みと判明(Setだけが`_9`と`_11`に分割している組織上の違いに過ぎない)。**真の欠落ではないため、この項目は保留リストから削除**。
  - `LazySequenceTests`(`.lazy`のmap/filter/chain/prefix/dropFirst/CoW非影響、いずれもSequence標準ライブラリの薄い皮なので型に依存しない)は本当の欠落と判断し、MultiSet(`_12_LazySequenceTests.swift`)・Dictionary(`_14_LazySequenceTests.swift`、`_12`はIntegerKeyTests既存のため空き番号を使用)・MultiMap(`_15_LazySequenceTests.swift`)に新設。Setの7テストをそのまま型ごとのAPIで移植(Dictionary/MultiMapは`.key`射影、MultiSetは重複要素を含む配列で検証)。
  - `IntegerElement/KeyTests`(`Int32`のフルレンジ・`Int128`(macOS 15+)がCoW経由でも壊れないことの検証、内部ノードキー比較器のFixedWidthInteger特化パスに関わる非自明な観点)をMultiSet(`_14_IntegerElementTests.swift`)・MultiMap(`_14_IntegerKeyTests.swift`)に新設。Setの`insert`/`remove`ベースをMultiSetの`insert`/`eraseMulti`(`#if !COMPATIBLE_ATCODER_2025`限定、互換側`removeAll(_:)`に分岐)に、Dictionaryの`checkReadAndWrite`ヘルパーをMultiMapの`insert(key:value:)`/`firstIndex(of:)`/`eraseMulti(key)`(同様に互換側`removeAll(forKey:)`に分岐)に適応。
  - 検証: 通常モードでビルド成功・新設5ファイル26件成功 → `COMPATIBLE_ATCODER_2025`有効化でビルド成功・同26件成功(MultiSet/MultiMapの互換分岐を確認) → 通常モードへ復帰しビルド成功。全体テスト1153件873成功・0失敗(直前の847成功+新設26件、残りは環境既知の"No result")を確認。
  - **残る欠落(次回以降)**: Set固有`_98_PointerTests`/`_98_RemovalInternalXCTests`(内部hint系API)が他3型に無い件(Set固有かどうか要検討)、`BidirectionalCollectionTests`の残り3件(`test_subscript_rangeAccess`/`test_subSequence_forEach`/`test_subSequence_makeIterator`、Dictionary/MultiMapの`_8_RangeViewTests.swift`との重複要精査)、Set固有`_8_EnumeratedSequenceTests`/`_98_SetAlgebraStressTests`/`_99_AdditionalDeathTests`が他3型に無い件(前2つはMultiSetにSetAlgebra(`_10`)があるため対象になり得る、後者は旧root DeathTest.swift由来でSet固有の可能性が高い)。
- (2026-09-29 22:40) ユーザーから「セッションを使い切るまで続けてよい」との継続許可のもとhands-offで前回の残り4項目を精査、それぞれ結論が出たので記録:
  - **`_8_EnumeratedSequenceTests.swift`は横展開対象ではなく死んだコードと判明** → 内容全体(`test_enumeratedSequence_forEach`等4件)が`#if DEBUG && false`で完全に無効化されており、依存API`rawIndexedElements`をSources全体で`grep`しても現行コードに存在しないことを確認(旧世代の遺物)。他ファイルからの参照も無し。`old/`の教訓に従いクロス参照確認の上、削除。
  - **`_98_PointerTests.swift`は横展開対象ではない** → 内容を確認したところ`setUpWithError`/`tearDownWithError`と`ENABLE_PERFORMANCE_TESTING`限定の空スタブのみで実質的なテストが無いボイラープレート。他3型に無くて当然のため対象外。
  - **`_98_RemovalInternalXCTests.swift`(`__emplace_hint_unique`/`__find_equal(hint:)`/freshBucket系)は他3型への移植を見送り** → 検証対象の`__find_equal`/`_unchecked_remove`等は`Implements/__tree/interfaces/`にある共有ジェネリック実装で、Set/MultiSet/Dictionary/MultiMapすべてが同じコードパスを通る(traitで特化されるのは`__emplace_hint_unique`/`__emplace_hint_multi`の呼び分けのみ)。Setでの検証がこの共有ロジックを実質的にカバーしているため、3型分の複製は投資対効果が低いと判断。将来「`__tree`基本層のテスト再構築」を議論する際に、型別ではなく共有実装として一本化する方が筋が良い。
  - **`_98_SetAlgebraStressTests.swift`はMultiSetへの直接移植不可と判明** → MultiSetの`union`/`intersection`/`difference`/`symmetricDifference`(`RedBlackTreeMultiSet+SetAlgebra.swift`)はマルチセットの多重度(multiplicity)を保持・演算する独自セマンティクスで、Setの`SetAlgebra`プロトコル(冪等な集合演算、`isSubset`/`isSuperset`/`isDisjoint`等も含む)とは異なる。MultiSetにはそれらの関係演算メソッド自体が存在しない。Swift標準`Set`と比較するSetのfuzzをそのまま流用できず、多重度を数える参照モデル(`[Element: Int]`ヒストグラム)との比較という別設計が必要。既存`_10_SetAlgebraTests.swift`が各操作の単体テストを既に持っているため、優先度は低いと判断し今回は見送り。
  - **`_99_AdditionalDeathTests.swift`は他3型との重複検証が必要で今回は見送り** → 内容(`endIndex`添字・削除済みIndex添字・cross-tree Index・不正区間3種・オフセットオーバーフロー・`index(before:/after:)`/`offsetBy`/`limitedBy`/`formIndex`の境界trap・CoW後のstale Index)は概念的にはIndex/Collection層の共有機能だが、他3型は既にそれぞれ独自の`_99_DeathTests.swift`(220/146/220行)を持ち、シナリオの重複有無の確認には各ファイルの全文精査が必要。死活テストは`DEATH_TEST`フラグでのプロセス終了観測という重いテスト形態のため、精査・移植・検証のコストが他項目より高い。次回以降、`_99_DeathTests.swift`同士の突き合わせから着手するのが良い。
  - 検証: 削除後、通常モードでビルド成功、全体テスト1149件873成功・0失敗(削除前と完全一致、`EnumeratedSequenceTests`の「No result」4件が消えた分だけtotal減)を確認。互換モード確認は内容変更なし(削除のみ)のため省略。
  - **ここまでで「4型の横展開」のうち低コスト・高確度な項目(ValueSemantics/LazySequence/IntegerElement・KeyTests、および過大評価の訂正2件)は全て完了。残る4項目は死活テストの重複精査や共有実装への一本化などの設計判断を要するため、ユーザーに相談。**
- (2026-09-29 22:45) ユーザーから「まかせるといった」との継続指示を受け、相談した4項目のうち`_99_AdditionalDeathTests.swift`の重複精査を実施(残り3項目は前回の結論どおり見送りで確定)。
  - **前提の訂正**: `DEATH_TEST`は`Package.swift`で`.define("DEATH_TEST", .when(platforms: [.macOS]))`により無条件で有効化されており、`COMPATIBLE_ATCODER_2025`のようなフラグ切り替えの手間は不要で通常の`RunSomeTests`で直接ビルド・実行・検証できると判明。前回「死活テストは重いテスト形態なのでコストが高い」と評価したのは過大評価だった。
  - Dictionary(146行)・MultiSet/MultiMap(各220行)の既存`_99_DeathTests.swift`を全文精査し、SetのAdditionalDeathTestsと突き合わせ。既存はcross-tree ElementRangeでのsubscript/erase系(MultiSet/MultiMapのみ)や逆順Range(半開)のsubscript/erase系(3型共通)を手厚くカバーしていたが、以下がどの型にも欠けていたため追加:
    - `endIndex`への素の`subscript get`トラップ(`remove(at: endIndex)`はあったが`dictionary[endIndex]`のような読み取り単体は無かった)
    - `ClosedRange(endIndex...startIndex)`・`ClosedRange(startIndex...endIndex)`の2種(既存は`Range`の逆順のみで`ClosedRange`の端点誤用は未カバー)
    - `index(before:)`/`index(after:)`の境界超過トラップ、`index(_:offsetBy:)`/`index(_:offsetBy:limitedBy:)`/`formIndex(_:offsetBy:limitedBy:)`の境界超過トラップ(5シナリオ、Setの`_99_AdditionalDeathTests.swift`にあった`String`との比較部分は型に依存しない共通知識のため省き、ツリー型側の検証のみ移植)
  - Dictionary/MultiSet/MultiMapの既存`_99_DeathTests.swift`にそれぞれ8件(計24件)追加。Set側にあった`index from another tree`・オフセットオーバーフロー・CoW後stale Indexの3系統は、`ALLOW_CROSS_TREE_INDEX`(無条件有効)/`ENABLE_OFFSET_OVERFLOW_GUARD`(trait無効時off)により現在の既定設定では全型で等しく無効化されるため、移植対象から除外(Set側でも実行時は"No result"になる)。
  - 検証: 通常モードでビルド成功・3型の新設8件×3=24件が対象クラス単体実行(63件、既存36件+新規24件+3件の既存無関係分)で全件成功 → `COMPATIBLE_ATCODER_2025`有効化でビルド成功(該当箇所は元々`!COMPATIBLE_ATCODER_2025`または全ファイルガードのため無効化されるだけで問題なし) → 通常モードへ復帰しビルド成功。全体テスト1173件897成功・0失敗(直前の873成功+新設24件、残りは環境既知の"No result")を確認。
  - **これで「4型の横展開」の低〜中コスト項目は全て完了。残るのは`_98_RemovalInternalXCTests`(共有実装のため見送り確定)と`_98_SetAlgebraStressTests`(マルチセット多重度セマンティクス用の別設計が必要、見送り確定)の2項目のみで、いずれも意図的な見送り。**
- (2026-09-29 22:48) ユーザーから「Fixture分類の観点ができているので`unsafeTree/`の作戦会議は不要」との指示。保留していた`unsafeTree/`(現役14ファイル)を、`RedBlackTreeInternal/`と同じ「実際に使っているFixture種別」の軸で棚卸し。14ファイル全文を確認し、同じ3分類(Synthetic/Base/Instance)がそのまま当てはまることを確認(ただし`RedBlackTreeInternal/`より1層下の生プリミティブ層なので、各分類の実体はレベルが異なる):
  - `Synthetic/`(ソースコード自身が`Fixture`と命名した独自ダミー型で代用しているもの): `RecyclePoolTests.swift`(`struct Fixture: _UnsafeNodePtrType, _RecyclePool, _RecyclePoolDebug`)・`UnsafeNodeFreshPoolTests.swift`(`struct FreshPoolFixture<_PayloadValue>: _FreshPool`)・`UnsafeNodeTests.swift`(`class Fixture: InsertNodeAtProtocol_ptr`)
  - `Base/`(trait準拠の独自Base型を定義して`UnsafeTreeV2<Base>`を直接使うもの、`RedBlackTreeInternal/`のBaseと同じ軸だが1層下の生木層): `UnsafeTreeBasicTests.swift`(独自`enum Base: ScalarValueTrait & ... & _UnsafeNodePtrType`を定義)
  - `Instance/`(ダミーFixtureを介さず`_Bucket`/`_BucketAllocator`/`UnsafeNode`/`UnsafeTreeV2BufferHeader`等の実プリミティブを直接使うもの、10ファイル): `BucketAccessorTests`・`BucketAllocatorTests`・`BucketMemoryLayoutTests`・`BucketQueueTests`・`BucketTraverserTests`・`BufferHeaderTests`・`MemoryLayoutTests`・`UnsafeNodeMemoryLayoutTests`・`UnsafePointerPointerTests`・`UnsafeTreeMemoryTests`
  - 副産物: `RecyclePoolTests.swift`は`#if DEBUG && USE_RECYCLE_POOL_PROTOCOL`、`UnsafeNodeFreshPoolTests.swift`は`#if DEBUG && USE_FRESH_POOL_PROTOCOL`でガードされており、両フラグとも`Package.swift`でコメントアウト済み(現状無効)。死んだコード(`&& false`)ではなく`ENABLE_PERFORMANCE_TESTING`と同種の「切替可能だが現状オフの代替実装」のため、削除せずそのままSynthetic/へ移設。
  - 検証: 通常モードのみ(内容変更なし、互換コード不関与のため互換モード確認は省略)。14ファイル全て`XcodeMV`で該当サブフォルダへ移動(中身は無改変)。ビルド成功、全体テスト1173件897成功・0失敗(移設前と完全一致)を確認。
  - **`unsafeTree/`のFixture種別サブフォルダ分けはこれで完了。`Legacy/unsafeTree-old/`は対象外(既存方針どおり保留継続)。** 次のテーマはユーザー指示待ち。
- (2026-09-29 22:55) ユーザーから次回への引き継ぎ指示。今回セッションはここで終了。
  - `Legacy/`(`old/`+`unsafeTree-old/`)の「`__tree`基本層のテスト再構築」は、ユーザー自身が「それは会議かな」と明言した議題。着手前に方針合意が必要。ユーザーの制約: 「内部で分類はしてほしいが、外に出してほしくない」――`Legacy/`配下の再構築や分類は歓迎だが、公開API境界に染み出す形は避けること。単純なFixture種別移動(`RedBlackTreeInternal/`・`unsafeTree/`で採用した手法)とは異なり、境界線の設計判断が先に必要。
  - **今セッションで完了した「4型の横展開」の全体像**: ValueSemantics(MultiSet/Dictionary/MultiMapに新設)・LazySequenceTests(同3型に新設)・IntegerElement/KeyTests(MultiSet/MultiMapに新設)・`_99_DeathTests.swift`の境界trap24件(Dictionary/MultiSet/MultiMapに追加)・`RedBlackTreeInternal/`と`unsafeTree/`のFixture種別(Synthetic/Base/Instance)サブフォルダ分け・過大評価だった2件の訂正(SubSequenceナビゲーション、ProtocolConformanceMore)・死んだコード1件削除(`RedBlackTreeSet_8_EnumeratedSequenceTests.swift`)。意図的に見送った項目: `_98_PointerTests`(空ボイラープレート)・`_98_RemovalInternalXCTests`(4型共有の生実装なので複製の投資対効果が低い)・`_98_SetAlgebraStressTests`(マルチセット多重度セマンティクス用の別設計が必要)。
  - 次回の入口: ユーザーから新規テーマの指示待ち。候補は`Legacy/`の会議、またはユーザーの気づき次第。
- (2026-09-30 06:15) `Legacy/`の「`__tree`基本層のテスト再構築」に着手。ユーザーからの事前確認(会議)を経て方針決定:
  - `Legacy/old/`(27ファイル、テストメソッド0件のスカフォールディング)を精査したところ、単一の役割ではなく2つの異質な役割が混在していると判明。
    - **役割A(19ファイル)**: 現行`Sources/Implements/__tree/interfaces/`と**同じ契約プロトコル**(`FindInteface`・`InsertUniqueInterface`・`TreeAlgorithmInterface`等、Sources側で定義)に対する、独立実装。多くは`_NodePtr`等の抽象associatedtypeのみで書かれ、具体型に依存しない完全ジェネリックな木アルゴリズム本体(`tree+algorithm.swift`・`tree+bounds.swift`・`tree+compare.swift`・`tree+count.swift`・`tree+distance.swift`・`tree+equal.swift`・`tree+find.swift`・`tree+insert.swift`・`tree+remove.swift`・`three_way_comparator.swift`・`three_way_compare_result.swift`・`unsafe_tree+compare.swift`・`unsafe_tree+three_way.swift`・`UnsafeTreeAccessHandleBase.swift`・`UnsafeTreeNodeAccessProtocol.swift`・`UnsafeTreeNodeRefAccessProtocol.swift`)と、`_TrackingTag`/`_PointerIndexRef`(配列インデックスをノードIDとして使う安全な参照実装)への具体的な結線(`tree.swift`・`tree+ref.swift`・`unsafe_node+debug.swift`)。`unsafeTree-old/TreeFixtures.swift`の`TreeFixture`(`__nodes: [___Node]`という配列だけでノードストレージを表現)がこれを土台にしており、**「配列だけで(生ポインタなしで)赤黒木アルゴリズムが正しく動く」ことの一目瞭然な証拠**になっている。ユーザー確認により、この役割をユーザーは「V0」(現行`UnsafeTreeV2`より前の初期型)と位置づけ、`Legacy/old/`を**`Legacy/ArrayBased/`へ改名**。
    - **役割B(8ファイル)**: `UnsafeTreeV2+Dump.swift`・`UnsafeTreeV2+GraphvizDebug.swift`・`UnsafeTreeV2+Testing.swift`・`_LazyTieWrap+Debug.swift`・`unsafe_node+dump.swift`・`unsafe_node+pointer+compare.swift`・`unsafe_node+pointer+distance.swift`・`unsafe_node+pointer+partial algorithm.swift`は、`@testable`で**現行・現役の`UnsafeTreeV2`/`UnsafeNode`本体を直接拡張**するデバッグ支援コード(dump/Graphviz可視化/`_TrackingTag`⇄実ポインタ変換アダプタ)と、実ポインタ上で動く素朴な代替アルゴリズム(例: `___dual_distance`、コメントに「遅い」とあるO(n)両方向カウントによる`distance`のクロスチェック用実装)。「Legacy」という名前は本来この役割には合わない(現行実装のための現役コード)。ユーザー確認により、`Legacy/ArrayBased/`から分離し、新設`Legacy/Debug/`へ移動(**フォルダ名は暫定、整理が完了してからユーザーと最終命名する**)。
    - `Legacy/unsafeTree-old/`(V0=`ArrayBased`を使うFixture+現役テスト39件)は今回未着手、名前も暫定のまま(ユーザー方針: 整理が済んでから命名)。
  - 検証: 通常モードのみ(内容変更なし、ファイル移動のみ)。ビルド成功、全体テスト1173件897成功・0失敗(移設前と完全一致)を確認。
  - **残作業**: `Legacy/Debug/`と`Legacy/unsafeTree-old/`の最終命名(ユーザー確認待ち)。役割Bの8ファイル内にも「デバッグツール(dump/graphviz)」と「実ポインタ上の素朴な別アルゴリズム(cross-validation)」というさらに細かい役割の違いがある可能性があり、命名時に検討の余地あり。
- (2026-09-30 06:27) ユーザー指示: `ArrayBased/`内の`three_way_comparator.swift`・`three_way_compare_result.swift`・`unsafe_tree+three_way.swift`(いずれも2026-06-01作成、比較的新しい)は依存が無さそうなので`ThreeWay/`へ分離してほしいとのこと。実際に依存関係を確認: 3ファイルが宣言する型/プロトコル(`___default_three_way_comparator`・`___enum_compare_result`・`__lazy_compare_result`・`__comparable_compare_result`・`LazySynthThreeWayComparator`・`ComparableThreeWayComparator`)は`Legacy/`内の他ファイルから一件も参照されておらず、逆に3ファイル自身もSources側の共有インターフェース(`ThreeWayCompareResult`・`_TreeKey_LazyThreeWayCompInterface`・`_BaseKey_LessThanInterface`)以外には依存していないことを`grep`で確認(双方向とも依存ゼロ)。`Legacy/ArrayBased/ThreeWay/`を新設し3ファイルを移動。ビルド成功、全体テスト1173件897成功・0失敗(移設前と完全一致)を確認。
- (2026-09-30 06:31) ユーザー指示: 「`UnsafeMutablePointer`をポインタとして使っているもの」を`Legacy/Unsafe/`へ格納。これで暫定名だった`Legacy/Debug/`の最終命名が確定(`Legacy/Unsafe/`にリネーム)。さらに`grep`で全`Legacy/`配下を再確認したところ、`ArrayBased/`直下に見落としが2件あった: `unsafe_node+debug.swift`(`extension UnsafeMutablePointer where Pointee == UnsafeNode`で実ノードポインタから`_TrackingTag`を算出するブリッジ)と`UnsafeTreeAccessHandleBase.swift`(`var header: UnsafeMutablePointer<UnsafeTreeV2BufferHeader> { get }`という実ポインタ型のプロトコル要件、他ファイルからの参照・準拠は現状ゼロで孤立プロトコルと判明)。両ファイルを`ArrayBased/`から`Legacy/Unsafe/`へ移動。`ArrayBased/`(`ThreeWay/`含む)には`UnsafeMutablePointer`参照が無いことを`grep`で確認済み。
  - 検証: ビルド成功、全体テスト1173件897成功・0失敗(移設前と完全一致)を確認。
  - **現在の`Legacy/`構成**: `ArrayBased/`(16ファイル、純粋にジェネリックな`_NodePtr`アルゴリズム本体+`_TrackingTag`結線)・`ArrayBased/ThreeWay/`(3ファイル、依存ゼロの三方比較)・`Unsafe/`(10ファイル、実`UnsafeMutablePointer<UnsafeNode>`/`UnsafeTreeV2`を直接使うデバッグ拡張・素朴な別実装・孤立プロトコル)・`unsafeTree-old/`(V0=ArrayBasedを使う現役Fixture+テスト39件、命名未着手)。
- (2026-09-30 06:34) ユーザー指示: `Legacy/unsafeTree-old/`(V0=`ArrayBased`を使う現役Fixture+テスト39件)を`Legacy/ArrayBasedFixture/`へリネーム。これで`Legacy/`配下の全フォルダ命名が完了。
  - 検証: ビルド成功、全体テスト1173件897成功・0失敗(移設前と完全一致)を確認。
  - **`Legacy/`の最終構成**: `ArrayBased/`(16ファイル、V0の純粋ジェネリック実装+`_TrackingTag`結線)・`ArrayBased/ThreeWay/`(3ファイル)・`ArrayBasedFixture/`(7ファイル、V0を使う現役Fixture+テスト39件)・`Unsafe/`(10ファイル、実ポインタ向けデバッグ拡張・別実装)。「配列だけで赤黒木が動く証拠」(V0)と「現行UnsafeTreeV2向けデバッグ支援」の2軸が名前で一目瞭然になった。**`Legacy/`再構築(命名フェーズ)はこれで完了**。次は`ArrayBasedFixture/`内部の精査(旧セッションで確認済みの39テストの現状把握)、または新規テーマへ。
- (2026-09-30 06:35-06:50) ユーザーがXcode側で手動再配置を並行して実施(`Legacy/Debug/`→`Legacy/Unsafe/`の内容を全て`Legacy/`の外の新設`DebugAdditionals/`(トップレベル、Legacyの兄弟)へ移動し、`RedBlackTreeSet+UnsafeTreeDebug.swift`・`___RedBlackTreeContainerTests_unsafe.swift`・`___RedBlackTreeBase+NodePool.swift`も同じ理由で`DebugAdditionals/`へ、その後さらに`___RedBlackTreeContainerTests_unsafe.swift`と`___RedBlackTreeBase+NodePool.swift`は再考の末`Legacy/ArrayBasedFixture/`・`Legacy/ArrayBasedTests/`へ戻す、等)。**「現行`UnsafeTreeV2`/`RedBlackTreeSet`向けデバッグ支援」は`Legacy`ではなくトップレベルの`DebugAdditionals/`が最終的な置き場所という結論**(Claudeが提案した「Legacyの中にUnsafeサブフォルダ」よりユーザーの意図に近い)。
  - ユーザー依頼: `___RedBlackTreeContainerTests`(実ポインタ版`RedBlackTreeSet`をテスト)を「ArrayBasedで動くようにする」か「過去にArrayBasedで動いていた似たテストで差し替える」で、「多分過渡期に喪失してる」との予想。
  - 調査した結果、**喪失していないと判明**: `git log --all -S "class ___RedBlackTreeContainerTests"`で履歴を追ったところ、このテストは2024年の最初期(`RedBlackTreeModule`時代)から常に実ポインタ版`RedBlackTreeSet`を対象にしており、ArrayBased版は元々別物として存在していた。実際、`Legacy/ArrayBasedFixture/TreeTests.swift`(21メソッド)には`___RedBlackTreeContainerTests`とほぼ同名のテストが既に揃っている: `testRootInvaliant`/`testRotate`/`testBalancing0`(`TreeBaseTests_EmptyNode`)、`testRemove2`/`testRemove3`/`testRemove7`/`testFindEqual0`/`testInsert0`(`TreeTests_EmptyNode`)、`testMin`/`testMax`/`testFindEqual1`(`TreeTests0_10_20`等)。つまり「実ポインタ版でも同じシナリオを検証する」ためのポート版(`___RedBlackTreeContainerTests`)と「ArrayBasedのオリジナル版」(`TreeTests.swift`)が最初から並行して存在しており、統合や移植は不要だった。
  - ユーザー指示: 「このまま(2ファイルを両方維持)で進めて、統合するかどうかは後で決める」。**今回は何も変更せず、この調査結果と方針をTESTING.mdに記録するのみ**。
  - 検証: ビルド成功、全体テスト1173件897成功・0失敗(移設前と完全一致)を確認。
- (2026-09-30 07:00-07:20) ユーザー指示で`___RedBlackTreeContainerTests_unsafe.swift`(現在`DebugAdditionals/TransitionFromLegacy/`)の「現在の環境(現行`UnsafeTreeV2`/`RedBlackTreeSet`)で動くよう復帰」に着手。ユーザーコメント: 「木の開発のブートストラップに該当する部分で、結構大事」。
  - ファイル冒頭のコメント`// TODO: ポインタベースで動くようにする`が示すとおり、`testRootInvaliant`/`testFixtures`/`testMin`/`testMax`/`testRotate`/`testBalancing0`/`testFindEqual0`/`testFindEqual1`が`#if false`で無効化されていた。原因は、旧デバッグAPIが`tree.__nodes = [...]`という**配列の直接代入**で任意の木構造(色・左右・親)を組み立てる方式だったが、現行の`RedBlackTreeSet+UnsafeTreeDebug.swift`の`__nodes`はGET-ONLYの計算プロパティ(実ポインタから毎回導出)で、直接代入できなくなっていたため。
  - 現行の生ポインタ木にも`_TrackingTag`単位のsetter(`__is_black_(_:_:)`・`__left_(_:_:)`・`__right_(_:_:)`・`__parent_(_:_:)`・`___element(_:_:)`、いずれも`Sources/.../UnsafeTreeV2/Debug/UnsafeTreeV2+Testing.swift`に現役で存在)があることを発見。これを使い、`RedBlackTreeSet+UnsafeTreeDebug.swift`に以下を新設:
    - `___NodePtr(_ tag: _TrackingTag) -> _NodePtr`(`__retrieve_(tag).get()`で実ポインタへ変換。`_TrackingTag`引数のため`.end`/`.nullptr`静的メンバも整数リテラルもそのまま渡せる)
    - `___applyFixture(nodes: [___Node], elements: [Element])`(`Element == Int`限定): 不足分は`Int.min`起点の番兵値で`__insert_unique`して枠を確保し(実際の目的値を先に挿れると、複数Fixtureを同一インスタンスに連続適用する際に値の重複で無限ループする不具合があったため番兵方式に変更)、その後`_TrackingTag`単位のsetterで色・左右・親・実際の値を上書きして目的の形状を作る。
  - `#if false`ブロックを全て解除し、`tree.__nodes = [...]`を`tree.___applyFixture(nodes:elements:)`呼び出しに書き換え。また`tree.__tree_.__left_ref(tree.___NodePtr(...))`という旧APIの呼び出し方も、現行では`__left_ref`/`__right_ref`が「ポインタ自身のプロパティ」(`Implements/__tree/unsafe_node/unsafe_node+pointer.swift`で`_ref(to: &pointee.__left_)`として定義)であると判明したため、`tree.___NodePtr(...).__left_ref`という書き方に修正。
  - **結果**: コンパイルは通り、既存の5件(`testRemove2`/`testRemove3`/`testRemove7`/`testFindEqual0`/`testInsert0`、いずれも`___applyFixture`を使わない/空Fixtureのみ)は成功。しかし新たに解除した7件(`testRootInvaliant`/`testFixtures`/`testMin`/`testMax`/`testRotate`/`testBalancing0`/`testFindEqual1`、いずれも1件以上のノードを持つ`___applyFixture`呼び出しを含む)は**実行時にクラッシュ**(アサーション失敗ではなくプロセスクラッシュ)。単一ノードの`testRootInvaliant`ですら失敗するため、複数ノード特有の問題ではなく`___applyFixture`自体か直後の`___tree_invariant()`呼び出し付近に根本原因がある可能性が高い。`print`+`fflush(stdout)`による診断を試みたが、クラッシュ位置の特定には至らず、診断コードは元に戻した(現在は素の実装のみ)。
  - ユーザー判断: 「コンパイルが通る時点まで進めて。さすがにわからん」→ **クラッシュの原因調査はここで中断**。全体テストで確認したところ、この7件の失敗は他のテストに影響を与えていない(全体1173件898成功・7失敗〈全て`___RedBlackTreeContainerTests`内〉・0スキップ、他の既存テストは無傷)。
  - **残作業(次回以降)**: `___applyFixture`のクラッシュ原因調査。疑わしい点として、(a) 番兵値`Int.min + i`での`__insert_unique`が何らかの内部境界値と衝突している可能性、(b) `_TrackingTag`経由の直接フィールド上書きが、`__insert_unique`の内部ブックキーピング(赤黒木以外の不変条件、例えば`_buffer.header`のキャッシュ値等)を壊している可能性、(c) `___tree_invariant()`自体が想定外の入力でクラッシュする経路を持つ可能性、の3点を次回調査の起点として記録する。
  - **原因判明・修正完了**: ユーザーがXcodeのlldbで実機デバッグし、バックトレースを提供。`Fatal error: 'try!' expression unexpectedly raised an error: SealError.null`、発生箇所は`UnsafeTreeV2+Testing.swift`の`__left_(p:l:)`内。原因は`_TrackingTag`の特殊値`.nullptr`(`-2`)/`.end`(`-1`)が実際には**どのノードにも対応しない純粋なセンチネル値**(`Sources/.../__tree/_types/tree_basic+tag.swift`のコメントに明記)であるにもかかわらず、setter(`__left_(_:_:)`/`__right_(_:_:)`/`__parent_(_:_:)`)が代入先の値`l`を無条件に`__retrieve_(l).get()`していたため。フィクスチャの木構造は葉ノードの`__left_`/`__right_`に`.nullptr`、根の`__parent_`に`.end`を指定するのが当然の使い方であり、`___applyFixture`が最初の1ノードから確実にこの経路を通っていた(単純ミスではなく、テスト用APIの見落とし)。
  - 修正: `UnsafeTreeV2+Testing.swift`に`___resolve_(_ tag: _TrackingTag) -> _NodePtr`(`.nullptr`→`nullptr`、`.end`→`end`、それ以外は`__retrieve_`経由)を新設し、3つのsetterから`try! __retrieve_(l).get()`をこれに置き換え。
  - 検証: ビルド成功、`___RedBlackTreeContainerTests`単体13件中12件成功(残り1件`testPerformanceExample`は`ENABLE_PERFORMANCE_TESTING`ガードで通常モード非実行、既知)。全体テスト1173件905成功・0失敗(直前の898成功から復帰した7件分ちょうど増加)を確認。
  - **`___RedBlackTreeContainerTests_unsafe.swift`の「現在の環境で動くよう復帰」はこれで完全に完了。** 全13メソッド(1件を除き)が現行`UnsafeTreeV2`/`RedBlackTreeSet`上で稼働。ユーザーコメント通り「木の開発のブートストラップに該当する部分」が復旧した。
- (2026-09-30 07:28) ユーザー指摘: 「テスト復帰したから配置場所おかしいかもな」。`___RedBlackTreeContainerTests_unsafe.swift`は復帰前は「過渡期の残骸」の一部として`DebugAdditionals/TransitionFromLegacy/`に置いていたが、現行`RedBlackTreeSet`/`UnsafeTreeV2`のブートストラップを検証する現役テストになった以上、その名前は合わなくなった。依存関係を確認したところ、直接依存するのは同じ`DebugAdditionals/`内の`RedBlackTreeSet+UnsafeTreeDebug.swift`・`UnsafeTreeV2+Testing.swift`(いずれも旧`UnsafeTree/`サブフォルダ)のみで、`TransitionFromLegacy/`に残る3つの孤立プロトコル(`UnsafeTreeAccessHandleBase`等、参照ゼロ)とは無関係と判明。
  - ユーザー指示で`DebugAdditionals/UnsafeTree/`を`DebugAdditionals/UnsafeTreeV2/`へ改名(型名`UnsafeTreeV2`と正確に一致させる)し、`___RedBlackTreeContainerTests_unsafe.swift`をそこへ移動。`TransitionFromLegacy/`には孤立3プロトコルのみが残る。
  - 検証: ビルド成功、全体テスト1173件905成功・0失敗(移設前と完全一致)を確認。
- (2026-09-30 07:33) ユーザー指摘: 「同じ名前のフォルダが二つあって混乱するな」。トップレベルの`Tests/RedBlackTreeTests/UnsafeTreeV2/`(以前の`unsafeTree/`をユーザーが改名、Base/Instance/Synthetic)と、今回改名した`DebugAdditionals/UnsafeTreeV2/`が同名で並立していた。ユーザーが先に`___RedBlackTreeContainerTests_unsafe.swift`をトップレベル`UnsafeTreeV2/`直下へ自ら移動済み(「めんどいから目的のフォルダに移動した」)。「中分類はまかせる。DebugAdditionalsってFixtureの一部あるいはゴミ置き場だから」との指示を受け、以下を実施:
    - `DebugAdditionals/UnsafeTreeV2/`(dump/Graphviz/Testing拡張)→`DebugAdditionals/UnsafeTreeV2Debug/`に改名(同階層の`UnsafeNode`/`ThreeWay`と命名を揃えつつ、本体テストスイートの`UnsafeTreeV2/`と重複しない名前に)。
    - トップレベル`UnsafeTreeV2/`直下に浮いていた`___RedBlackTreeContainerTests_unsafe.swift`を、既存のFixture種別分類(実`RedBlackTreeSet`インスタンスを使用=`Instance`)に合わせて`UnsafeTreeV2/Instance/`へ格納。
  - 検証: ビルド成功、全体テスト1173件905成功・0失敗(移設前と完全一致)を確認。**同名フォルダの混乱はこれで解消。**
- (2026-09-30 07:38) ユーザー指示: `___RedBlackTreeContainerTests`(クラス名)とファイル名(`___RedBlackTreeContainerTests_unsafe.swift`)を「いいかんじ」に改名。ユーザー自身が使った「木の開発のブートストラップに該当する部分」という言葉から`UnsafeTreeV2BootstrapTests`に改名(クラス名・ファイル名とも)。コード内から旧クラス名への参照はゼロ(`grep`で確認、TESTING.mdの過去ログのみ)だったため安全に改名。
  - 検証: ビルド成功、`UnsafeTreeV2BootstrapTests`単体13件中12件成功(残り1件`testPerformanceExample`は既知の`ENABLE_PERFORMANCE_TESTING`ガードで非実行)を確認。
- (2026-09-30 08:xx) ユーザー指示で`memoize/`フォルダを調査。`MemoizeCache.swift`(全体`#if false`)は別リポジトリ`swift-ac-memoize`に切り出し済みのメモ化DSL試作コード(`MemoizeCache1〜4`・`Memoized_Ver1〜4`・tarai関数)、`MemoizeCacheTests.swift`(クラス全体`#if false`)はその依存先。`_MemoizeCacheBase`・`_KeyCustomProtocol`・`_ComparableMemoizationCacheProtocol`が現行`Sources`のどこにも存在しないことを確認(`grep`で0件)。ユーザー判断:「そもそもユースケース例なんだよね。やっぱけすかな」。他ファイルからの参照が無いことを確認の上、両ファイルを削除。`MemoizeCacheLRUTests.swift`(`___LRULinkList`という現行Sources型を使う、無効化されていない現役テスト)はそのまま残置。
  - 検証: ビルド成功、全体テスト1165件905成功・0失敗を確認(memoize削除分のみ総数減、リグレッションなし)。
- (2026-09-30 08:xx) ユーザーからの新規要望(ユーザー記入欄`連絡事項`にも追記): 「カバレッジが落ちてきてるので横展開と合わせてカバレッジ改善(90%目安)」「カバレッジだけを目的とした分類があってもいいかも」。`xcrun xccov view --report <xcresult>`でカバレッジ取得可能と判明(質問に回答済み)。`Sources/RedBlackTreeCollections`のみで集計すると88.11%(7526/8542行)、90%まで約162行相当。
  - Sources側で完全に0%な2ファイルを発見したが、いずれも「テスト不足」ではなく**未結線コードの疑い**と判明したため、テストを書かずに保留:
    - `Implements/Iterator/UnsafeIterator/UnsafeIterator+Reverse4.swift`(`_Reverse4`、0/11行): `UnsafeIterator.swift`で`ValueReverse`/`KeyReverse`等の型として定義されているが、実際に呼ばれる`.keys`/`.values`等の互換API側は`Deprecated/Iterator/UnsafeIterator+deprecated.swift`にある同名だが別実装の`_TieTrait`版を使っており、`_Reverse4`系はSources内で呼び出し元がゼロ。
    - `Implements/UnsafeTreeV2/UnsafeTreeV2+Update.swift`(`swap_key`/`swap_mapped_value`、0/20行、2026/09/28作成の新しいファイル): Sources内で呼び出しゼロ。進行中の未着手機能の可能性がある。
  - 不確定要素(未結線か削除対象かの判断)は保留し、次に絶対的な未カバー行数が最大のファイルから着手: **`RedBlackTreeView/RedBlackTreeMappedValuesView.swift`(37.14%→88.57%)**。これは`RedBlackTreeDictionary.values`/`RedBlackTreeMultiMap.values`/`RedBlackTreeRangeView(KeyValue).values`が返す型(ユーザー記入欄の「RedBlackTreeViewのテストが必要そう」に該当)。関数単位のカバレッジを確認したところ、`subscript`(get/set)・`count`・`first`/`last`・`popFirst`/`popLast`・`removeFirst`/`removeLast`・`erase()`/`erase(where:)`・`isElement(at:)`/`isEnd(_:)`が0%(全て`#if !COMPATIBLE_ATCODER_2025`限定だが無条件で公開されているAPI、内部専用の`_isdentical`/`_copyCount`は対象外)だったため、テストを追加。
  - ユーザー提案:「それらはRedBlackTreeViewフォルダに連番でまとめたほうがよくない？」。`RedBlackTreeMappedValuesView`/`RedBlackTreeKeyValueRangeView`はDictionary/MultiMapで共有されるジェネリック型なので、型別フォルダに分散させず専用の`Tests/RedBlackTreeTests/RedBlackTreeView/`フォルダを新設し、Test as Specの連番規約をそこにも適用する方針に転換。
    - `RedBlackTreeDictionary_7_UtilityTests.swift`に追加していた`.values`関連テスト(既存の`swapAt`系5件+新設10件)を`RedBlackTreeView/RedBlackTreeView_0_MappedValuesViewTests.swift`(クラス名`RedBlackTreeMappedValuesViewTests`)へ丸ごと移動。Dictionary側には基本の統合確認(`test_keysAndValues_followKeyOrder`)のみ残した。
    - 次に`RedBlackTreeRangeView+KeyValue.swift`(共有RangeView、`RedBlackTreeKeyValueRangeView`)の未カバー関数(`sorted()`・`keys`・`values`・`removeFirst()`・`removeLast()`・単体`erase(where:)`)を新設`RedBlackTreeView/RedBlackTreeView_1_KeyValueRangeViewTests.swift`に追加。`unranged()`(および内部`_create`)は`@available(*, deprecated)`だったため、現行APIのみを検証するTest as Specの原則により対象から除外した。
  - 検証: 通常モードでビルド成功、新設2ファイル計25件(既存5件+新規20件)成功。全体テスト1180件920成功・0失敗を確認。`Sources/RedBlackTreeCollections`集計カバレッジは**88.11%→89.47%**(90%目安まで残り約40行相当)。
  - **残作業(次回以降)**: 90%まで詰めるなら次点候補は`RedBlackTreeDictionary.swift`(43行未カバー)・`Implements/__tree/unsafe_tree/unsafe_tree+algorithm.swift`(43行未カバー、赤黒木コア算法)・`RawRange/_RawRangeExpression.swift`(34行未カバー)。0%だった`UnsafeIterator+Reverse4.swift`/`UnsafeTreeV2+Update.swift`は未結線コードの疑いが濃く、削除するかテストを書くかはユーザー判断が必要(保留継続)。

# 外部所有型Extension監査

最終更新: 2026-10-04 / Codex

## 目的

標準ライブラリなど、swift-ac-collectionsが所有しない型へ追加しているextensionを一覧化し、
利用者や他ライブラリへ影響するものと、モジュール内部だけで使うものを区別する。

Swiftでは`extension`宣言そのものより、次が外部影響を決める。

- 追加メンバーのアクセスレベル
- 外部所有protocolへのretroactive conformance
- package/internal protocolへの適合
- `@inlinable`または`@usableFromInline`を通したclient codeへの埋め込み
- build configurationによる有無

## 現在の一覧

| 外部所有型 | 追加内容 | 宣言上の範囲 | 構成 | 外部への影響 | 判定 |
| --- | --- | --- | --- | --- | --- |
| `Collection where Index == Int` | `nextPermutations()` | `public` | 常時 | importした利用者の全該当Collectionへメソッド候補を追加 | 意図した公開API |
| `Int` | `__less()` / `__greater()` | `public` | 常時 | importした利用者の`Int`へ二つのメソッドを追加 | 公開の必要性を再確認 |
| `Int` | `ThreeWayCompareResult`適合 | `public` protocolへの適合 | 常時 | `@_documentation(visibility: internal)`でもsource上は公開。witnessの`__less()` / `__greater()`を伴う | protocolごと可視性再検討 |
| `Int` / `Int32` | `_TrackingTag`の`nullptr` / `end` / `retire` / `debug` | package `@inlinable` | trait依存 | package外から直接呼べないが、整数型全体への追加 | 内部用途 |
| `Result`ほかIndex比較宣言群 | `Comparable`適合・比較 | publicを含む | `DEBUG`のみ | `Result`、`_LazyTieWrap`、`_NodePtrSealing`、`_LazyTie`を一群で成立させ、Debug/Releaseの適合集合を変える | 最優先で一群として処理 |
| 特殊化された`Result` | 複数の`==` / `!=` overload | `public` | 常時 | 該当する`Result`のoverload resolutionへ追加候補が見える | Index再設計時に監査 |
| `Result` | `_NodePtr` typealias | `public` | 常時 | すべての`Result`へ赤黒木内部由来の名前を追加 | 非公開化候補 |
| `Result<_NodePtrSealing, SealError>` | `exists` | `public` | 互換modeのみ | compat構成だけで公開member集合が変わる | compat限定例外として記録 |
| 特殊化された`Result` | pointer検証、変換、`SealError`伝播helper | internal / package中心 | 常時、一部`DEBUG` | 通常は外部から直接呼べない。`@inlinable`経由の依存は残り得る | 内部へ閉じる |
| `Range` / `ClosedRange` | `SortedSequence`適合 | package protocolへの適合 | `DEBUG`かつ非互換mode | package外からprotocolを利用できない | 実験用。削除可否を確認 |
| `String` | RedBlackTree診断文言 | internal `@usableFromInline` | 常時 | source APIには出ないが、公開`@inlinable`実装から参照可能 | 内部用途 |
| `MemoryLayout` | node/payload layout helper | internal `@inlinable` | 常時 | source APIには出ない。serialized implementationの依存になり得る | 内部用途 |
| `UnsafeMutablePointer where Pointee == UnsafeNode` | `_NodePtr` typealias | `public` | 常時 | 該当pointer specializationへ赤黒木内部由来の名前を追加 | 非公開化候補 |
| `UnsafeMutablePointer where Pointee == UnsafeNode` | `_NodeRef` typealias | `public` | 常時 | 該当pointer specializationへ赤黒木内部由来の名前を追加 | 非公開化候補 |
| `UnsafeMutablePointer` | node/bucket操作helper | internal中心、一部`@inlinable` | 常時、一部deprecated | source APIには出ないが、公開`@inlinable`経路を個別確認する余地あり | 内部用途 |
| `UnsafeMutableRawPointer` | allocate/deallocate helper | internal、一部`@inlinable` | `USE_C_MALLOC`分岐 | source APIには出ない。serialized implementationの依存になり得る | 内部用途 |

Indexを端点とする`..<` / `...`演算子、prefix/postfix範囲演算子もpublic global operatorとして
公開面に含める。Debug限定の`Result: Comparable`があると標準`Comparable`用Range演算子も
候補になり、同じ式のoverload resolutionがDebugとReleaseで変わり得る。

RedBlackTree固有のbound DSLである`start` / `last` / `end` / `lowerBound` / `upperBound` /
`find` / `equalRange`と関連operatorは、漏洩と決め付けず意図した公開APIか確認する。

## 重要な区別

### 公開メンバーの追加

`public`メンバーは、利用者がmoduleをimportすると外部所有型のメンバー候補として見える。
名前衝突やoverload resolutionへの影響がある。`Collection.nextPermutations()`は意図した
製品APIだが、`Int.__less()` / `__greater()`は赤黒木内部の都合を公開していないか確認する。

### Retroactive conformance

外部所有型を外部所有protocolへ適合させる変更は、単なるhelper追加より影響が大きい。
現在該当する重要例はDebug構成の`Result: Comparable`である。

Debug限定でも、Debugでライブラリを利用するclientと同一process内の他moduleへ適合が見える。
Releaseに存在しないため、構成によってgeneric制約の成立可否が変わる問題もある。
RedBlackTreeIndexを`Comparable`にする正式手段としては採用しない。

### Internal / package member

アクセス制御された追加メンバーは、通常は利用者のsource APIへ現れない。ただし
`@inlinable`な公開関数から使われる`@usableFromInline`宣言は、clientへ直列化される実装の
一部になり得る。source公開と同一ではないが、完全に自由な実装詳細ともみなさない。

## TestCodeへ移動できる候補

### 移動可能性が高い

| 対象 | 現在地 | 利用状況 | 移動先候補 | 備考 |
| --- | --- | --- | --- | --- |
| `Range` / `ClosedRange: SortedSequence` | `RedBlackTreeSet+SetAlgebra.swift` | `EtcTests.testAPICheck()`だけ | `RedBlackTreeTestSupport`または当該test file | DEBUG限定protocol、generic `union<S: SortedSequence>`、generic `___meld_unique<S>`、iterator `___copy_range`だけを一群で移す。productionの`___meld_unique(UnsafeTreeV2)`は移さない |
| Debug限定Index比較宣言群 | `_NodePtrSealing.swift`、`_LazyTie.swift`、`_LazyTieWrap.swift`、`_LazyTieWrap+Result.swift` | 番号付きIndex比較仕様テストで使用。性能実験の利用は未確認 | `RedBlackTreeTestSupport`または削除 | 正式APIにしない場合。4宣言を一群で処理する |
| 特殊化`Result.unsafe(tree:rawTag:)` | `_LazyTieWrap+Result.swift` | 4コンテナの`_98_IndexValidityXCTests`等だけ | `RedBlackTreeTestSupport` | 不正・任意tagのIndexを合成するfixtureであり、production処理から参照されない |

Debug限定Index比較宣言群の移動は、Indexを正式に`Comparable`へ適合させない場合に限る。
正式適合させる場合はTestCodeへ移すのではなく、固有Index型等でproductionに実装する。

### 本体に残すが公開範囲を狭める候補

| 対象 | 本体に必要な理由 | 対応候補 |
| --- | --- | --- |
| `Int: ThreeWayCompareResult`、`__int_compare_result`、`__less()` / `__greater()` | 赤黒木の検索・境界・比較アルゴリズムが使用 | TestCodeへは移さず、protocolを含む宣言群をpackage / `@usableFromInline`へ狭められるか確認 |
| 特殊化`Result`の`==` / `!=` | 現行Indexとsealed pointerの等価比較に使用 | Index再設計後に固有型または内部helperへ閉じる |
| `String`診断文言 | productionのprecondition/fatal errorで使用 | internalを維持 |
| `MemoryLayout` helper | bucket/node layout計算で使用 | internalを維持 |
| pointer操作extension | productionの木・allocatorアルゴリズムで使用 | internal/packageを維持し、public typealiasだけ監査 |
| `Collection.nextPermutations()` | PermutationModuleの意図した公開API | publicを維持 |

### 移動時の注意

- extensionだけを移してproduction側に専用protocolや専用algorithmを残さない。
- TestSupportへ置くconformanceはtest process内には影響するため、標準型への適合追加は
  最小限にする。
- `@testable import`だけに依存せず、package accessで必要なfixtureを構成できるか確認する。
- Debug/Release双方でtest target自体がcompileできる構造にし、`#if DEBUG`の位置を確認する。

## 残タスク

- [ ] `Int.__less()` / `__greater()`をpublicにする必要があるか確認する
- [ ] `ThreeWayCompareResult`と`__int_compare_result`を含むInt関連宣言群の可視性を確認する
- [ ] Debug限定Index比較4宣言をIndex設計の決定に従って一群で移動または削除する
- [ ] `SortedSequence`実験経路を一群でTestCodeへ移す
- [ ] Debug/package限定`Index.unsafe(tree:rawTag:)`をTestSupportへ移す（公開面ゲートではなくtest整理）
- [ ] 特殊化`Result`のpublic `==` / `!=`が必要か確認する
- [ ] `Result._NodePtr`と`UnsafeMutablePointer._NodePtr`のpublic typealiasを非公開化できるか確認する
- [ ] `_NodeRef`、`_SafePtr`、`_SealedPtr`、`_SafeRange`、`_SafeRangeExpression`、`_LazyTiedPtr`、`UnsafeNode.Seal`を追加監査する
- [ ] `_SealedPtr`を公開する`UnsafeIterator`のinitializer / propertyを追加監査する
- [ ] public global operatorとbound DSLを追加監査する
- [ ] 外部所有型extension内の全`public` / `package`メンバーを機械的に再抽出する
- [ ] 公開を維持するextensionをAPI MatrixまたはDocCへ記録する
- [ ] 内部用途のextensionは、可能なら名前空間を所有する内部型またはfree functionへ寄せる
- [ ] DebugとReleaseでprotocol conformance集合が変わる箇所をゼロまたは明示的な例外にする

## 完了条件

1. 外部所有型へ追加するすべての公開メンバーとprotocol conformanceが列挙されている。
2. 各項目について、製品API、境界内部、完全な内部用途のいずれかが決まっている。
3. 意図しない公開メンバーとretroactive conformanceが除去されている。
4. DebugとReleaseの差が診断コードだけに限定され、公開適合の集合を変えない。

この文書はpackage全体を一覧化するが、RedBlackTree完成を止めるのは
`RedBlackTreeCollections`の項目だけである。PermutationModuleの意図した
`nextPermutations()`公開はRedBlackTreeのゲートに含めない。`AcCollections`が
`RedBlackTreeCollections`を再公開するため、同moduleの漏洩はAcCollectionsにも波及する。

## 主な確認元

- `Sources/PermutationModule/Permutations.swift`
- `Sources/RedBlackTreeCollections/Implements/__tree/three_way_compare/three_way_compare_result.swift`
- `Sources/RedBlackTreeCollections/Implements/RawBuffer/_LazyTieWrap+Result.swift`
- `Sources/RedBlackTreeCollections/RedBlackTreeSet/RedBlackTreeSet+SetAlgebra.swift`
- `Sources/RedBlackTreeCollections/Implements/Misc/Message.swift`
- `Sources/RedBlackTreeCollections/Implements/RawBuffer/_BucketQueue.swift`
- `Sources/RedBlackTreeCollections/Implements/RawBuffer/UnsafeMutableRawPointer+malloc.swift`

## Gate A final extraction

2026-10-04 / Claude Opus 5.5。棚卸しのみ。分類・可視性の判断はしていない。この節のパスは
`Sources/RedBlackTreeCollections/`からの相対パス。

### 抽出方法

1. `swift build --target RedBlackTreeCollections`をDebugとReleaseで実行した
   (既定構成。`ALLOW_CROSS_TREE_INDEX`は有効)。
2. 構成の差分を見るため、Debugで`-Xswiftc -DCOMPATIBLE_ATCODER_2025`、`-DUSE_LAZY_DETACH`、
   `-DUSE_COMPACT_NODE_METADATA`を一つずつ付けて追加ビルドした。最後に既定のDebugで再ビルドした。
3. 生成した`.swiftmodule`から、`xcrun swift-symbolgraph-extract -minimum-access-level internal
   -emit-extension-block-symbols`でsymbol graphを出力した。出力先は一時ディレクトリで、作業後に削除した。
   `public`のままでは`_`接頭辞の宣言と`@_documentation(visibility: internal)`の宣言がgraphから
   除外されるため、internalまで出力し、`accessLevel`で絞り込んだ。
4. 実効public(宣言自体と親の型がすべてpublic)の宣言を集計した。protocol extensionの既定実装が
   各型へ複製された分(`::SYNTHESIZED::`)は除いた。結果はDebugで963件、Releaseで892件。
5. `RedBlackTreeCollections@Swift.symbols.json`(標準ライブラリ型へのextension)は全件を確認した。
   symbol graphに出ない`MemoryLayout` / `UnsafeMutableRawPointer`のメンバーはsourceで確認した。
6. 構成の分岐は、`#if`の入れ子ごとに中の`public`行を集計して確認した。
   `ALLOW_CROSS_TREE_INDEX`の無効化(`Package.swift`の`defines`に直書きされている)と`BENCHMARK`
   traitはビルドせず、sourceだけで確認した。

### 既存の表で網羅を確認した行

| 既存の行 | 機械抽出の結果 |
| --- | --- |
| `Int.__less()` / `__greater()` | `__tree/three_way_compare/three_way_compare_result.swift:30,32`。Debug/Releaseとも同じ |
| `Int: ThreeWayCompareResult` | `three_way_compare_result.swift`。protocolは`__tree/interfaces/tree_interface+three_way.swift:30`。Debug/Releaseとも同じ |
| `Int` / `Int32`の`_TrackingTag` | `__tree/_types/tree_basic+tag.swift:56-76`。package。`Int32`になるのは`USE_COMPACT_NODE_METADATA`のときだけ |
| `Result`ほかIndex比較宣言群(Debug) | 網羅を確認。細部は下の「欠落」1を参照 |
| 特殊化`Result`の`==` / `!=` | 3種類だけ: `_LazyTieWrappedPtr`(`RawBuffer/_LazyTieWrap+Result.swift:38,50`)、`_SafePtr`(`__tree/unsafe_node/unsafe_node+pointer+safe.swift:89,101`)、`_SealedPtr`(同`:175,187`) |
| `Result._NodePtr` | `unsafe_node+pointer+safe.swift:324`。制約は`Failure: Error`だけなので、すべての`Result`に付く |
| `Result.exists`(互換modeのみ) | `Implements/Deprecated/unsafe_node/unsafe_node+pointer+safe+deprecated.swift:67`。互換modeのビルドで追加を確認 |
| 特殊化`Result`のhelper | package/internalだけ。public・openはない |
| `Range` / `ClosedRange: SortedSequence` | `RedBlackTreeSet/RedBlackTreeSet+SetAlgebra.swift:130,132`。package protocol。Debugのみ |
| `String`の診断文言 | `Implements/Misc/Message.swift:26-71`。すべてinternal `@usableFromInline` |
| `MemoryLayout`のhelper | `Implements/RawBuffer/_BucketQueue.swift:78-85`。internal `@inlinable` |
| `UnsafeMutablePointer`の`_NodePtr` / `_NodeRef` | `__tree/unsafe_node/unsafe_node+pointer.swift:25-26` |
| `UnsafeMutablePointer`のhelper | public・openはない。表は「internal中心」だが、実際は`nullptr`、`__left_`、`__right_`、`__parent_`、`__is_black_`、`___is_end`などpackageが中心(`unsafe_node+pointer.swift:30-76`、`unsafe_node+pointer+validation.swift:26-36`) |
| `UnsafeMutableRawPointer`のhelper | `Implements/RawBuffer/UnsafeMutableRawPointer+malloc.swift:25,52`。internal `@inlinable`。`USE_C_MALLOC`で分岐する |
| Index range演算子とbound DSL | Index演算子は5つ(`Implements/Index/UnsafeIndexV3RangeExpression.swift:44,52,60,65,70`)。bound DSL演算子も5つ(`Implements/BoundsExpression/RedBlackTreeBoundRangeExpression.swift:83,92,101,108,115`)。global関数は`start` / `last` / `end` / `lowerBound` / `upperBound` / `find`(`RedBlackTreeBoundExpression+TopLevel.swift:31-79`)と`equalRange`(`RedBlackTreeBoundRangeExpression.swift:122`) |

既存の表にない標準ライブラリ型へのextensionはない。`@retroactive`は1か所だけ
(`_LazyTieWrap+Result.swift:109`)。`open`、`@_spi`、`@_implementationOnly`、
`@_alwaysEmitIntoClient`はない。

### 新しく見つかった欠落

1. **Debug限定`Result: Comparable`の適用範囲。** `_LazyTieWrap+Result.swift:109-111`の適合は
   `where Success: Comparable, Failure: Comparable`の汎用条件付きである。Indexだけでなく、条件を満たす
   すべての`Result`(利用者の型を含む)に適合する。このとき`>`、`<=`、`>=`と範囲演算子5種もpublicになる。
   同じくDebug限定で`_LazyTieWrap: Comparable`(`RawBuffer/_LazyTieWrap.swift:60`)と
   `_NodePtrSealing: Comparable`(`__tree/unsafe_node/Seal/_NodePtrSealing.swift:166`)がある。
2. **Debug限定のpublic protocol群とコンテナの適合。** `Implements/Protocol/BalancedSequence.swift:32-182`に
   `BalancedSequence`、`BalancedCollection`、`BalancedMultiCollection`、`BalancedView`、`BalancedDynamic`、
   `BalancedSomething`がある。4コンテナとKeyOnly/KeyValue Range Viewは、Debugでだけこれらに適合する
   (`:186-`)。適合を外すと性能に影響するというTODOがある。これらのprotocolはIndex、IndexRange、
   Boundを関連型に持つ。
3. **Debug限定のpublicメンバー。** `RedBlackTreeSet.freeCapacity`(`BalancedSequence.swift:193`。
   `DEBUG && !COMPATIBLE_ATCODER_2025`)。`RedBlackTreeBoundExpression.index(_:)` / `.debug(_:)`
   (`Implements/BoundsExpression/RedBlackTreeBoundExpression.swift:209,214`)。
4. **underscore名のpublic protocol 45個。** `__tree/_types/tree_basic+types.swift:47-218`、
   `__tree/base/tree_base+{interface,common,compare,distance,keyValue,scalar}.swift`、
   `__tree/interfaces/tree_interface+base.swift:141`、`__tree/unsafe_tree/unsafe_tree+types.swift:24`、
   `Implements/Protocol/_BaseV2.swift:32,38`、`Implements/Protocol/_BridgeV2.swift:24-36`にある
   (`_BaseType`系、`_Base*Interface/Protocol`系、`_*Bride`、`_NodePtrType`、`_UnsafeNodePtrType`、
   `___Root`、`_pointer_type`など)。このうち、Set / MultiSetは10個(`_BaseBridge`、`_KeyBride`、
   `_ElementType`、`_UnsafeNodePtrType`、`___Root`など)に適合する。Dictionary / MultiMapは、それに
   `_MappedValueBride`と`_MappedValueType`を加えた12個に適合する。Range Viewは
   `Container: ___Root`、`Container.Base: ___TreeBase & ScalarValueTrait / PairValueTrait`を
   generic制約に使うので、public signatureから到達する。
5. **underscore名でないpublic protocol 15個。** `ComparableKeyTrait`、`ScalarValueTrait`、`KeyValueTrait`、
   `PairValueTrait`、`ValueComparer`、`UniqueMultiplicity`、`MultiMultiplicity`
   (`__tree/base/tree_base+trait.swift:28-92`)、`MultiplicityHelper`(`tree_base+interface.swift:91`)、
   `ThreeWayCompareResult`、`UnsafeTreeBindingV2`(`_BaseV2.swift:45`)、`ObverseIterator` /
   `ReverseIterator` / `UnsafeIteratorProtocol` / `UnsafeAssosiatedIterator`
   (`Implements/Iterator/UnsafeIterator/UnsafeIterator+Protocol.swift:24-48`)、`LinkPairValueTrait`。
   `UnsafeIteratorProtocol.init(_start:_end:)`もpublic requirementである。
6. **既存の文書が触れていないトップレベルのpublic typealias。** `___TreeBase`、`___TreeIndex`
   (`_BaseV2.swift:27,29`)、`UnsafeIndexV3`(`Implements/Index/UnsafeIndexV3.swift:27`)、
   `_LazyTieWrappedPtr`(`_LazyTieWrap+Result.swift:33`)、`_NodeRange`(`RawRange/_RawRange.swift:102`)、
   `_NodeRangeExpression`(`RawRange/_RawRangeExpression.swift:205`)、`_TrackingTag`という型名そのもの
   (`tree_basic+tag.swift:47,49`)。
7. **内部実装由来に見えるトップレベルのpublic型。** `UnsafeTreeV2`(`UnsafeTreeV2/UnsafeTreeV2.swift:25`。
   publicメンバーは`__construct_node(_:)`、`_NodePtr`、`_NodeRef`、`_Key`、`_PayloadValue`、
   `_PayloadValues`、`_KeyValues`、`Tree`、`isMulti`、`subscript(_:default:)`、`==`、`<`、`hash`、
   `description`)。`UnsafeNode`(`__tree/unsafe_node/unsafe_node.swift:113-228`。public init、
   `___tracking_tag`、`___recycle_count`、`___has_payload_content`、`__is_black_`、`__left_`、
   `__right_`、`__parent_`)。`_RawRange`(`RawRange/_RawRange.swift:23`)。`_RawRangeExpression`
   (`_RawRangeExpression.swift:23`。publicなcase 6個と`==` / `!=`)。`__UniqueHelper` /
   `__MultiHelper`(`tree_base+compare.swift:44,95`)。`__eager_compare_result`
   (`three_way_compare_result.swift:37`)。`UnsafeIndexV3Range` / `UnsafeIndexV3RangeExpression`
   (`Implements/Index/`)。`RedBlackTreeIterator`(`Implements/Iterator/RedBlackTreeIteratorV2.swift:23`)。
8. **`UnsafeIterator`のpublicなnested型。** 既定構成でも`Implements/Deprecated/Iterator/`の
   `_Obverse1-3`と`_Reverse1-3`がコンパイルされ、`_start`、`_end`、`_current`、`_sealed_*`、`_safe_*`が
   publicになっている。ほかに`_CopyOnWrite`、`_Payload`、`_Key`、`_KeyValue`、`_MappedValue`、
   `_Obverse4`、`_Reverse4`がある。後者はコンテナの`Keys`、`makeIterator()`(`Tree._PayloadValues`)、
   `RedBlackTreeIterator.*`、`UnsafeIterator.*Obverse/*Reverse`(`UnsafeIterator.swift:29-46`)
   を通じてpublic signatureから到達する。
9. **コンテナ内のnested `Base` enum(4つ)と、そのunderscore名typealias。**
   `RedBlackTreeSet.Base._Key` / `_PayloadValue`など(`RedBlackTreeSet/RedBlackTreeSet.swift:109-111`。
   ほか3コンテナも同様)。Viewの`Base`、`Key`、`Value`、`Element`は`Container.Base._Key`などを露出する。
10. **3つのViewの`_isIdentical(to:)`。** `RedBlackTreeView/*.swift:351,351,422`。
11. **Memoize群。** `___LRUMemoizeStorage`(`Implements/Memoize/___LRUMemoizeStorage.swift:28`)、
    `_LinkingPair`、`___LRULinkListBase`、`LinkPairValueTrait`(`___LRULinkList.swift:23,40,71`)。
    リポジトリ内の利用は`Tests/RedBlackTreeTests/memoize/`だけ。
12. **既存の表にない標準型extension(client影響なし)。** すべての`Result`に付くinternal
    `flatMapThrowing`(`UnsafeTreeV2/UnsafeTreeV2+Erase.swift:146`)。`Result where Failure == SealError`の
    package `error`(`unsafe_node+pointer+safe.swift:330`)。
13. **`@frozen`のレイアウトを通じた露出。** `@frozen`は46か所。4コンテナは
    `package @usableFromInline var __tree_: UnsafeTreeV2<Base>`を保持する。`UnsafeTreeV2`は
    `@usableFromInline var _buffer`を保持する。3つのViewは`@usableFromInline var _sealed_start/_end:
    _SealedPtr`を保持する。`_NodePtrSealing`と`_LazyTieWrap`(保存プロパティは`_LazyTie`)も`@frozen`で
    ある。`@inlinable`は1572か所、`@usableFromInline`は380か所で、宣言単位では列挙していない。
    `@_documentation(visibility: internal)`は22か所あるが、source上はpublicのままである。

### 構成によってだけ変わる公開面

| 構成 | 差分(ビルドで確認したものは「実測」) |
| --- | --- |
| Debug / Release | 実測。Debugだけにある実効public宣言が71件、Releaseだけにあるものは0件。内訳は上の欠落1〜3とBalanced protocolの要求。Debugだけにある適合は、`Result: Comparable`、`_LazyTieWrap: Comparable/Equatable`(条件付き)、`_NodePtrSealing: Comparable`、コンテナとViewのBalanced*適合 |
| `COMPATIBLE_ATCODER_2025` | 実測。追加340件、削除297件。3つのView型が消え、`RedBlackTreeSliceV2`、`UnsafeIndexV2`(`@frozen`のnominal型)、`UnsafeIndexV2Collection`、`UnsafeIndexV2RangeExpression`、`UnsafeIndexBindingV2`、`UnsafeIndicesBinding`、`CompareTrait`、global演算子`+` / `-`(`UnsafeIndexV2`)、`Result.exists`が増える。コンテナの`Index`は`UnsafeIndexV2<Base>`、`SubSequence`は`RedBlackTreeSliceV2`になる。`AcCollections`は`RedBlackTreeModule`と`PermutationModule`も再公開する(`Sources/AcCollections/AcCollections.swift`) |
| `USE_LAZY_DETACH` | 実測。publicメソッドが4つ消える: `RedBlackTreeSet` / `RedBlackTreeMultiMap`の`index(inserting:)`と`erase(exactly:)`(`RedBlackTreeSet+Index.swift:263-`、`RedBlackTreeMultiMap+Index.swift:286-`)。`@frozen _NodePtrSealing`の保存プロパティ`trackingTag`も消えるので(`_NodePtrSealing.swift:40-42`)、Indexのレイアウトが変わる |
| `USE_COMPACT_NODE_METADATA` | 実測。`_TrackingTag`が`Int`から`Int32`へ、`UnsafeNode.Seal`が`UInt32`から`UInt16`へ変わる。`@frozen UnsafeNode`と`_NodePtrSealing`のレイアウトも変わる |
| `ALLOW_CROSS_TREE_INDEX`の無効化 | sourceのみ。publicな`SealError.crossTree`が増える(`unsafe_node+pointer+safe.swift:260-263`)。上記4メソッドが消える |
| `BENCHMARK` | sourceのみ。`UnsafeIterator._Indices`、`RedBlackTreeDictionary.__indices`、`RedBlackTreeSet.__raw_find(_:)` / `__raw_end`が増える(`*+Benchmark.swift:27-32`、`Iterator/UnsafeIterator/UnsafeIterator+Index.swift:27`) |
| `USE_INT128`、`USE_C_MALLOC`ほか | sourceのみ。public行の差はpackage型の中(`_NodePathBitmap`)かinternal extensionにしかなく、client向けの公開面は変わらない |

### Index契約が決まるまで分類を保留する宣言

- alias chain: `RedBlackTreeIndex` → `UnsafeIndexV3` → `_LazyTieWrappedPtr` →
  `Result<_LazyTieWrap<_NodePtrSealing>, SealError>`。関連する`_LazyTiedPtr`。
- `_LazyTieWrap`、`_NodePtrSealing`(`_NodePtr`、`hash`、`description`を含む)、`SealError`
  (全case、`Equatable` / `Comparable` / `Hashable`、構成で変わる`crossTree`)。
- `_SealedPtr`、`_SafePtr`、特殊化`Result`の`==` / `!=`(3種類)、`Result._NodePtr`。
- Debug限定の`Result: Comparable`、`_LazyTieWrap` / `_NodePtrSealing`の`<`、Balanced* protocol群と
  その適合、`RedBlackTreeBoundExpression.index(_:)` / `.debug(_:)`。
- `UnsafeIndexV3Range` / `RedBlackTreeIndexRange`、`UnsafeIndexV3RangeExpression` /
  `RedBlackTreeIndexRangeExpression`、`_RawRange` / `_NodeRange` / `_SafeRange`、
  `_RawRangeExpression` / `_NodeRangeExpression` / `_SafeRangeExpression`、Index range演算子5つ。
- `index(inserting:)` / `erase(exactly:)`(構成で有無が変わる)。
- 3つのViewの保存プロパティ`_sealed_start/_end`。`UnsafeIterator`各型のpublicな`_sealed_*` / `_safe_*`
  と`UnsafeIteratorProtocol.init(_start:_end:)`。
- Indexのレイアウトに入る`UnsafeNode`、`UnsafeNode.Seal`、`_TrackingTag`。
- 互換modeの`UnsafeIndexV2`系(互換modeのIndex契約として別に扱う)。

Index表現に依存しないもの(Bで分類できる): 欠落4〜11のうち上に挙げていない宣言。具体的には、protocol階層、
trait、`ThreeWayCompareResult`系、`UnsafeTreeV2`のメンバー、`UnsafeIterator`のうち`_sealed_*`以外、
`Base` enum、`_isIdentical`、Memoize群、`__UniqueHelper` / `__MultiHelper` / `__eager_compare_result`、
`___TreeBase` / `___TreeIndex`。

### 判定

`complete for classification`。

既定構成のDebug/Releaseと、3つの構成(互換mode、`USE_LAZY_DETACH`、`USE_COMPACT_NODE_METADATA`)は、
symbol graphで実効publicの宣言と適合を全件抽出した。残りはブロッカーではない。

- `ALLOW_CROSS_TREE_INDEX`の無効化と`BENCHMARK`はsourceだけで確認した。差分は上の表に挙げた
  宣言に限られる。実測するには`Package.swift`の`defines`を一時的に変更するか、trait付きでビルドする必要がある。
- Index表現に拘束される宣言は上に列挙した。B以降では「Index表現拘束」として分類だけ行い、Fまで狭めない。
- 残タスクの「外部所有型extension内の全`public` / `package`メンバーを機械的に再抽出する」は、
  この節で実施した。チェックボックスは更新していない。

## Gate B classification draft

2026-10-04 / Codex。Gate Aの列挙結果を、変更の可否ではなく、外部契約との関係と
実装順で分類する。これは実装指示ではない。Claudeのread-only反証レビューを受けてから
変更バッチを確定する。

### B1. 意図した製品API

| 宣言群 | 判定 | 理由・次の確認 |
| --- | --- | --- |
| 4コンテナと利用者向けcollection操作 | 製品API | packageの中心。API MatrixとDocCを契約の正本候補にする |
| KeyOnly / KeyValue / Mapped Values View | 製品API | Range/View契約として公開済み。内部型の露出は別に縮小する |
| bound DSL (`start` / `last` / `end` / `lowerBound` / `upperBound` / `find` / `equalRange`とoperator) | 製品API候補 | Test as Specificationとガイドで利用を確認し、意図したDSLであることを最終確認する |
| `RedBlackTreeIterator`等、Collection要件から直接返す型 | 製品APIまたは公開必須境界 | 型名・操作を公開する必要と、内部nested型まで露出する必要は分けて扱う |

### B2. Index表現拘束 — 分類だけ行いF〜Kまで変更しない

Gate Aの「Index契約が決まるまで分類を保留する宣言」全体を一つの変更境界とする。
具体的にはIndex alias chain、`_LazyTieWrap`、`_NodePtrSealing`、`SealError`、safe/sealed pointer、
Index range、関連operator、Viewのsealed端点、iteratorのsealed/safe member、Indexに入る
`UnsafeNode` / `Seal` / tracking tag、Debug Comparable群、Balanced protocol群、互換Indexを含む。

この群は「公開維持」と判定したのではない。現行public signatureを成立させるため、
外部契約Fと表現Iが決まるまでaccess変更しないという保留である。

### B3. 境界内部 — 製品APIではないが、現在のpublic signatureから到達する

| 宣言群 | 分類 | 変更条件 |
| --- | --- | --- |
| 45個のunderscore public protocolと15個の内部由来public protocol | 境界内部 | 4コンテナ、View、iteratorのpublic generic constraintから切り離す設計を先に作る |
| `UnsafeTreeV2`のIndex非依存部分とhelper型 | 境界内部 | `@frozen` storage、public alias、public member signatureを一つのバッチで解消する。`UnsafeNode`、`_RawRange*`、`UnsafeTreeV2.Index`はB2所有 |
| 4コンテナとViewのnested `Base`およびunderscore alias | 境界内部 | Viewとiteratorが参照するassociated typeを同時に置換する |
| UnsafeIteratorのnested型とpublic member | 境界内部 | Collectionが返すiterator表面と、node pointerを運ぶ内部表現を分離する |
| `__UniqueHelper` / `__MultiHelper` / `__eager_compare_result` | 完全内部候補 | public protocol requirementまたは`@inlinable`依存を外してから狭める |
| `_isIdentical(to:)` | 境界内部候補 | 最適化用のpublic underscored hookとして必要か、内部比較へ閉じられるか確認する |

この群は名前が内部風だから即時に非公開化するのではない。public signatureから到達しているため、
先に外側のsignatureを所有型または標準protocolだけで表現できるようにする。

### B4. Index非依存で先行調査・変更できる候補

| バッチ | 対象 | 暫定判定 | 実装前ゲート |
| --- | --- | --- | --- |
| B4-a | `ThreeWayCompareResult`、`__int_compare_result`、`Int.__less()` / `__greater()` | 赤黒木内部の比較機構。製品APIではない | public `@inlinable`から必要なvisibilityをtypecheckし、protocol・witness・aliasを一群で縮小できることを確認 |
| B4-b | Memoize群 | TestCode候補 | `Tests/RedBlackTreeTests/memoize/`以外の参照がないこと、production targetから外してtest targetで成立することを確認 |
| B4-c | Debug限定`SortedSequence`実験経路 | TestCode候補 | production `___meld_unique(UnsafeTreeV2)`を含めず、generic実験overloadとtestだけを一群で移す |

最初の実装候補はB4-aとする。変更範囲が比較的局所で、Index表現を決めずに標準型`Int`への
public member追加を除去できる可能性がある。ただし`@inlinable`のvisibility制約を満たさない
access縮小は行わない。

### B5. TestCode専用と判断できるが、Index決定または別設計を待つもの

- Debug限定Index Comparable群: Comparable採否Dと表現Iを待つ。
- `Result.unsafe(tree:rawTag:)`: test fixtureだが、現行Index aliasとtest support境界の整理時に移す。
- Balanced protocol群: Debug限定である点は解消対象だが、Index、Range、性能TODOと結び付くため
  単純移動しない。要件としてだけ存在する`RedBlackTreeSet.freeCapacity`も同じバッチで扱う。
- deprecated iterator `_Obverse1-3` / `_Reverse1-3`: 既定buildへ入る理由と互換API参照を確認してから、
  TestCode、compat隔離、削除のいずれかを決める。
- BENCHMARK限定`UnsafeIterator._Indices` / `__indices`はIndexを直接返すためB2所有とする。
  `__raw_find` / `__raw_end`は`UnsafeNode`と`UnsafeTreeV2`に依存するためB2/B3の変更後に扱う。
  `Benchmarks/`は別packageなので、単純なpackage化はできない。trait限定publicの維持、SPI、
  benchmark実装変更のいずれかを別途選ぶ。

### Gate B draft verdict

- Gate Aの列挙は完了として扱える。
- Index拘束群と境界内部群を先に狭めない。
- 最初の安全な候補はB4-aのThreeWay比較宣言群。ただしtypecheck前提であり、まだ実装指示ではない。
- B4-bはproduct owner判断を待つ。B4-cは独立バッチ化できる。旧B4-d/eはB2/B5へ再分類した。
- この分類をClaudeが反証し、blocking correctionがなければGate Bを確定する。

### Claude review of Gate B draft

2026-10-04 / Claude Opus 5.5。read-onlyのレビュー。source、test、`Package.swift`は変更しておらず、
buildとtestも実行していない。パスはrepository rootからの相対パス。

#### Blocking corrections

1. **B4-dはB4に置けない。** `RedBlackTreeSet.freeCapacity`
   (`Sources/RedBlackTreeCollections/Implements/Protocol/BalancedSequence.swift:193`)の参照はrepository内に
   なく、Debug限定protocol `BalancedDynamic`の要件`var freeCapacity`(同`:176`)を満たすためだけに存在する。
   このメンバーを単独で消すと`extension RedBlackTreeSet: BalancedDynamic`がcompileできない。Balanced群は
   性能TODO(同`:187`)によりB5で「単純移動しない」としているので、freeCapacityもBalanced群と同じ
   バッチにする必要がある。B5へ移すこと。
2. **B4-eはIndex非依存ではなく、package境界でも成立しない。**
   - `UnsafeIterator._Indices.next() -> UnsafeIndexV3?`
     (`Sources/RedBlackTreeCollections/Implements/Iterator/UnsafeIterator/UnsafeIterator+Index.swift`)は、
     現行のIndex表現をそのまま返す。`__indices`はB2に属する。
   - `RedBlackTreeSet.__raw_find(_:)`と`__raw_end`は`_NodePtr`(`UnsafeMutablePointer<UnsafeNode>`)を返す
     (`RedBlackTreeSet/RedBlackTreeSet+Benchmark.swift:27-32`)。B2(UnsafeNode)とB3(`UnsafeTreeV2`)に
     依存する。
   - 利用者の`Benchmarks/`は別package(`Benchmarks/Package.swift:17-19`。`path: ".."`、
     `traits: ["BENCHMARK"]`)である。そのため`package` accessも`@testable`(Releaseの`swift run`)も
     使えない。実装前ゲートの「package/test support経由で利用できるか」は、構造上必ず否になる。
   - 現実的な選択肢は、`BENCHMARK` trait限定のpublicを維持するか、`@_spi`か、benchmarkの実装方法を
     変えるかである。これを明記したうえで、`__indices`はB2、`__raw_*`はB3との依存付きに分類し直すこと。
     `Benchmarks/Sources/Benchmarks/RedBlackTreeSetBenchmarks.swift:447-468`と
     `RedBlackTreeDictionaryBenchmarks.swift:90`がCIのbenchmark jobで使われている。
3. **B2とB3の境界が重複している。** B3の2行目は`UnsafeNode`と`_RawRange*`を含む。しかし`UnsafeNode`、
   `Seal`、tracking tagはIndexのレイアウトに入り(`_NodePtrSealing`の保存プロパティ)、`_RawRange` /
   `_RawRangeExpression`は`UnsafeIndexV3Range` / `UnsafeIndexV3RangeExpression`の保存プロパティである
   (`Implements/Index/UnsafeIndexV3Range.swift:31`、`UnsafeIndexV3RangeExpression.swift:28`)。
   どちらもB2の範囲にある。B3から外すか、「B2所有。参照だけ」と明記すること。同じ行の`UnsafeTreeV2`のうち、
   `UnsafeTreeV2.Index = RedBlackTreeIndex`(`UnsafeTreeV2/UnsafeTreeV2+Index.swift:26`)もB2所有になる。

#### Non-blocking safeguards

- **B4-aの範囲。**
  - `__eager_compare_result`も同じ比較機構に属する。protocolだけを狭めても、public structがpackage
    protocolへ適合する形になるだけでcompileはできる。ただし公開面を一度で閉じるなら、B4-aに含めるのが自然である。
  - repository内の利用者はtestだけである(`Tests/RedBlackTreeLegacyTests/ArrayBasedFixture/TreeFixtures.swift:147`、
    `Tests/RedBlackTreeTests/RedBlackTreeInternal/Synthetic/RedBlackTreeInternal_98_CoverageTests.swift:56-61`)。
- **B4-aの検証範囲。**
  - `ThreeWayCompareResult`、`__int_compare_result`、`Int.__less/__greater`、`__eager_compare_result`は、
    次のtest targetで直接使われている。
    - `RedBlackTreeTreeTests`(`TreeFoundamentalComparisonInjectionTests`、`TreeFoundamentalValueTests`)
    - `RedBlackTreeLegacyTests`(原木のコピー`ArrayBased/tree+{find,bounds,count,equal}.swift`)
    - `RedBlackTreeTests`(`DebugAdditionals/ThreeWay+Old/three_way_compare_result.swift`。public型が
      `ThreeWayCompareResult`へ適合している)
  - 同じpackageなので`package`まで狭めても参照できる。internalまで狭めると`@testable`が必要になり、
    Release testで壊れる箇所が出る。
  - 縮小の下限は`@usableFromInline package`とし、DebugとReleaseの両方で上記3 targetをbuildして確認すること。
  - 関連するprotocolは`_ThreeWayResultType` / `_TreeKey_*ThreeWayCompInterface` / `IntThreeWayComparator`
    で、すでにpackageである(`Implements/__tree/interfaces/tree_interface+three_way.swift:37-60`、
    `Implements/__tree/unsafe_tree/unsafe_tree+three_way.swift:24-26`)。publicなprotocol要件や
    public signatureからの参照はない。互換modeのsourceにも参照はない。
  - 設計文書`Sources/RedBlackTreeCollections/Documentation/Design/Design-InternalArchitecture.md:160`は
    このprotocolに言及しているので、同期すること。
- **B4-aは利用者から見える削除である。** public `Int`メンバーとpublic protocolの削除は、理論上
  source-breakingになる。CHANGELOGへの記載が必要。
- **B4-bはproduct ownerの確認が要る。**
  - 参照は`Tests/RedBlackTreeTests/memoize/MemoizeCacheLRUTests.swift`(`#if DEBUG`と`@testable`)だけで、
    production、Benchmarks、AcCollectionsからは使われていない。
  - ただし`CHANGELOG.md:396`(0.1.33)では「memoize cache機能」として公開された経緯がある。
    `Sources/RedBlackTreeCollections/Documentation/MEMO.md:67`は、`swift-ac-memoize`をdropしたと記録している。
  - drop前のrelease利用者がいる可能性を考えると、製品surfaceからの削除はuserの判断事項になる。
    test targetへ移す場合は、実装がinternalな`___LRUHandle`とtreeの内部要素に依存するので、`@testable`
    (Debug限定)で成立するか、package化が必要かを確認すること。memoize testはuser指示により保持する。
- **B4-cはcompile可能だと確認した。**
  - test targetへ移す対象は、`SortedSequence`、`Range` / `ClosedRange`の適合、generic `union<S>`
    (`RedBlackTreeSet/RedBlackTreeSet+SetAlgebra.swift:122-144`)、generic `___copy_range<Iterator>` /
    `___meld_unique<S>`(`Implements/UnsafeTreeV2/UnsafeTreeV2+SetAlgebra.swift:210-278`)の一群である。
  - production側には、非genericの`___copy_range` / `___meld_unique(_ other: UnsafeTreeV2)`(同`:26,42`。
    公開`union`が使用)が残る。
  - 唯一の利用者`Tests/RedBlackTreeTests/EtcTests.swift:49-58`は`#if !COMPATIBLE_ATCODER_2025 && DEBUG`かつ
    `@testable`なので、移した側も同じguardにすること。test moduleで標準`Range`へ適合を追加すると、test process
    全体に適合が見える点は残る。
- **B3のiterator行。** 既定構成でsealed / safe memberを持つのは、deprecatedの`_Obverse1-3` / `_Reverse1-3`
  (B5)だけである。現行の`_Obverse4.next()`は`_NodePtr?`を返す(`UnsafeIterator+Obverse4.swift:47`)。
  iteratorの表面を狭めるときは、`UnsafeNode`のaccess(B2)を変えずに、内部保持へ移すだけに留めること。

#### Confirmed classifications

- B1: 4コンテナ、3つのView、bound DSL(global関数7つと演算子5つ)を製品APIまたはその候補とする分類は妥当。
- B2: Gate Aの保留リストを一つの変更境界にする扱いは妥当。Balanced群とDebug Comparable群をB2とB5の
  両方に記載しているが、「Index決定待ち」という結論は一致しているので問題ない。
- B3: protocol階層、nested `Base`、`_isIdentical`は境界内部として妥当。`_isIdentical`はViewだけにあり、
  4コンテナは`isTriviallyIdentical`(`*+IsTriviallyIdentical.swift`)を持つ。
- B4-a: Index表現には依存しない。現行のpublic signatureからも到達しない。
- B4-c: Index非依存で、独立してcompileできる。production `___meld_unique`との分離も正しい。
- B5: `Result.unsafe(tree:rawTag:)`とdeprecated iteratorの保留は妥当。

#### Verdict

B4-aを最初の実装作業指示にしてよい。条件は次のとおり。

- 縮小の下限を`@usableFromInline package`とする。
- `__eager_compare_result`を含めるかどうかを指示書に明記する。
- 上記3つのtest targetをDebugとReleaseの両方でbuild・実行する。
- 設計文書とCHANGELOGを同期する。

Gate Bの確定前に、blocking 1〜3(B4-dとB4-eの再分類、B2とB3の重複解消)を反映すること。
B4-bは技術的には独立できるが、product ownerの判断を待つ。

### B4-a implementation result

2026-10-04 / Codex。Claude reviewのblocking correctionをGate Bへ反映したうえで、
最初の独立バッチとしてThreeWay比較宣言群を縮小した。

- `ThreeWayCompareResult`、`__int_compare_result`、`Int.__less()` / `__greater()`、
  `__eager_compare_result`を`@usableFromInline package`または`@inlinable package`へ変更した。
- public `@inlinable`から必要な可視性は維持し、標準型`Int`へ追加していたpublic memberと
  public protocolを製品APIから除いた。
- `Design-InternalArchitecture.md`と`CHANGELOG.md`を同期した。
- Xcode buildは成功。`RedBlackTreeTreeTests`、`RedBlackTreeLegacyTests`、
  `RedBlackTreeTests`をDebug/Releaseで実行し、実行されたtestは成功した。Releaseの
  `RedBlackTreeLegacyTests` filterだけは対象testが構成上存在せず、build成功・0件実行だった。
- `git diff --check`は成功した。

Gate B分類はClaude reviewを反映済みとして確定する。公開面全体の縮小は未完了だが、
B4-aは完了した。

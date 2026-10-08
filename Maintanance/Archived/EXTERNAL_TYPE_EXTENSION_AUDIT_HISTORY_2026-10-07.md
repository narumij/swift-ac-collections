# 外部所有型Extension監査（2026-10-07アーカイブ前スナップショット）

最終更新: 2026-10-07 / Codex

> 現在の状態(2026-10-06): 機械抽出と分類、独立縮小可能なbatchは完了。残る対象は
> Index契約依存、外部consumer移行待ち、または凍結clusterであり、明示的な再開条件が満たされるまで
> 本文中の旧「次タスク」を現行指示として扱わない。
>
> 2026-10-07追記: 特殊化`Result`のpublic比較overloadとpublic `Result._NodePtr`の縮小は完了した。
> Debug / Release / 互換mode / DocCの検証に加え、GitHub Actionsのperformance job成功
> (run 37502938888、job 112404281751、5分34秒)を確認した。これらを一つの完了単位として閉じる。
> 後続コミットで削除した`Result: @retroactive Comparable`と旧Result-based Index helperもこの完了を
> 妨げない。残るDebug比較3宣言は別の凍結taskであり、本項目へ戻さない。

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

- [x] `Int.__less()` / `__greater()`をpublicにする必要があるか確認し、B4-aでpackageへ縮小する
- [x] `ThreeWayCompareResult`と`__int_compare_result`を含むInt関連宣言群の可視性を確認し、B4-aでpackageへ縮小する
- [ ] Debug限定Index比較4宣言をIndex設計の決定に従って一群で移動または削除する（2026-10-06: うち`Result: @retroactive Comparable`はPR #158後に利用者0件と確認し、ユーザー指示で削除済み。残りは`_LazyTieWrap`・`_NodePtrSealing`・`_LazyTie`の3宣言）
- [ ] `SortedSequence`実験経路を一群でTestCodeへ移す
- [ ] Debug/package限定`Index.unsafe(tree:rawTag:)`をTestSupportへ移す（公開面ゲートではなくtest整理）
- [x] 特殊化`Result`のpublic `==` / `!=`が必要か確認する（2026-10-06ユーザー判断: `_SafePtr`・`_SealedPtr`用はpackage、`_LazyTieWrappedPtr`用はRedBlackTreeTestsへ移動。標準の`Equatable`適合があるので外部の比較結果は不変）
- [x] `Result._NodePtr`と`UnsafeMutablePointer._NodePtr`のpublic typealiasを非公開化できるか確認する（2026-10-06ユーザー判断: `Result._NodePtr`は`@usableFromInline package`、`UnsafeMutablePointer`の`_NodePtr` / `_NodeRef`は現状維持）
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

- alias chain: `RedBlackTreeIndex` → `UnsafeIndexV3` → `_LazyTiedPtr` → `_LazyTieWrap<_NodePtrSealing>`
  (PR #158で切替。以前の`UnsafeIndexV3`は`_LazyTieWrappedPtr`の別名)。public aliasとして残る
  `_LazyTieWrappedPtr` = `Result<_LazyTieWrap<_NodePtrSealing>, SealError>`。
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

### B4-c implementation result

2026-10-04 / Codex。Debug限定の`SortedSequence`、`Range` / `ClosedRange`適合、
generic `union` / `___meld_unique` / iterator版`___copy_range`を、唯一の利用者である
`EtcTests.swift`へ移した。productionで使う非genericのtree-to-tree set algebra経路は変更していない。

- Xcode file diagnosticsとproject buildは成功した。
- `EtcTests.testAPICheck`は1件成功した。
- Releaseのpackage buildは成功した。
- `git diff --check`は成功した。

B4-cは完了した。標準型へのtest-only conformanceはtest process内に限定される。

### B4-b external-consumer decision

2026-10-04 / User + Codex。B4-bのMemoize群は現時点でTestCodeへ移さず、外部consumerの
移行待ちとして保留する。

- `swift-ac-memoize`は次回AtCoder向けでは削除予定。ただし現在の`main`は
  `AcCollections`（`compatible/AtCoder/2025`）へ依存し、LRU cacheをbalanced treeで実装すると
  公開説明している。
- `Memoization`は今後のんびり継続する別プロジェクトで、現在の`main`も
  `swift-ac-collections` 0.1.30以降の`AcCollections`へ依存している。
- このrepositoryのMemoize群はproduction内部からは使われていないが、外部packageの依存が
  残っているため「repository内参照がtestだけ」を根拠に非公開化しない。

解除条件は、(1) `swift-ac-memoize`の次回AtCoder系から依存を削除またはrepositoryを終了し、
(2) `Memoization`が独自実装へ移行するか、必要な正式APIを別途固定した後とする。それまでは
新規の製品中心APIとして拡張せず、互換維持対象として扱う。

### _isIdentical implementation result

2026-10-04 / Claude Opus 5.5。Codexの割り当てに基づき実装した。

- 次の3宣言について、`@inlinable public func _isIdentical(to:)`を
  `@inlinable internal func _isIdentical(to:)`へ変更した。本体と`@inlinable`は変更していない。
  - `Sources/RedBlackTreeCollections/RedBlackTreeView/RedBlackTreeRangeView+KeyOnly.swift:351`
  - `Sources/RedBlackTreeCollections/RedBlackTreeView/RedBlackTreeRangeView+KeyValue.swift:422`
  - `Sources/RedBlackTreeCollections/RedBlackTreeView/RedBlackTreeMappedValuesView.swift:351`
- 下限の判断:
  - internalの`@inlinable`宣言は、それ自体で`@usableFromInline`として扱われる。そのため、
    public `@inlinable`の`==` / `<`から呼び出せる。`@usableFromInline`を重ねて付ける必要はない。
  - 呼び出し元はpackage内にないので、`package`は不要である。
  - DebugとReleaseのbuildがどちらも成功したことで確認した。
- 変更していないもの:
  - 互換modeの`_isIdentical`(`Implements/Deprecated/Protocol/UnsafeTreeSealedRangeProtocol.swift:50`、
    `Implements/Deprecated/RawBuffer/_TiedRawBuffer+deprecated.swift:12`)
  - 4コンテナの`isTriviallyIdentical(to:)`
  - test、benchmark、`Package.swift`
- 同期した文書: API Matrixの監査候補の行、`CHANGELOG.md`(source-breakingな公開面縮小として記載)。
- 検証:
  - Debugの`swift build --target RedBlackTreeCollections`と`--build-tests`が成功した。
  - `swift test --skip-build --filter 'RangeView|MappedValuesView'`は、RedBlackTreeTestsのXCTest 98件が
    0 failureで成功した。KeyOnly、KeyValue、MappedValues、Set、MultiSet、Dictionary、MultiMapの
    各View suiteが実行されたことを確認した。
  - Releaseの`swift build -c release --target RedBlackTreeCollections`が成功した。
  - CIと同じRelease DocC生成(`--warnings-as-errors`)が成功した。

### Debug / Release public-surface decision audit

2026-10-04 / Claude Opus 5.5。Codexの割り当てによるread-only監査。source、test、構成は
変更していない。testは実行していない。`try/index/1`は参照していない。パスはrepository rootからの
相対パス。

#### Dependency table

| cluster | 宣言とguard | repository内の利用者 | 意味 | Index / Comparable / 互換 / 性能への依存 |
| --- | --- | --- | --- | --- |
| 1. Balanced群 | `Sources/RedBlackTreeCollections/Implements/Protocol/BalancedSequence.swift`。protocol 6個(`:32-182`、`#if DEBUG`)、`BalancedSequence.popFirst(_ k:)` / `popLast(_ k:)`(`:52,66`。TODOに「そもそも間違ってる」とある)、4コンテナと2 Range Viewの適合、および`RedBlackTreeSet.freeCapacity`(`:186-205`、`DEBUG && !COMPATIBLE_ATCODER_2025`) | generic利用者はない。`freeCapacity`の利用者もない(`BalancedDynamic`要件のwitnessとしてだけ存在)。番号付き仕様test `Tests/RedBlackTreeTests/RedBlackTreeMultiMap/RedBlackTreeMultiMap_8_RangeViewTests.swift:68-82`(`#if DEBUG`)が`popFirst(2)` / `popLast(10)`を使う。`isValid.md:71`に記述がある | Debug専用の抽象化とinstrumentation。Releaseの製品面には存在しない | Index要件は`Equatable`だけでComparable非依存。関連型の既定値に`UnsafeIndexV3Range` / `UnsafeIndexV3RangeExpression`を名指ししているが、表現は選んでいない。互換modeでは適合しない。`:187`のTODOは「適合を外すと性能に影響する」とするが、適合はDebugにしか存在しないので、Releaseの製品性能には影響し得ない(Debugでの影響は未計測) |
| 2. Bound `index` / `debug` | `Sources/RedBlackTreeCollections/Implements/BoundsExpression/RedBlackTreeBoundExpression.swift:207-217`の`@inlinable public static func index(_: UnsafeIndexV3)`と`debug(_: SealError)`(`#if DEBUG`)。内部case `Internal.index` / `.debug`(`:111-112`)と、評価処理(`Implements/UnsafeTreeV2/UnsafeTreeV2+BoundsExpression.swift:128-139`、`#if DEBUG`) | testだけ。`RedBlackTreeSet_16_BoundExpressionTests.swift:197-209,360`(`#if DEBUG && !COMPATIBLE_ATCODER_2025`、`@testable`なしの`import RedBlackTreeCollections`)と、4コンテナの`*_98_InternalTests.swift`(`@testable`)。production、benchmark、DocCからの参照はない | test fixture。無効なboundと他の木のIndexを合成する | signatureにIndex型と`SealError`が現れるが、access縮小は表現を選ばない。parameter型はaliasに追従する。他の2 clusterとは参照関係がない |
| 3. Debug比較群 | `extension Result: @retroactive Comparable where Success: Comparable, Failure: Comparable`(`Sources/RedBlackTreeCollections/Implements/RawBuffer/_LazyTieWrap+Result.swift:107-125`)、`_LazyTieWrap: Comparable`(`_LazyTieWrap.swift:51-`)、`_NodePtrSealing: Comparable`と`lessThanSlow`(`Implements/__tree/unsafe_node/Seal/_NodePtrSealing.swift:144-170`)、package `_LazyTie.<`(`_LazyTie.swift:84-`)。いずれも`#if DEBUG` | 番号付き仕様test `RedBlackTreeSet_9_ProtocolConformanceTests.swift:66-71`(`XCTAssertLessThan(startIndex, endIndex)`)、`Tests/RedBlackTreeTreeTests/Foundamental/TreeFoundamentalNodeSealingTests.swift:93-161`、`RedBlackTreeSet_98_PerformanceTests.swift:199-210`(`DEBUG && false`のためcompileされない) | IndexのComparable可否そのもの。標準型への遡及適合を含む | Comparable方針、Index表現、upstreamのContainer要件(1.7.0は`Index: Comparable`を要求)に依存する。`SealError: Comparable`(`unsafe_node+pointer+safe.swift:273`)はDebug限定ではない |

#### Confirmed independent work

- **cluster 2**は、他の2 clusterに触れずに単独で縮小できる。
  - 呼び出し元はすべて同じpackage内のtestである。`@testable`なしで使う`_16_`も含まれるので、
    下限は`package`になる(internalにするとtestの変更が必要になる)。
  - production側に`@inlinable`の呼び出し元はない。
  - Releaseのsymbolには影響せず、Debugの公開symbolが2つ減る。
  - Gate Aでは、signatureにIndexが現れることを理由に「Index契約待ち」の一覧へ入れていた。しかし
    access縮小は表現を固定せず、公開面を減らす方向にしか働かない。そのため独立していると判断を改める。

#### Deferred decisions

- **cluster 3**は、Comparable方針とIndex表現(D・F・I)を待つ。割り当ての指示どおり、
  `Result: Comparable`は変更しない。
- **cluster 1**は機械的にはTestSupportへ移せる。test moduleに置くprotocolへの適合で、Debugと
  `@testable`の範囲で成立する。ただし次の2つの判断が必要になる。
  - 番号付き仕様test `_8_`が使うDebug限定`popFirst(_ k:)` / `popLast(_ k:)`は、TODOで戻り値を
    疑問視されている。そのため、削除、移動、仕様変更のどれにするかは仕様判断になる。
  - 性能TODOを外す根拠はowner noteと食い違う。
  - `freeCapacity`は`BalancedDynamic`と一緒に扱う。
- Balanced群を移した後に、関連型の既定値(`UnsafeIndexV3Range`など)を見直すかどうかは、
  Range/View契約に従う。

#### Recommended next batch

cluster 2だけを対象にする。

- `Sources/RedBlackTreeCollections/Implements/BoundsExpression/RedBlackTreeBoundExpression.swift:208-216`の
  `@inlinable public static func index(_:)`と`debug(_:)`を`@inlinable package static func`へ変更する。
  本体、内部case、評価処理、`#if DEBUG`は変更しない。test、互換mode、他のclusterには触れない。
- 検証:
  - Debugの`swift build --build-tests`。
  - `RedBlackTreeSetBoundExpressionTests`と`*_98_InternalTests`の実行。test名で発見されたことを確認する。
  - Releaseの`swift build --target RedBlackTreeCollections`。Releaseでは宣言が存在しないので、差分がないことを確認する。
  - CIと同じRelease DocC。
- source互換: 影響はDebug buildの利用者だけで、Debug限定のfixture APIの削除になる。
  CHANGELOGに1行記載すること。

#### Verdict

`independent implementation batch available`

### Bound index / debug implementation result

2026-10-04 / Claude Opus 5.5。上の推奨batch(cluster 2)をCodexの割り当てに基づき実施した。

- `Sources/RedBlackTreeCollections/Implements/BoundsExpression/RedBlackTreeBoundExpression.swift:209,214`の
  `index(_:)`と`debug(_:)`を、`@inlinable public static`から`@inlinable package static`へ変更した。
  `#if DEBUG`、signature、本体、`Internal.index` / `.debug`、`UnsafeTreeV2`での評価処理は変更していない。
- 下限が`package`である根拠: `RedBlackTreeSet_16_BoundExpressionTests`は`@testable`を使わずに
  importしており、testを変更せずにcompileできた。
- Balanced群、Debug比較群、互換mode、testは変更していない。
- 検証:
  - Debugの`swift build --build-tests`が成功した。
  - `swift test --skip-build --filter 'RedBlackTreeSetBoundExpressionTests|InternalTests'`:
    - XCTestは`RedBlackTreeSetBoundExpressionTests`の27件が0 failureで成功した。
    - Swift Testingは4コンテナの`*InternalTests`、計4 suite・4件が成功した。
  - Releaseの`swift build -c release --target RedBlackTreeCollections`が成功した。
  - CIと同じRelease DocC(`--warnings-as-errors`)が成功した。

### Deprecated iterator generations 1–3 disposition audit

2026-10-04 / Claude Opus 5.5。Codexの割り当てによるread-only監査。source、test、構成は変更して
いない。build、test、`try/index/1`の参照は行っていない。パスは
`Sources/RedBlackTreeCollections/`からの相対パス。

#### Types and references

6型とも`Implements/Deprecated/Iterator/UnsafeIterator+{Obverse,Reverse}{1,2,3}.swift`にあり、
ファイル全体を囲むguardはない(既定構成でもcompileされる)。いずれも`public struct`で`@frozen`ではなく、
`_UnsafeNodePtrType`、`UnsafeIteratorProtocol`、`ObverseIterator`(Reverseは`ReverseIterator`)、
`IteratorProtocol`、`Sequence`、`Equatable`、`@unchecked Sendable`に適合する。

| 型 | 保存表現 | 互換modeでの利用 | 通常modeでの利用 |
| --- | --- | --- | --- |
| `_Obverse1` / `_Reverse1` | raw `_NodePtr` × 3。`public let _start` / `_end`、`public var _current` | `Implements/Deprecated/UnsafeTreeV2/UnsafeTreeV2+sequence+deprecated.swift:64-79`の`unsafeSequence` / `unsafeValues`(`COMPATIBLE_ATCODER_2025`)。これらを`UnsafeTreeV2+Sequence.swift:30-80,194`、`UnsafeTreeV2+Hashable.swift:27`、`UnsafeTreeV2+KeyValue.swift:155,177`の`==`、`<`、hash、filterなどが使う | production利用なし。Debugのtestだけ |
| `_Obverse2` / `_Reverse2` | `_SealedPtr` × 3(public)。毎step `purified`で再検証する | `Implements/Deprecated/Iterator/UnsafeIterator+deprecated.swift:23-66`の互換public alias(`_RemoveTrait<_Obverse2>`、`_RemoveAwarePointers`など。`COMPATIBLE_ATCODER_2025`)。memberの`#if COMPATIBLE_ATCODER_2025` / `#else`も互換modeを前提に分かれている | production利用なし。Debugのtestだけ |
| `_Obverse3` / `_Reverse3` | `_SafePtr` × 3(public) | 利用なし | 利用なし。Debugのtestだけ |

- **test:** `Tests/RedBlackTreeTests/RedBlackTreeInternal/Instance/RedBlackTreeInternal_NaiveIteratorTests.swift`。
  - `#if DEBUG`下の通常部分(`:17-82`)にある8件が、6型と`_Payload<_, _Obverse1/_Reverse1>`を直接生成する。
  - 互換部分(`:85-105`)の2件は`_Obverse1` / `_Reverse1`を使う。
- **その他の参照:** benchmark、DocC、Markdownからの参照はない(この監査記録を除く)。

#### Supersession evidence

- 通常modeの4コンテナとViewは、`UnsafeIterator.swift:27-47`(`!COMPATIBLE_ATCODER_2025`)の
  `_CopyOnWrite<_Payload/_Key/_KeyValue/_MappedValue<Base, _Obverse4/_Reverse4>>`を使う。
  内部走査の`unsafeSequence` / `unsafeValues`も、通常modeでは`_Obverse4`を返す
  (`UnsafeTreeV2+Sequence.swift:204-223`)。
- 挙動の違い:
  - 世代1と3は、有効なpayloadが無いと`fatalError(.outOfBounds)`で止まる。
  - 世代2は、毎stepのseal検証で、走査中のstaleを`fatalError(.invalidIndex)`として検出する。
  - 世代4は`_CopyOnWrite`と組み合わせ、変更されない複製を走査することで同じ安全性を確保している。
    nullptrは木から受け取る。
- 通常modeの公開表面で、これらの挙動を必要とする型、alias、signatureはない。いずれも順方向・逆方向の
  O(1)/step走査で、計算量の契約に差はない。
- 世代1〜3を出荷版として使っているのは互換modeだけで、その設計意図
  (2026-05-29のcommit `0684ea2e` "deprecated"でDeprecatedへ移動)と一致する。

#### Configuration findings

- **通常mode(DebugとRelease):** 6型はpublicなsymbolとして残り、public memberから`_SealedPtr`、
  `_SafePtr`、`_NodePtr`を露出している(B2のIndex表現に拘束される型)。
- **互換mode:** 世代1と2は必要で、世代3は不要である。
- **通常modeの公開signatureと`@inlinable`本体:** これらの型を参照しているものはない。
  `@frozen`ではないので、レイアウトの約束もない。
- **副次的な観察:** 通常modeでは、`UnsafeIteratorProtocol` / `ObverseIterator` / `ReverseIterator`の
  適合型がこの6型だけになる(世代4はこれらに適合しない)。`_Key`などの条件付き適合
  (`Iterator/UnsafeIterator/UnsafeIterator+Key.swift:96-110`ほか)は、隔離後も残るが適合する型がなくなる。
  これらの扱いは別の監査で決める。

#### Blockers

- 互換modeの隔離はIndex表現を選ばない。互換modeのIndex契約(`UnsafeIndexV2`)にも触れない。
  したがって、Indexの判断によるblockerはない。
- 通常modeでの削除はsource-breakingになる。`UnsafeIterator`は`@_documentation(visibility: internal)`の
  underscore型だが、CHANGELOGに記載すること。
- 世代3は両modeで未使用なので削除できる。ただし削除するとtest 2件(`testNaive{Forward,Reverse}3`)の
  coverageも消える。`Tests/CLAUDE.md`に従い、coverageの削除は承認を得てから行うこと。
  隔離だけならcoverageは互換runへ移るだけで、失われない。

#### Recommended batch

互換mode専用への隔離を、1つのbatchで行う。

- 6ファイルの全体を`#if COMPATIBLE_ATCODER_2025`で囲む。世代2と3の内部にある`#else`
  (通常mode用の`_start` / `_end` / `reversed()`)は不要になるので除去する。本体の挙動は変えない。
- `RedBlackTreeInternal_NaiveIteratorTests.swift:17-82`を`COMPATIBLE_ATCODER_2025`の下へ移す。
  coverageは互換runで保持される。
- 世代3の削除は、承認を得たうえで別batchにしてよい。
- 検証:
  - 通常modeのDebugとReleaseのbuild、Debugの`--build-tests`。
  - 走査を使うtest(Sequence、Equatable、Comparable、Hashable、RangeView、MappedValuesView)。
  - 互換modeのDebugのbuildとtest(`NaiveIteratorTests`の10件が発見・実行されることを確認する)。
    互換modeの検証は、通常→互換の2回のbuildで十分である。
  - Release DocC。
- source互換: 通常modeの利用者だけに影響する(underscore付きの内部iterator 6型が消える)。
  互換modeは変わらない。

#### Verdict

`compatibility-only isolation batch`

### Deprecated iterator generations 1–3 isolation result

2026-10-04 / Claude Opus 5.5。上の推奨batchをCodexの割り当てに基づき実施した。

- **source:** `Sources/RedBlackTreeCollections/Implements/Deprecated/Iterator/UnsafeIterator+{Obverse,Reverse}{1,2,3}.swift`
  の6ファイルを、ファイル全体で`#if COMPATIBLE_ATCODER_2025`に入れた。
  - 世代2と3の内側にあった`#if COMPATIBLE_ATCODER_2025` / `#else`は計6か所(Obverse2: 2、Obverse3: 2、
    Reverse2: 1、Reverse3: 1)。互換branchの本体はそのまま残し、到達しなくなった`#else`側
    (通常mode用の`_start` / `_end`と`reversed()`)だけを削除した。
  - 空白を無視したdiffでは、directiveと上記の`#else`側以外に変更がない。
  - 世代3は削除していない。
- **test:** `RedBlackTreeInternal_NaiveIteratorTests.swift`の外側のguardを`#if DEBUG && COMPATIBLE_ATCODER_2025`へ
  変更した。10件はすべて残している。内側の互換guardは冗長だが、差分を最小にするため残した。
- **変更していないもの:** `_Obverse4` / `_Reverse4`、`_CopyOnWrite`、iterator protocol、互換alias、
  `Package.swift`。
- **通常modeの検証:**
  - Debugの`--build-tests`が成功した。
  - `swift test --skip-build --filter 'SequenceTests|Equatable|Comparable|Hashable|ProtocolConformance|RangeView|MappedValuesView|NaiveIterator'`:
    RedBlackTreeTests 256件とRedBlackTreeTreeTests 2件のXCTest、Swift Testing 1件が、いずれも0 failureで成功した。
    NaiveIteratorTestsは期待どおり発見されなかった。
  - Releaseの`swift build -c release --target RedBlackTreeCollections`が成功した。
  - Release DocC(`--warnings-as-errors`)が成功した。
  - `#if`の入れ子を追跡する走査で、`Sources`と`Tests`にある世代1〜3の参照が、すべて
    `COMPATIBLE_ATCODER_2025`のguard内にあることを確認した。
- **互換modeの検証:**
  - `swift build --target RedBlackTreeTests -Xswiftc -DCOMPATIBLE_ATCODER_2025`は成功した。
    6型とNaiveIteratorTestsを含めてcompileできた。
  - 当初は`CppBehaviorReferenceTests`が現行Index APIを前提としていたため、互換modeのtest buildが失敗した。
    C++比較4ファイル全体を`#if !COMPATIBLE_ATCODER_2025`に限定した。C++比較は現行Swift APIと
    libc++の挙動比較であり、旧AtCoder互換APIの比較対象ではない。
  - `swift build --build-tests -Xswiftc -DCOMPATIBLE_ATCODER_2025`が成功した。
  - `NaiveIteratorTests` 10件を発見・実行し、0 failureで成功した。
  - 通常modeへ戻して`CppBehaviorReferenceTests` 35件を実行し、0 failureで成功した。
- **source互換:** 通常modeでは`UnsafeIterator._Obverse1...3` / `_Reverse1...3`が消える
  (CHANGELOGに記載)。互換modeは変わらない。

### Iterator protocol layer disposition audit

2026-10-04 / Claude Opus 5.5。Codexの割り当てによるread-only監査。source、test、構成は変更して
いない。buildとtestは実行していない。パスは`Sources/RedBlackTreeCollections/Implements/`からの相対パス。

#### Declarations and references

| 宣言 | 場所 / guard | 通常modeの適合型 | 互換modeの適合型 | 通常modeの参照元 |
| --- | --- | --- | --- | --- |
| `ObverseIterator`(`associatedtype ReversedIterator`、`reversed()`)と、既定の`typealias Reversed` | `Iterator/UnsafeIterator/UnsafeIterator+Protocol.swift:23-32`。guardなし。public、`@_documentation(visibility: internal)` | なし(下の条件付き適合だけで、条件を満たす型がない) | 世代1〜3のObverse、`_RemoveAware`、`_RemoveCheck`、`Tied`、`LazyTie`、`TiedIndexing`と、wrapperの条件付き適合 | `_Payload` / `_Key` / `_KeyValue` / `_MappedValue`の条件付き適合(`UnsafeIterator+{Payload,Key,KeyValue,MappedValue}.swift`の`:96-110` / `:116-129` / `:101-114`、guardなし)と、`_CopyOnWrite`の条件付き適合(`UnsafeIterator+CopyOnWrite.swift:72-85`、`!COMPATIBLE_ATCODER_2025`) |
| `ReverseIterator`(要件なしのmarker protocol) | 同`:34-35`。guardなし | なし | 世代1〜3のReverseと各wrapper | 上と同じ条件付き適合 |
| `UnsafeIteratorProtocol`(`init(_start: _NodePtr, _end: _NodePtr)`) | 同`:37-42`(`!COMPATIBLE_ATCODER_2025`)。互換modeは別の宣言(`Deprecated/Iterator/UnsafeIterator+Protocol+deprecated.swift:9`、`_SealedPtr`版) | なし(世代1〜3を互換modeへ隔離した結果) | 世代1〜3と`_RemoveAware` / `_RemoveCheck` | 上の条件付き適合のwhere句(`Source.ReversedIterator: UnsafeIteratorProtocol & Sequence`)だけ |
| (参考)`UnsafeAssosiatedIterator` | 同`:44-49`(`!COMPATIBLE_ATCODER_2025`) | `_Payload` / `_Key` / `_KeyValue` / `_MappedValue` | 互換版は別の宣言 | `_CopyOnWrite<Source: UnsafeAssosiatedIterator>`の制約。世代4の経路に必要なので、変更の対象外 |

- **世代4は使っていない:** `_Obverse4` / `_Reverse4`は`_UnsafeNodePtrType`、`IteratorProtocol`、`Sequence`、
  `Equatable`、`TreeAlgorithmBaseProtocol_ptr`にだけ適合する(`Iterator/UnsafeIterator/UnsafeIterator+Obverse4.swift:26-31`)。
  通常modeの逆走査は、`UnsafeIterator.swift:29-46`のaliasが`_Reverse4`を直接組み立てて実現している。
  `reversed()` / `Reversed`を使う通常modeのコードはない。`.Reversed`を使っているのは4コンテナの
  `*+Deprecated.swift`(ファイル全体が`COMPATIBLE_ATCODER_2025`)だけである。
- **test、benchmark、DocC:** いずれのprotocol名も参照していない。

#### Normal vs compatibility

- **通常mode:**
  - 3つのprotocolはどれも適合型を持たない。
  - `_Payload` / `_Key` / `_KeyValue` / `_MappedValue` / `_CopyOnWrite`の`ObverseIterator` / `ReverseIterator`
    への条件付き適合(計10個)は、条件を満たす型がない。`reversed()`とpublic typealias `Reversed`を
    宣言だけしている状態である。
  - いずれもIndex型やComparableに依存しない。
- **互換mode:** `ObverseIterator`と`ReverseIterator`、および`_Payload`ほか4 wrapperの条件付き適合が必要である
  (`Tree._PayloadValues.Reversed`などのcontainer `reversed()`経路)。`UnsafeIteratorProtocol`は互換mode用に
  別の宣言を持つので、通常modeの宣言とは独立している。

#### Public-surface impact

- 通常modeから、public protocol 3個、そのrequirement(`reversed()`、`init(_start:_end:)`)、10個の条件付き適合に
  ある`reversed()`と`Reversed`が消える。
- 利用者がこれらを使うには、独自のiteratorを`ObverseIterator` / `UnsafeIteratorProtocol`に適合させたうえで、
  public `init(source:)`を持つwrapperに入れる必要があり、現実的な使い方ではない。`_CopyOnWrite`の
  `init(_source:tree:)`はinternalなので、利用者は作れない。
- 形式上はsource-breakingなので、CHANGELOGに記載すること。互換modeの公開面は変わらない。

#### Proposed batch

互換mode専用への隔離を、1つのbatchで行う。

1. `Iterator/UnsafeIterator/UnsafeIterator+Protocol.swift`
   - `ObverseIterator`、その既定extension、`ReverseIterator`を`#if COMPATIBLE_ATCODER_2025`に入れる。
   - `!COMPATIBLE_ATCODER_2025`側の`UnsafeIteratorProtocol`を削除する。互換modeの宣言は別ファイルにある。
   - `UnsafeAssosiatedIterator`は残す。
2. `Iterator/UnsafeIterator/UnsafeIterator+{Payload,Key,KeyValue,MappedValue}.swift`
   - guardのない`ObverseIterator` / `ReverseIterator`の条件付き適合を`#if COMPATIBLE_ATCODER_2025`に入れる。
     本体は変えない。
3. `Iterator/UnsafeIterator/UnsafeIterator+CopyOnWrite.swift:72-85`
   - `_CopyOnWrite`の2つの条件付き適合を削除する。これらは通常mode専用で、通常modeでは条件を満たす型がない。
     protocolを互換mode専用にするとcompileできなくなる。

#### Validation matrix

- **通常mode:**
  - Debugの`--build-tests`。
  - Sequence、reversed、RangeView、MappedValuesView、ProtocolConformanceのtest。
  - Releaseのbuild。
  - Release DocC(`--warnings-as-errors`)。
  - `#if`の入れ子を追跡する走査で、3つのprotocolの参照がすべて互換guard内にあることを確認する。
- **互換mode:**
  - `-Xswiftc -DCOMPATIBLE_ATCODER_2025`でbuild-testsする。前回のCppBehaviorReferenceTestsの互換対応は
    Codexが済ませている前提である。
  - `NaiveIteratorTests` 10件。
  - 4コンテナのAtCoder2025互換test。
- **coverageの注意:** `NaiveIteratorTests` 10件は世代1と`_RemoveAware`の順方向・逆方向の走査を検証するが、
  wrapperの`reversed()`(条件付き適合のwitness)は呼んでいない。互換modeでcontainerの`reversed()`
  (`*+Deprecated.swift`の`-> Tree._PayloadValues.Reversed`)を通るtestがあるかを実装batchで確認すること。
  無ければ、そのtestを追加するかどうかを判断すること。

#### Verdict

`compatibility-only isolation batch`

### Iterator protocol layer isolation result

2026-10-04 / Claude Opus 5.5。上の推奨batchをCodexの割り当てに基づき実施した。差分は構造的な変更に
限定し、既存行のインデント変更は行っていない。

- **変更内容:** パスは`Sources/RedBlackTreeCollections/Implements/Iterator/UnsafeIterator/`からの相対パス。
  - `UnsafeIterator+Protocol.swift`
    - `ObverseIterator`、その既定`Reversed`、`ReverseIterator`を`#if COMPATIBLE_ATCODER_2025`で囲んだ。
    - 通常modeの`UnsafeIteratorProtocol`を削除した。
    - `UnsafeAssosiatedIterator`は変更していない。
  - `UnsafeIterator+{Payload,Key,KeyValue,MappedValue}.swift`
    - `ObverseIterator` / `ReverseIterator`への条件付き適合だけを`#if COMPATIBLE_ATCODER_2025`で囲んだ。
    - wrapper型と`UnsafeAssosiatedIterator`への適合は変更していない。
  - `UnsafeIterator+CopyOnWrite.swift`
    - 通常mode専用の2つの条件付き適合を削除した。型、`Sendable`適合、世代4の経路は変更していない。
- **通常modeの検証:**
  - Debugの`swift build --disable-sandbox --build-tests`が成功した。
  - `swift test --skip-build --filter 'SequenceTests|Reversed|reversed|RangeView|MappedValuesView|ProtocolConformance'`:
    RedBlackTreeTestsのXCTest 253件が0 failureで成功し、Swift Testingも1 suite・4件が成功した。
  - Releaseの`swift build -c release --target RedBlackTreeCollections`が成功した。
  - Release DocC(`--warnings-as-errors`)が成功した。
- **互換modeの検証(`-Xswiftc -DCOMPATIBLE_ATCODER_2025`):**
  - `--build-tests`(全test target)が成功した。
  - `swift test --skip-build --filter 'NaiveIteratorTests|AtCoder2025Compatibility'`: `NaiveIteratorTests` 10件、
    `DictionaryAtCoder2025CompatibilityTests` 5件、`SetAtCoder2025CompatibilityTests` 12件、
    `MultiMapAtCoder2025CompatibilityTests` 1件が、いずれも0 failureで成功した。
  - `RedBlackTreeMultiset*LegacyTests`(Pointer、Etc、IndexRemoval)は10件で、1件skip、0 failureだった。
  - wrapperの`reversed()`(条件付き適合のwitness)を通る
    `RedBlackTreeDictionaryEtcAtCoder2025LegacyTests.testKeysAndValuesFunctionStyleReversed`が
    実行され、成功したことを確認した。
  - 検証後、通常modeで`--build-tests`を再実行し、`.build`を元に戻した。
- **guardの確認:** `#if`の入れ子を追跡する走査で、`Sources`と`Tests`にある`ObverseIterator` /
  `ReverseIterator` / `UnsafeIteratorProtocol`の参照が、すべて`COMPATIBLE_ATCODER_2025`のguard内にあることを
  確認した。`UnsafeAssosiatedIterator`は通常modeに残っている。

### Public-surface cleanup closure audit

2026-10-04 / Claude Opus 5.5。Codexの割り当てによるread-only監査。sourceは変更していない。

#### Method

- 現在のworking treeで`swift build --target RedBlackTreeCollections`をDebugとReleaseで実行した。
- `swift-symbolgraph-extract -minimum-access-level internal -emit-extension-block-symbols`の出力を
  `mktemp -d`へ置き、親型を含めて実効publicの宣言とconformanceを再集計した。一時ディレクトリは削除済み。
- 各public protocolについて、他のpublic宣言のsignature、generic制約、extension制約、protocol継承から
  参照されているかと、適合型があるかを機械的に調べた。

#### Residual table

| 区分 | 現在の残り(既定構成) | 分類 |
| --- | --- | --- |
| 4コンテナ、3 View、bound DSL、`RedBlackTreePair`、`RedBlackTreeIterator` | 製品API | 意図した製品面 |
| Index alias chain、`_LazyTieWrap`、`_NodePtrSealing`、`SealError`、`_SafePtr` / `_SealedPtr`、`_RawRange*`、`UnsafeIndexV3Range*`、特殊化`Result`の`==` / `!=`、`Result._NodePtr`、`UnsafeNode`、`_TrackingTag` | B2 | 保留中のcluster(Index) |
| Debug限定の差分: Balanced群(protocol 6個とその要件、`RedBlackTreeSet.freeCapacity`)と、Debug比較群(`Result.<`、`_LazyTieWrap.<`、`_NodePtrSealing.<`) | Debugだけにある実効public宣言(Releaseだけにあるものは0件) | 保留中のcluster(executable API Matrix / Index) |
| Memoize群、`LinkPairValueTrait` | 外部consumerの移行待ち | 保留中のcluster |
| `BENCHMARK` traitの公開hook | 別packageのBenchmarksが利用 | 保留中のcluster |
| `UnsafeMutablePointer<UnsafeNode>._NodePtr` / `._NodeRef` | 標準型extensionに残るpublic memberはこれと特殊化`Result`の演算子だけ | B2(Index表現と同じ型) |
| `ComparableKeyTrait` / `ScalarValueTrait` / `PairValueTrait` / `KeyValueTrait` / `ValueComparer` / `___Root` / `_UnsafeNodePtrType` / `UnsafeAssosiatedIterator`、および多数の`_Base*` / `_*Type`系 | Viewのgeneric制約、`UnsafeTreeV2.Index`の制約、protocol継承から参照される | B3: 境界内部(外側のsignature設計が先) |
| 実効public protocolのうち、public signatureからの参照がなく、適合型が直接ある13個: `UniqueMultiplicity`、`MultiMultiplicity`、`UnsafeTreeBindingV2`、`_ElementBride`、`_KeyBride`、`_MappedValueBride`、`_PayloadValueBride`、`_ScalarBasePayloadValue_KeyProtocol`、`_Tree_IsMultiTraitInterface`、`_BaseNode_NodeCompareProtocol`、`_BaseNode_SignedDistanceProtocol`、`LinkPairValueTrait`(Memoize)、`MultiplicityHelper`(関連型制約からのみ参照) | 4コンテナやnested `Base`が適合し、これらのprotocol extensionが他のpublic protocol要件のwitnessを提供している可能性がある | B3: typecheckを要する(下記) |
| **public signatureからの参照がなく、production内に適合型もないもの: 5個**(下記) | 下記 | **独立して対処できる、意図しない公開面** |

#### Independently actionable items

いずれも`Sources/RedBlackTreeCollections/Implements/__tree/`の原木protocolである。

| 宣言 | 場所 | repository内の参照 | 下限 |
| --- | --- | --- | --- |
| `_BaseKey_EquivInterface` | `base/tree_base+interface.swift:66` | 宣言だけ。参照0件 | `package`(近隣に合わせるなら`@usableFromInline package`) |
| `_BaseNode_PtrUniqueCompInterface` | `base/tree_base+interface.swift:77` | 宣言だけ。参照0件 | 同上 |
| `_Base_MultiplicityHelperProtocol` | `base/tree_base+interface.swift:104` | 宣言だけ。参照0件 | 同上 |
| `_pointer_type` | `_types/tree_basic+types.swift:218` | `@usableFromInline package protocol TreeEndNodeAccessInterface`(`interfaces/tree_interface+node.swift:27`)が継承するだけ | `@usableFromInline package` |
| `_BaseNode_KeyProtocol`(とextensionの既定`__get_value`) | `base/tree_base+common.swift:26-45`。コメントに「資料的に残されている」とある | production内に適合型はない。test fixtureとして`Tests/RedBlackTreeTreeTests/Foundamental/TreeFoundamentalValueTests.swift:38`と`Tests/RedBlackTreeTests/RedBlackTreeInternal/Synthetic/RedBlackTreeInternal_98_CoverageTests.swift:21`(同じpackage)が使う | `package` |

- **外部露出:** 5個とも、public signature、`@inlinable`本体の型制約、DocC、benchmarkからの参照はない。
  利用者から見えるのは名前だけである。
- **構成による差:** guardはなく、Debug、Release、互換modeで同じである。互換mode側にも参照はない。
- **Index依存:** ない。
- **最小の変更範囲:** 3ファイルで5宣言の`public`を変えるだけ。削除はしない。
  - 原木は将来のportabilityのために、参照用の宣言を意図的に残している(上表のコメント参照)。
    access縮小はこの意図を保つが、削除はこの意図とぶつかる。
- **検証項目:**
  - 通常modeのDebugの`--build-tests`(上記2つのtest fixtureがpackage accessでcompileできること)とReleaseのbuild。
  - `RedBlackTreeTreeTests`の`TreeFoundamentalValueTests`と、`RedBlackTreeInternal_98_CoverageTests`。
  - 互換modeのbuild。
  - Release DocC。
- **source互換:** 名前だけのpublic protocolが消える。形式上は破壊的変更なので、CHANGELOGに記載すること。

#### Accounting corrections

- 実効publicの件数は、Gate A時点のDebug 963 / Release 892から、Debug 889 / Release 819になった。
  public protocolはReleaseで56個(Gate Aでは非Balancedが60個)。減った4個は`ThreeWayCompareResult`、
  `ObverseIterator`、`ReverseIterator`、`UnsafeIteratorProtocol`で、実施済みのbatchと一致する。
- 冒頭の「現在の一覧」表の`Int.__less()` / `__greater()`(`:23`)と`Int: ThreeWayCompareResult`(`:24`)、
  および残タスク`:103-104`は、B4-aでpackageへ縮小済みである。表は過去の監査記録として残っているが、
  現状を表していない。
- 冒頭表の`UnsafeMutablePointer`のhelper行(`:36`)は、Gate Aで「package中心」と補正済みである。

#### Debug / Release item

`PROGRESS_OVERVIEW.md`の「DebugとReleaseで公開protocol適合集合が変わる箇所を解消」が未完のまま残る理由は、
Balanced群とDebug比較群(どちらも保留中のcluster)だけである。それ以外のDebug限定の差分は見つからなかった。

#### Remaining gates

- Index契約: D、F、Iの判断。
- Balanced群: executable API Matrixの方針と、Debug/Releaseの扱い。
- 世代3を削除するかどうか: owner判断。
- Memoize群: 外部consumer 2つの移行。
- B3: 適合型を持つ13個のprotocolは、witnessの提供関係をtypecheckしてからでないと、縮小できるか判定できない。

#### Verdict

`independent cleanup remains`

次の作業は、上の5個のprotocolをpackageへ縮小するbatchとする。完了後は、B3のtypecheck監査に進まない限り、
独立して進められる公開面整理は終わりになる。

### 原木 reference protocol narrowing result

2026-10-04 22:30 JST、Claude Opus 5.5。closure auditで独立対処可能とした5個を、削除せずにpublicから縮小した。
差分はaccess修飾子と属性だけで、要件、本体、コメントは変えていない。

| 宣言 | 場所 | 変更 |
| --- | --- | --- |
| `_BaseKey_EquivInterface` | `base/tree_base+interface.swift:66` | `public protocol` → `package protocol` |
| `_BaseNode_PtrUniqueCompInterface` | `base/tree_base+interface.swift:77` | 同上 |
| `_Base_MultiplicityHelperProtocol` | `base/tree_base+interface.swift:104` | 同上 |
| `_pointer_type` | `_types/tree_basic+types.swift:218-219` | `public protocol` → `@usableFromInline package protocol` |
| `_BaseNode_KeyProtocol` | `base/tree_base+common.swift:26` | `public protocol` → `package protocol` |
| 既定の`__get_value(_:)` | `base/tree_base+common.swift:42-43` | `@inlinable public static` → `@inlinable package static` |

- **access下限:**
  - 3個の参照0件protocolは、public `@inlinable`本体からも`@usableFromInline` protocolからも参照されないので、
    `@usableFromInline`を付けない素の`package`でcompileできた。
  - `_pointer_type`は`@usableFromInline package`の`TreeEndNodeAccessInterface`が継承するので、
    指示どおり`@usableFromInline package`にした。
  - `_BaseNode_KeyProtocol`のfixture 2つは、どちらも`#if DEBUG`内で`@testable import`する
    (`TreeFoundamentalValueTests.swift:37-65`、`RedBlackTreeInternal_98_CoverageTests.swift`は
    `DEBUG && DEATH_TEST`)。したがって、今のtestだけなら`internal`でも足りる。
    指示どおり`package`にしたので、非`@testable`の同package testから使える余地も残っている。
  - Releaseのtest buildには、このfixtureは含まれない。Releaseでpackage accessを確かめたことにはならない。
- **保持:** `_BaseKey_LessThanInterface`、`_BaseNode_PtrCompInterface`、`_BaseNode_PtrRangeCompInterface`、
  `_Base_MultiplicityHelperInterface`、`_PointerType`、`_parent_pointer_type`、
  `_BaseComparableKey_LessThanProtocol`、test fixture 2つは変えていない。
- **参照の再確認:** `Sources`、`Tests`、`Benchmarks/Sources`で5個の名前を検索した。production内の参照は、
  `TreeEndNodeAccessInterface`(package)による`_pointer_type`の継承だけだった。testの参照は、上記fixture 2つと
  `Fixtures.md`だけだった。public signatureからの参照はない。
- **検証(通常mode):**
  - `swift build --disable-sandbox --build-tests`: 成功。
  - `swift test --disable-sandbox --skip-build --filter 'TreeFoundamentalValueTests|RedBlackTreeInternalCoverageTests'`:
    - `TreeFoundamentalValueTests`: XCTest 11件、失敗0。
    - `RedBlackTreeInternalCoverageTests`: Swift Testing 5件(`_BaseNode_KeyProtocolのカバレッジ確保`を含む)、すべて成功。
  - `swift build --disable-sandbox -c release --target RedBlackTreeCollections`: 成功。
  - `swift build --disable-sandbox -c release --target RedBlackTreeTreeTests`: 成功。
  - CIと同じRelease DocCの`generate-documentation ... --warnings-as-errors`: 成功。
- **検証(互換mode):** `-Xswiftc -DCOMPATIBLE_ATCODER_2025`を付けて、`RedBlackTreeTreeTests`と
  `RedBlackTreeTests`をbuildした。どちらも成功。
- **source互換:** 名前だけのpublic protocol 5個と、public extension member 1個が外部から見えなくなる。
  `CHANGELOG.md`の`Unreleased / Changed`に記載した。
- **残り:** B3の13 protocolのtypecheck監査と、保留中のgate。独立した公開面整理はこれで一区切りになる。

### B3 protocol witness and conformance audit

2026-10-04 22:31 JST、Claude Opus 5.5。read-onlyの監査である。source、test、`Package.swift`は編集していない。
対象はclosure auditの残り13個から、Memoize所有の`LinkPairValueTrait`を除いた12個。

#### Protocol / witness table

「witness」の列は、その protocol の extension にある既定実装が、container の`Base`などの**public適合**で、
他の public protocol の要件を満たしているかどうかを示す。単に protocol 制約を通して呼べるだけのものは含めない。

| protocol | 継承 / 要件 | production の適合型 | 既定実装が満たす public 要件(witness) | 参照元 | 下限 |
| --- | --- | --- | --- | --- | --- |
| `_KeyBride` | `_BaseBridge & _KeyType`、`where _Key == Base._Key`。要件なし | 4 container(内部の`_RedBlackTreeKeyOnlyV2` / `_RedBlackTreeKeyValuesV2`経由) | メソッドの witness はなし(extensionなし)。ただし same-type 制約で関連型`_Key`を推論させている(下記) | `@usableFromInline`内部protocol `_SequenceV2`、`_PayloadValueBridge_Key`、`_ValueCompBridge`、内部typealias `_SetBridge` / `_MapBridge`。互換modeでは`@usableFromInline` `___UnsafeIndexV2`、内部`_CompareV2`。test: `TreeFoundamentalComparisonInjectionTests`(`#if DEBUG`、`@testable`) | `@usableFromInline`が必須(`@usableFromInline` protocolが継承するため) |
| `_PayloadValueBride` | 同上(`_PayloadValue`) | 4 container、3 View(`UnsafeMutableTreeHostV2`) | メソッドの witness はなし。関連型`_PayloadValue`を推論させている(下記) | `@usableFromInline` `UnsafeMutableTreeHostV2`、`_SequenceV2`、`_PayloadValueBridge_Key`、内部typealias。互換modeでは内部`___RemoveV2` / `_RemoveV2` / `UnsafeTreeSealedRangeProtocol` | 同上 |
| `_ElementBride` | 同上(`Element`) | 4 container | なし | `@usableFromInline` `_PaylodValueBridge_Element`、内部typealias | 同上 |
| `_MappedValueBride` | 同上(`_MappedValue`) | Dictionary / MultiMap | なし | 内部typealias `_MapBridge`のみ | 同上 |
| `_Tree_IsMultiTraitInterface` | `isMulti`(instance) | `UnsafeTreeV2`(自前の`public var isMulti`)、内部handle 2つ | なし(既定実装なし。witnessは各型自身のmember) | `@usableFromInline` `BoundBothProtocol`の`@inlinable` lower/upper bound | 同上 |
| `UniqueMultiplicity` | `_Base_MultiplicityHelperInterface`、`where _MultiplicityHelper == __UniqueHelper<Self>` | Set / Dictionary の`Base` | **あり**: `isMulti`(public `_Base_IsMultiInterface`、つまり public typealias `___TreeBase`の要件)。関連型`_MultiplicityHelper`も same-type 制約で供給 | 互換modeの内部`_CompareV2` extension。test: `TreeNodeOnlyFixture`と`RedBlackTreeInternal_KeyValueComparerTests`(どちらも guard なしの非`@testable` import)、ほか Debug `@testable` 3件 | `package`(Release の非`@testable` test) |
| `MultiMultiplicity` | 同上(`__MultiHelper<Self>`) | MultiSet / MultiMap の`Base` | **あり**: 同上 | 同上(`TreeNodeOnlyFixture`) | `package` |
| `MultiplicityHelper` | `___ptr_comp`、`___ptr_range_comp` | public struct `__UniqueHelper` / `__MultiHelper` | — | public protocol `_Base_MultiplicityHelperInterface`の**関連型制約** | **public のまま**(public protocol の関連型制約は public でなければならない) |
| `_BaseNode_NodeCompareProtocol` | `_BaseNode_PtrCompInterface & _BaseNode_PtrRangeCompInterface & _Base_MultiplicityHelperInterface` | 4 container の`Base` | **あり**: `___ptr_comp` / `___ptr_range_comp`(public `_BaseNode_PtrCompInterface` / `_PtrRangeCompInterface`。public typealias `___TreeIndex`、`UnsafeTreeV2`の public 制約付き extension(RawRange、Erase)が使う) | test: `TreeNodeOnlyFixture`(非`@testable`) | `package` |
| `_BaseNode_SignedDistanceProtocol` | `_UnsafeNodePtrType & _BaseNode_SignedDistanceInterface & _BaseNode_PtrCompInterface`、独自の関連型`difference_type` / `_InputIter` | 4 container の`Base` | **あり**: `___signed_distance`(public `_BaseNode_SignedDistanceInterface`。`___TreeIndex`と`UnsafeTreeV2+Index.swift:65`の public 制約付き extension が使う) | test: `TreeNodeOnlyFixture`(非`@testable`) | `package` |
| `_ScalarBasePayloadValue_KeyProtocol` | `_ScalarBaseType & _BasePayloadValue_KeyInterface` | Set / MultiSet の`Base`(`@usableFromInline` `_ScalarBasePayload_KeyProtocol_ptr`経由) | **あり**: `__key`(public `_BasePayloadValue_KeyInterface`、`ScalarValueTrait`経由) | `@usableFromInline` `_ScalarBasePayload_KeyProtocol_ptr`。test: `TreeFoundamentalValueTests:19-20`(guard 外。Release では非`@testable`)、`UnsafeTreeBasicTests`(Debug `@testable`) | `@usableFromInline package` |
| `UnsafeTreeBindingV2` | `___Root & _UnsafeNodePtrType`、`where Tree == UnsafeTreeV2<Base>`。要件なし | 通常mode: 4 container と 3 View(`@usableFromInline` `UnsafeTreeHostV2`経由)。互換mode: public struct `UnsafeIndexV2` 等 | なし | 通常mode: `@usableFromInline` `UnsafeTreeHostV2`のみ。**互換mode: public protocol `UnsafeIndexBindingV2` / `UnsafeIndicesBinding`が継承** | 通常mode `@usableFromInline package`、**互換mode public** |
| (`LinkPairValueTrait`) | — | — | — | Memoize 所有。対象外(件数合わせのためだけに記載) | — |

- **public signature:** 12個とも、public な関数・型の signature、public typealias、View の generic 制約から
  直接は参照されない。View の generic 制約は`___Root`、`___TreeBase`、`ScalarValueTrait`などで、対象の12個は含まない。Benchmarks/Sources からの参照も0件。
- **関連型の推論:** 4 container の外側の型と3 View は`_Key` / `_PayloadValue` / `_MappedValue`(container は`Element`も)を
  明示的に宣言していない。Bride の same-type 制約(`_PayloadValue == Base._PayloadValue`など)から推論される。
  この推論された型は public な位置で使われている。例: `RedBlackTreeKeyOnlyRangeView`の
  `extension ...: Equatable where _PayloadValue: Equatable`(`RedBlackTreeRangeView+KeyOnly.swift:313`)と
  `Comparable`(`:323`)。したがって Bride 群は、public signature に名前は出ないが、public signature の型を決めている。
- **名前の露出と挙動の露出:** witness 列が「あり」の5個は、縮小しても挙動は public 要件を通じて外から呼べるまま残る。
  縮小で消えるのは protocol 名と、container `Base`の public 適合一覧に出る名前だけである。

#### 言語規則の確認(合成コード)

実 source を編集せずに判断するため、task 専用の一時ディレクトリで合成コードを`swiftc -package-name`で compile した
(一時ディレクトリは削除済み)。

| 形 | 結果 |
| --- | --- |
| public 型が package protocol `Q`(public `P`を継承)に適合し、`P`の要件の witness が`Q`の extension にある(`public`宣言) | compile 成功。別 package の client から`-O`で generic 経由・直接呼び出しとも動作した |
| `@usableFromInline` internal protocol が、`@usableFromInline`なしの package protocol を継承 | **error**: `protocol refined by '@usableFromInline' protocol must be '@usableFromInline' or public` |
| `@usableFromInline package` protocol(`where K == B.K`)を`@usableFromInline` internal protocol 経由で public 型が採用。関連型の明示あり / 推論のみ | どちらも compile 成功 |
| 上と同じ形で、推論された関連型`_PayloadValue`を public 条件付き適合(`Equatable where _PayloadValue: Equatable`)と public method の戻り値に使う | compile 成功。別 package の client から`V<Int>._PayloadValue`の参照、`==`、method 呼び出しとも動作した |

結論:

- witness を供給する protocol を縮小しても、言語上は public 適合が壊れるとは限らない。
- ただし実コードには`~Copyable`、`where _MultiplicityHelper == __UniqueHelper<Self>`による関連型推論、
  Release / 互換mode の差がある。合成コードの結果だけで witness 群の縮小が通るとは言えない。
- Bride 群と`_Tree_IsMultiTraitInterface`は`@usableFromInline` protocol から継承されているので、
  下限は`@usableFromInline package`(または`@usableFromInline internal`)。素の`package`にはできない。

#### Dependency groups

| group | protocol | 状態 | 理由 |
| --- | --- | --- | --- |
| G1 | `_KeyBride`、`_PayloadValueBride`、`_ElementBride`、`_MappedValueBride`、`_Tree_IsMultiTraitInterface` | **独立して縮小できる** | メソッドの witness を供給しない(関連型の推論は供給するが、同じ形が合成コードで client 利用まで通った)。refiner は通常mode・互換modeとも internal / `@usableFromInline`だけ。test は Debug `@testable`のみ。Index、Balanced、Memoize、BENCHMARK に触れない |
| G2 | `UniqueMultiplicity`、`MultiMultiplicity` | 実コードでの compile 実験が要る | `isMulti`の witness と`_MultiplicityHelper`の関連型推論を供給する |
| G3 | `_BaseNode_NodeCompareProtocol`、`_BaseNode_SignedDistanceProtocol` | 実コードでの compile 実験が要る。Index に隣接 | Index の比較・距離を支える public 要件の witness を供給する。縮小は Index 表現を決めないが、`___TreeIndex`の要件と同じ場所なので、Index 契約の作業と同時に動かすほうが安全 |
| G4 | `_ScalarBasePayloadValue_KeyProtocol` | 実コードでの compile 実験が要る | `__key`の witness を供給する。下限は`@usableFromInline package` |
| G5 | `MultiplicityHelper` | 現状では public のまま | public `_Base_MultiplicityHelperInterface`の関連型制約。縮小するなら`_Base_MultiplicityHelperInterface`、`__UniqueHelper` / `__MultiHelper`まで含む大きな cluster になり、今回の範囲外 |
| G6 | `UnsafeTreeBindingV2` | 互換mode の境界で保留 | 互換mode の public protocol 2つが継承する。縮小には構成ごとに access を変える分岐が要る |

#### Configuration findings

- Debug / Release: G1〜G4 の宣言と適合に guard はなく、両構成で同じ。Release の非`@testable` test が
  G2〜G4 を参照するので、これらの下限は`package`以上になる。G1 は Release の test から参照されない。
- 互換mode: G1 の互換 refiner(`___UnsafeIndexV2`、`_CompareV2`、`___RemoveV2`、`_RemoveV2`、
  `UnsafeTreeSealedRangeProtocol`)はすべて internal / `@usableFromInline`で、縮小と両立する。
  互換mode に public refiner があるのは G6 だけ。

#### Proposed validation matrix(G1 batch)

| 構成 | 内容 |
| --- | --- |
| 通常 Debug | `swift build --build-tests`。`TreeFoundamentalComparisonInjectionTests`、Sequence / RangeView / MappedValuesView(View の Equatable / Comparable を含む)、ProtocolConformance、BoundExpression と lower/upper bound 系の test を実行し、discovery を確認 |
| 通常 Release | `RedBlackTreeCollections`、`RedBlackTreeTests`、`RedBlackTreeTreeTests`の build |
| DocC | CI と同じ Release DocC `--warnings-as-errors` |
| 互換mode | `-Xswiftc -DCOMPATIBLE_ATCODER_2025`で build-tests。`AtCoder2025Compatibility`と`NaiveIteratorTests`を実行 |
| 検索 | 5個の名前が public signature に無く、`@usableFromInline` refiner からだけ参照されること |
| 関連型 | Release symbol graph で、4 container / 3 View の`_Key` / `_PayloadValue` / `_MappedValue` / `Element`が引き続き public であること(推論された型 witness が隠れていないこと) |

source 互換: 5個の protocol 名が外部から見えなくなる(4 container / 3 View の public 適合一覧からも消える)。
挙動は変わらない。CHANGELOG に source-breaking として記載する。

#### Recommended next action

G1 の5個を`public`から`@usableFromInline package`へ縮小する batch。要件・本体・コメントは変えない。
G2〜G4 は G1 の後に、実 source での targeted compile 実験として別 task にする。G5 / G6 は保留。

#### Verdict

`independent narrowing batch available`

### G1 bridge protocol narrowing result

2026-10-04 / Codex。監査で独立実装可能とされたG1を実施した。

- `_KeyBride`、`_PayloadValueBride`、`_MappedValueBride`、`_ElementBride`、
  `_Tree_IsMultiTraitInterface`を`public`から`@usableFromInline package`へ縮小した。
- protocolの要件、same-type制約、適合、実装本体は変更していない。
- Release symbol graphでは5個のprotocol名が外部公開面から消え、`_PayloadValue`と
  `_MappedValue`を含む公開関連型の記録が残ることを確認した。
- `CHANGELOG.md`の`Unreleased / Changed`へsource-breakingな公開名縮小として記録した。

検証:

- Xcode `BuildProject(buildForTesting: true)`: 成功、診断0件。
- `swift build --disable-sandbox -c release --target RedBlackTreeCollections`: 成功。
- 通常構成の対象test (`TreeFoundamentalComparisonInjectionTests`、Sequence、Equatable、
  Comparable、ProtocolConformance、RangeView、MappedValuesView、BoundExpression、
  lower/upper bound): 330件成功、失敗0。原木比較注入testは10件実行を確認した。
- `-Xswiftc -DCOMPATIBLE_ATCODER_2025 --build-tests`: 成功。互換testの
  `AtCoder2025Compatibility`と`NaiveIteratorTests`: 28件成功、失敗0。
- CIと同じRelease DocC生成 (`--warnings-as-errors`): 成功。

G1は完了。次はG2 (`UniqueMultiplicity` / `MultiMultiplicity`) またはG4
(`_ScalarBasePayloadValue_KeyProtocol`) の実source targeted compile実験を、G3のIndex隣接群とは
分離して行える。G5 (`MultiplicityHelper`) とG6 (`UnsafeTreeBindingV2`) は引き続き保留する。

### G4 targeted compile experiment

2026-10-04 / Codex。実sourceでアクセス縮小を一時適用し、DebugとReleaseのtypecheck結果を確認した。
実験後、sourceは実験前へ復元した。

1. protocolだけを`@usableFromInline package`へ縮小し、既定の`__key`を`public`のままにすると、
   `Cannot declare a public static method in an extension with package requirements`となる。
   後続のClaudeレビューにより、これはpackage protocol extension一般の制約ではなく、
   `where Self: ~Copyable`句がpackage requirementとして扱われることが原因と限定された。
2. `__key`も`package`へ縮小するとファイル単体の診断は消えるが、Set / MultiSetのpublic nested
   `Base`がpublic `_BasePayloadValue_KeyInterface`へ適合する際のwitnessとして不足する。DebugとReleaseの
   module buildはいずれも`Method '__key' must be declared public because it matches a requirement in public
   protocol '_BasePayloadValue_KeyInterface'`で失敗した。
3. したがってG4はprotocol宣言だけの独立縮小として成立しない。縮小するには、public witnessを別の
   public extension / conforming typeへ移すか、`_BasePayloadValue_KeyInterface`を含む上位clusterの公開設計を
   変更する必要がある。これはaccess modifierだけのバッチを越えるため、この実験では実装しない。

結論: `deferred; public witness boundary confirmed`。

#### G4 experiment review (Claude)

2026-10-04 JST、Claude Opus 5.5。read-onlyの独立レビュー。repository内のsourceは編集していない。
task専用の一時ディレクトリで合成コードを`swiftc -package-name`でcompileした(ディレクトリは削除済み)。

- **対象の確認:**
  - `_ScalarBasePayloadValue_KeyProtocol`(`tree_base+scalar.swift:23`)は`~Copyable`で、既定の`__key`は
    `extension ... where Self: ~Copyable`(`:25`)にある。
  - Set / MultiSetのpublic nested `Base`は、`ScalarValueTrait`(public)を通じてpublic
    `_BasePayloadValue_KeyInterface`に適合する。`@usableFromInline` `_ScalarBasePayload_KeyProtocol_ptr`
    を通じて、この既定`__key`がwitnessになっている。
- **失敗2(`__key`をpackageにした場合):** 正しい。public型のpublic適合では、public要件のwitnessは
  publicでなければならない。合成コードでも同じ`must be declared public because it matches a requirement in
  public protocol`が出た。
- **失敗1の理由づけは一般化しすぎ:** 「package protocolのextensionにはpublic memberを宣言できない」は、
  一般則としては成り立たない。原因は`where Self: ~Copyable`句である。合成コードの結果:

  | protocol | extension | 結果 |
  | --- | --- | --- |
  | `@usableFromInline package`、`~Copyable` | where句なし、`public static func __key` | compile成功。public `Base`のpublic witnessとしても通る |
  | 同上 | `where Self: ~Copyable`あり | `cannot declare a public static method in an extension with package requirements` と witness不足の2つが出る |
  | 同上(適合型なし) | `where Self: ~Copyable`あり | 1つ目のerrorだけで失敗する。逆制約(`~Copyable`)の句だけで、extensionがpackage制約付きとみなされる |

  Codexが観測したdiagnostic自体は再現した。結論も変わらない。ただし、この記録をG2/G3の判断に流用するときは、
  原因が`where Self: ~Copyable`句であることを前提にすること。
- **access修飾子だけで済む方法:** ない。
  - `@usableFromInline`を外すことはできない。`@usableFromInline` `_ScalarBasePayload_KeyProtocol_ptr`が継承している。
  - where句を外すとcompileは通る見込みだが、noncopyableな適合型に既定実装が届かなくなる。これはgenericsの変更で、
    access-onlyではない。原木の`~Copyable`維持方針(portability)ともぶつかる。
  - 将来の設計案(このbatchの対象外): `where Self: ~Copyable`の扱いを決めること、witnessを別のpublic
    extensionへ移すこと、`_BasePayloadValue_KeyInterface`を含む上位clusterの公開設計を見直すこと。
- **後続groupへの影響(参考):**
  - G2の`UniqueMultiplicity` / `MultiMultiplicity`は、extensionにwhere句がない(`tree_base+trait.swift:80,89`)。
    この障害には当たらない見込み。
  - G3の`_BaseNode_SignedDistanceProtocol`は`where Self: ~Copyable`付き(`tree_base+distance.swift:39`)なので、
    同じ障害に当たる見込み。`_BaseNode_NodeCompareProtocol`はwhere句なし(`tree_base+compare.swift:29`)。
- **復元の確認:**
  - `tree_base+scalar.swift`はpublic protocolとpublic `__key`のままで、HEADと差分がない。
  - `git diff HEAD`の対象は、`Maintanance/CLAUDE_TASK.md`とこのファイルだけである。
  - `Sources`、`Tests`、`CHANGELOG.md`、`Package.swift`、`.github`、`Benchmarks`には差分がない。

Verdict: `defer G4`

### G2 multiplicity protocol narrowing result

2026-10-04 / Codex。G4の理由を流用せず、where句を持たないG2を実sourceで検証した。

- `UniqueMultiplicity`と`MultiMultiplicity`を`public`から`package`へ縮小した。
- 既定のpublic `isMulti`、same-type制約 (`_MultiplicityHelper == __UniqueHelper<Self>` / `__MultiHelper<Self>`)、
  適合、実装本体は変更していない。
- 両extensionにはG4で問題になった`where Self: ~Copyable`句がなく、public `isMulti`はSet / MultiSet /
  Dictionary / MultiMapのpublic nested `Base`が持つpublic `_Base_IsMultiInterface`適合のwitnessとして維持された。
- Release symbol graphでは両protocol名が公開面に現れないことを確認した。ただし`_`始まりのprotocolと
  memberは元々symbol graphへ出ないため、witness維持の根拠にはしていない。後続のClaudeレビューで、
  package名なしの外部clientから`isMulti`と`_MultiplicityHelper`が引き続き利用でき、両protocol名だけが
  scope外になったことをtypecheckで確認した。

検証:

- Xcode `BuildProject(buildForTesting: true)`: 成功、診断0件。
- 通常DebugのG2利用元: XCTest 7 suite・77件とSwift Testing 4件が成功、失敗0
  (Claudeレビューで不足していたtest実行を補完)。
- `swift build --disable-sandbox -c release --build-tests`: 成功。
- Release対象test (`TreeFoundamentalValueTests`、`KeyValueComparerTests`): 10件成功、失敗0。
- `-Xswiftc -DCOMPATIBLE_ATCODER_2025 --build-tests`: 成功。G2と互換経路の対象test
  (`TreeFoundamentalValueTests`、`KeyValueComparerTests`、`UnsafeTreeBasicTests`、
  `AtCoder2025Compatibility`、`NaiveIteratorTests`): 42件成功、失敗0。
- CIと同じRelease DocC生成 (`--warnings-as-errors`): 成功。

G2の実装・検証とClaudeの独立レビューは完了。Verdictは`approve G2`。

#### G2 narrowing review (Claude)

2026-10-04 23:40 JST、Claude Opus 5.5。独立レビュー。repository内のsourceは編集していない。

- **差分:** sourceの差分は`tree_base+trait.swift:78,87`の`public protocol` → `package protocol`の2行だけ。
  `@_documentation(visibility: internal)`、where句、public `isMulti`、本体は変わっていない。
- **G4の障害には当たらない:** 両extension(`:80`、`:89`)にはwhere句がない。G4のレビューで確認した
  `where Self: ~Copyable`起因のdiagnosticは出ない。Debug、Release、互換modeのbuildで再確認した。
- **witnessと関連型:** 4 containerの`Base`は、package protocolを経由して、public `_Base_IsMultiInterface` /
  `_Base_MultiplicityHelperInterface`へのpublic適合を保っている。
  - 確認方法: 現在のRelease module(`.build/out/Products/Release`)に対して、package名なしの外部clientを
    task専用の一時ディレクトリで`swiftc -typecheck`した(一時ディレクトリは削除済み)。
  - 通ったもの:
    - `RedBlackTreeSet<Int>.Base.isMulti`と`RedBlackTreeMultiSet<Int>.Base.isMulti`の直接参照。
    - `B: _Base_IsMultiInterface`のgeneric経由でのDictionary / MultiMap `Base`の`isMulti`。
    - `Base._MultiplicityHelper`が`__UniqueHelper<…>` / `__MultiHelper<…>`と一致すること。
    - `B: _Base_MultiplicityHelperInterface`への受け渡し。
  - 通らなかったもの: `UniqueMultiplicity` / `MultiMultiplicity`を制約に使うclientは
    `cannot find type ... in scope`になった。名前だけが外部から消えたことを示す。
  - 補足: Release symbol graphは、`_`で始まるprotocolとそのmemberを出力しない。そのため`isMulti`が
    保たれているかは、symbol graphでは確認できない。上のclient typecheckがその代わりになる。
- **最小access:** `package`が正しい。
  - `TreeNodeOnlyFixture.swift:92,101,113`は`RedBlackTreeTreeTests`にあり、guardなしの非`@testable` importで使う。
    `RedBlackTreeInternal_KeyValueComparerTests.swift:11`も同じ。どちらもRelease test buildに含まれる。
  - `@usableFromInline`は不要。通常modeでは`@inlinable`本体や`@usableFromInline` protocolの継承から参照されない。
  - 互換modeの`@usableFromInline` `_CompareV2`は、extensionのwhere句で参照するだけで、継承はしていない。
    中のmemberは`@inlinable internal`で、Codexの互換mode buildが通っている。
- **記録の文言:** CHANGELOG、PROGRESS_OVERVIEW、上の結果節の内容は、実際の影響と合っている。
  影響は、通常modeと互換modeの両方で名前が外部から見えなくなることだけで、挙動は変わらない。
- **Codexの検証で欠けていたもの:**
  - 通常modeのDebugは、Xcode `BuildProject`によるbuildだけで、`swift test`の実行がなかった。
  - これを補うため、次を実行した。
    - `swift build --disable-sandbox --build-tests`: 成功。
    - `swift test --skip-build --filter`でG2の利用元を実行し、すべて成功(失敗0)。内訳はXCTest 7 suite・77件:
      - `TreeFoundamentalComparisonInjectionTests`: 10件
      - `TreeFoundamentalMultiplicityTests`: 16件
      - `TreeFoundamentalSealTests`: 7件
      - `TreeFoundamentalTests`: 19件
      - `TreeFoundamentalValueTests`: 11件
      - `KeyValueComparerTests`: 1件
      - `UnsafeTreeBasicTests`: 13件
    - 同じく、Swift Testingの`RedBlackTreeInternalPointerDeathTests`: 4件成功。
    - 外部APIの確認は上のclient typecheckで補った。
  - ほかに足りない構成はない。

Verdict: `approve G2`

### G3 NodeCompare protocol narrowing result

2026-10-04 / Codex。G3を分割し、where句のない`_BaseNode_NodeCompareProtocol`だけを
実sourceで検証した。`_BaseNode_SignedDistanceProtocol`とIndexの公開設計には触れていない。

- `_BaseNode_NodeCompareProtocol`を`public`から`package`へ縮小した。
- protocolの継承、既定のpublic `___ptr_comp` / `___ptr_range_comp`、4 container `Base`の適合、
  実装本体は変更していない。
- extensionにはG4で問題になった`where Self: ~Copyable`句がない。
- Releaseの非`@testable` `TreeNodeOnlyFixture`がこのprotocolを直接参照するため、下限は`package`。

検証:

- Xcode `BuildProject(buildForTesting: true)`: 成功。対象fileのlive diagnosticsも0件。
- 通常Debugの対象test: XCTest 135件とSwift Testingの対象suiteが成功、失敗0。
- `swift build --disable-sandbox -c release --build-tests`: 成功。Release対象test 69件成功、失敗0。
- `-Xswiftc -DCOMPATIBLE_ATCODER_2025 --build-tests`: 成功。対象test commandも成功、失敗0。
- CIと同じRelease DocC生成 (`--warnings-as-errors`): 成功。

公開witnessの維持はunderscore-prefixed symbolが省略されるsymbol graphでは判定しない。Claudeの
独立レビューで、package名なしの外部clientから`___ptr_comp` / `___ptr_range_comp`が引き続き
利用でき、`_BaseNode_NodeCompareProtocol`の名前だけがscope外になることをtypecheckする。

#### G3 NodeCompare narrowing review (Claude)

2026-10-04 JST、Claude Opus 5.5。独立レビュー。repository内のsourceは編集していない。

- **差分:** sourceの差分は`tree_base+compare.swift:23`の`public protocol` → `package protocol`の1行だけ。
  `_BaseNode_SignedDistanceProtocol`(`tree_base+distance.swift`)、Index、test、実装本体には差分がない。
- **G4の障害には当たらない:** extension(`:29`)にはwhere句がない。Release buildも成功した。
- **witnessの維持:** 現在のRelease module(`.build/out/Products/Release`)に対して、package名なしの外部clientを
  task専用の一時ディレクトリで`swiftc -typecheck`した(一時ディレクトリは削除済み)。
  - 通ったもの:
    - 4 container `Base`の`___ptr_comp` / `___ptr_range_comp`を直接参照すること。
    - `_BaseNode_PtrCompInterface` / `_BaseNode_PtrRangeCompInterface`のgeneric経由で呼ぶこと。
    - `_BaseNode_PtrCompInterface & _BaseNode_PtrRangeCompInterface & _Base_MultiplicityHelperInterface`を
      満たすこと。
    - public typealias `___TreeIndex`を満たすこと。
  - 通らなかったもの: `_BaseNode_NodeCompareProtocol`を制約に使うclientは`cannot find type ... in scope`になった。
  - symbol graphは根拠に使っていない。
- **最小access:** `package`が正しい。
  - `TreeNodeOnlyFixture.swift:93,102,114`は、Releaseの非`@testable` importで使う。
  - `@usableFromInline`は不要。このprotocolを継承する`@usableFromInline` protocolはなく、`@inlinable`本体からの参照もない。
  - 参照は4 containerの適合と、上記fixtureだけである。
- **互換mode:** 互換側のconsumerは`_BaseNode_PtrCompInterface` / `_PtrRangeCompInterface`(public)を制約に使う。
  このprotocolは参照していない。
- **記録の文言:** CHANGELOG、PROGRESS_OVERVIEW、上の結果節の内容は、実際の差分と合っている。
  PROGRESS_OVERVIEWはSignedDistanceを分離したと明記している。Codexの検証は、通常Debug・Release・互換mode・DocCを覆っている。
  足りない構成はない。

Verdict: `approve G3 NodeCompare`

### G3 SignedDistance targeted compile experiment

2026-10-04 / Codex。G3後半の`_BaseNode_SignedDistanceProtocol`を、Index設計やwitness移設を
行わないaccess-only変更として実sourceで検証した。実験後、sourceは元のpublic宣言へ復元した。

1. protocolだけを`package`へ縮小し、既定の`___signed_distance`を`public`のままにすると、
   `cannot declare a public static method in an extension with package requirements`となる。
   extensionの`where Self: ~Copyable`により、G4と同じpackage requirements制約に当たる。
2. `___signed_distance`も`package`へ下げると、4 containerのpublic
   `_BaseNode_SignedDistanceInterface`適合について、`method '___signed_distance' must be
   declared public because it matches a requirement in public protocol`となる。

したがって、`where Self: ~Copyable`、public interface、4 containerのpublic適合を維持したまま、
このprotocolだけをaccess-onlyで縮小する方法はない。where句の除去、witnessの移設・重複実装、
public protocol clusterやIndex表現の変更は別の設計作業であり、今回の範囲外とする。

- `tree_base+distance.swift`はprotocolと`___signed_distance`の両方がpublicの元状態へ復元済み。
- CHANGELOG、テスト、Package.swift、workflow、benchmark、DocC、Index実装には変更を加えていない。

Verdict: `defer G3 SignedDistance`

#### G3 SignedDistance experiment review (Claude)

2026-10-04 JST、Claude Opus 5.5。read-onlyの独立レビュー。repository内のsourceは編集していない。

- **構造の確認:**
  - `_BaseNode_SignedDistanceProtocol`(`tree_base+distance.swift:27`)の既定`___signed_distance`は、
    `extension ... where Self: ~Copyable`(`:39`)にある。
  - 4 containerのpublic `Base`は、このextensionをwitnessにしてpublic `_BaseNode_SignedDistanceInterface`を満たしている。
  - この要件は、public typealias `___TreeIndex`と、`UnsafeTreeV2+Index.swift:65`の制約付きextension
    (`distance(from:to:)`など)が使う。
- **2つの失敗の再現:** 同じ形の合成コードを、task専用の一時ディレクトリで`swiftc -package-name`によりcompileした
  (一時ディレクトリは削除済み)。合成コードは、関連型`difference_type` / `_InputIter`のsame-type制約、
  `~Copyable`、逆制約付きextension、public適合型を含む。
  - witnessを`public`のままにすると、`cannot declare a public static method in an extension with package
    requirements`と、witness不足のerrorが出る。
  - witnessを`package`にすると、`must be declared public because it matches a requirement in public protocol`が出る。
  - protocolを素の`package`にした場合と`@usableFromInline package`にした場合で、結果は同じだった。
  - 記録された2つのdiagnosticはどちらも再現し、G4で特定した逆制約句という原因と一致する。
- **access修飾子だけで済む方法:** ない。protocol、witnessのどちらのaccessを組み合わせても通らない。
  - 将来の設計案(このbatchの対象外): 逆制約句の扱いを決めること、witnessを移すか重複させること、
    public protocol clusterを見直すこと、Indexを再設計すること。
- **復元の確認:**
  - `tree_base+distance.swift`は、public protocolとpublic `___signed_distance`のまま、HEADと差分がない。
  - `git diff HEAD`の対象は、`Maintanance/CLAUDE_TASK.md`とこのファイルだけである。

Verdict: `defer G3 SignedDistance`

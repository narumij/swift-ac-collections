# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
- リリース専用Task Registry、判断gate、訓練テンプレート、完了時cleanupを含むリリースプロセスを整備

## [0.5.2] - 2026-10-09

### Changed
- BareArrayとOptionalArrayの公開APIコメントに、所有権、非所有Viewの寿命と変更共有、軸順、境界条件、破棄、計算量を明記
- Permutation通常モードの公開APIコメントに、列挙規則、入力copy、iteratorの独立性、終端、zero-based index、値semantics、計算量を明記

## [0.5.1] - 2026-10-09

### Changed
- Permutation、OptionalArray、BareArrayのテストを、公開契約へ対応する番号付きTest as Specificationとして整理

### Fixed
- BareArrayの全公開initializerで、負の次元と`Int`で表現できない次元積を事前条件違反として停止し、zero次元は空配列として許可
- BareArrayの多次元subscriptで、連鎖書き込み時の同一View writebackだけを許可し、別storageまたは範囲外位置のView代入を停止

## [0.5.0] - 2026-10-09

### Added
- 後続の互換branchで使用するAtCoder 2025時点のPermutation sourceと、提出用単一file生成utilityを追加（0.5.0の既定APIは通常版）
- PermutationModuleの`NextPermutationsSequence.Permutation`を`Equatable`、`Hashable`(要素が`Hashable`のとき)、`CustomStringConvertible`(`[1, 3, 2]`形式)へ適合。いずれも要素の並びだけで決まる
- RedBlackTreeCollectionsのSwift-DocCカタログを追加し、4つのコレクション型、3つのRange/MappedValues View、共通操作ガイドを公開APIドキュメントとして整備
- Release構成でDocCを警告込みで検証し、artifact保存と`main`からGitHub Pagesへの自動公開を行うCIを追加
- RedBlackTreeSet / MultiSet / MultiMapの利用者向け日英ドキュメントと、4型のAtCoder 2025互換APIドキュメントを追加
- 現行API、View API、C++標準ライブラリとの対応、位置指定DSL、削除API、Index validity、品質方針、テストfixtureに関する開発者向けドキュメントを追加
- `RedBlackTreeMappedValuesView`を追加し、Dictionary / MultiMap本体およびKeyValue Range Viewのmapped valueを参照・更新・交換できるようにした
- 4型すべてに`isEnd(_:)`、`isElement(at:)`、`containsSubrange(_:)`を追加
- 4型すべてに`insert(_:hint:)`等のヒント付き挿入APIを横展開し、Set / Dictionaryに`update(_:hint:)`を追加
- RedBlackTreeMultiMapに`index(inserting:)` / `erase(exactly:)`を追加(Setと同様の横展開、`ALLOW_CROSS_TREE_INDEX && !USE_LAZY_DETACH`限定)
- Bound / BoundRangeExpressionのtop-level構築APIと、4型共通の位置・範囲評価、subscript、距離、条件付き削除APIを追加
- 1,600万要素での検索・削除ベンチマーク、実行設定、Swift / C++比較結果を追加
- 4型のTest as Specificationを初期化、走査、Index、検索、挿入、削除、Range View、プロトコル適合、Codable、値セマンティクス、遅延Sequence、整数幅境界へ拡充
- 4型のCopy-on-Write、固定seed fuzz、Index validity、性能、削除stress、death testを追加・横展開
- MappedValues / KeyValue Range / KeyOnly Range View専用の仕様テストを追加
- raw range expression、node sealing、pointer比較、木の基本操作、赤黒木fixture、raw memory / allocationを直接検証する内部テストを追加

### Changed
- PermutationModuleの`nextPermutations()`の`Index == Int`制約を外し、`String`など任意の`Collection`で使えるようにした (要素はbufferへコピーしてから並べ替えるため、入力の添字型に依存しない)
- PermutationModuleの公開型を改名 (source-breaking): `Permutations<C>.Nexts` → `NextPermutationsSequence<Base>`、`IteratorN` → `NextPermutationsSequence.Iterator`、`SubSequenceN` → `NextPermutationsSequence.Permutation`。名前空間`Permutations`は廃止。`nextPermutations()`の挙動は変更なし
- staleな赤黒木Indexのsubscript・移動を`-Ounchecked`でも検査し、確保外メモリアクセス前に具体的な`SealError`診断で停止するよう変更
- 赤黒木内部の三方比較機構 (`ThreeWayCompareResult`、`Int.__less()` / `__greater()`、関連alias / eager wrapper) をpublic APIからpackage内部境界へ縮小
- KeyOnly / KeyValue Range ViewとMappedValues Viewの内部同一性hook `_isIdentical(to:)` をpublic APIから`@inlinable internal`へ縮小 (source-breaking。View同士の`==` / `<`の結果と計算量、4型の`isTriviallyIdentical(to:)`は変更なし)
- Debug構成限定のtest fixture `RedBlackTreeBoundExpression.index(_:)` / `.debug(_:)` をpublic APIから`package`へ縮小 (Debug buildのみsource-breaking。Release構成には元々存在しない)
- 旧世代のiterator `UnsafeIterator._Obverse1`〜`_Obverse3` / `_Reverse1`〜`_Reverse3` を`COMPATIBLE_ATCODER_2025`専用へ隔離 (通常構成ではsource-breaking。互換構成の挙動は変更なし)
- 通常構成で適合型のない旧iterator protocol層 (`ObverseIterator`、`ReverseIterator`、`UnsafeIteratorProtocol`と、各wrapperの条件付き適合・`reversed()`) を`COMPATIBLE_ATCODER_2025`専用へ隔離 (通常構成ではsource-breaking。互換構成の挙動は変更なし)
- 適合型もpublic signatureからの参照もない原木の参照用protocol (`_BaseKey_EquivInterface`、`_BaseNode_PtrUniqueCompInterface`、`_Base_MultiplicityHelperProtocol`、`_pointer_type`、`_BaseNode_KeyProtocol`と既定の`__get_value(_:)`) をpublic APIから`package`へ縮小 (source-breaking。宣言は移植用資料として保持し、挙動の変更なし)
- 内部の関連型を橋渡しするprotocol (`_KeyBride`、`_PayloadValueBride`、`_MappedValueBride`、`_ElementBride`、`_Tree_IsMultiTraitInterface`) をpublic APIから`@usableFromInline package`へ縮小 (source-breaking。公開コンテナ／Viewの関連型と挙動は変更なし)
- 要素の重複可否を内部型へ注入するprotocol (`UniqueMultiplicity`、`MultiMultiplicity`) をpublic APIから`package`へ縮小 (source-breaking。`isMulti` witness、関連型、4コンテナの挙動は変更なし)
- node pointerの比較witnessを供給するprotocol (`_BaseNode_NodeCompareProtocol`) をpublic APIから`package`へ縮小 (source-breaking。`___ptr_comp` / `___ptr_range_comp` witnessと4コンテナの挙動は変更なし)
- Debug限定の`SortedSequence`とsorted range union実験実装をproduction targetからテストコードへ移動
- DocCの公開メンバーをSwift標準`Set`/`Dictionary`に近い利用目的別Topicsへ分類し、独自のIndex・Range・Bound APIと全オーバーロードへ具象型ページから辿れるように変更
- Swift-DocCおよび`UInt128`を使用する通常構成に合わせ、パッケージのmacOS最小バージョンを15へ変更
- BoundsExpression / RangeExpressionを現行のBound / Index Rangeモデルへ整理し、4型の範囲subscriptと範囲削除実装を共通化
- Indexの所属、node世代、slot再利用、Copy-on-Write後の解決規則を整理し、有効性検査を強化
- node path bitmap / sealing、pointer比較、find / insert / erase、raw range、bucket確保・再利用、Copy-on-Write周辺の内部実装を整理
- KeyOnly / KeyValue Range Viewを`RedBlackTreeView`配下へ整理し、mutable Viewとしての削除・走査・比較APIを拡充
- 通常APIと`COMPATIBLE_ATCODER_2025`互換APIのテスト配置と条件コンパイルを整理
- テスト群を4型別の連番Test as Specification、共有View、内部実装、Legacy、TestSupportへ再編
- RedBlackTreeMultiMapの利用者向け日英ドキュメントに、mapped valuesの`swapAt(_:_:)`とキー順を維持した値交換の説明を追加
- README、設計文書、APIマトリクス、ベンチマーク結果を現行実装へ更新
- `isValid(_ index:)`を`isElement(at:)`へ改名し、要素へアクセス可能かの判定に意味を明確化(4型共通)
- `isValid(_ bounds: UnboundedRange/IndexRange/IndexRangeExpression)`を`containsSubrange(_:)`へ改名(4型共通)
- Set / MultiMapの`removeSafe(at:)`を`erase(exactly:)`へ改名し、戻り値を`Bool`から削除後の`Index?`へ変更

### Fixed
- `OptionalArray3DView`のsubscriptが`depth`ではなく`height`を上限に使い、非立方形の4次元配列で有効位置を拒否または範囲外位置を許していた問題を修正
- RedBlackTreeの4コンテナで、`Decodable`が未整列入力を木の順序へ正しく再構築するよう修正し、Set / Dictionaryの一意性とMultiSet / MultiMapの重複保持を回帰テストで確認
- `OptionalArray1D` / `OptionalArray1DView`で、subscriptを通じて参照型要素を`nil`へ変更した際、`move()`済みのstorageを再度deinitializeして二重解放する問題を修正
- 異なるツリー、削除済みnode、世代の異なる再利用slotに属するIndexを誤って有効と扱う問題を修正
- Copy-on-Writeで分岐した木におけるIndex解決、node世代の継承、stale Index判定を修正
- Bounds / Index Rangeの解決、距離、比較、条件付き削除、逆順・空範囲の処理を修正
- RedBlackTreeMultiMapの`index(inserting:)`が重複キーを一意挿入として扱っていた問題を修正
- 空の4型コンテナおよびMappedValues / KeyValue / KeyOnly Viewに対する削除系APIが、要素を削除しない場合にも不要なCopy-on-Writeを発生させる問題を修正
- UnsafeTreeV2のテスト用fixture setterが`.nullptr` / `.end` sentinelを通常nodeとして解決しクラッシュする問題を修正
- bucket終端、fresh / recycle pool、payload layout、pointer advance / distance / comparison周辺の不整合を修正

### Removed
- RedBlackTreeBoundExpression V2の旧実装を削除
- 旧Array-based treeの重複実装をLegacyへ隔離し、復旧不能または現行テストと重複するテスト・補助実装を削除
- 型別Test as Specificationへ移管済みの旧dictionary / multiset / multimap / fatalError / root直下テストを削除
- `Bound`/`BoundRangeExpression`を引数に取る`isValid(_:)`を削除(評価が常に安全なため事前判定が不要。空判定は`collection[bounds].isEmpty`で代替)
- PermutationModuleの全順列列挙系(`unsafePermutations()`、`Permutations.All`、`IteratorA`、`SubSequenceA`)および`unsafe`系の公開初期化経路(`unsafeNextPermutations()`、`Permutations.Nexts.init(safe:)`/`init(unsafe:)`)を削除し、`nextPermutations()`のみを公開APIとして残した(ソース破壊的変更)
- Range Viewの`unranged()`と、それ専用のプロトコル(`ScalarBaseInit`/`KeyValueBaseInit`)および`_create(_:)`要件を削除(ソース破壊的変更)

## [0.4.4] - 2026-09-24

### Added
- バケットキューと走査処理のテストを追加
- ベンチマーク結果と実行設定を追加

### Changed
- BoundsExpression、インデックス比較、バケット管理周辺の内部実装を整理
- CIのdebug / releaseテスト構成を整理
- READMEとベンチマーク結果を更新

### Fixed
- オフセット計算時のオーバーフロー検査を追加
- 内部実装のリファクタリングに伴う不整合を修正

## [0.4.3] - 2026-09-23

### Added
- メモリレイアウトと品質方針に関するドキュメントを追加
- Int32 / Int128を使用するSet / Dictionaryのテストを追加
- GitHub ActionsにAddress Sanitizerによる検証を追加

### Changed
- CIログから不要なverbose出力を削減
- パフォーマンステストの出力をblack holeへ変更
- Package.swiftでDocumentationをビルド対象から除外

### Fixed
- バケット終端、capacity、メモリアラインメント周辺のテストと実装を修正

## [0.4.2] - 2026-09-22

### Added
- BareArrayModuleを追加
- OptionalArrayModuleを追加
- `ENABLE_LEGACY_TREE_LOWER_UPPER_BOUND` traitを追加
- `USE_INT128` traitを追加
- AtCoder 2025とのAPI互換性を確認するテストを追加
- RedBlackTreeCollectionsの内部設計、メモリ安全性、Copy-on-Write、Rangeに関するドキュメントを追加
- バケットとノードのメモリレイアウトに関するテストを追加
- ベンチマーク設定と結果を追加

### Changed
- Swift tools versionを6.2へ更新
- RedBlackTreeCollectionsのlower/upper bound探索でレガシー実装を切り替え可能にし、デフォルトを新実装へ変更
- 単一のbounds expression評価とRedBlackTreeDictionaryのdefault subscriptを最適化
- READMEとベンチマーク結果・差分レポートを更新

### Fixed
- BareArray / OptionalArrayのテストを追加し、既存テストを修正
- RedBlackTreeCollectionsの比較・bounds・find周りの実装を修正
- Swift 6.2でのComparable / Equatable適合に関するコンパイル互換性を修正
- deprecatedなSet / MultiSetの`remove(at:)`でendIndexを不正なインデックスとして扱うよう修正

### Removed
- Rigid系の実験コードを削除

## [0.4.1] - 2026-06-04
### Added
- Benchmarksパッケージを追加し、RedBlackTreeDictionary / RedBlackTreeSetのベンチマーク結果を整理
- Death test / fatal error系のテストを整理・追加
- RigidArray系の実験コードを追加

### Changed
- RedBlackTreeModuleからRedBlackTreeCollectionsへの移行後の互換性・deprecated APIを調整
- テスト・ベンチマーク用ターゲット構成を整理
- README / LICENSE / Package.swiftを更新

### Fixed
- 互換性維持のためのdeprecated APIを修正
- コンパイルエラーとテストを修正

### Removed
- 旧Tests/Benchmarks・Tests/Executables系の実験ターゲットを整理・削除

## [0.4.0] - 2026-06-01
### Changed
- RedBlackTreeModuleをRedBlackTreeCollectionsへリネーム
- Package.swiftのターゲット構成をRedBlackTreeCollections向けに更新

## [0.3.4] - 2026-06-01
### Added
- CollectionBenchmarks / Benchmark7を追加
- RedBlackTreeSetのreserveCapacityテストを追加
- `LazyDetach` / `_KeyOnly_FindEqual`など内部実装を追加
- Benchmark.Chartsを追加

### Changed
- RedBlackTreeSet / MultiSet / MultiMap / DictionaryのIndex・Sequence・RangeExpression・SetAlgebra周りを更新
- bounds / find / iterator / copy-on-write周りの内部実装を大きく整理
- benchmarkとREADMEを更新

### Fixed
- set algebra、ensureCapacity、find、index、iterator周りの不具合を修正
- コンパイル警告とテストを修正

### Removed
- 一部の実験用executable / benchmarkターゲットを削除
- 不要なコメントアウト・dead codeを削除

## [0.3.3] - 2026-05-13
### Added
- SetAlgebra関連の実装とテストを追加・拡充
- `pop` / `removeFirst` / `removeLast` / min-max / count周りの操作を追加・調整
- ベンチマークを追加・更新

### Changed
- UnsafeIndexV3 / RawRange / iterator / tied buffer proxy周りを更新
- `@inlinable` / `@usableFromInline` / `@inline(__always)`周りの指定を整理
- 互換性維持用APIとdeprecated APIを整理

### Fixed
- 互換性、テスト、ベンチマークを修正

## [0.3.2] - 2026-05-10
### Added
- LRU / Memoizeのhandle実装を追加
- UnsafeTreeV2 / RawBuffer / RawRangeのdeprecated互換APIを追加
- coverage・テストを追加

### Changed
- UnsafeIteratorのKey / KeyValue / MappedValue / Payload周りを更新
- RawBuffer、Bucket、FreshPool、TiedRawBuffer周りの内部実装を整理
- three-way compareとポインタ比較周りを整理

### Fixed
- 互換性とテストを修正
- コンパイル警告を削減

## [0.3.1] - 2026-05-06
### Added
- RedBlackTreeDictionary / Set / MultiSet / MultiMapを機能別ファイルへ分割
- Codable / Equatable / Hashable / Comparable / CustomReflectable / Literal / Sendable / Sequence / Subscript / ReserveCapacity系の実装ファイルを追加
- UnsafeIteratorのTiedIndexingとRawRange関連を追加

### Changed
- RedBlackTreeModule配下の実装を`Implements`以下へ大きく再配置
- BoundsExpression / RangeExpression / UnsafeIndexV3 / UnsafeTreeV2 / RawBuffer / __tree周りのファイル構成を整理
- Package.swiftとGitHub Actionsを更新
- バッファ確保・capacity growth・deallocation周りを調整

### Fixed
- tied raw bufferのdeallocation、初期化チェック、iterator周りの不具合を修正
- 互換性とテストを修正

### Removed
- 旧配置のファイルと一部deprecatedコードを削除

## [0.3.0] - 2026-02-23
### Added
- README.ja.mdを追加
- BoundsExpressionの新API（RedBlackTreeBoundExpression / RedBlackTreeBoundRangeExpression）を追加
- UnsafeIndexV3とRawRangeExpression系を追加
- UnsafeIteratorにObverse/Reverse系のバリエーションを追加

### Changed
- BoundsExpression関連の配置と実装を更新（BoundExpression→BoundsExpression）
- UnsafeIndexV2をDeprecatedに移動
- README/Package.swiftの更新・整理

### Fixed
- release buildの修正
- テストの修正
- protocol conformanceの修正

### Removed
- death testをスキップ（テスト設定の変更）

## [0.2.28] - 2026-01-25
### Changed
- UnsafeTreeV2の内部実装を整理
- Memoizeの内部実装を整理
### Fixed
- テストの修正

## [0.2.17] - 2026-01-25
### Changed
- BoundsExpression / RangeExpressionの実装を調整
- allocation / erase周りの実装を調整
### Fixed
- ensureCapacity関連の修正
- テストの修正

## [0.2.16] - 2026-01-25
### Added
- BoundsExpressionを追加（Dictionary / Set / MultiSet / MultiMap）
- RangeExpressionを追加（Dictionary / Set / MultiSet / MultiMap / Slice）
- UnsafeIndexV2を追加
- UnsafeTreeV2のDebug/Testing（Graphviz等）を追加
### Changed
- イテレーターの実装を更新（RedBlackTreeIteratorV2など）
- Deprecated APIを整理

## [0.2.15] - 2026-01-05
### Added
- UnsafeTreeV2を追加
- Benchmarksを追加/更新
### Removed
- RedBlackTreeSlice（旧実装）を削除

## [0.2.14] - 2025-12-27
### Changed
- Deprecated APIの調整
- テストの整理

## [0.2.13] - 2025-12-27
### Changed
- READMEの更新
- 逆順イテレーター周りの調整

## [0.2.12] - 2025-12-26
### Added
- 互換性維持のためのDeprecated APIを追加

## [0.2.11] - 2025-12-25
### Changed
- Base/Protocol構成の整理（内部実装のリファクタリング）

## [0.2.10] - 2025-12-24
### Fixed
- Memoizeの修正

## [0.2.9] - 2025-12-24
### Changed
- Memoizeの調整

## [0.2.8] - 2025-12-24
### Added
- KeyValueIterator等の追加
### Removed
- RedBlackTreeMap（型/実装/テスト）を削除

## [0.2.7] - 2025-12-09
### Changed
- Key iterator周りの調整
### Fixed
- テストの修正

## [0.2.6] - 2025-12-05
### Changed
- `__tree`の内部実装を更新

## [0.2.5] - 2025-12-03
### Changed
- three way comparator周りの実装を更新
- テストの修正

## [0.2.4] - 2025-11-03
### Fixed
- Index周りの軽微な修正

## [0.2.3] - 2025-11-03
### Fixed
- Index周りの軽微な修正

## [0.2.2] - 2025-10-26
### Changed
- llvm(`__tree`)由来のlower/upper bound実装更新を反映（unique側の探索実装を調整）
- リファクタリング・リネーム
### Fixed
- テストの修正

## [0.2.1] - 2025-10-20
### Added
- サブシーケンスのサブスクリプトにRangeExpression対応を追加
### Fixed
- DictionaryとMapのinsertのバグを修正

## [0.2.0] - 2025-10-12
### Added
- RedBlackTreeMapを追加
- RedBlackTreeIndexを追加
- RedBlackTreeSliceを追加
- RangeExpression対応を追加
### Changed
- RedBlackTreeMultiMapのKeyValueをタプルから構造体に変更
- IndexをRedBlackTreeIndexに変更
- SubSequenceをRedBlackTreeSliceに変更
- 内部Indexの比較アルゴリズムを変更
- プロトコル構成の変更
- `_unsafe`サブスクリプトを`unchecked`に変更
### Fixed
- Xcodeでコード補完が効きにくい不具合の修正

## [0.1.44] - 2025-9-3
(AtCoder 2025搭載版です)

## [0.1.43] - 2025-9-3

## [0.1.42] - 2025-8-22

## [0.1.41] - 2025-8-10

## [0.1.40] - 2025-8-3

## [0.1.39] - 2025-7-30

## [0.1.38] - 2025-7-21
### Changed
- tree+base.swiftファイルの更新（PR #38）
- tree.swiftファイルの更新
- tree+insert.swiftファイルの更新
- left unsafe実装の継続改善
- テストの重量化対応
### Fixed
- Copilotによるコードレビュー対応

## [0.1.37] - 2025-7-21
### Changed
- left unsafe実装の改善（PR #36）
- root ptr関連の修正
- tree.swiftファイルの更新
- find、equal関連のアルゴリズム修正
### Fixed
- CHANGELOGに記載されていなかったバージョン0.1.32-0.1.36を追加
- バージョン0.1.31の日付を修正
- Copilotによるコードレビュー対応

## [0.1.36] - 2025-7-21
### Changed
- left unsafe関連の実装修正

## [0.1.35] - 2025-7-17
### Changed
- テストの修正
- メモ機能の削除
- 0.1.30-0.1.32のチューニングをリバート

## [0.1.34] - 2025-7-14
### Removed
- Copy-on-Write機能を削除
### Changed
- テストの修正
- リファクタリング

## [0.1.33] - 2025-7-13
### Added
- memoize cache機能を追加

## [0.1.32] - 2025-7-11
### Changed
- un-inline化
- テストの修正
- 成長係数の調整
- コメントの追加

## [0.1.31] - 2025-7-9
### Added
- MemoizePack及びMemoizeCacheを追加
### Changed
- 対応プラットフォームバージョンを変更

## [0.1.30] - 2025-6-30
### Added
- init(naive:)を追加
### Changed
- 初期化コードの修正

## [0.1.29] - 2025-6-28
### Changed
- 内部実装の改善

## [0.1.28] - 2025-6-14
### Added
- MultiSetにmeld及びmeldingメソッドを追加
- MultiMapにmeld及びmeldingメソッドを追加

## [0.1.27] - 2025-6-14
### Fixed
- タグミス修正

## [0.1.26] - 2025-6-9
### Changed
- 各種シーケンスをequatable適用

## [0.1.25] - 2025-6-8
### Added
- 各種シーケンスにシーケンス生成メソッドを追加
### Changed
- RawIndexを用いるforEachを非公開扱いに降格
- rawIndicesを非公開扱いに降格
- 辞書やmultimapのkeys及びvaluesをプロパティからメソッドに変更

## [0.1.24] - 2025-6-7
### Changed
- ビルド時の警告を抑制

## [0.1.23] - 2025-6-7
### Added
- RangeExpression用のisValidメソッドを追加
### Changed
- isValidメソッドの判定条件をsubscriptやremoveで利用可能な範囲に限定する変更

## [0.1.22] - 2025-6-5
### Changed
- チューニング

## [0.1.21] - 2025-6-3
### Added
- forEachを追加
### Removed
- RawIndexedItetator及びRawIndexedSequenceと関連プロパティの削除
### Changed
- 内部APIの整理改変

## [0.1.20] - 2025-5-31
### Fixed
- タグミス修正

## [0.1.19] - 2025-6-2
### Fixed
- タグミス修正

## [0.1.18] - 2025-5-31
### Added
- `Range<Index>`相当のシーケンスを追加
### Removed
- Pointer(Index)のStridable対応を削除
- over,underを削除

## [0.1.17] - 2025-5-27
### Added
- over及びunderを追加
- Pointerにover及びunderの判定を追加
### Changed
- Pointer(Index)をStridableに対応
- BidirectionalCollection適合のIndexがIntからPointerに変更
- enumerated()を`___enumerated`()にリネームし、非公開扱いに変更

## [0.1.16] - 2025-5-27
### Added
- RedBlackTreeMultiMapを追加
- equalRangeメソッドを追加
- RedBlackTreeDictionaryにcontains(forKey:)、min()、max()を追加
### Changed
- RedBlackTreeMultisetをRedBlackTreeMultiSetに名称変更
- `___equal_range`メソッドをinternalに変更

## [0.1.15] - 2025-5-24
### Added
- popFirstメソッドを追加
- elements(in:)メソッドを追加
- 辞書にmergeとmergingメソッドを追加
- 辞書にmapValuesとcompactMapValuesメソッドを追加
- 辞書にfilterメソッドを追加
- 辞書にExpressibleByArrayLiteral適用を追加
### Changed
- setやmultisetの添え字による要素範囲取得をdeprecatedに変更

## [0.1.14] - 2025-5-10
### Changed
- nextPermutations()をunsafeNextPermutations()に名前変更
### Added
- イテレーター使用時にコピー動作をするnextPermutations()を追加

## [0.1.13] - 2025-2-1
### Fixed
- Indexの内部メンバーを削除

## [0.1.12] - 2025-1-27
### Added
- Indexにメンバーを追加

## [0.1.11] - 2025-1-26
### Fixed
- Tagの打ち直し

## [0.1.10] - 2025-1-26
### Added
- IndexSequenceを追加

## [0.1.9] - 2025-1-24
### Fixed
- コードカバレッジの改善

## [0.1.8] - 2025-1-24
### Changed
- Index比較アルゴリズムを修正

## [0.1.7] - 2025-1-19
### Added
- ClosedRangeを利用するメソッドの追加
- SubsequenceにisValid(index:)を追加
### Changed
- Rangeの範囲間違いを修正

## [0.1.6] - 2025-1-17
### Added
- `_MemoizeCacheCoW`を追加
### Changed
- Nodeのレイアウトを変更

## [0.1.5] - 2025-1-13
### Added
- `_MemoizeCacheLRU`を追加
- `_MemoizeCacheStandard`を追加
- `_MemoizeCacheBase`にinfoを追加
- バッファの成長サイズ計算式を変更

## [0.1.4] - 2025-1-8
### Added
- `_MemoizeCacheBase`にキャパシティ上限機能を追加
- `_MemoizeCacheBase`のinitにキャパシティ上限値パラメータを追加
### Changed
- ManagedBufferの期待確保サイズではなく、実確保サイズをキャパシティ値として用いるよう変更
- バッファの成長サイズ計算式と係数を変更
- `___RedBlackTreeMapBase`を`_MemoizeCacheBase`に名称変更

### Fixed
- `___RedBlackTreeMapBase`の`_tree`メンバーをinternalに変更

## [0.1.3] - 2025-1-8
### Removed
- Ouncheckedフラグの再追加と再削除

## [0.1.2] - 2025-1-7
### Fixed
- リリースミスの解消

## [0.1.1] - 2025-1-7
### Added
- remove(contesntsOf:)を追加
- insert(contesntsOf:)を追加
- RedBlackTreeSetにSetAlgebraを追加
### Changed
- contains(:)を変更
- 初期化方式の変更
- count(_:)をcount(of:)に変更

## [0.1.0] - 2025-1-2
### Added
- ジャッジ用の初期バージョン

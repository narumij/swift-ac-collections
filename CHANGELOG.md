# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- BareArrayModuleを追加
- OptionalArrayModuleを追加
- `ENABLE_LEGACY_TREE_LOWER_UPPER_BOUND` traitを追加
- `USE_INT128` traitを追加

### Changed
- Swift tools versionを6.2へ更新
- RedBlackTreeCollectionsのlower/upper bound探索でレガシー実装を切り替え可能に変更
- ベンチマーク結果・差分レポートを更新

### Fixed
- BareArray / OptionalArrayのテストを追加し、既存テストを修正
- RedBlackTreeCollectionsの比較・bounds・find周りの実装を修正

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

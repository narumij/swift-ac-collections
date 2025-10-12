# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2025-10-12
### Added
- RedBlackTreeIndexを追加
- RedBlackTreeSliceを追加
- RangeExpression対応を追加
### Changed
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

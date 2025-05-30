# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.18] - 2025-?-?
### Removed
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

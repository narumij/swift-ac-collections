# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.5] - 2025-1-?
### Added
- `_MemoizeCacheLRU`を追加

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

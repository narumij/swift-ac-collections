<!-- このREADME.ja.mdを正本とします。README.mdは、この文書の英訳コピーです。 -->
<!-- 1.0になるまで多少のジョークを許容すること -->

# swift-ac-collections

[English](README.md) | 日本語

## コンセプト

swift-ac-collections は、

**C++ の `std::set` / `std::map` に匹敵する性能を目指すソート済み集合・辞書**
を中心に、さまざまなデータ構造を提供する Swift ライブラリです。

このソート済み集合・辞書は、**「C++ の `std::set` / `std::multiset` を前提とした
[AtCoder][atcoder] の問題を、Swift でも実用的な性能で解けるようにする」**
ことを目的として設計されています。

[![CI](https://github.com/narumij/swift-ac-collections/actions/workflows/ci.yml/badge.svg?event=pull_request)](https://github.com/narumij/swift-ac-collections/actions/workflows/ci.yml?query=event%3Apull_request)
[![Platforms](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fnarumij%2Fswift-ac-collections%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/narumij/swift-ac-collections)
[![Swift](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fnarumij%2Fswift-ac-collections%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/narumij/swift-ac-collections)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

## 利用方法

### Swift Package Manager での利用

現行パッケージはSwift 6.4以降が必要です。macOSでは15以降を対象とします。

`Package.swift` の `dependencies` に以下を追加してください:

```swift
dependencies: [
  .package(
    url: "https://github.com/narumij/swift-ac-collections",
    branch: "main"),
]
```

さらに、ビルドターゲットに以下を追加します:

```swift
dependencies: [
  .product(name: "AcCollections", package: "swift-ac-collections")
]
```

ソースコード上で以下を記述してインポートできます:

```swift
import AcCollections
```

通常の入口は`AcCollections`で、Permutation APIも再公開します。moduleを直接利用する場合の
主入口は`NextPermutationModule`です。旧名`PermutationModule`は同じ宣言を再公開する互換入口として残します。

### OptionalElementBufferを有効にする

`OptionalElementBuffer`は既定では`AcCollections`から公開されません。実験的な低レベル部品として
明示的に利用する場合は、package dependencyで`ENABLE_OPTIONAL_ELEMENT_BUFFER` traitを有効にします。

```swift
dependencies: [
  .package(
    url: "https://github.com/narumij/swift-ac-collections",
    branch: "main",
    traits: ["ENABLE_OPTIONAL_ELEMENT_BUFFER"]),
]
```

traitを有効にした後は、通常どおり`AcCollections`をimportすると1Dから4Dの
`OptionalElementBuffer`を利用できます。SwiftPMのtrait設定については、
[Swift Package Managerの案内](https://docs.swift.org/latest/documentation/packagemanagerdocs/addingdependencies/#Packages-with-Traits)を参照してください。

<!-- 英訳: Branch Strategy -->
## ブランチ運用方針

| Branch | Recommended | Description |
|----------|----------|----------|
| `main` | ⭐ | 開発版（Swift 6.4以降） |
| `compatible/AtCoder/2025` | | AtCoder 2025 互換版 |
| `release/AtCoder/2025` | | AtCoder 2025 搭載版 |

<!-- 英訳: Which branch should I use? -->
通常は `main` を利用してください。現在は開発中で、APIや実装は変更される可能性があります。

AtCoder 2025互換版は `compatible/AtCoder/2025`、搭載時の版は `release/AtCoder/2025` です。

---

## コンテナ

- RedBlackTreeSet — ソート済み集合（重複なし）
- RedBlackTreeMultiSet — ソート済み集合（重複あり）
- RedBlackTreeDictionary — ソート済み辞書（キー一意）
- RedBlackTreeMultiMap — ソート済みマップ（重複キー可）

## 削除について

インデックスは削除で無効になります（再利用不可）。
連続削除には範囲削除 API を使用してください。

## ドキュメント

各モジュールの現行ソース版ガイド：

- [RedBlackTreeCollections](Sources/RedBlackTreeCollections/RedBlackTreeCollections.docc/RedBlackTreeCollections.md)
- [NextPermutationModule](Sources/NextPermutationModule/NextPermutationModule.docc/NextPermutationModule.md)
- [OptionalElementBufferModule](Sources/OptionalElementBufferModule/OptionalElementBufferModule.docc/OptionalElementBufferModule.md)
- [ElementBufferModule](Sources/ElementBufferModule/ElementBufferModule.docc/ElementBufferModule.md)

APIドキュメントは[Swift Package Index](https://swiftpackageindex.com/narumij/swift-ac-collections)の
ドキュメントリンクから閲覧できます（初回生成・公開待ち）。
公開されるまでは、[GitHub PagesのAPIドキュメント](https://narumij.github.io/swift-ac-collections/documentation/redblacktreecollections/)をご利用ください。

## AtCoder 2025

AtCoder 2025 ジャッジと同一のものをご希望の場合は、以下を指定してください。

```swift
dependencies: [
  .package(
    url: "https://github.com/narumij/swift-ac-collections",
    branch: "release/AtCoder/2025"),
]
```

## ライセンス

このライブラリは [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0) に基づいて配布しています。

RedBlackTreeCollectionsの`__tree`は LLVM による実装をもとに改変したものであり、オリジナルのライセンスに関しては  
[LLVM libc++のライセンス](Licenses/LLVM-libcxx.txt) をご参照ください。

Swift Collections・Swift Algorithmsなどの第三者由来コードのライセンスは、[Licenses](Licenses/README.md)に収録しています。

---

不具合報告や機能追加の要望は、Issue または Pull Request でお気軽にお寄せください。  

[atcoder]: https://atcoder.jp/

<!-- 何度目かの正直 -->

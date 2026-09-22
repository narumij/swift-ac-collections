<!-- このREADME.ja.mdを正本とします。README.mdは、この文書の英訳コピーです。 -->

# swift-ac-collections

## コンセプト

swift-ac-collections は、

**「C++ の std::set / std::multiset を前提とした [AtCoder][atcoder] の問題を、
Swift でも実用的な性能で解けるようにする」**

ことを目的として設計されています。

競技プログラミングで頻出する順序付き集合・辞書を、
赤黒木ベースで提供します。
C++ 標準ライブラリとの性能乖離をできるだけ小さくすることを重視しています。

[![Swift](https://github.com/narumij/swift-ac-collections/actions/workflows/swift.yml/badge.svg?branch=main)](https://github.com/narumij/swift-ac-collections/actions/workflows/swift.yml)  
[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

## 利用方法

### Swift Package Manager での利用

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

## Branch Strategy

| Branch | Recommended | Description |
|----------|----------|----------|
| `main` | ⭐ | 通常利用。最新の安定版 Swift を対象とする開発版 |
| `compatible/AtCoder/2025` | | AtCoder 2025 互換版 |
| `release/AtCoder/2025` | | AtCoder 2025 搭載版 |

### Which branch should I use?

通常は `main` の利用をおすすめします。

AtCoder 2025 ジャッジ環境との互換性が必要な場合は、`compatible/AtCoder/2025` を利用してください。このブランチでは AtCoder 2025 との互換性を維持したまま、ドキュメント補強、deprecated 指定、注意喚起の追加などの保守を行っています。

`release/AtCoder/2025` は AtCoder に搭載されている状態をそのまま保持するためのブランチです。

`main` は最新の安定版 Swift を対象とする開発中のブランチです。基本的な機能と検証は揃いつつあり、現時点でも試用できます。ただし、安定版としての API 互換性はまだ保証しておらず、API や実装が変更される可能性があります。

---

## コンテナ

- RedBlackTreeSet — ソート済み集合（重複なし）
- RedBlackTreeMultiSet — ソート済み集合（重複あり）
- RedBlackTreeDictionary — ソート済み辞書（キー一意）
- RedBlackTreeMultiMap — ソート済みマップ（重複キー可）

## 削除について

インデックスは削除で無効になります（再利用不可）。
連続削除には範囲削除 API を使用してください。

## アンダースコア付き宣言について

「アンダースコア付き宣言」は、完全修飾名のどこかにアンダースコア (`_`) で始まる部分が含まれる宣言のことを指します。たとえば、以下のような名前は技術的に `public` として宣言されていても、パブリックAPIには含まれません：

- `FooModule.Bar._someMember(value:)`（アンダースコア付きのメンバー）
- `FooModule._Bar.someMember`（アンダースコア付きの型）
- `_FooModule.Bar`（アンダースコア付きのモジュール）
- `FooModule.Bar.init(_value:)`（アンダースコア付きの引数を持つイニシャライザ）

さらに、コードベース全般についても同様に、互換性が保証されることは期待しないでください。これらの宣言は必要に応じて変更される可能性があり、非互換な修正が加えられる場合があります。

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
[https://llvm.org/LICENSE.txt](https://llvm.org/LICENSE.txt) をご参照ください。

---

不具合報告や機能追加の要望は、Issue または Pull Request でお気軽にお寄せください。  

[atcoder]: https://atcoder.jp/

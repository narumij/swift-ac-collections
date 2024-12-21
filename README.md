# swift-ac-collections

`swift-ac-collections` は、競技プログラミングで利用するために作成された、赤黒木（Red-Black Tree）を基盤としたコレクションライブラリです。このプロジェクトでは、LLVMの `__tree` を Swift に移植し、平衡二分木を活用したさまざまなデータ構造を提供します。

## 利用方法

SwiftPM で `swift-ac-collections` を利用するには、以下を `Package.swift` に追加してください。

```swift
dependencies: [
  .package(url: "https://github.com/narumij/swift-ac-collections.git", from: "0.0.1"),
]
```

ビルドターゲットに以下を追加します。

```swift
dependencies: [
  .product(name: "AcCollections", package: "swift-ac-collections")
]
```

ソースコードに以下を記述してインポートします。

```swift
import AcCollections
```

## 内容

### RedBlackTreeModule

[平衡二分木](https://ja.wikipedia.org/wiki/平衡二分探索木)の一種である [赤黒木](https://ja.wikipedia.org/wiki/赤黒木) を用いたコレクションを実装しています。このモジュールは、以下の3つのデータ構造を提供します：

#### RedBlackTreeSet
- 二分探索木をベースにした集合(Set)のデータ構造です。
- 要素の挿入、削除、探索を効率的に行えます。

以下のリンクから具体的な使用例を見ることができます：
- [使用例](https://atcoder.jp/contests/abc370/submissions/57922896)

#### RedBlackTreeMultiSet
- 重複要素を許容する集合(MultiSet)のデータ構造です。
- 同じ要素を複数回保持できる点が `RedBlackTreeSet` との違いです。

以下のリンクから具体的な使用例を見ることができます：
- [使用例](https://atcoder.jp/contests/abc358/submissions/59018223)

#### RedBlackTreeDictionary
- 辞書(Dictionary)として利用可能なキーと値のペアを管理するデータ構造です。
- **補助的な実装であり、実用性や機能性が十分ではありません。**
  - シンプルな動作や基本的な用途には対応していますが、競技プログラミングでの使用には注意が必要です。

### TreeSet等との差異

謹製のTreeSetは集合操作に長けていますが、BidirectionaCollectionに対応していないこともあり、クエリー的な用途で不利となっています。
対してこちらの実装では、BidirectionalCollectionへ対応していることと、lowerBoundやupperBoundがあることで、クエリー的な用途でも使えるようになっています。
一方で集合的な操作に関してはほとんど実装しておりません。そういった用途には標準のSetや、その他集合のコレクションをご利用ください。

## ライセンス

このプロジェクトは LLVM の派生成果物であり、特例が不要であるため、Apache 2.0 ライセンスに基づいて公開されています。

もしライセンスに関して誤解や間違いがある場合は、ご指摘いただけると幸いです。

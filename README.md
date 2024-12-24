# swift-ac-collections

`swift-ac-collections` は、Swift で実装された赤黒木（Red-Black Tree）ベースのコレクションライブラリです。  
競技プログラミング等での高速な挿入・削除・探索が必要な場合に役立ちます。

## 利用方法

### Swift Package Manager での利用

`Package.swift` の `dependencies` に以下を追加してください:

dependencies: [
  .package(url: "https://github.com/narumij/swift-ac-collections.git", from: "0.0.1"),
]

さらに、ビルドターゲットに以下を追加します:

dependencies: [
  .product(name: "AcCollections", package: "swift-ac-collections")
]

ソースコード上で以下を記述してインポートできます:

import AcCollections

## 内容

### RedBlackTreeModule

本ライブラリでは、赤黒木（Red-Black Tree）を用いて以下のコレクションを提供しています。

#### 1. RedBlackTreeSet

- **重複なし** の要素を管理する Set。  
- 要素の挿入・削除・探索を平均的に `O(log n)` で行えます。  
- `Collection` に適合しており、インデックスによる要素アクセスや `startIndex` / `endIndex` などが利用可能です。  
- 境界探索メソッド（`lowerBound` / `upperBound`）なども提供しています。  
- 使用例: [AtCoder 提出例](https://atcoder.jp/contests/abc370/submissions/57922896) / [AtCoder 提出例](https://atcoder.jp/contests/abc385/submissions/61003801) など。

#### 2. RedBlackTreeMultiSet

- **重複あり** の要素を管理する MultiSet。  
- `count(_:)` により、特定の要素が何個含まれるかを取得できます。  
- その他の特性や使い方は `RedBlackTreeSet` に準じます。  
- 使用例: [AtCoder 提出例](https://atcoder.jp/contests/abc358/submissions/59018223) など。

#### 3. RedBlackTreeDictionary

- **キーと値** を管理する Dictionary。  
- 基本的なキー検索・挿入・削除などの操作を `O(log n)` で行えます。  
- 連想配列リテラル（`ExpressibleByDictionaryLiteral`）にも対応しています。

## 簡単な使用例

import AcCollections

// RedBlackTreeSet の例
var set = RedBlackTreeSet<Int>()
set.insert(10)
set.insert(5)
set.insert(5)    // 重複は無視される
print(set)       // 例: [5, 10]
print(set.min()) // 例: Optional(5)

// RedBlackTreeMultiSet の例
var multiset = RedBlackTreeMultiSet<Int>([1, 2, 2, 3])
multiset.insert(2)
print(multiset)       // 例: [1, 2, 2, 2, 3]
print(multiset.count(2))  // 例: 3

// RedBlackTreeDictionary の例
var dict = RedBlackTreeDictionary<String, Int>()
dict["apple"] = 5
dict["banana"] = 3
print(dict) // 例: [apple: 5, banana: 3]

## ライセンス

このライブラリは [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0) に基づいて配布しています。  
本コードは LLVM による実装をもとに改変したものであり、オリジナルのライセンスに関しては  
[https://llvm.org/LICENSE.txt](https://llvm.org/LICENSE.txt) をご参照ください。

---

不具合報告や機能追加の要望は、Issue または Pull Request をお寄せください。  
ご利用いただきありがとうございます！

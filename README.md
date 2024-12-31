# swift-ac-collections

`swift-ac-collections` は、Swift で実装された赤黒木（Red-Black Tree）ベースのコレクションライブラリです。  

## 利用方法

### Swift Package Manager での利用

`Package.swift` の `dependencies` に以下を追加してください:

```Swift
dependencies: [
  .package(url: "https://github.com/narumij/swift-ac-collections.git", from: "0.0.1"),
]
```

さらに、ビルドターゲットに以下を追加します:

```Swift
dependencies: [
  .product(name: "AcCollections", package: "swift-ac-collections")
]
```

ソースコード上で以下を記述してインポートできます:

```Swift
import AcCollections
```

## 内容

### RedBlackTreeModule

本ライブラリでは、赤黒木（Red-Black Tree）を用いて以下のコレクションを提供しています。

#### 1. RedBlackTreeSet

- **重複なし** の要素を管理する Set。  
- 要素の挿入・削除・探索を平均的に `O(log n)` で行えます。  
- `Collection` に適合しており、インデックスによる要素アクセスや `startIndex` / `endIndex` などが利用可能です。  
- 境界探索メソッド（`lowerBound` / `upperBound`）なども提供しています。  
- 使用例: [AtCoder 提出例](https://atcoder.jp/contests/abc370/submissions/57922896) / [AtCoder 提出例](https://atcoder.jp/contests/abc385/submissions/61134983) など。

#### 2. RedBlackTreeMultiSet

- **重複あり** の要素を管理する MultiSet。  
- `count(_:)` により、特定の要素が何個含まれるかを取得できます。  
- その他の特性や使い方は `RedBlackTreeSet` に準じます。  
- 使用例: [AtCoder 提出例](https://atcoder.jp/contests/abc358/submissions/59018223) など。

#### 3. RedBlackTreeDictionary

- **キーと値** を管理する Dictionary。  
- 基本的なキー検索・挿入・削除などの操作を `O(log n)` で行えます。  
- 連想配列リテラル（`ExpressibleByDictionaryLiteral`）にも対応しています。
- Swift 5.8.1では標準辞書に及びませんが、Swift 6.0ではこちらの方が速い場合もあります。

## 簡単な使用例

```Swift
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
```

## 削除時のインデックス（ポインタ）無効化と安全な範囲削除方法

削除操作を行うことで、対象のノードとインデックスは無効となります。ツリーから外れ、再利用管理リンクリストの一部となります。

範囲削除を行う際は、この挙動には十分に注意を払う必要があります。

- 削除されたノードへの参照を使い続けると、クラッシュします。有効無効の確認が必要な場合、isValid(index:)を使ってください。

- `enumerated()` は単なる連番ではなく、実際のノードインデックスを返すように挙動が変更されています。

- endIndexは例外で、常に不変です。

### 範囲削除方法の例

1. whileループで削除する

```Swift
var b: RedBlackTreeSet<Int> = [0,1,2,3,4,5]
var i = b.startIndex
while i != b.endIndex { // endIndexは不変
  let j = i
  i = b.index(after: i)
  b.remove(at: j) // jはこの時点で無効になる
  XCTAssertFalse(b.isValid(index: j))
}
XCTAssertEqual(b.count, 0)
```

2. enumerated()で削除する

enumerated()の挙動が変更されていて、単調増加の整数との組み合わせでは無く、ノードインデックスと値を返します。
削除のための対策が施してあり、内部的には値を返した時点で次の値を持っています。このため、以下のように書いて問題ありません。


```Swift
var b: RedBlackTreeSet<Int> = [0,1,2,3,4,5]
for (i,_) in b[b.startIndex ..< b.endIndex].enumerated() {
  b.remove(at: i) // iはこの時点で無効
  print(b.isValid(index: i)) // false
}
print(b.count) // 0
```

3. removeSubrange()で削除する

範囲削除メソッドのremoveSubrange(...)もあります。削除動作のオーバーヘッドが一番少なく、他の方法と比べて一番速いです。

```Swift
var b: RedBlackTreeSet<Int> = [0,1,2,3,4,5]
b.removeSubrange(b.startIndex ..< b.endIndex)
XCTAssertEqual(b.count, 0)
```

4. erase()を自作して削除する

標準ライブラリに寄せた作りにしたため、eraseは非公開となっていますが、C++のsetと同じような削除コードを書くことも可能です。

```Swift
extension RedBlackTreeSet {
  mutating func erase(at position: Index) -> Index {
    defer { remove(at: position) }
    return index(after: position)
  }
}

var tree3: RedBlackTreeSet<Int> = [0, 1, 2, 3, 4, 5]
var idx = tree3.startIndex
while idx != tree3.endIndex {
  idx = tree3.erase(at: idx)
}
```

5. removeSubrange(:Range<Element>)を自作して削除する。

インデックスを操作するコードは、インデックスが整数ではない場合、煩雑になりがちで負担が大きいモノです。
単に値と値の間の削除をしたい場合、以下のようにすることで可能です。


```Swift
extension RedBlackTreeSet {
  mutating func removeSubrange(_ range: Range<Element>) {
    let lower = lowerBound(range.lowerBound)
    let upper = upperBound(range.upperBound)
    var it = lower
    while it != upper {
      it = erase(at: it)
    }
  }
}

var tree4: RedBlackTreeSet<Int> = [0, 1, 2, 3, 4, 5]
tree4.removeSubrange(0 ..< 6)
// 0〜5が削除され、結果は空
```

### Multisetのremove(:)

RedBlackTreeMultisetのremove(:)は、enumerated()やforEach(:)の削除時対策が効かないため、通常のコピーオンライトとくらべて、さらにコピーが発生しやすい挙動としています。

このため、要素数が多い場合には注意を必要とします。具体的には、削除時に有効なイテレータやサブシーケンスが存在しない状態にする必要があります。削除に必要な情報は一度map関数で配列にする等。

## アンダースコア付き宣言について

「アンダースコア付き宣言」は、完全修飾名のどこかにアンダースコア (`_`) で始まる部分が含まれる宣言のことを指します。たとえば、以下のような名前は技術的に `public` として宣言されていても、パブリックAPIには含まれません：

- `FooModule.Bar._someMember(value:)`（アンダースコア付きのメンバー）
- `FooModule._Bar.someMember`（アンダースコア付きの型）
- `_FooModule.Bar`（アンダースコア付きのモジュール）
- `FooModule.Bar.init(_value:)`（アンダースコア付きの引数を持つイニシャライザ）

また、`Tests`、`Utils`、`Benchmarks` の各サブディレクトリに含まれる内容もパブリックAPIではありません。これらは自由に引用し、自前のライブラリとしてメンテナンスするための「盆栽」としてお使いください。ただし、これらに関してはソースコードの互換性を保証することはありません。将来のリリースで内容が変更されたり、削除される可能性があるため、必要な部分をコピーして独自に管理することを推奨します。

さらに、アンダースコア付き宣言全般についても同様に、互換性が保証されることは期待しないでください。これらの宣言は必要に応じて変更される可能性があり、非互換な修正が加えられる場合があります。

## ライセンス

このライブラリは [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0) に基づいて配布しています。  
本コードは LLVM による実装をもとに改変したものであり、オリジナルのライセンスに関しては  
[https://llvm.org/LICENSE.txt](https://llvm.org/LICENSE.txt) をご参照ください。

---

不具合報告や機能追加の要望は、Issue または Pull Request をお寄せください。  
ご利用いただきありがとうございます！

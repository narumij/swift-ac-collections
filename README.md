# swift-ac-collections

`swift-ac-collections` は、[AtCoder][atcoder]での利用を想定したデータ構造等のオープソース・パッケージです。

[![Swift](https://github.com/narumij/swift-ac-collections/actions/workflows/swift.yml/badge.svg?branch=main)](https://github.com/narumij/swift-ac-collections/actions/workflows/swift.yml)  
[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

## 利用方法

### Swift Package Manager での利用

`Package.swift` の `dependencies` に以下を追加してください:

```Swift
dependencies: [
  .package(url: "https://github.com/narumij/swift-ac-collections", from: "0.0.1"),
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

本モジュールでは平衡二分探索木の一種、赤黒木（Red-Black Tree）を用いたコンテナを提供しています。
具体的には以下で、それぞれ、C++のstd::set, std::multiset, std::map, std::multimapに相当します。

#### 1. RedBlackTreeSet

- **重複なし** の要素を管理する Set。  
- 要素の挿入・削除・探索を平均的に `O(log n)` で行えます。  
- `Collection` に適合しており、インデックスによる要素アクセスや `startIndex` / `endIndex` などが利用可能です。  
- 境界探索メソッド（`lowerBound` / `upperBound`）なども提供しています。  
- 使用例: [AtCoder 提出例 (ABC370D)](https://atcoder.jp/contests/abc370/submissions/62143443) / [AtCoder 提出例 (ABC385D)](https://atcoder.jp/contests/abc385/submissions/61848462) など。

#### 2. RedBlackTreeMultiSet

- **重複あり** の要素を管理する MultiSet。  
- `count(_:)` により、特定の要素が何個含まれるかを取得できます。  
- その他の特性や使い方は `RedBlackTreeSet` に準じます。  
- 使用例: [AtCoder 提出例 (ABC358D)](https://atcoder.jp/contests/abc358/submissions/62143179) など。

#### 3. RedBlackTreeDictionary

- **キーと値** を管理する Dictionary。  
- 基本的なキー検索・挿入・削除などの操作を `O(log n)` で行えます。  
- 連想配列リテラル（`ExpressibleByDictionaryLiteral`）にも対応しています。

#### 4. RedBlackTreeMultiMap
- **重複ありのキーと値** の要素を管理する Map。  
- `count(forKey:)` により、特定キーの要素が何個含まれるかを取得できます。  
- MultiSetやDictionaryをベースに、なるべくSwiftに寄せたAPIとなっています。

#### 簡単な使用例

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

#### IndexとRawIndex

赤黒木モジュールの各データ構造は木のノードを配列に格納しています。
この内部配列のインデックス同士を比較した場合、順序と結果が一致しません。

Swift標準のプロトコルではインデックス比較と順序の一致を要求するため、抽象化されたインデックスを用いています。
これが`Index`です。実際的にはノードへのポインタやC++のイテレータのような働きをします。
赤黒木モジュールの大半のAPIではこの抽象化された`Index`を用いています。

他に`RawIndex`があります、`RawIndex`同士の比較はできませんが軽量で、要素アクセスや要素削除に利用できます。
一部のAPIは`RawIndex`を用いています。

どちらも単なるIntによるIndexとは異なることと、RawIndexは限られた目的にしか使えないことに注意してください。

- indicesプロパティはIndexのシーケンスを返します。
- rawIndicesプロパティはRawIndexのシーケンスを返します。

#### 削除時のIndex無効化と安全な範囲削除

削除操作を行うことで、対象のノードは内容がクリアされ、再利用管理リンクリストの一部となります。

削除されたノードを指すインデックスは単純に無効となります。

範囲削除を行う際は、この挙動には十分に注意を払う必要があります。

- 削除されたノードへの参照を使い続けると、クラッシュします。

- 有効無効の確認が必要な場合、isValid(index:)を使ってください。

- endIndexは例外で、内部的インデックスが常に不変です。

各種サブシーケンスやイテレーターには削除対策が施されています。このため、これらはほぼ問題なく範囲削除に利用できます。

##### 範囲削除の例

0. 普通に削除する

この問題を迂回しない楽な使い方です。
紆余曲折のすえに、安定してできるようになりました。

IndexをStridableにした場合とても遅かったのですが
（1要素毎にO(log *n*)等）、
イテレータやシーケンスに別途用意したモノを利用することで速度を稼いでいます。

ようやく普通に動くようになりました。

`..<` 演算子は通常Rangeを生成しますが、型推論次第で別のシーケンスとなります。

普通に書いて普通に動かない場合があるという事態が解消しているので、残りの例は参考程度に眺めてください。

```Swift
var tree0: RedBlackTreeSet<Int> = [0,1,2,3,4,5]
for i in tree0.startIndex ..< tree0.endIndex {
  tree0.remove(at: i) // iはこの時点で無効になる
  print(tree0.isValid(index: i)) // false
}
print(tree0.count) // 0
```

```Swift
var tree0: RedBlackTreeSet<Int> = [0,1,2,3,4,5]
for i in tree0.indices {
  tree0.remove(at: i) // iはこの時点で無効になる
  print(tree0.isValid(index: i)) // false
}
print(tree0.count) // 0
```

```Swift
var tree0: RedBlackTreeSet<Int> = [0,1,2,3,4,5]
for i in (tree0.startIndex ..< tree0.endIndex).reversed() {
  tree0.remove(at: i) // iはこの時点で無効になる
  print(tree0.isValid(index: i)) // false
}
print(tree0.count) // 0
```

```Swift
var tree0: RedBlackTreeSet<Int> = [0,1,2,3,4,5]
for i in tree0.indices.reversed() {
  tree0.remove(at: i) // iはこの時点で無効になる
  print(tree0.isValid(index: i)) // false
}
print(tree0.count) // 0
```

1. whileループで削除する

この問題を迂回する、標準APIによるベーシックな方法です。

```Swift
var tree1: RedBlackTreeSet<Int> = [0,1,2,3,4,5]
var i = tree1.startIndex
while i != tree1.endIndex { // endIndexは不変
  let j = i
  i = tree1.index(after: i)
  tree1.remove(at: j) // jはこの時点で無効になる
  print(tree1.isValid(index: j)) // false
}
print(tree1.count) // 0
```

~~2. enumerated()で削除する~~

~~値とノードインデックスを列挙して、削除操作を行うことができます。
削除時のインデックス無効対策がイテレータに施してあるので、以下のように書いて問題ありません。~~

enumerated()の型が原義に沿っていないことから、誤用の懸念があり、廃止します。
`___enumerated`()と別の名前で残していますが、名前から推察できるとおり、半非公開扱いとします。

```Swift
var tree2: RedBlackTreeSet<Int> = [0,1,2,3,4,5]
for (i,_) in tree2[tree2.startIndex ..< tree2.endIndex].___enumerated() { i, _ in
  tree2.remove(at: i) // この時点でiは無効だが、イテレータは内部で次のインデックスを保持している
  print(tree2.isValid(index: i)) // false
  // iはRedBlackTreeSet<Int>.RawIndex型
}
print(tree2.count) // 0
```

3. `rawIndices`で削除する

RawIndexは赤黒木ノードへの軽量なポインタとなっていて、rawIndicesはRawIndexのシーケンスを返します。
削除時のインデックス無効対策がイテレータに施してあり、削除操作に利用することができます。

```Swift
var tree3: RedBlackTreeSet<Int> = [0,1,2,3,4,5]
for (i,_) in tree3[tree3.startIndex ..< tree3.endIndex].rawIndices { i in
  tree3.remove(at: i) // この時点でiは無効だが、イテレータは内部で次のインデックスを保持している
  print(tree3.isValid(index: i)) // false
  // iはRedBlackTreeSet<Int>.RawIndex型
}
print(tree3.count) // 0
```

4. removeSubrange(_:Range<Index>)で削除する

インデックスの区間で削除対象を指定することが可能です。

```Swift
var tree4: RedBlackTreeSet<Int> = [0,1,2,3,4,5]
tree4.removeSubrange(tree4.startIndex ..< tree3.endIndex)
XCTAssertEqual(tree4.count, 0)
```

5. remove(contentsOf:Range<Element>)を使用して削除する。

値の区間で削除対象を指定することが可能です。


```Swift
var tree5: RedBlackTreeSet<Int> = [0, 1, 2, 3, 4, 5]
tree5.remove(contentsOf: 0 ..< 6)
// 0〜5が削除され、結果は空

```

6. erase()を自作して削除する

C++のsetと同じような削除コードを書くことも可能です。

```Swift
extension RedBlackTreeSet {
  mutating func erase(at position: Index) -> Index {
    defer { remove(at: position) }
    return index(after: position)
  }
}

var tree6: RedBlackTreeSet<Int> = [0, 1, 2, 3, 4, 5]
var idx = tree6.startIndex
while idx != tree6.endIndex {
  idx = tree6.erase(at: idx)
}
```

比較演算子の計算量がそこそこあるためおすすめできませんが、
C++のイテレータとは異なり比較でループを回すこともできます。 

```Swift
var tree6: RedBlackTreeSet<Int> = [0, 1, 2, 3, 4, 5]
var idx = tree6.startIndex
while idx < tree6.endIndex {
  idx = tree6.erase(at: idx)
}
```

#### MultiSetのremove(:)

RedBlackTreeMultiSetのremove(:)は、enumerated()やforEach(:)の削除時対策が効かないため、通常のコピーオンライトとくらべて、さらにコピーが発生しやすい挙動としています。

このため、この操作をさらにループして使う場合には、注意が必要となります。安直に行うとループ毎に全体のコピーが発生するためです。

これを避けるには、削除時に有効なイテレータやサブシーケンスが消費済みの状態にする必要があります。

具体的には、削除に必要な情報は一度map関数で配列にする等です。

```Swift
var multiset: RedBlackTreeMultiSet<Int> = [0,0,1,1,2,2]
for member in multiset {
  // この時点でイテレータが有効で、イテレータの破壊を予防するために内部コピーを行う
  // この場合、1回内部コピーが行われる
  multiset.remove(member)
}
```

```Swift
var multiset: RedBlackTreeMultiSet<Int> = [0,0,1,1,2,2]
for member in multiset.map({ $0 }) {
  // イテレータが消費済みなため、コピーが発生しない
  multiset.remove(member)
}
```

#### MultiMap

赤黒木モジュールの標準コンテナとの比較やSTLとの比較で漏れを潰していて未実装に気付いたため用意しました。
このコンテナを対象とする問題を知らないため、AC実績もなく、APIやチューニングが甘い状態ですが、ここまでの他のコンテナをベースとしてるため、そこそこの性能には仕上がっています。
辞書がマルチセットに退化したようなAPIとなっており、キーアクセスでの返却がサブシーケンスなこととあわせて、辞書と思うと絶望的に使いにくいものとなっています。
lowerBound, upperBound, equalRange, indices, enumeratedを駆使する必要がありそうです。

### PermutationModule

#### 使い方

```Swift
import AcCollections

for p in [1,2].nextPermutations() {
  print(p.map{$0})
  // [1,2]
  // [2,1]
}
```

#### 説明

これの何が嬉しいかというと、辞書順での残りを列挙します。終了条件はソート済みと変わらない並びとなることで、その直前までが出力されます。

ABC328Eという問題がありまして、C++で書かれた解説コードを読んだとき、C++はこの問題を力尽くで計算できると1年ぐらい勘違いしていました。そうではなく、辞書順の変化だけを行うnext_permutationsの挙動が理由で、組み合わせ数が減っていたために計算可能だったようです。

28!を2秒で用意できるかどうかはライブラリの問題では無く、そもそも論でした。

勘違いの結果、オーバーヘッドが少ない実装を追い求め、結果としてとても軽量な実装を生み出すこととなりました。おまけでunsafePermutationsというものもありますが、どちらもコピーオンライトをキャンセルして行わない動作となっています。

## アンダースコア付き宣言について

「アンダースコア付き宣言」は、完全修飾名のどこかにアンダースコア (`_`) で始まる部分が含まれる宣言のことを指します。たとえば、以下のような名前は技術的に `public` として宣言されていても、パブリックAPIには含まれません：

- `FooModule.Bar._someMember(value:)`（アンダースコア付きのメンバー）
- `FooModule._Bar.someMember`（アンダースコア付きの型）
- `_FooModule.Bar`（アンダースコア付きのモジュール）
- `FooModule.Bar.init(_value:)`（アンダースコア付きの引数を持つイニシャライザ）

また、`Sources`以外の、の各サブディレクトリに含まれる内容もパブリックAPIではありません。
これらは自由に引用し、自前のライブラリとしてメンテナンスするための「盆栽」としてお使いください。
将来のリリースで内容が変更されたり、削除される可能性があるため、必要な部分をコピーして独自に管理することを推奨します。

さらに、コードベース全般についても同様に、互換性が保証されることは期待しないでください。これらの宣言は必要に応じて変更される可能性があり、非互換な修正が加えられる場合があります。

## ライセンス

このライブラリは [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0) に基づいて配布しています。  

RedBlackTreeModuleは LLVM による実装をもとに改変したものであり、オリジナルのライセンスに関しては  
[https://llvm.org/LICENSE.txt](https://llvm.org/LICENSE.txt) をご参照ください。

PermutationModuleは swift-algorithms による実装をもとに改変したものであり、オリジナルのライセンスに関しては  
[https://github.com/apple/swift-algorithms/blob/main/LICENSE.txt](https://github.com/apple/swift-algorithms/blob/main/LICENSE.txt) をご参照ください。

---

不具合報告や機能追加の要望は、Issue または Pull Request をお寄せください。  
ご利用いただきありがとうございます！

[atcoder]: https://atcoder.jp/

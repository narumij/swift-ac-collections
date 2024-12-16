// Copyright 2024 narumij
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// This code is based on work originally distributed under the Apache License 2.0 with LLVM Exceptions:
//
// Copyright © 2003-2024 The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.

import Collections
import Foundation

// AC https://atcoder.jp/contests/abc358/submissions/59018223

/// 重複を許容する要素を格納する順序付きコレクションである赤黒木マルチセット。
///
/// `RedBlackTreeMultiSet` は、赤黒木（Red-Black Tree）を基盤としたマルチセットのデータ構造で、効率的な要素の挿入、削除、探索をサポートします。
/// マルチセットは、同じ要素を複数回格納する必要がある場合や、順序付きのデータを扱う場合に有用です。
///
/// ## 主な特徴
/// - 要素は昇順に自動的にソートされます。
/// - 同じ値の要素を複数回格納することができます。
/// - 任意の比較可能な型（`Comparable` に準拠した型）を要素として使用可能です。
/// - `BidirectionalCollection` に適合しており、双方向に要素を走査できます。
///
/// ## 実装済みの機能
/// - **境界探索**:
///   - `lowerBound(_:)` メソッドで、指定した値以上の最小要素を効率的に見つけられます。
///   - `upperBound(_:)` メソッドで、指定した値より大きい最小要素を効率的に見つけられます。
/// - **イテレーション**:
///   - 順序に従った要素の走査が可能です。
///
/// ## 使用例
/// 以下の例は、`RedBlackTreeMultiSet` を使用して重複要素を扱う方法を示します:
///
/// ```swift
/// var multiset: RedBlackTreeMultiSet<Int> = [1, 2, 2, 3, 3, 3]
///
/// // 要素の挿入
/// multiset.insert(2)
/// print(multiset) // 出力: [1, 2, 2, 2, 3, 3, 3]
///
/// // lowerBoundとupperBoundの使用
/// if let lower = multiset.lowerBound(2) {
///     print("Lower bound for 2: \(multiset[lower])") // 出力: 2
/// }
/// if let upper = multiset.upperBound(2) {
///     print("Upper bound for 2: \(multiset[upper])") // 出力: 3
/// }
/// ```
///
/// ## 制約
/// - 要素型は `Comparable` プロトコルに準拠している必要があります。
///
/// ## 計算量
/// - 要素の挿入、削除、探索: O(log *n*)
/// - 境界探索 (`lowerBound`, `upperBound`): O(log *n*)
///
/// `RedBlackTreeMultiSet` は、重複した値を扱う必要がある競技プログラミングや、順序付けられたデータを効率的に操作する必要があるアプリケーションで有用です。
@frozen
public struct RedBlackTreeMultiset<Element: Comparable> {

  public
    typealias Element = Element

  public
    typealias Index = RedBlackTree.Index

  @usableFromInline
  typealias _Key = Element

  @usableFromInline
  var header: RedBlackTree.___Header
  @usableFromInline
  var nodes: [RedBlackTree.___Node]
  @usableFromInline
  var values: [Element]
  @usableFromInline
  var stock: Heap<_NodePtr>
}

extension RedBlackTreeMultiset {

  /// 空の赤黒木マルチセットを作成します。
  ///
  /// このイニシャライザは、新しい空の `RedBlackTreeMultiSet` インスタンスを作成します。
  /// 作成直後のマルチセットは要素を持たず、操作に応じて動的に要素が追加されます。
  ///
  /// 以下は、空のマルチセットを作成し要素を追加する例です:
  ///
  /// ```swift
  /// var multiset = RedBlackTreeMultiSet<Int>()
  /// multiset.insert(3)
  /// multiset.insert(3)
  /// print(multiset) // 出力: [3, 3]
  /// ```
  @inlinable @inline(__always)
  public init() {
    header = .zero
    nodes = []
    values = []
    stock = []
  }

  /// 指定された容量を持つ空の赤黒木マルチセットを作成します。
  ///
  /// このイニシャライザは、要素の格納に必要な初期容量を指定して空の `RedBlackTreeMultiSet` を作成します。
  /// あらかじめ容量を確保することで、要素の追加時における動的なメモリ割り当ての回数を削減できます。
  ///
  /// 以下は、初期容量を指定してマルチセットを作成する例です:
  ///
  /// ```swift
  /// var multiset = RedBlackTreeMultiSet<Int>(minimumCapacity: 10)
  /// multiset.insert(1)
  /// multiset.insert(2)
  /// print(multiset) // 出力: [1, 2]
  /// ```
  ///
  /// - Parameter minimumCapacity: 初期確保する要素の容量。
  @inlinable
  public init(minimumCapacity: Int) {
    header = .zero
    nodes = []
    values = []
    stock = []
    nodes.reserveCapacity(minimumCapacity)
    values.reserveCapacity(minimumCapacity)
  }
}

extension RedBlackTreeMultiset {

  /// 指定されたシーケンスの要素を持つ赤黒木マルチセットを作成します。
  ///
  /// このイニシャライザは、指定されたシーケンス内の全ての要素を格納する新しい `RedBlackTreeMultiSet` を作成します。
  /// シーケンスに重複要素が含まれる場合、それらもそのまま格納されます。
  ///
  /// 以下は、シーケンスを基にしたマルチセットの作成例です:
  ///
  /// ```swift
  /// let numbers = [1, 2, 2, 3, 3, 3]
  /// let multiset = RedBlackTreeMultiSet(numbers)
  /// print(multiset) // 出力: [1, 2, 2, 3, 3, 3]
  /// ```
  ///
  /// - Parameter sequence: 新しいマルチセットに含める要素を持つシーケンス。
  ///   シーケンス内の要素は順序に従って格納されます。
  ///
  /// - Complexity: O(*n* log *n*), ここで *n* はシーケンスの要素数。
  @inlinable
  public init<Source>(_ sequence: Source)
  where Element == Source.Element, Source: Sequence {
    // 全数使うため、一度確保すると、そのまま
    var _values: [Element] = sequence + []
    var _header: RedBlackTree.___Header = .zero
    self.nodes = [RedBlackTree.___Node](
      unsafeUninitializedCapacity: _values.count
    ) { _nodes, initializedCount in
      withUnsafeMutablePointer(to: &_header) { _header in
        var count = 0
        _values.withUnsafeMutableBufferPointer { _values in
          func ___construct_node(_ __k: Element) -> _NodePtr {
            _nodes[count] = .zero
            defer { count += 1 }
            return count
          }
          let tree = _UnsafeMutatingHandle<Self>(
            __header_ptr: _header,
            __node_ptr: _nodes.baseAddress!,
            __value_ptr: _values.baseAddress!)
          var i = 0
          while i < _values.count {
            let __k = _values[i]
            i += 1
            let __h = ___construct_node(__k)
            var __parent = _NodePtr.nullptr
            let __child = tree.__find_leaf_high(&__parent, __k)
            tree.__insert_node_at(__parent, __child, __h)
          }
          initializedCount = count
        }
      }
    }
    self.header = _header
    self.values = _values
    self.stock = []
  }
}

#if true
  // naive
  extension RedBlackTreeMultiset {
    @inlinable @inline(__always)
    public init<S>(_ _a: S) where S: Collection, S.Element == Element {
      self.nodes = []
      self.header = .zero
      self.values = []
      self.stock = []
      for a in _a {
        _ = insert(a)
      }
    }
  }
#endif

extension RedBlackTreeMultiset {

  /// 赤黒木セットが空であるかどうかを示すブール値。
  @inlinable
  public var isEmpty: Bool {
    ___isEmpty
  }

  /// 赤黒木セットに含まれる要素の数。
  ///
  /// - 計算量: O(1)
  @inlinable
  public var count: Int {
    ___count
  }

  /// 新しい領域を割り当てることなく、赤黒木セットが格納できる要素の総数。
  @inlinable
  public var capacity: Int {
    ___capacity
  }
}

extension RedBlackTreeMultiset {

  /// 指定された要素数を格納するのに十分な領域を確保します。
  ///
  /// 挿入する要素数が事前にわかっている場合、このメソッドを使用すると、
  /// 複数回の領域再割り当てを避けることができます。このメソッドは、
  /// 赤黒木セットが一意で変更可能な連続した領域を持つようにし、
  /// 少なくとも指定された要素数を格納できる領域を確保します。
  ///
  /// 既存のストレージに `minimumCapacity` 個の要素を格納できる余地があったとしても、
  /// `reserveCapacity(_:)` メソッドを呼び出すと、連続した新しい領域へのコピーが発生します。
  ///
  /// - Parameter minimumCapacity: 確保したい要素数。
  @inlinable
  public mutating func reserveCapacity(_ minimumCapacity: Int) {
    nodes.reserveCapacity(minimumCapacity)
    values.reserveCapacity(minimumCapacity)
  }
}

extension RedBlackTreeMultiset: ValueComparer {

  @inlinable @inline(__always)
  static func __key(_ e: Element) -> Element { e }

  @inlinable
  static func value_comp(_ a: Element, _ b: Element) -> Bool {
    a < b
  }
}

extension RedBlackTreeMultiset: RedBlackTreeSetContainer {}

extension RedBlackTreeMultiset: _UnsafeHandleBase {}

extension RedBlackTreeMultiset: _UnsafeMutatingHandleBase {

  // プロトコルでupdateが書けなかったため、個別で実装している
  @inlinable
  @inline(__always)
  mutating func _update<R>(_ body: (_UnsafeMutatingHandle<Self>) throws -> R) rethrows -> R {
    return try withUnsafeMutablePointer(to: &header) { header in
      try nodes.withUnsafeMutableBufferPointer { nodes in
        try values.withUnsafeMutableBufferPointer { values in
          try body(
            _UnsafeMutatingHandle<Self>(
              __header_ptr: header,
              __node_ptr: nodes.baseAddress!,
              __value_ptr: values.baseAddress!))
        }
      }
    }
  }
}

extension RedBlackTreeMultiset: InsertMultiProtocol {}
extension RedBlackTreeMultiset: EraseMultiProtocol {}
extension RedBlackTreeMultiset: RedBlackTree.SetInternal {}
extension RedBlackTreeMultiset: RedBlackTreeEraseProtocol {}

extension RedBlackTreeMultiset {

  /// 指定された要素を赤黒木マルチセットに挿入します。
  ///
  /// このメソッドは、指定された要素 `newMember` をマルチセットに挿入します。
  /// マルチセットは重複を許容するため、同じ値の要素が既に存在していても新たに挿入されます。
  ///
  /// 以下は、要素を挿入する例です:
  ///
  /// ```swift
  /// var multiset: RedBlackTreeMultiSet = [1, 2, 3]
  ///
  /// let result = multiset.insert(2)
  /// print(result) // 出力: (inserted: true, memberAfterInsert: 2)
  /// print(multiset) // 出力: [1, 2, 2, 3]
  /// ```
  ///
  /// - Parameter newMember: マルチセットに挿入する要素。
  /// - Returns: タプル `(inserted: Bool, memberAfterInsert: Element)` を返します。
  ///   - `inserted`: 要素が正常に挿入された場合は `true`、そうでない場合は `false`。
  ///   - `memberAfterInsert`: 挿入後の要素（マルチセット内に既に存在していた場合も含む）。
  ///
  /// - Complexity: O(log *n*), ここで *n* はマルチセット内の要素数。
  ///
  /// - Note: `@discardableResult` を使用しているため、戻り値を使用しない場合でも警告は発生しません。
  @inlinable
  @discardableResult
  public mutating func insert(_ newMember: Element) -> (
    inserted: Bool, memberAfterInsert: Element
  ) {
    _ = __insert_multi(newMember)
    return (true, newMember)
  }

  /// 指定された要素を赤黒木マルチセットから削除します。
  ///
  /// このメソッドは、指定された要素 `member` をマルチセットから1つ削除します。
  /// 同じ値の要素が複数存在する場合、その中の1つだけが削除されます。
  /// 該当する要素が存在しない場合、このメソッドは `nil` を返します。
  ///
  /// 以下は、`remove(_:)` メソッドを使用した例です:
  ///
  /// ```swift
  /// var multiset: RedBlackTreeMultiSet = [1, 2, 2, 3, 3, 3]
  ///
  /// if let removed = multiset.remove(2) {
  ///     print("Removed \(removed)") // 出力: "Removed 2"
  /// } else {
  ///     print("Element not found.")
  /// }
  /// print(multiset) // 出力: [1, 2, 3, 3, 3]
  /// ```
  ///
  /// - Parameter member: 削除対象の要素。
  /// - Returns: 削除された要素を返します。
  ///   マルチセットに指定された要素が存在しない場合は `nil` を返します。
  ///
  /// - Complexity: O(log *n*), ここで *n* はマルチセット内の要素数。
  @inlinable
  @discardableResult
  public mutating func remove(_ member: Element) -> Element? {
    __erase_multi(member) != 0 ? member : nil
  }

  /// 指定されたインデックス位置にある要素を赤黒木セットから削除します。
  ///
  /// - Parameter index: 削除する要素のインデックス。
  ///   `index` はセット内の有効なインデックスであり、セットの終端インデックス（`endIndex`）と等しくない必要があります。
  /// - Returns: セットから削除された要素。
  @inlinable
  @discardableResult
  public mutating func remove(at index: Index) -> Element {
    guard let element = __remove(at: index.pointer) else {
      fatalError("Attempting to access RedBlackTreeSet elements using an invalid index")
    }
    return element
  }

  /// 赤黒木セットからすべての要素を削除します。
  ///
  /// - Parameter keepingCapacity: `true` を指定すると、セットのバッファ容量が保持されます。
  ///   `false` を指定すると、内部バッファが解放されます（デフォルトは `false`）。
  @inlinable
  public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
    __removeAll(keepingCapacity: keepCapacity)
  }
}

extension RedBlackTreeMultiset {

  /// 指定された要素が赤黒木マルチセット内に存在するかを示すブール値を返します。
  ///
  /// このメソッドは、指定された要素 `member` がマルチセット内に少なくとも1つ存在するかを判定します。
  ///
  /// 以下は、`contains(_:)` メソッドを使用した例です:
  ///
  /// ```swift
  /// let multiset: RedBlackTreeMultiSet = [1, 2, 2, 3, 3, 3]
  ///
  /// print(multiset.contains(2)) // 出力: true
  /// print(multiset.contains(4)) // 出力: false
  /// ```
  ///
  /// - Parameter member: 検索対象の要素。
  /// - Returns: `member` がマルチセット内に存在する場合は `true`、存在しない場合は `false`。
  ///
  /// - Complexity: O(log *n*), ここで *n* はマルチセット内の要素数。
  @inlinable public func contains(_ member: Element) -> Bool {
    ___contains(member)
  }

  @inlinable public func min() -> Element? {
    ___min()
  }

  @inlinable public func max() -> Element? {
    ___max()
  }
}

extension RedBlackTreeMultiset: ExpressibleByArrayLiteral {
  
  /// 配列リテラルから赤黒木マルチセットを作成します。
  ///
  /// このイニシャライザは、配列リテラル内の全ての要素を格納する新しい `RedBlackTreeMultiSet` を作成します。
  /// 配列リテラルに重複要素が含まれる場合、それらもそのまま格納されます。
  ///
  /// 配列リテラルを使用して赤黒木マルチセットを作成するには、要素をカンマで区切って角括弧で囲んでください:
  ///
  /// ```swift
  /// let multiset: RedBlackTreeMultiSet = [1, 2, 2, 3, 3, 3]
  /// print(multiset) // 出力: [1, 2, 2, 3, 3, 3]
  /// ```
  ///
  /// このイニシャライザは、`ExpressibleByArrayLiteral` プロトコルに準拠しているため、配列リテラルを使用して簡単にマルチセットを初期化できます。
  ///
  /// - Parameter elements: 新しいマルチセットに含める要素のリスト。
  ///
  /// - Complexity: O(*n* log *n*), ここで *n* は配列リテラル内の要素数。
  @inlinable public init(arrayLiteral elements: Element...) {
    self.init(elements)
  }
}

extension RedBlackTreeMultiset {

  /// 指定された値以上の最小の要素を指すインデックスを返します。
  ///
  /// このメソッドは、`RedBlackTreeMultiSet` 内で指定された値 `member` と等しい、またはそれより大きい最小の要素を効率的に見つけます。
  /// 見つかった要素を指すインデックスを返します。該当する要素が存在しない場合は、`endIndex` を返します。
  ///
  /// 以下は、`lowerBound(_:)` メソッドを使用した例です:
  ///
  /// ```swift
  /// let multiset: RedBlackTreeMultiSet = [1, 2, 2, 3, 3, 3]
  ///
  /// let index = multiset.lowerBound(2)
  /// if index != multiset.endIndex {
  ///     print("Lower bound for 2 is \(multiset[index])") // 出力: 2
  /// } else {
  ///     print("No elements are greater than or equal to 2.")
  /// }
  /// ```
  ///
  /// - Parameter member: 検索対象の値。
  /// - Returns: `member` と等しい、またはそれより大きい最小の要素を指すインデックス。該当する要素が存在しない場合は `endIndex`。
  ///
  /// - Complexity: O(log *n*), ここで *n* はマルチセット内の要素数。
  @inlinable public func lowerBound(_ member: Element) -> Index {
    Index(___lower_bound(member))
  }

  /// 指定された値より大きい最小の要素を指すインデックスを返します。
  ///
  /// このメソッドは、`RedBlackTreeMultiSet` 内で指定された値 `member` より大きい最小の要素を効率的に見つけます。
  /// 見つかった要素を指すインデックスを返します。該当する要素が存在しない場合は、`endIndex` を返します。
  ///
  /// 以下は、`upperBound(_:)` メソッドを使用した例です:
  ///
  /// ```swift
  /// let multiset: RedBlackTreeMultiSet = [1, 2, 2, 3, 3, 3]
  ///
  /// let index = multiset.upperBound(2)
  /// if index != multiset.endIndex {
  ///     print("Upper bound for 2 is \(multiset[index])") // 出力: 3
  /// } else {
  ///     print("No elements are greater than 2.")
  /// }
  /// ```
  ///
  /// - Parameter member: 検索対象の値。
  /// - Returns: `member` より大きい最小の要素を指すインデックス。該当する要素が存在しない場合は `endIndex`。
  ///
  /// - Complexity: O(log *n*), ここで *n* はマルチセット内の要素数。
  @inlinable public func upperBound(_ member: Element) -> Index {
    Index(___upper_bound(member))
  }
}

extension RedBlackTreeMultiset {

  @inlinable public func lessThan(_ p: Element) -> Element? {
    ___lt(p)
  }
  @inlinable public func greatorThan(_ p: Element) -> Element? {
    ___gt(p)
  }
  @inlinable public func lessEqual(_ p: Element) -> Element? {
    ___le(p)
  }
  @inlinable public func greatorEqual(_ p: Element) -> Element? {
    ___ge(p)
  }
}

extension RedBlackTreeMultiset: BidirectionalCollection {

  @inlinable public subscript(position: RedBlackTree.Index) -> Element {
    values[position.pointer]
  }

  @inlinable public func index(before i: Index) -> Index {
    Index(_read { $0.__tree_prev_iter(i.pointer) })
  }

  @inlinable public func index(after i: Index) -> Index {
    Index(_read { $0.__tree_next_iter(i.pointer) })
  }

  @inlinable public var startIndex: Index {
    Index(___begin())
  }

  @inlinable public var endIndex: Index {
    Index(___end())
  }
}

/// Overwrite Default implementation for bidirectional collections.
extension RedBlackTreeMultiset {

  /// Replaces the given index with its predecessor.
  ///
  /// - Parameter i: A valid index of the collection. `i` must be greater than
  ///   `startIndex`.
  @inlinable public func formIndex(before i: inout Index) {
    i = Index(_read { $0.__tree_prev_iter(i.pointer) })
  }

  @inlinable public func index(_ i: Index, offsetBy distance: Int) -> Index {
    _read {
      Index($0.pointer(i.pointer, offsetBy: distance, type: "RedBlackTreeMultiset"))
    }
  }

  @inlinable public func index(
    _ i: Index, offsetBy distance: Int, limitedBy limit: Index
  ) -> Index? {
    _read {
      Index(
        $0.pointer(
          i.pointer, offsetBy: distance, limitedBy: limit.pointer, type: "RedBlackTreeMultiset"))
    }
  }

  @inlinable func distance(__last: _NodePtr) -> Int {
    if __last == end() { return count }
    return _read { $0.distance(__first: $0.__begin_node, __last: __last) }
  }

  /// O(n)
  @inlinable public func distance(from start: Index, to end: Index) -> Int {
    distance(__last: end.pointer) - distance(__last: start.pointer)
  }
}

extension RedBlackTreeMultiset {

  /// 指定された要素が赤黒木マルチセット内に含まれる回数を返します。
  ///
  /// このメソッドは、指定された要素 `element` がマルチセット内に何回出現するかを計算します。
  /// 内部的には、`lowerBound` と `upperBound` を利用して要素の範囲を特定し、その範囲の要素数を計算します。
  ///
  /// 以下は、`count(_:)` メソッドを使用した例です:
  ///
  /// ```swift
  /// let multiset: RedBlackTreeMultiSet = [1, 2, 2, 3, 3, 3]
  ///
  /// print(multiset.count(2)) // 出力: 2
  /// print(multiset.count(3)) // 出力: 3
  /// print(multiset.count(4)) // 出力: 0
  /// ```
  ///
  /// - Parameter element: カウント対象の要素。
  /// - Returns: `element` がマルチセット内に含まれる回数。該当要素が存在しない場合は `0` を返します。
  ///
  /// - Complexity: O(log *n* + *k*), ここで *n* はマルチセット内の要素数、*k* は指定された要素の出現回数。
  ///   - `lowerBound` と `upperBound` の計算に O(log *n*)。
  ///   - 範囲内の要素数を計算するために O(*k*)。
  @inlinable public func count(_ element: Element) -> Int {
    _read {
      $0.distance(
        __first: $0.__lower_bound(element, $0.__root(), $0.__end_node()),
        __last: $0.__upper_bound(element, $0.__root(), $0.__end_node()))
    }
  }
}

extension RedBlackTreeMultiset: CustomStringConvertible, CustomDebugStringConvertible {
  /// 人間が読みやすい形式でセットの内容を文字列として表現します。
  public var description: String {
    "[\((map {"\($0)"} as [String]).joined(separator: ", "))]"
  }

  /// デバッグ時にセットの詳細情報を含む文字列を返します。
  public var debugDescription: String {
    "RedBlackTreeMultiset(\(description))"
  }
}

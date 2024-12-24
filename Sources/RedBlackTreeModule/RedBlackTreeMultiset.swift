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
    typealias Index = ___RedBlackTree.Index

  @usableFromInline
  typealias _Key = Element

  @usableFromInline
  var ___header: ___RedBlackTree.___Header

  @usableFromInline
  var ___nodes: [___RedBlackTree.___Node]

  @usableFromInline
  var ___values: [Element]
  
  @usableFromInline
  var ___stock: Heap<_NodePtr>
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
    ___header = .zero
    ___nodes = []
    ___values = []
    ___stock = []
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
    ___header = .zero
    ___nodes = []
    ___values = []
    ___stock = []
    ___nodes.reserveCapacity(minimumCapacity)
    ___values.reserveCapacity(minimumCapacity)
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
  public init<Source>(_ sequence: __owned Source)
  where Element == Source.Element, Source: Sequence {
    (
      ___header,
      ___nodes,
      ___values,
      ___stock
    ) = Self.___initialize(
      _sequence: sequence,
      _to_elements: { $0.map { $0 } }
    ) { tree, __k, _, __construct_node in
      let __h = __construct_node(__k)
      var __parent = _NodePtr.nullptr
      let __child = tree.__find_leaf_high(&__parent, __k)
      tree.__insert_node_at(__parent, __child, __h)
    }
  }
}

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
    ___nodes.reserveCapacity(minimumCapacity)
    ___values.reserveCapacity(minimumCapacity)
  }
}

extension RedBlackTreeMultiset: ValueComparer {

  @inlinable @inline(__always)
  static func __key(_ e: Element) -> Element { e }

  @inlinable @inline(__always)
  static func value_comp(_ a: Element, _ b: Element) -> Bool {
    a < b
  }
}

extension RedBlackTreeMultiset: ___RedBlackTreeUpdateBase {

  // プロトコルでupdateが書けなかったため、個別で実装している
  @inlinable
  @inline(__always)
  mutating func _update<R>(_ body: (___UnsafeMutatingHandle<Self>) throws -> R) rethrows -> R {
    return try withUnsafeMutablePointer(to: &___header) { header in
      try ___nodes.withUnsafeMutableBufferPointer { nodes in
        try ___values.withUnsafeMutableBufferPointer { values in
          try body(
            ___UnsafeMutatingHandle<Self>(
              __header_ptr: header,
              __node_ptr: nodes.baseAddress!,
              __value_ptr: values.baseAddress!))
        }
      }
    }
  }
}

extension RedBlackTreeMultiset: InsertMultiProtocol {}
extension RedBlackTreeMultiset: ___RedBlackTreeRemove {}
extension RedBlackTreeMultiset: ___RedBlackTreeDirectReadImpl {}

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
    ___erase_multi(member) != 0 ? member : nil
  }

  /// 指定されたインデックス位置にある要素を赤黒木セットから削除します。
  ///
  /// - Parameter index: 削除する要素のインデックス。
  ///   `index` はセット内の有効なインデックスであり、セットの終端インデックス（`endIndex`）と等しくない必要があります。
  /// - Returns: セットから削除された要素。
  @inlinable
  @discardableResult
  public mutating func remove(at index: Index) -> Element {
    guard let element = ___remove(at: index.pointer) else {
      fatalError("Attempting to access RedBlackTreeMultiset elements using an invalid index")
    }
    return element
  }

  @inlinable
  @discardableResult
  public mutating func removeFirst() -> Element {
    guard !isEmpty else {
      preconditionFailure("Can't removeFirst from an empty RedBlackTreeMultiset")
    }
    return remove(at: startIndex)
  }

  @inlinable
  @discardableResult
  public mutating func removeLast() -> Element {
    guard !isEmpty else {
      preconditionFailure("Can't removeFirst from an empty RedBlackTreeMultiset")
    }
    return remove(at: index(before: endIndex))
  }

  @inlinable
  public mutating func removeSubrange(_ range: ___RedBlackTree.Range) {
    ___remove(from: range.lhs.pointer, to: range.rhs.pointer)
  }

  /// 赤黒木セットからすべての要素を削除します。
  ///
  /// - Parameter keepingCapacity: `true` を指定すると、セットのバッファ容量が保持されます。
  ///   `false` を指定すると、内部バッファが解放されます（デフォルトは `false`）。
  @inlinable
  public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
    ___removeAll(keepingCapacity: keepCapacity)
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

  /// 赤黒木セット内の最小要素を返します。
  ///
  /// このメソッドは、`RedBlackTreeSet` 内で順序的に最小の要素を返します。
  /// セットが空の場合は `nil` を返します。
  ///
  /// 以下は、`min()` メソッドを使用した例です:
  ///
  /// ```swift
  /// let set: RedBlackTreeSet = [3, 1, 4, 5, 9]
  /// if let minValue = set.min() {
  ///     print("Minimum value: \(minValue)") // 出力: "Minimum value: 1"
  /// } else {
  ///     print("The set is empty.")
  /// }
  /// ```
  ///
  /// - Returns: セット内の最小要素。セットが空の場合は `nil`。
  ///
  /// - Complexity: O(log *n*), ここで *n* はセット内の要素数。
  ///
  /// - Note: `RedBlackTreeSet` は要素を昇順で管理しているため、最小要素は割と効率的に取得できます。
  @inlinable public func min() -> Element? {
    ___min()
  }

  /// 赤黒木セット内の最大要素を返します。
  ///
  /// このメソッドは、`RedBlackTreeSet` 内で順序的に最大の要素を返します。
  /// セットが空の場合は `nil` を返します。
  ///
  /// 以下は、`max()` メソッドを使用した例です:
  ///
  /// ```swift
  /// let set: RedBlackTreeSet = [3, 1, 4, 5, 9]
  /// if let maxValue = set.max() {
  ///     print("Maximum value: \(maxValue)") // 出力: "Maximum value: 9"
  /// } else {
  ///     print("The set is empty.")
  /// }
  /// ```
  ///
  /// - Returns: セット内の最大要素。セットが空の場合は `nil`。
  ///
  /// - Complexity: O(log *n*), ここで *n* はセット内の要素数。
  ///
  /// - Note: `RedBlackTreeSet` は要素を昇順で管理しているため、最大要素は割と効率的に取得できます。
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
    ___index_lower_bound(member)
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
    ___index_upper_bound(member)
  }
}

extension RedBlackTreeMultiset {

  /// セット内の最小の要素を返します。
  ///
  /// - Returns: セット内の最小の要素。セットが空の場合は `nil`。
  ///
  /// - Complexity: O(1)。
  @inlinable
  public var first: Element? {
    isEmpty ? nil : self[startIndex]
  }

  /// セット内の最大の要素を返します。
  ///
  /// - Returns: セット内の最大の要素。セットが空の場合は `nil`。
  ///
  /// - Complexity: O(1)。
  @inlinable
  public var last: Element? {
    isEmpty ? nil : self[index(before: .end)]
  }

  @inlinable
  public func first(where predicate: (Element) throws -> Bool) rethrows -> Element? {
    try ___first(where: predicate)
  }

  /// 指定された要素のインデックスを返します。要素がセットに存在しない場合は `nil` を返します。
  ///
  /// このメソッドは、赤黒木セット内で指定された要素 `member` を検索し、存在する場合はその要素のインデックスを返します。
  /// 要素がセット内に存在しない場合は `nil` を返します。
  ///
  /// 以下は、`index(of:)` メソッドの使用例です:
  ///
  /// ```swift
  /// let set: RedBlackTreeSet = [1, 3, 5, 7]
  ///
  /// if let index = set.index(of: 5) {
  ///     print("Index of 5: \(index)")
  ///     print("Value at index: \(set[index])") // 出力: 5
  /// } else {
  ///     print("5 is not in the set.")
  /// }
  /// ```
  ///
  /// - Parameter member: セット内で検索する要素。
  /// - Returns: `member` のインデックスを返します。要素が存在しない場合は `nil`。
  ///
  /// - Complexity: O(log *n*), ここで *n* はセット内の要素数。
  @inlinable
  public func firstIndex(of member: Element) -> Index? {
    ___first_index(of: member)
  }

  /// 指定された述語を満たす最初の要素のインデックスを返します。
  ///
  /// このメソッドは、`RedBlackTreeSet` 内の要素を順序に従って走査し、指定された述語 `predicate` が `true` を返す最初の要素のインデックスを返します。
  /// 述語を満たす要素が存在しない場合は `nil` を返します。
  ///
  /// 以下は、`firstIndex(where:)` メソッドを使用した例です:
  ///
  /// ```swift
  /// let set: RedBlackTreeSet = [1, 3, 5, 7, 9]
  ///
  /// if let index = set.firstIndex(where: { $0 > 4 }) {
  ///     print("First index where element > 4: \(index)")
  ///     print("Value at index: \(set[index])") // 出力: 5
  /// } else {
  ///     print("No elements match the condition.")
  /// }
  /// ```
  ///
  /// - Parameter predicate: 各要素に対して評価する述語。`predicate` は `true` または `false` を返します。
  /// - Returns: `predicate` を満たす最初の要素のインデックス。条件に一致する要素がない場合は `nil`。
  ///
  /// - Complexity: O(*n*), ここで *n* はセット内の要素数。
  ///
  /// - Note: このメソッドは、セット内の要素を昇順に走査します。
  @inlinable
  public func firstIndex(where predicate: (Element) throws -> Bool) rethrows -> Index? {
    try ___first_index(where: predicate)
  }
}

extension RedBlackTreeMultiset {

  @inlinable
  func sorted() -> [Element] {
    ___element_sequence__
  }
}

extension RedBlackTreeMultiset: Collection {

  @inlinable public subscript(position: ___RedBlackTree.Index) -> Element {
    ___values[position.pointer]
  }

  @inlinable public func index(before i: Index) -> Index {
    ___index_prev(i, type: "RedBlackTreeMultiset")
  }

  @inlinable public func index(after i: Index) -> Index {
    ___index_next(i, type: "RedBlackTreeMultiset")
  }

  @inlinable public var startIndex: Index {
    ___index_begin()
  }

  @inlinable public var endIndex: Index {
    ___index_end()
  }
}

/// Overwrite Default implementation for bidirectional collections.
extension RedBlackTreeMultiset {

  @inlinable public func index(_ i: Index, offsetBy distance: Int) -> Index {
    ___index(i, offsetBy: distance, type: "RedBlackTreeMultiset")
  }

  @inlinable public func index(_ i: Index, offsetBy distance: Int, limitedBy limit: Index) -> Index?
  {
    ___index(i, offsetBy: distance, limitedBy: limit, type: "RedBlackTreeMultiset")
  }

  /// O(n)
  @inlinable public func distance(from start: Index, to end: Index) -> Int {
    ___distance(__last: end.pointer) - ___distance(__last: start.pointer)
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
    _read { tree in
      tree.distance(
        __first: tree.__lower_bound(element, tree.__root(), tree.__end_node()),
        __last: tree.__upper_bound(element, tree.__root(), tree.__end_node()))
    }
  }
}

extension RedBlackTreeMultiset: CustomStringConvertible, CustomDebugStringConvertible {
  /// 人間が読みやすい形式でセットの内容を文字列として表現します。
  @inlinable
  public var description: String {
    "[\((map {"\($0)"} as [String]).joined(separator: ", "))]"
  }

  /// デバッグ時にセットの詳細情報を含む文字列を返します。
  @inlinable
  public var debugDescription: String {
    "RedBlackTreeMultiset(\(description))"
  }
}

extension RedBlackTreeMultiset: Equatable {

  @inlinable
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.___equal_with(rhs)
  }
}

extension RedBlackTreeMultiset {

  public typealias IndexRange = ___RedBlackTree.Range
  public typealias SeqenceState = (current: _NodePtr, next: _NodePtr, to: _NodePtr)
  public typealias EnumeratedElement = (position: Index, element: Element)

  public typealias EnumeratedSequence = UnfoldSequence<EnumeratedElement, SeqenceState>
  public typealias ElementSequence = Array<Element>

  @inlinable
  public subscript(bounds: IndexRange) -> ElementSequence {
    ___element_sequence__(from: bounds.lhs, to: bounds.rhs)
  }

  @inlinable
  public func enumrated() -> EnumeratedSequence {
    ___enumerated_sequence
  }

  @inlinable
  public func enumrated(from: Index, to: Index) -> EnumeratedSequence {
    ___enumerated_sequence(from: from, to: to)
  }
}

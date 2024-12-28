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

import Foundation

// AC https://atcoder.jp/contests/abc370/submissions/57922896
// AC https://atcoder.jp/contests/abc385/submissions/61003801

/// `RedBlackTreeSet` は、`Element` 型の要素を一意に格納するための
/// 赤黒木（Red-Black Tree）ベースの集合型です。
///
/// 要素の挿入、削除、検索（`contains(_:)` など）が平均して **O(log *n*)**
/// （*n* は格納されている要素数）で実行されるように設計されており、
/// 高速かつ効率的にデータを扱うことが可能です。
///
/// 同じ要素を重複して挿入しようとした場合、既存の要素が返され、新たに挿入はされません。
///
/// ## トピックス
///
/// ### 生成方法
/// - ``init()``
/// - ``init(minimumCapacity:)``
/// - ``init<Source>(_:)``
/// - `ExpressibleByArrayLiteral` 対応
///
/// ### 要素操作
/// - ``insert(_:)``
/// - ``update(with:)``
/// - ``remove(_:)``
/// - ``remove(at:)``
/// - ``removeFirst()``
/// - ``removeLast()``
/// - ``removeSubrange(_:)``
/// - ``removeAll(keepingCapacity:)``
///
/// ### 集合の状態確認
/// - ``isEmpty``
/// - ``count``
/// - ``capacity``
/// - ``contains(_:)``
/// - ``min()``
/// - ``max()``
///
/// ### インデックス操作
/// - ``startIndex``
/// - ``endIndex``
/// - ``index(before:)``
/// - ``index(after:)``
/// - ``lowerBound(_:)``
/// - ``upperBound(_:)``
/// - ``firstIndex(of:)``
/// - ``firstIndex(where:)``
///
/// ### 各種変換
/// - ``map(_:)``
/// - ``filter(_:)``
/// - ``reduce(into:_:)``
/// - ``reduce(_:_:)``
/// - ``sorted()``
/// - ``enumerated()``
///
/// ### 使用例
/// ```swift
/// var treeSet: RedBlackTreeSet = [3, 1, 4, 1, 5, 9]
/// print(treeSet)              // "[1, 3, 4, 5, 9]"
///
/// treeSet.insert(2)
/// print(treeSet.contains(2))  // true
///
/// // 要素の削除
/// treeSet.remove(9)
/// print(treeSet)              // "[1, 2, 3, 4, 5]"
///
/// // イテレーション
/// for element in treeSet {
///     print(element)
/// }
/// ```
///
/// ## 適合しているプロトコル
///
/// - `Collection`
///   シーケンシャルに要素を列挙するためのメソッド・プロパティを提供します。
/// - `ExpressibleByArrayLiteral`
///   配列リテラル (`[...]`) から直接初期化するための機能を提供します。
/// - `Equatable`
///   `==` 演算子により、他の `RedBlackTreeSet` と要素を比較して等価判定ができます。
/// - `CustomStringConvertible`, `CustomDebugStringConvertible`
///   デバッグや文字列表現が必要な場面で、コレクションの内容を文字列として取得できます。
///
/// **Note**: この実装では、ノード管理に内部配列や付加的なメタデータを使用しています。
/// 将来的に内部実装が変わる可能性はありますが、計算量や基本メソッドのインターフェースは変わりません。
///
/// - Important: `RedBlackTreeSet` はスレッドセーフではありません。複数のスレッドから同時に
///   アクセスする場合は、適切なロックや同期を行う必要があります。
@frozen
public struct RedBlackTreeSet<Element: Comparable> {

  public
    typealias Element = Element

  /// `Index` は `RedBlackTreeSet` 内の要素を参照するための型です。
  ///
  /// `Collection` プロトコルに準拠するために用意されており、
  /// `startIndex` から `endIndex` の範囲でシーケンシャルに要素を走査できます。
  /// また、`index(before:)` や `index(after:)` などのメソッドを使用することで、
  /// インデックスを前後に移動できます。
  ///
  /// - Important: `Index` はコレクションの状態が変化（挿入・削除など）すると無効に
  ///   なる場合があります。無効なインデックスを使用するとランタイムエラーや
  ///   不正な参照が発生する可能性があるため注意してください。
  ///
  /// - SeeAlso: `startIndex`, `endIndex`, `index(before:)`, `index(after:)`
  public
    typealias Index = ___RedBlackTree.Index

  public
    typealias IndexRange = ___RedBlackTree.Range

  @usableFromInline
  typealias _Key = Element

  @usableFromInline
  var tree: Tree
}

extension RedBlackTreeSet: NewContainer {}
extension RedBlackTreeSet: ScalarValueComparer {}

extension RedBlackTreeSet {

  @inlinable @inline(__always)
  public init() {
    self.init(minimumCapacity: 0)
  }

  @inlinable @inline(__always)
  public init(minimumCapacity: Int) {
    tree = .create(withCapacity: minimumCapacity)
  }
}

extension RedBlackTreeSet {

  @inlinable
  public init<Source>(_ sequence: __owned Source)
  where Element == Source.Element, Source: Sequence {

    self.init()
    for __k in sequence {
      Tree.ensureCapacity(tree: &tree, minimumCapacity: tree.count + 1)
      var __parent = _NodePtr.nullptr
      let __child = tree.__find_equal(&__parent, __k)
      if tree.__ref_(__child) == .nullptr {
        let __h = tree.__construct_node(__k)
        tree.__insert_node_at(__parent, __child, __h)
      }
    }
  }
}

extension RedBlackTreeSet {

  /// - 計算量: O(1)
  @inlinable
  public var isEmpty: Bool {
    ___isEmpty
  }

  /// - 計算量: O(1)
  @inlinable
  public var count: Int {
    ___count
  }

  @inlinable
  public var capacity: Int {
    ___capacity
  }
}

extension RedBlackTreeSet {

  @inlinable
  public mutating func reserveCapacity(_ minimumCapacity: Int) {
    ensureUniqueAndCapacity(minimumCapacity: minimumCapacity)
  }
}

extension RedBlackTreeSet {

  @discardableResult
  @inlinable public mutating func insert(_ newMember: Element) -> (
    inserted: Bool, memberAfterInsert: Element
  ) {
    ensureUniqueAndCapacity()
    let (__r, __inserted) = tree.__insert_unique(newMember)
    return (__inserted, __inserted ? newMember : ___elements(tree.__ref_(__r)))
  }

  @discardableResult
  @inlinable public mutating func update(with newMember: Element) -> Element? {
    ensureUniqueAndCapacity()
    let (__r, __inserted) = tree.__insert_unique(newMember)
    guard !__inserted else { return nil }
    let __p = tree.__ref_(__r)
    let oldMember = ___elements(__p)
    tree[__p].__value_ = newMember
    return oldMember
  }

  @discardableResult
  @inlinable public mutating func remove(_ member: Element) -> Element? {
    tree.___erase_unique(member) ? member : nil
  }

  @inlinable
  @discardableResult
  public mutating func remove(at index: Index) -> Element {
    guard let element = ___remove(at: index.pointer) else {
      fatalError(.invalidIndex)
    }
    return element
  }

  /// - Complexity: O(log *n*), ここで *n* はセット内の要素数。
  @inlinable
  @discardableResult
  public mutating func removeFirst() -> Element {
    guard !isEmpty else {
      preconditionFailure(.emptyFirst)
    }
    return remove(at: startIndex)
  }

  @inlinable
  @discardableResult
  public mutating func removeLast() -> Element {
    guard !isEmpty else {
      preconditionFailure(.emptyLast)
    }
    return remove(at: index(before: endIndex))
  }

  /// 指定した半開区間（`lhs ..< rhs`）に含まれる要素をすべて削除します。
  ///
  /// - Parameter range: `lhs`（含む）から `rhs`（含まない）までを表す `___RedBlackTree.Range`
  ///   で、削除対象の要素範囲を示します。
  ///   範囲が逆転している場合（`lhs >= rhs`）や、木の要素範囲外を指している場合などの
  ///   “無効な” 状態では動作が未定義となります。
  ///
  /// ## 計算量
  /// - 削除する要素数を *k* とすると、単発的なノード削除が **O(log n)** 程度かかったとしても、
  ///   連続した削除操作では共通処理が再利用されるため、**償却計算量は O(k)** に近いパフォーマンス
  ///   が見込まれます。（実装によっては最大 **O(k log n)** となる可能性もあります）
  ///
  /// - Important: 削除後は、これまで使用していたインデックスが無効になる場合があります。
  ///   引き続き同じインデックスを利用する際は、事前に再取得してください。
  ///
  /// ### 使用例
  /// ```swift
  /// var treeSet = RedBlackTreeSet([0,1,2,3,4,5,6])
  /// let startIdx = treeSet.lowerBound(2)
  /// let endIdx   = treeSet.lowerBound(5)
  /// // [2, 3, 4] の範囲を削除したい
  /// treeSet.removeSubrange(.init(lhs: startIdx, rhs: endIdx))
  /// // 結果: treeSet = [0,1,5,6]
  /// ```
  @inlinable
  public mutating func removeSubrange(_ range: ___RedBlackTree.Range) {
    ___remove(from: range.lhs.pointer, to: range.rhs.pointer)
  }

  /// - Complexity: O(1)
  @inlinable
  public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
    ___removeAll(keepingCapacity: keepCapacity)
  }
}

extension RedBlackTreeSet {

  /// - Complexity: O(*n*), ここで *n* はセット内の要素数。
  @inlinable public func contains(_ member: Element) -> Bool {
    ___contains(member)
  }

  /// - Complexity: O(log *n*), ここで *n* はセット内の要素数。
  @inlinable public func min() -> Element? {
    // O(1)にできるが、オリジナルにならい、一旦このまま
    ___min()
  }

  /// - Complexity: O(log *n*), ここで *n* はセット内の要素数。
  @inlinable public func max() -> Element? {
    // O(1)にできるが、オリジナルにならい、一旦このまま
    ___max()
  }
}

extension RedBlackTreeSet: ExpressibleByArrayLiteral {

  @inlinable public init(arrayLiteral elements: Element...) {
    self.init(elements)
  }
}

extension RedBlackTreeSet {

  /// `lowerBound(_:)` は、指定した要素 `member` 以上の値が格納されている
  /// 最初の位置（`Index`）を返します。
  ///
  /// たとえば、ソートされた `[1, 3, 5, 7, 9]` があるとき、
  /// - `lowerBound(0)` は最初の要素 `1` の位置を返します。（つまり `startIndex`）
  /// - `lowerBound(3)` は要素 `3` の位置を返します。
  /// - `lowerBound(4)` は要素 `5` の位置を返します。（`4` 以上で最初に出現する値が `5`）
  /// - `lowerBound(10)` は `endIndex` を返します。
  ///
  /// - Parameter member: 二分探索で検索したい要素
  /// - Returns: 指定した要素 `member` 以上の値が格納されている先頭の `Index`
  /// - Complexity: 平均 O(log *n*)
  @inlinable public func lowerBound(_ member: Element) -> Index {
    ___index_lower_bound(member)
  }

  /// `upperBound(_:)` は、指定した要素 `member` より大きい値が格納されている
  /// 最初の位置（`Index`）を返します。
  ///
  /// たとえば、ソートされた `[1, 3, 5, 5, 7, 9]` があるとき、
  /// - `upperBound(3)` は要素 `5` の位置を返します。
  ///   （`3` より大きい値が最初に現れる場所）
  /// - `upperBound(5)` は要素 `7` の位置を返します。
  ///   （`5` と等しい要素は含まないため、`5` の直後）
  /// - `upperBound(9)` は `endIndex` を返します。
  ///
  /// - Parameter member: 二分探索で検索したい要素
  /// - Returns: 指定した要素 `member` より大きい値が格納されている先頭の `Index`
  /// - Complexity: 平均 O(log *n*)
  @inlinable public func upperBound(_ member: Element) -> Index {
    ___index_upper_bound(member)
  }
}

extension RedBlackTreeSet {

  /// - Complexity: O(1)。
  @inlinable
  public var first: Element? {
    isEmpty ? nil : self[startIndex]
  }

  /// - Complexity: O(1)。
  @inlinable
  public var last: Element? {
    isEmpty ? nil : self[index(before: .end)]
  }

  @inlinable
  public func first(where predicate: (Element) throws -> Bool) rethrows -> Element? {
    try ___first(where: predicate)
  }

  /// - Complexity: O(log *n*), ここで *n* はセット内の要素数。
  @inlinable
  public func firstIndex(of member: Element) -> Index? {
    ___first_index(of: member)
  }

  /// - Complexity: O(*n*), ここで *n* はセット内の要素数。
  @inlinable
  public func firstIndex(where predicate: (Element) throws -> Bool) rethrows -> Index? {
    try ___first_index(where: predicate)
  }
}

extension RedBlackTreeSet {

  /// - Complexity: O(*n*), ここで *n* はセット内の要素数。
  @inlinable
  func sorted() -> [Element] {
    ___element_sequence__
  }
}

extension RedBlackTreeSet: Collection {

  /// - Complexity: O(1)。
  @inlinable public subscript(position: ___RedBlackTree.Index) -> Element {
    ___elements(position.pointer)
  }

  /// - Complexity: 償却された O(1)。
  @inlinable public func index(before i: Index) -> Index {
    ___index_prev(i)
  }

  /// - Complexity: 償却された O(1)。
  @inlinable public func index(after i: Index) -> Index {
    ___index_next(i)
  }

  /// - Complexity: O(1)
  @inlinable public var startIndex: Index {
    ___index_begin()
  }

  /// - Complexity: O(1)
  @inlinable public var endIndex: Index {
    ___index_end()
  }
}

extension RedBlackTreeSet {

  @inlinable public func index(_ i: Index, offsetBy distance: Int) -> Index {
    ___index(i, offsetBy: distance, type: "RedBlackTreeSet")
  }

  @inlinable public func index(_ i: Index, offsetBy distance: Int, limitedBy limit: Index) -> Index?
  {
    ___index(i, offsetBy: distance, limitedBy: limit, type: "RedBlackTreeSet")
  }

  /// 償却された O(*n*)
  @inlinable
  public func distance(from start: Index, to end: Index) -> Int {
    ___distance(from: start, to: end)
  }
}

extension RedBlackTreeSet: CustomStringConvertible, CustomDebugStringConvertible {

  @inlinable
  public var description: String {
    "[\((map {"\($0)"} as [String]).joined(separator: ", "))]"
  }

  @inlinable
  public var debugDescription: String {
    "RedBlackTreeSet(\(description))"
  }
}

extension RedBlackTreeSet: Equatable {

  @inlinable
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.___equal_with(rhs)
  }
}

extension RedBlackTreeSet {

  public typealias ElementSequence = [Element]

  @inlinable
  public subscript(bounds: IndexRange) -> ElementSequence {
    ___element_sequence__(from: bounds.lhs, to: bounds.rhs)
  }
}

extension RedBlackTreeSet {

  @inlinable public func map<T>(_ transform: (Element) throws -> T) rethrows -> [T] {
    try ___element_sequence__(from: ___index_begin(), to: ___index_end(), transform: transform)
  }

  @inlinable public func filter(_ isIncluded: (Element) throws -> Bool) rethrows -> [Element] {
    try ___element_sequence__(from: ___index_begin(), to: ___index_end(), isIncluded: isIncluded)
  }

  @inlinable public func reduce<Result>(
    into initialResult: Result, _ updateAccumulatingResult: (inout Result, Element) throws -> Void
  ) rethrows -> Result {
    try ___element_sequence__(
      from: ___index_begin(), to: ___index_end(), into: initialResult, updateAccumulatingResult)
  }

  @inlinable public func reduce<Result>(
    _ initialResult: Result, _ nextPartialResult: (Result, Element) throws -> Result
  ) rethrows -> Result {
    try ___element_sequence__(
      from: ___index_begin(), to: ___index_end(), initialResult, nextPartialResult)
  }
}

extension RedBlackTreeSet {

  public typealias EnumeratedElement = (position: Index, element: Element)
  public typealias EnumeratedSequence = [EnumeratedElement]

  @inlinable
  public func enumerated() -> EnumeratedSequence {
    ___enumerated_sequence__
  }

  /// 指定した範囲（`lhs ..< rhs` の半開区間）内の要素を、
  /// `(position: Index, element: Element)` タプルの配列として返します。
  ///
  /// - Parameter range: 列挙したい要素の範囲を示す `IndexRange` で、
  ///   Swift の `lhs ..< rhs` のように、`lhs`（含む）から `rhs`（含まない）までの
  ///   半開区間を表します。
  /// - Returns: 該当範囲の要素を `(Index, Element)` タプルの配列で返す `EnumeratedSequence`。
  ///
  /// ## 計算量 (償却)
  /// - 単一の「次ノード」取得 (`tree_next_iter` など) に注目すれば、
  ///   木の高さに比例して最悪 **O(log n)** となる場合があります。
  /// - しかし、範囲内の要素を **連続** して辿る場合は、同じ枝を何度も上り下りしないため、
  ///   *k* 個の要素を取得し終えるまでの合計コストは償却 **O(k)** です。
  ///   （ここで *k* は範囲内の要素数）
  ///
  /// - Important: `lhs ..< rhs` のように左端が右端より大きい（または等しい）場合など、
  ///   無効な区間が指定されたときの挙動は未定義です。必ず正しい範囲を指定してください。
  @inlinable
  public func enumeratedSubrange(_ range: IndexRange) -> EnumeratedSequence {
    ___enumerated_sequence__(from: range.lhs, to: range.rhs)
  }
}

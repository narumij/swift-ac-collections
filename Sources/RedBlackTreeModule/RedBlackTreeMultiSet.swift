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

/// `RedBlackTreeMultiSet` は、`Element` 型の要素を格納するための
/// 赤黒木（Red-Black Tree）ベースのマルチセット型です。
///
/// ### 使用例
/// ```swift
/// var multiset = RedBlackTreeMultiSet<Int>()
/// multiset.insert(5)
/// multiset.insert(3)
/// multiset.insert(5) // 重複した要素の挿入
///
/// // 要素の出現回数を確認
/// print(multiset.count(of: 5)) // 出力例: 2
/// print(multiset.count(of: 3)) // 出力例: 1
/// ```
@frozen
public struct RedBlackTreeMultiSet<Element: Comparable> {

  public
    typealias Element = Element

  public
    typealias Index = Tree.Index

  public
    typealias _Key = Element

  @usableFromInline
  var _storage: Tree.Storage
}

extension RedBlackTreeMultiSet: ___RedBlackTreeBase {}
extension RedBlackTreeMultiSet: ___RedBlackTreeCopyOnWrite {}
extension RedBlackTreeMultiSet: ___RedBlackTreeMulti {}
extension RedBlackTreeMultiSet: ___RedBlackTreeSequence { }
extension RedBlackTreeMultiSet: ___RedBlackTreeSubSequence { }
extension RedBlackTreeMultiSet: ScalarValueComparer {}

// MARK: - Initialization（初期化）

extension RedBlackTreeMultiSet {

  /// - Complexity: O(1)
  @inlinable @inline(__always)
  public init() {
    self.init(minimumCapacity: 0)
  }

  /// - Complexity: O(1)
  @inlinable @inline(__always)
  public init(minimumCapacity: Int) {
    _storage = .create(withCapacity: minimumCapacity)
  }
}

extension RedBlackTreeMultiSet {

  /// - Complexity: O(*n* log *n*)
  @inlinable
  public init<Source>(_ sequence: __owned Source)
  where Element == Source.Element, Source: Sequence {
    let count = (sequence as? (any Collection))?.count
    var tree: Tree = .create(minimumCapacity: count ?? 0)
    // 初期化直後はO(1)
    var (__parent, __child) = tree.___max_ref()
    // ソートの計算量がO(*n* log *n*)
    for __k in sequence.sorted() {
      if count == nil {
        Tree.ensureCapacity(tree: &tree)
      }
      // バランシングの計算量がO(log *n*)
      (__parent, __child) = tree.___emplace_hint_right(__parent, __child, __k)
      assert(tree.__tree_invariant(tree.__root()))
    }
    self._storage = .init(__tree: tree)
  }
}

extension RedBlackTreeMultiSet {

  /// - Complexity: O(*n* log *n*)
  @inlinable
  public init<R>(_ range: __owned R)
  where R: RangeExpression, R: Collection, R.Element == Element {
    precondition(range is Range<Element> || range is ClosedRange<Element>)
    let tree: Tree = .create(minimumCapacity: range.count)
    // 初期化直後はO(1)
    var (__parent, __child) = tree.___max_ref()
    for __k in range {
      // バランシングの計算量がO(log *n*)
      (__parent, __child) = tree.___emplace_hint_right(__parent, __child, __k)
    }
    assert(tree.__tree_invariant(tree.__root()))
    self._storage = .init(__tree: tree)
  }
}

extension RedBlackTreeMultiSet {

  @inlinable
  public mutating func reserveCapacity(_ minimumCapacity: Int) {
    _ensureUniqueAndCapacity(to: minimumCapacity)
  }
}

// MARK: - Insert（挿入）

extension RedBlackTreeMultiSet {

  /// - Complexity: O(log *n*)
  @inlinable
  @discardableResult
  public mutating func insert(_ newMember: Element) -> (
    inserted: Bool, memberAfterInsert: Element
  ) {
    _ensureUniqueAndCapacity()
    _ = __tree_.__insert_multi(newMember)
    return (true, newMember)
  }
}

extension RedBlackTreeMultiSet {

  /// - Complexity: O(*k* log *k*)
  @inlinable
  @inline(__always)
  public mutating func insert(contentsOf other: RedBlackTreeSet<Element>) {
    _ensureUniqueAndCapacity(to: count + other.count)
    __tree_.__node_handle_merge_multi(other.__tree_)
  }

  /// - Complexity: O(*k* log *k*)
  @inlinable
  @inline(__always)
  public mutating func insert(contentsOf other: RedBlackTreeMultiSet<Element>) {
    _ensureUniqueAndCapacity(to: count + other.count)
    __tree_.__node_handle_merge_multi(other.__tree_)
  }

  /// - Complexity: O(*k* log *k*)
  @inlinable
  @inline(__always)
  public mutating func insert<S>(contentsOf other: S) where S: Sequence, S.Element == Element {
    other.forEach { insert($0) }
  }
}

// MARK: - Remove（削除）

extension RedBlackTreeMultiSet {
  
  /// - Important: 削除したメンバーを指すインデックスが無効になります。
  /// - Complexity: O(1)
  @inlinable
  public mutating func popFirst() -> Element? {
    guard !isEmpty else { return nil }
    return remove(at: startIndex)
  }
}

extension RedBlackTreeMultiSet {

  /// - Important: 削除したメンバーを指すインデックスが無効になります。
  /// - Complexity: O(log *n*)
  @inlinable
  @discardableResult
  public mutating func remove(_ member: Element) -> Element? {
    _strongEnsureUnique()
    return __tree_.___erase_unique(member) ? member : nil
  }

  /// - Important: 削除後は、インデックスが無効になります。
  /// - Complexity: O(1)
  @inlinable
  @discardableResult
  public mutating func remove(at index: RawIndex) -> Element {
    _ensureUnique()
    guard let element = ___remove(at: index.rawValue) else {
      fatalError(.invalidIndex)
    }
    return element
  }

  /// - Important: 削除後は、インデックスが無効になります。
  /// - Complexity: O(1)
  @inlinable
  @discardableResult
  public mutating func remove(at index: Index) -> Element {
    _ensureUnique()
    guard let element = ___remove(at: index.rawValue) else {
      fatalError(.invalidIndex)
    }
    return element
  }

  /// - Important: 削除したメンバーを指すインデックスが無効になります。
  /// - Complexity: O(1)
  @inlinable
  @discardableResult
  public mutating func removeFirst() -> Element {
    guard !isEmpty else {
      preconditionFailure(.emptyFirst)
    }
    return remove(at: startIndex)
  }

  /// - Important: 削除したメンバーを指すインデックスが無効になります。
  /// - Complexity: O(log *n*)
  @inlinable
  @discardableResult
  public mutating func removeLast() -> Element {
    guard !isEmpty else {
      preconditionFailure(.emptyLast)
    }
    return remove(at: index(before: endIndex))
  }

  /// - Important: 削除後は、インデックスが無効になります。
  /// - Complexity: O(*k*)
  @inlinable
  public mutating func removeSubrange(_ range: Range<Index>) {
    _ensureUnique()
    ___remove(from: range.lowerBound.rawValue, to: range.upperBound.rawValue)
  }

  /// - Important: 削除したメンバーを指すインデックスが無効になります。
  /// - Complexity: O(log *n* : *k*)
  @inlinable
  @discardableResult
  public mutating func removeAll(_ member: Element) -> Element? {
    _strongEnsureUnique()
    return __tree_.___erase_multi(member) != 0 ? member : nil
  }

  /// - Important: 削除したメンバーを指すインデックスが無効になります。
  /// - Complexity: O(log *n* : *k*)
  @inlinable
  @discardableResult
  public mutating func removeAll(_unsafe member: Element) -> Element? {
    _ensureUnique()
    return __tree_.___erase_multi(member) != 0 ? member : nil
  }

  /// - Complexity: O(1)
  @inlinable
  public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
    _ensureUnique()
    ___removeAll(keepingCapacity: keepCapacity)
  }
}

extension RedBlackTreeMultiSet {

  /// - Complexity: O(log *n* + *k*)
  @inlinable
  @inline(__always)
  public mutating func remove(contentsOf elementRange: Range<Element>) {
    _strongEnsureUnique()
    let lower = ___lower_bound(elementRange.lowerBound)
    let upper = ___lower_bound(elementRange.upperBound)
    ___remove(from: lower, to: upper)
  }

  /// - Complexity: O(log *n* : *k*)
  @inlinable
  @inline(__always)
  public mutating func remove(contentsOf elementRange: ClosedRange<Element>) {
    _strongEnsureUnique()
    let lower = ___lower_bound(elementRange.lowerBound)
    let upper = ___upper_bound(elementRange.upperBound)
    ___remove(from: lower, to: upper)
  }
}

// MARK: - Search（検索・探索）

extension RedBlackTreeMultiSet {

  /// - Complexity: O(*n*)
  @inlinable
  public func contains(_ member: Element) -> Bool {
    ___contains(member)
  }

  /// - Complexity: O(*n*)
  ///
  /// O(1)が欲しい場合、firstが等価でO(1)
  @inlinable
  public func min() -> Element? {
    ___min()
  }

  /// - Complexity: O(*n*)
  @inlinable
  public func max() -> Element? {
    ___max()
  }
}

extension RedBlackTreeMultiSet {

  /// - Complexity: O(log *n*)
  @inlinable
  public func lowerBound(_ member: Element) -> Index {
    ___iter_lower_bound(member)
  }

  /// - Complexity: O(log *n*)
  @inlinable
  public func upperBound(_ member: Element) -> Index {
    ___iter_upper_bound(member)
  }
}

extension RedBlackTreeMultiSet {

  /// - Complexity: O(1)。
  @inlinable
  public var first: Element? {
    isEmpty ? nil : self[startIndex]
  }

  /// - Complexity: O(log *n*)
  @inlinable
  public var last: Element? {
    isEmpty ? nil : self[index(before: endIndex)]
  }

  /// - Complexity: O(*n*)
  @inlinable
  public func first(where predicate: (Element) throws -> Bool) rethrows -> Element? {
    try ___first(where: predicate)
  }

  /// - Complexity: O(log *n*)
  @inlinable
  public func firstIndex(of member: Element) -> Index? {
    ___first_iter(of: member)
  }

  /// - Complexity: O(*n*)
  @inlinable
  public func firstIndex(where predicate: (Element) throws -> Bool) rethrows -> Index? {
    try ___first_iter(where: predicate)
  }
}

extension RedBlackTreeMultiSet {

  /// - Complexity: O(log *n*)
  @inlinable
  public func equalRange(_ element: Element) -> (lower: Index, upper: Index) {
    let (lo,hi) = ___equal_range(element)
    return (___iter(lo), ___iter(hi))
  }
}

// MARK: - Utility（ユーティリティ、isEmptyやcapacityなど）

extension RedBlackTreeMultiSet {

  /// - Complexity: O(1)
  @inlinable
  public var isEmpty: Bool {
    ___is_empty
  }

  /// - Complexity: O(1)
  @inlinable
  public var capacity: Int {
    ___capacity
  }
  
  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public var count: Int {
    ___count
  }
}

extension RedBlackTreeMultiSet {

  /// - Complexity: O(log *n* + *k*)
  @inlinable
  public func count(of element: Element) -> Int {
    __tree_.__count_multi(element)
  }
}

// MARK: - Collection Conformance（コレクション適合系）

// MARK: - Sequence
// MARK: - Collection
// MARK: - BidirectionalCollection

extension RedBlackTreeMultiSet: Sequence, Collection, BidirectionalCollection { }

// MARK: - Range Access

extension RedBlackTreeMultiSet {

  /// - Complexity: O(1)
  @inlinable
  public subscript(bounds: Range<Index>) -> SubSequence {
    .init(tree: __tree_, start: bounds.lowerBound.rawValue, end: bounds.upperBound.rawValue)
  }
}

extension RedBlackTreeMultiSet {
  // 割と注意喚起の為のdeprecatedなだけで、実際にいつ消すのかは不明です。
  // 分かってると便利なため、競技プログラミングにこのシンタックスシュガーは有用と考えているからです。

  /// 範囲 `[lower, upper)` に含まれる要素を返します。
  ///
  /// index範囲ではないことに留意
  /// **Deprecated – `elements(in:)` を使ってください。**
  @available(*, deprecated, renamed: "elements(in:)")
  @inlinable
  public subscript(bounds: Range<Element>) -> SubSequence {
    elements(in: bounds)
  }

  /// 範囲 `[lower, upper]` に含まれる要素を返します。
  ///
  /// index範囲ではないことに留意
  /// **Deprecated – `elements(in:)` を使ってください。**
  @available(*, deprecated, renamed: "elements(in:)")
  @inlinable
  public subscript(bounds: ClosedRange<Element>) -> SubSequence {
    elements(in: bounds)
  }
}

extension RedBlackTreeMultiSet {
  /// 値レンジ `[lower, upper)` に含まれる要素のスライス
  /// - Complexity: O(log *n*)
  @inlinable
  public func elements(in range: Range<Element>) -> SubSequence {
    .init(tree: __tree_, start: ___lower_bound(range.lowerBound), end: ___lower_bound(range.upperBound))
  }

  /// 値レンジ `[lower, upper]` に含まれる要素のスライス
  /// - Complexity: O(log *n*)
  @inlinable
  public func elements(in range: ClosedRange<Element>) -> SubSequence {
    .init(tree: __tree_, start: ___lower_bound(range.lowerBound), end: ___upper_bound(range.upperBound))
  }
}

// MARK: - SubSequence: Sequence

extension RedBlackTreeMultiSet {

  @frozen
  public struct SubSequence {

    @usableFromInline
    let __tree_: Tree

    @usableFromInline
    var _start, _end: _NodePtr

    @inlinable
    @inline(__always)
    internal init(tree: Tree, start: _NodePtr, end: _NodePtr) {
      __tree_ = tree
      _start = start
      _end = end
    }
  }
}

extension RedBlackTreeMultiSet.SubSequence: Equatable {
  
  /// - Complexity: O(*m*), where *m* is the lesser of the length of `lhs` and `rhs`.
  @inlinable
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.elementsEqual(rhs)
  }
}

extension RedBlackTreeMultiSet.SubSequence: Comparable {

  /// - Complexity: O(*m*), where *m* is the lesser of the length of `lhs` and `rhs`.
  @inlinable
  public static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.lexicographicallyPrecedes(rhs)
  }
}

extension RedBlackTreeMultiSet.SubSequence {
  
  /// - Complexity: O(*m*), where *m* is the lesser of the length of the
  ///   sequence and the length of `other`.
  @inlinable
  public func elementsEqual<OtherSequence>(_ other: OtherSequence) -> Bool
  where OtherSequence : Sequence, Element == OtherSequence.Element
  {
      elementsEqual(other, by: Tree.___key_equiv)
  }
  
  /// - Complexity: O(*m*), where *m* is the lesser of the length of the
  ///   sequence and the length of `other`.
  @inlinable
  public func lexicographicallyPrecedes<OtherSequence>(_ other: OtherSequence) -> Bool
  where OtherSequence : Sequence, Element == OtherSequence.Element
  {
      lexicographicallyPrecedes(other, by: Tree.___key_comp)
  }
}

extension RedBlackTreeMultiSet.SubSequence: ___SubSequenceBase {
  public typealias Base = RedBlackTreeMultiSet
  public typealias Element = Tree.Element
  public typealias Indices = Tree.Indices
}

extension RedBlackTreeMultiSet.SubSequence: Sequence, Collection, BidirectionalCollection {
  public typealias Index = RedBlackTreeMultiSet.Index
  public typealias SubSequence = Self
}

// MARK: - Index Range

extension RedBlackTreeMultiSet {

  public typealias Indices = Tree.Indices
}

// MARK: - Raw Index Sequence（インデックス系）

extension RedBlackTreeMultiSet {

  /// RawIndexは赤黒木ノードへの軽量なポインタとなっていて、rawIndicesはRawIndexのシーケンスを返します。
  /// 削除時のインデックス無効対策がイテレータに施してあり、削除操作に利用することができます。
  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public var rawIndices: RawIndexSequence<Tree> {
    RawIndexSequence(tree: __tree_)
  }
}

// MARK: - Raw Indexed Sequence

extension RedBlackTreeMultiSet {

  /// - Complexity: O(1)
  @inlinable @inline(__always)
  public var rawIndexedElements: RawIndexedSequence<Tree> {
    RawIndexedSequence(tree: __tree_)
  }
}

extension RedBlackTreeMultiSet {

  @available(*, deprecated, renamed: "rawIndexedElements")
  @inlinable
  @inline(__always)
  public func enumerated() -> RawIndexedSequence<Tree> {
    rawIndexedElements
  }
}

// MARK: - Protocol Conformance

// MARK: - ExpressibleByArrayLiteral

extension RedBlackTreeMultiSet: ExpressibleByArrayLiteral {

  /// - Complexity: O(*n* log *n*)
  @inlinable
  public init(arrayLiteral elements: Element...) {
    self.init(elements)
  }
}

// MARK: - CustomStringConvertible

extension RedBlackTreeMultiSet: CustomStringConvertible {

  @inlinable
  public var description: String {
    "[\((map {"\($0)"} as [String]).joined(separator: ", "))]"
  }
}

// MARK: - CustomDebugStringConvertible

extension RedBlackTreeMultiSet: CustomDebugStringConvertible {

  @inlinable
  public var debugDescription: String {
    "RedBlackTreeMultiSet(\(description))"
  }
}

// MARK: - Equatable

extension RedBlackTreeMultiSet: Equatable {
  
  /// - Complexity: O(*m*), where *m* is the lesser of the length of `lhs` and `rhs`.
  @inlinable
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.count == rhs.count && lhs.elementsEqual(rhs)
  }
}

extension RedBlackTreeMultiSet: Comparable {
  
  /// - Complexity: O(*m*), where *m* is the lesser of the length of `lhs` and `rhs`.
  @inlinable
  public static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.lexicographicallyPrecedes(rhs)
  }
}

extension RedBlackTreeMultiSet {
  
  /// - Complexity: O(*m*), where *m* is the lesser of the length of the
  ///   sequence and the length of `other`.
  @inlinable
  public func elementsEqual<OtherSequence>(_ other: OtherSequence) -> Bool
  where OtherSequence : Sequence, Element == OtherSequence.Element
  {
      elementsEqual(other, by: Tree.___key_equiv)
  }
  
  /// - Complexity: O(*m*), where *m* is the lesser of the length of the
  ///   sequence and the length of `other`.
  @inlinable
  public func lexicographicallyPrecedes<OtherSequence>(_ other: OtherSequence) -> Bool
  where OtherSequence : Sequence, Element == OtherSequence.Element
  {
      lexicographicallyPrecedes(other, by: Tree.___key_comp)
  }
}

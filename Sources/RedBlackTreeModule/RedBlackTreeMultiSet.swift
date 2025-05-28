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

/// `RedBlackTreeMultiSet` は、`Element` 型の要素を複数格納するための
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
    typealias Index = Tree.Pointer

  public
    typealias _Key = Element

  @usableFromInline
  var _storage: Tree.Storage
}

extension RedBlackTreeMultiSet: ___RedBlackTreeBase {}
extension RedBlackTreeMultiSet: ___RedBlackTreeStorageLifetime {}
extension RedBlackTreeMultiSet: ___RedBlackTreeEqualRangeMulti {}
extension RedBlackTreeMultiSet: ScalarValueComparer {}

// MARK: - Initialization（初期化）

extension RedBlackTreeMultiSet {

  @inlinable @inline(__always)
  public init() {
    self.init(minimumCapacity: 0)
  }

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
    _ = _tree.__insert_multi(newMember)
    return (true, newMember)
  }
}

extension RedBlackTreeMultiSet {

  @inlinable
  @inline(__always)
  public mutating func insert(contentsOf other: RedBlackTreeSet<Element>) {
    _ensureUniqueAndCapacity(to: count + other.count)
    _tree.__node_handle_merge_multi(other._tree)
  }

  @inlinable
  @inline(__always)
  public mutating func insert(contentsOf other: RedBlackTreeMultiSet<Element>) {
    _ensureUniqueAndCapacity(to: count + other.count)
    _tree.__node_handle_merge_multi(other._tree)
  }

  @inlinable
  @inline(__always)
  public mutating func insert<S>(contentsOf other: S) where S: Sequence, S.Element == Element {
    other.forEach { insert($0) }
  }
}

// MARK: - Remove（削除）

extension RedBlackTreeMultiSet {
  @inlinable
  public mutating func popFirst() -> Element? {
    guard !isEmpty else { return nil }
    return remove(at: startIndex)
  }
}

extension RedBlackTreeMultiSet {

  /// - Complexity: O(log *n*)
  @inlinable
  @discardableResult
  public mutating func remove(_ member: Element) -> Element? {
    _strongEnsureUnique()
    return _tree.___erase_unique(member) ? member : nil
  }

  /// - Important: 削除後は、これまで使用していたインデックスが無効になります。
  ///
  /// - Complexity: O(log *n*)
  @inlinable
  @discardableResult
  public mutating func remove(at index: RawIndex) -> Element {
    _ensureUnique()
    guard let element = ___remove(at: index.rawValue) else {
      fatalError(.invalidIndex)
    }
    return element
  }

  /// - Important: 削除後は、これまで使用していたインデックスが無効になります。
  ///
  /// - Complexity: O(log *n*)
  @inlinable
  @discardableResult
  public mutating func remove(at index: Index) -> Element {
    _ensureUnique()
    index.phantomMark()
    guard let element = ___remove(at: index.rawValue) else {
      fatalError(.invalidIndex)
    }
    return element
  }

  /// - Complexity: O(log *n*)
  @inlinable
  @discardableResult
  public mutating func removeFirst() -> Element {
    guard !isEmpty else {
      preconditionFailure(.emptyFirst)
    }
    return remove(at: startIndex)
  }

  /// - Complexity: O(log *n*)
  @inlinable
  @discardableResult
  public mutating func removeLast() -> Element {
    guard !isEmpty else {
      preconditionFailure(.emptyLast)
    }
    return remove(at: index(before: endIndex))
  }

  /// - Complexity: O(log *n* + *k*)
  ///
  /// - Important: 削除後は、これまで使用していたインデックスが無効になります。
  @inlinable
  public mutating func removeSubrange(_ range: Range<Index>) {
    _ensureUnique()
    ___remove(from: range.lowerBound.rawValue, to: range.upperBound.rawValue)
  }

  /// - Complexity: O(log *n*)
  @inlinable
  @discardableResult
  public mutating func removeAll(_ member: Element) -> Element? {
    _strongEnsureUnique()
    return _tree.___erase_multi(member) != 0 ? member : nil
  }

  /// - Complexity: O(log *n*)
  @inlinable
  @discardableResult
  public mutating func removeAll(_unsafe member: Element) -> Element? {
    _ensureUnique()
    return _tree.___erase_multi(member) != 0 ? member : nil
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
    let lower = lowerBound(elementRange.lowerBound)
    let upper = lowerBound(elementRange.upperBound)
    removeSubrange(lower..<upper)
  }

  @inlinable
  @inline(__always)
  public mutating func remove(contentsOf elementRange: ClosedRange<Element>) {
    let lower = lowerBound(elementRange.lowerBound)
    let upper = upperBound(elementRange.upperBound)
    removeSubrange(lower..<upper)
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
    ___index_lower_bound(member)
  }

  /// - Complexity: O(log *n*)
  @inlinable
  public func upperBound(_ member: Element) -> Index {
    ___index_upper_bound(member)
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
    ___first_index(of: member)
  }

  /// - Complexity: O(*n*)
  @inlinable
  public func firstIndex(where predicate: (Element) throws -> Bool) rethrows -> Index? {
    try ___first_index(where: predicate)
  }
}

extension RedBlackTreeMultiSet {

  @inlinable
  public func equalRange(_ element: Element) -> (lower: Tree.Pointer, upper: Tree.Pointer) {
    ___equal_range(element)
  }
}

// MARK: - Utility（ユーティリティ、isEmptyやcapacityなど）

extension RedBlackTreeMultiSet {

  /// - 計算量: O(1)
  @inlinable
  public var isEmpty: Bool {
    ___is_empty
  }

  /// - 計算量: O(1)
  @inlinable
  public var capacity: Int {
    ___capacity
  }
}

extension RedBlackTreeMultiSet {

  /// - Complexity: O(log *n* + *k*)
  @inlinable
  public func count(of element: Element) -> Int {
    _tree.__count_multi(element)
  }
}

extension RedBlackTreeMultiSet {

  @inlinable
  @inline(__always)
  public func isValid(index: Index) -> Bool {
    _tree.___is_valid_index(index.rawValue)
  }

  @inlinable
  @inline(__always)
  public func isValid(index: RawIndex) -> Bool {
    _tree.___is_valid_index(index.rawValue)
  }
}

extension RedBlackTreeMultiSet.SubSequence {

  @inlinable
  @inline(__always)
  public func isValid(index i: Index) -> Bool {
    _subSequence.___is_valid_index(index: i.rawValue)
  }

  @inlinable
  @inline(__always)
  public func isValid(index i: RawIndex) -> Bool {
    _subSequence.___is_valid_index(index: i.rawValue)
  }
}

// MARK: - Iteration

extension RedBlackTreeMultiSet {

  @inlinable
  public func sorted() -> [Element] {
    _tree.___sorted
  }
}

// MARK: - Collection Conformance（コレクション適合系）

// MARK: - Sequence

extension RedBlackTreeMultiSet: Sequence {

  @inlinable
  @inline(__always)
  public func forEach(_ body: (Element) throws -> Void) rethrows {
    try _tree.___for_each_(body)
  }

  @frozen
  public struct Iterator: IteratorProtocol {
    @usableFromInline
    internal var _iterator: Tree.Iterator

    @inlinable
    @inline(__always)
    internal init(_base: RedBlackTreeMultiSet) {
      self._iterator = _base._tree.makeIterator()
    }

    @inlinable
    @inline(__always)
    public mutating func next() -> Element? {
      return self._iterator.next()
    }
  }

  @inlinable
  @inline(__always)
  public __consuming func makeIterator() -> Iterator {
    return Iterator(_base: self)
  }
}

// MARK: - BidirectionalCollection

extension RedBlackTreeMultiSet: BidirectionalCollection {

  @inlinable
  @inline(__always)
  public var startIndex: Index {
    ___index_start()
  }

  @inlinable
  @inline(__always)
  public var endIndex: Index {
    ___index_end()
  }

  @inlinable
  @inline(__always)
  public var count: Int {
    ___count
  }

  @inlinable
  @inline(__always)
  public func distance(from start: Index, to end: Index) -> Int {
    ___distance(from: start.rawValue, to: end.rawValue)
  }

  @inlinable
  @inline(__always)
  public func index(after i: Index) -> Index {
    ___index(after: i.rawValue)
  }

  @inlinable
  @inline(__always)
  public func formIndex(after i: inout Index) {
    ___form_index(after: &i.rawValue)
  }

  @inlinable
  @inline(__always)
  public func index(before i: Index) -> Index {
    ___index(before: i.rawValue)
  }

  @inlinable
  @inline(__always)
  public func formIndex(before i: inout Index) {
    ___form_index(before: &i.rawValue)
  }

  @inlinable
  @inline(__always)
  public func index(_ i: Index, offsetBy distance: Int) -> Index {
    ___index(i.rawValue, offsetBy: distance)
  }

  @inlinable
  @inline(__always)
  public func formIndex(_ i: inout Index, offsetBy distance: Int) {
    ___form_index(&i.rawValue, offsetBy: distance)
  }

  @inlinable
  @inline(__always)
  public func index(_ i: Index, offsetBy distance: Int, limitedBy limit: Index) -> Index? {
    ___index(i.rawValue, offsetBy: distance, limitedBy: limit.rawValue)
  }

  @inlinable
  @inline(__always)
  public func formIndex(_ i: inout Index, offsetBy distance: Int, limitedBy limit: Self.Index)
    -> Bool
  {
    ___form_index(&i.rawValue, offsetBy: distance, limitedBy: limit.rawValue)
  }

  @inlinable
  @inline(__always)
  public subscript(position: Index) -> Element {
    return _tree[position.rawValue]
  }

  @inlinable
  @inline(__always)
  public subscript(position: RawIndex) -> Element {
    return _tree[position.rawValue]
  }
}

// MARK: - SubSequence（部分コレクション）

extension RedBlackTreeMultiSet {

  @inlinable
  public subscript(bounds: Range<Index>) -> SubSequence {
    SubSequence(
      _subSequence:
        _tree.subsequence(
          from: bounds.lowerBound.rawValue,
          to: bounds.upperBound.rawValue)
    )
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
  @inlinable
  public func elements(in range: Range<Element>) -> SubSequence {
    SubSequence(
      _subSequence:
        _tree.subsequence(
          from: ___ptr_lower_bound(range.lowerBound),
          to: ___ptr_lower_bound(range.upperBound)))
  }

  /// 値レンジ `[lower, upper]` に含まれる要素のスライス
  @inlinable
  public func elements(in range: ClosedRange<Element>) -> SubSequence {
    SubSequence(
      _subSequence:
        _tree.subsequence(
          from: ___ptr_lower_bound(range.lowerBound),
          to: ___ptr_upper_bound(range.upperBound)))
  }
}

// MARK: - SubSequence: Sequence

extension RedBlackTreeMultiSet {

  @frozen
  public struct SubSequence {

    @usableFromInline
    internal typealias _SubSequence = Tree.SubSequence

    @usableFromInline
    internal let _subSequence: _SubSequence

    @inlinable
    init(_subSequence: _SubSequence) {
      self._subSequence = _subSequence
    }
  }
}

extension RedBlackTreeMultiSet.SubSequence {

  public typealias Base = RedBlackTreeMultiSet
  public typealias SubSequence = Self
  public typealias Index = Base.Index
  public typealias Element = Base.Element
}

extension RedBlackTreeMultiSet.SubSequence: Sequence {

  public struct Iterator: IteratorProtocol {
    @usableFromInline
    internal var _iterator: _SubSequence.Iterator

    @inlinable
    @inline(__always)
    internal init(_ _iterator: _SubSequence.Iterator) {
      self._iterator = _iterator
    }

    @inlinable
    @inline(__always)
    public mutating func next() -> Element? {
      _iterator.next()
    }
  }

  @inlinable
  @inline(__always)
  public __consuming func makeIterator() -> Iterator {
    Iterator(_subSequence.makeIterator())
  }
}

extension RedBlackTreeMultiSet.SubSequence: ___RedBlackTreeSubSequenceBase {}

// MARK: - SubSequence: BidirectionalCollection

extension RedBlackTreeMultiSet.SubSequence: BidirectionalCollection {

  @inlinable
  @inline(__always)
  public var startIndex: Index {
    ___start_index
  }

  @inlinable
  @inline(__always)
  public var endIndex: Index {
    ___end_index
  }

  @inlinable
  @inline(__always)
  public var count: Int {
    ___count
  }

  @inlinable
  @inline(__always)
  public func forEach(_ body: (Element) throws -> Void) rethrows {
    try ___for_each(body)
  }

  @inlinable
  @inline(__always)
  public func distance(from start: Index, to end: Index) -> Int {
    ___distance(from: start, to: end)
  }

  @inlinable
  @inline(__always)
  public func index(after i: Index) -> Index {
    ___index(after: i)
  }

  @inlinable
  @inline(__always)
  public func formIndex(after i: inout Index) {
    ___form_index(after: &i)
  }

  @inlinable
  @inline(__always)
  public func index(before i: Index) -> Index {
    ___index(before: i)
  }

  @inlinable
  @inline(__always)
  public func formIndex(before i: inout Index) {
    ___form_index(before: &i)
  }

  @inlinable
  @inline(__always)
  public func index(_ i: Index, offsetBy distance: Int) -> Index {
    ___index(i, offsetBy: distance)
  }

  @inlinable
  @inline(__always)
  public func formIndex(_ i: inout Index, offsetBy distance: Int) {
    ___form_index(&i, offsetBy: distance)
  }

  @inlinable
  @inline(__always)
  public func index(_ i: Index, offsetBy distance: Int, limitedBy limit: Index) -> Index? {
    ___index(i, offsetBy: distance, limitedBy: limit)
  }

  @inlinable
  @inline(__always)
  public func formIndex(_ i: inout Index, offsetBy distance: Int, limitedBy limit: Index)
    -> Bool
  {
    ___form_index(&i, offsetBy: distance, limitedBy: limit)
  }

  @inlinable
  @inline(__always)
  public subscript(position: Index) -> Element {
    _subSequence[position.rawValue]
  }

  @inlinable
  @inline(__always)
  public subscript(position: RawIndex) -> Element {
    _subSequence[position.rawValue]
  }

  @inlinable
  public subscript(bounds: Range<Index>) -> SubSequence {
    SubSequence(
      _subSequence:
        _subSequence[bounds.lowerBound..<bounds.upperBound])
  }
}

// MARK: - Index Range

extension RedBlackTreeMultiSet {

  public typealias Indices = Range<Index>

  @inlinable
  @inline(__always)
  public var indices: Indices {
    startIndex..<endIndex
  }
}

extension RedBlackTreeMultiSet.SubSequence {

  public typealias Indices = Range<Index>

  @inlinable
  @inline(__always)
  public var indices: Indices {
    startIndex..<endIndex
  }
}

// MARK: - Raw Index Sequence（インデックス系）

extension RedBlackTreeMultiSet: RedBlackTreeRawIndexIteratable { }

extension RedBlackTreeMultiSet {

  /// RawIndexは赤黒木ノードへの軽量なポインタとなっていて、rawIndicesはRawIndexのシーケンスを返します。
  /// 削除時のインデックス無効対策がイテレータに施してあり、削除操作に利用することができます。
  @inlinable
  @inline(__always)
  public var rawIndices: RawIndexSequence<RedBlackTreeMultiSet> {
    RawIndexSequence(tree: _tree)
  }
}

extension RedBlackTreeMultiSet.SubSequence {

  /// RawIndexは赤黒木ノードへの軽量なポインタとなっていて、rawIndicesはRawIndexのシーケンスを返します。
  /// 削除時のインデックス無効対策がイテレータに施してあり、削除操作に利用することができます。
  @inlinable
  @inline(__always)
  public var rawIndices: RawIndexSequence<RedBlackTreeMultiSet> {
    RawIndexSequence(
      tree: _tree,
      start: startIndex.rawValue,
      end: endIndex.rawValue)
  }
}

// MARK: - Raw Indexed Sequence

extension RedBlackTreeMultiSet {

  @inlinable @inline(__always)
  public var rawIndexedElements: RawIndexedSequence<RedBlackTreeMultiSet> {
    RawIndexedSequence(tree: _tree)
  }
}

extension RedBlackTreeMultiSet.SubSequence {

  @inlinable @inline(__always)
  public var rawIndexedElements: RawIndexedSequence<RedBlackTreeMultiSet> {
    RawIndexedSequence(
      tree: _tree,
      start: startIndex.rawValue,
      end: endIndex.rawValue)
  }
}

extension RedBlackTreeMultiSet {

  @available(*, deprecated, renamed: "rawIndexedElements")
  @inlinable
  @inline(__always)
  public func enumerated() -> RawIndexedSequence<RedBlackTreeMultiSet> {
    rawIndexedElements
  }
}

extension RedBlackTreeMultiSet.SubSequence {

  @available(*, deprecated, renamed: "rawIndexedElements")
  @inlinable
  @inline(__always)
  public func enumerated() -> RawIndexedSequence<RedBlackTreeMultiSet> {
    rawIndexedElements
  }
}

// MARK: - Protocol Conformance（プロトコル適合）

// MARK: - ExpressibleByArrayLiteral

extension RedBlackTreeMultiSet: ExpressibleByArrayLiteral {

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

  @inlinable
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.___equal_with(rhs)
  }
}

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

/// `RedBlackTreeMultiset` は、`Element` 型の要素を複数格納するための
/// 赤黒木（Red-Black Tree）ベースのマルチセット型です。
///
/// ### 使用例
/// ```swift
/// var multiset = RedBlackTreeMultiset<Int>()
/// multiset.insert(5)
/// multiset.insert(3)
/// multiset.insert(5) // 重複した要素の挿入
///
/// // 要素の出現回数を確認
/// print(multiset.count(of: 5)) // 出力例: 2
/// print(multiset.count(of: 3)) // 出力例: 1
/// ```
@frozen
public struct RedBlackTreeMultiset<Element: Comparable> {

  public
    typealias Element = Element

  public
    typealias EnumElement = Tree.EnumElement

  public
    typealias Index = Tree.Pointer

  public
    typealias _Key = Element

  @usableFromInline
  var _storage: Tree.Storage

  @inlinable
  @inline(__always)
  var _tree: Tree { _storage.tree }
}

extension RedBlackTreeMultiset {
  public typealias RawIndex = Tree.RawPointer
}

extension RedBlackTreeMultiset: ___RedBlackTreeBase {}
extension RedBlackTreeMultiset: ___RedBlackTreeStorageLifetime {}
extension RedBlackTreeMultiset: ScalarValueComparer {}

extension RedBlackTreeMultiset {

  @inlinable @inline(__always)
  public init() {
    self.init(minimumCapacity: 0)
  }

  @inlinable @inline(__always)
  public init(minimumCapacity: Int) {
    _storage = .create(withCapacity: minimumCapacity)
  }
}

extension RedBlackTreeMultiset {

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

extension RedBlackTreeMultiset {

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

extension RedBlackTreeMultiset {

  /// - 計算量: O(1)
  @inlinable
  public var isEmpty: Bool {
    ___isEmpty
  }

  /// - 計算量: O(1)
  @inlinable
  public var capacity: Int {
    ___header_capacity
  }
}

extension RedBlackTreeMultiset {

  @inlinable
  public mutating func reserveCapacity(_ minimumCapacity: Int) {
    _ensureUniqueAndCapacity(to: minimumCapacity)
  }
}

extension RedBlackTreeMultiset {

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

  /// - Complexity: O(log *n*)
  @inlinable
  @discardableResult
  public mutating func remove(_ member: Element) -> Element? {
    _strongEnsureUnique()
    return _tree.___erase_multi(member) != 0 ? member : nil
  }

  /// - Complexity: O(log *n*)
  @inlinable
  @discardableResult
  public mutating func remove(_unsafe member: Element) -> Element? {
    _ensureUnique()
    return _tree.___erase_multi(member) != 0 ? member : nil
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

  /// - Complexity: O(1)
  @inlinable
  public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
    _ensureUnique()
    ___removeAll(keepingCapacity: keepCapacity)
  }
}

extension RedBlackTreeMultiset {

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

extension RedBlackTreeMultiset {

  /// - Complexity: O(*n*)
  @inlinable
  public func contains(_ member: Element) -> Bool {
    ___contains_unique(member)
  }

  /// - Complexity: O(*n*)
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

extension RedBlackTreeMultiset: ExpressibleByArrayLiteral {

  @inlinable
  public init(arrayLiteral elements: Element...) {
    self.init(elements)
  }
}

extension RedBlackTreeMultiset {

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

extension RedBlackTreeMultiset {

  /// - Complexity: O(1)。
  @inlinable
  public var first: Element? {
    isEmpty ? nil : self[startIndex]
  }

  /// - Complexity: O(log *n*)
  @inlinable
  public var last: Element? {
    isEmpty ? nil : self[index(before: .end(_storage))]
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

extension RedBlackTreeMultiset {

  @inlinable
  public func sorted() -> [Element] {
    _tree.___sorted
  }
}

extension RedBlackTreeMultiset {

  /// - Complexity: O(log *n* + *k*)
  @inlinable
  public func count(of element: Element) -> Int {
    _tree.__count_multi(element)
  }
}

extension RedBlackTreeMultiset: CustomStringConvertible, CustomDebugStringConvertible {

  @inlinable
  public var description: String {
    "[\((map {"\($0)"} as [String]).joined(separator: ", "))]"
  }

  @inlinable
  public var debugDescription: String {
    "RedBlackTreeMultiset(\(description))"
  }
}

// MARK: - Equatable

extension RedBlackTreeMultiset: Equatable {

  @inlinable
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.___equal_with(rhs)
  }
}

// MARK: - Sequence, BidirectionalCollection

extension RedBlackTreeMultiset: Sequence {

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
    internal init(_base: RedBlackTreeMultiset) {
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

  #if false
    @inlinable
    @inline(__always)
    public func enumerated() -> AnySequence<EnumElement> {
      AnySequence { _tree.makeEnumIterator() }
    }
  #else
    @inlinable
    @inline(__always)
    public func enumerated() -> EnumSequence {
      EnumSequence(_subSequence: _tree.enumeratedSubsequence())
    }
  #endif
}

extension RedBlackTreeMultiset: BidirectionalCollection {

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
    ___count }

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

  @inlinable
  public subscript(bounds: Range<Index>) -> SubSequence {
    SubSequence(
      _subSequence:
        _tree.subsequence(
          from: bounds.lowerBound.rawValue,
          to: bounds.upperBound.rawValue)
    )
  }

  @inlinable
  public subscript(bounds: Range<Element>) -> SubSequence {
    SubSequence(
      _subSequence:
        _tree.subsequence(
          from: ___ptr_lower_bound(bounds.lowerBound),
          to: ___ptr_lower_bound(bounds.upperBound)))
  }

  @inlinable
  public subscript(bounds: ClosedRange<Element>) -> SubSequence {
    SubSequence(
      _subSequence:
        _tree.subsequence(
          from: ___ptr_lower_bound(bounds.lowerBound),
          to: ___ptr_upper_bound(bounds.upperBound)))
  }
}

extension RedBlackTreeMultiset {

  @frozen
  public struct SubSequence {

    @usableFromInline
    internal typealias _Tree = Tree

    @usableFromInline
    internal typealias _TreeSubSequence = Tree.SubSequence

    @usableFromInline
    internal let _subSequence: _TreeSubSequence

    @inlinable
    init(_subSequence: _TreeSubSequence) {
      self._subSequence = _subSequence
    }

    @inlinable
    @inline(__always)
    internal var tree: Tree { _subSequence._tree }
  }
}

extension RedBlackTreeMultiset.SubSequence {

  public typealias Base = RedBlackTreeMultiset
  public typealias SubSequence = Self
  public typealias Index = Base.Index
  public typealias RawIndex = Base.RawIndex
  public typealias Element = Base.Element
  public typealias EnumElement = Base.Tree.EnumElement
  public typealias EnumSequence = Base.EnumSequence
}

extension RedBlackTreeMultiset.SubSequence: Sequence {

  public struct Iterator: IteratorProtocol {
    @usableFromInline
    internal var _iterator: _TreeSubSequence.Iterator

    @inlinable
    @inline(__always)
    internal init(_ _iterator: _TreeSubSequence.Iterator) {
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

  #if false
    @inlinable
    @inline(__always)
    public func enumerated() -> AnySequence<EnumElement> {
      AnySequence {
        tree.makeEnumeratedIterator(start: startIndex.rawValue, end: endIndex.rawValue)
      }
    }
  #else
    @inlinable
    @inline(__always)
    public func enumerated() -> EnumSequence {
      EnumSequence(
        _subSequence: tree.enumeratedSubsequence(from: startIndex.rawValue, to: endIndex.rawValue))
    }
  #endif
}

extension RedBlackTreeMultiset.SubSequence: ___RedBlackTreeSubSequenceBase { }

extension RedBlackTreeMultiset.SubSequence: BidirectionalCollection {


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
  internal func formIndex(_ i: inout Index, offsetBy distance: Int) {
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
    return _subSequence[position.rawValue]
  }

  @inlinable
  @inline(__always)
  public subscript(position: RawIndex) -> Element {
    return tree[position.rawValue]
  }

  @inlinable
  public subscript(bounds: Range<Index>) -> SubSequence {
    SubSequence(
      _subSequence:
        _subSequence[bounds.lowerBound..<bounds.upperBound])
  }
}

// MARK: - Enumerated Sequence

extension RedBlackTreeMultiset {

  @frozen
  public struct EnumSequence {

    public typealias _Element = Tree.EnumElement

    public typealias Element = Tree.EnumElement

    @usableFromInline
    internal typealias _TreeEnumSequence = Tree.EnumSequence

    @usableFromInline
    internal let _subSequence: _TreeEnumSequence

    @inlinable
    init(_subSequence: _TreeEnumSequence) {
      self._subSequence = _subSequence
    }
  }
}

extension RedBlackTreeMultiset.EnumSequence: Sequence {

  public struct EnumIterator: IteratorProtocol {

    @usableFromInline
    internal var _iterator: _TreeEnumSequence.Iterator

    @inlinable
    @inline(__always)
    internal init(_ _iterator: _TreeEnumSequence.Iterator) {
      self._iterator = _iterator
    }

    @inlinable
    @inline(__always)
    public mutating func next() -> _Element? {
      _iterator.next()
    }
  }

  @inlinable
  @inline(__always)
  public __consuming func makeIterator() -> EnumIterator {
    Iterator(_subSequence.makeIterator())
  }
}

extension RedBlackTreeMultiset.EnumSequence {

  @inlinable
  @inline(__always)
  public func forEach(_ body: (_Element) throws -> Void) rethrows {
    try _subSequence.forEach(body)
  }
}

// MARK: -

extension RedBlackTreeMultiset {

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

extension RedBlackTreeMultiset.SubSequence {

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

extension RedBlackTreeMultiset {

  @inlinable
  @inline(__always)
  public mutating func insert(contentsOf other: RedBlackTreeSet<Element>) {
    _ensureUniqueAndCapacity(to: count + other.count)
    _tree.__node_handle_merge_multi(other._tree)
  }

  @inlinable
  @inline(__always)
  public mutating func insert(contentsOf other: RedBlackTreeMultiset<Element>) {
    _ensureUniqueAndCapacity(to: count + other.count)
    _tree.__node_handle_merge_multi(other._tree)
  }

  @inlinable
  @inline(__always)
  public mutating func insert<S>(contentsOf other: S) where S: Sequence, S.Element == Element {
    other.forEach { insert($0) }
  }
}

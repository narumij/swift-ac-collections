// Copyright 2024-2025 narumij
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

// 先頭ドキュメントは学習用途を想定し、実用的な使い方と誤用防止を優先して簡潔に記述する。

/// # RedBlackTreeMultiSet
///
/// `RedBlackTreeMultiSet` is an **ordered multiset (allowing duplicates)**
/// implemented using a red-black tree.
/// Elements are always kept in sorted order.
///
/// ```swift
/// var set: RedBlackTreeMultiSet<Int> = []
/// set.insert(3) // -> [3]
/// set.insert(1) // -> [1, 3]
/// set.insert(4) // -> [1, 3, 4]
/// set.insert(1) // -> [1, 1, 3, 4]
/// set.insert(5) // -> [1, 1, 3, 4, 5]
/// ```
///
/// ## Removal
///
/// Both single-element removal and range removal are supported.
///
/// ```swift
/// var set: RedBlackTreeMultiSet<Int> = [1, 1, 3, 4, 5]
/// set.remove(3) // -> [1, 1, 4, 5]
/// ```
///
/// Avoid performing repeated removals via indices in a `for` loop.
/// Since indices are tightly coupled with tree nodes, removing an element
/// invalidates the operation that retrieves the next index.
/// Use the range-removal APIs for consecutive deletions instead.
///
/// ```swift
/// var set: RedBlackTreeMultiSet<Int> = [1, 1, 3, 4, 5]
/// set[set.lowerBound(4)..<set.endIndex].erase() // -> [1, 1, 3]
/// ```
///
/// ```swift
/// var set: RedBlackTreeMultiSet<Int> = [1, 1, 3, 4, 5]
/// set.erase(set.lowerBound(4)..<set.endIndex) // -> [1, 1, 3]
/// ```
///
/// As in C++, sequential removal using `erase(_:) -> Index` is also supported.
/// You can remove elements while receiving the next index.
///
/// ```swift
/// var set: RedBlackTreeMultiSet<Int> = [1, 1, 3, 4, 5]
/// var i = set.startIndex
/// while i != set.endIndex {
///   i = set.erase(i)
/// }
/// ```
///
/// ## Index Alternative Syntax
///
/// `BoundExpression` is designed as a **safe alternative** to direct index usage.
/// It allows specifying elements or boundaries without handling indices directly.
///
/// ```swift
/// var set: RedBlackTreeMultiSet<Int> = [1, 1, 3, 4, 5]
/// print(set[.start.advance(by: 1)]) // -> 1
/// ```
///
/// ```swift
/// var set: RedBlackTreeMultiSet<Int> = [1, 1, 3, 4, 5]
/// print(set[.lowerBound(5)]) // -> 5
/// print(set[.upperBound(5)]) // -> nil (equivalent to end)
/// print(set[.find(2)]) // -> nil (not found)
/// ```
///
/// - Important: `RedBlackTreeMultiSet` is not thread-safe.
@frozen
public struct RedBlackTreeMultiSet<Element: Comparable> {

  public typealias Element = Element

  public typealias _Key = Element

  public typealias _PayloadValue = Element

  @usableFromInline
  var __tree_: Tree

  @inlinable @inline(__always)
  internal init(__tree_: Tree) {
    self.__tree_ = __tree_
  }
}

extension RedBlackTreeMultiSet {
  public typealias Base = Self
}

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiSet: _RedBlackTreeKeyOnly {}
#endif

extension RedBlackTreeMultiSet: CompareMultiTrait {}
extension RedBlackTreeMultiSet: ScalarValueTrait {}
extension RedBlackTreeMultiSet: _ScalarBasePayload_KeyProtocol_ptr {}
extension RedBlackTreeMultiSet: _BaseNode_NodeCompareProtocol {}

// MARK: - Creating a MultSet

extension RedBlackTreeMultiSet {

  /// - Complexity: O(1)
  @inlinable @inline(__always)
  public init() {
    self.init(__tree_: .create())
  }

  /// - Complexity: O(1)
  @inlinable @inline(__always)
  public init(minimumCapacity: Int) {
    self.init(__tree_: .create(minimumCapacity: minimumCapacity))
  }
}

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiSet {

    /// - Complexity: O(*n* log *n*)
    ///   When inserting elements sequentially from an already sorted sequence,
    ///   no search is required, and rebalancing is amortized O(1),
    ///   so the overall construction cost becomes O(*n*).
    @inlinable
    public init<Source>(_ sequence: __owned Source)
    where Element == Source.Element, Source: Sequence {
      self.init(
        __tree_:
          .___insert_range_multi(
            tree: .create(),
            sequence))
    }

    /// - Complexity: O(*n* log *n*)
    ///   When inserting elements sequentially from an already sorted sequence,
    ///   no search is required, and rebalancing is amortized O(1),
    ///   so the overall construction cost becomes O(*n*).
    @inlinable
    public init<Source>(_ collection: __owned Source)
    where Element == Source.Element, Source: Collection {
      self.init(
        __tree_:
          .___insert_range_multi(
            tree: .create(minimumCapacity: collection.count),
            collection))
    }
  }
#endif

extension RedBlackTreeMultiSet {

  /// - Important: This implementation assumes ascending order and omits certain checks.
  ///   Using it with descending order results in undefined behavior.
  /// - Complexity: Amortized O(*n*).
  @inlinable
  public init<R>(_ range: __owned R)
  where R: RangeExpression, R: Collection, R.Element == Element {
    precondition(range is Range<Element> || range is ClosedRange<Element>)
    self.init(__tree_: .create(range: range))
  }
}

// MARK: -

extension RedBlackTreeMultiSet {

  @inlinable
  public mutating func reserveCapacity(_ minimumCapacity: Int) {
    __tree_.ensureUniqueAndCapacity(to: minimumCapacity)
  }
}

// MARK: - Inspecting a MultiSet

extension RedBlackTreeMultiSet {

  /// - Complexity: O(1)
  @inlinable
  public var capacity: Int {
    __tree_.capacity
  }
}

extension RedBlackTreeMultiSet {

  /// - Complexity: O(1)
  @inlinable
  public var isEmpty: Bool {
    count == 0
  }

  /// - Complexity: O(1)
  @inlinable
  public var count: Int {
    __tree_.count
  }
}

extension RedBlackTreeMultiSet {

  /// - Complexity: O(log *n* + *k*)
  @inlinable
  public func count(of element: Element) -> Int {
    __tree_.__count_multi(element)
  }
}

// MARK: - Testing for Membership

extension RedBlackTreeMultiSet {

  /// - Complexity: O(*n*)
  @inlinable
  public func contains(_ member: Element) -> Bool {
    __tree_.__count_unique(member) != 0
  }
}

// MARK: - Accessing Elements

extension RedBlackTreeMultiSet {

  /// - Complexity: O(1)。
  @inlinable
  @inline(__always)
  public var first: Element? {
    isEmpty ? nil : __tree_[_unsafe_raw: _start]
  }

  /// - Complexity: O(log *n*)
  @inlinable
  public var last: Element? {
    isEmpty ? nil : __tree_[_unsafe_raw: __tree_.__tree_prev_iter(_end)]
  }
}

// MARK: - Range Accessing Elements

// MARK: - Insert

extension RedBlackTreeMultiSet {

  /// - Complexity: O(log *n*)
  @inlinable
  @inline(__always)
  @discardableResult
  public mutating func insert(_ newMember: Element) -> (
    inserted: Bool, memberAfterInsert: Element
  ) {
    __tree_.ensureUniqueAndCapacity()
    _ = __tree_.__insert_multi(newMember)
    return (true, newMember)
  }
}

// MARK: - Combining MultiSet

extension RedBlackTreeMultiSet {

  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  ///
  /// - Important: If sufficient space is available,
  ///   using `meld` is recommended.
  @inlinable
  public mutating func insert(contentsOf other: RedBlackTreeSet<Element>) {
    __tree_.ensureUnique { __tree_ in
      .___insert_range_multi(
        tree: __tree_,
        other: other.__tree_,
        other.__tree_.__begin_node_,
        other.__tree_.__end_node)
    }
  }

  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  @inlinable
  public mutating func insert(contentsOf other: RedBlackTreeMultiSet<Element>) {
    __tree_.ensureUnique { __tree_ in
      .___insert_range_multi(
        tree: __tree_,
        other: other.__tree_,
        other.__tree_.__begin_node_,
        other.__tree_.__end_node)
    }
  }

  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  @inlinable
  public mutating func insert<S>(contentsOf other: S) where S: Sequence, S.Element == Element {
    __tree_.ensureUnique { __tree_ in
      .___insert_range_multi(tree: __tree_, other)
    }
  }

  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  @inlinable
  public func inserting(contentsOf other: RedBlackTreeSet<Element>) -> Self {
    var result = self
    result.insert(contentsOf: other)
    return result
  }

  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  ///
  /// - Important: If sufficient space is available,
  ///   using `melding` is recommended.
  @inlinable
  public func inserting(contentsOf other: RedBlackTreeMultiSet<Element>) -> Self {
    var result = self
    result.insert(contentsOf: other)
    return result
  }

  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  @inlinable
  public func inserting<S>(contentsOf other: __owned S) -> Self
  where S: Sequence, S.Element == Element {
    var result = self
    result.insert(contentsOf: other)
    return result
  }
}

extension RedBlackTreeMultiSet {

  /// - Complexity: O(*n* + *m*)
  @inlinable
  @inline(__always)
  public mutating func meld(_ other: __owned RedBlackTreeMultiSet<Element>) {
    __tree_ = __tree_.___meld_multi(other.__tree_)
  }

  /// - Complexity: O(*n* + *m*)
  @inlinable
  @inline(__always)
  public func melding(_ other: __owned RedBlackTreeMultiSet<Element>)
    -> RedBlackTreeMultiSet<Element>
  {
    var result = self
    result.meld(other)
    return result
  }
}

// MARK: - Remove

extension RedBlackTreeMultiSet {

  /// - Complexity: Amortized O(1)
  @inlinable
  @inline(__always)
  public mutating func popFirst() -> Element? {
    __tree_.ensureUnique()
    return ___remove_first()?.payload
  }
}

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiSet {

    /// - Complexity: O(log `count`)
    @inlinable
    public mutating func popLast() -> Element? {
      __tree_.ensureUnique()
      return ___remove_last()?.payload
    }
  }
#endif

extension RedBlackTreeMultiSet {

  /// - Important: Indices that refer to removed members become invalid.
  /// - Complexity: Amortized O(1)
  @inlinable
  @inline(__always)
  @discardableResult
  public mutating func removeFirst() -> Element {
    __tree_.ensureUnique()
    guard let element = ___remove_first() else {
      preconditionFailure(.emptyFirst)
    }
    return element.payload
  }

  /// - Important: Indices that refer to removed members become invalid.
  /// - Complexity: O(log *n*)
  @inlinable
  @discardableResult
  public mutating func removeLast() -> Element {
    __tree_.ensureUnique()
    guard let element = ___remove_last() else {
      preconditionFailure(.emptyFirst)
    }
    return element.payload
  }
}

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiSet {

    /// - Important: After removal, indices become invalid.
    /// - Complexity: Amortized O(1)
    @inlinable
    @discardableResult
    public mutating func remove(at index: Index) -> Element {
      __tree_.ensureUnique()
      guard let __p = __tree_.__purified_(index).pointer else {
        fatalError(.invalidIndex)
      }
      return __tree_._unchecked_remove(at: __p).payload
    }
  }
#endif

extension RedBlackTreeMultiSet {

  /// - Complexity: O(1)
  @inlinable
  public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
    if keepCapacity {
      __tree_.ensureUnique()
      __tree_.deinitialize()
    } else {
      self = .init()
    }
  }
}

// MARK: Finding Elements

extension RedBlackTreeMultiSet {

  /// - Complexity: O(*n*)
  ///
  /// If O(1) is required, `first` provides an equivalent operation in O(1).
  @inlinable
  public func min() -> Element? {
    __tree_.___min()
  }

  /// - Complexity: O(*n*)
  @inlinable
  public func max() -> Element? {
    __tree_.___max()
  }
}

// MARK: - Transformation

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiSet {

    /// - Complexity: O(*n*)
    @inlinable
    public func filter(
      _ isIncluded: (Element) throws -> Bool
    ) rethrows -> Self {
      .init(__tree_: try __tree_.___filter(_start, _end, isIncluded))
    }
  }
#endif

// MARK: - Collection Conformance

// MARK: - Sequence
// MARK: - Collection
// MARK: - BidirectionalCollection

extension RedBlackTreeMultiSet: Sequence {}

extension RedBlackTreeMultiSet {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public func makeIterator() -> Tree._PayloadValues {
    .init(start: _sealed_start, end: _sealed_end, tie: __tree_.tied)
  }
}

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiSet {

    /// - Complexity: O(*n*)
    @inlinable
    @inline(__always)
    public func sorted() -> [Element] {
      __tree_.___copy_all_to_array()
    }

    /// - Complexity: O(`count`)
    @inlinable
    @inline(__always)
    public func reversed() -> [Element] {
      __tree_.___rev_copy_all_to_array()
    }
  }
#endif

// MARK: -

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiSet {

    /// - Important:
    ///   When an element or its corresponding node is removed, any related index becomes invalid.
    ///   Using an invalid index may result in a runtime error or undefined behavior.
    public typealias Index = UnsafeIndexV3
    public typealias SubSequence = RedBlackTreeKeyOnlyRangeView<Base>
  }

  extension RedBlackTreeMultiSet {

    @inlinable
    func ___index(_ p: _SealedPtr) -> UnsafeIndexV3 {
      p.band(__tree_.tied)
    }

    @inlinable
    func ___index_or_nil(_ p: _SealedPtr) -> UnsafeIndexV3? {
      p.exists ? p.band(__tree_.tied) : nil
    }
  }

  extension RedBlackTreeMultiSet {
    /// - Complexity: O( log `count` )
    @inlinable
    public func firstIndex(of member: Element) -> Index? {
      ___index_or_nil(__tree_.find(member).sealed)
    }
  }

  extension RedBlackTreeMultiSet {

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public var startIndex: Index { ___index(_sealed_start) }

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public var endIndex: Index { ___index(_sealed_end) }
  }

  extension RedBlackTreeMultiSet {

    /// - Complexity: O(log *n* + *k*)
    @inlinable
    @inline(__always)
    public func distance(from start: Index, to end: Index)
      -> Int
    {
      guard
        let d = __tree_.___distance(
          from: __tree_.__purified_(start),
          to: __tree_.__purified_(end))
      else { fatalError(.invalidIndex) }
      return d
    }
  }

  extension RedBlackTreeMultiSet {

    /// Returns the index of the first element that is not less than the given value.
    ///
    /// `lowerBound(_:)` returns the first position (`Index`) where the value is
    /// greater than or equal to the specified element `member`.
    ///
    /// For example, given a sorted sequence `[1, 3, 5, 7, 9]`:
    /// - `lowerBound(0)` returns the position of the first element `1` (i.e. `startIndex`).
    /// - `lowerBound(3)` returns the position of element `3`.
    /// - `lowerBound(4)` returns the position of element `5` (the first value ≥ `4`).
    /// - `lowerBound(10)` returns `endIndex`.
    ///
    /// - Parameter member: The element to search for using binary search.
    /// - Returns: The first `Index` whose value is greater than or equal to `member`.
    /// - Complexity: O(log *n*), where *n* is the number of elements.
    @inlinable
    public func lowerBound(_ member: Element) -> Index {
      ___index(__tree_.lower_bound(member).sealed)
    }

    /// Returns the index of the first element that is greater than the given value.
    ///
    /// `upperBound(_:)` returns the first position (`Index`) where the value is
    /// strictly greater than the specified element `member`.
    ///
    /// For example, given a sorted sequence `[1, 3, 5, 5, 7, 9]`:
    /// - `upperBound(3)` returns the position of element `5`
    ///   (the first value greater than `3`).
    /// - `upperBound(5)` returns the position of element `7`
    ///   (elements equal to `5` are excluded, so it points just after them).
    /// - `upperBound(9)` returns `endIndex`.
    ///
    /// - Parameter member: The element to search for using binary search.
    /// - Returns: The first `Index` whose value is strictly greater than `member`.
    /// - Complexity: O(log *n*), where *n* is the number of elements.
    @inlinable
    public func upperBound(_ member: Element) -> Index {
      ___index(__tree_.upper_bound(member).sealed)
    }
  }

  extension RedBlackTreeMultiSet {

    /// - Complexity: O( log `count` )
    @inlinable
    public func find(_ member: Element) -> Index {
      ___index(__tree_.find(member).sealed)
    }
  }

  extension RedBlackTreeMultiSet {

    /// - Complexity: O(log *n*), where *n* is the number of elements.
    @inlinable
    public func equalRange(_ element: Element) -> UnsafeIndexV3Range {
      let (lower, upper) = __tree_.__equal_range_multi(element)
      return .init(.init(lowerBound: ___index(lower.sealed), upperBound: ___index(upper.sealed)))
    }
  }

  extension RedBlackTreeMultiSet {

    /// - Complexity: O(1)
    @inlinable
    public func index(before i: Index) -> Index {
      __tree_.__purified_(i)
        .flatMap { ___tree_prev_iter($0.pointer) }
        .flatMap { $0.sealed.band(__tree_.tied) }
    }

    /// - Complexity: O(1)
    @inlinable
    public func index(after i: Index) -> Index {
      __tree_.__purified_(i)
        .flatMap { ___tree_next_iter($0.pointer) }
        .flatMap { $0.sealed.band(__tree_.tied) }
    }

    /// - Complexity: O(`distance`)
    @inlinable
    public func index(_ i: Index, offsetBy distance: Int)
      -> Index
    {
      __tree_.__purified_(i)
        .flatMap { ___tree_adv_iter($0.pointer, distance) }
        .flatMap { $0.sealed.band(__tree_.tied) }
    }

    /// - Complexity: O(`distance`)
    @inlinable
    public func index(
      _ i: Index, offsetBy distance: Int, limitedBy limit: Index
    )
      -> Index?
    {
      var i = i
      let result = formIndex(&i, offsetBy: distance, limitedBy: limit)
      return result ? i : nil
    }
  }

  extension RedBlackTreeMultiSet {

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public func formIndex(before i: inout Index) {
      i = index(before: i)
    }

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public func formIndex(after i: inout Index) {
      i = index(after: i)
    }

    /// - Complexity: O(*d*)
    @inlinable
    //  @inline(__always)
    public func formIndex(_ i: inout Index, offsetBy distance: Int) {
      i = index(i, offsetBy: distance)
    }

    /// - Complexity: O(*d*)
    @inlinable
    @inline(__always)
    public func formIndex(
      _ i: inout Index,
      offsetBy distance: Int,
      limitedBy limit: Index
    )
      -> Bool
    {
      guard let ___i = __tree_.__purified_(i).pointer
      else { return false }

      let __l = __tree_.__purified_(limit).map(\.pointer)

      return ___form_index(___i, offsetBy: distance, limitedBy: __l) {
        i = $0.flatMap { $0.sealed.band(__tree_.tied) }
      }
    }
  }
#endif

// MARK: -

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiSet {

    /// Returns whether the index can be used with subscript or remove operations.
    ///
    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public func isValid(_ index: Index) -> Bool {
      __tree_.__purified_(index).exists
    }
  }

  extension RedBlackTreeMultiSet {

    /// - Complexity: O(1)
    @inlinable
    public subscript(position: Index) -> Element {
      @inline(__always) get {
        __tree_[_unsafe: __tree_.__purified_(position)]
      }
    }
  }

  extension RedBlackTreeMultiSet {

    @discardableResult
    @inlinable @inline(__always)
    public mutating func erase(_ ptr: Index) -> Index {
      ___index(__tree_.erase(__tree_.__purified_(ptr).pointer!).sealed)
    }
  }

  extension RedBlackTreeMultiSet {

    @inlinable
    public mutating func erase(where shouldBeRemoved: (Element) throws -> Bool) rethrows {
      __tree_.ensureUnique()
      let result = try __tree_.___erase_if(
        __tree_.__begin_node_.sealed,
        __tree_.__end_node.sealed,
        shouldBeRemoved)
      if case .failure(let e) = result {
        fatalError(e.localizedDescription)
      }
    }
  }
#endif

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiSet {

    /// - Important: Indices that refer to removed members become invalid.
    /// - Complexity: O(log *n*)
    @inlinable
    @inline(__always)
    @discardableResult
    public mutating func eraseUnique(_ member: Element) -> Bool {
      __tree_._strongEnsureUnique()
      return __tree_.___erase_unique(member)
    }
  }

  extension RedBlackTreeMultiSet {

    // TODO: イテレータ利用の注意をドキュメントすること
    /// - Important: Indices that refer to removed members become invalid.
    /// - Complexity: O(log *n* : *k*)
    @inlinable
    @discardableResult
    public mutating func eraseMulti(_ member: Element) -> Int {
      __tree_._strongEnsureUnique()
      return __tree_.___erase_multi(member)
    }
  }
#endif

// MARK: - Protocol Conformance

// MARK: - ExpressibleByArrayLiteral

extension RedBlackTreeMultiSet: ExpressibleByArrayLiteral {

  /// - Complexity: O(*n* log *n*)
  @inlinable
  @inline(__always)
  public init(arrayLiteral elements: Element...) {
    self.init(elements)
  }
}

// MARK: - CustomStringConvertible

extension RedBlackTreeMultiSet: CustomStringConvertible {

  @inlinable
  public var description: String {
    _arrayDescription(for: self)
  }
}

// MARK: - CustomDebugStringConvertible

extension RedBlackTreeMultiSet: CustomDebugStringConvertible {

  public var debugDescription: String {
    description
  }
}

// MARK: - CustomReflectable

extension RedBlackTreeMultiSet: CustomReflectable {
  /// The custom mirror for this instance.
  public var customMirror: Mirror {
    Mirror(self, unlabeledChildren: self + [], displayStyle: .set)
  }
}

// MARK: - Is Identical To

extension RedBlackTreeMultiSet {

  /// Returns a boolean value indicating whether this set is identical to
  /// `other`.
  ///
  /// Two set values are identical if there is no way to distinguish between
  /// them.
  ///
  /// For any values `a`, `b`, and `c`:
  ///
  /// - `a.isTriviallyIdentical(to: a)` is always `true`. (Reflexivity)
  /// - `a.isTriviallyIdentical(to: b)` implies `b.isTriviallyIdentical(to: a)`. (Symmetry)
  /// - If `a.isTriviallyIdentical(to: b)` and `b.isTriviallyIdentical(to: c)` are both `true`,
  ///   then `a.isTriviallyIdentical(to: c)` is also `true`. (Transitivity)
  /// - `a.isTriviallyIdentical(b)` implies `a == b`
  ///   - `a == b` does not imply `a.isTriviallyIdentical(b)`
  ///
  /// Values produced by copying the same value, with no intervening mutations,
  /// will compare identical:
  ///
  /// ```swift
  /// let d = c
  /// print(c.isTriviallyIdentical(to: d))
  /// // Prints true
  /// ```
  ///
  /// Comparing sets this way includes comparing (normally) hidden
  /// implementation details such as the memory location of any underlying set
  /// storage object. Therefore, identical sets are guaranteed to compare equal
  /// with `==`, but not all equal sets are considered identical.
  ///
  /// - Performance: O(1)
  @inlinable
  @inline(__always)
  public func isTriviallyIdentical(to other: Self) -> Bool {
    __tree_._isIdentical(to: other.__tree_)
  }
}

// MARK: - Equatable

extension RedBlackTreeMultiSet: Equatable {

  /// - Complexity: O(*m*), where *m* is the lesser of the length of `lhs` and `rhs`.
  @inlinable
  @inline(__always)
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.__tree_ == rhs.__tree_
  }
}

// MARK: - Comparable

extension RedBlackTreeMultiSet: Comparable {

  /// - Complexity: O(*m*), where *m* is the lesser of the length of `lhs` and `rhs`.
  @inlinable
  @inline(__always)
  public static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.__tree_ < rhs.__tree_
  }
}

// MARK: - Hashable

extension RedBlackTreeMultiSet: Hashable where Element: Hashable {

  @inlinable
  @inline(__always)
  public func hash(into hasher: inout Hasher) {
    hasher.combine(__tree_)
  }
}

// MARK: - Sendable

#if swift(>=5.5)
  extension RedBlackTreeMultiSet: @unchecked Sendable
  where Element: Sendable {}
#endif

// MARK: - Codable

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiSet: Encodable where Element: Encodable {

    @inlinable
    public func encode(to encoder: Encoder) throws {
      var container = encoder.unkeyedContainer()
      for element in self {
        try container.encode(element)
      }
    }
  }

  extension RedBlackTreeMultiSet: Decodable where Element: Decodable {

    @inlinable
    public init(from decoder: Decoder) throws {
      self.init(__tree_: try .create(from: decoder))
    }
  }
#endif

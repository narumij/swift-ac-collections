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

/// # RedBlackTreeSet
///
/// `RedBlackTreeSet` is an **ordered unique set** implemented using a red-black tree.
/// Elements are always kept in sorted order.
///
/// ```swift
/// var set: RedBlackTreeSet<Int> = []
/// set.insert(3) // -> [3]
/// set.insert(1) // -> [1, 3]
/// set.insert(4) // -> [1, 3, 4]
/// set.insert(1) // -> [1, 3, 4]
/// set.insert(5) // -> [1, 3, 4, 5]
/// ```
///
/// ## Removal
///
/// Both single-element removal and range removal are supported.
///
/// ```swift
/// var set: RedBlackTreeSet<Int> = [1, 3, 4, 5]
/// set.remove(3) // -> [1, 4, 5]
/// ```
///
/// Avoid performing repeated removals via indices in a `for` loop.
/// Since indices are tightly coupled with tree nodes, removing an element
/// invalidates the operation that retrieves the next index.
/// Use the range-removal APIs for consecutive deletions instead.
///
/// ```swift
/// var set: RedBlackTreeSet<Int> = [1, 3, 4, 5]
/// set[set.lowerBound(4)..<set.endIndex].erase() // -> [1, 3]
/// ```
///
/// ```swift
/// var set: RedBlackTreeSet<Int> = [1, 3, 4, 5]
/// set.erase(set.lowerBound(4)..<set.endIndex) // -> [1, 3]
/// ```
///
/// As in C++, sequential removal using `erase(_:) -> Index` is also supported.
/// You can remove elements while receiving the next index.
///
/// ```swift
/// var set: RedBlackTreeSet<Int> = [1, 3, 4, 5]
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
/// var set: RedBlackTreeSet<Int> = [1, 3, 4, 5]
/// print(set[.start.advance(by: 1)]) // -> 3
/// ```
///
/// ```swift
/// var set: RedBlackTreeSet<Int> = [1, 3, 4, 5]
/// print(set[.lowerBound(5)]) // -> 5
/// print(set[.upperBound(5)]) // -> nil (equivalent to end)
/// print(set[.find(2)]) // -> nil (not found)
/// ```
///
/// - Important: `RedBlackTreeDictionary` is not thread-safe.
@frozen
public struct RedBlackTreeSet<Element: Comparable> {

  public
    typealias Element = Element

  @usableFromInline
  var __tree_: Tree

  @inlinable @inline(__always)
  package init(__tree_: Tree) {
    self.__tree_ = __tree_
  }
}

extension RedBlackTreeSet {
  @frozen
  public enum Base {
    public typealias _Key = Element
    public typealias _PayloadValue = Element
  }
}

extension RedBlackTreeSet.Base: CompareUniqueTrait {}
extension RedBlackTreeSet.Base: ScalarValueTrait & _UnsafeNodePtrType {}
extension RedBlackTreeSet.Base: _ScalarBasePayload_KeyProtocol_ptr {}
extension RedBlackTreeSet.Base: _BaseNode_NodeCompareProtocol {}

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeSet: _RedBlackTreeKeyOnlyV2 {}
#endif

// MARK: - Inspecting a Set

extension RedBlackTreeSet {

  /// - Complexity: O(1)
  @inlinable
  public var capacity: Int {
    __tree_.capacity
  }
}

extension RedBlackTreeSet {

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

extension RedBlackTreeSet {

  /// - Complexity: O(log `count`)
  @inlinable
  public func count(of element: Element) -> Int {
    __tree_.__count_unique(element)
  }
}

// MARK: - Testing for Membership

extension RedBlackTreeSet {

  /// - Complexity: O(log *n*), where *n* is the number of elements.
  @inlinable
  @inline(never)
  public func contains(_ member: Element) -> Bool {
    __tree_.read { $0.__count_unique(member) != 0 }
  }
}

// MARK: - Accessing Elements

extension RedBlackTreeSet {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public var first: Element? {
    isEmpty ? nil : __tree_[_unsafe_raw: _start]
  }

  /// - Complexity: O(log `count`)
  @inlinable
  public var last: Element? {
    isEmpty ? nil : __tree_[_unsafe_raw: __tree_.__tree_prev_iter(_end)]
  }
}

// MARK: - Insertion

extension RedBlackTreeSet {

  /// - Complexity: O(log *n*), where *n* is the number of elements.
  @inlinable
  @discardableResult
  public mutating func insert(_ newMember: Element) -> (
    inserted: Bool, memberAfterInsert: Element
  ) {
    __tree_.ensureUniqueAndCapacity()
    let (__r, __inserted) = __tree_.update { $0.__insert_unique(newMember) }
    return (__inserted, __inserted ? newMember : __tree_[_unsafe_raw: __r])
  }

  /// - Complexity: O(log *n*), where *n* is the number of elements.
  @inlinable
  @inline(__always)
  @discardableResult
  public mutating func update(with newMember: Element) -> Element? {
    __tree_.ensureUniqueAndCapacity()
    let (__r, __inserted) = __tree_.update { $0.__insert_unique(newMember) }
    guard !__inserted else { return nil }
    let oldMember = __tree_[_unsafe_raw: __r]
    __tree_[_unsafe_raw: __r] = newMember
    return oldMember
  }
}

// MARK: - Removal

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeSet {

    /// - Complexity: Amortized O(1)
    @inlinable
    public mutating func popFirst() -> Element? {
      __tree_.ensureUnique()
      return ___remove_first()?.payload
    }

    /// - Complexity: O(log `count`)
    @inlinable
    public mutating func popLast() -> Element? {
      __tree_.ensureUnique()
      return ___remove_last()?.payload
    }
  }
#endif

extension RedBlackTreeSet {

  /// - Important: Indices that refer to removed members become invalid.
  /// - Complexity: Amortized O(1)
  @inlinable
  @discardableResult
  public mutating func removeFirst() -> Element {
    __tree_.ensureUnique()
    guard let element = ___remove_first() else {
      preconditionFailure(.emptyFirst)
    }
    return element.payload
  }
}

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeSet {

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
#endif

extension RedBlackTreeSet {

  /// - Important: Indices that refer to removed members become invalid.
  /// - Complexity: O(log *n*), where *n* is the number of elements.
  @inlinable
  @discardableResult
  public mutating func remove(_ member: Element) -> Element? {
    __tree_.ensureUnique()
    return __tree_.update { $0.___erase_unique(member) } ? member : nil
  }
}

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeSet {

    /// - Important: Indices that refer to removed members become invalid.
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

extension RedBlackTreeSet {

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

// MARK: -

extension RedBlackTreeSet {

  /// - Complexity: O(log *n*), where *n* is the number of elements.
  ///
  /// If O(1) is required, `first` provides an equivalent operation in O(1).
  @inlinable
  public func min() -> Element? {
    __tree_.___min()
  }

  /// - Complexity: O(log *n*), where *n* is the number of elements.
  @inlinable
  public func max() -> Element? {
    __tree_.___max()
  }
}

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeSet {

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

  extension RedBlackTreeSet {

    /// - Complexity: O( log `count` )
    @inlinable
    public func find(_ member: Element) -> Index {
      ___index(__tree_.find(member).sealed)
    }
  }

  extension RedBlackTreeSet {

    /// - Complexity: O(log *n*), where *n* is the number of elements.
    @inlinable
    public func equalRange(_ element: Element) -> UnsafeIndexV3Range {
      let (lower, upper) = __tree_.__equal_range_unique(element)
      return .init(.init(lowerBound: ___index(lower.sealed), upperBound: ___index(upper.sealed)))
    }
  }
#endif

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeSet {

    /// - Complexity: Amortized O(1)
    @discardableResult
    @inlinable @inline(__always)
    public mutating func erase(_ ptr: Index) -> Index {
      ___index(__tree_.erase(__tree_.__purified_(ptr).pointer!).sealed)
    }
  }

  extension RedBlackTreeSet {

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

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

  @usableFromInline
  var __tree_: Tree

  @inlinable @inline(__always)
  internal init(__tree_: Tree) {
    self.__tree_ = __tree_
  }
}

extension RedBlackTreeMultiSet {
  @frozen
  public enum Base {
    public typealias _Key = Element
    public typealias _PayloadValue = Element
  }
}

extension RedBlackTreeMultiSet.Base: CompareMultiTrait {}
extension RedBlackTreeMultiSet.Base: ScalarValueTrait {}
extension RedBlackTreeMultiSet.Base: _ScalarBasePayload_KeyProtocol_ptr {}
extension RedBlackTreeMultiSet.Base: _BaseNode_NodeCompareProtocol {}

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiSet: _RedBlackTreeKeyOnlyV2 {}
#endif

// MARK: - Inspecting a MultiSet

extension RedBlackTreeMultiSet {

  /// The total number of elements that the multi set can contain without allocating new storage.
  ///
  /// - Complexity: O(1)
  @inlinable
  public var capacity: Int {
    __tree_.capacity
  }
}

extension RedBlackTreeMultiSet {

  /// A Boolean value that indicates whether the multi set is empty.
  ///
  /// - Complexity: O(1)
  @inlinable
  public var isEmpty: Bool {
    count == 0
  }

  /// The number of elements in the multi set.
  ///
  /// - Complexity: O(1)
  @inlinable
  public var count: Int {
    __tree_.count
  }
}

extension RedBlackTreeMultiSet {

  /// Returns the number of elements equal to the given value.
  ///
  /// - Complexity: O(log `count` + `distance`), where `distance` is the number of matching elements.
  @inlinable
  public func count(of element: Element) -> Int {
    __tree_.__count_multi(element)
  }
}

// MARK: - Testing for Membership

extension RedBlackTreeMultiSet {

  /// Returns a Boolean value that indicates whether the given element exists in the set.
  ///
  /// - Complexity: O(log `count`)
  @inlinable
  public func contains(_ member: Element) -> Bool {
    __tree_.__count_unique(member) != 0
  }
}

// MARK: - Accessing Elements

extension RedBlackTreeMultiSet {

  /// The first element of the collection.
  ///
  /// - Complexity: O(1)。
  @inlinable
  @inline(__always)
  public var first: Element? {
    isEmpty ? nil : __tree_[_unsafe_raw: _start]
  }

  /// The last element of the collection.
  ///
  /// - Complexity: O(log `count`)
  @inlinable
  public var last: Element? {
    isEmpty ? nil : __tree_[_unsafe_raw: __tree_.__tree_prev_iter(_end)]
  }
}

extension RedBlackTreeMultiSet {

  /// Returns the minimum element in the sequence.
  ///
  /// - Complexity: O(*n*)
  ///
  /// If O(1) is required, `first` provides an equivalent operation in O(1).
  @inlinable
  public func min() -> Element? {
    __tree_.___min()
  }

  /// Returns the maximum element in the sequence.
  ///
  /// - Complexity: O(*n*)
  @inlinable
  public func max() -> Element? {
    __tree_.___max()
  }
}

// MARK: - Insertion

extension RedBlackTreeMultiSet {

  /// Inserts the given element in the set if it is not already present.
  ///
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

// MARK: - Remove

extension RedBlackTreeMultiSet {

  /// Removes and returns the first element of the collection.
  ///
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

    /// Removes and returns the last element of the collection.
    ///
    /// - Complexity: O(log `count`)
    @inlinable
    public mutating func popLast() -> Element? {
      __tree_.ensureUnique()
      return ___remove_last()?.payload
    }
  }
#endif

extension RedBlackTreeMultiSet {

  /// Removes the first element of the collection.
  ///
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

  /// Removes the last element of the collection.
  ///
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

    /// Removes the element at the given index of the set.
    ///
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

  /// Removes all members from the set.
  ///
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

// MARK: - Transformation

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiSet {

    /// Removes the element at the given position from the set and returns the index of the next element.
    ///
    /// - Complexity: Amortized O(1)
    @discardableResult
    @inlinable @inline(__always)
    public mutating func erase(_ ptr: Index) -> Index {
      ___index(__tree_.erase(__tree_.__purified_(ptr).pointer!).sealed)
    }
  }

  extension RedBlackTreeMultiSet {

    /// Removes all elements that satisfy the given predicate.
    ///
    /// - Complexity: O(n log n)
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

    /// Removes a single element equivalent to the given key.
    ///
    /// If multiple elements with an equivalent key exist, an arbitrary one is removed.
    ///
    /// - Parameter member: The key of the element to remove.
    /// - Returns: `true` if an element was removed; otherwise `false`.
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

    /// Removes all elements equivalent to the given key.
    ///
    /// - Parameter member: The key of the elements to remove.
    /// - Returns: The number of elements removed.
    /// - Complexity: O(log `count` + `distance`), where `distance` is the number of removed elements.
    @inlinable
    @discardableResult
    public mutating func eraseMulti(_ member: Element) -> Int {
      __tree_._strongEnsureUnique()
      return __tree_.___erase_multi(member)
    }
  }
#endif

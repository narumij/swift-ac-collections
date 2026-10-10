//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-ac-collections project.
//
// Copyright (c) 2024-2026 narumij.
// Licensed under the Apache License v2.0.
//
// SPDX-License-Identifier: Apache-2.0
//
// This implementation includes code derived from LLVM libc++'s red-black tree
// implementation, originally distributed under the Apache License v2.0 with
// LLVM Exceptions.
//
// Copyright © 2003-2026 The LLVM Project.
// Licensed under the Apache License v2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by
// narumij.
//
//===----------------------------------------------------------------------===//

// 先頭ドキュメントは学習用途を想定し、実用的な使い方と誤用防止を優先して簡潔に記述する。

/// # RedBlackTreeMultiSet
///
/// `RedBlackTreeMultiSet` is a **sorted multiset (allowing duplicates)**
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
/// print(set[.start.advanced(by: 1)]) // -> 1
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
  package var __tree_: Tree

  @inlinable
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

extension RedBlackTreeMultiSet.Base: MultiMultiplicity {}
extension RedBlackTreeMultiSet.Base: ScalarValueTrait {}
extension RedBlackTreeMultiSet.Base: _ScalarBasePayload_KeyProtocol_ptr {}
extension RedBlackTreeMultiSet.Base: _BaseNode_NodeCompareProtocol {}
extension RedBlackTreeMultiSet.Base: _BaseNode_SignedDistanceProtocol {}

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
  /// - Parameter element: The element to count.
  /// - Returns: The number of occurrences of `element` in the multiset.
  /// - Complexity: O(log `count` + `distance`), where `distance` is the number of matching elements.
  @inlinable
  public func count(of element: Element) -> Int {
    __tree_.update { $0.__count_multi(element) }
  }
}

// MARK: - Testing for Membership

extension RedBlackTreeMultiSet {

  /// Returns a Boolean value that indicates whether the given element exists in the multiset.
  ///
  /// - Parameter element: The element to look for.
  /// - Returns: `true` if the multiset contains at least one occurrence of `element`; otherwise, `false`.
  /// - Complexity: O(log `count`)
  @inlinable
  public func contains(_ element: Element) -> Bool {
    __tree_.update { $0.__count_unique(element) != 0 }
  }
}

// MARK: - Accessing Elements

extension RedBlackTreeMultiSet {

  /// The first element of the collection.
  ///
  /// - Complexity: O(1)。
  @inlinable
  public var first: Element? {
    isEmpty ? nil : Base.__payload_(_start)
  }

  /// The last element of the collection.
  ///
  /// - Complexity: O(log `count`)
  @inlinable
  public var last: Element? {
    __tree_.___max()
  }
}

extension RedBlackTreeMultiSet {

  /// Returns the minimum element in the sequence.
  ///
  /// - Complexity: O(1)。
  @inlinable
  public func min() -> Element? {
    isEmpty ? nil : Base.__payload_(_start)
  }

  /// Returns the maximum element in the sequence.
  ///
  /// - Complexity: O(log `count`)
  @inlinable
  public func max() -> Element? {
    __tree_.___max()
  }
}

// MARK: - Insertion

extension RedBlackTreeMultiSet {

  /// Inserts the given element into the multiset, including when an equivalent element is already present.
  ///
  /// - Parameter newMember: An element to insert.
  /// - Returns: `(true, newMember)`; a multiset always inserts another occurrence.
  /// - Complexity: O(log *n*)
  /// - SeeAlso: `index(inserting:)`, which also returns the index of the inserted or existing element.
  @inlinable
  @discardableResult
  public mutating func insert(_ newMember: Element) -> (
    inserted: Bool, memberAfterInsert: Element
  ) {
    __tree_.ensureUniqueAndCapacity()
    _ = __tree_.update { $0.__insert_multi(newMember) }
    return (true, newMember)
  }
}

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiSet {

    /// Replaces the element at `i` when it is equivalent to `newMember`.
    ///
    /// Requiring equivalence preserves the multiset's sorted order.
    ///
    /// - Parameters:
    ///   - newMember: The replacement element.
    ///   - i: The index of the element to replace.
    /// - Returns: The replaced element, or `nil` if the index is invalid or the elements aren't equivalent.
    @inlinable
    public mutating func update(_ newMember: Element, at i: Index) -> Element? {
      __tree_.ensureUnique()
      let __i = __tree_.__purified_(i)
      guard
        __i.accessible.error == nil,
        let i = __i.pointer
      else {
        return nil
      }

      let oldMember = Base.__key_(i)
      guard oldMember == newMember else {
        return nil
      }

      Base.__key_ptr(i).pointee = newMember
      return oldMember
    }

  }
#endif

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiSet {

    /// Inserts another occurrence, using `hint` as a suggested insertion position.
    ///
    /// When `hint` is usable, the new occurrence is inserted at that position,
    /// including within a group of equivalent elements. Otherwise, the hint affects
    /// only performance.
    /// `endIndex` is a valid hint.
    ///
    /// - Parameters:
    ///   - newMember: An element to insert.
    ///   - hint: A valid index of this multiset to use as an insertion hint.
    /// - Returns: The index of the newly inserted occurrence.
    /// - Precondition: `hint` is valid for this multiset.
    @inlinable
    @discardableResult
    public mutating func insert(_ newMember: Element, hint: Index) -> Index {
      __tree_.ensureUniqueAndCapacity()
      let p = __tree_.__purified_(hint)
      guard let __p = p.pointer else {
        fatalError(.invalidIndex)
      }
      let __r = __tree_.__emplace_hint_multi(__p, newMember)
      return __tree_.index(__r)
    }
  }
#endif

// MARK: - Remove

extension RedBlackTreeMultiSet {

  /// Removes and returns one least element of the multiset.
  ///
  /// Returns `nil` if the multiset is empty.
  ///
  /// - Returns: The removed element, or `nil` if the multiset was empty.
  /// - Complexity: Amortized O(1)
  @inlinable
  public mutating func popFirst() -> Element? {
    guard __tree_.count > 0 else { return nil }
    __tree_.ensureUnique()
    return __tree_.___unchecked_remove_first()
  }
}

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiSet {

    /// Removes and returns one greatest element of the multiset.
    ///
    /// Returns `nil` if the multiset is empty.
    ///
    /// - Returns: The removed element, or `nil` if the multiset was empty.
    /// - Complexity: O(log `count`)
    @inlinable
    public mutating func popLast() -> Element? {
      guard __tree_.count > 0 else { return nil }
      __tree_.ensureUnique()
      return __tree_.___unchecked_remove_last()
    }
  }
#endif

extension RedBlackTreeMultiSet {

  /// Removes and returns one least element of the multiset.
  ///
  /// - Returns: The removed element.
  /// - Precondition: The multiset isn't empty.
  /// - Complexity: Amortized O(1)
  @inlinable
  @discardableResult
  public mutating func removeFirst() -> Element {
    guard let element = popFirst() else {
      preconditionFailure(.emptyFirst)
    }
    return element
  }
}

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiSet {

    /// Removes and returns one greatest element of the multiset.
    ///
    /// - Returns: The removed element.
    /// - Precondition: The multiset isn't empty.
    /// - Complexity: O(log *n*)
    @inlinable
    @discardableResult
    public mutating func removeLast() -> Element {
      guard let element = popLast() else {
        preconditionFailure(.emptyLast)
      }
      return element
    }
  }
#endif

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiSet {

    /// Removes the element at the given index of the set.
    ///
    /// - Parameter index: A valid index of the multiset. The index must refer
    ///   to an element, not the multiset's `endIndex`.
    /// - Returns: The removed element.
    /// - Precondition: `index` is valid for this multiset and isn't `endIndex`.
    /// - Complexity: Amortized O(1)
    @inlinable
    @discardableResult
    public mutating func remove(at index: Index) -> Element {
      __tree_.ensureUnique()
      guard let __p = __tree_.__purified_(index).accessible.pointer else {
        fatalError(.invalidIndex)
      }
      return __tree_._unchecked_remove(at: __p).payload
    }
  }
#endif

extension RedBlackTreeMultiSet {

  /// Removes all elements from the multiset.
  ///
  /// - Parameter keepCapacity: Pass `true` to retain the multiset's allocated
  ///   storage for later use.
  /// - Complexity: O(*n*), where *n* is the number of elements.
  @inlinable
  public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
    if keepCapacity && __tree_.count > 0 {
      __tree_.ensureUnique()
      __tree_.deinitialize()
    } else if !keepCapacity {
      __tree_ = .create()
    }
  }
}

// MARK: - Transformation

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiSet {

    /// Removes the element at the given position from the set and returns the index of the next element.
    ///
    /// - Parameter ptr: A valid index of the multiset. The index must refer to
    ///   an element, not the multiset's `endIndex`.
    /// - Returns: The index that followed `ptr` before removal, or `endIndex`
    ///   if the removed element was last.
    /// - Precondition: `ptr` is valid for this multiset and isn't `endIndex`.
    /// - Complexity: Amortized O(1)
    @discardableResult
    @inlinable
    public mutating func erase(_ ptr: Index) -> Index {
      ___index(__tree_.erase(__tree_.__purified_(ptr).accessible.pointer!))
    }
  }

  extension RedBlackTreeMultiSet {

    /// Removes all elements that satisfy the given predicate.
    ///
    /// - Parameter shouldBeRemoved: A closure that returns `true` for an
    ///   element that should be removed.
    /// - Complexity: O(n log n)
    @inlinable
    public mutating func erase(where shouldBeRemoved: (Element) throws -> Bool) rethrows {
      guard __tree_.count > 0 else { return }
      __tree_.ensureUnique()
      let result = try __tree_.___erase_range_if(
        __tree_.__begin_node_.unchecked,
        __tree_.__end_node.unchecked,
        shouldBeRemoved)
      assert(result.error == nil)
    }
  }
#endif

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiSet {

    /// Removes a single element equivalent to the given key.
    ///
    /// If multiple elements with an equivalent key exist, an arbitrary one is removed.
    ///
    /// - Parameter member: The element to remove.
    /// - Returns: `true` if an element was removed; otherwise `false`.
    /// - Complexity: O(log *n*)
    @inlinable
    @discardableResult
    public mutating func eraseUnique(_ member: Element) -> Bool {
      __tree_._strongEnsureUnique()
      return __tree_.___erase_unique(member)
    }
  }

  extension RedBlackTreeMultiSet {

    /// Removes all elements equivalent to the given key.
    ///
    /// - Parameter member: The element whose equivalent occurrences are removed.
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

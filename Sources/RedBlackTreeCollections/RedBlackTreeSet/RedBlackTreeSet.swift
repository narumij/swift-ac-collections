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

/// # RedBlackTreeSet
///
/// ## Declaration
///
/// Use `RedBlackTreeSet` with `import AcCollections`. Any declaration below illustrates the type signature rather than a complete executable program.
///
/// ## Overview
///
/// A red-black-tree set that stores unique elements in ascending order. Insertion and removal preserve order, and inserting a duplicate does not add another copy. Unlike the standard `Set`, it supports ordered searches and traversal; unlike an `Array`, it maintains sorting across updates. Use `RedBlackTreeMultiSet` for duplicates. It suits changing sets that need ordered traversal or bound searches.
///
/// Create an empty set, use an array literal, or initialize from an input sequence. Reserve storage with `init(minimumCapacity:)` or `reserveCapacity(_:)`. Normal iteration is ascending; `sorted()` / `reversed()` return ascending / descending arrays.
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
/// ## Searching and Accessing Elements
///
/// `contains(_:)` checks membership and `count(of:)` returns the number of matches. `first` / `last` and `min()` / `max()` access the endpoints. `firstIndex(of:)` returns `nil` when absent; `find(_:)` returns `endIndex`. `lowerBound(_:)` finds the first value greater than or equal to its argument, and `upperBound(_:)` the first strictly greater value; both return the end if none exists. `equalRange(_:)` returns the half-open range of all equivalent elements. Move forward or backward from search results within the endpoint preconditions; the end cannot be dereferenced as an element.
///
/// ## Insertion and Removal
///
/// `insert(_:)` preserves uniqueness and does not add duplicate elements. `remove(_:)` searches for and removes a value. Range removal and removal at a known index are also supported. Do not advance from a deleted index; use the next index returned by `erase(_:) -> Index` for sequential removal.
///
/// ```swift
/// var set: RedBlackTreeSet<Int> = [1, 3, 4, 5]
/// set.remove(3) // -> [1, 4, 5]
/// ```
///
/// ```swift
/// var set: RedBlackTreeSet<Int> = [1, 3, 4, 5]
/// set[.lowerBound(4) ..< .end].erase() // -> [1, 3]
/// ```
///
/// ```swift
/// var set: RedBlackTreeSet<Int> = [1, 3, 4, 5]
/// set.erase(.lowerBound(4) ..< .end) // -> [1, 3]
/// ```
///
/// ```swift
/// var set: RedBlackTreeSet<Int> = [1, 3, 4, 5]
/// var i = set.startIndex
/// while i != set.endIndex {
///   i = set.erase(i)
/// }
/// ```
///
/// ## Set Algebra
///
/// `union` / `formUnion`, `intersection` / `formIntersection`, `difference` / `formDifference`, and `symmetricDifference` / `formSymmetricDifference` compute the union, intersection, difference, and symmetric difference. The `form` variants mutate this set; their counterparts return results.
///
/// ## Indices and Bound Expressions
///
/// An index represents an element position, not an integer offset. Indices support forward and backward movement within their endpoint preconditions. Inserting or deleting other elements preserves an index while its element exists. Deleting that element invalidates the index; reusing its slot does not revive it. In the normal configuration, corresponding positions can be shared across copy-on-write branches, but validity depends on the target’s generation and deletion state. Using an unrelated tree’s index violates a precondition and is not guaranteed to be detected.
///
/// Index-range subscripting returns a view without copying elements into an array. It uses the base’s index type but has its own range and endpoint. A view endpoint can identify an element in the base. Mutation directly through a subscript changes the base; mutation of a view stored separately is isolated through copy-on-write. `containsSubrange(_:)` checks a range, and `distance(from:to:)` accepts indices or bounds.
///
/// `Bound` specifies positions without directly manipulating indices. It provides `.start`, `.last`, `.end`, `.lowerBound`, `.upperBound`, `.find`, `.lessThan` / `.lessThanOrEqual`, `.greaterThan` / `.greaterThanOrEqual`, `.before` / `.after`, and `.advanced(by:limit:)`. A single bound that resolves to the end or no position returns `nil` through subscripting. Invalid or reversed bound ranges return empty views.
///
/// ```swift
/// var set: RedBlackTreeSet<Int> = [1, 3, 4, 5]
/// print(set[.start.advanced(by: 1)]) // Optional containing 3
/// ```
///
/// ```swift
/// var set: RedBlackTreeSet<Int> = [1, 3, 4, 5]
/// print(set[.lowerBound(5)]) // Optional containing 5
/// print(set[.upperBound(5)]) // -> nil (equivalent to end)
/// print(set[.find(2)]) // -> nil (not found)
/// ```
///
/// ## Performance
///
/// These bounds assume constant-time comparisons and element operations, and exclude copying shared storage for copy-on-write. Copying retains deletion history and is not always bounded by the current count alone. Creating a view does not copy elements into an array, but a later mutation can require copy-on-write.
///
/// | Operation | Complexity |
/// | --- | --- |
/// | `isEmpty`, `count`, `startIndex`, `endIndex` | O(1) |
/// | Lookup, lower/upper bound, insertion, lookup and removal of one element | O(log n) |
/// | Removal at a known index; rebalancing | Amortized O(1) |
/// | Union, intersection, difference, symmetric difference | O(n+m) |
///
///
/// ## Red-Black Tree
///
/// A red-black tree is a self-balancing binary search tree that maintains logarithmic height through recoloring and rotations. Logical element order differs from physical memory layout. In duplicate-supporting types, each element still occupies its own node. Nodes are managed in grouped storage rather than requiring a separate allocation for every node.
///
/// ## Important
///
/// This type is not thread-safe and does not protect concurrent access to the same variable. This guide describes the normal configuration.
@frozen
public struct RedBlackTreeSet<Element: Comparable> {

  public
    typealias Element = Element

  @usableFromInline
  package var __tree_: Tree

  @inlinable
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

extension RedBlackTreeSet.Base: UniqueMultiplicity {}
extension RedBlackTreeSet.Base: ScalarValueTrait & _UnsafeNodePtrType {}
extension RedBlackTreeSet.Base: _ScalarBasePayload_KeyProtocol_ptr {}
extension RedBlackTreeSet.Base: _BaseNode_NodeCompareProtocol {}
extension RedBlackTreeSet.Base: _BaseNode_SignedDistanceProtocol {}

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeSet: _RedBlackTreeKeyOnlyV2 {}
#endif

// MARK: - Inspecting a Set

extension RedBlackTreeSet {

  /// The total number of elements that the set can contain without allocating new storage.
  ///
  /// - Complexity: O(1)
  @inlinable
  public var capacity: Int {
    __tree_.capacity
  }
}

extension RedBlackTreeSet {

  /// A Boolean value that indicates whether the set is empty.
  ///
  /// - Complexity: O(1)
  @inlinable
  public var isEmpty: Bool {
    count == 0
  }

  /// The number of elements in the set.
  ///
  /// - Complexity: O(1)
  @inlinable
  public var count: Int {
    __tree_.count
  }
}

extension RedBlackTreeSet {

  /// Returns the number of elements equal to the given value.
  ///
  /// Because a set stores unique elements, the result is either `0` or `1`.
  ///
  /// - Parameter element: The element to count.
  /// - Returns: `1` if the set contains `element`; otherwise, `0`.
  /// - Complexity: O(log `count`)
  @inlinable
  public func count(of element: Element) -> Int {
    __tree_.update { $0.__count_unique(element) }
  }
}

// MARK: - Testing for Membership

extension RedBlackTreeSet {

  /// Returns a Boolean value that indicates whether the given element exists in the set.
  ///
  /// - Parameter element: The element to look for.
  /// - Returns: `true` if the set contains `element`; otherwise, `false`.
  /// - Complexity: O(log *n*), where *n* is the number of elements.
  @inlinable
  public func contains(_ element: Element) -> Bool {
    __tree_.update { $0.__count_unique(element) != 0 }
  }
}

// MARK: - Accessing Elements

extension RedBlackTreeSet {

  /// The first element of the collection.
  ///
  /// - Complexity: O(1)
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

extension RedBlackTreeSet {

  /// Returns the minimum element in the sequence.
  ///
  /// - Complexity: O(1)
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

extension RedBlackTreeSet {

  /// Inserts the given element in the set if it is not already present.
  ///
  /// - Parameter newMember: An element to insert.
  /// - Returns: A tuple indicating whether insertion occurred and containing
  ///   either `newMember` or the existing equivalent element.
  /// - Complexity: O(log *n*), where *n* is the number of elements.
  /// - SeeAlso: `index(inserting:)`, which also returns the index of the inserted or existing element.
  @inlinable
  @discardableResult
  public mutating func insert(_ newMember: Element) -> (
    inserted: Bool, memberAfterInsert: Element
  ) {
    __tree_.ensureUniqueAndCapacity()
    let (__r, __inserted) = __tree_.update { $0.__insert_unique(newMember) }
    return (__inserted, __inserted ? newMember : Base.__payload_(__r))
  }

  /// Inserts the given element, replacing an existing equivalent element if one is already present.
  ///
  /// - Parameter newMember: The element to insert or use as a replacement.
  /// - Returns: The replaced element, or `nil` if `newMember` was newly inserted.
  /// - Complexity: O(log *n*), where *n* is the number of elements.
  @inlinable
  @discardableResult
  public mutating func update(with newMember: Element) -> Element? {
    __tree_.ensureUniqueAndCapacity()
    let (__r, __inserted) = __tree_.update { $0.__insert_unique(newMember) }
    guard !__inserted else { return nil }
    let oldMember = Base.__payload_(__r)
    Base.__payload_ptr(__r).pointee = newMember
    return oldMember
  }
}

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeSet {

    /// Inserts an element, using `hint` as a suggested insertion position.
    ///
    /// An incorrect hint doesn't change the result; it can only affect performance.
    /// `endIndex` is a valid hint.
    ///
    /// - Parameters:
    ///   - newMember: An element to insert.
    ///   - hint: A valid index of this set to use as an insertion hint.
    /// - Returns: Whether insertion occurred and the index of the inserted or existing element.
    /// - Precondition: `hint` is valid for this set.
    @inlinable
    @discardableResult
    public mutating func insert(_ newMember: Element, hint: Index)
      -> (inserted: Bool, indexAfterInsert: Index)
    {
      __tree_.ensureUniqueAndCapacity()
      let p = __tree_.__purified_(hint)
      // endIndex is a valid insertion hint; do not require element accessibility here.
      guard let __p = p.pointer else {
        fatalError(.invalidIndex)
      }
      let (__r, __inserted) = __tree_.___emplace_hint_unique_(__p, newMember, newMember)
      return (__inserted, ___index(__r))
    }

    /// Inserts or replaces an element, using `hint` as a suggested insertion position.
    ///
    /// An incorrect hint doesn't change the result; it can only affect performance.
    /// `endIndex` is a valid hint.
    ///
    /// - Parameters:
    ///   - newMember: The element to insert or use as a replacement.
    ///   - hint: A valid index of this set to use as an insertion hint.
    /// - Returns: The replaced element, or `nil` if `newMember` was newly inserted.
    /// - Precondition: `hint` is valid for this set.
    @inlinable
    @discardableResult
    public mutating func update(_ newMember: Element, hint: Index) -> Element? {
      __tree_.ensureUniqueAndCapacity()
      let p = __tree_.__purified_(hint)
      // endIndex is a valid insertion hint; do not require element accessibility here.
      guard let __p = p.pointer else {
        fatalError(.invalidIndex)
      }
      let (__r, __inserted) = __tree_.___emplace_hint_unique_(__p, newMember, newMember)
      guard !__inserted else { return nil }
      let oldMember = Base.__payload_(__r)
      Base.__payload_ptr(__r).pointee = newMember
      return oldMember
    }
  }
#endif

// MARK: - Removal

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeSet {

    /// Removes and returns the least element of the set.
    ///
    /// Returns `nil` if the set is empty.
    ///
    /// - Returns: The removed element, or `nil` if the set was empty.
    /// - Complexity: Amortized O(1)
    @inlinable
    public mutating func popFirst() -> Element? {
      guard __tree_.count > 0 else { return nil }
      __tree_.ensureUnique()
      return __tree_.___unchecked_remove_first()
    }

    /// Removes and returns the greatest element of the set.
    ///
    /// Returns `nil` if the set is empty.
    ///
    /// - Returns: The removed element, or `nil` if the set was empty.
    /// - Complexity: O(log `count`)
    @inlinable
    public mutating func popLast() -> Element? {
      guard __tree_.count > 0 else { return nil }
      __tree_.ensureUnique()
      return __tree_.___unchecked_remove_last()
    }
  }
#endif

extension RedBlackTreeSet {

  /// Removes and returns the least element of the set.
  ///
  /// - Returns: The removed element.
  /// - Precondition: The set isn't empty.
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
  extension RedBlackTreeSet {

    /// Removes and returns the greatest element of the set.
    ///
    /// - Returns: The removed element.
    /// - Precondition: The set isn't empty.
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

extension RedBlackTreeSet {

  /// Removes the specified element from the set.
  ///
  /// - Parameter member: The element to remove.
  /// - Returns: The removed element, or `nil` if the set didn't contain an
  ///   equivalent element.
  /// - Complexity: O(log *n*), where *n* is the number of elements.
  @inlinable
  @discardableResult
  public mutating func remove(_ member: Element) -> Element? {
    guard __tree_.count > 0 else { return nil }
    __tree_.ensureUnique()
    return __tree_.update { $0.___erase_unique(member) } ? member : nil
  }
}

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeSet {

    /// Removes the element at the given index of the set.
    ///
    /// - Parameter index: A valid index of the set. The index must refer to an
    ///   element, not the set's `endIndex`.
    /// - Returns: The removed element.
    /// - Precondition: `index` is valid for this set and isn't `endIndex`.
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

extension RedBlackTreeSet {

  /// Removes all members from the set.
  ///
  /// - Parameter keepCapacity: Pass `true` to retain the set's allocated
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

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeSet {

    /// Removes the element at the given position from the set and returns the index of the next element.
    ///
    /// - Parameter ptr: A valid index of the set. The index must refer to an
    ///   element, not the set's `endIndex`.
    /// - Returns: The index that followed `ptr` before removal, or `endIndex`
    ///   if the removed element was last.
    /// - Precondition: `ptr` is valid for this set and isn't `endIndex`.
    /// - Complexity: Amortized O(1)
    @discardableResult
    @inlinable
    public mutating func erase(_ ptr: Index) -> Index {
      ___index(__tree_.erase(__tree_.__purified_(ptr).accessible.pointer!))
    }
  }

  extension RedBlackTreeSet {

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

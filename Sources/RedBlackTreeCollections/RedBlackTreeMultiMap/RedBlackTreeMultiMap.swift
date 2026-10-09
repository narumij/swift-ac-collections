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

/// # RedBlackTreeMultiMap
///
/// `RedBlackTreeMultiMap` is a **sorted multimap (allowing duplicate keys)**
/// implemented using a red-black tree.
/// Keys are always kept in sorted order.
/// The order of elements with the same key is the insertion order.
///
/// ```swift
/// var map: RedBlackTreeMultiMap<Int, String> = []
/// map.insert(key: 3, value: "a") // -> [3: "a"]
/// map.insert(key: 1, value: "b") // -> [1: "b", 3: "a"]
/// map.insert(key: 4, value: "c") // -> [1: "b", 3: "a", 4: "c"]
/// map.insert(key: 1, value: "d") // -> [1: "b", 1: "d", 3: "a", 4: "c"]
/// map.insert(key: 5, value: "e") // -> [1: "b", 1: "d", 3: "a", 4: "c", 5: "e"]
/// ```
///
/// ## Removal
///
/// Both single-element removal and range removal are supported.
///
/// ```swift
/// var map: RedBlackTreeMultiMap<Int, String> =
///   [1: "b", 1: "d", 3: "a", 4: "c", 5: "e"]
/// map.eraseUnique(3) // -> [1: "b", 1: "d", 4: "c", 5: "e"]
/// ```
///
/// Avoid performing repeated removals via indices in a `for` loop.
/// Since indices are tightly coupled with tree nodes, removing an element
/// invalidates the operation that retrieves the next index.
/// Use the range-removal APIs for consecutive deletions instead.
///
/// ```swift
/// var map: RedBlackTreeMultiMap<Int, String> =
///   [1: "b", 1: "d", 3: "a", 4: "c", 5: "e"]
/// map[map.lowerBound(4)..<map.endIndex].erase() // -> [1: "b", 1: "d", 3: "a"]
/// ```
///
/// ```swift
/// var map: RedBlackTreeMultiMap<Int, String> =
///   [1: "b", 1: "d", 3: "a", 4: "c", 5: "e"]
/// map.erase(map.lowerBound(4)..<map.endIndex) // -> [1: "b", 1: "d", 3: "a"]
/// ```
///
/// As in C++, sequential removal using `erase(_:) -> Index` is also supported.
/// You can remove elements while receiving the next index.
///
/// ```swift
/// var map: RedBlackTreeMultiMap<Int, String> =
///   [1: "b", 1: "d", 3: "a", 4: "c", 5: "e"]
/// var i = map.startIndex
/// while i != map.endIndex {
///   i = map.erase(i)
/// }
/// ```
///
/// ## Index Alternative Syntax
///
/// `BoundExpression` is designed as a **safe alternative** to direct index usage.
/// It allows specifying elements or boundaries without handling indices directly.
///
/// ```swift
/// var map: RedBlackTreeMultiMap<Int, String> =
///   [1: "b", 1: "d", 3: "a", 4: "c", 5: "e"]
/// print(map[.start.advance(by: 1)]) // -> (1, "d")
/// ```
///
/// ```swift
/// var map: RedBlackTreeMultiMap<Int, String> =
///   [1: "b", 1: "d", 3: "a", 4: "c", 5: "e"]
/// print(map[.lowerBound(5)]) // -> (5, "e")
/// print(map[.upperBound(5)]) // -> nil (equivalent to end)
/// print(map[.find(2)])       // -> nil (not found)
/// ```
///
/// - Important: `RedBlackTreeMultiMap` is not thread-safe.
@frozen
public struct RedBlackTreeMultiMap<Key: Comparable, Value> {

  public
    typealias Element = (key: Key, value: Value)

  @usableFromInline
  package var __tree_: Tree

  @inlinable
  internal init(__tree_: Tree) {
    self.__tree_ = __tree_
  }
}

extension RedBlackTreeMultiMap {
  @frozen
  public enum Base {
    public typealias Element = (key: Key, value: Value)
    public typealias _Key = Key
    public typealias _MappedValue = Value
    public typealias _PayloadValue = RedBlackTreePair<Key, Value>
  }
}

extension RedBlackTreeMultiMap.Base: MultiMultiplicity {}
extension RedBlackTreeMultiMap.Base: PairValueTrait {}
extension RedBlackTreeMultiMap.Base: _PairBasePayload_KeyProtocol_ptr {}
extension RedBlackTreeMultiMap.Base: _BaseNode_NodeCompareProtocol {}
extension RedBlackTreeMultiMap.Base: _BaseNode_SignedDistanceProtocol {}

  extension RedBlackTreeMultiMap: _RedBlackTreeKeyValuesV2 {}
//extension RedBlackTreeMultiMap: _RedBlackTreeKeyValuesBase {}

// MARK: - Inspecting a MultiMap

extension RedBlackTreeMultiMap {

  /// The total number of elements that the multi map can contain without allocating new storage.
  ///
  /// - Complexity: O(1)
  @inlinable
  public var capacity: Int {
    __tree_.capacity
  }
}

extension RedBlackTreeMultiMap {

  /// A Boolean value that indicates whether the multi map is empty.
  ///
  /// - Complexity: O(1)
  @inlinable
  public var isEmpty: Bool {
    count == 0
  }

  /// The number of elements in the multi map.
  ///
  /// - Complexity: O(1)
  @inlinable
  public var count: Int {
    __tree_.count
  }
}

extension RedBlackTreeMultiMap {

  /// Returns the number of key-value pairs with the given key.
  ///
  /// - Parameter key: The key to count.
  /// - Returns: The number of key-value pairs whose key is equal to `key`.
  /// - Complexity: O(log `count` + `distance`), where `distance` is the number of matching elements.
  @inlinable
  public func count(forKey key: Key) -> Int {
    __tree_.update { $0.__count_multi(key) }
  }
}

// MARK: - Testing for Membership

extension RedBlackTreeMultiMap {

  /// Returns a Boolean value that indicates whether the given key exists in the multimap.
  ///
  /// - Parameter key: The key to look for.
  /// - Returns: `true` if the multimap contains at least one element with `key`; otherwise, `false`.
  /// - Complexity: O(log `count`)
  @inlinable
  public func contains(key: Key) -> Bool {
    __tree_.update { $0.__count_unique(key) != 0 }
  }
}

// MARK: - Accessing Keys and Values

extension RedBlackTreeMultiMap {

  /// The first element of the collection.
  ///
  /// - Complexity: O(1)
  @inlinable
  public var first: Element? {
    isEmpty ? nil : __element_(_start)
  }

  /// The last element of the collection.
  ///
  /// - Complexity: O(log `count`)
  @inlinable
  public var last: Element? {
    __tree_.___max().map(__element_)
  }
}

extension RedBlackTreeMultiMap {

  /// Returns the minimum element in the sequence.
  ///
  /// - Complexity: O(1)
  @inlinable
  public func min() -> Element? {
    isEmpty ? nil : __element_(_start)
  }

  /// Returns the maximum element in the sequence.
  ///
  /// - Complexity: O(log `count`)
  @inlinable
  public func max() -> Element? {
    __tree_.___max().map(__element_)
  }
}

//  extension RedBlackTreeMultiMap {
//
//    /// - Complexity: O(log *n*)
//    @inlinable
//    public func values(forKey key: Key) -> [_MappedValue] {
//      let (lo, hi) = __tree_.__equal_range_multi(key)
//      return __tree_.___copy_to_array(lo, hi) { Base.__mapped_value_($0) }
//    }
//  }

// MARK: - Insert

extension RedBlackTreeMultiMap {

  /// Inserts the given key-value pair into the multimap.
  ///
  /// New pairs are placed after existing pairs with an equivalent key, preserving
  /// insertion order within each group of equivalent keys.
  ///
  /// - Parameters:
  ///   - key: The key to insert.
  ///   - value: The value to associate with this occurrence of `key`.
  /// - Returns: `(true, (key, value))`; a multimap always inserts another pair.
  /// - Complexity: O(log *n*)
  @inlinable
  @discardableResult
  public mutating func insert(key: Key, value: Value) -> (
    inserted: Bool, memberAfterInsert: Element
  ) {
    insert((key, value))
  }

  /// Inserts the given key-value pair into the multimap.
  ///
  /// New pairs are placed after existing pairs with an equivalent key, preserving
  /// insertion order within each group of equivalent keys.
  ///
  /// - Parameter newMember: A key-value pair to insert.
  /// - Returns: `(true, newMember)`; a multimap always inserts another pair.
  /// - Complexity: O(log *n*)
  /// - SeeAlso: `index(inserting:)`, which also returns the index of the inserted or existing element.
  @inlinable
  @discardableResult
  public mutating func insert(_ newMember: Element) -> (
    inserted: Bool, memberAfterInsert: Element
  ) {
    __tree_.ensureUniqueAndCapacity()
    _ = __tree_.update { $0.__insert_multi(Base.__payload_(newMember)) }
    return (true, newMember)
  }
}

  // 結局復活してみた。でも少し変えた
  extension RedBlackTreeMultiMap {

    /// Replaces the mapped value at `ptr` without changing its key.
    ///
    /// - Parameters:
    ///   - newValue: The replacement mapped value.
    ///   - ptr: The index of the pair to update.
    /// - Returns: The previous mapped value, or `nil` if `ptr` is invalid.
    /// - Complexity: O(log *n*)
    @inlinable
    @discardableResult
    public mutating func updateValue(_ newValue: Value, at ptr: Index) -> Value? {
      __tree_.ensureUnique()
      let unsealed = __tree_.__purified_(ptr).accessible
      guard let p = unsealed.pointer
      else { return nil }
      let old = Base.__mapped_value_(p)
      Base.__mapped_value_ptr(p).pointee = newValue
      return old
    }
  }

extension RedBlackTreeMultiMap {

  /// Inserts another key-value pair, using `hint` as a suggested insertion position.
  ///
  /// When `hint` is usable, the new pair is inserted at that position, including
  /// within a group of equivalent keys. Otherwise, the hint affects only performance.
  /// `endIndex` is a valid hint.
  ///
  /// - Parameters:
  ///   - newMember: A key-value pair to insert.
  ///   - hint: A valid index of this multimap to use as an insertion hint.
  /// - Returns: The index of the newly inserted pair.
  /// - Precondition: `hint` is valid for this multimap.
  @inlinable
  @discardableResult
  public mutating func insert(_ newMember: Element, hint: Index) -> Index {
    __tree_.ensureUniqueAndCapacity()
    let p = __tree_.__purified_(hint)
    guard let __p = p.pointer else {
      fatalError(.invalidIndex)
    }
    let __r = __tree_.__emplace_hint_multi(__p, Base.__payload_(newMember))
    return __tree_.index(__r)
  }
}

// MARK: - Remove（削除）

extension RedBlackTreeMultiMap {

  /// Removes and returns one key-value pair with the least key.
  ///
  /// Returns `nil` if the multimap is empty.
  ///
  /// - Returns: The removed key-value pair, or `nil` if the multimap was empty.
  /// - Complexity: Amortized O(1)
  @inlinable
  public mutating func popFirst() -> Element? {
    guard __tree_.count > 0 else { return nil }
    __tree_.ensureUnique()
    return __tree_.___unchecked_remove_first().map { Base.__element_($0) }
  }
}

  extension RedBlackTreeMultiMap {

    /// Removes and returns one key-value pair with the greatest key.
    ///
    /// Returns `nil` if the multimap is empty.
    ///
    /// - Returns: The removed key-value pair, or `nil` if the multimap was empty.
    /// - Complexity: O(log `count`)
    @inlinable
    public mutating func popLast() -> Element? {
      guard __tree_.count > 0 else { return nil }
      __tree_.ensureUnique()
      return __tree_.___unchecked_remove_last().map { Base.__element_($0) }
    }
  }

extension RedBlackTreeMultiMap {

  /// Removes and returns one key-value pair with the least key.
  ///
  /// - Returns: The removed key-value pair.
  /// - Precondition: The multimap isn't empty.
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

  extension RedBlackTreeMultiMap {

    /// Removes and returns one key-value pair with the greatest key.
    ///
    /// - Returns: The removed key-value pair.
    /// - Precondition: The multimap isn't empty.
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

extension RedBlackTreeMultiMap {

  /// Removes the key-value pair at the given index of the multimap.
  ///
  /// - Parameter index: A valid index of the multimap. The index must refer to
  ///   an element, not the multimap's `endIndex`.
  /// - Returns: The removed key-value pair.
  /// - Precondition: `index` is valid for this multimap and isn't `endIndex`.
  /// - Complexity: Amortized O(1)
  @inlinable
  @discardableResult
  public mutating func remove(at index: Index) -> Element {
    __tree_.ensureUnique()
    guard case .success(let __p) = __tree_.__purified_(index).accessible else {
      fatalError(.invalidIndex)
    }
    return Base.__element_(__tree_._unchecked_remove(at: __p.pointer).payload)
  }
}

extension RedBlackTreeMultiMap {

  /// Removes all key-value pairs from the multimap.
  ///
  /// - Parameter keepCapacity: Pass `true` to retain the multimap's allocated
  ///   storage for later use.
  /// - Complexity: O(*n*), where *n* is the number of key-value pairs.
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

  extension RedBlackTreeMultiMap {

    /// Removes the key-value pair at the given position from the multimap and returns the index of the next element.
    ///
    /// - Parameter ptr: A valid index of the multimap. The index must refer to
    ///   an element, not the multimap's `endIndex`.
    /// - Returns: The index that followed `ptr` before removal, or `endIndex`
    ///   if the removed key-value pair was last.
    /// - Precondition: `ptr` is valid for this multimap and isn't `endIndex`.
    /// - Complexity: Amortized O(1)
    @discardableResult
    @inlinable
    public mutating func erase(_ ptr: Index) -> Index {
      ___index(__tree_.erase(__tree_.__purified_(ptr).accessible.pointer!))
    }
  }

  extension RedBlackTreeMultiMap {

    /// Removes all elements that satisfy the given predicate.
    ///
    /// - Parameter shouldBeRemoved: A closure that returns `true` for a
    ///   key-value pair that should be removed.
    /// - Complexity: O(n log n)
    @inlinable
    public mutating func erase(where shouldBeRemoved: (Element) throws -> Bool) rethrows {
      guard __tree_.count > 0 else { return }
      __tree_.ensureUnique()
      let result = try __tree_.___erase_range_if(
        __tree_.__begin_node_.unchecked,
        __tree_.__end_node.unchecked,
        { try shouldBeRemoved(Base.__element_($0)) })
      assert(result.error == nil)
    }
  }

  extension RedBlackTreeMultiMap {

    /// Removes a single element equivalent to the given key.
    ///
    /// If multiple elements with an equivalent key exist, an arbitrary one is removed.
    ///
    /// - Parameter key: The key of the element to remove.
    /// - Returns: `true` if an element was removed; otherwise `false`.
    /// - Complexity: O(log *n*)
    @inlinable
    @discardableResult
    public mutating func eraseUnique(_ key: Key) -> Bool {
      __tree_._strongEnsureUnique()
      return __tree_.___erase_unique(key)
    }
  }

  extension RedBlackTreeMultiMap {

    /// Removes all elements equivalent to the given key.
    ///
    /// - Parameter key: The key of the elements to remove.
    /// - Returns: The number of elements removed.
    /// - Complexity: O(log `count` + `distance`), where `distance` is the number of removed elements.
    @inlinable
    @discardableResult
    public mutating func eraseMulti(_ key: Key) -> Int {
      __tree_._strongEnsureUnique()
      return __tree_.___erase_multi(key)
    }
  }

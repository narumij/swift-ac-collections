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

/// # RedBlackTreeMultiMap
///
/// `RedBlackTreeMultiMap` is an **ordered multimap (allowing duplicate keys)**
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
/// map.remove(3) // -> [1: "b", 1: "d", 4: "c", 5: "e"]
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

  public
    typealias Keys = RedBlackTreeIteratorV2.Keys<Base>

  public
    typealias Values = RedBlackTreeIteratorV2.MappedValues<Base>

  @usableFromInline
  var __tree_: Tree

  @inlinable @inline(__always)
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

extension RedBlackTreeMultiMap.Base: CompareMultiTrait {}
extension RedBlackTreeMultiMap.Base: PairValueTrait {}
extension RedBlackTreeMultiMap.Base: _PairBasePayload_KeyProtocol_ptr {}
extension RedBlackTreeMultiMap.Base: _BaseNode_NodeCompareProtocol {}

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiMap: _RedBlackTreeKeyValuesV2 {}
#endif
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

  /// Returns the number of elements equal to the given value.
  ///
  /// - Complexity: O(log `count` + `distance`), where `distance` is the number of matching elements.
  @inlinable
  public func count(forKey key: Key) -> Int {
    __tree_.__count_multi(key)
  }
}

// MARK: - Testing for Membership

extension RedBlackTreeMultiMap {

  /// Returns a Boolean value that indicates whether the given element exists in the set.
  ///
  /// - Complexity: O(log `count`)
  @inlinable
  public func contains(key: Key) -> Bool {
    __tree_.__count_unique(key) != 0
  }
}

// MARK: - Accessing Keys and Values

extension RedBlackTreeMultiMap {

  /// The first element of the collection.
  ///
  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public var first: Element? {
    isEmpty ? nil : Base.__element_(__tree_[_unsafe_raw: _start])
  }

  /// The last element of the collection.
  ///
  /// - Complexity: O(log `count`)
  @inlinable
  @inline(__always)
  public var last: Element? {
    isEmpty ? nil : Base.__element_(__tree_[_unsafe_raw: __tree_.__tree_prev_iter(_end)])
  }
}

extension RedBlackTreeMultiMap {

  /// Returns the minimum element in the sequence.
  ///
  /// - Complexity: O(*n*)
  ///
  /// If O(1) is required, `first` provides an equivalent operation in O(1).
  @inlinable
  public func min() -> Element? {
    __tree_.___min().map(Base.__element_)
  }

  /// Returns the maximum element in the sequence.
  ///
  /// - Complexity: O(log *n*)
  @inlinable
  public func max() -> Element? {
    __tree_.___max().map(Base.__element_)
  }
}

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiMap {

    /// - Complexity: O(log *n*)
    @inlinable
    public func values(forKey key: Key) -> [_MappedValue] {
      let (lo, hi) = __tree_.__equal_range_multi(key)
      return __tree_.___copy_to_array(lo, hi, transform: Base.___mapped_value)
    }
  }
#endif

// MARK: - Insert

extension RedBlackTreeMultiMap {

  /// Inserts the given element in the set if it is not already present.
  ///
  /// - Complexity: O(log *n*)
  @inlinable
  @inline(__always)
  @discardableResult
  public mutating func insert(key: Key, value: Value) -> (
    inserted: Bool, memberAfterInsert: Element
  ) {
    insert((key, value))
  }

  /// Inserts the given element into the set unconditionally.
  ///
  /// - Complexity: O(log *n*)
  @inlinable
  @inline(__always)
  @discardableResult
  public mutating func insert(_ newMember: Element) -> (
    inserted: Bool, memberAfterInsert: Element
  ) {
    __tree_.ensureUniqueAndCapacity()
    _ = __tree_.__insert_multi(Base.__payload_(newMember))
    return (true, newMember)
  }
}

// MARK: - Remove（削除）

extension RedBlackTreeMultiMap {

  /// Removes and returns the first element of the collection.
  ///
  /// - Complexity: Amortized O(1)
  @inlinable
  @inline(__always)
  public mutating func popFirst() -> Element? {
    guard !isEmpty else { return nil }
    return remove(at: startIndex)
  }
}

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiMap {

    /// Removes and returns the last element of the collection.
    ///
    /// - Complexity: O(log `count`)
    @inlinable
    public mutating func popLast() -> Element? {
      __tree_.ensureUnique()
      return ___remove_last().map(\.payload).map(Base.__element_)
    }
  }
#endif

extension RedBlackTreeMultiMap {

  /// Removes the first element of the collection.
  ///
  /// - Complexity: Amortized O(1)
  @inlinable
  @inline(__always)
  @discardableResult
  public mutating func removeFirst() -> Element {
    guard !isEmpty else {
      preconditionFailure(.emptyFirst)
    }
    return remove(at: startIndex)
  }

  /// Removes the last element of the collection.
  ///
  /// - Complexity: O(log *n*)
  @inlinable
  @discardableResult
  public mutating func removeLast() -> Element {
    guard !isEmpty else {
      preconditionFailure(.emptyLast)
    }
    return remove(at: index(before: endIndex))
  }
}

extension RedBlackTreeMultiMap {

  /// Removes the element at the given index of the set.
  ///
  /// - Complexity: Amortized O(1)
  @inlinable
  @inline(__always)
  @discardableResult
  public mutating func remove(at index: Index) -> Element {
    __tree_.ensureUnique()
    guard case .success(let __p) = __tree_.__purified_(index) else {
      fatalError(.invalidIndex)
    }
    return Base.__element_(__tree_._unchecked_remove(at: __p.pointer).payload)
  }
}

extension RedBlackTreeMultiMap {

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

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiMap {

    /// Removes the element at the given position from the set and returns the index of the next element.
    ///
    /// - Complexity: Amortized O(1)
    @discardableResult
    @inlinable @inline(__always)
    public mutating func erase(_ ptr: Index) -> Index {
      ___index(__tree_.erase(__tree_.__purified_(ptr).pointer!).sealed)
    }
  }

  extension RedBlackTreeMultiMap {

    /// Removes all elements that satisfy the given predicate.
    ///
    /// - Complexity: O(n log n)
    @inlinable
    public mutating func erase(where shouldBeRemoved: (Element) throws -> Bool) rethrows {
      __tree_.ensureUnique()
      let result = try __tree_.___erase_if(
        __tree_.__begin_node_.sealed,
        __tree_.__end_node.sealed,
        { try shouldBeRemoved(Base.__element_($0)) })
      if case .failure(let e) = result {
        fatalError(e.localizedDescription)
      }
    }
  }
#endif

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiMap {

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
    public mutating func eraseUnique(_ key: Key) -> Bool {
      __tree_._strongEnsureUnique()
      return __tree_.___erase_unique(key)
    }
  }

  extension RedBlackTreeMultiMap {

    /// Removes all elements equivalent to the given key.
    ///
    /// - Parameter member: The key of the elements to remove.
    /// - Returns: The number of elements removed.
    /// - Complexity: O(log `count` + `distance`), where `distance` is the number of removed elements.
    @inlinable
    @discardableResult
    public mutating func eraseMulti(_ key: Key) -> Int {
      __tree_._strongEnsureUnique()
      return __tree_.___erase_multi(key)
    }
  }
#endif

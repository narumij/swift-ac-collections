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

/// # RedBlackTreeDictionary
///
/// `RedBlackTreeDictionary` is an **ordered dictionary (unique keys)**
/// implemented using a red-black tree.
/// Keys are always kept in sorted order.
///
/// ```swift
/// var dict: RedBlackTreeDictionary<Int, String> = [:]
/// dict[3] = "c"   // -> [3: "c"]
/// dict[1] = "a"   // -> [1: "a", 3: "c"]
/// dict[4] = "d"   // -> [1: "a", 3: "c", 4: "d"]
/// dict[1] = "aa"  // -> [1: "aa", 3: "c", 4: "d"] (updated)
/// ```
///
/// ## Removal
///
/// Both single-element removal and range removal are supported.
///
/// ```swift
/// var dict: RedBlackTreeDictionary<Int, String> = [1: "a", 3: "c", 4: "d", 5: "e"]
/// dict.removeValue(forKey: 3) // -> [1: "a", 4: "d", 5: "e"]
/// ```
///
/// Avoid performing repeated removals via indices in a `for` loop.
/// Since indices are tightly coupled with tree nodes, removing an element
/// invalidates the operation that retrieves the next index.
/// Use the range-removal APIs for consecutive deletions instead.
///
/// ```swift
/// var dict: RedBlackTreeDictionary<Int, String> = [1: "a", 3: "c", 4: "d", 5: "e"]
/// dict[dict.lowerBound(4)..<dict.endIndex].erase() // -> [1: "a", 3: "c"]
/// ```
///
/// ```swift
/// var dict: RedBlackTreeDictionary<Int, String> = [1: "a", 3: "c", 4: "d", 5: "e"]
/// dict.erase(dict.lowerBound(4)..<dict.endIndex) // -> [1: "a", 3: "c"]
/// ```
///
/// As in C++, sequential removal using `erase(_:) -> Index` is also supported.
/// You can remove elements while receiving the next index.
///
/// ```swift
/// var dict: RedBlackTreeDictionary<Int, String> = [1: "a", 3: "c", 4: "d", 5: "e"]
/// var i = dict.startIndex
/// while i != dict.endIndex {
///   i = dict.erase(i)
/// }
/// ```
///
/// ## Index Alternative Syntax
///
/// `BoundExpression` is designed as a **safe alternative** to direct index usage.
/// It allows specifying elements or boundaries without handling indices directly.
///
/// ```swift
/// var dict: RedBlackTreeDictionary<Int, String> = [1: "a", 3: "c", 4: "d", 5: "e"]
/// print(dict[.lowerBound(4)]) // -> (4, "d")
/// print(dict[.upperBound(5)]) // -> nil (equivalent to end)
/// print(dict[.find(2)])       // -> nil (not found)
/// ```
///
/// - Important: `RedBlackTreeDictionary` is not thread-safe.
@frozen
public struct RedBlackTreeDictionary<Key: Comparable, Value> {

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

extension RedBlackTreeDictionary {
  @frozen
  public enum Base {
    public typealias Element = (key: Key, value: Value)
    public typealias _Key = Key
    public typealias _MappedValue = Value
    public typealias _PayloadValue = RedBlackTreePair<Key, Value>
  }
}

extension RedBlackTreeDictionary.Base: CompareUniqueTrait {}
extension RedBlackTreeDictionary.Base: PairValueTrait {}
extension RedBlackTreeDictionary.Base: _PairBasePayload_KeyProtocol_ptr {}
extension RedBlackTreeDictionary.Base: _BaseNode_NodeCompareProtocol {}

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeDictionary: _RedBlackTreeKeyValuesV2 {}
#endif

// MARK: - Inspecting a MultiMap

extension RedBlackTreeDictionary {

  /// - Complexity: O(1)
  @inlinable
  public var capacity: Int {
    __tree_.capacity
  }
}

extension RedBlackTreeDictionary {

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

extension RedBlackTreeDictionary {

  /// - Complexity: O(log `count`)
  @inlinable
  public func count(forKey key: Key) -> Int {
    __tree_.__count_unique(key)
  }
}

// MARK: - Testing for Membership

extension RedBlackTreeDictionary {

  /// - Complexity: O(log `count`)
  @inlinable
  public func contains(key: Key) -> Bool {
    __tree_.__count_unique(key) != 0
  }
}

// MARK: - Accessing Keys and Values

extension RedBlackTreeDictionary {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public var first: Element? {
    isEmpty ? nil : Base.__element_(__tree_[_unsafe_raw: _start])
  }

  /// - Complexity: O(log *n*)
  @inlinable
  public var last: Element? {
    isEmpty ? nil : Base.__element_(__tree_[_unsafe_raw: __tree_.__tree_prev_iter(_end)])
  }
}

extension RedBlackTreeDictionary {

  /// - Complexity: O(log *n*)
  ///
  /// If O(1) is required, `first` provides an equivalent operation in O(1).
  @inlinable
  public func min() -> Element? {
    __tree_.___min().map(Base.__element_)
  }

  /// - Complexity: O(log *n*)
  @inlinable
  public func max() -> Element? {
    __tree_.___max().map(Base.__element_)
  }
}

// MARK: - Insert

extension RedBlackTreeDictionary {
  // multi mapとの統一感のために復活

  /// - Complexity: O(log *n*)
  @inlinable
  @inline(__always)
  @discardableResult
  public mutating func insert(key: Key, value: Value) -> (
    inserted: Bool, memberAfterInsert: Element
  ) {
    insert((key, value))
  }

  /// - Complexity: O(log *n*)
  @inlinable
  @inline(__always)
  @discardableResult
  public mutating func insert(_ newMember: Element) -> (
    inserted: Bool, memberAfterInsert: Element
  ) {
    __tree_.ensureUniqueAndCapacity()
    let (__r, __inserted) = __tree_.__insert_unique(Base.__payload_(newMember))
    return (__inserted, __inserted ? newMember : Base.__element_(__tree_[_unsafe_raw: __r]))
  }
}

extension RedBlackTreeDictionary {

  /// - Complexity: O(log *n*)
  @inlinable
  @inline(__always)
  @discardableResult
  public mutating func updateValue(
    _ value: Value,
    forKey key: Key
  ) -> Value? {
    __tree_.ensureUniqueAndCapacity()
    let (__r, __inserted) = __tree_.__insert_unique(Base.__payload_((key, value)))
    guard !__inserted else { return nil }
    let oldMember = __tree_[_unsafe_raw: __r]
    __tree_[_unsafe_raw: __r] = Base.__payload_((key, value))
    return oldMember.value
  }
}

// MARK: - Remove

extension RedBlackTreeDictionary {

  /// - Complexity: Amortized O(1)
  @inlinable
  @inline(__always)
  public mutating func popFirst() -> Element? {
    guard !isEmpty else { return nil }
    return remove(at: startIndex)
  }
}

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeDictionary {

    /// - Complexity: O(log `count`)
    @inlinable
    public mutating func popLast() -> Element? {
      __tree_.ensureUnique()
      return ___remove_last().map(\.payload).map(Base.__element_)
    }
  }
#endif

extension RedBlackTreeDictionary {

  /// - Important: Indices that refer to removed members become invalid.
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

  /// - Important: Indices that refer to removed members become invalid.
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

extension RedBlackTreeDictionary {

  /// - Important: Indices that refer to removed members become invalid.
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

extension RedBlackTreeDictionary {

  /// - Important: Indices that refer to removed members become invalid.
  /// - Complexity: O(log *n*)
  @inlinable
  @inline(__always)
  @discardableResult
  public mutating func removeValue(forKey __k: Key) -> Value? {
    __tree_.ensureUnique()
    let __i = __tree_.find(__k)
    if __i == __tree_.end {
      return nil
    }
    let value = __tree_.__value_(__i).value
    _ = __tree_.erase(__i)
    return value
  }
}

extension RedBlackTreeDictionary {

  /// - Important: Indices that refer to removed members become invalid.
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
  extension RedBlackTreeDictionary {

    /// - Complexity: Amortized O(1)
    @discardableResult
    @inlinable @inline(__always)
    public mutating func erase(_ ptr: Index) -> Index {
      ___index(__tree_.erase(__tree_.__purified_(ptr).pointer!).sealed)
    }
  }

  extension RedBlackTreeDictionary {

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

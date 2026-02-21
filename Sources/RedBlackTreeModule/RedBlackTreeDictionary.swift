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

  public
    typealias _Key = Key

  public
    typealias _MappedValue = Value

  public
    typealias _PayloadValue = RedBlackTreePair<Key, Value>

  @usableFromInline
  var __tree_: Tree

  @inlinable @inline(__always)
  internal init(__tree_: Tree) {
    self.__tree_ = __tree_
  }
}

extension RedBlackTreeDictionary {
  public typealias Base = Self
}

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeDictionary: _RedBlackTreeKeyValues {}
#endif

extension RedBlackTreeDictionary: CompareUniqueTrait {}
extension RedBlackTreeDictionary: PairValueTrait {}
extension RedBlackTreeDictionary: _PairBasePayload_KeyProtocol_ptr {}
extension RedBlackTreeDictionary: _BaseNode_NodeCompareProtocol {}

// MARK: - Creating a Dictionay

extension RedBlackTreeDictionary {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public init() {
    self.init(__tree_: .create())
  }

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public init(minimumCapacity: Int) {
    self.init(__tree_: .create(minimumCapacity: minimumCapacity))
  }
}

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeDictionary {

    /// - Complexity: O(*n* log *n*)
    ///   When inserting elements sequentially from an already sorted sequence,
    ///   no search is required, and rebalancing is amortized O(1),
    ///   so the overall construction cost becomes O(*n*).
    @inlinable
    public init<S>(uniqueKeysWithValues keysAndValues: __owned S)
    where S: Sequence, S.Element == (Key, Value) {
      self.init(
        __tree_:
          .___insert_range_unique(
            tree: .create(),
            keysAndValues,
            transform: Base.__payload_(_:)))
    }

    /// - Complexity: O(*n* log *n*)
    ///   When inserting elements sequentially from an already sorted sequence,
    ///   no search is required, and rebalancing is amortized O(1),
    ///   so the overall construction cost becomes O(*n*).
    @inlinable
    public init<S>(uniqueKeysWithValues keysAndValues: __owned S)
    where S: Collection, S.Element == (Key, Value) {
      self.init(
        __tree_:
          .___insert_range_unique(
            tree:
              .create(minimumCapacity: keysAndValues.count),
            keysAndValues,
            transform: Base.__payload_(_:)))
    }
  }
#endif

extension RedBlackTreeDictionary {

  /// - Complexity: O(*n* log *n* + *n*)
  @inlinable
  public init<S>(
    _ keysAndValues: __owned S,
    uniquingKeysWith combine: (Value, Value) throws -> Value
  ) rethrows where S: Sequence, S.Element == (Key, Value) {

    self.init(
      __tree_: try .create_unique(
        sorted: keysAndValues.sorted { $0.0 < $1.0 },
        uniquingKeysWith: combine,
        transform: Self.__payload_
      ))
  }
}

extension RedBlackTreeDictionary {

  /// - Complexity: O(*n* log *n* + *n*)
  @inlinable
  public init<S: Sequence>(
    grouping values: __owned S,
    by keyForValue: (S.Element) throws -> Key
  ) rethrows where Value == [S.Element] {

    self.init(
      __tree_: try .create_unique(
        sorted: try values.sorted {
          try keyForValue($0) < keyForValue($1)
        },
        by: keyForValue
      ))
  }
}

// MARK: -

extension RedBlackTreeDictionary {

  @inlinable
  public mutating func reserveCapacity(_ minimumCapacity: Int) {
    __tree_.ensureUniqueAndCapacity(to: minimumCapacity)
  }
}

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

  /// - Complexity: O(log *n* + *k*)
  @inlinable
  public func count(forKey key: Key) -> Int {
    __tree_.__count_unique(key)
  }
}

// MARK: - Testing for Membership

extension RedBlackTreeDictionary {

  /// - Complexity: O(log *n*)
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
  @inlinable
  public subscript(key: Key) -> Value? {

    @inline(__always) get {
      __tree_.lookup(key)
    }

    set(newValue) {
      if let x = newValue {
        __tree_.setValue(x, forKey: key)
      } else {
        _ = __tree_.___erase_unique(key)
      }
    }

    _modify {
      defer { _fixLifetime(__tree_) }
      yield &__tree_[key]
    }
  }

  /// - Complexity: O(log *n*)
  @inlinable
  public subscript(
    key: Key, default defaultValue: @autoclosure () -> Value
  ) -> Value {
    @inline(__always) get {
      __tree_.lookup(key) ?? defaultValue()
    }
    @inline(__always) _modify {
      defer { _fixLifetime(__tree_) }
      __tree_.ensureUnique()
      let (__parent, __child) = __tree_.__find_equal(key)
      if __child.pointee.___is_null {
        __tree_.ensureCapacity()
        assert(__tree_.capacity > __tree_.count)
        __tree_.update {
          let __h = $0.__construct_node(Self.__payload_((key, defaultValue())))
          $0.__insert_node_at(__parent, __child, __h)
        }
      }
      yield &__tree_[_unsafe_raw: __child.pointee].value
    }
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
    let (__r, __inserted) = __tree_.__insert_unique(Self.__payload_(newMember))
    return (__inserted, __inserted ? newMember : Self.__element_(__tree_[_unsafe_raw: __r]))
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
    let (__r, __inserted) = __tree_.__insert_unique(Self.__payload_((key, value)))
    guard !__inserted else { return nil }
    let oldMember = __tree_[_unsafe_raw: __r]
    __tree_[_unsafe_raw: __r] = Self.__payload_((key, value))
    return oldMember.value
  }
}

// MARK: - Combining Dictionary

extension RedBlackTreeDictionary {

  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  @inlinable
  public mutating func merge(
    _ other: RedBlackTreeDictionary<Key, Value>,
    uniquingKeysWith combine: (Value, Value) throws -> Value
  ) rethrows {

    try __tree_.ensureUnique { __tree_ in
      try .___insert_range_unique(
        tree: __tree_,
        other: other.__tree_,
        other.__tree_.__begin_node_,
        other.__tree_.__end_node,
        uniquingKeysWith: combine)
    }
  }

  /// Merges the elements of `other` into the dictionary.
  /// If duplicate keys are encountered, the result of `combine` is used.
  ///
  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  @inlinable
  public mutating func merge<S>(
    _ other: __owned S,
    uniquingKeysWith combine: (Value, Value) throws -> Value
  ) rethrows where S: Sequence, S.Element == (Key, Value) {

    try __tree_.ensureUnique { __tree_ in
      try .___insert_range_unique(
        tree: __tree_,
        other,
        uniquingKeysWith: combine
      ) { Self.__payload_($0) }
    }
  }

  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  @inlinable
  public func merging(
    _ other: RedBlackTreeDictionary<Key, Value>,
    uniquingKeysWith combine: (Value, Value) throws -> Value
  ) rethrows -> Self {
    var result = self
    try result.merge(other, uniquingKeysWith: combine)
    return result
  }

  /// Returns a new dictionary by merging `self` and `other`.
  ///
  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  @inlinable
  public func merging<S>(
    _ other: __owned S,
    uniquingKeysWith combine: (Value, Value) throws -> Value
  ) rethrows -> Self where S: Sequence, S.Element == (Key, Value) {
    var result = self
    try result.merge(other, uniquingKeysWith: combine)
    return result
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
    return Self.__element_(__tree_._unchecked_remove(at: __p.pointer).payload)
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

// MARK: - Transformation

extension RedBlackTreeDictionary {

  /// - Complexity: O(*n*)
  @inlinable
  public func filter(
    _ isIncluded: (Element) throws -> Bool
  ) rethrows -> Self {
    .init(
      __tree_: try __tree_.___filter(_start, _end) {
        try isIncluded(Self.__element_($0))
      })
  }
}

extension RedBlackTreeDictionary {

  /// - Complexity: O(*n*)
  @inlinable
  public func mapValues<T>(_ transform: (Value) throws -> T) rethrows
    -> RedBlackTreeDictionary<Key, T>
  {
    .init(__tree_: try __tree_.___mapValues(_start, _end, transform))
  }

  /// - Complexity: O(*n*)
  @inlinable
  public func compactMapValues<T>(_ transform: (Value) throws -> T?)
    rethrows -> RedBlackTreeDictionary<Key, T>
  {
    .init(__tree_: try __tree_.___compactMapValues(_start, _end, transform))
  }
}

// MARK: - Collection Conformance

// MARK: - Sequence
// MARK: - Collection
// MARK: - BidirectionalCollection

extension RedBlackTreeDictionary: Sequence {}

extension RedBlackTreeDictionary {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public func makeIterator() -> Tree._KeyValues {
    .init(start: _sealed_start, end: _sealed_end, tie: __tree_.tied)
  }
}

#if !COMPATIBLE_ATCODER_2025

  extension RedBlackTreeDictionary {

    /// - Complexity: O(`count`)
    @inlinable
    @inline(__always)
    public func sorted() -> [Element] {
      __tree_.___copy_all_to_array(transform: Base.__element_)
    }

    /// - Complexity: O(`count`)
    @inlinable
    @inline(__always)
    public func reversed() -> [Element] {
      __tree_.___rev_copy_all_to_array(transform: Base.__element_)
    }
  }
#endif

// MARK: -

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeDictionary {

    /// - Complexity: O(`count`)
    @inlinable
    @inline(__always)
    public var keys: [Key] {
      __tree_.___copy_all_to_array(transform: Base.__key)
    }

    /// - Complexity: O(`count`)
    @inlinable
    @inline(__always)
    public var values: [Value] {
      __tree_.___copy_all_to_array(transform: Base.___mapped_value)
    }
  }
#endif

// MARK: -

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeDictionary {

    /// - Important:
    ///   When an element or its corresponding node is removed, any related index becomes invalid.
    ///   Using an invalid index may result in a runtime error or undefined behavior.
    public typealias Index = UnsafeIndexV3
    public typealias SubSequence = RedBlackTreeKeyValueRangeView<Base>
  }

  extension RedBlackTreeDictionary {

    @inlinable
    func ___index(_ p: _SealedPtr) -> UnsafeIndexV3 {
      p.band(__tree_.tied)
    }

    @inlinable
    func ___index_or_nil(_ p: _SealedPtr) -> UnsafeIndexV3? {
      p.exists ? p.band(__tree_.tied) : nil
    }
  }

  extension RedBlackTreeDictionary {
    /// - Complexity: O( log `count` )
    @inlinable
    public func firstIndex(of key: Key) -> Index? {
      ___index_or_nil(__tree_.find(key).sealed)
    }
  }

  extension RedBlackTreeDictionary {

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public var startIndex: Index { ___index(_sealed_start) }

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public var endIndex: Index { ___index(_sealed_end) }
  }

  extension RedBlackTreeDictionary {

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

  extension RedBlackTreeDictionary {

    /// Returns the index of the first element whose key is not less than the given key.
    ///
    /// `lowerBound(_:)` returns the first position (`Index`) whose element has a key
    /// greater than or equal to the specified `key`.
    ///
    /// For example, given a key-sorted sequence `[1: "a", 3: "c", 5: "e", 7: "g", 9: "i"]`:
    /// - `lowerBound(0)` returns the position of the first element `(1, "a")` (i.e. `startIndex`).
    /// - `lowerBound(3)` returns the position of the element with key `3`, `(3, "c")`.
    /// - `lowerBound(4)` returns the position of `(5, "e")` (the first key ≥ `4`).
    /// - `lowerBound(10)` returns `endIndex`.
    ///
    /// - Parameter key: The key to search for using binary search.
    /// - Returns: The first `Index` whose element’s key is greater than or equal to `key`.
    /// - Complexity: O(log *n*), where *n* is the number of elements.
    @inlinable
    public func lowerBound(_ key: Key) -> Index {
      ___index(__tree_.lower_bound(key).sealed)
    }

    /// Returns the index of the first element whose key is greater than the given key.
    ///
    /// `upperBound(_:)` returns the first position (`Index`) whose element has a key
    /// strictly greater than the specified `key`.
    ///
    /// For example, given a key-sorted sequence `[1: "a", 3: "c", 5: "e", 7: "g", 9: "i"]`:
    /// - `upperBound(3)` returns the position of the element with key `5`, `(5, "e")`
    ///   (the first key greater than `3`).
    /// - `upperBound(5)` returns the position of the element with key `7`, `(7, "g")`.
    /// - `upperBound(9)` returns `endIndex`.
    ///
    /// - Parameter key: The key to search for using binary search.
    /// - Returns: The first `Index` whose element’s key is strictly greater than `key`.
    /// - Complexity: O(log *n*), where *n* is the number of elements.
    @inlinable
    public func upperBound(_ key: Key) -> Index {
      ___index(__tree_.upper_bound(key).sealed)
    }
  }

  extension RedBlackTreeDictionary {

    /// - Complexity: O( log `count` )
    @inlinable
    public func find(_ key: Key) -> Index {
      ___index(__tree_.find(key).sealed)
    }
  }

  extension RedBlackTreeDictionary {

    /// - Complexity: O(log *n*), where *n* is the number of elements.
    @inlinable
    public func equalRange(_ key: Key) -> UnsafeIndexV3Range {
      let (lower, upper) = __tree_.__equal_range_unique(key)
      return .init(.init(lowerBound: ___index(lower.sealed), upperBound: ___index(upper.sealed)))
    }
  }

  extension RedBlackTreeDictionary {

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

  extension RedBlackTreeDictionary {

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
  extension RedBlackTreeDictionary {

    /// Returns whether the index can be used with subscript or remove operations.
    ///
    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public func isValid(_ index: Index) -> Bool {
      __tree_.__purified_(index).exists
    }
  }

  extension RedBlackTreeDictionary {

    /// - Complexity: O(1)
    @inlinable
    public subscript(position: Index) -> Element {
      @inline(__always) get {
        Base.__element_(__tree_[_unsafe: __tree_.__purified_(position)])
      }
    }
  }

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

// MARK: - Protocol Conformance

// MARK: - ExpressibleByDictionaryLiteral

extension RedBlackTreeDictionary: ExpressibleByDictionaryLiteral {

  /// - Complexity: O(*n* log *n*)
  @inlinable
  @inline(__always)
  public init(dictionaryLiteral elements: (Key, Value)...) {
    self.init(uniqueKeysWithValues: elements)
  }
}

// MARK: - ExpressibleByArrayLiteral

extension RedBlackTreeDictionary: ExpressibleByArrayLiteral {

  /// Creates a dictionary from a literal in the form `[("key", value), ...]`.
  ///
  /// - Important: If duplicate keys are present,
  ///   a **runtime error** occurs, just like `Dictionary(uniqueKeysWithValues:)`.
  ///   (If you want to allow duplicates and merge them, use `merge` / `merging`.)
  ///
  /// Example:
  /// ```swift
  /// let d: RedBlackTreeDictionary = [("a", 1), ("b", 2)]
  /// ```
  @inlinable
  @inline(__always)
  public init(arrayLiteral elements: (Key, Value)...) {
    self.init(uniqueKeysWithValues: elements)
  }
}

// MARK: - CustomStringConvertible

extension RedBlackTreeDictionary: CustomStringConvertible {

  @inlinable
  public var description: String {
    _dictionaryDescription(for: self)
  }
}

// MARK: - CustomDebugStringConvertible

extension RedBlackTreeDictionary: CustomDebugStringConvertible {

  public var debugDescription: String {
    description
  }
}

// MARK: - CustomReflectable

extension RedBlackTreeDictionary: CustomReflectable {
  /// The custom mirror for this instance.
  public var customMirror: Mirror {
    Mirror(self, unlabeledChildren: self + [], displayStyle: .dictionary)
  }
}

// MARK: - Is Identical To

extension RedBlackTreeDictionary {

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

extension RedBlackTreeDictionary: Equatable where Value: Equatable {

  /// - Complexity: O(*m*), where *m* is the lesser of the length of `lhs` and `rhs`.
  @inlinable
  @inline(__always)
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.__tree_ == rhs.__tree_
  }
}

// MARK: - Comparable

extension RedBlackTreeDictionary: Comparable where Value: Comparable {

  /// - Complexity: O(*m*), where *m* is the lesser of the length of `lhs` and `rhs`.
  @inlinable
  @inline(__always)
  public static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.__tree_ < rhs.__tree_
  }
}

// MARK: - Hashable

extension RedBlackTreeDictionary: Hashable where Key: Hashable, Value: Hashable {

  @inlinable
  @inline(__always)
  public func hash(into hasher: inout Hasher) {
    hasher.combine(__tree_)
  }
}

// MARK: - Sendable

#if swift(>=5.5)
  extension RedBlackTreeDictionary: @unchecked Sendable
  where Key: Sendable, Value: Sendable {}
#endif

// MARK: - Codable

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeDictionary: Encodable where Key: Encodable, Value: Encodable {

    @inlinable
    public func encode(to encoder: Encoder) throws {
      var container = encoder.unkeyedContainer()
      for element in __tree_.unsafeValues(__tree_.__begin_node_, __tree_.__end_node) {
        try container.encode(element)
      }
    }
  }

  extension RedBlackTreeDictionary: Decodable where Key: Decodable, Value: Decodable {

    @inlinable
    public init(from decoder: Decoder) throws {
      self.init(__tree_: try .create(from: decoder))
    }
  }
#endif

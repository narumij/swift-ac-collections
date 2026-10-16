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

/// # RedBlackTreeDictionary
///
/// ## Declaration
///
/// Use `RedBlackTreeDictionary<Key: Comparable, Value>` with `import AcCollections`.
///
/// ## Overview
///
/// A red-black-tree dictionary that stores unique keys in ascending order. Assigning to an existing key replaces its mapped value. Insertion, removal, and value updates preserve key order. Unlike the standard `Dictionary`, it supports ordered traversal and lower- and upper-bound searches. Use `RedBlackTreeMultiMap` when a key must retain multiple values.
///
/// ```swift
/// var dict: RedBlackTreeDictionary<Int, String> = [:]
/// dict[3] = "c"   // -> [3: "c"]
/// dict[1] = "a"   // -> [1: "a", 3: "c"]
/// dict[4] = "d"   // -> [1: "a", 3: "c", 4: "d"]
/// dict[1] = "aa"  // -> [1: "aa", 3: "c", 4: "d"] (updated)
/// ```
///
/// ## Creating a Dictionary
///
/// Create an empty dictionary with `init()` or an empty dictionary literal. Supply unique keys to dictionary literals and `init(uniqueKeysWithValues:)`. For duplicate keys, use `init(_:uniquingKeysWith:)`; its closure receives the stored value followed by the incoming value. `init(grouping:by:)` associates each key with an array in source order.
///
/// Use `init(minimumCapacity:)` or `reserveCapacity(_:)` to reserve storage. `capacity` describes storage capacity rather than the number of elements.
///
/// ## Searching and Accessing Elements
///
/// Key subscripting returns `nil` when the key is absent. The default-value subscript returns its default without inserting it on a read. `contains(key:)` checks membership; `count(forKey:)` returns zero or one.
///
/// `first` / `last` and `min()` / `max()` access the endpoints in key order. `firstIndex(of:)` / `index(forKey:)` return `nil` for an absent key, while `find(_:)` returns `endIndex`. `lowerBound(_:)` finds the first key greater than or equal to its argument; `upperBound(_:)` finds the first strictly greater key. Both return the end when no such key exists. `equalRange(_:)` describes the matching half-open range. When moving with `index(after:)` or `index(before:)`, respect the endpoint preconditions.
///
/// ## Insertion, Updating, and Removal
///
/// Assign a value through key subscripting to insert or update; assign `nil` to remove. Mutation through the default-value subscript inserts the default first when the key is absent. `updateValue(_:forKey:)` returns the previous value, or `nil` for a new key. `removeValue(forKey:)` removes the matching element.
///
/// Use range removal for consecutive elements. Do not advance from an index after deleting its element. For sequential removal, use the next index returned by `erase(_:) -> Index`.
///
/// ```swift
/// var dict: RedBlackTreeDictionary<Int, String> = [1: "a", 3: "c", 4: "d", 5: "e"]
/// dict.removeValue(forKey: 3) // -> [1: "a", 4: "d", 5: "e"]
/// ```
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
/// ```swift
/// var dict: RedBlackTreeDictionary<Int, String> = [1: "a", 3: "c", 4: "d", 5: "e"]
/// var i = dict.startIndex
/// while i != dict.endIndex {
///   i = dict.erase(i)
/// }
/// ```
///
/// ## Transforming and Combining Dictionaries
///
/// `filter(_:)` returns a dictionary containing the selected pairs. `mapValues(_:)` transforms values without changing keys; `compactMapValues(_:)` omits pairs whose transformed value is `nil`. These operations retain key order.
///
/// `merge(_:uniquingKeysWith:)` modifies this dictionary; `merging(_:uniquingKeysWith:)` returns a result. For duplicate keys, the closure receives the existing value and then the incoming value; its result becomes the value for that key.
///
/// ## Iterating over Keys and Values
///
/// Elements are `(key: Key, value: Value)` pairs. Normal iteration follows ascending key order. `keys` traverses keys lazily, and `values` is a mapped-values view. `sorted()` returns an ascending array and `reversed()` a descending array. An index-range view also exposes pairs, keys, and values.
///
/// ## Indices and Bound Expressions
///
/// Indices represent element positions, not integer offsets. Inserting or removing other elements preserves them; deleting the indexed element invalidates its index, even if the slot is reused. In the normal configuration, corresponding positions can be shared across copy-on-write branches, but validity depends on the target’s generation and deletion state. Using an unrelated tree’s index violates a precondition and is not guaranteed to be detected.
///
/// Index-range subscripting returns a pair view without copying elements into an array. The view has its own endpoint. Mutating directly through the subscript changes the base; mutating a view stored in a separate variable is isolated through copy-on-write. `containsSubrange(_:)` checks a range, and `distance(from:to:)` accepts indices or bounds.
///
/// `Bound` provides `.start`, `.last`, `.end`, `.lowerBound`, `.upperBound`, `.find`, `.lessThan`, `.lessThanOrEqual`, `.greaterThan`, `.greaterThanOrEqual`, `.before`, `.after`, and `.advanced(by:limit:)`. A single bound resolving to the end or no position returns `nil` through subscripting. Invalid or reversed bound ranges produce empty views.
///
/// ```swift
/// var dict: RedBlackTreeDictionary<Int, String> = [1: "a", 3: "c", 4: "d", 5: "e"]
/// print(dict[.lowerBound(4)]) // Optional containing (4, "d")
/// print(dict[.upperBound(5)]) // -> nil (equivalent to end)
/// print(dict[.find(2)])       // -> nil (not found)
/// ```
///
/// ## Performance
///
/// The following assumes constant-time comparisons and element operations, and excludes copying shared storage for copy-on-write. Copying can retain deletion history, so its cost is not always determined by the current element count.
///
///
///
/// | Operation | Complexity |
/// | --- | --- |
/// | `isEmpty`, `count`, `startIndex`, `endIndex` | O(1) |
/// | Key lookup, lower/upper bound, insertion, key-based update/removal | O(log n) |
/// | Removal at a known index; rebalancing | Amortized O(1) |
/// | `filter`, `mapValues`, `compactMapValues` | O(n), plus closure costs |
/// | `merge`, `merging` with m existing and n incoming pairs | O(n log(m+n)), plus closure and storage-copy costs |
///
///
/// ## Red-Black Tree
///
/// The red-black tree orders elements by key and maintains logarithmic height through recoloring and rotations. Logical key order is distinct from physical memory layout.
///
/// ## Important
///
/// This type is not thread-safe and does not protect concurrent access to the same variable. This guide describes the normal configuration.
@frozen
public struct RedBlackTreeDictionary<Key: Comparable, Value> {

  public
    typealias Element = (key: Key, value: Value)

  @usableFromInline
  package var __tree_: Tree

  @inlinable
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

extension RedBlackTreeDictionary.Base: UniqueMultiplicity {}
extension RedBlackTreeDictionary.Base: PairValueTrait {}
extension RedBlackTreeDictionary.Base: _PairBasePayload_KeyProtocol_ptr {}
extension RedBlackTreeDictionary.Base: _BaseNode_NodeCompareProtocol {}
extension RedBlackTreeDictionary.Base: _BaseNode_SignedDistanceProtocol {}

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeDictionary: _RedBlackTreeKeyValuesV2 {}
#endif

// MARK: - Inspecting a MultiMap

extension RedBlackTreeDictionary {

  /// The total number of key-value pairs that the dictionary can contain without allocating new storage.
  ///
  /// - Complexity: O(1)
  @inlinable
  public var capacity: Int {
    __tree_.capacity
  }
}

extension RedBlackTreeDictionary {

  /// A Boolean value that indicates whether the dictionary is empty.
  ///
  /// - Complexity: O(1)
  @inlinable
  public var isEmpty: Bool {
    count == 0
  }

  /// The number of key-value pairs in the dictionary.
  ///
  /// - Complexity: O(1)
  @inlinable
  public var count: Int {
    __tree_.count
  }
}

extension RedBlackTreeDictionary {

  /// Returns the number of elements with the given key.
  ///
  /// Because a dictionary stores unique keys, the result is either `0` or `1`.
  ///
  /// - Parameter key: The key to count.
  /// - Returns: `1` if the dictionary contains `key`; otherwise, `0`.
  /// - Complexity: O(log `count`)
  @inlinable
  public func count(forKey key: Key) -> Int {
    __tree_.update { $0.__count_unique(key) }
  }
}

// MARK: - Testing for Membership

extension RedBlackTreeDictionary {

  /// Returns a Boolean value that indicates whether the given key exists in the dictionary.
  ///
  /// - Parameter key: The key to look for.
  /// - Returns: `true` if the dictionary contains `key`; otherwise, `false`.
  /// - Complexity: O(log `count`)
  @inlinable
  public func contains(key: Key) -> Bool {
    // TODO: 冬休み頃にハンドルを使った特殊化実装を試し、生成された探索ループにwitness dispatch が残ってないことを確認する。
    __tree_.update { $0.__count_unique(key) != 0 }
  }
}

// MARK: - Accessing Keys and Values

extension RedBlackTreeDictionary {

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

extension RedBlackTreeDictionary {

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

// MARK: - Insert

extension RedBlackTreeDictionary {
  // multi mapとの統一感のために復活

  /// Inserts the given key-value pair into the dictionary if its key is not already present.
  ///
  /// - Parameters:
  ///   - key: The key to insert.
  ///   - value: The value to associate with `key` when insertion succeeds.
  /// - Returns: Whether insertion occurred and the inserted or existing key-value pair.
  /// - Complexity: O(log *n*)
  @inlinable
  @discardableResult
  public mutating func insert(key: Key, value: Value)
    -> (inserted: Bool, memberAfterInsert: Element)
  {
    insert((key, value))
  }

  /// Inserts the given key-value pair into the dictionary if its key is not already present.
  ///
  /// - Parameter newMember: A key-value pair to insert.
  /// - Returns: Whether insertion occurred and the inserted or existing key-value pair.
  /// - Complexity: O(log *n*)
  /// - SeeAlso: `index(inserting:)`, which also returns the index of the inserted or existing element.
  @inlinable
  @discardableResult
  public mutating func insert(_ newMember: Element)
    -> (inserted: Bool, memberAfterInsert: Element)
  {
    __tree_.ensureUniqueAndCapacity()
    let (__r, __inserted) = __tree_.update { $0.__insert_unique(Base.__payload_(newMember)) }
    return (__inserted, __inserted ? newMember : Base.__element_(__r))
  }
}

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeDictionary {

    /// Inserts a key-value pair, using `hint` as a suggested insertion position.
    ///
    /// An incorrect hint doesn't change the result; it can only affect performance.
    /// `endIndex` is a valid hint.
    ///
    /// - Parameters:
    ///   - key: The key to insert.
    ///   - value: The value to associate with `key` when insertion succeeds.
    ///   - hint: A valid index of this dictionary to use as an insertion hint.
    /// - Returns: Whether insertion occurred and the index of the inserted or existing pair.
    /// - Precondition: `hint` is valid for this dictionary.
    @inlinable
    @discardableResult
    public mutating func insert(key: Key, value: Value, hint: Index)
      -> (inserted: Bool, indexAfterInsert: Index)
    {
      insert((key, value), hint: hint)
    }

    /// Inserts a key-value pair, using `hint` as a suggested insertion position.
    ///
    /// - Parameters:
    ///   - newMember: A key-value pair to insert.
    ///   - hint: A valid index of this dictionary to use as an insertion hint.
    /// - Returns: Whether insertion occurred and the index of the inserted or existing pair.
    /// - Precondition: `hint` is valid for this dictionary.
    @inlinable
    @discardableResult
    public mutating func insert(_ newMember: Element, hint: Index)
      -> (inserted: Bool, indexAfterInsert: Index)
    {
      __tree_.ensureUniqueAndCapacity()
      let p = __tree_.__purified_(hint)
      guard let __p = p.pointer else {
        fatalError(.invalidIndex)
      }
      let (__r, __inserted) = __tree_.__emplace_hint_unique(
        __p, newMember.key, Base.__payload_(newMember))
      return (__inserted, ___index(__r))
    }

    /// Inserts or replaces a key-value pair, using `hint` as a suggested insertion position.
    ///
    /// - Parameters:
    ///   - newMember: The pair to insert or use as a replacement.
    ///   - hint: A valid index of this dictionary to use as an insertion hint.
    /// - Returns: The replaced pair, or `nil` if `newMember` was newly inserted.
    /// - Precondition: `hint` is valid for this dictionary.
    @inlinable
    @discardableResult
    public mutating func update(_ newMember: Element, hint: Index)
      -> Element?
    {
      __tree_.ensureUniqueAndCapacity()
      let p = __tree_.__purified_(hint)
      // endIndex is a valid insertion hint; do not require element accessibility here.
      guard let __p = p.pointer else {
        fatalError(.invalidIndex)
      }
      let (__r, __inserted) = __tree_.___emplace_hint_unique_(
        __p, newMember.key, Base.__payload_(newMember))
      guard !__inserted else { return nil }
      let oldMember = Base.__payload_(__r)
      Base.__payload_ptr(__r).pointee = Base.__payload_(newMember)
      return Base.__element_(oldMember)
    }
  }
#endif

extension RedBlackTreeDictionary {

  /// Updates the value stored in the dictionary for the given key, or adds a new key-value pair if the key does not exist.
  ///
  /// - Parameters:
  ///   - value: The value to store.
  ///   - key: The key whose value to update.
  /// - Returns: The previous value, or `nil` if a new key-value pair was inserted.
  /// - Complexity: O(log *n*)
  @inlinable
  @discardableResult
  public mutating func updateValue(
    _ value: Value,
    forKey key: Key
  ) -> Value? {
    __tree_.ensureUniqueAndCapacity()
    let (__r, __inserted) = __tree_.__insert_unique(Base.__payload_((key, value)))
    guard !__inserted else { return nil }
    let oldMember = Base.__mapped_value_(__r)
    Base.__mapped_value_ptr(__r).pointee = value
    return oldMember
  }
}

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeDictionary {

    /// Updates or inserts a value, using `hint` as a suggested insertion position.
    ///
    /// - Parameters:
    ///   - value: The value to store.
    ///   - key: The key whose value to update.
    ///   - hint: A valid index of this dictionary to use as an insertion hint.
    /// - Returns: The previous value, or `nil` if a new key-value pair was inserted.
    /// - Precondition: `hint` is valid for this dictionary.
    @inlinable
    @discardableResult
    public mutating func updateValue(
      _ value: Value,
      forKey key: Key,
      hint: Index
    ) -> Value? {
      __tree_.ensureUniqueAndCapacity()
      let p = __tree_.__purified_(hint)
      // endIndex is a valid insertion hint; do not require element accessibility here.
      guard let __p = p.pointer else {
        fatalError(.invalidIndex)
      }
      let (__r, __inserted) = __tree_.___emplace_hint_unique_(
        __p, key, Base.__payload_((key, value)))
      guard !__inserted else { return nil }
      let oldMember = Base.__mapped_value_(__r)
      Base.__mapped_value_ptr(__r).pointee = value
      return oldMember
    }
  }
#endif

// MARK: - Remove

extension RedBlackTreeDictionary {

  /// Removes and returns the key-value pair with the least key.
  ///
  /// Returns `nil` if the dictionary is empty.
  ///
  /// - Returns: The removed key-value pair, or `nil` if the dictionary was empty.
  /// - Complexity: Amortized O(1)
  @inlinable
  public mutating func popFirst() -> Element? {
    guard __tree_.count > 0 else { return nil }
    __tree_.ensureUnique()
    return __tree_.___unchecked_remove_first().map { Base.__element_($0) }
  }
}

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeDictionary {

    /// Removes and returns the key-value pair with the greatest key.
    ///
    /// Returns `nil` if the dictionary is empty.
    ///
    /// - Returns: The removed key-value pair, or `nil` if the dictionary was empty.
    /// - Complexity: O(log `count`)
    @inlinable
    public mutating func popLast() -> Element? {
      guard __tree_.count > 0 else { return nil }
      __tree_.ensureUnique()
      return __tree_.___unchecked_remove_last().map { Base.__element_($0) }
    }
  }
#endif

extension RedBlackTreeDictionary {

  /// Removes and returns the key-value pair with the least key.
  ///
  /// - Returns: The removed key-value pair.
  /// - Precondition: The dictionary isn't empty.
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
  extension RedBlackTreeDictionary {

    /// Removes and returns the key-value pair with the greatest key.
    ///
    /// - Returns: The removed key-value pair.
    /// - Precondition: The dictionary isn't empty.
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

extension RedBlackTreeDictionary {

  /// Removes the key-value pair at the given index of the dictionary.
  ///
  /// - Parameter index: A valid index of the dictionary. The index must refer
  ///   to an element, not the dictionary's `endIndex`.
  /// - Returns: The removed key-value pair.
  /// - Precondition: `index` is valid for this dictionary and isn't `endIndex`.
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

extension RedBlackTreeDictionary {

  /// Removes the key-value pair for the specified key.
  ///
  /// - Parameter key: The key to remove along with its value.
  /// - Returns: The removed value, or `nil` if the key wasn't present.
  /// - Important: Indices that refer to removed members become invalid.
  /// - Complexity: O(log *n*)
  @inlinable
  @discardableResult
  public mutating func removeValue(forKey key: Key) -> Value? {
    guard __tree_.count > 0 else { return nil }
    __tree_.ensureUnique()
    return __tree_.update {
      let __i = $0.find(key)
      if __i == $0.end {
        return nil
      }
      let value = Base.__mapped_value_(__i)
      _ = $0.erase(__i)
      return value
    }
  }
}

extension RedBlackTreeDictionary {

  /// Removes all key-value pairs from the dictionary.
  ///
  /// - Parameter keepCapacity: Pass `true` to retain the dictionary's
  ///   allocated storage for later use.
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

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeDictionary {

    /// Removes the key-value pair at the given position from the dictionary and returns the index of the next element.
    ///
    /// - Parameter ptr: A valid index of the dictionary. The index must refer
    ///   to an element, not the dictionary's `endIndex`.
    /// - Returns: The index that followed `ptr` before removal, or `endIndex`
    ///   if the removed key-value pair was last.
    /// - Precondition: `ptr` is valid for this dictionary and isn't `endIndex`.
    /// - Complexity: Amortized O(1)
    @discardableResult
    @inlinable
    public mutating func erase(_ ptr: Index) -> Index {
      ___index(__tree_.erase(__tree_.__purified_(ptr).accessible.pointer!))
    }
  }

  extension RedBlackTreeDictionary {

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
#endif

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
/// ## Declaration
///
/// Use `RedBlackTreeMultiMap` with `import AcCollections`.
///
/// ## Overview
///
/// A red-black-tree multimap that orders pairs by key and retains multiple values for the same key. Each pair is a separate element. Ordinary insertion preserves insertion order within an equivalent-key group; a valid hint satisfying the ordering conditions can insert within that group.
///
/// Unlike `Dictionary` or `RedBlackTreeDictionary`, it retains duplicate keys. Unlike `Dictionary<Key, [Value]>`, it represents each pair as an individual tree position. It suits ordered searches, traversal, and removal of groups of values.
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
/// ## Creating a Multimap
///
/// Create an empty instance, use a literal, or initialize from an input sequence. `init(minimumCapacity:)` sets initial capacity and `reserveCapacity(_:)` reserves storage. `capacity` is distinct from the element count. Array literals, dictionary literals, and `init(keysWithValues:)` retain duplicate keys. `init(grouping:by:)` assigns a key to each source value and retains individual pairs rather than grouping values into arrays.
///
/// ## Searching and Accessing Elements
///
/// `contains(key:)` checks membership and `count(forKey:)` returns the number of matches. `first` / `last` and `min()` / `max()` access the endpoints. `firstIndex(of:)` returns `nil` when absent; `find(_:)` returns `endIndex`. `lowerBound(_:)` finds the first key greater than or equal to its argument, and `upperBound(_:)` the first strictly greater key; both return the end if none exists. `equalRange(_:)` returns the half-open range of all matching pairs. Move forward or backward from search results within the endpoint preconditions; the end cannot be dereferenced as an element.
///
/// ## Key Access and Views
///
/// Key subscripting returns a `RedBlackTreeMappedValuesView`, not a single value or pair view. It represents values for one key without copying them into an array. To traverse pairs, use `map[map.equalRange(key)]`, a `RedBlackTreeKeyValueRangeView`; its `keys` traverses keys lazily and its `values` exposes mapped values.
///
/// Keys determine ordering and are not mutable through the view. `Value` need not be Comparable. A mapped view supports value updates, `swapAt(_:_:)`, and removal; removing a value also removes its pair. Supply two element indices within the view to swap. Mutation directly through `map[key]` changes the base; mutation of a separately stored view does not.
///
/// ## Insertion, Updating, and Removal
///
/// `insert(key:value:)` / `insert(_:)` add a pair even when its key already exists. `insert(_:hint:)` can insert immediately before a valid hint when the ordering conditions fit. A valid hint that does not satisfy those ordering conditions affects only performance; insertion still uses the normal ordered position. An invalid hint violates a precondition. `updateValue(_:at:)` replaces only the mapped value at an index and returns its old value, or `nil` for an invalid index.
///
/// `eraseUnique(_:)` removes one matching pair; `eraseMulti(_:)` removes all. `popFirst()` / `popLast()` return `nil` when empty; `removeFirst()` / `removeLast()` require a nonempty map. Predicate removal, range/view removal, and `removeAll(keepingCapacity:)` are supported. For sequential removal use the next index returned by `erase(_:) -> Index`. `index(inserting:)` returns an insertion result and index. `erase(exactly:)` removes the indexed element and returns the next index, or `nil` if the index is not accessible in this map.
///
/// ```swift
/// var map: RedBlackTreeMultiMap<Int, String> =
///   [1: "b", 1: "d", 3: "a", 4: "c", 5: "e"]
/// map.eraseUnique(3) // -> [1: "b", 1: "d", 4: "c", 5: "e"]
/// ```
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
/// ```swift
/// var map: RedBlackTreeMultiMap<Int, String> =
///   [1: "b", 1: "d", 3: "a", 4: "c", 5: "e"]
/// var i = map.startIndex
/// while i != map.endIndex {
///   i = map.erase(i)
/// }
/// ```
///
/// ## Combining Multimaps
///
/// `insert(contentsOf:)` inserts into this value; `inserting(contentsOf:)` returns the result. These operations insert elements into existing storage, copying it first when shared. `meld(_:)` replaces this value with the combined result; `melding(_:)` returns a result. Both traverse two sorted trees and build new storage. Spare capacity alone is not a reason to prefer meld. Inputs can be multimaps or sequences of pairs; every pair is retained, including duplicate keys.
///
/// ## Transforming and Iterating
///
/// Elements are `(key: Key, value: Value)` pairs, iterated in ascending key order. `filter(_:)` retains selected pairs; `mapValues(_:)` transforms their values; `compactMapValues(_:)` omits pairs whose transformed value is `nil`. Retained pairs preserve key order and duplicates. `sorted()` / `reversed()` return ascending / descending arrays.
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
/// var map: RedBlackTreeMultiMap<Int, String> =
///   [1: "b", 1: "d", 3: "a", 4: "c", 5: "e"]
/// print(map[.start.advanced(by: 1)]) // Optional containing (1, "d")
/// ```
///
/// ```swift
/// var map: RedBlackTreeMultiMap<Int, String> =
///   [1: "b", 1: "d", 3: "a", 4: "c", 5: "e"]
/// print(map[.lowerBound(5)]) // Optional containing (5, "e")
/// print(map[.upperBound(5)]) // -> nil (equivalent to end)
/// print(map[.find(2)])       // -> nil (not found)
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
/// | Lookup and removal/processing of K matching elements | O(log n + K) |
/// | `insert(contentsOf:)`, `inserting(contentsOf:)` (n incoming, m existing) | O(n log(m+n)), plus storage-copy costs |
/// | `meld`, `melding` | O(n+m), new storage |
/// | `filter`, `mapValues`, `compactMapValues` | O(n), plus closure costs |
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

#if !COMPATIBLE_ATCODER_2025
//  extension RedBlackTreeMultiMap {
//
//    /// - Complexity: O(log *n*)
//    @inlinable
//    public func values(forKey key: Key) -> [_MappedValue] {
//      let (lo, hi) = __tree_.__equal_range_multi(key)
//      return __tree_.___copy_to_array(lo, hi) { Base.__mapped_value_($0) }
//    }
//  }
#endif

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

#if !COMPATIBLE_ATCODER_2025
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
#endif

#if !COMPATIBLE_ATCODER_2025
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
#endif

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

#if !COMPATIBLE_ATCODER_2025
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
#endif

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

#if !COMPATIBLE_ATCODER_2025
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
#endif

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

#if !COMPATIBLE_ATCODER_2025
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
#endif

#if !COMPATIBLE_ATCODER_2025
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
#endif

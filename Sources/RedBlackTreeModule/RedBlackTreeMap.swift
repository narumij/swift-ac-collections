// Copyright 2024 narumij
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

/// `RedBlackTreeMap` は、`Key` 型のキーと `Value` 型の値のペアをキーに対して一意に格納するための
/// 赤黒木（Red-Black Tree）ベースのマップ型です。
///
/// ### 使用例
/// ```swift
/// /// `RedBlackTreeMap` を使用する例
/// var map = RedBlackTreeMap<String, Int>()
/// map["apple"] = 5
/// map["banana"] = 3
/// map["cherry"] = 7
///
/// // キーを使用して値にアクセス
/// if let value = map.value(forKey: "banana") {
///     print("banana の値は \(value) です。") // 出力例: banana の値は 3 です。
/// }
///
/// // キーと値のペアを削除
/// map.remove(key: "apple")
/// ```
@frozen
public struct RedBlackTreeMap<Key: Comparable, Value> {

  /// - Important:
  ///  要素及びノードが削除された場合、インデックスは無効になります。
  /// 無効なインデックスを使用するとランタイムエラーや不正な参照が発生する可能性があるため注意してください。
  public
    typealias Index = Tree.Index

  public
//    typealias KeyValue = (key: Key, value: Value)
  typealias KeyValue = Pair<Key, Value>

  public
    typealias Element = KeyValue

  public
    typealias Keys = KeyIterator<Tree, Key, Value>

  public
    typealias Values = ValueIterator<Tree, Key, Value>

  public
    typealias _Key = Key

  public
    typealias _MappedValue = Value

  public
    typealias _Value = Element

  @usableFromInline
  var _storage: Tree.Storage

  @inlinable @inline(__always)
  init(_storage: Tree.Storage) {
    self._storage = _storage
  }
}

extension RedBlackTreeMap: ___RedBlackTreeBase {}
extension RedBlackTreeMap: ___RedBlackTreeCopyOnWrite {}
extension RedBlackTreeMap: ___RedBlackTreeUnique {}
extension RedBlackTreeMap: ___RedBlackTreeMerge {}
extension RedBlackTreeMap: ___RedBlackTreeSequence {}
extension RedBlackTreeMap: ___RedBlackTreeSubSequence {}
extension RedBlackTreeMap: KeyValueComparer {}

// MARK: - Creating a Dictionay

extension RedBlackTreeMap {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public init() {
    self.init(minimumCapacity: 0)
  }

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public init(minimumCapacity: Int) {
    _storage = .create(withCapacity: minimumCapacity)
  }
}

extension RedBlackTreeMap {

  /// - Complexity: O(*n* log *n* + *n*)
  @inlinable
  public init<S>(uniqueKeysWithValues keysAndValues: __owned S)
  where S: Sequence, S.Element == KeyValue {
    let elements = keysAndValues.sorted(by: { $0.key < $1.key })
    let count = elements.count
    let tree: Tree = .create(minimumCapacity: count)
    // 初期化直後はO(1)
    var (__parent, __child) = tree.___max_ref()
    // ソートの計算量がO(*n* log *n*)
    for __k in elements {
      if __parent == .end || tree[__parent].key != __k.key {
        // バランシングの最悪計算量が結局わからず、ならしO(1)とみている
        (__parent, __child) = tree.___emplace_hint_right(__parent, __child, __k)
      } else {
        fatalError("Dupricate values for key: '\(__k.key)'")
      }
    }
    assert(tree.__tree_invariant(tree.__root()))
    self._storage = .init(tree: tree)
  }
  
  /// - Complexity: O(*n* log *n* + *n*)
  @inlinable
  public init<S>(uniqueKeysWithValues keysAndValues: __owned S)
  where S: Sequence, S.Element == (Key, Value) {
    let elements = keysAndValues.sorted(by: { $0.0 < $1.0 })
    let count = elements.count
    let tree: Tree = .create(minimumCapacity: count)
    // 初期化直後はO(1)
    var (__parent, __child) = tree.___max_ref()
    // ソートの計算量がO(*n* log *n*)
    for __k in elements {
      if __parent == .end || tree[__parent].key != __k.0 {
        // バランシングの最悪計算量が結局わからず、ならしO(1)とみている
        (__parent, __child) = tree.___emplace_hint_right(__parent, __child, .init(__k))
      } else {
        fatalError("Dupricate values for key: '\(__k.0)'")
      }
    }
    assert(tree.__tree_invariant(tree.__root()))
    self._storage = .init(tree: tree)
  }
}

extension RedBlackTreeMap {

  /// - Complexity: O(*n* log *n* + *n*)
  @inlinable
  public init<S>(
    _ keysAndValues: __owned S,
    uniquingKeysWith combine: (Value, Value) throws -> Value
  ) rethrows where S: Sequence, S.Element == (Key, Value) {
    let elements = keysAndValues.sorted(by: { $0.0 < $1.0 })
    let count = elements.count
    let tree: Tree = .create(minimumCapacity: count)
    // 初期化直後はO(1)
    var (__parent, __child) = tree.___max_ref()
    // ソートの計算量がO(*n* log *n*)
    for __k in elements {
      if __parent == .end || tree[__parent].key != __k.0 {
        // バランシングの最悪計算量が結局わからず、ならしO(1)とみている
        (__parent, __child) = tree.___emplace_hint_right(__parent, __child, .init(__k))
      } else {
        tree[__parent].value = try combine(tree[__parent].value, __k.1)
      }
    }
    assert(tree.__tree_invariant(tree.__root()))
    self._storage = .init(tree: tree)
  }
}

extension RedBlackTreeMap {

  /// - Complexity: O(*n* log *n* + *n*)
  @inlinable
  public init<S: Sequence>(
    grouping values: __owned S,
    by keyForValue: (S.Element) throws -> Key
  ) rethrows where Value == [S.Element] {
    let values = try values.sorted(by: { try keyForValue($0) < keyForValue($1) })
    let count = values.count
    let tree: Tree = .create(minimumCapacity: count)
    // 初期化直後はO(1)
    var (__parent, __child) = tree.___max_ref()
    // ソートの計算量がO(*n* log *n*)
    for __v in values {
      let __k = try keyForValue(__v)
      if __parent == .end || tree[__parent].key != __k {
        // バランシングの最悪計算量が結局わからず、ならしO(1)とみている
        (__parent, __child) = tree.___emplace_hint_right(__parent, __child, .init(__k, [__v]))
      } else {
        tree[__parent].value.append(__v)
      }
    }
    assert(tree.__tree_invariant(tree.__root()))
    self._storage = .init(tree: tree)
  }
}

// MARK: - Inspecting a MultiMap

extension RedBlackTreeMap {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public var isEmpty: Bool {
    ___is_empty
  }

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public var capacity: Int {
    ___capacity
  }

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public var count: Int {
    ___count
  }
}

extension RedBlackTreeMap {

  /// - Complexity: O(log *n* + *k*)
  @inlinable
  public func count(forKey key: Key) -> Int {
    __tree_.__count_unique(key)
  }
}

// MARK: - Accessing Keys and Values

extension RedBlackTreeMap {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public var first: Element? {
    ___first
  }

  /// - Complexity: O(log *n*)
  @inlinable
  public var last: Element? {
    ___last
  }
}

extension RedBlackTreeMap {

  @frozen
  @usableFromInline
  struct ___ModifyHelper {
    @inlinable
    @inline(__always)
    init(pointer: UnsafeMutablePointer<Value>) {
      self.pointer = pointer
    }
    @usableFromInline
    var isNil: Bool = false
    @usableFromInline
    var pointer: UnsafeMutablePointer<Value>
    @inlinable
    var value: Value? {
      @inline(__always) _read {
        yield isNil ? nil : pointer.pointee
      }
      @inline(__always) _modify {
        var value: Value? = pointer.move()
        defer {
          if let value {
            isNil = false
            pointer.initialize(to: value)
          } else {
            isNil = true
          }
        }
        yield &value
      }
    }
  }

  /// - Complexity: O(log *n*)
  @inlinable
  public subscript(key: Key) -> Value? {
    @inline(__always) _read {
      yield ___value_for(key)?.value
    }
    @inline(__always) _modify {
      // TODO: もうすこしライフタイム管理に明るくなったら、再度ここのチューニングに取り組む
      let (__parent, __child, __ptr) = _prepareForKeyingModify(key)
      if __ptr == .nullptr {
        var value: Value?
        defer {
          if let value {
            _ensureUniqueAndCapacity()
            let __h = __tree_.__construct_node(.init(key, value))
            __tree_.__insert_node_at(__parent, __child, __h)
          }
        }
        yield &value
      } else {
        _ensureUnique()
        var helper = ___ModifyHelper(pointer: &__tree_[__ptr].value)
        defer {
          if helper.isNil {
            _ = __tree_.erase(__ptr)
          }
        }
        yield &helper.value
      }
    }
  }

  /// - Complexity: O(log *n*)
  @inlinable
  public subscript(
    key: Key, default defaultValue: @autoclosure () -> Value
  ) -> Value {
    @inline(__always) _read {
      yield ___value_for(key)?.value ?? defaultValue()
    }
    @inline(__always) _modify {
      defer { _fixLifetime(self) }
      var (__parent, __child, __ptr) = _prepareForKeyingModify(key)
      if __ptr == .nullptr {
        _ensureUniqueAndCapacity()
        assert(__tree_.header.capacity > __tree_.count)
        __ptr = __tree_.__construct_node(.init(key, defaultValue()))
        __tree_.__insert_node_at(__parent, __child, __ptr)
      } else {
        _ensureUnique()
      }
      yield &__tree_[__ptr].value
    }
  }

  @inlinable
  @inline(__always)
  internal func _prepareForKeyingModify(
    _ key: Key
  ) -> (__parent: _NodePtr, __child: _NodeRef, __ptr: _NodePtr) {
    var __parent = _NodePtr.nullptr
    let __child = __tree_.__find_equal(&__parent, key)
    let __ptr = __tree_.__ptr_(__child)
    return (__parent, __child, __ptr)
  }
}

// MARK: - Range Accessing Keys and Values

extension RedBlackTreeMap {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public subscript(bounds: Range<Index>) -> SubSequence {
    __tree_.___ensureValidRange(
      begin: bounds.lowerBound.rawValue,
      end: bounds.upperBound.rawValue)

    return .init(
      tree: __tree_,
      start: bounds.lowerBound.rawValue,
      end: bounds.upperBound.rawValue)
  }

  /// - Warning: This subscript trades safety for performance. Using an invalid index results in undefined behavior.
  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public subscript(unchecked bounds: Range<Index>) -> SubSequence {
    .init(
      tree: __tree_,
      start: bounds.lowerBound.rawValue,
      end: bounds.upperBound.rawValue)
  }
}

// MARK: - Insert

extension RedBlackTreeMap {
  // multi mapとの統一感のために復活

  /// - Complexity: O(log *n*)
  @inlinable
  @inline(__always)
  @discardableResult
  public mutating func insert(key: Key, value: Value) -> (
    inserted: Bool, memberAfterInsert: Element
  ) {
    insert(.init(key, value))
  }
  
  /// - Complexity: O(log *n*)
  @inlinable
  @inline(__always)
  @discardableResult
  public mutating func insert(_ tuple: (key: Key, value: Value)) -> (
    inserted: Bool, memberAfterInsert: Element
  ) {
    insert(.init(tuple))
  }

  /// - Complexity: O(log *n*)
  @inlinable
  @inline(__always)
  @discardableResult
  public mutating func insert(_ newMember: Element) -> (
    inserted: Bool, memberAfterInsert: Element
  ) {
    _ensureUniqueAndCapacity()
    _ = __tree_.__insert_unique(newMember)
    return (true, newMember)
  }
}

extension RedBlackTreeMap {

  /// - Complexity: O(log *n*)
  @inlinable
  @inline(__always)
  @discardableResult
  public mutating func updateValue(
    _ value: Value,
    forKey key: Key
  ) -> Value? {
    _ensureUniqueAndCapacity()
    let (__r, __inserted) = __tree_.__insert_unique(.init(key, value))
    guard !__inserted else { return nil }
    let oldMember = __tree_[__r]
    __tree_[__r] = .init(key, value)
    return oldMember.value
  }
}

extension RedBlackTreeMap {

  @inlinable
  public mutating func reserveCapacity(_ minimumCapacity: Int) {
    _ensureUniqueAndCapacity(to: minimumCapacity)
  }
}

// MARK: - Combining Dictionary

extension RedBlackTreeMap {

  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  @inlinable
  public mutating func merge(
    _ other: RedBlackTreeMap<Key, Value>,
    uniquingKeysWith combine: (Value, Value) throws -> Value
  ) rethrows {
    _ensureUnique()
    try ___tree_merge_unique(other.__tree_, uniquingKeysWith: combine)
  }

  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  @inlinable
  public mutating func merge(
    _ other: RedBlackTreeMultiMap<Key, Value>,
    uniquingKeysWith combine: (Value, Value) throws -> Value
  ) rethrows {
    _ensureUnique()
    try ___tree_merge_unique(other.__tree_, uniquingKeysWith: combine)
  }

  /// mapに `other` の要素をマージします。
  /// キーが重複したときは `combine` の戻り値を採用します。
  ///
  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  @inlinable
  public mutating func merge<S>(
    _ other: __owned S,
    uniquingKeysWith combine: (Value, Value) throws -> Value
  ) rethrows where S: Sequence, S.Element == (Key, Value) {

    _ensureUnique()
    try ___merge_unique(other.map({ Pair($0) }), uniquingKeysWith: combine)
  }

  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  @inlinable
  public func merging(
    _ other: RedBlackTreeMap<Key, Value>,
    uniquingKeysWith combine: (Value, Value) throws -> Value
  ) rethrows -> Self {
    var result = self
    try result.merge(other, uniquingKeysWith: combine)
    return result
  }

  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  @inlinable
  public func merging(
    _ other: RedBlackTreeMultiMap<Key, Value>,
    uniquingKeysWith combine: (Value, Value) throws -> Value
  ) rethrows -> Self {
    var result = self
    try result.merge(other, uniquingKeysWith: combine)
    return result
  }

  /// `self` と `other` をマージした新しいmapを返します。
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

extension RedBlackTreeMap {

  /// 最小キーのペアを取り出して削除
  ///
  /// - Important: 削除したメンバーを指すインデックスが無効になります。
  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public mutating func popFirst() -> KeyValue? {
    guard !isEmpty else { return nil }
    return remove(at: startIndex)
  }
}

extension RedBlackTreeMap {

  /// - Important: 削除したメンバーを指すインデックスが無効になります。
  /// - Complexity: O(log *n*)
  @inlinable
  @inline(__always)
  @discardableResult
  public mutating func removeValue(forKey __k: Key) -> Value? {
    let __i = __tree_.find(__k)
    if __i == __tree_.end() {
      return nil
    }
    let value = __tree_.__value_(__i).value
    _ensureUnique()
    _ = __tree_.erase(__i)
    return value
  }

  /// - Important: 削除したメンバーを指すインデックスが無効になります。
  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  @discardableResult
  public mutating func removeFirst() -> Element {
    guard !isEmpty else {
      preconditionFailure(.emptyFirst)
    }
    return remove(at: startIndex)
  }

  /// - Important: 削除したメンバーを指すインデックスが無効になります。
  /// - Complexity: O(log *n*)
  @inlinable
  @discardableResult
  public mutating func removeLast() -> Element {
    guard !isEmpty else {
      preconditionFailure(.emptyLast)
    }
    return remove(at: index(before: endIndex))
  }

  /// - Important: 削除後は、インデックスが無効になります。
  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  @discardableResult
  public mutating func remove(at index: Index) -> KeyValue {
    _ensureUnique()
    guard let element = ___remove(at: index.rawValue) else {
      fatalError(.invalidIndex)
    }
    return element
  }

  /// Removes the specified subrange of elements from the collection.
  ///
  /// - Important: 削除後は、subrangeのインデックスが無効になります。
  /// - Parameter bounds: The subrange of the collection to remove. The bounds of the
  ///     range must be valid indices of the collection.
  /// - Returns: The key-value pair that correspond to `index`.
  /// - Complexity: O(`m ) where  `m` is the size of `bounds`
  @inlinable
  public mutating func removeSubrange<R: RangeExpression>(
    _ bounds: R
  ) where R.Bound == Index {

    let bounds = bounds.relative(to: self)
    _ensureUnique()
    ___remove(
      from: bounds.lowerBound.rawValue,
      to: bounds.upperBound.rawValue)
  }
}

extension RedBlackTreeMap {

  /// - Important: 削除したメンバーを指すインデックスが無効になります。
  /// - Complexity: O(log *n* + *k*)
  @inlinable
  @inline(__always)
  public mutating func remove(contentsOf keyRange: Range<Key>) {
    _strongEnsureUnique()
    let lower = ___lower_bound(keyRange.lowerBound)
    let upper = ___lower_bound(keyRange.upperBound)
    ___remove(from: lower, to: upper)
  }

  /// - Important: 削除したメンバーを指すインデックスが無効になります。
  /// - Complexity: O(log *n* + *k*)
  @inlinable
  @inline(__always)
  public mutating func remove(contentsOf keyRange: ClosedRange<Key>) {
    _strongEnsureUnique()
    let lower = ___lower_bound(keyRange.lowerBound)
    let upper = ___upper_bound(keyRange.upperBound)
    ___remove(from: lower, to: upper)
  }
}

extension RedBlackTreeMap {

  /// - Complexity: O(1)
  @inlinable
  public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
    _ensureUnique()
    ___removeAll(keepingCapacity: keepCapacity)
  }
}

// MARK: Finding Elements

extension RedBlackTreeMap {

  /// - Complexity: O(log *n*)
  @inlinable
  public func contains(key: Key) -> Bool {
    ___contains(key)
  }
}

extension RedBlackTreeMap {

  /// - Complexity: O(log *n*)
  @inlinable
  public func lowerBound(_ p: Key) -> Index {
    ___index_lower_bound(p)
  }

  /// - Complexity: O(log *n*)
  @inlinable
  public func upperBound(_ p: Key) -> Index {
    ___index_upper_bound(p)
  }
}

extension RedBlackTreeMap {

  /// - Complexity: O(log *n*)
  @inlinable
  public func equalRange(_ key: Key) -> (lower: Index, upper: Index) {
    ___index_equal_range(key)
  }
}

extension RedBlackTreeMap {

  /// - Complexity: O(log *n*)
  ///
  /// O(1)が欲しい場合、firstが等価でO(1)
  @inlinable
  public func min() -> Element? {
    ___min()
  }

  /// - Complexity: O(log *n*)
  @inlinable
  public func max() -> Element? {
    ___max()
  }
}

extension RedBlackTreeMap {

  /// - Complexity: O(*n*)
  @inlinable
  public func first(where predicate: (Element) throws -> Bool) rethrows -> Element? {
    try ___first(where: predicate)
  }
}

extension RedBlackTreeMap {

  /// - Complexity: O(log *n*)
  @inlinable
  public func firstIndex(of key: Key) -> Index? {
    ___first_index(of: key)
  }

  /// - Complexity: O(*n*)
  @inlinable
  public func firstIndex(where predicate: (Element) throws -> Bool) rethrows -> Index? {
    try ___first_index(where: predicate)
  }
}

extension RedBlackTreeMap {

  // setやmultisetと比べて、驚き最小違反とはいいにくいので、deprecatedには一旦しない
  /// 範囲 `[lower, upper)` に含まれる要素を返します。
  /// - Complexity: O(log *n*)
  @inlinable
  @inline(__always)
  public subscript(bounds: Range<Key>) -> SubSequence {
    elements(in: bounds)
  }

  // setやmultisetと比べて、驚き最小違反とはいいにくいので、deprecatedには一旦しない
  /// 範囲 `[lower, upper]` に含まれる要素を返します。
  /// - Complexity: O(log *n*)
  @inlinable
  @inline(__always)
  public subscript(bounds: ClosedRange<Key>) -> SubSequence {
    elements(in: bounds)
  }
}

extension RedBlackTreeMap {
  /// キーレンジ `[lower, upper)` に含まれる要素のスライス
  /// - Complexity: O(log *n*)
  @inlinable
  public func elements(in range: Range<Key>) -> SubSequence {
    .init(
      tree: __tree_,
      start: ___lower_bound(range.lowerBound),
      end: ___lower_bound(range.upperBound))
  }

  /// キーレンジ `[lower, upper]` に含まれる要素のスライス
  /// - Complexity: O(log *n*)
  @inlinable
  public func elements(in range: ClosedRange<Key>) -> SubSequence {
    .init(
      tree: __tree_,
      start: ___lower_bound(range.lowerBound),
      end: ___upper_bound(range.upperBound))
  }
}

// MARK: - Transformation

extension RedBlackTreeMap {

  /// - Complexity: O(*n*)
  @inlinable
  public func filter(
    _ isIncluded: (Element) throws -> Bool
  ) rethrows -> Self {
    .init(_storage: .init(tree: try __tree_.___filter(isIncluded)))
  }
}

extension RedBlackTreeMap {

  /// - Complexity: O(*n*)
  @inlinable
  public func mapValues<T>(_ transform: (Value) throws -> T) rethrows
    -> RedBlackTreeMap<Key, T>
  {
    .init(_storage: .init(tree: try __tree_.___mapValues(transform)))
  }

  /// - Complexity: O(*n*)
  @inlinable
  public func compactMapValues<T>(_ transform: (Value) throws -> T?)
    rethrows -> RedBlackTreeMap<Key, T>
  {
    .init(_storage: .init(tree: try __tree_.___compactMapValues(transform)))
  }
}

// MARK: - Collection Conformance

// MARK: - Sequence
// MARK: - Collection
// MARK: - BidirectionalCollection

extension RedBlackTreeMap: Sequence, Collection, BidirectionalCollection {}

// MARK: - SubSequence

extension RedBlackTreeMap {

  @frozen
  public struct SubSequence {

    @usableFromInline
    let __tree_: Tree

    @usableFromInline
    var _start, _end: _NodePtr

    @inlinable
    @inline(__always)
    internal init(tree: Tree, start: _NodePtr, end: _NodePtr) {
      __tree_ = tree
      _start = start
      _end = end
    }
  }
}

extension RedBlackTreeMap.SubSequence: Equatable where Value: Equatable {

  /// - Complexity: O(*m*), where *m* is the lesser of the length of `lhs` and `rhs`.
  @inlinable
  @inline(__always)
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.elementsEqual(rhs)
  }
}

extension RedBlackTreeMap.SubSequence: Comparable where Value: Comparable {

  /// - Complexity: O(*m*), where *m* is the lesser of the length of `lhs` and `rhs`.
  @inlinable
  @inline(__always)
  public static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.lexicographicallyPrecedes(rhs)
  }
}

extension RedBlackTreeMap.SubSequence where Value: Equatable {

  /// - Complexity: O(*m*), where *m* is the lesser of the length of the
  ///   sequence and the length of `other`.
  @inlinable
  @inline(__always)
  public func elementsEqual<OtherSequence>(_ other: OtherSequence) -> Bool
  where OtherSequence: Sequence, Element == OtherSequence.Element {
    elementsEqual(other, by: Tree.___element_equiv)
  }
}

extension RedBlackTreeMap.SubSequence where Value: Comparable {

  /// - Complexity: O(*m*), where *m* is the lesser of the length of the
  ///   sequence and the length of `other`.
  @inlinable
  @inline(__always)
  public func lexicographicallyPrecedes<OtherSequence>(_ other: OtherSequence) -> Bool
  where OtherSequence: Sequence, Element == OtherSequence.Element {
    lexicographicallyPrecedes(other, by: Tree.___element_comp)
  }
}

extension RedBlackTreeMap.SubSequence: ___SubSequenceBase {
  public typealias Base = RedBlackTreeMap
  public typealias Element = Tree.Element
  public typealias Indices = Tree.Indices
}

extension RedBlackTreeMap.SubSequence: Sequence, Collection, BidirectionalCollection {
  public typealias Index = RedBlackTreeMap.Index
  public typealias SubSequence = Self
}

// MARK: - Index Range

extension RedBlackTreeMap {

  public typealias Indices = Tree.Indices
}

// MARK: - ExpressibleByDictionaryLiteral

extension RedBlackTreeMap: ExpressibleByDictionaryLiteral {

  /// - Complexity: O(*n* log *n*)
  @inlinable
  @inline(__always)
  public init(dictionaryLiteral elements: (Key, Value)...) {
    self.init(uniqueKeysWithValues: elements)
  }
}

// MARK: - ExpressibleByArrayLiteral

extension RedBlackTreeMap: ExpressibleByArrayLiteral {

  /// `[("key", value), ...]` 形式のリテラルからmapを生成します。
  ///
  /// - Important: キーが重複していた場合は
  ///   `Dictionary(uniqueKeysWithValues:)` と同じく **ランタイムエラー** になります。
  ///   （重複を許容してマージしたい場合は `merge` / `merging` を使ってください）
  ///
  /// 使用例
  /// ```swift
  /// let d: RedBlackTreeMap = [("a", 1), ("b", 2)]
  /// ```
  /// - Complexity: O(*n* log *n*)
  @inlinable
  @inline(__always)
  public init(arrayLiteral elements: (Key, Value)...) {
    self.init(uniqueKeysWithValues: elements)
  }
}

// MARK: - CustomStringConvertible

extension RedBlackTreeMap: CustomStringConvertible {

  @inlinable
  public var description: String {
    if isEmpty { return "[:]" }
    var result = "["
    var first = true
    for kv in self {
      let (key, value) = (kv.key, kv.value)
      if first {
        first = false
      } else {
        result += ", "
      }
      result += "\(key): \(value)"
    }
    result += "]"
    return result
  }
}

// MARK: - CustomDebugStringConvertible

extension RedBlackTreeMap: CustomDebugStringConvertible {

  public var debugDescription: String {
    var result = "RedBlackTreeMap<\(Key.self), \(Value.self)>("
    if isEmpty {
      result += "[:]"
    } else {
      result += "["
      var first = true
      for kv in self {
        let (key, value) = (kv.key, kv.value)
        if first {
          first = false
        } else {
          result += ", "
        }

        debugPrint(key, value, separator: ": ", terminator: "", to: &result)
      }
      result += "]"
    }
    result += ")"
    return result
  }
}

// MARK: - CustomReflectable

extension RedBlackTreeMap: CustomReflectable {
  /// The custom mirror for this instance.
  public var customMirror: Mirror {
    Mirror(self, unlabeledChildren: self, displayStyle: .dictionary)
  }
}

// MARK: - Is Identical To

extension RedBlackTreeMap {

  /// Returns a boolean value indicating whether this set is identical to
  /// `other`.
  ///
  /// Two set values are identical if there is no way to distinguish between
  /// them.
  ///
  /// For any values `a`, `b`, and `c`:
  ///
  /// - `a.isIdentical(to: a)` is always `true`. (Reflexivity)
  /// - `a.isIdentical(to: b)` implies `b.isIdentical(to: a)`. (Symmetry)
  /// - If `a.isIdentical(to: b)` and `b.isIdentical(to: c)` are both `true`,
  ///   then `a.isIdentical(to: c)` is also `true`. (Transitivity)
  /// - `a.isIdentical(b)` implies `a == b`
  ///   - `a == b` does not imply `a.isIdentical(b)`
  ///
  /// Values produced by copying the same value, with no intervening mutations,
  /// will compare identical:
  ///
  /// ```swift
  /// let d = c
  /// print(c.isIdentical(to: d))
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
  public func isIdentical(to other: Self) -> Bool {
    _isIdentical(to: other)
  }
}

// MARK: - Equatable

extension RedBlackTreeMap: Equatable where Value: Equatable {

  /// - Complexity: O(*m*), where *m* is the lesser of the length of `lhs` and `rhs`.
  @inlinable
  @inline(__always)
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.isIdentical(to: rhs) || lhs.count == rhs.count && lhs.elementsEqual(rhs)
  }
}

// MARK: - Comparable

extension RedBlackTreeMap: Comparable where Value: Comparable {

  /// - Complexity: O(*m*), where *m* is the lesser of the length of `lhs` and `rhs`.
  @inlinable
  @inline(__always)
  public static func < (lhs: Self, rhs: Self) -> Bool {
    !lhs.isIdentical(to: rhs) && lhs.lexicographicallyPrecedes(rhs)
  }
}

// MARK: -

extension RedBlackTreeMap where Value: Equatable {

  /// - Complexity: O(*m*), where *m* is the lesser of the length of the
  ///   sequence and the length of `other`.
  @inlinable
  @inline(__always)
  public func elementsEqual<OtherSequence>(_ other: OtherSequence) -> Bool
  where OtherSequence: Sequence, Element == OtherSequence.Element {
    elementsEqual(other, by: Tree.___element_equiv)
  }
}

extension RedBlackTreeMap where Value: Comparable {

  /// - Complexity: O(*m*), where *m* is the lesser of the length of the
  ///   sequence and the length of `other`.
  @inlinable
  @inline(__always)
  public func lexicographicallyPrecedes<OtherSequence>(_ other: OtherSequence) -> Bool
  where OtherSequence: Sequence, Element == OtherSequence.Element {
    lexicographicallyPrecedes(other, by: Tree.___element_comp)
  }
}

// MARK: - Sendable

#if swift(>=5.5)
  extension RedBlackTreeMap: @unchecked Sendable
  where Element: Sendable {}
#endif

#if swift(>=5.5)
  extension RedBlackTreeMap.SubSequence: @unchecked Sendable
  where Key: Sendable, Value: Sendable {}
#endif

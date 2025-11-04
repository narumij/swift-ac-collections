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
    typealias KeyValue = Pair<Key, Value>

  public
    typealias Element = KeyValue

  public
    typealias Keys = RedBlackTreeIterator<Self>.Keys

  public
    typealias Values = RedBlackTreeIterator<Self>.MappedValues

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
extension RedBlackTreeMap: ___RedBlackTreeSequenceBase {}
extension RedBlackTreeMap: KeyValueComparer {}
extension RedBlackTreeMap: ElementComparable where Value: Comparable {}
extension RedBlackTreeMap: ElementEqutable where Value: Equatable {}
extension RedBlackTreeMap: ElementHashable where Key: Hashable, Value: Hashable {}

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

    self._storage = .init(
      tree:
        .create_unique(
          sorted: keysAndValues.sorted { $0.key < $1.key }
        ) {
          $0
        })
  }

  /// - Complexity: O(*n* log *n* + *n*)
  @inlinable
  public init<S>(uniqueKeysWithValues keysAndValues: __owned S)
  where S: Sequence, S.Element == (Key, Value) {
    self._storage = .init(
      tree:
        .create_unique(
          sorted: keysAndValues.sorted { $0.0 < $1.0 }
        ) {
          Pair($0)
        })
  }
}

extension RedBlackTreeMap {

  /// - Complexity: O(*n* log *n* + *n*)
  @inlinable
  public init<S>(
    _ keysAndValues: __owned S,
    uniquingKeysWith combine: (Value, Value) throws -> Value
  ) rethrows where S: Sequence, S.Element == (Key, Value) {

    self._storage = .init(
      tree:
        try .create_unique(
          sorted: keysAndValues.sorted {
            $0.0 < $1.0
          },
          uniquingKeysWith: combine
        ) {
          Pair($0)
        })
  }
}

extension RedBlackTreeMap {

  /// - Complexity: O(*n* log *n* + *n*)
  @inlinable
  public init<S: Sequence>(
    grouping values: __owned S,
    by keyForValue: (S.Element) throws -> Key
  ) rethrows where Value == [S.Element] {

    self._storage = .init(
      tree: try .create_unique(
        sorted: try values.sorted {
          try keyForValue($0) < keyForValue($1)
        },
        by: keyForValue
      ))
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
    let (__parent, __child) = __tree_.__find_equal(key)
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
    __tree_.___ensureValid(
      begin: bounds.lowerBound.rawValue,
      end: bounds.upperBound.rawValue)

    return .init(
      tree: __tree_,
      start: bounds.lowerBound.rawValue,
      end: bounds.upperBound.rawValue)
  }

  @inlinable
  @inline(__always)
  public subscript<R>(bounds: R) -> SubSequence where R: RangeExpression, R.Bound == Index {
    let bounds: Range<Index> = bounds.relative(to: self)

    __tree_.___ensureValid(
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

  /// - Warning: This subscript trades safety for performance. Using an invalid index results in undefined behavior.
  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public subscript<R>(unchecked bounds: R) -> SubSequence where R: RangeExpression, R.Bound == Index
  {
    let bounds: Range<Index> = bounds.relative(to: self)
    return .init(
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
    let (__r, __inserted) = __tree_.__insert_unique(newMember)
    return (__inserted, __inserted ? newMember : __tree_[__r])
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
    try _ensureUnique { __tree_ in
      try .___insert_range_unique(
        tree: __tree_,
        other: other.__tree_,
        other.__tree_.__begin_node_,
        other.__tree_.__end_node(),
        uniquingKeysWith: combine)
    }
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
  ) rethrows where S: Sequence, S.Element == Pair<Key, Value> {

    try _ensureUnique { __tree_ in
      try .___insert_range_unique(
        tree: __tree_,
        other,
        uniquingKeysWith: combine
      ) { $0 }
    }
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

    try _ensureUnique { __tree_ in
      try .___insert_range_unique(
        tree: __tree_,
        other,
        uniquingKeysWith: combine
      ) {
        Pair($0)
      }
    }
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

  /// `self` と `other` をマージした新しいmapを返します。
  ///
  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  @inlinable
  public func merging<S>(
    _ other: __owned S,
    uniquingKeysWith combine: (Value, Value) throws -> Value
  ) rethrows -> Self where S: Sequence, S.Element == Pair<Key, Value> {
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
    .init(
      _storage: .init(
        tree: try __tree_.___filter(__tree_.__begin_node_, __tree_.__end_node(), isIncluded)))
  }
}

extension RedBlackTreeMap {

  /// - Complexity: O(*n*)
  @inlinable
  public func mapValues<T>(_ transform: (Value) throws -> T) rethrows
    -> RedBlackTreeMap<Key, T>
  {
    .init(
      _storage: .init(
        tree: try __tree_.___mapValues(__tree_.__begin_node_, __tree_.__end_node(), transform)))
  }

  /// - Complexity: O(*n*)
  @inlinable
  public func compactMapValues<T>(_ transform: (Value) throws -> T?)
    rethrows -> RedBlackTreeMap<Key, T>
  {
    .init(
      _storage: .init(
        tree: try __tree_.___compactMapValues(
          __tree_.__begin_node_, __tree_.__end_node(), transform)))
  }
}

// MARK: - Collection Conformance

// MARK: - Sequence
// MARK: - Collection
// MARK: - BidirectionalCollection

extension RedBlackTreeMap: Sequence, Collection, BidirectionalCollection {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public func makeIterator() -> Tree._Values {
    _makeIterator()
  }

  @inlinable
  @inline(__always)
  public func forEach(_ body: (_Value) throws -> Void) rethrows {
    try _forEach(body)
  }

  /// 特殊なforEach
  @inlinable
  @inline(__always)
  public func forEach(_ body: (Index, _Value) throws -> Void) rethrows {
    try _forEach(body)
  }

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public func sorted() -> Tree._Values {
    .init(tree: __tree_, start: __tree_.__begin_node_, end: __tree_.__end_node())
  }

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public var startIndex: Index { _startIndex }

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public var endIndex: Index { _endIndex }

  /// - Complexity: O(log *n*)
  @inlinable
  //  @inline(__always)
  public func distance(from start: Index, to end: Index) -> Int {
    _distance(from: start, to: end)
  }

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public func index(after i: Index) -> Index {
    _index(after: i)
  }

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public func formIndex(after i: inout Index) {
    _formIndex(after: &i)
  }

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public func index(before i: Index) -> Index {
    _index(before: i)
  }

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public func formIndex(before i: inout Index) {
    _formIndex(before: &i)
  }

  /// - Complexity: O(*d*)
  @inlinable
  //  @inline(__always)
  public func index(_ i: Index, offsetBy distance: Int) -> Index {
    _index(i, offsetBy: distance)
  }

  /// - Complexity: O(*d*)
  @inlinable
  //  @inline(__always)
  public func formIndex(_ i: inout Index, offsetBy distance: Int) {
    _formIndex(&i, offsetBy: distance)
  }

  /// - Complexity: O(*d*)
  @inlinable
  //  @inline(__always)
  public func index(_ i: Index, offsetBy distance: Int, limitedBy limit: Index) -> Index? {
    _index(i, offsetBy: distance, limitedBy: limit)
  }

  /// - Complexity: O(*d*)
  @inlinable
  //  @inline(__always)
  public func formIndex(_ i: inout Index, offsetBy distance: Int, limitedBy limit: Index)
    -> Bool
  {
    _formIndex(&i, offsetBy: distance, limitedBy: limit)
  }

  /// - Complexity: O(1)
  @inlinable
  public subscript(position: Index) -> _Value {
    @inline(__always) _read { yield self[_checked: position] }
  }

  /// - Warning: This subscript trades safety for performance. Using an invalid index results in undefined behavior.
  /// - Complexity: O(1)
  @inlinable
  public subscript(unchecked position: Index) -> _Value {
    @inline(__always) _read { yield self[_unchecked: position] }
  }

  /// Indexがsubscriptやremoveで利用可能か判別します
  ///
  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public func isValid(index: Index) -> Bool {
    _isValid(index: index)
  }

  /// RangeExpressionがsubscriptやremoveで利用可能か判別します
  ///
  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public func isValid<R: RangeExpression>(_ bounds: R) -> Bool
  where R.Bound == Index {
    _isValid(bounds)
  }

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public func reversed() -> Tree._Values.Reversed {
    _reversed()
  }

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public var indices: Indices {
    _indices
  }

  /// - Complexity: O(*m*), where *m* is the lesser of the length of the
  ///   sequence and the length of `other`.
  @inlinable
  @inline(__always)
  public func elementsEqual<OtherSequence>(
    _ other: OtherSequence, by areEquivalent: (_Value, OtherSequence.Element) throws -> Bool
  ) rethrows -> Bool where OtherSequence: Sequence {
    try _elementsEqual(other, by: areEquivalent)
  }

  /// - Complexity: O(*m*), where *m* is the lesser of the length of the
  ///   sequence and the length of `other`.
  @inlinable
  @inline(__always)
  public func lexicographicallyPrecedes<OtherSequence>(
    _ other: OtherSequence, by areInIncreasingOrder: (_Value, _Value) throws -> Bool
  ) rethrows -> Bool where OtherSequence: Sequence, _Value == OtherSequence.Element {
    try _lexicographicallyPrecedes(other, by: areInIncreasingOrder)
  }
}

extension RedBlackTreeMap where Value: Equatable {

  /// - Complexity: O(*m*), where *m* is the lesser of the length of the
  ///   sequence and the length of `other`.
  @inlinable
  @inline(__always)
  public func elementsEqual<OtherSequence>(_ other: OtherSequence) -> Bool
  where OtherSequence: Sequence, Element == OtherSequence.Element {
    __tree_.elementsEqual(__tree_.__begin_node_, __tree_.__end_node(), other)
  }
}

extension RedBlackTreeMap where Value: Comparable {

  /// - Complexity: O(*m*), where *m* is the lesser of the length of the
  ///   sequence and the length of `other`.
  @inlinable
  @inline(__always)
  public func lexicographicallyPrecedes<OtherSequence>(_ other: OtherSequence) -> Bool
  where OtherSequence: Sequence, Element == OtherSequence.Element {
    __tree_.lexicographicallyPrecedes(__tree_.__begin_node_, __tree_.__end_node(), other)
  }
}

// MARK: -

extension RedBlackTreeMap {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public func keys() -> Keys {
    .init(tree: __tree_, start: __tree_.__begin_node_, end: __tree_.__end_node())
  }

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public func values() -> Values {
    .init(tree: __tree_, start: __tree_.__begin_node_, end: __tree_.__end_node())
  }
}

// MARK: - SubSequence

extension RedBlackTreeMap {

  public typealias SubSequence = RedBlackTreeSlice<Self>
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
    lhs.__tree_ == rhs.__tree_
  }
}

// MARK: - Comparable

extension RedBlackTreeMap: Comparable where Value: Comparable {

  /// - Complexity: O(*m*), where *m* is the lesser of the length of `lhs` and `rhs`.
  @inlinable
  @inline(__always)
  public static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.__tree_ < rhs.__tree_
  }
}

// MARK: - Hashable

extension RedBlackTreeMap: Hashable where Key: Hashable, Value: Hashable {
  
  @inlinable
  @inline(__always)
  public func hash(into hasher: inout Hasher) {
    hasher.combine(__tree_)
  }
}

// MARK: - Sendable

#if swift(>=5.5)
  extension RedBlackTreeMap: @unchecked Sendable
  where Element: Sendable {}
#endif

// MARK: - Codable

extension RedBlackTreeMap: Encodable where Key: Encodable, Value: Encodable {
  
  @inlinable
  public func encode(to encoder: Encoder) throws {
    var container = encoder.unkeyedContainer()
    for element in self {
      try container.encode(element)
    }
  }
}

extension RedBlackTreeMap: Decodable where Key: Decodable, Value: Decodable {
  
  @inlinable
  public init(from decoder: Decoder) throws {
    _storage = .init(tree: try .create(from: decoder))
  }
}

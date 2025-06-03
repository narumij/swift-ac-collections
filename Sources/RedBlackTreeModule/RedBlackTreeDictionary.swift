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

/// `RedBlackTreeDictionary` は、`Key` 型のキーと `Value` 型の値のペアをキーに対して一意に格納するための
/// 赤黒木（Red-Black Tree）ベースの辞書型です。
///
/// ### 使用例
/// ```swift
/// /// `RedBlackTreeDictionary` を使用する例
/// var dictionary = RedBlackTreeDictionary<String, Int>()
/// dictionary["apple"] = 5
/// dictionary["banana"] = 3
/// dictionary["cherry"] = 7
///
/// // キーを使用して値にアクセス
/// if let value = dictionary.value(forKey: "banana") {
///     print("banana の値は \(value) です。") // 出力例: banana の値は 3 です。
/// }
///
/// // キーと値のペアを削除
/// dictionary.remove(key: "apple")
/// ```
@frozen
public struct RedBlackTreeDictionary<Key: Comparable, Value> {

  public
    typealias Index = Tree.Index

  public
    typealias KeyValue = (key: Key, value: Value)

  public
    typealias Element = KeyValue

  public
    typealias Keys = KeyIterator<Tree, Key, Value>

  public
    typealias Values = ValueIterator<Tree, Key, Value>

  public
    typealias _Key = Key

  public
    typealias _Value = Value

  @usableFromInline
  var _storage: Tree.Storage

  @inlinable @inline(__always)
  init(_storage: Tree.Storage) {
    self._storage = _storage
  }
}

extension RedBlackTreeDictionary: ___RedBlackTreeBase {}
extension RedBlackTreeDictionary: ___RedBlackTreeCopyOnWrite {}
extension RedBlackTreeDictionary: ___RedBlackTreeUnique {}
extension RedBlackTreeDictionary: ___RedBlackTreeMerge {}
extension RedBlackTreeDictionary: ___RedBlackTreeSequence {}
extension RedBlackTreeDictionary: ___RedBlackTreeSubSequence {}
extension RedBlackTreeDictionary: KeyValueComparer {}

// MARK: - Initialization

extension RedBlackTreeDictionary {

  /// - Complexity: O(1)
  @inlinable @inline(__always)
  public init() {
    self.init(minimumCapacity: 0)
  }

  /// - Complexity: O(1)
  @inlinable @inline(__always)
  public init(minimumCapacity: Int) {
    _storage = .create(withCapacity: minimumCapacity)
  }
}

extension RedBlackTreeDictionary {

  /// - Complexity: O(*n* log *n* + *n*)
  @inlinable
  public init<S>(uniqueKeysWithValues keysAndValues: __owned S)
  where S: Sequence, S.Element == (Key, Value) {
    let count = (keysAndValues as? (any Collection))?.count
    var tree: Tree = .create(minimumCapacity: count ?? 0)
    // 初期化直後はO(1)
    var (__parent, __child) = tree.___max_ref()
    // ソートの計算量がO(*n* log *n*)
    for __k in keysAndValues.sorted(by: { $0.0 < $1.0 }) {
      if count == nil {
        Tree.ensureCapacity(tree: &tree)
      }
      if __parent == .end || tree[__parent].0 != __k.0 {
        // バランシングの計算量がO(log *n*)
        (__parent, __child) = tree.___emplace_hint_right(__parent, __child, __k)
        assert(tree.__tree_invariant(tree.__root()))
      } else {
        fatalError("Dupricate values for key: '\(__k.0)'")
      }
    }
    self._storage = .init(tree: tree)
  }
}

extension RedBlackTreeDictionary {

  /// - Complexity: O(*n* log *n* + *n*)
  @inlinable
  public init<S>(
    _ keysAndValues: __owned S,
    uniquingKeysWith combine: (Value, Value) throws -> Value
  ) rethrows where S: Sequence, S.Element == (Key, Value) {
    let count = (keysAndValues as? (any Collection))?.count
    var tree: Tree = .create(minimumCapacity: count ?? 0)
    // 初期化直後はO(1)
    var (__parent, __child) = tree.___max_ref()
    // ソートの計算量がO(*n* log *n*)
    for __k in keysAndValues.sorted(by: { $0.0 < $1.0 }) {
      if count == nil {
        Tree.ensureCapacity(tree: &tree)
      }
      if __parent == .end || tree[__parent].0 != __k.0 {
        // バランシングの計算量がO(log *n*)
        (__parent, __child) = tree.___emplace_hint_right(__parent, __child, __k)
        assert(tree.__tree_invariant(tree.__root()))
      } else {
        tree[__parent].value = try combine(tree[__parent].value, __k.1)
      }
    }
    self._storage = .init(tree: tree)
  }
}

extension RedBlackTreeDictionary {

  /// - Complexity: O(*n* log *n* + *n*)
  @inlinable
  public init<S: Sequence>(
    grouping values: __owned S,
    by keyForValue: (S.Element) throws -> Key
  ) rethrows where Value == [S.Element] {
    let count = (values as? (any Collection))?.count
    var tree: Tree = .create(minimumCapacity: count ?? 0)
    // 初期化直後はO(1)
    var (__parent, __child) = tree.___max_ref()
    // ソートの計算量がO(*n* log *n*)
    for __v in try values.sorted(by: { try keyForValue($0) < keyForValue($1) }) {
      let __k = try keyForValue(__v)
      if count == nil {
        Tree.ensureCapacity(tree: &tree)
      }
      if __parent == .end || tree[__parent].key != __k {
        // バランシングの計算量がO(log *n*)
        (__parent, __child) = tree.___emplace_hint_right(__parent, __child, (__k, [__v]))
        assert(tree.__tree_invariant(tree.__root()))
      } else {
        tree[__parent].value.append(__v)
      }
    }
    self._storage = .init(tree: tree)
  }
}

extension RedBlackTreeDictionary {

  @inlinable
  public mutating func reserveCapacity(_ minimumCapacity: Int) {
    _ensureUniqueAndCapacity(to: minimumCapacity)
  }
}

// MARK: - Insert（挿入）

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
  @discardableResult
  public mutating func insert(_ newMember: Element) -> (
    inserted: Bool, memberAfterInsert: Element
  ) {
    _ensureUniqueAndCapacity()
    _ = __tree_.__insert_unique(newMember)
    return (true, newMember)
  }
}

extension RedBlackTreeDictionary {

  /// - Complexity: O(log *n*)
  @discardableResult
  @inlinable
  public mutating func updateValue(
    _ value: Value,
    forKey key: Key
  ) -> Value? {
    _ensureUniqueAndCapacity()
    let (__r, __inserted) = __tree_.__insert_unique((key, value))
    guard !__inserted else { return nil }
    let oldMember = __tree_[__r]
    __tree_[__r] = (key, value)
    return oldMember.value
  }
}

extension RedBlackTreeDictionary {

#if false
  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  @inlinable
  @inline(__always)
  public mutating func insert(contentsOf other: RedBlackTreeDictionary<Key, Value>) {
    _ensureUnique()
    ___tree_merge_unique(other.__tree_)
  }
  
  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  @inlinable
  @inline(__always)
  public mutating func insert(contentsOf other: RedBlackTreeMultiMap<Key, Value>) {
    _ensureUnique()
    ___tree_merge_unique(other.__tree_)
  }
  
  
  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  @inlinable
  @inline(__always)
  public mutating func insert<S>(contentsOf other: S) where S: Sequence, S.Element == Element {
    _ensureUnique()
    ___merge_unique(other)
  }

  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  @inlinable
  @inline(__always)
  public mutating func inserting(contentsOf other: RedBlackTreeDictionary<Key, Value>) -> Self {
    var result = self
    result.insert(contentsOf: other)
    return result
  }

  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  @inlinable
  @inline(__always)
  public mutating func inserting(contentsOf other: RedBlackTreeMultiMap<Key, Value>) -> Self {
    var result = self
    result.insert(contentsOf: other)
    return result
  }
  
  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  @inlinable
  public func inserting<S>(contentsOf other: __owned S) -> Self where S: Sequence, S.Element == Element {
    var result = self
    result.insert(contentsOf: other)
    return result
  }
#endif
}

extension RedBlackTreeDictionary {

  /// 辞書に `other` の要素をマージします。
  /// キーが重複したときは `combine` の戻り値を採用します。
  ///
  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  @inlinable
  public mutating func merge<S>(
    _ other: __owned S,
    uniquingKeysWith combine: (Value, Value) throws -> Value
  ) rethrows where S: Sequence, S.Element == KeyValue {

    for (k, v) in other {
      if let old = self[k] {
        self[k] = try combine(old, v)
      } else {
        self[k] = v
      }
    }
  }
  
  /// `self` と `other` をマージした新しい辞書を返します。
  ///
  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  @inlinable
  public func merging<S>(
    _ other: __owned S,
    uniquingKeysWith combine: (Value, Value) throws -> Value
  ) rethrows -> Self where S: Sequence, S.Element == KeyValue {
    var result = self
    try result.merge(other, uniquingKeysWith: combine)
    return result
  }
}

// MARK: - Remove（削除）

extension RedBlackTreeDictionary {

  /// 最小キーのペアを取り出して削除
  ///
  /// - Important: 削除したメンバーを指すインデックスが無効になります。
  /// - Complexity: O(1)
  @inlinable
  public mutating func popFirst() -> KeyValue? {
    guard !isEmpty else { return nil }
    return remove(at: startIndex)
  }
}

extension RedBlackTreeDictionary {

  /// - Important: 削除したメンバーを指すインデックスが無効になります。
  /// - Complexity: O(log *n*)
  @inlinable
  @discardableResult
  public mutating func removeValue(forKey __k: Key) -> Value? {
    let __i = __tree_.find(__k)
    if __i == __tree_.end() {
      return nil
    }
    let value = __tree_.___element(__i).value
    _ensureUnique()
    _ = __tree_.erase(__i)
    return value
  }

  /// - Important: 削除したメンバーを指すインデックスが無効になります。
  /// - Complexity: O(1)
  @inlinable
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
  @discardableResult
  public mutating func remove(at index: Index) -> KeyValue {
    _ensureUnique()
    guard let element = ___remove(at: index.rawValue) else {
      fatalError(.invalidIndex)
    }
    return element
  }

  /// - Important: 削除後は、インデックスが無効になります。
  /// - Complexity: O(1)
  @inlinable
  @discardableResult
  public mutating func remove(at index: RawIndex) -> KeyValue {
    _ensureUnique()
    guard let element = ___remove(at: index.rawValue) else {
      fatalError(.invalidIndex)
    }
    return element
  }

  /// - Important: 削除後は、インデックスが無効になります。
  /// - Complexity: O(*k*)
  @inlinable
  public mutating func removeSubrange(_ range: Range<Index>) {
    _ensureUnique()
    ___remove(from: range.lowerBound.rawValue, to: range.upperBound.rawValue)
  }
}

extension RedBlackTreeDictionary {

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

extension RedBlackTreeDictionary {

  /// - Complexity: O(1)
  @inlinable
  public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
    _ensureUnique()
    ___removeAll(keepingCapacity: keepCapacity)
  }
}

// MARK: - Search（検索・探索）

extension RedBlackTreeDictionary {

  @usableFromInline
  struct ___ModifyHelper {
    @inlinable @inline(__always)
    init(pointer: UnsafeMutablePointer<Value>) {
      self.pointer = pointer
    }
    @usableFromInline
    var isNil: Bool = false
    @usableFromInline
    var pointer: UnsafeMutablePointer<Value>
    @inlinable
    var value: Value? {
      @inline(__always)
      _read { yield isNil ? nil : pointer.pointee }
      @inline(__always)
      _modify {
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
    @inline(__always)
    _read { yield ___value_for(key)?.value }
    @inline(__always)
    _modify {
      // TODO: もうすこしライフタイム管理に明るくなったら、再度ここのチューニングに取り組む
      let (__parent, __child, __ptr) = _prepareForKeyingModify(key)
      if __ptr == .nullptr {
        var value: Value?
        defer {
          if let value {
            _ensureUniqueAndCapacity()
            let __h = __tree_.__construct_node((key, value))
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
    @inline(__always)
    _read { yield ___value_for(key)?.value ?? defaultValue() }
    @inline(__always)
    _modify {
      defer { _fixLifetime(self) }
      var (__parent, __child, __ptr) = _prepareForKeyingModify(key)
      if __ptr == .nullptr {
        _ensureUniqueAndCapacity()
        assert(__tree_.header.capacity > __tree_.count)
        __ptr = __tree_.__construct_node((key, defaultValue()))
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

extension RedBlackTreeDictionary {

  /// - Complexity: O(log *n*)
  @inlinable
  public func contains(key: Key) -> Bool {
    ___contains(key)
  }

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

extension RedBlackTreeDictionary {

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

extension RedBlackTreeDictionary {

  /// - Complexity: O(log *n*)
  @inlinable
  public func equalRange(_ key: Key) -> (lower: Index, upper: Index) {
    ___index_equal_range(key)
  }
}

extension RedBlackTreeDictionary {

  /// - Complexity: O(1)
  @inlinable
  public var first: Element? {
    isEmpty ? nil : self[startIndex]
  }

  /// - Complexity: O(log *n*)
  @inlinable
  public var last: Element? {
    isEmpty ? nil : self[index(before: endIndex)]
  }

  /// - Complexity: O(*n*)
  @inlinable
  public func first(where predicate: (Element) throws -> Bool) rethrows -> Element? {
    try ___first(where: predicate)
  }

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

// MARK: - Transformation

extension RedBlackTreeDictionary {

  /// - Complexity: O(*n*)
  @inlinable
  public func filter(
    _ isIncluded: (Element) throws -> Bool
  ) rethrows -> Self {
    .init(_storage: .init(tree: try __tree_.___filter(isIncluded)))
  }
}

extension RedBlackTreeDictionary {

  @inlinable
  public func mapValues<T>(_ transform: (Value) throws -> T) rethrows
    -> RedBlackTreeDictionary<Key, T>
  {
    .init(_storage: .init(tree: try __tree_.___mapValues(transform)))
  }

  @inlinable
  public func compactMapValues<T>(_ transform: (Value) throws -> T?)
    rethrows -> RedBlackTreeDictionary<Key, T>
  {
    .init(_storage: .init(tree: try __tree_.___compactMapValues(transform)))
  }
}

// MARK: - Utility（ユーティリティ、isEmptyやcapacityなど）

extension RedBlackTreeDictionary {

  /// - Complexity: O(1)
  @inlinable
  public var isEmpty: Bool {
    ___is_empty
  }

  /// - Complexity: O(1)
  @inlinable
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

extension RedBlackTreeDictionary {

  /// - Complexity: O(1)
  public var keys: Keys {
    .init(tree: __tree_, start: __tree_.__begin_node, end: __tree_.__end_node())
  }

  /// - Complexity: O(1)
  public var values: Values {
    .init(tree: __tree_, start: __tree_.__begin_node, end: __tree_.__end_node())
  }
}

// MARK: - Collection Conformance（コレクション適合系）

// MARK: - Sequence
// MARK: - Collection
// MARK: - BidirectionalCollection

extension RedBlackTreeDictionary: Sequence, Collection, BidirectionalCollection {}

// MARK: - Range Access

extension RedBlackTreeDictionary {

  /// - Complexity: O(1)
  @inlinable
  public subscript(bounds: Range<Index>) -> SubSequence {
    .init(tree: __tree_, start: bounds.lowerBound.rawValue, end: bounds.upperBound.rawValue)
  }
}

extension RedBlackTreeDictionary {

  // setやmultisetと比べて、驚き最小違反とはいいにくいので、deprecatedには一旦しない
  /// 範囲 `[lower, upper)` に含まれる要素を返します。
  /// - Complexity: O(log *n*)
  @inlinable
  public subscript(bounds: Range<Key>) -> SubSequence {
    elements(in: bounds)
  }

  // setやmultisetと比べて、驚き最小違反とはいいにくいので、deprecatedには一旦しない
  /// 範囲 `[lower, upper]` に含まれる要素を返します。
  /// - Complexity: O(log *n*)
  @inlinable
  public subscript(bounds: ClosedRange<Key>) -> SubSequence {
    elements(in: bounds)
  }
}

extension RedBlackTreeDictionary {
  /// キーレンジ `[lower, upper)` に含まれる要素のスライス
  /// - Complexity: O(log *n*)
  @inlinable
  public func elements(in range: Range<Key>) -> SubSequence {
    .init(
      tree: __tree_, start: ___lower_bound(range.lowerBound), end: ___lower_bound(range.upperBound))
  }

  /// キーレンジ `[lower, upper]` に含まれる要素のスライス
  /// - Complexity: O(log *n*)
  @inlinable
  public func elements(in range: ClosedRange<Key>) -> SubSequence {
    .init(
      tree: __tree_, start: ___lower_bound(range.lowerBound), end: ___upper_bound(range.upperBound))
  }
}

// MARK: - SubSequence

extension RedBlackTreeDictionary {

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

extension RedBlackTreeDictionary.SubSequence: Equatable where Value: Equatable {

  /// - Complexity: O(*m*), where *m* is the lesser of the length of `lhs` and `rhs`.
  @inlinable
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.elementsEqual(rhs)
  }
}

extension RedBlackTreeDictionary.SubSequence: Comparable where Value: Comparable {

  /// - Complexity: O(*m*), where *m* is the lesser of the length of `lhs` and `rhs`.
  @inlinable
  public static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.lexicographicallyPrecedes(rhs)
  }
}

extension RedBlackTreeDictionary.SubSequence where Value: Equatable {

  /// - Complexity: O(*m*), where *m* is the lesser of the length of the
  ///   sequence and the length of `other`.
  @inlinable
  public func elementsEqual<OtherSequence>(_ other: OtherSequence) -> Bool
  where OtherSequence: Sequence, Element == OtherSequence.Element {
    elementsEqual(other, by: Tree.___key_value_equiv)
  }
}

extension RedBlackTreeDictionary.SubSequence where Value: Comparable {

  /// - Complexity: O(*m*), where *m* is the lesser of the length of the
  ///   sequence and the length of `other`.
  @inlinable
  public func lexicographicallyPrecedes<OtherSequence>(_ other: OtherSequence) -> Bool
  where OtherSequence: Sequence, Element == OtherSequence.Element {
    lexicographicallyPrecedes(other, by: Tree.___key_value_comp)
  }
}

extension RedBlackTreeDictionary.SubSequence: ___SubSequenceBase {
  public typealias Base = RedBlackTreeDictionary
  public typealias Element = Tree.Element
  public typealias Indices = Tree.Indices
}

extension RedBlackTreeDictionary.SubSequence: Sequence, Collection, BidirectionalCollection {
  public typealias Index = RedBlackTreeDictionary.Index
  public typealias SubSequence = Self
}

// MARK: - Index Range

extension RedBlackTreeDictionary {

  public typealias Indices = Tree.Indices
}

// MARK: - Raw Index Sequence

extension RedBlackTreeDictionary {

  /// RawIndexは赤黒木ノードへの軽量なポインタとなっていて、rawIndicesはRawIndexのシーケンスを返します。
  /// 削除時のインデックス無効対策がイテレータに施してあり、削除操作に利用することができます。
  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public var rawIndices: RawIndexSequence<Tree> {
    RawIndexSequence(tree: __tree_)
  }
}

// MARK: - Enumerated Sequence

extension RedBlackTreeDictionary {

  /// - Complexity: O(1)
  @inlinable @inline(__always)
  public var rawIndexedElements: RawIndexedSequence<Tree> {
    RawIndexedSequence(tree: __tree_)
  }
}

// MARK: - ExpressibleByDictionaryLiteral

extension RedBlackTreeDictionary: ExpressibleByDictionaryLiteral {

  /// - Complexity: O(*n* log *n*)
  @inlinable
  public init(dictionaryLiteral elements: (Key, Value)...) {
    self.init(uniqueKeysWithValues: elements)
  }
}

// MARK: - ExpressibleByArrayLiteral

extension RedBlackTreeDictionary: ExpressibleByArrayLiteral {

  /// `[("key", value), ...]` 形式のリテラルから辞書を生成します。
  ///
  /// - Important: キーが重複していた場合は
  ///   `Dictionary(uniqueKeysWithValues:)` と同じく **ランタイムエラー** になります。
  ///   （重複を許容してマージしたい場合は `merge` / `merging` を使ってください）
  ///
  /// 使用例
  /// ```swift
  /// let d: RedBlackTreeDictionary = [("a", 1), ("b", 2)]
  /// ```
  /// - Complexity: O(*n* log *n*)
  @inlinable
  public init(arrayLiteral elements: (Key, Value)...) {
    self.init(uniqueKeysWithValues: elements)
  }
}

// MARK: - CustomStringConvertible

extension RedBlackTreeDictionary: CustomStringConvertible {

  @inlinable
  public var description: String {
    if isEmpty { return "[:]" }
    var result = "["
    var first = true
    for (key, value) in self {
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

extension RedBlackTreeDictionary: CustomDebugStringConvertible {

  @inlinable
  public var debugDescription: String {
    var result = "RedBlackTreeDictionary<\(Key.self), \(Value.self)>("
    if isEmpty {
      result += "[:]"
    } else {
      result += "["
      var first = true
      for (key, value) in self {
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

extension RedBlackTreeDictionary: CustomReflectable {
  /// The custom mirror for this instance.
  public var customMirror: Mirror {
    Mirror(self, unlabeledChildren: self, displayStyle: .dictionary)
  }
}

// MARK: - Equatable

extension RedBlackTreeDictionary: Equatable where Value: Equatable {

  /// - Complexity: O(*m*), where *m* is the lesser of the length of `lhs` and `rhs`.
  @inlinable
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.count == rhs.count && lhs.elementsEqual(rhs)
  }
}

extension RedBlackTreeDictionary: Comparable where Value: Comparable {

  /// - Complexity: O(*m*), where *m* is the lesser of the length of `lhs` and `rhs`.
  @inlinable
  public static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.lexicographicallyPrecedes(rhs)
  }
}

extension RedBlackTreeDictionary where Value: Equatable {

  /// - Complexity: O(*m*), where *m* is the lesser of the length of the
  ///   sequence and the length of `other`.
  @inlinable
  public func elementsEqual<OtherSequence>(_ other: OtherSequence) -> Bool
  where OtherSequence: Sequence, Element == OtherSequence.Element {
    elementsEqual(other, by: Tree.___key_value_equiv)
  }
}

extension RedBlackTreeDictionary where Value: Comparable {

  /// - Complexity: O(*m*), where *m* is the lesser of the length of the
  ///   sequence and the length of `other`.
  @inlinable
  public func lexicographicallyPrecedes<OtherSequence>(_ other: OtherSequence) -> Bool
  where OtherSequence: Sequence, Element == OtherSequence.Element {
    lexicographicallyPrecedes(other, by: Tree.___key_value_comp)
  }
}

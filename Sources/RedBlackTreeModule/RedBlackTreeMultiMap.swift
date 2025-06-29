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

/// `RedBlackTreeMultiMap` は、`Key` 型のキーと `Value` 型の値のペアを格納するための
/// 赤黒木（Red-Black Tree）ベースのマルチマップ型です。
///
/// ### 使用例
/// ```swift
/// /// `RedBlackTreeMultiMap` を使用する例
/// var multimap = RedBlackTreeMultiMap<String, Int>()
/// multimap.insert(key: "apple", value: 5)
/// multimap.insert(key: "banana", value: 3)
/// multimap.insert(key: "cherry", value: 7)
///
/// // キーを使用して値にアクセス
/// let values = multimap.values(forKey: "banana")
///
/// values.forEach { value in
///   print("banana の値は \(value) です。") // 出力例: banana の値は 3 です。
/// }
///
/// // キーと値のペアを一つ削除
/// multimap.removeFirst(forKey: "apple")
/// ```
@frozen
public struct RedBlackTreeMultiMap<Key: Comparable, Value> {

  /// - Important:
  ///  要素及びノードが削除された場合、インデックスは無効になります。
  /// 無効なインデックスを使用するとランタイムエラーや不正な参照が発生する可能性があるため注意してください。
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

extension RedBlackTreeMultiMap: ___RedBlackTreeBase {}
extension RedBlackTreeMultiMap: ___RedBlackTreeCopyOnWrite {}
extension RedBlackTreeMultiMap: ___RedBlackTreeMulti {}
extension RedBlackTreeMultiMap: ___RedBlackTreeMerge {}
extension RedBlackTreeMultiMap: ___RedBlackTreeSequence {}
extension RedBlackTreeMultiMap: ___RedBlackTreeSubSequence {}
extension RedBlackTreeMultiMap: KeyValueComparer {}

// MARK: - Creating a MultiMap

extension RedBlackTreeMultiMap {

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

extension RedBlackTreeMultiMap {

  /// - Complexity: O(*n* log *n* + *n*)
  @inlinable
  public init<S>(multiKeysWithValues keysAndValues: __owned S)
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
      // バランシングの最悪計算量が結局わからず、ならしO(1)とみている
      (__parent, __child) = tree.___emplace_hint_right(__parent, __child, __k)
      assert(tree.__tree_invariant(tree.__root()))
    }
    self._storage = .init(tree: tree)
  }
}

extension RedBlackTreeMultiMap {
  // Dictionaryからぱくってきたが、割と様子見

  /// - Complexity: O(*n* log *n* + *n*)
  @inlinable
  public init<S: Sequence>(
    grouping values: __owned S,
    by keyForValue: (S.Element) throws -> Key
  ) rethrows where Value == S.Element {
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
      // バランシングの最悪計算量が結局わからず、ならしO(1)とみている
      (__parent, __child) = tree.___emplace_hint_right(__parent, __child, (__k, __v))
      assert(tree.__tree_invariant(tree.__root()))
    }
    self._storage = .init(tree: tree)
  }
}

// MARK: - Inspecting a MultiMap

extension RedBlackTreeMultiMap {

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

extension RedBlackTreeMultiMap {

  /// - Complexity: O(log *n* + *k*)
  @inlinable
  public func count(forKey key: Key) -> Int {
    __tree_.__count_multi(key)
  }
}

// MARK: - Accessing Keys and Values

extension RedBlackTreeMultiMap {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public var first: Element? {
    ___first
  }

  /// - Complexity: O(log *n*)
  @inlinable
  @inline(__always)
  public var last: Element? {
    ___last
  }
}

extension RedBlackTreeMultiMap {

  /// - Complexity: O(log *n*)
  @inlinable
  public func values(forKey key: Key) -> Values {
    let (lo, hi) = __tree_.__equal_range_multi(key)
    return .init(tree: __tree_, start: lo, end: hi)
  }
}

// MARK: - Range Accessing Keys and Values

extension RedBlackTreeMultiMap {

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

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public subscript(_unsafe bounds: Range<Index>) -> SubSequence {
    .init(
      tree: __tree_,
      start: bounds.lowerBound.rawValue,
      end: bounds.upperBound.rawValue)
  }
}

// MARK: - Insert

extension RedBlackTreeMultiMap {

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
    _ensureUniqueAndCapacity()
    _ = __tree_.__insert_multi(newMember)
    return (true, newMember)
  }
}

extension RedBlackTreeMultiMap {

  /// - Complexity: O(log *n*)
  @inlinable
  @inline(__always)
  @discardableResult
  public mutating func updateValue(_ newValue: Value, at ptr: Index) -> Element? {
    guard !__tree_.___is_subscript_null(ptr.rawValue) else {
      return nil
    }
    _ensureUnique()
    let old = __tree_[ptr.rawValue]
    __tree_[ptr.rawValue].value = newValue
    return old
  }
}

extension RedBlackTreeMultiMap {

  @inlinable
  public mutating func reserveCapacity(_ minimumCapacity: Int) {
    _ensureUniqueAndCapacity(to: minimumCapacity)
  }
}

// MARK: - Combining MultiMap

extension RedBlackTreeMultiMap {

  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  ///
  /// - Important: 空間計算量に余裕がある場合、meldの使用を推奨します
  @inlinable
  public mutating func insert(contentsOf other: RedBlackTreeMultiMap<Key, Value>) {
    _ensureUniqueAndCapacity(to: count + other.count)
    ___tree_merge_multi(other.__tree_)
  }

  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  @inlinable
  public mutating func insert(contentsOf other: RedBlackTreeDictionary<Key, Value>) {
    _ensureUniqueAndCapacity(to: count + other.count)
    ___tree_merge_multi(other.__tree_)
  }

  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  @inlinable
  public mutating func insert<S>(contentsOf other: S) where S: Sequence, S.Element == (Key, Value) {
    _ensureUnique()
    ___merge_multi(other)
  }

  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  @inlinable
  public func inserting(contentsOf other: RedBlackTreeMultiMap<Key, Value>) -> Self {
    var result = self
    result.insert(contentsOf: other)
    return result
  }

  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  ///
  /// - Important: 空間計算量に余裕がある場合、meldingの使用を推奨します
  @inlinable
  public func inserting(contentsOf other: RedBlackTreeDictionary<Key, Value>) -> Self {
    var result = self
    result.insert(contentsOf: other)
    return result
  }

  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  @inlinable
  public func inserting<S>(contentsOf other: __owned S) -> Self
  where S: Sequence, S.Element == (Key, Value) {
    var result = self
    result.insert(contentsOf: other)
    return result
  }
}

extension RedBlackTreeMultiMap {

  /// - Complexity: O(*n* + *m*)
  @inlinable
  @inline(__always)
  public mutating func meld(_ other: __owned RedBlackTreeMultiMap<Key, Value>) {
    _storage = .init(tree: __tree_.___meld_multi(other.__tree_))
  }

  /// - Complexity: O(*n* + *m*)
  @inlinable
  @inline(__always)
  public func melding(_ other: __owned RedBlackTreeMultiMap<Key, Value>)
    -> RedBlackTreeMultiMap<Key, Value>
  {
    var result = self
    result.meld(other)
    return result
  }
}

extension RedBlackTreeMultiMap {

  /// - Complexity: O(*n* log(*m + n*))
  @inlinable
  @inline(__always)
  static func + (lhs: Self, rhs: Self) -> Self {
    lhs.inserting(contentsOf: rhs)
  }

  /// - Complexity: O(*n* log(*m + n*))
  @inlinable
  @inline(__always)
  static func += (lhs: inout Self, rhs: Self) {
    lhs.insert(contentsOf: rhs)
  }
}

// MARK: - Remove（削除）

extension RedBlackTreeMultiMap {
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

extension RedBlackTreeMultiMap {

  /// - Important: 削除したメンバーを指すインデックスが無効になります。
  /// - Complexity: O(log *n*)
  @inlinable
  @discardableResult
  public mutating func removeFirst(forKey key: Key) -> Bool {
    _strongEnsureUnique()
    return __tree_.___erase_unique(key)
  }

  /// - Important: 削除したメンバーを指すインデックスが無効になります。
  /// - Complexity: O(log *n*)
  @inlinable
  @discardableResult
  public mutating func removeFirst(_unsafeForKey key: Key) -> Bool {
    _ensureUnique()
    return __tree_.___erase_unique(key)
  }

  /// - Important: 削除したメンバーを指すインデックスが無効になります。
  /// - Complexity: O(log *n* + *k*)
  @inlinable
  @discardableResult
  public mutating func removeAll(forKey key: Key) -> Int {
    _strongEnsureUnique()
    return __tree_.___erase_multi(key)
  }

  /// - Important: 削除したメンバーを指すインデックスが無効になります。
  /// - Complexity: O(log *n* + *k*)
  @inlinable
  @discardableResult
  public mutating func removeAll(_unsafeForKey key: Key) -> Int {
    _ensureUnique()
    return __tree_.___erase_multi(key)
  }
}

extension RedBlackTreeMultiMap {

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

extension RedBlackTreeMultiMap {

  /// - Complexity: O(log *n* + *k*)
  @inlinable
  @inline(__always)
  public mutating func remove(contentsOf keyRange: Range<Key>) {
    _strongEnsureUnique()
    let lower = ___lower_bound(keyRange.lowerBound)
    let upper = ___lower_bound(keyRange.upperBound)
    ___remove(from: lower, to: upper)
  }

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

extension RedBlackTreeMultiMap {

  /// - Complexity: O(1)
  @inlinable
  public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
    _ensureUnique()
    ___removeAll(keepingCapacity: keepCapacity)
  }
}

// MARK: Finding Elements

extension RedBlackTreeMultiMap {

  /// - Complexity: O(log *n*)
  @inlinable
  public func contains(key: Key) -> Bool {
    ___contains(key)
  }
}

extension RedBlackTreeMultiMap {

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

extension RedBlackTreeMultiMap {

  /// - Complexity: O(log *n*)
  @inlinable
  public func equalRange(_ key: Key) -> (lower: Index, upper: Index) {
    ___index_equal_range(key)
  }
}

extension RedBlackTreeMultiMap {

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

extension RedBlackTreeMultiMap {

  /// - Complexity: O(*n*)
  @inlinable
  public func first(where predicate: (Element) throws -> Bool) rethrows -> Element? {
    try ___first(where: predicate)
  }
}

extension RedBlackTreeMultiMap {

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

extension RedBlackTreeMultiMap {
  // 割と注意喚起の為のdeprecatedなだけで、実際にいつ消すのかは不明です。
  // 分かってると便利なため、競技プログラミングにこのシンタックスシュガーは有用と考えているからです。

  /// 範囲 `[lower, upper)` に含まれる要素を返します。
  ///
  /// index範囲ではないことに留意
  /// **Deprecated – `elements(in:)` を使ってください。**
  @available(*, deprecated, renamed: "elements(in:)")
  @inlinable
  @inline(__always)
  public subscript(bounds: Range<Key>) -> SubSequence {
    elements(in: bounds)
  }

  /// 範囲 `[lower, upper]` に含まれる要素を返します。
  ///
  /// index範囲ではないことに留意
  /// **Deprecated – `elements(in:)` を使ってください。**
  @available(*, deprecated, renamed: "elements(in:)")
  @inlinable
  @inline(__always)
  public subscript(bounds: ClosedRange<Key>) -> SubSequence {
    elements(in: bounds)
  }
}

extension RedBlackTreeMultiMap {
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

extension RedBlackTreeMultiMap {

  /// - Complexity: O(*n*)
  @inlinable
  public func filter(
    _ isIncluded: (Element) throws -> Bool
  ) rethrows -> Self {
    .init(_storage: .init(tree: try __tree_.___filter(isIncluded)))
  }
}

extension RedBlackTreeMultiMap {

  @inlinable
  public func mapValues<T>(_ transform: (Value) throws -> T) rethrows
    -> RedBlackTreeMultiMap<Key, T>
  {
    .init(_storage: .init(tree: try __tree_.___mapValues(transform)))
  }

  @inlinable
  public func compactMapValues<T>(_ transform: (Value) throws -> T?)
    rethrows -> RedBlackTreeMultiMap<Key, T>
  {
    .init(_storage: .init(tree: try __tree_.___compactMapValues(transform)))
  }
}

// MARK: - Sequence
// MARK: - Collection
// MARK: - BidirectionalCollection

extension RedBlackTreeMultiMap: Sequence, Collection, BidirectionalCollection {}

// MARK: - Range Access

// MARK: - SubSequence

extension RedBlackTreeMultiMap {

  /// - Complexity: O(log *n*)
  @inlinable
  @inline(__always)
  public subscript(key: Key) -> SubSequence {
    let (lo, hi): (_NodePtr, _NodePtr) = self.___equal_range(key)
    return .init(tree: __tree_, start: lo, end: hi)
  }
}

extension RedBlackTreeMultiMap {

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

extension RedBlackTreeMultiMap.SubSequence: Equatable where Value: Equatable {

  /// - Complexity: O(*m*), where *m* is the lesser of the length of `lhs` and `rhs`.
  @inlinable
  @inline(__always)
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.elementsEqual(rhs)
  }
}

extension RedBlackTreeMultiMap.SubSequence: Comparable where Value: Comparable {

  /// - Complexity: O(*m*), where *m* is the lesser of the length of `lhs` and `rhs`.
  @inlinable
  @inline(__always)
  public static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.lexicographicallyPrecedes(rhs)
  }
}

extension RedBlackTreeMultiMap.SubSequence where Value: Equatable {

  /// - Complexity: O(*m*), where *m* is the lesser of the length of the
  ///   sequence and the length of `other`.
  @inlinable
  @inline(__always)
  public func elementsEqual<OtherSequence>(_ other: OtherSequence) -> Bool
  where OtherSequence: Sequence, Element == OtherSequence.Element {
    elementsEqual(other, by: Tree.___key_value_equiv)
  }
}

extension RedBlackTreeMultiMap.SubSequence where Value: Comparable {

  /// - Complexity: O(*m*), where *m* is the lesser of the length of the
  ///   sequence and the length of `other`.
  @inlinable
  @inline(__always)
  public func lexicographicallyPrecedes<OtherSequence>(_ other: OtherSequence) -> Bool
  where OtherSequence: Sequence, Element == OtherSequence.Element {
    lexicographicallyPrecedes(other, by: Tree.___key_value_comp)
  }
}

extension RedBlackTreeMultiMap.SubSequence: ___SubSequenceBase {
  public typealias Base = RedBlackTreeMultiMap
  public typealias Element = Tree.Element
  public typealias Indices = Tree.Indices
}

extension RedBlackTreeMultiMap.SubSequence: Sequence, Collection, BidirectionalCollection {
  public typealias Index = RedBlackTreeMultiMap.Index
  public typealias SubSequence = Self
}

// MARK: - Index Range

extension RedBlackTreeMultiMap {

  public typealias Indices = Tree.Indices
}

// MARK: - ExpressibleByDictionaryLiteral

extension RedBlackTreeMultiMap: ExpressibleByDictionaryLiteral {

  /// - Complexity: O(*n* log *n*)
  @inlinable
  @inline(__always)
  public init(dictionaryLiteral elements: (Key, Value)...) {
    self.init(multiKeysWithValues: elements)
  }
}

// MARK: - ExpressibleByArrayLiteral

extension RedBlackTreeMultiMap: ExpressibleByArrayLiteral {

  /// - Complexity: O(*n* log *n*)
  @inlinable
  @inline(__always)
  public init(arrayLiteral elements: (Key, Value)...) {
    self.init(multiKeysWithValues: elements)
  }
}

// MARK: - CustomStringConvertible

extension RedBlackTreeMultiMap: CustomStringConvertible {

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

extension RedBlackTreeMultiMap: CustomDebugStringConvertible {

  public var debugDescription: String {
    var result = "RedBlackTreeMultiMap<\(Key.self), \(Value.self)>("
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

extension RedBlackTreeMultiMap: CustomReflectable {
  /// The custom mirror for this instance.
  public var customMirror: Mirror {
    Mirror(self, unlabeledChildren: self, displayStyle: .dictionary)
  }
}

// MARK: - Equatable

extension RedBlackTreeMultiMap: Equatable where Value: Equatable {

  /// - Complexity: O(*m*), where *m* is the lesser of the length of `lhs` and `rhs`.
  @inlinable
  @inline(__always)
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.count == rhs.count && lhs.elementsEqual(rhs)
  }
}

// MARK: - Comparable

extension RedBlackTreeMultiMap: Comparable where Value: Comparable {

  /// - Complexity: O(*m*), where *m* is the lesser of the length of `lhs` and `rhs`.
  @inlinable
  @inline(__always)
  public static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.lexicographicallyPrecedes(rhs)
  }
}

// MARK: -

extension RedBlackTreeMultiMap where Value: Equatable {

  /// - Complexity: O(*m*), where *m* is the lesser of the length of the
  ///   sequence and the length of `other`.
  @inlinable
  @inline(__always)
  public func elementsEqual<OtherSequence>(_ other: OtherSequence) -> Bool
  where OtherSequence: Sequence, Element == OtherSequence.Element {
    elementsEqual(other, by: Tree.___key_value_equiv)
  }
}

extension RedBlackTreeMultiMap where Value: Comparable {

  /// - Complexity: O(*m*), where *m* is the lesser of the length of the
  ///   sequence and the length of `other`.
  @inlinable
  @inline(__always)
  public func lexicographicallyPrecedes<OtherSequence>(_ other: OtherSequence) -> Bool
  where OtherSequence: Sequence, Element == OtherSequence.Element {
    lexicographicallyPrecedes(other, by: Tree.___key_value_comp)
  }
}

// MARK: - Sendable

#if swift(>=5.5)
  extension RedBlackTreeMultiMap: @unchecked Sendable
  where Element: Sendable {}
#endif

#if swift(>=5.5)
  extension RedBlackTreeMultiMap.SubSequence: @unchecked Sendable
  where Element: Sendable {}
#endif

extension RedBlackTreeMultiMap {

  // 旧初期化実装
  // メモリ制限がきつい場合に備えて復活

  /// - Complexity: O(*n* log *n*)
  ///
  /// 標準のイニシャライザはメモリを余分につかう面がある。
  /// メモリ制限がきつい場合、こちらをお試しください
  @inlinable
  public init<Source>(naive sequence: __owned Source)
  where Element == Source.Element, Source: Sequence {
    let count = (sequence as? (any Collection))?.count
    var tree: Tree = .create(minimumCapacity: count ?? 0)
    for __k in sequence {
      if count == nil {
        Tree.ensureCapacity(tree: &tree)
      }
      var __parent = _NodePtr.nullptr
      // 検索の計算量がO(log *n*)
      let __child = tree.__find_leaf_high(&__parent, tree.__key(__k))
      if tree.__ptr_(__child) == .nullptr {
        let __h = tree.__construct_node(__k)
        // バランシングの最悪計算量が結局わからず、ならしO(1)とみている
        tree.__insert_node_at(__parent, __child, __h)
      }
    }
    self._storage = .init(tree: tree)
  }
}

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

  #if COMPATIBLE_ATCODER_2025
    public
      typealias KeyValue = (key: Key, value: Value)
  #else
    public
      typealias KeyValue = Pair<Key, Value>
  #endif

  public
    typealias Element = (key: Key, value: Value)

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

extension RedBlackTreeMultiMap: ___RedBlackTreeBase {}
extension RedBlackTreeMultiMap: ___RedBlackTreeCopyOnWrite {}
extension RedBlackTreeMultiMap: ___RedBlackTreeMulti {}
extension RedBlackTreeMultiMap: ___RedBlackTreeSequenceBase {}
extension RedBlackTreeMultiMap: KeyValueComparer {}
extension RedBlackTreeMultiMap: ElementComparable where Value: Comparable {}
extension RedBlackTreeMultiMap: ElementEqutable where Value: Equatable {}
extension RedBlackTreeMultiMap: ElementHashable where Key: Hashable, Value: Hashable {}

extension RedBlackTreeMultiMap: HasDefaultThreeWayComparator {}

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

  #if !COMPATIBLE_ATCODER_2025 && false
    /// - Complexity: O(*n* log *n* + *n*)
    @inlinable
    public init<S>(multiKeysWithValues keysAndValues: __owned S)
    where S: Sequence, S.Element == KeyValue {
      self._storage = .init(
        tree:
          .create_multi(sorted: keysAndValues.sorted { $0.key < $1.key }))
    }
  #endif

  /// - Complexity: O(*n* log *n* + *n*)
  @inlinable
  public init<S>(multiKeysWithValues keysAndValues: __owned S)
  where S: Sequence, S.Element == (Key, Value) {
    self._storage = .init(
      tree:
        .create_multi(sorted: keysAndValues.sorted { $0.0 < $1.0 }) { Self.__value_($0) })
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
    self._storage = .init(
      tree: try .create_multi(
        sorted: try values.sorted {
          try keyForValue($0) < keyForValue($1)
        },
        by: keyForValue
      ))
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

extension RedBlackTreeMultiMap {

  /// - Complexity: O(log *n*)
  @inlinable
  @inline(__always)
  @discardableResult
  public mutating func insert(key: Key, value: Value) -> (
    inserted: Bool, memberAfterInsert: Element
  ) {
    insert(Self.__value_(key, value))
  }

  #if !COMPATIBLE_ATCODER_2025 && false
    /// - Complexity: O(log *n*)
    @inlinable
    @inline(__always)
    @discardableResult
    public mutating func insert(_ tuple: (key: Key, value: Value)) -> (
      inserted: Bool, memberAfterInsert: Element
    ) {
      insert(Self.__value_(tuple))
    }
  #endif

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
    _ensureUnique { __tree_ in
      .___insert_range_multi(
        tree: __tree_,
        other: other.__tree_,
        other.__tree_.__begin_node_,
        other.__tree_.__end_node())
    }
  }

  #if !COMPATIBLE_ATCODER_2025 && false
    /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
    ///   and *m* is the size of the current tree.
    @inlinable
    public mutating func insert<S>(contentsOf other: S)
    where S: Sequence, S.Element == Pair<Key, Value> {
      _ensureUnique { __tree_ in
        .___insert_range_multi(tree: __tree_, other)
      }
    }
  #endif

  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  @inlinable
  public mutating func insert<S>(contentsOf other: S) where S: Sequence, S.Element == (Key, Value) {
    _ensureUnique { __tree_ in
      .___insert_range_multi(tree: __tree_, other.map { Self.__value_($0) })
    }
  }

  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  @inlinable
  public func inserting(contentsOf other: RedBlackTreeMultiMap<Key, Value>) -> Self {
    var result = self
    result.insert(contentsOf: other)
    return result
  }

  #if !COMPATIBLE_ATCODER_2025 && false
    /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
    ///   and *m* is the size of the current tree.
    @inlinable
    public func inserting<S>(contentsOf other: __owned S) -> Self
    where S: Sequence, S.Element == Pair<Key, Value> {
      var result = self
      result.insert(contentsOf: other)
      return result
    }
  #endif

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
  public static func + (lhs: Self, rhs: Self) -> Self {
    lhs.inserting(contentsOf: rhs)
  }

  /// - Complexity: O(*n* log(*m + n*))
  @inlinable
  @inline(__always)
  public static func += (lhs: inout Self, rhs: Self) {
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
  public mutating func popFirst() -> Element? {
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
  public mutating func remove(at index: Index) -> Element {
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
    .init(
      _storage: .init(
        tree: try __tree_.___filter(__tree_.__begin_node_, __tree_.__end_node(), isIncluded)))
  }
}

extension RedBlackTreeMultiMap {

  @inlinable
  public func mapValues<T>(_ transform: (Value) throws -> T) rethrows
    -> RedBlackTreeMultiMap<Key, T>
  {
    .init(
      _storage: .init(
        tree: try __tree_.___mapValues(__tree_.__begin_node_, __tree_.__end_node(), transform)))
  }

  @inlinable
  public func compactMapValues<T>(_ transform: (Value) throws -> T?)
    rethrows -> RedBlackTreeMultiMap<Key, T>
  {
    .init(
      _storage: .init(
        tree: try __tree_.___compactMapValues(
          __tree_.__begin_node_, __tree_.__end_node(), transform)))
  }
}

// MARK: - Sequence
// MARK: - Collection
// MARK: - BidirectionalCollection

extension RedBlackTreeMultiMap: Sequence, Collection, BidirectionalCollection {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public func makeIterator() -> Tree._KeyValues {
    _makeIterator()
  }

  @inlinable
  @inline(__always)
  public func forEach(_ body: (Element) throws -> Void) rethrows {
    try _forEach(body)
  }

  /// 特殊なforEach
  @inlinable
  @inline(__always)
  public func forEach(_ body: (Index, Element) throws -> Void) rethrows {
    try _forEach(body)
  }

  #if COMPATIBLE_ATCODER_2025
    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public func sorted() -> Tree._KeyValues {
      .init(tree: __tree_, start: __tree_.__begin_node_, end: __tree_.__end_node())
    }
  #else
    /// - Complexity: O(*n*)
    @inlinable
    @inline(__always)
    public func sorted() -> [Element] {
      __tree_.___copy_to_array(__tree_.__begin_node_, __tree_.__end_node())
    }
  #endif

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
  public subscript(position: Index) -> Element {
    @inline(__always) _read { yield self[_checked: position] }
  }

  /// - Warning: This subscript trades safety for performance. Using an invalid index results in undefined behavior.
  /// - Complexity: O(1)
  @inlinable
  public subscript(unchecked position: Index) -> Element {
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
  public func reversed() -> Tree._KeyValues.Reversed {
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
    _ other: OtherSequence, by areEquivalent: (Element, OtherSequence.Element) throws -> Bool
  ) rethrows -> Bool where OtherSequence: Sequence {
    try _elementsEqual(other, by: areEquivalent)
  }

  /// - Complexity: O(*m*), where *m* is the lesser of the length of the
  ///   sequence and the length of `other`.
  @inlinable
  @inline(__always)
  public func lexicographicallyPrecedes<OtherSequence>(
    _ other: OtherSequence, by areInIncreasingOrder: (Element, Element) throws -> Bool
  ) rethrows -> Bool where OtherSequence: Sequence, Element == OtherSequence.Element {
    try _lexicographicallyPrecedes(other, by: areInIncreasingOrder)
  }
}

extension RedBlackTreeMultiMap where Value: Equatable {

  /// - Complexity: O(*m*), where *m* is the lesser of the length of the
  ///   sequence and the length of `other`.
  @inlinable
  @inline(__always)
  public func elementsEqual<OtherSequence>(_ other: OtherSequence) -> Bool
  where OtherSequence: Sequence, Element == OtherSequence.Element {
    __tree_.elementsEqual(__tree_.__begin_node_, __tree_.__end_node(), other)
  }
}

extension RedBlackTreeMultiMap where Value: Comparable {

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

extension RedBlackTreeMultiMap {

  #if COMPATIBLE_ATCODER_2025
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
  #else
    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public var keys: Keys {
      .init(tree: __tree_, start: __tree_.__begin_node_, end: __tree_.__end_node())
    }

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public var values: Values {
      .init(tree: __tree_, start: __tree_.__begin_node_, end: __tree_.__end_node())
    }
  #endif
}

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

  public typealias SubSequence = RedBlackTreeSlice<Self>
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
    _dictionaryDescription(for: self)
  }
}

// MARK: - CustomDebugStringConvertible

extension RedBlackTreeMultiMap: CustomDebugStringConvertible {

  public var debugDescription: String {
    description
  }
}

// MARK: - CustomReflectable

extension RedBlackTreeMultiMap: CustomReflectable {
  /// The custom mirror for this instance.
  public var customMirror: Mirror {
    Mirror(self, unlabeledChildren: self, displayStyle: .dictionary)
  }
}

// MARK: - Is Identical To

extension RedBlackTreeMultiMap {

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

extension RedBlackTreeMultiMap: Equatable where Value: Equatable {

  /// - Complexity: O(*m*), where *m* is the lesser of the length of `lhs` and `rhs`.
  @inlinable
  @inline(__always)
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.__tree_ == rhs.__tree_
  }
}

// MARK: - Comparable

extension RedBlackTreeMultiMap: Comparable where Value: Comparable {

  /// - Complexity: O(*m*), where *m* is the lesser of the length of `lhs` and `rhs`.
  @inlinable
  @inline(__always)
  public static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.__tree_ < rhs.__tree_
  }
}

// MARK: - Hashable

extension RedBlackTreeMultiMap: Hashable where Key: Hashable, Value: Hashable {

  @inlinable
  @inline(__always)
  public func hash(into hasher: inout Hasher) {
    hasher.combine(__tree_)
  }
}

// MARK: - Sendable

#if swift(>=5.5)
  extension RedBlackTreeMultiMap: @unchecked Sendable
  where Element: Sendable {}
#endif

// MARK: - Codable

#if !COMPATIBLE_ATCODER_2025 && false
  extension RedBlackTreeMultiMap: Encodable where Key: Encodable, Value: Encodable {

    @inlinable
    public func encode(to encoder: Encoder) throws {
      var container = encoder.unkeyedContainer()
      for element in self {
        try container.encode(element)
      }
    }
  }

  extension RedBlackTreeMultiMap: Decodable where Key: Decodable, Value: Decodable {

    @inlinable
    public init(from decoder: Decoder) throws {
      _storage = .init(tree: try .create(from: decoder))
    }
  }
#endif

// MARK: - Init naive

extension RedBlackTreeMultiMap {

  /// - Complexity: O(*n* log *n*)
  ///
  /// 省メモリでの初期化
  @inlinable
  public init<Source>(naive sequence: __owned Source)
  where Element == Source.Element, Source: Sequence {
    self._storage = .init(tree: .create_multi(naive: sequence))
  }
}

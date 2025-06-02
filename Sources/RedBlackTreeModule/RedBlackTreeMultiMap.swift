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

  public
    typealias Index = Tree.Index

  public
    typealias KeyValue = (key: Key, value: Value)

  public
    typealias Element = KeyValue

  public
    typealias Keys = [Key]

  public
    typealias Values = [Value]

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
extension RedBlackTreeMultiMap: ___RedBlackTreeSequence { }
extension RedBlackTreeMultiMap: KeyValueComparer {}

// MARK: - Initialization（初期化）

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

  /// - Complexity: O(*n* log *n*)
  @inlinable
  public init<S>(keysWithValues keysAndValues: __owned S)
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
      // バランシングの計算量がO(log *n*)
      (__parent, __child) = tree.___emplace_hint_right(__parent, __child, __k)
      assert(tree.__tree_invariant(tree.__root()))
    }
    self._storage = .init(__tree: tree)
  }
}

extension RedBlackTreeMultiMap {

  @inlinable
  public mutating func reserveCapacity(_ minimumCapacity: Int) {
    _ensureUniqueAndCapacity(to: minimumCapacity)
  }
}

// MARK: - Insert（挿入）

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
  @discardableResult
  public mutating func insert(_ newMember: Element) -> (
    inserted: Bool, memberAfterInsert: Element
  ) {
    _ensureUniqueAndCapacity()
    _ = _tree.__insert_multi(newMember)
    return (true, newMember)
  }
}

extension RedBlackTreeMultiMap {

  /// - Complexity: O(log *n*)
  @discardableResult
  @inlinable
  public mutating func updateValue(_ newValue: Value, at ptr: RawIndex) -> Element? {
    guard
      !___is_null_or_end(ptr.rawValue),
      _tree.___is_valid_index(ptr.rawValue)
    else {
      return nil
    }
    _ensureUnique()
    let old = _tree[ptr.rawValue]
    _tree[ptr.rawValue].value = newValue
    return old
  }

  /// - Complexity: O(log *n*)
  @discardableResult
  @inlinable
  public mutating func updateValue(_ newValue: Value, at ptr: Index) -> Element? {
    guard
      !___is_null_or_end(ptr._rawValue),
      _tree.___is_valid_index(ptr._rawValue)
    else {
      return nil
    }
    _ensureUnique()
    let old = _tree[ptr.rawValue]
    _tree[ptr.rawValue].value = newValue
    return old
  }
}

extension RedBlackTreeMultiMap {

  /// - Complexity: O(*n* log *n*)
  @inlinable
  @inline(__always)
  public mutating func insert(contentsOf other: RedBlackTreeMultiMap<Key, Value>) {
    _ensureUniqueAndCapacity(to: count + other.count)
    _tree.__node_handle_merge_multi(other._tree)
  }

  /// - Complexity: O(*n* log *n*)
  @inlinable
  @inline(__always)
  public mutating func inserting(contentsOf other: RedBlackTreeMultiMap<Key, Value>) -> Self {
    var result = self
    result.insert(contentsOf: other)
    return result
  }

  /// - Complexity: O(*n* log *n*)
  @inlinable
  @inline(__always)
  public mutating func insert<S>(_ other: S) where S: Sequence, S.Element == Element {
    other.forEach { insert($0) }
  }

  /// - Complexity: O(*n* log *n*)
  @inlinable
  public func inserting<S>(_ other: __owned S) -> Self where S: Sequence, S.Element == Element {
    var result = self
    result.insert(other)
    return result
  }
}

// MARK: - Remove（削除）

extension RedBlackTreeMultiMap {
  /// 最小キーのペアを取り出して削除
  /// - Important: 削除したメンバーを指すインデックスが無効になります。
  /// - Complexity: O(1)
  @inlinable
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
    return _tree.___erase_unique(key)
  }

  /// - Important: 削除したメンバーを指すインデックスが無効になります。
  /// - Complexity: O(log *n*)
  @inlinable
  @discardableResult
  public mutating func removeFirst(_unsafeForKey key: Key) -> Bool {
    _ensureUnique()
    return _tree.___erase_unique(key)
  }

  /// - Important: 削除したメンバーを指すインデックスが無効になります。
  /// - Complexity: O(log *n* + *k*)
  @inlinable
  @discardableResult
  public mutating func removeAll(forKey key: Key) -> Int {
    _strongEnsureUnique()
    return _tree.___erase_multi(key)
  }

  /// - Important: 削除したメンバーを指すインデックスが無効になります。
  /// - Complexity: O(log *n* + *k*)
  @inlinable
  @discardableResult
  public mutating func removeAll(_unsafeForKey key: Key) -> Int {
    _ensureUnique()
    return _tree.___erase_multi(key)
  }
}

extension RedBlackTreeMultiMap {

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

  @inlinable
  public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
    _ensureUnique()
    ___removeAll(keepingCapacity: keepCapacity)
  }
}

extension RedBlackTreeMultiMap {

  /// - Complexity: O(log *n* + *k*)
  @inlinable
  @inline(__always)
  public mutating func remove(contentsOf keyRange: Range<Key>) {
    let lower = lowerBound(keyRange.lowerBound)
    let upper = lowerBound(keyRange.upperBound)
    removeSubrange(lower..<upper)
  }

  /// - Complexity: O(log *n* + *k*)
  @inlinable
  @inline(__always)
  public mutating func remove(contentsOf keyRange: ClosedRange<Key>) {
    let lower = lowerBound(keyRange.lowerBound)
    let upper = upperBound(keyRange.upperBound)
    removeSubrange(lower..<upper)
  }
}

// MARK: - Search（検索・探索）

extension RedBlackTreeMultiMap {

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

extension RedBlackTreeMultiMap {

  /// - Complexity: O(log *n*)
  @inlinable
  public func lowerBound(_ p: Key) -> Index {
    ___iter_lower_bound(p)
  }

  /// - Complexity: O(log *n*)
  @inlinable
  public func upperBound(_ p: Key) -> Index {
    ___iter_upper_bound(p)
  }
}

extension RedBlackTreeMultiMap {

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
    ___first_iter(of: key)
  }

  /// - Complexity: O(*n*)
  @inlinable
  public func firstIndex(where predicate: (Element) throws -> Bool) rethrows -> Index? {
    try ___first_iter(where: predicate)
  }
}

extension RedBlackTreeMultiMap {

  /// - Complexity: O(log *n* + *k*)
  @inlinable
  public func count(forKey key: Key) -> Int {
    _tree.__count_multi(key)
  }
}

extension RedBlackTreeMultiMap {

  /// - Complexity: O(log *n*)
  @inlinable
  public func equalRange(_ key: Key) -> (lower: Tree.___Iterator, upper: Tree.___Iterator) {
    ___equal_range(key)
  }
}

// MARK: - Transformation

extension RedBlackTreeMultiMap {

  /// - Complexity: O(*n*)
  @inlinable
  public func filter(
    _ isIncluded: (Element) throws -> Bool
  ) rethrows -> Self {
    var tree: Tree = .create(minimumCapacity: 0)
    var (__parent, __child) = tree.___max_ref()
    for pair in self where try isIncluded(pair) {
      Tree.ensureCapacity(tree: &tree)
      (__parent, __child) = tree.___emplace_hint_right(__parent, __child, pair)
      assert(tree.__tree_invariant(tree.__root()))
    }
    return Self(_storage: .init(__tree: tree))
  }
}

extension RedBlackTreeMultiMap {

  @inlinable
  public func mapValues<T>(_ transform: (Value) throws -> T) rethrows
    -> RedBlackTreeMultiMap<Key, T>
  {
    typealias Tree = RedBlackTreeMultiMap<Key, T>.Tree
    let tree: Tree = .create(minimumCapacity: count)
    var (__parent, __child) = tree.___max_ref()
    for (k, v) in self {
      (__parent, __child) = tree.___emplace_hint_right(__parent, __child, (k, try transform(v)))
      assert(tree.__tree_invariant(tree.__root()))
    }
    return .init(_storage: .init(__tree: tree))
  }

  @inlinable
  public func compactMapValues<T>(_ transform: (Value) throws -> T?)
    rethrows -> RedBlackTreeMultiMap<Key, T>
  {
    typealias Tree = RedBlackTreeMultiMap<Key, T>.Tree
    var tree: Tree = .create(minimumCapacity: 0)
    var (__parent, __child) = tree.___max_ref()
    for (k, v) in self {
      if let new = try transform(v) {
        Tree.ensureCapacity(tree: &tree)
        (__parent, __child) = tree.___emplace_hint_right(__parent, __child, (k, new))
        assert(tree.__tree_invariant(tree.__root()))
      }
    }
    return .init(_storage: .init(__tree: tree))
  }
}

// MARK: - Utility（ユーティリティ、isEmptyやcapacityなど）

extension RedBlackTreeMultiMap {

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

extension RedBlackTreeMultiMap {

  /// - Complexity: O(*n*)
  public var keys: Keys {
    map(\.key)
  }

  /// - Complexity: O(*n*)
  public var values: Values {
    map(\.value)
  }
}

extension RedBlackTreeMultiMap {

  /// - Complexity: O(log *n* + *k*)
  @inlinable
  public func values(forKey key: Key) -> [Value] {
    var (lo, hi) = _tree.__equal_range_multi(key)
    var result = [Value]()
    while lo != hi {
      result.append(_tree.___element(lo).value)
      lo = _tree.__tree_next(lo)
    }
    return result
  }
}

// MARK: - Sequence
// MARK: - Collection
// MARK: - BidirectionalCollection

extension RedBlackTreeMultiMap: Sequence, Collection, BidirectionalCollection { }

// MARK: - Range Access

extension RedBlackTreeMultiMap {

  /// - Complexity: O(1)
  @inlinable
  public subscript(bounds: Range<Index>) -> SubSequence {
    .init(tree: _tree, start: bounds.lowerBound.rawValue, end: bounds.upperBound.rawValue)
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
  public subscript(bounds: Range<Key>) -> SubSequence {
    elements(in: bounds)
  }

  /// 範囲 `[lower, upper]` に含まれる要素を返します。
  ///
  /// index範囲ではないことに留意
  /// **Deprecated – `elements(in:)` を使ってください。**
  @available(*, deprecated, renamed: "elements(in:)")
  @inlinable
  public subscript(bounds: ClosedRange<Key>) -> SubSequence {
    elements(in: bounds)
  }
}

extension RedBlackTreeMultiMap {
  /// キーレンジ `[lower, upper)` に含まれる要素のスライス
  /// - Complexity: O(log *n*)
  @inlinable
  public func elements(in range: Range<Key>) -> SubSequence {
    .init(tree: _tree, start: ___ptr_lower_bound(range.lowerBound), end: ___ptr_lower_bound(range.upperBound))
  }

  /// キーレンジ `[lower, upper]` に含まれる要素のスライス
  /// - Complexity: O(log *n*)
  @inlinable
  public func elements(in range: ClosedRange<Key>) -> SubSequence {
    .init(tree: _tree, start: ___ptr_lower_bound(range.lowerBound), end: ___ptr_upper_bound(range.upperBound))
  }
}

// MARK: - SubSequence

extension RedBlackTreeMultiMap {

  /// - Complexity: O(log *n*)
  @inlinable
  @inline(__always)
  public subscript(key: Key) -> SubSequence {
    let (lo, hi) = self.___equal_range(key)
    return .init(tree: _tree, start: lo.rawValue, end: hi.rawValue)
  }
}

extension RedBlackTreeMultiMap {

  @frozen
  public struct SubSequence {

    @usableFromInline
    let _tree: Tree

    @usableFromInline
    var _start, _end: _NodePtr

    @inlinable
    @inline(__always)
    internal init(tree: Tree, start: _NodePtr, end: _NodePtr) {
      _tree = tree
      _start = start
      _end = end
    }
  }
}

extension RedBlackTreeMultiMap: ___RedBlackTreeSubSequence { }

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

// MARK: - Raw Index Sequence

extension RedBlackTreeMultiMap {

  /// RawIndexは赤黒木ノードへの軽量なポインタとなっていて、rawIndicesはRawIndexのシーケンスを返します。
  /// 削除時のインデックス無効対策がイテレータに施してあり、削除操作に利用することができます。
  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public var rawIndices: RawIndexSequence<Tree> {
    RawIndexSequence(tree: _tree)
  }
}

// MARK: - Enumerated Sequence

extension RedBlackTreeMultiMap {

  /// - Complexity: O(1)
  @inlinable @inline(__always)
  public var rawIndexedElements: RawIndexedSequence<Tree> {
    RawIndexedSequence(tree: _tree)
  }
}

// MARK: - ExpressibleByDictionaryLiteral

extension RedBlackTreeMultiMap: ExpressibleByDictionaryLiteral {

  /// - Complexity: O(*n* log *n*)
  @inlinable
  public init(dictionaryLiteral elements: (Key, Value)...) {
    self.init(keysWithValues: elements)
  }
}

// MARK: - ExpressibleByArrayLiteral

extension RedBlackTreeMultiMap: ExpressibleByArrayLiteral {

  /// - Complexity: O(*n* log *n*)
  @inlinable
  public init(arrayLiteral elements: (Key, Value)...) {
    self.init(keysWithValues: elements)
  }
}

// MARK: - CustomStringConvertible

extension RedBlackTreeMultiMap: CustomStringConvertible {

  @inlinable
  public var description: String {
    let pairs = map { "\($0.key): \($0.value)" }
    return "[\(pairs.joined(separator: ", "))]"
  }

}

// MARK: - CustomDebugStringConvertible

extension RedBlackTreeMultiMap: CustomDebugStringConvertible {

  @inlinable
  public var debugDescription: String {
    return "RedBlackTreeMultiMap<\(String(describing: Key.self)),\(String(describing: Value.self))>(\(description))"
  }
}

// MARK: - Equatable

extension RedBlackTreeMultiMap: Equatable where Value: Equatable {

  /// - Complexity: O(*n* log *n*)
  @inlinable
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.___equal_with(rhs)
  }
}

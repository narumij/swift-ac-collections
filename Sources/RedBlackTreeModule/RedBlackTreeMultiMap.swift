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
/// - Important: `RedBlackTreeMultiMap` はスレッドセーフではありません。
@frozen
public struct RedBlackTreeMultiMap<Key: Comparable, Value> {

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

extension RedBlackTreeMultiMap {
  public typealias Base = Self
}

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiMap: _RedBlackTreeKeyValues {}
#endif
//extension RedBlackTreeMultiMap: _RedBlackTreeKeyValuesBase {}

extension RedBlackTreeMultiMap: CompareMultiTrait {}
extension RedBlackTreeMultiMap: PairValueTrait {}
extension RedBlackTreeMultiMap: _PairBasePayload_KeyProtocol_ptr {}
extension RedBlackTreeMultiMap: _BaseNode_NodeCompareProtocol {}

// MARK: - Creating a MultiMap

extension RedBlackTreeMultiMap {

  /// - Complexity: O(1)
  @inlinable @inline(__always)
  public init() {
    self.init(__tree_: .create())
  }

  /// - Complexity: O(1)
  @inlinable @inline(__always)
  public init(minimumCapacity: Int) {
    self.init(__tree_: .create(minimumCapacity: minimumCapacity))
  }
}

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiMap {

    /// - Complexity: O(*n* log *n*)
    ///   ソート済み列からの逐次挿入では探索が不要となり、再平衡は償却 O(1) のため、
    ///   全体の構築コストは O(*n*)
    @inlinable
    public init<S>(multiKeysWithValues keysAndValues: __owned S)
    where S: Sequence, S.Element == (Key, Value) {
      self.init(
        __tree_:
          .___insert_range_multi(
            tree: .create(),
            keysAndValues,
            transform: Base.__payload_(_:)))
    }

    /// - Complexity: O(*n* log *n*)
    ///   ソート済み列からの逐次挿入では探索が不要となり、再平衡は償却 O(1) のため、
    ///   全体の構築コストは O(*n*)
    @inlinable
    public init<S>(multiKeysWithValues keysAndValues: __owned S)
    where S: Collection, S.Element == (Key, Value) {
      self.init(
        __tree_:
          .___insert_range_multi(
            tree:
              .create(minimumCapacity: keysAndValues.count),
            keysAndValues,
            transform: Base.__payload_(_:)))
    }
  }
#endif

extension RedBlackTreeMultiMap {
  // Dictionaryからぱくってきたが、割と様子見

  /// - Complexity: O(*n* log *n* + *n*)
  @inlinable
  public init<S: Sequence>(
    grouping values: __owned S,
    by keyForValue: (S.Element) throws -> Key
  ) rethrows where Value == S.Element {
    self.init(
      __tree_: try .create_multi(
        sorted: try values.sorted {
          try keyForValue($0) < keyForValue($1)
        },
        by: keyForValue
      ))
  }
}

// MARK: -

extension RedBlackTreeMultiMap {

  @inlinable
  public mutating func reserveCapacity(_ minimumCapacity: Int) {
    __tree_.ensureUniqueAndCapacity(to: minimumCapacity)
  }
}

// MARK: - Inspecting a MultiMap

extension RedBlackTreeMultiMap {

  /// - Complexity: O(1)
  @inlinable
  public var capacity: Int {
    __tree_.capacity
  }
}

extension RedBlackTreeMultiMap {

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

extension RedBlackTreeMultiMap {

  /// - Complexity: O(log *n* + *k*)
  @inlinable
  public func count(forKey key: Key) -> Int {
    __tree_.__count_multi(key)
  }
}

// MARK: - Testing for Membership

extension RedBlackTreeMultiMap {

  /// - Complexity: O(log *n*)
  @inlinable
  public func contains(key: Key) -> Bool {
    __tree_.__count_unique(key) != 0
  }
}

// MARK: - Accessing Keys and Values

extension RedBlackTreeMultiMap {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public var first: Element? {
    isEmpty ? nil : Base.__element_(__tree_[_unsafe_raw: _start])
  }

  /// - Complexity: O(log *n*)
  @inlinable
  @inline(__always)
  public var last: Element? {
    isEmpty ? nil : Base.__element_(__tree_[_unsafe_raw: __tree_.__tree_prev_iter(_end)])
  }
}

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiMap {

    /// - Complexity: O(log *n*)
    @inlinable
    @inline(__always)
    public subscript(key: Key) -> View {
      @inline(__always) get {
        let (lower, upper) = ___equal_range(key)
        return self[unchecked: .init(lowerBound: lower.sealed, upperBound: upper.sealed)]
      }
      @inline(__always) _modify {
        let (lower, upper) = ___equal_range(key)
        yield &self[unchecked: .init(lowerBound: lower.sealed, upperBound: upper.sealed)]
      }
    }
  }
#endif

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiMap {

    /// - Complexity: O(log *n*)
    @inlinable
    public func values(forKey key: Key) -> [_MappedValue] {
      let (lo, hi) = __tree_.__equal_range_multi(key)
      return __tree_.___copy_to_array(lo, hi, transform: Base.___mapped_value)
    }
  }
#endif

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
    __tree_.ensureUniqueAndCapacity()
    _ = __tree_.__insert_multi(Self.__payload_(newMember))
    return (true, newMember)
  }
}

extension RedBlackTreeMultiMap {

  /// - Complexity: O(log *n*)
  @inlinable
  @inline(__always)
  @discardableResult
  public mutating func updateValue(_ newValue: Value, at ptr: Index) -> Element? {
    __tree_.ensureUnique()
    guard let p = __tree_.__purified_(ptr).pointer, p.sealed.exists
    else { return nil }
    let old = __tree_[_unsafe_raw: p]
    __tree_[_unsafe_raw: p].value = newValue
    return Self.__element_(old)
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
    __tree_.ensureUnique { __tree_ in
      .___insert_range_multi(
        tree: __tree_,
        other: other.__tree_,
        other.__tree_.__begin_node_,
        other.__tree_.__end_node)
    }
  }

  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  @inlinable
  public mutating func insert<S>(contentsOf other: S) where S: Sequence, S.Element == (Key, Value) {
    __tree_.ensureUnique { __tree_ in
      .___insert_range_multi(tree: __tree_, other.map { Self.__payload_($0) })
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
    __tree_ = __tree_.___meld_multi(other.__tree_)
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
}

extension RedBlackTreeMultiMap {

  /// - Important: 削除後は、インデックスが無効になります。
  /// - Complexity: O(1)
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

extension RedBlackTreeMultiMap {

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

extension RedBlackTreeMultiMap {

  /// - Complexity: O(log *n*)
  ///
  /// O(1)が欲しい場合、firstが等価でO(1)
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

extension RedBlackTreeMultiMap {

  /// - Complexity: O(*n*)
  @inlinable
  public func filter(
    _ isIncluded: (Element) throws -> Bool
  ) rethrows -> Self {
    .init(
      __tree_: try __tree_.___filter(_start, _end) {
        try isIncluded(Self.__element_($0))
      }
    )
  }
}

extension RedBlackTreeMultiMap {

  /// - Complexity: O(*n*)
  @inlinable
  public func mapValues<T>(_ transform: (Value) throws -> T) rethrows
    -> RedBlackTreeMultiMap<Key, T>
  {
    .init(__tree_: try __tree_.___mapValues(_start, _end, transform))
  }

  /// - Complexity: O(*n*)
  @inlinable
  public func compactMapValues<T>(_ transform: (Value) throws -> T?)
    rethrows -> RedBlackTreeMultiMap<Key, T>
  {
    .init(__tree_: try __tree_.___compactMapValues(_start, _end, transform))
  }
}

// MARK: - Sequence
// MARK: - Collection
// MARK: - BidirectionalCollection

extension RedBlackTreeMultiMap: Sequence {}

extension RedBlackTreeMultiMap {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public func makeIterator() -> Tree._KeyValues {
    .init(start: _sealed_start, end: _sealed_end, tie: __tree_.tied)
  }
}

extension RedBlackTreeMultiMap {

  /// - Complexity: O(`count`)
  @inlinable
  @inline(__always)
  public func sorted() -> [Element] {
    __tree_.___copy_all_to_array(transform: Base.__element_)
  }
}

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiMap {

    /// - Complexity: O(`count`)
    @inlinable
    @inline(__always)
    public func reversed() -> [Element] {
      __tree_.___rev_copy_all_to_array(transform: Base.__element_)
    }
  }
#endif

// MARK: -

extension RedBlackTreeMultiMap {

  #if !COMPATIBLE_ATCODER_2025
    #if false
      /// - Complexity: O(1)
      @inlinable
      @inline(__always)
      public var keys: Keys {
        .init(start: _sealed_start, end: _sealed_end, tie: __tree_.tied)
      }

      /// - Complexity: O(1)
      @inlinable
      @inline(__always)
      public var values: Values {
        .init(start: _sealed_start, end: _sealed_end, tie: __tree_.tied)
      }
    #else
      // 速いし気にすること減るし、こっちのほうがいいかなって
      // TODO: どっちの方針にするか検討確定すること

      /// - Complexity: O(1)
      @inlinable
      @inline(__always)
      public var keys: [Key] {
        __tree_.___copy_all_to_array(transform: Base.__key)
      }

      /// - Complexity: O(1)
      @inlinable
      @inline(__always)
      public var values: [Value] {
        __tree_.___copy_all_to_array(transform: Base.___mapped_value)
      }
    #endif
  #endif
}

// MARK: -

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiMap {

    /// - Important:
    ///  要素及びノードが削除された場合、インデックスは無効になります。
    /// 無効なインデックスを使用するとランタイムエラーや不正な参照が発生する可能性があるため注意してください。
    public typealias Index = UnsafeIndexV3
    public typealias SubSequence = RedBlackTreeKeyValueRangeView<Base>
  }

  extension RedBlackTreeMultiMap {

    @inlinable
    func ___index(_ p: _SealedPtr) -> UnsafeIndexV3 {
      p.band(__tree_.tied)
    }

    @inlinable
    func ___index_or_nil(_ p: _SealedPtr) -> UnsafeIndexV3? {
      p.exists ? p.band(__tree_.tied) : nil
    }
  }

  extension RedBlackTreeMultiMap {
    // TODO: 標準踏襲でOptionalとしてるが、やや疑問。再検討すること
    /// - Complexity: O( log `count` )
    @inlinable
    public func firstIndex(of key: Key)
      -> Index?
    {
      ___index_or_nil(__tree_.find(key).sealed)
    }
  }

  extension RedBlackTreeMultiMap {

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public var startIndex: Index { ___index(_sealed_start) }

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public var endIndex: Index { ___index(_sealed_end) }
  }

  extension RedBlackTreeMultiMap {

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

  extension RedBlackTreeMultiMap {

    /// 与えられた値より小さくない最初の要素へのインデックスを返す
    ///
    /// `lowerBound(_:)` は、指定した要素 `member` 以上の値が格納されている
    /// 最初の位置（`Index`）を返します。
    ///
    /// たとえば、ソートされた `[1, 3, 5, 7, 9]` があるとき、
    /// - `lowerBound(0)` は最初の要素 `1` の位置を返します。（つまり `startIndex`）
    /// - `lowerBound(3)` は要素 `3` の位置を返します。
    /// - `lowerBound(4)` は要素 `5` の位置を返します。（`4` 以上で最初に出現する値が `5`）
    /// - `lowerBound(10)` は `endIndex` を返します。
    ///
    /// - Parameter member: 二分探索で検索したい要素
    /// - Returns: 指定した要素 `member` 以上の値が格納されている先頭の `Index`
    /// - Complexity: O(log *n*), where *n* is the number of elements.
    @inlinable
    public func lowerBound(_ key: Key) -> Index {
      ___index(__tree_.lower_bound(key).sealed)
    }

    /// 与えられた値よりも大きい最初の要素へのインデックスを返す
    ///
    /// `upperBound(_:)` は、指定した要素 `member` より大きい値が格納されている
    /// 最初の位置（`Index`）を返します。
    ///
    /// たとえば、ソートされた `[1, 3, 5, 5, 7, 9]` があるとき、
    /// - `upperBound(3)` は要素 `5` の位置を返します。
    ///   （`3` より大きい値が最初に現れる場所）
    /// - `upperBound(5)` は要素 `7` の位置を返します。
    ///   （`5` と等しい要素は含まないため、`5` の直後）
    /// - `upperBound(9)` は `endIndex` を返します。
    ///
    /// - Parameter member: 二分探索で検索したい要素
    /// - Returns: 指定した要素 `member` より大きい値が格納されている先頭の `Index`
    /// - Complexity: O(log *n*), where *n* is the number of elements.
    @inlinable
    public func upperBound(_ key: Key) -> Index {
      ___index(__tree_.upper_bound(key).sealed)
    }
  }

  extension RedBlackTreeMultiMap {

    /// - Complexity: O(log *n*), where *n* is the number of elements.
    @inlinable
    public func equalRange(_ key: Key) -> UnsafeIndexV3Range {
      let (lower, upper) = __tree_.__equal_range_multi(key)
      return .init(.init(lowerBound: ___index(lower.sealed), upperBound: ___index(upper.sealed)))
    }
  }

  extension RedBlackTreeMultiMap {

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

  extension RedBlackTreeMultiMap {

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
  extension RedBlackTreeMultiMap {

    /// Indexがsubscriptやremoveで利用可能か判別します
    ///
    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public func isValid(index: Index) -> Bool {
      __tree_.__purified_(index).exists
    }
  }

  extension RedBlackTreeMultiMap {

    /// - Complexity: O(1)
    @inlinable
    public subscript(position: Index) -> Element {
      @inline(__always) get {
        Base.__element_(__tree_[_unsafe: __tree_.__purified_(position)])
      }
    }
  }

  extension RedBlackTreeMultiMap {

    @discardableResult
    @inlinable @inline(__always)
    public mutating func erase(_ ptr: Index) -> Index {
      ___index(__tree_.erase(__tree_.__purified_(ptr).pointer!).sealed)
    }
  }

  extension RedBlackTreeMultiMap {

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

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiMap {

    /// - Important: 削除したメンバーを指すインデックスが無効になります。
    /// - Complexity: O(log *n*)
    @inlinable
    @inline(__always)
    @discardableResult
    public mutating func eraseUnique(_ key: Key) -> Bool {
      __tree_._strongEnsureUnique()
      return __tree_.___erase_unique(key)
    }
  }

  extension RedBlackTreeMultiMap {

    // TODO: イテレータ利用の注意をドキュメントすること
    /// - Important: 削除したメンバーを指すインデックスが無効になります。
    /// - Complexity: O(log *n* + *k*)
    @inlinable
    @discardableResult
    public mutating func eraseMulti(_ key: Key) -> Int {
      __tree_._strongEnsureUnique()
      return __tree_.___erase_multi(key)
    }
  }
#endif

// MARK: - Protocol Conformance

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
    Mirror(self, unlabeledChildren: self + [], displayStyle: .dictionary)
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
  where Key: Sendable, Value: Sendable {}
#endif

// MARK: - Codable

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiMap: Encodable where Key: Encodable, Value: Encodable {

    @inlinable
    public func encode(to encoder: Encoder) throws {
      var container = encoder.unkeyedContainer()
      for element in __tree_.unsafeValues(__tree_.__begin_node_, __tree_.__end_node) {
        try container.encode(element)
      }
    }
  }

  extension RedBlackTreeMultiMap: Decodable where Key: Decodable, Value: Decodable {

    @inlinable
    public init(from decoder: Decoder) throws {
      self.init(__tree_: try .create(from: decoder))
    }
  }
#endif

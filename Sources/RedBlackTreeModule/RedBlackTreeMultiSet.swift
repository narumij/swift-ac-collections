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

/// `RedBlackTreeMultiSet` は、`Element` 型の要素を格納するための
/// 赤黒木（Red-Black Tree）ベースのマルチセット型です。
///
/// ### 使用例
/// ```swift
/// var multiset = RedBlackTreeMultiSet<Int>()
/// multiset.insert(5)
/// multiset.insert(3)
/// multiset.insert(5) // 重複した要素の挿入
///
/// // 要素の出現回数を確認
/// print(multiset.count(of: 5)) // 出力例: 2
/// print(multiset.count(of: 3)) // 出力例: 1
/// ```
/// - Important: `RedBlackTreeMultiSet` はスレッドセーフではありません。
@frozen
public struct RedBlackTreeMultiSet<Element: Comparable> {

  public typealias Element = Element

  public typealias _Key = Element

  public typealias _PayloadValue = Element

  @usableFromInline
  var __tree_: Tree

  @inlinable @inline(__always)
  internal init(__tree_: Tree) {
    self.__tree_ = __tree_
  }
}

extension RedBlackTreeMultiSet {
  public typealias Base = Self
}

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiSet: _RedBlackTreeKeyOnly {}
#endif

extension RedBlackTreeMultiSet: CompareMultiTrait {}
extension RedBlackTreeMultiSet: ScalarValueTrait {}
extension RedBlackTreeMultiSet: _ScalarBasePayload_KeyProtocol_ptr {}
extension RedBlackTreeMultiSet: _BaseNode_NodeCompareProtocol {}

// MARK: - Creating a MultSet

extension RedBlackTreeMultiSet {

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
  extension RedBlackTreeMultiSet {

    /// - Complexity: O(*n* log *n*)
    ///   ソート済み列からの逐次挿入では探索が不要となり、再平衡は償却 O(1) のため、
    ///   全体の構築コストは O(*n*)
    @inlinable
    public init<Source>(_ sequence: __owned Source)
    where Element == Source.Element, Source: Sequence {
      self.init(
        __tree_:
          .___insert_range_multi(
            tree: .create(),
            sequence))
    }

    /// - Complexity: O(*n* log *n*)
    ///   ソート済み列からの逐次挿入では探索が不要となり、再平衡は償却 O(1) のため、
    ///   全体の構築コストは O(*n*)
    @inlinable
    public init<Source>(_ collection: __owned Source)
    where Element == Source.Element, Source: Collection {
      self.init(
        __tree_:
          .___insert_range_multi(
            tree: .create(minimumCapacity: collection.count),
            collection))
    }
  }
#endif

extension RedBlackTreeMultiSet {

  /// - Important: 昇順を想定して処理を省いている。降順に用いた場合未定義
  /// - Complexity: O(*n*)
  @inlinable
  public init<R>(_ range: __owned R)
  where R: RangeExpression, R: Collection, R.Element == Element {
    precondition(range is Range<Element> || range is ClosedRange<Element>)
    self.init(__tree_: .create(range: range))
  }
}

// MARK: -

extension RedBlackTreeMultiSet {

  @inlinable
  public mutating func reserveCapacity(_ minimumCapacity: Int) {
    __tree_.ensureUniqueAndCapacity(to: minimumCapacity)
  }
}

// MARK: - Inspecting a MultiSet

extension RedBlackTreeMultiSet {

  /// - Complexity: O(1)
  @inlinable
  public var capacity: Int {
    __tree_.capacity
  }
}

extension RedBlackTreeMultiSet {

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

extension RedBlackTreeMultiSet {

  /// - Complexity: O(log *n* + *k*)
  @inlinable
  public func count(of element: Element) -> Int {
    __tree_.__count_multi(element)
  }
}

// MARK: - Testing for Membership

extension RedBlackTreeMultiSet {

  /// - Complexity: O(*n*)
  @inlinable
  public func contains(_ member: Element) -> Bool {
    __tree_.__count_unique(member) != 0
  }
}

// MARK: - Accessing Elements

extension RedBlackTreeMultiSet {

  /// - Complexity: O(1)。
  @inlinable
  @inline(__always)
  public var first: Element? {
    isEmpty ? nil : __tree_[_unsafe_raw: _start]
  }

  /// - Complexity: O(log *n*)
  @inlinable
  public var last: Element? {
    isEmpty ? nil : __tree_[_unsafe_raw: __tree_.__tree_prev_iter(_end)]
  }
}

// MARK: - Range Accessing Elements

// MARK: - Insert

extension RedBlackTreeMultiSet {

  /// - Complexity: O(log *n*)
  @inlinable
  @inline(__always)
  @discardableResult
  public mutating func insert(_ newMember: Element) -> (
    inserted: Bool, memberAfterInsert: Element
  ) {
    __tree_.ensureUniqueAndCapacity()
    _ = __tree_.__insert_multi(newMember)
    return (true, newMember)
  }
}

// MARK: - Combining MultiSet

extension RedBlackTreeMultiSet {

  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  ///
  /// - Important: 空間計算量に余裕がある場合、meldの使用を推奨します
  @inlinable
  public mutating func insert(contentsOf other: RedBlackTreeSet<Element>) {
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
  public mutating func insert(contentsOf other: RedBlackTreeMultiSet<Element>) {
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
  public mutating func insert<S>(contentsOf other: S) where S: Sequence, S.Element == Element {
    __tree_.ensureUnique { __tree_ in
      .___insert_range_multi(tree: __tree_, other)
    }
  }

  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  @inlinable
  public func inserting(contentsOf other: RedBlackTreeSet<Element>) -> Self {
    var result = self
    result.insert(contentsOf: other)
    return result
  }

  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  ///
  /// - Important: 空間計算量に余裕がある場合、meldingの使用を推奨します
  @inlinable
  public func inserting(contentsOf other: RedBlackTreeMultiSet<Element>) -> Self {
    var result = self
    result.insert(contentsOf: other)
    return result
  }

  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  @inlinable
  public func inserting<S>(contentsOf other: __owned S) -> Self
  where S: Sequence, S.Element == Element {
    var result = self
    result.insert(contentsOf: other)
    return result
  }
}

extension RedBlackTreeMultiSet {

  /// - Complexity: O(*n* + *m*)
  @inlinable
  @inline(__always)
  public mutating func meld(_ other: __owned RedBlackTreeMultiSet<Element>) {
    __tree_ = __tree_.___meld_multi(other.__tree_)
  }

  /// - Complexity: O(*n* + *m*)
  @inlinable
  @inline(__always)
  public func melding(_ other: __owned RedBlackTreeMultiSet<Element>)
    -> RedBlackTreeMultiSet<Element>
  {
    var result = self
    result.meld(other)
    return result
  }
}

extension RedBlackTreeMultiSet {

  /// - Complexity: O(*n* log(*m + n*))
  @inlinable
  public static func + (lhs: Self, rhs: Self) -> Self {
    lhs.inserting(contentsOf: rhs)
  }

  /// - Complexity: O(*n* log(*m + n*))
  @inlinable
  public static func += (lhs: inout Self, rhs: Self) {
    lhs.insert(contentsOf: rhs)
  }
}

// MARK: - Remove

extension RedBlackTreeMultiSet {

  /// - Important: 削除したメンバーを指すインデックスが無効になります。
  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public mutating func popFirst() -> Element? {
    __tree_.ensureUnique()
    return ___remove_first()?.payload
  }
}

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiSet {

    /// - Complexity: O(log `count`)
    @inlinable
    public mutating func popLast() -> Element? {
      __tree_.ensureUnique()
      return ___remove_last()?.payload
    }
  }
#endif

extension RedBlackTreeMultiSet {

  /// - Important: 削除したメンバーを指すインデックスが無効になります。
  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  @discardableResult
  public mutating func removeFirst() -> Element {
    __tree_.ensureUnique()
    guard let element = ___remove_first() else {
      preconditionFailure(.emptyFirst)
    }
    return element.payload
  }

  /// - Important: 削除したメンバーを指すインデックスが無効になります。
  /// - Complexity: O(log *n*)
  @inlinable
  @discardableResult
  public mutating func removeLast() -> Element {
    __tree_.ensureUnique()
    guard let element = ___remove_last() else {
      preconditionFailure(.emptyFirst)
    }
    return element.payload
  }
}

extension RedBlackTreeMultiSet {

  /// - Important: 削除したメンバーを指すインデックスが無効になります。
  /// - Complexity: O(log *n*)
  @inlinable
  @inline(__always)
  @discardableResult
  public mutating func remove(_ member: Element) -> Element? {
    __tree_._strongEnsureUnique()
    return __tree_.___erase_unique(member) ? member : nil
  }
}

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiSet {

    /// - Important: 削除後は、インデックスが無効になります。
    /// - Complexity: O(1)
    @inlinable
    @discardableResult
    public mutating func remove(at index: Index) -> Element {
      __tree_.ensureUnique()
      guard let __p = __tree_.__purified_(index).pointer else {
        fatalError(.invalidIndex)
      }
      return _unchecked_remove(at: __p).payload
    }
  }
#endif

extension RedBlackTreeMultiSet {

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

// MARK: Finding Elements

extension RedBlackTreeMultiSet {

  /// - Complexity: O(*n*)
  ///
  /// O(1)が欲しい場合、firstが等価でO(1)
  @inlinable
  public func min() -> Element? {
    __tree_.___min()
  }

  /// - Complexity: O(*n*)
  @inlinable
  public func max() -> Element? {
    __tree_.___max()
  }
}

// MARK: - Transformation

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiSet {

    /// - Complexity: O(*n*)
    @inlinable
    public func filter(
      _ isIncluded: (Element) throws -> Bool
    ) rethrows -> Self {
      .init(__tree_: try __tree_.___filter(_start, _end, isIncluded))
    }
  }
#endif

// MARK: - Collection Conformance

// MARK: - Sequence
// MARK: - Collection
// MARK: - BidirectionalCollection

extension RedBlackTreeMultiSet: Sequence {}

extension RedBlackTreeMultiSet {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public func makeIterator() -> Tree._PayloadValues {
    .init(start: _sealed_start, end: _sealed_end, tie: __tree_.tied)
  }
}

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiSet {

    /// - Complexity: O(*n*)
    @inlinable
    @inline(__always)
    public func sorted() -> [Element] {
      __tree_.___copy_all_to_array()
    }

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public func reversed() -> [Element] {
      __tree_.___rev_copy_all_to_array()
    }
  }
#endif

// MARK: -

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiSet {

    /// - Important:
    ///  要素及びノードが削除された場合、インデックスは無効になります。
    /// 無効なインデックスを使用するとランタイムエラーや不正な参照が発生する可能性があるため注意してください。
    public typealias Index = UnsafeIndexV3
    public typealias SubSequence = RedBlackTreeKeyOnlyRangeView<Base>
  }

  extension RedBlackTreeMultiSet {

    @inlinable
    func ___index(_ p: _SealedPtr) -> UnsafeIndexV3 {
      p.band(__tree_.tied)
    }

    @inlinable
    func ___index_or_nil(_ p: _SealedPtr) -> UnsafeIndexV3? {
      p.exists ? p.band(__tree_.tied) : nil
    }
  }

  extension RedBlackTreeMultiSet {
    // TODO: 標準踏襲でOptionalとしてるが、やや疑問。再検討すること
    /// - Complexity: O( log `count` )
    @inlinable
    public func firstIndex(of member: Element)
      -> Index?
    {
      ___index_or_nil(__tree_.find(member).sealed)
    }
  }

  extension RedBlackTreeMultiSet {

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public var startIndex: Index { ___index(_sealed_start) }

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public var endIndex: Index { ___index(_sealed_end) }
  }

  extension RedBlackTreeMultiSet {

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

  extension RedBlackTreeMultiSet {

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
    public func lowerBound(_ member: Element) -> Index {
      ___index(__tree_.lower_bound(member).sealed)
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
    public func upperBound(_ member: Element) -> Index {
      ___index(__tree_.upper_bound(member).sealed)
    }
  }

  extension RedBlackTreeMultiSet {

    /// - Complexity: O(log *n*), where *n* is the number of elements.
    @inlinable
    public func equalRange(_ element: Element) -> (
      lower: Index, upper: Index
    ) {
      let (lower, upper) = __tree_.__equal_range_multi(element)
      return (___index(lower.sealed), ___index(upper.sealed))
    }
  }

  extension RedBlackTreeMultiSet {

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

  extension RedBlackTreeMultiSet {

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

  extension RedBlackTreeMultiSet {

    /// - Complexity: O(1)
    @inlinable
    public subscript(position: Index) -> Element {
      @inline(__always) get {
        __tree_[_unsafe: __tree_.__purified_(position)]
      }
    }
  }

  extension RedBlackTreeMultiSet {

    /// - Complexity: O(1)
    @inlinable
    public subscript(_result position: Index) -> Result<Element, SealError> {
      __tree_.__purified_(position)
        .map { $0.pointer.__value_().pointee }
    }
  }

  extension RedBlackTreeMultiSet {

    /// Indexがsubscriptやremoveで利用可能か判別します
    ///
    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public func isValid(index: Index) -> Bool {
      __tree_.__purified_(index).exists
    }
  }
#endif

// MARK: -

#if !COMPATIBLE_ATCODER_2025
extension RedBlackTreeMultiSet {

  // TODO: イテレータ利用の注意をドキュメントすること
  /// - Important: 削除したメンバーを指すインデックスが無効になります。
  /// - Complexity: O(log *n* : *k*)
  @inlinable
  @discardableResult
  public mutating func eraseMulti(_ member: Element) -> Element? {
    __tree_._strongEnsureUnique()
    return __tree_.___erase_multi(member) != 0 ? member : nil
  }
}
#endif

#if !COMPATIBLE_ATCODER_2025

  extension RedBlackTreeMultiSet {

    @discardableResult
    @inlinable @inline(__always)
    public mutating func erase(_ ptr: Index) -> Index {
      ___index(__tree_.erase(__tree_.__purified_(ptr).pointer!).sealed)
    }
  }

  extension RedBlackTreeMultiSet {

    @inlinable
    public mutating func erase(where shouldBeRemoved: (Element) throws -> Bool) rethrows {
      __tree_.ensureUnique()
      let result = try __tree_.___erase_if(
        __tree_.__begin_node_.sealed,
        __tree_.__end_node.sealed,
        shouldBeRemoved: shouldBeRemoved)
      if case .failure(let e) = result {
        fatalError(e.localizedDescription)
      }
    }
  }
#endif

// MARK: - Protocol Conformance

// MARK: - ExpressibleByArrayLiteral

extension RedBlackTreeMultiSet: ExpressibleByArrayLiteral {

  /// - Complexity: O(*n* log *n*)
  @inlinable
  @inline(__always)
  public init(arrayLiteral elements: Element...) {
    self.init(elements)
  }
}

// MARK: - CustomStringConvertible

extension RedBlackTreeMultiSet: CustomStringConvertible {

  @inlinable
  public var description: String {
    _arrayDescription(for: self)
  }
}

// MARK: - CustomDebugStringConvertible

extension RedBlackTreeMultiSet: CustomDebugStringConvertible {

  public var debugDescription: String {
    description
  }
}

// MARK: - CustomReflectable

extension RedBlackTreeMultiSet: CustomReflectable {
  /// The custom mirror for this instance.
  public var customMirror: Mirror {
    Mirror(self, unlabeledChildren: self + [], displayStyle: .set)
  }
}

// MARK: - Is Identical To

extension RedBlackTreeMultiSet {

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

extension RedBlackTreeMultiSet: Equatable {

  /// - Complexity: O(*m*), where *m* is the lesser of the length of `lhs` and `rhs`.
  @inlinable
  @inline(__always)
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.__tree_ == rhs.__tree_
  }
}

// MARK: - Comparable

extension RedBlackTreeMultiSet: Comparable {

  /// - Complexity: O(*m*), where *m* is the lesser of the length of `lhs` and `rhs`.
  @inlinable
  @inline(__always)
  public static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.__tree_ < rhs.__tree_
  }
}

// MARK: - Hashable

extension RedBlackTreeMultiSet: Hashable where Element: Hashable {

  @inlinable
  @inline(__always)
  public func hash(into hasher: inout Hasher) {
    hasher.combine(__tree_)
  }
}

// MARK: - Sendable

#if swift(>=5.5)
  extension RedBlackTreeMultiSet: @unchecked Sendable
  where Element: Sendable {}
#endif

// MARK: - Codable

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiSet: Encodable where Element: Encodable {

    @inlinable
    public func encode(to encoder: Encoder) throws {
      var container = encoder.unkeyedContainer()
      for element in self {
        try container.encode(element)
      }
    }
  }

  extension RedBlackTreeMultiSet: Decodable where Element: Decodable {

    @inlinable
    public init(from decoder: Decoder) throws {
      self.init(__tree_: try .create(from: decoder))
    }
  }
#endif

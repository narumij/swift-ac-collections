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

  public
    typealias Element = Element

  /// - Important:
  ///  要素及びノードが削除された場合、インデックスは無効になります。
  /// 無効なインデックスを使用するとランタイムエラーや不正な参照が発生する可能性があるため注意してください。
  public
    typealias Index = Tree.Index

  public
    typealias _Key = Element

  public
    typealias _PayloadValue = Element

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

extension RedBlackTreeMultiSet: _RedBlackTreeKeyOnlyBase {}
extension RedBlackTreeMultiSet: CompareMultiTrait {}
extension RedBlackTreeMultiSet: ScalarValueComparer {
  public static func __value_(_ p: UnsafeMutablePointer<UnsafeNode>) -> Element {
    p.__value_().pointee
  }
}

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

extension RedBlackTreeMultiSet {

  /// - Complexity: O(*n* log *n* + *n*)
  @inlinable
  public init<Source>(_ sequence: __owned Source)
  where Element == Source.Element, Source: Sequence {
    self.init(__tree_: .create_multi(sorted: sequence.sorted()))
  }
}

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

// MARK: - Inspecting a MultiSet

extension RedBlackTreeMultiSet {

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
    ___contains(member)
  }
}

// MARK: - Accessing Elements

extension RedBlackTreeMultiSet {

  /// - Complexity: O(1)。
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

// MARK: - Range Accessing Elements

extension RedBlackTreeMultiSet {

  #if COMPATIBLE_ATCODER_2025
    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public subscript(bounds: Range<Index>) -> SubSequence {
      return .init(
        tree: __tree_,
        start: try! __tree_._remap_to_safe_(bounds.lowerBound).get(),
        end: try! __tree_._remap_to_safe_(bounds.upperBound).get())
    }
  #endif
}

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

extension RedBlackTreeMultiSet {

  @inlinable
  public mutating func reserveCapacity(_ minimumCapacity: Int) {
    __tree_.ensureUniqueAndCapacity(to: minimumCapacity)
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
    guard !isEmpty else { return nil }
    return remove(at: startIndex)
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

  /// - Important: 削除後は、インデックスが無効になります。
  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  @discardableResult
  public mutating func remove(at index: Index) -> Element {
    __tree_.ensureUnique()
    guard case .success(let __p) = __tree_._remap_to_safe_(index) else {
      fatalError(.invalidIndex)
    }
    return _unchecked_remove(at: __p).payload
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

  #if COMPATIBLE_ATCODER_2025
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
      __tree_.ensureUnique()
      ___remove(
        from: try! __tree_._remap_to_safe_(bounds.lowerBound).get(),
        to: try! __tree_._remap_to_safe_(bounds.upperBound).get())
    }
  #endif

  // TODO: イテレータ利用の注意をドキュメントすること
  /// - Important: 削除したメンバーを指すインデックスが無効になります。
  /// - Complexity: O(log *n* : *k*)
  @inlinable
  @discardableResult
  public mutating func removeAll(_ member: Element) -> Element? {
    __tree_._strongEnsureUnique()
    return __tree_.___erase_multi(member) != 0 ? member : nil
  }
}

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

  /// - Complexity: O(log *n*)
  @inlinable
  public func lowerBound(_ member: Element) -> Index {
    ___index_lower_bound(member)
  }

  /// - Complexity: O(log *n*)
  @inlinable
  public func upperBound(_ member: Element) -> Index {
    ___index_upper_bound(member)
  }
}

extension RedBlackTreeMultiSet {

  /// - Complexity: O(log *n*)
  @inlinable
  public func equalRange(_ element: Element) -> (lower: Index, upper: Index) {
    ___index_equal_range(element)
  }
}

extension RedBlackTreeMultiSet {

  /// - Complexity: O(*n*)
  ///
  /// O(1)が欲しい場合、firstが等価でO(1)
  @inlinable
  public func min() -> Element? {
    ___min()
  }

  /// - Complexity: O(*n*)
  @inlinable
  public func max() -> Element? {
    ___max()
  }
}

extension RedBlackTreeMultiSet {

  /// - Complexity: O(*n*)
  @inlinable
  public func first(where predicate: (Element) throws -> Bool) rethrows -> Element? {
    try ___first(where: predicate)
  }
}

extension RedBlackTreeMultiSet {

  /// - Complexity: O(log *n*)
  @inlinable
  public func firstIndex(of member: Element) -> Index? {
    ___first_index(of: member)
  }

  /// - Complexity: O(*n*)
  @inlinable
  public func firstIndex(where predicate: (Element) throws -> Bool) rethrows -> Index? {
    try ___first_index(where: predicate)
  }
}

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiSet {
    /// 値レンジ `[start, end)` に含まれる要素のスライス
    /// - Complexity: O(log *n*)
    @inlinable
    public func sequence(from start: Element, to end: Element) -> SubSequence {
      .init(
        tree: __tree_,
        start: __tree_.lower_bound(start),
        end: __tree_.lower_bound(end))
    }

    /// 値レンジ `[start, end]` に含まれる要素のスライス
    /// - Complexity: O(log *n*)
    @inlinable
    public func sequence(from start: Element, through end: Element) -> SubSequence {
      .init(
        tree: __tree_,
        start: __tree_.lower_bound(start),
        end: __tree_.upper_bound(end))
    }
  }
#endif

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

#if COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiSet: Sequence, Collection, BidirectionalCollection {}
#else
  extension RedBlackTreeMultiSet: Sequence {}
#endif

extension RedBlackTreeMultiSet {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public func makeIterator() -> Tree._PayloadValues {
    _makeIterator()
  }

  @inlinable
  @inline(__always)
  public func forEach(_ body: (_PayloadValue) throws -> Void) rethrows {
    try _forEach(body)
  }

  #if COMPATIBLE_ATCODER_2025
    /// 特殊なforEach
    @inlinable
    @inline(__always)
    public func forEach(_ body: (Index, _PayloadValue) throws -> Void) rethrows {
      try _forEach(body)
    }
  #endif

  #if !COMPATIBLE_ATCODER_2025
    /// - Complexity: O(*n*)
    @inlinable
    @inline(__always)
    public func sorted() -> [Element] {
      _sorted()
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

  /// - Complexity: O(*d* + log *n*)
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

  #if COMPATIBLE_ATCODER_2025 || true
    /// - Complexity: O(1)
    @inlinable
    public subscript(position: Index) -> _PayloadValue {
      @inline(__always) _read { yield self[_checked: position] }
    }
  #endif

  /// Indexがsubscriptやremoveで利用可能か判別します
  ///
  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public func isValid(index: Index) -> Bool {
    _isValid(index: index)
  }

  #if COMPATIBLE_ATCODER_2025
    /// RangeExpressionがsubscriptやremoveで利用可能か判別します
    ///
    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public func isValid<R: RangeExpression>(_ bounds: R) -> Bool
    where R.Bound == Index {
      _isValid(bounds)
    }
  #endif

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public func reversed() -> Tree._PayloadValues.Reversed {
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
    _ other: OtherSequence, by areEquivalent: (_PayloadValue, OtherSequence.Element) throws -> Bool
  ) rethrows -> Bool where OtherSequence: Sequence {
    try _elementsEqual(other, by: areEquivalent)
  }

  /// - Complexity: O(*m*), where *m* is the lesser of the length of the
  ///   sequence and the length of `other`.
  @inlinable
  @inline(__always)
  public func lexicographicallyPrecedes<OtherSequence>(
    _ other: OtherSequence, by areInIncreasingOrder: (_PayloadValue, _PayloadValue) throws -> Bool
  ) rethrows -> Bool where OtherSequence: Sequence, _PayloadValue == OtherSequence.Element {
    try _lexicographicallyPrecedes(other, by: areInIncreasingOrder)
  }
}

extension RedBlackTreeMultiSet {

  /// - Complexity: O(*m*), where *m* is the lesser of the length of the
  ///   sequence and the length of `other`.
  @inlinable
  @inline(__always)
  public func elementsEqual<OtherSequence>(_ other: OtherSequence) -> Bool
  where OtherSequence: Sequence, Element == OtherSequence.Element {
    _elementsEqual(other, by: ==)
  }

  /// - Complexity: O(*m*), where *m* is the lesser of the length of the
  ///   sequence and the length of `other`.
  @inlinable
  @inline(__always)
  public func lexicographicallyPrecedes<OtherSequence>(_ other: OtherSequence) -> Bool
  where OtherSequence: Sequence, Element == OtherSequence.Element {
    _lexicographicallyPrecedes(other, by: <)
  }
}

// MARK: - SubSequence: Sequence

extension RedBlackTreeMultiSet {

  public typealias SubSequence = RedBlackTreeSliceV2<Self>.KeyOnly
}

// MARK: - Index Range

extension RedBlackTreeMultiSet {

  public typealias Indices = Tree.Indices
}

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
    _isTriviallyIdentical(to: other)
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

// MARK: - Init naive

extension RedBlackTreeMultiSet {

  /// - Complexity: O(*n* log *n*)
  ///
  /// 省メモリでの初期化
  @inlinable
  public init<Source>(naive sequence: __owned Source)
  where Element == Source.Element, Source: Sequence {
    self.init(__tree_: .create_multi(naive: sequence))
  }
}

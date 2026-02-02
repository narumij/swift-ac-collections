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

/// # RedBlackTreeSet
///
/// `RedBlackTreeSet` は、**赤黒木を用いて実装された、一意要素の順序付き集合**です。
///
/// 標準の `Set` と同様に、各要素は **高々一度だけ** 登場し、
/// **効率的な所属判定（membership test）** を提供します。
/// 一方で `Set` と異なり、`RedBlackTreeSet` は **要素をソート順（比較順）に保持** し、
/// **順序付き走査** や **範囲検索** を効率的にサポートします。
///
/// この型は、**順序付き集合**・**高速検索**・
/// **安定した計算量保証** を同時に満たしたい用途に適しています。
///
/// ```swift
/// let set: RedBlackTreeSet = [3, 1, 4, 1, 5]
/// // => [1, 3, 4, 5]
/// ```
///
/// ## 等価性（Equality）
///
/// 2つの `RedBlackTreeSet` は、**同じ要素を含む場合に等しい**とみなされます。
///
/// 要素は常にソート順に保持されるため、**挿入順は等価性に影響しません**。
/// これは標準 `Set` と同じ意味論です。
///
/// ```swift
/// let a: RedBlackTreeSet = [1, 2, 3]
/// let b: RedBlackTreeSet = [3, 2, 1]
/// a == b // true
/// ```
///
/// ## 順序と走査（Ordering & Traversal）
///
/// `RedBlackTreeSet` は **要素を比較順に保持** します。
///
/// - `min` / `max`
/// - 昇順・降順イテレーション
/// - `lowerBound` / `upperBound`
/// - 範囲ベースの探索
///
/// といった操作を **O(log N)** で提供します。
///
/// ```swift
/// set.lowerBound(3)
/// set.upperBound(3)
///
/// for value in set {
///   print(value) // 昇順
/// }
/// ```
///
/// ## 挿入・削除（Insertion & Removal）
///
/// 赤黒木により、**挿入・削除・検索はすべて O(log N)** の計算量で保証されます。
///
/// ```swift
/// set.insert(10)
/// set.remove(3)
/// set.contains(5)
/// ```
///
/// 重複値は許可されず、挿入時に既存要素がある場合は
/// **無視または更新** されます。
///
/// ## 範囲操作（Range Operations）
///
/// `RedBlackTreeSet` は **範囲ベースの効率的な操作**をサポートします。
///
/// - 範囲削除
/// - 範囲イテレーション
/// - 区間検索（range queries）
///
/// ```swift
/// let subset = set.range(3..<10) // TODO: コード例を修正
/// ```
///
/// これらは、木構造を活かして **線形走査を避ける** 実装が可能です。
///
/// ## パフォーマンス特性（Performance Characteristics）
///
/// ### 要素検索（Lookup）
///
/// - **O(log N)** の最悪計算量保証
/// - ハッシュに依存しないため、**衝突劣化が発生しません**
///
/// ### 挿入・削除（Insertion & Removal）
///
/// - **O(log N)**
/// - 木の高さが平衡に保たれるため、**安定した性能**
///
/// ### 順序付き走査（Ordered Traversal）
///
/// - **O(N)** で昇順・降順走査
/// - 中間ノードからの継続走査も効率的
///
/// ### メモリ特性（Memory Characteristics）
///
/// - 各要素はノードとして個別に管理される
/// - `Array` や `HashTable` ベース構造より **ポインタオーバーヘッドがある**
/// - 代わりに、**範囲検索・順序操作・最悪計算量保証** を提供
///
/// ## ハッシュ不要の利点（No Hashing Required）
///
/// `RedBlackTreeSet` はハッシュに依存しないため、以下の利点があります。
///
/// - `Hashable` 不要（`Comparable` のみ）
/// - 悪意ある入力による **DoS 的ハッシュ衝突** を回避
/// - **性能の予測可能性が高い**
///
/// ## Set / OrderedSet との使い分け
///
/// | 型                 | 内部構造           | 検索       | 順序     | 範囲検索 | 最悪計算量保証 |
/// | ------------------ | ------------------ | ---------- | -------- | -------- | ---------------- |
/// | `Set`              | Hash Table         | O(1) avg   | ❌       | ❌       | ❌               |
/// | `OrderedSet`       | Array + Hash       | O(1) avg   | 挿入順   | ❌       | ❌               |
/// | `RedBlackTreeSet`  | Red-Black Tree     | O(log N)   | ソート順 | ✅       | ✅               |
///
/// ## 使いどころ（When to Use）
///
/// `RedBlackTreeSet` は次のようなケースに向いています。
///
/// - **順序付き集合** が必要
/// - **範囲検索 / lowerBound / upperBound** を多用
/// - **最悪計算量の保証** が重要
/// - **ハッシュ品質に依存したくない**
/// - **アルゴリズム競技 / DB / インデックス / ルーティング構造**
///
@frozen
public struct RedBlackTreeSet<Element: Comparable> {

  public
    typealias Element = Element

  public
    typealias _Key = Element

  public
    typealias _PayloadValue = Element

  public
    typealias Base = Self

  @usableFromInline
  var __tree_: Tree

  @inlinable @inline(__always)
  internal init(__tree_: Tree) {
    self.__tree_ = __tree_
  }
}

#if COMPATIBLE_ATCODER_2025
  extension RedBlackTreeSet: _RedBlackTreeKeyOnlyBase {}
#else
  extension RedBlackTreeSet: _RedBlackTreeKeyOnlyBase2 {}
#endif

extension RedBlackTreeSet: CompareUniqueTrait {}
extension RedBlackTreeSet: ScalarValueComparer {
  public static func __value_(_ p: UnsafeMutablePointer<UnsafeNode>) -> Element {
    p.__value_().pointee
  }
}

// MARK: - Creating a Set

extension RedBlackTreeSet {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public init() {
    self.init(__tree_: .create())
  }

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public init(minimumCapacity: Int) {
    self.init(__tree_: .create(minimumCapacity: minimumCapacity))
  }
}

extension RedBlackTreeSet {

  /// - Complexity: O(*n* log *n* + *n*)
  @inlinable
  public init<Source>(_ sequence: __owned Source)
  where Element == Source.Element, Source: Sequence {
    self.init(__tree_: .create_unique(sorted: sequence.sorted()))
  }
}

extension RedBlackTreeSet {

  /// - Important: 昇順を想定して処理を省いている。降順に用いた場合未定義
  /// - Complexity: O(*n*)
  @inlinable
  public init<R>(_ range: __owned R)
  where R: RangeExpression, R: Collection, R.Element == Element {
    precondition(range is Range<Element> || range is ClosedRange<Element>)
    self.init(__tree_: .create(range: range))
  }
}

// MARK: - Inspecting a Set

extension RedBlackTreeSet {

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

extension RedBlackTreeSet {

  /// - Complexity: O(log *n* + *k*)
  @inlinable
  public func count(of element: Element) -> Int {
    __tree_.__count_unique(element)
  }
}

// MARK: - Testing for Membership

extension RedBlackTreeSet {

  /// - Complexity: O(log *n*), where *n* is the number of elements.
  @inlinable
  @inline(never)
  public func contains(_ member: Element) -> Bool {
    __tree_.read { $0.__count_unique(member) != 0 }
  }
}

// MARK: - Accessing Elements

extension RedBlackTreeSet {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public var first: Element? {
    ___first
  }

  /// - Complexity: O(log `count`)
  @inlinable
  public var last: Element? {
    ___last
  }
}

// MARK: - Range Accessing Elements

// MARK: - Insertion

extension RedBlackTreeSet {

  /// - Complexity: O(log *n*), where *n* is the number of elements.
  @inlinable
  @discardableResult
  public mutating func insert(_ newMember: Element) -> (
    inserted: Bool, memberAfterInsert: Element
  ) {
    __tree_.ensureUniqueAndCapacity()
    let (__r, __inserted) = __tree_.update { $0.__insert_unique(newMember) }
    return (__inserted, __inserted ? newMember : __tree_[__r])
  }

  /// - Complexity: O(log *n*), where *n* is the number of elements.
  @inlinable
  @inline(__always)
  @discardableResult
  public mutating func update(with newMember: Element) -> Element? {
    __tree_.ensureUniqueAndCapacity()
    let (__r, __inserted) = __tree_.update { $0.__insert_unique(newMember) }
    guard !__inserted else { return nil }
    let oldMember = __tree_[__r]
    __tree_[__r] = newMember
    return oldMember
  }
}

extension RedBlackTreeSet {

  @inlinable
  public mutating func reserveCapacity(_ minimumCapacity: Int) {
    __tree_.ensureUniqueAndCapacity(to: minimumCapacity)
  }
}

// MARK: - Combining Set

extension RedBlackTreeSet {

  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  ///
  /// - Important: 空間計算量に余裕がある場合、formUnionの使用を推奨します
  @inlinable
  public mutating func merge(_ other: RedBlackTreeSet<Element>) {
    __tree_.ensureUnique { __tree_ in
      .___insert_range_unique(
        tree: __tree_,
        other: other.__tree_,
        other.__tree_.__begin_node_,
        other.__tree_.__end_node)
    }
  }

  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  @inlinable
  public mutating func merge(_ other: RedBlackTreeMultiSet<Element>) {
    __tree_.ensureUnique { __tree_ in
      .___insert_range_unique(
        tree: __tree_,
        other: other.__tree_,
        other.__tree_.__begin_node_,
        other.__tree_.__end_node)
    }
  }

  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  @inlinable
  public mutating func merge<S>(_ other: S) where S: Sequence, S.Element == Element {
    __tree_.ensureUnique { __tree_ in
      .___insert_range_unique(tree: __tree_, other)
    }
  }

  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  ///
  /// - Important: 空間計算量に余裕がある場合、unionの使用を推奨します
  @inlinable
  public func merging(_ other: RedBlackTreeSet<Element>) -> Self {
    var result: Self = self
    result.merge(other)
    return result
  }

  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  @inlinable
  public func merging(_ other: RedBlackTreeMultiSet<Element>) -> Self {
    var result = self
    result.merge(other)
    return result
  }

  /// - Complexity: O(*n* log(*m + n*)), where *n* is the length of `other`
  ///   and *m* is the size of the current tree.
  @inlinable
  public func merging<S>(_ other: __owned S) -> Self where S: Sequence, S.Element == Element {
    var result = self
    result.merge(other)
    return result
  }
}

// MARK: - Removal

extension RedBlackTreeSet {

  /// - Complexity: O(1)
  @inlinable
  //  @inline(__always)
  public mutating func popMin() -> Element? {
    __tree_.ensureUnique()
    return ___remove_first()?.payload
  }

  /// - Complexity: O(log `count`)
  @inlinable
  //  @inline(__always)
  public mutating func popMax() -> Element? {
    __tree_.ensureUnique()
    return ___remove_last()?.payload
  }
}

extension RedBlackTreeSet {

  /// - Important: 削除したメンバーを指すインデックスが無効になります。
  /// - Complexity: O(log *n*), where *n* is the number of elements.
  @inlinable
  @discardableResult
  public mutating func remove(_ member: Element) -> Element? {
    __tree_.ensureUnique()
    return __tree_.update { $0.___erase_unique(member) } ? member : nil
  }

  /// - Important: 削除したメンバーを指すインデックスが無効になります。
  /// - Complexity: O(1)
  @inlinable
  @discardableResult
  public mutating func removeFirst() -> Element {
    __tree_.ensureUnique()
    guard let element = ___remove_first() else {
      preconditionFailure(.emptyFirst)
    }
    return element.payload
  }
}

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeSet {

    @inlinable
    public mutating func removeAll(where shouldBeRemoved: (Element) throws -> Bool) rethrows {
      __tree_.ensureUnique()
      try __tree_.___checking_erase_if(
        __tree_.__begin_node_,
        __tree_.__end_node,
        shouldBeRemoved: shouldBeRemoved)
    }
  }
#endif

extension RedBlackTreeSet {

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

// MARK: -

extension RedBlackTreeSet {

  /// - Complexity: O(log *n*), where *n* is the number of elements.
  ///
  /// O(1)が欲しい場合、firstが等価でO(1)
  @inlinable
  public func min() -> Element? {
    ___min()
  }

  /// - Complexity: O(log *n*), where *n* is the number of elements.
  @inlinable
  public func max() -> Element? {
    ___max()
  }
}

extension RedBlackTreeSet {

  /// - Complexity: O(*n*), where *n* is the number of elements.
  @inlinable
  public func first(where predicate: (Element) throws -> Bool) rethrows -> Element? {
    try ___first(where: predicate)
  }
}

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeSet {

    /// - Complexity: O(*n*)
    @inlinable
    public func filter(
      _ isIncluded: (Element) throws -> Bool
    ) rethrows -> Self {
      .init(__tree_: try __tree_.___filter(_start, _end, isIncluded))
    }
  }
#endif

// MARK: - Sequence
// MARK: - Collection
// MARK: - BidirectionalCollection

extension RedBlackTreeSet: Sequence {}

extension RedBlackTreeSet {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public func makeIterator() -> Tree._PayloadValues {
    _makeIterator()
  }

  #if false
    @inlinable
    @inline(__always)
    public func forEach(_ body: (Element) throws -> Void) rethrows {
      try _forEach(body)
    }
  #endif

  #if !COMPATIBLE_ATCODER_2025
    /// - Complexity: O(*n*)
    @inlinable
    @inline(__always)
    public func sorted() -> [Element] {
      __tree_.___copy_all_to_array()
    }
  #endif
}

// MARK: -

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeSet {

    /// - Important:
    ///  要素及びノードが削除された場合、インデックスは無効になります。
    /// 無効なインデックスを使用するとランタイムエラーや不正な参照が発生する可能性があるため注意してください。
    public typealias Index = RedBlackTreeTrackingTag
    public typealias SubSequence = RedBlackTreeKeyOnlyRangeView<Base>
  }

  extension RedBlackTreeSet {

    /// - Complexity: O( log `count` )
    @inlinable
    public func firstIndex(of member: Element)
      -> RedBlackTreeTrackingTag
    {
      .create(__tree_.find(member)).flatMap { $0 == .end ? nil : $0 }
    }

    /// - Complexity: O( `count` )
    @inlinable
    public func firstIndex(where predicate: (Element) throws -> Bool) rethrows
      -> RedBlackTreeTrackingTag
    {
      try ___first_tracking_tag(where: predicate)
    }
  }

  extension RedBlackTreeSet {

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public var startIndex: RedBlackTreeTrackingTag { .create(_start) }

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public var endIndex: RedBlackTreeTrackingTag { .create(_end) }
  }

  extension RedBlackTreeSet {

    /// - Complexity: O(log *n* + *k*)
    @inlinable
    @inline(__always)
    public func distance(from start: RedBlackTreeTrackingTag, to end: RedBlackTreeTrackingTag)
      -> Int
    {
      __tree_.___distance(
        from: try! start.relative(to: __tree_).get().pointer,
        to: try! end.relative(to: __tree_).get().pointer)
    }
  }

  extension RedBlackTreeSet {

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
      .create(__tree_.lower_bound(member))
    }

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
      .create(__tree_.upper_bound(member))
    }
  }

  extension RedBlackTreeSet {

    /// - Complexity: O(log *n*), where *n* is the number of elements.
    @inlinable
    public func equalRange(_ element: Element) -> (
      lower: RedBlackTreeTrackingTag, upper: RedBlackTreeTrackingTag
    ) {
      let (lower, upper) = __tree_.__equal_range_unique(element)
      return (.create(lower), .create(upper))
    }
  }

  extension RedBlackTreeSet {

    /// - Complexity: O(1)
    @inlinable
    public func index(before i: RedBlackTreeTrackingTag) -> RedBlackTreeTrackingTag {
      try? i.relative(to: __tree_)
        .flatMap { ___tree_prev_iter($0.pointer) }
        .map { .create($0) }
        .get()
    }

    /// - Complexity: O(1)
    @inlinable
    public func index(after i: RedBlackTreeTrackingTag) -> RedBlackTreeTrackingTag {
      try? i.relative(to: __tree_)
        .flatMap { ___tree_next_iter($0.pointer) }
        .map { .create($0) }
        .get()
    }

    /// - Complexity: O(`distance`)
    @inlinable
    public func index(_ i: RedBlackTreeTrackingTag, offsetBy distance: Int)
      -> RedBlackTreeTrackingTag
    {
      try? i.relative(to: __tree_)
        .flatMap { ___tree_adv_iter($0.pointer, distance) }
        .map { .create($0) }
        .get()
    }

    /// - Complexity: O(`distance`)
    @inlinable
    public func index(
      _ i: RedBlackTreeTrackingTag, offsetBy distance: Int, limitedBy limit: RedBlackTreeTrackingTag
    )
      -> RedBlackTreeTrackingTag
    {
      let __l = limit.relative(to: __tree_)
      return try? i.relative(to: __tree_)
        .flatMap { ___tree_adv_iter($0.pointer, distance, __l.pointer) }
        .map { .create($0) }
        .get()
    }
  }

  extension RedBlackTreeSet {

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public func formIndex(before i: inout RedBlackTreeTrackingTag) {
      i = index(before: i)
    }

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public func formIndex(after i: inout RedBlackTreeTrackingTag) {
      i = index(after: i)
    }

    /// - Complexity: O(*d*)
    @inlinable
    //  @inline(__always)
    public func formIndex(_ i: inout RedBlackTreeTrackingTag, offsetBy distance: Int) {
      i = index(i, offsetBy: distance)
    }

    /// - Complexity: O(*d*)
    @inlinable
    @inline(__always)
    public func formIndex(
      _ i: inout RedBlackTreeTrackingTag,
      offsetBy distance: Int,
      limitedBy limit: RedBlackTreeTrackingTag
    )
      -> Bool
    {
      if let result = index(i, offsetBy: distance, limitedBy: limit) {
        i = result
        return true
      }
      return false
    }
  }

  extension RedBlackTreeSet {

    @inlinable
    @discardableResult
    public mutating func remove(at index: RedBlackTreeTrackingTag) -> Element {
      __tree_.ensureUnique()
      guard case .success(let __p) = index.relative(to: __tree_) else {
        fatalError(.invalidIndex)
      }
      return _unchecked_remove(at: __p.pointer).payload
    }
  }

  extension RedBlackTreeSet {

    /// - Complexity: O(1)
    @inlinable
    public subscript(position: RedBlackTreeTrackingTag) -> Element {
      @inline(__always) get {
        guard
          let p: _NodePtr = try? __tree_[position].get().pointer,
          !p.___is_end
        else {
          fatalError(.invalidIndex)
        }
        return p.__value_().pointee
      }
    }

    /// Indexがsubscriptやremoveで利用可能か判別します
    ///
    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public func isValid(index: RedBlackTreeTrackingTag) -> Bool {
      guard
        let p: _NodePtr = try? __tree_[index].get().pointer,
        !p.___is_end
      else {
        return false
      }
      return true
    }
  }

  extension RedBlackTreeSet {

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    package var __indices: [RedBlackTreeTrackingTag] {
      // TODO: 基本的に廃止
      _indices.map(\.trackingTag)
    }
  }

  extension RedBlackTreeSet {

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public func reversed() -> Tree._PayloadValues.ReversedIterator {
      _reversed()
    }
  }
#endif

extension RedBlackTreeSet {

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

extension RedBlackTreeSet {

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

// MARK: - Protocol Adaption

// MARK: - ExpressibleByArrayLiteral

extension RedBlackTreeSet: ExpressibleByArrayLiteral {

  /// - Complexity: O(*n* log *n* + *n*)
  @inlinable
  @inline(__always)
  public init(arrayLiteral elements: Element...) {
    self.init(elements)
  }
}

// MARK: - CustomStringConvertible

extension RedBlackTreeSet: CustomStringConvertible {

  @inlinable
  public var description: String {
    _arrayDescription(for: self + [])
  }
}

// MARK: - CustomDebugStringConvertible

extension RedBlackTreeSet: CustomDebugStringConvertible {

  public var debugDescription: String {
    description
  }
}

// MARK: - CustomReflectable

extension RedBlackTreeSet: CustomReflectable {
  /// The custom mirror for this instance.
  public var customMirror: Mirror {
    Mirror(self, unlabeledChildren: self + [], displayStyle: .set)
  }
}

// MARK: - Is Identical To

extension RedBlackTreeSet {

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

extension RedBlackTreeSet: Equatable {

  /// - Complexity: O(*m*), where *m* is the lesser of the length of `lhs` and `rhs`.
  @inlinable
  @inline(__always)
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.__tree_ == rhs.__tree_
  }
}

// MARK: - Comparable

extension RedBlackTreeSet: Comparable {

  /// - Complexity: O(*m*), where *m* is the lesser of the length of `lhs` and `rhs`.
  @inlinable
  @inline(__always)
  public static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.__tree_ < rhs.__tree_
  }
}

// MARK: - Hashable

extension RedBlackTreeSet: Hashable where Element: Hashable {

  @inlinable
  @inline(__always)
  public func hash(into hasher: inout Hasher) {
    hasher.combine(__tree_)
  }
}

// MARK: - Sendable

#if swift(>=5.5)
  extension RedBlackTreeSet: @unchecked Sendable
  where Element: Sendable {}
#endif

// MARK: - Codable

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeSet: Encodable where Element: Encodable {

    @inlinable
    public func encode(to encoder: Encoder) throws {
      var container = encoder.unkeyedContainer()
      for element in self {
        try container.encode(element)
      }
    }
  }

  extension RedBlackTreeSet: Decodable where Element: Decodable {

    @inlinable
    public init(from decoder: Decoder) throws {
      self.init(__tree_: try .create(from: decoder))
    }
  }
#endif

// MARK: - Init naive

extension RedBlackTreeSet {

  /// - Complexity: O(*n* log *n*)
  ///
  /// 省メモリでの初期化
  @inlinable
  public init<Source>(naive sequence: __owned Source)
  where Element == Source.Element, Source: Sequence {
    self.init(__tree_: .create_unique(naive: sequence))
  }
}

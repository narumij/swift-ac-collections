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

/// `RedBlackTreeSet` は、`Element` 型の要素を一意に格納するための
/// 赤黒木（Red-Black Tree）ベースの集合型です。
///
/// ### 使用例
/// ```swift
/// var set: RedBlackTreeSet = [3, 1, 4, 1, 5, 9]
/// print(set) // 出力例: [1, 3, 4, 5, 9]
///
/// set.insert(2)
/// print(set.contains(2)) // 出力例: true
///
/// // 要素の削除
/// set.remove(9)
/// print(set) // 出力例: [1, 2, 3, 4, 5]
///
/// // イテレーション
/// for element in set {
///     print(element)
/// }
/// ```
/// - Important: `RedBlackTreeSet` はスレッドセーフではありません。
@frozen
public struct RedBlackTreeSet<Element: Comparable> {

  public
    typealias Element = Element

  /// `Index`は赤黒木ノードへの標準インデックスです
  ///
  /// プロパティや探索系メソッドから取得できます。
  ///
  /// 要素取得、要素削除、範囲取得、範囲削除等、様々な操作に用いる事ができます。
  ///
  /// `Index`は`Collection`や`BidirectionalCollection`
  /// 準拠に用いられていて、様々な操作が可能です。
  ///
  /// - Important:
  ///  要素及びノードが削除された場合、インデックスは無効になります。
  /// 無効なインデックスを使用するとランタイムエラーや不正な参照が発生する可能性があるため注意してください。
  public
    typealias Index = Tree.Index

  public
    typealias _Key = Element

  @usableFromInline
  var _storage: Tree.Storage
}

extension RedBlackTreeSet: ___RedBlackTreeBase {}
extension RedBlackTreeSet: ___RedBlackTreeCopyOnWrite {}
extension RedBlackTreeSet: ___RedBlackTreeUnique {}
extension RedBlackTreeSet: ___RedBlackTreeSequence { }
extension RedBlackTreeSet: ___RedBlackTreeSubSequence { }
extension RedBlackTreeSet: ScalarValueComparer {}

// MARK: - Initialization

extension RedBlackTreeSet {

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

extension RedBlackTreeSet {

  /// - Complexity: O(*n* log *n*)
  @inlinable
  public init<Source>(_ sequence: __owned Source)
  where Element == Source.Element, Source: Sequence {
    let count = (sequence as? (any Collection))?.count
    var tree: Tree = .create(minimumCapacity: count ?? 0)
    // 初期化直後はO(1)
    var (__parent, __child) = tree.___max_ref()
    // ソートの計算量がO(*n* log *n*)
    for __k in sequence.sorted() {
      if count == nil {
        Tree.ensureCapacity(tree: &tree)
      }
      if __parent == .end || tree[__parent] != __k {
        // バランシングの計算量がO(log *n*)
        (__parent, __child) = tree.___emplace_hint_right(__parent, __child, __k)
        assert(tree.__tree_invariant(tree.__root()))
      }
    }
    self._storage = .init(__tree: tree)
  }
}

extension RedBlackTreeSet {

  /// - Complexity: O(*n* log *n*)
  @inlinable
  public init<R>(_ range: __owned R)
  where R: RangeExpression, R: Collection, R.Element == Element {
    precondition(range is Range<Element> || range is ClosedRange<Element>)
    let tree: Tree = .create(minimumCapacity: range.count)
    // 初期化直後はO(1)
    var (__parent, __child) = tree.___max_ref()
    for __k in range {
      // バランシングの計算量がO(log *n*)
      (__parent, __child) = tree.___emplace_hint_right(__parent, __child, __k)
    }
    assert(tree.__tree_invariant(tree.__root()))
    self._storage = .init(__tree: tree)
  }
}

extension RedBlackTreeSet {

  @inlinable
  public mutating func reserveCapacity(_ minimumCapacity: Int) {
    _ensureUniqueAndCapacity(to: minimumCapacity)
  }
}

// MARK: - Insertion

extension RedBlackTreeSet {

  /// - Complexity: O(log *n*)
  @discardableResult
  @inlinable
  public mutating func insert(_ newMember: Element) -> (
    inserted: Bool, memberAfterInsert: Element
  ) {
    _ensureUniqueAndCapacity()
    let (__r, __inserted) = _tree.__insert_unique(newMember)
    return (__inserted, __inserted ? newMember : _tree[__r])
  }

  /// - Complexity: O(log *n*)
  @discardableResult
  @inlinable
  public mutating func update(with newMember: Element) -> Element? {
    _ensureUniqueAndCapacity()
    let (__r, __inserted) = _tree.__insert_unique(newMember)
    guard !__inserted else { return nil }
    let oldMember = _tree[__r]
    _tree[__r] = newMember
    return oldMember
  }
}

extension RedBlackTreeSet {

  /// - Complexity: O(*k* log *k*)
  @inlinable
  @inline(__always)
  public mutating func insert(contentsOf other: RedBlackTreeSet<Element>) {
    _ensureUniqueAndCapacity(to: count + other.count)
    _tree.__node_handle_merge_unique(other._tree)
  }

  /// - Complexity: O(*k* log *k*)
  @inlinable
  @inline(__always)
  public mutating func insert(contentsOf other: RedBlackTreeMultiSet<Element>) {
    _ensureUniqueAndCapacity(to: count + other.count)
    _tree.__node_handle_merge_unique(other._tree)
  }

  /// - Complexity: O(*k* log *k*)
  @inlinable
  @inline(__always)
  public mutating func insert<S>(contentsOf other: S) where S: Sequence, S.Element == Element {
    other.forEach { insert($0) }
  }
}

// MARK: - Removal

extension RedBlackTreeSet {

  /// - Complexity: O(1)
  @inlinable
  public mutating func popFirst() -> Element? {
    guard !isEmpty else { return nil }
    return remove(at: startIndex)
  }
}

extension RedBlackTreeSet {

  /// - Complexity: O(log *n*)
  @discardableResult
  @inlinable
  public mutating func remove(_ member: Element) -> Element? {
    _ensureUnique()
    return _tree.___erase_unique(member) ? member : nil
  }

  /// - Important: 削除後は、これまで使用していたインデックスが無効になります。
  ///
  /// - Complexity: O(log *n*)
  @inlinable
  @discardableResult
  public mutating func remove(at index: Index) -> Element {
    _ensureUnique()
    guard let element = ___remove(at: index.rawValue) else {
      fatalError(.invalidIndex)
    }
    return element
  }

  /// - Important: 削除後は、これまで使用していたインデックスが無効になります。
  ///
  /// - Complexity: O(log *n*)
  @inlinable
  @discardableResult
  public mutating func remove(at index: RawIndex) -> Element {
    _ensureUnique()
    guard let element = ___remove(at: index.rawValue) else {
      fatalError(.invalidIndex)
    }
    return element
  }

  /// - Complexity: O(log *n*)
  @inlinable
  @discardableResult
  public mutating func removeFirst() -> Element {
    guard !isEmpty else {
      preconditionFailure(.emptyFirst)
    }
    return remove(at: startIndex)
  }

  /// - Complexity: O(log *n*)
  @inlinable
  @discardableResult
  public mutating func removeLast() -> Element {
    guard !isEmpty else {
      preconditionFailure(.emptyLast)
    }
    return remove(at: index(before: endIndex))
  }

  /// 指定した半開区間（`lhs ..< rhs`）に含まれる要素をすべて削除します。
  ///
  /// - Parameter range: `lhs`（含む）から `rhs`（含まない）までを表す `Range`
  ///   で、削除対象の要素範囲を示します。
  ///   範囲が逆転している場合（`lhs >= rhs`）や、木の要素範囲外を指している場合などの
  ///   “無効な” 状態では動作が未定義となります。
  ///
  /// - Complexity: O(log *n* + *k*)
  ///
  /// - Important: 削除後は、これまで使用していたインデックスが無効になります。
  ///
  /// ### 使用例
  /// ```swift
  /// var treeSet = RedBlackTreeSet([0,1,2,3,4,5,6])
  /// let startIdx = treeSet.lowerBound(2)
  /// let endIdx   = treeSet.lowerBound(5)
  /// // [2, 3, 4] の範囲を削除したい
  /// treeSet.removeSubrange(.init(lhs: startIdx, rhs: endIdx))
  /// // 結果: treeSet = [0,1,5,6]
  /// ```
  /// - Complexity: O(*k*)
  @inlinable
  public mutating func removeSubrange(_ range: Range<Index>) {
    _ensureUnique()
    ___remove(from: range.lowerBound.rawValue, to: range.upperBound.rawValue)
  }
}

extension RedBlackTreeSet {

  /// - Complexity: O(log *n* + *k*)
  @inlinable
  @inline(__always)
  public mutating func remove(contentsOf elementRange: Range<Element>) {
    _ensureUnique()
    let lower = lowerBound(elementRange.lowerBound).rawValue
    let upper = lowerBound(elementRange.upperBound).rawValue
    ___remove(from: lower, to: upper)
  }

  /// - Complexity: O(log *n* + *k*)
  @inlinable
  @inline(__always)
  public mutating func remove(contentsOf elementRange: ClosedRange<Element>) {
    _ensureUnique()
    let lower = lowerBound(elementRange.lowerBound).rawValue
    let upper = upperBound(elementRange.upperBound).rawValue
    ___remove(from: lower, to: upper)
  }
}

extension RedBlackTreeSet {

  /// - Complexity: O(1)
  @inlinable
  public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
    _ensureUnique()
    ___removeAll(keepingCapacity: keepCapacity)
  }
}

// MARK: - Search

extension RedBlackTreeSet {

  /// - Complexity: O(log *n*)
  @inlinable
  public func contains(_ member: Element) -> Bool {
    ___contains(member)
  }
}

extension RedBlackTreeSet {

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
  public func firstIndex(of member: Element) -> Index? {
    ___first_iter(of: member)
  }

  /// - Complexity: O(*n*)
  @inlinable
  public func firstIndex(where predicate: (Element) throws -> Bool) rethrows -> Index? {
    try ___first_iter(where: predicate)
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
  /// - Complexity: O(log *n*)
  @inlinable
  public func lowerBound(_ member: Element) -> Index {
    ___iter_lower_bound(member)
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
  /// - Complexity: O(log *n*)
  @inlinable
  public func upperBound(_ member: Element) -> Index {
    ___iter_upper_bound(member)
  }
}

extension RedBlackTreeSet {

  /// - Complexity: O(log *n*)
  @inlinable
  public func equalRange(_ element: Element) -> (lower: Tree.___Iterator, upper: Tree.___Iterator) {
    ___equal_range(element)
  }
}

extension RedBlackTreeSet {

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

// MARK: - Sequence
// MARK: - Collection
// MARK: - BidirectionalCollection

extension RedBlackTreeSet: Sequence, Collection, BidirectionalCollection { }

// MARK: - Range Access

extension RedBlackTreeSet {

  /// - Complexity: O(1)
  @inlinable
  public subscript(bounds: Range<Index>) -> SubSequence {
    .init(tree: _tree, start: bounds.lowerBound.rawValue, end: bounds.upperBound.rawValue)
  }
}

extension RedBlackTreeSet {
  // 割と注意喚起の為のdeprecatedなだけで、実際にいつ消すのかは不明です。
  // 分かってると便利なため、競技プログラミングにこのシンタックスシュガーは有用と考えているからです。

  /// 範囲 `[lower, upper)` に含まれる要素を返します。
  ///
  /// index範囲ではないことに留意
  /// **Deprecated – `elements(in:)` を使ってください。**
  @available(*, deprecated, renamed: "elements(in:)")
  @inlinable
  public subscript(bounds: Range<Element>) -> SubSequence {
    elements(in: bounds)
  }

  /// 範囲 `[lower, upper]` に含まれる要素を返します。
  ///
  /// index範囲ではないことに留意
  /// **Deprecated – `elements(in:)` を使ってください。**
  @available(*, deprecated, renamed: "elements(in:)")
  @inlinable
  public subscript(bounds: ClosedRange<Element>) -> SubSequence {
    elements(in: bounds)
  }
}

extension RedBlackTreeSet {
  /// 値レンジ `[lower, upper)` に含まれる要素のスライス
  ///
  /// - Complexity: O(1)
  @inlinable
  public func elements(in range: Range<Element>) -> SubSequence {
    .init(tree: _tree, start: ___ptr_lower_bound(range.lowerBound), end: ___ptr_lower_bound(range.upperBound))
  }

  /// 値レンジ `[lower, upper]` に含まれる要素のスライス
  ///
  /// - Complexity: O(1)
  @inlinable
  public func elements(in range: ClosedRange<Element>) -> SubSequence {
    .init(tree: _tree, start: ___ptr_lower_bound(range.lowerBound), end: ___ptr_upper_bound(range.upperBound))
  }
}

// MARK: - SubSequence

extension RedBlackTreeSet {

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

extension RedBlackTreeSet.SubSequence: ___SubSequenceBase {
  public typealias Base = RedBlackTreeSet
  public typealias Element = Tree.Element
  public typealias Indices = Tree.Indices
}

extension RedBlackTreeSet.SubSequence: Sequence, Collection, BidirectionalCollection {
  public typealias Index = RedBlackTreeSet.Index
  public typealias SubSequence = Self
}

// MARK: - Index Range

extension RedBlackTreeSet {
  public typealias Indices = Tree.Indices
}

// MARK: - Raw Index Sequence

// 独自の型だと学習コストが高くなるので、速度を少し犠牲にして読みやすそうな型に変更
// forEachが呼ばれないので、計測結果次第で元に戻します。名前も少しましに改名しましたし

extension RedBlackTreeSet {

  /// RawIndexは赤黒木ノードへの軽量なポインタとなっていて、rawIndicesはRawIndexのシーケンスを返します。
  /// 削除時のインデックス無効対策がイテレータに施してあり、削除操作に利用することができます。
  ///
  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public var rawIndices: RawIndexSequence<Tree> {
    RawIndexSequence(tree: _tree)
  }
}

// MARK: - Raw Indexed Sequence

// 元々、ポインタと値同時に列挙できたら実行時間短くなるんじゃね？
// ぐらいのノリでつくったものを、雰囲気でenumerated()として本流っぽくしていたけれども
// やはりおまけポジでした

extension RedBlackTreeSet {
  
  /// - Complexity: O(1)
  @inlinable @inline(__always)
  public var rawIndexedElements: RawIndexedSequence<Tree> {
    RawIndexedSequence(tree: _tree)
  }
}

extension RedBlackTreeSet {

  @available(*, deprecated, renamed: "rawIndexedElements")
  @inlinable @inline(__always)
  public func enumerated() -> RawIndexedSequence<Tree> {
    rawIndexedElements
  }
}

// MARK: - Utility

extension RedBlackTreeSet {

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

// MARK: - Protocol Adaption

extension RedBlackTreeSet: ExpressibleByArrayLiteral {

  /// - Complexity: O(*n* log *n*)
  @inlinable
  public init(arrayLiteral elements: Element...) {
    self.init(elements)
  }
}

// MARK: - CustomStringConvertible

extension RedBlackTreeSet: CustomStringConvertible {

  @inlinable
  public var description: String {
    "[\((map {"\($0)"} as [String]).joined(separator: ", "))]"
  }
}

// MARK: - CustomDebugStringConvertible

extension RedBlackTreeSet: CustomDebugStringConvertible {

  @inlinable
  public var debugDescription: String {
    "RedBlackTreeSet(\(description))"
  }
}

// MARK: - Equatable

extension RedBlackTreeSet: Equatable {

  /// - Complexity: O(*n*)
  @inlinable
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.___equal_with(rhs)
  }
}

// MARK: -

#if PERFOMANCE_CHECK
  extension RedBlackTreeSet {

    // 旧初期化実装
    // 性能比較用にのこしてある

    /// - Complexity: O(log *n*)
    @inlinable
    public init<Source>(_sequence sequence: __owned Source)
    where Element == Source.Element, Source: Sequence {
      let count = (sequence as? (any Collection))?.count
      var tree: Tree = .create(minimumCapacity: count ?? 0)
      for __k in sequence {
        if count == nil {
          Tree.ensureCapacity(tree: &tree)
        }
        var __parent = _NodePtr.nullptr
        // 検索の計算量がO(log *n*)
        let __child = tree.__find_equal(&__parent, __k)
        if tree.__ptr_(__child) == .nullptr {
          let __h = tree.__construct_node(__k)
          // バランシングの計算量がO(log *n*)
          tree.__insert_node_at(__parent, __child, __h)
        }
      }
      self._storage = .init(__tree: tree)
    }
  }
#endif

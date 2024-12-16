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

import Collections
import Foundation

/// ユニークな要素を格納する順序付きコレクションである赤黒木セット。
///
/// `RedBlackTreeSet` は、赤黒木（Red-Black Tree）を基盤としたデータ構造で、効率的な要素の挿入、削除、および探索をサポートします。
/// 順序を意識したコレクション操作が必要な場合に、リストや配列の代わりに利用できます。
///
/// ## 主な特徴
/// - 要素はユニークで、重複を許しません。
/// - 自動的に昇順にソートされた状態で管理されます。
/// - 任意の比較可能な型（`Comparable` に準拠した型）を要素として使用可能です。
/// - `BidirectionalCollection` に適合しており、双方向に要素を走査できます。
///
/// ## 実装済みの機能
/// - **境界探索**:
///   - `lowerBound(_:)` メソッドで、指定した値以上の最小要素を効率的に見つけられます。
///   - `upperBound(_:)` メソッドで、指定した値より大きい最小要素を効率的に見つけられます。
/// - **イテレーション**:
///   - 順序に従った要素の走査が可能です。
/// - **集合操作（未実装）**:
///   - 現在、典型的な集合演算（和集合、積集合、差集合など）は未実装です。
///
/// ## 例
/// `RedBlackTreeSet` を使用してソートされた集合を作成し、要素を探索する例:
///
/// ```swift
/// let numbers = RedBlackTreeSet([1, 3, 5, 7, 9])
/// if let lower = numbers.lowerBound(4) {
///     print(lower) // 出力: 5
/// }
/// if let upper = numbers.upperBound(7) {
///     print(upper) // 出力: 9
/// }
/// ```
///
/// ## 制約
/// - 要素型は `Comparable` プロトコルに準拠している必要があります。
/// - 集合演算（例: `union(_:)`, `intersection(_:)`, `subtracting(_:)` など）は現在未実装のため、手動で操作を行う必要があります。
///
/// ## 計算量
/// - 要素の挿入、削除、探索: O(log *n*)
/// - 境界探索 (`lowerBound`, `upperBound`): O(log *n*)
///
/// `RedBlackTreeSet` は、順序付けられたデータを扱う競技プログラミングや、高速な境界探索が必要なアプリケーションで有用です。
@frozen
public struct RedBlackTreeSet<Element: Comparable> {

  public
    typealias Element = Element

  public
    typealias Index = RedBlackTree.Index

  @usableFromInline
  typealias _Key = Element

  @usableFromInline
  var header: RedBlackTree.___Header

  @usableFromInline
  var nodes: [RedBlackTree.___Node]

  @usableFromInline
  var values: [Element]

  @usableFromInline
  var stock: Heap<_NodePtr> = []
}

extension RedBlackTreeSet {

  /// 空の赤黒木セットを作成します。
  ///
  /// これは空の配列リテラルで初期化するのと同等です。例:
  ///
  ///     var emptySet = RedBlackTreeSet<Int>()
  ///     print(emptySet.isEmpty)
  ///     // 出力: "true"
  ///
  ///     emptySet = []
  ///     print(emptySet.isEmpty)
  ///     // 出力: "true"
  @inlinable @inline(__always)
  public init() {
    header = .zero
    nodes = []
    values = []
  }

  /// 指定された要素数を収容するための領域を事前に確保した空の赤黒木セットを作成します。
  ///
  /// このイニシャライザは、セット作成後に挿入する要素数が事前にわかっている場合に、
  /// セットの内部バッファの再割り当てを回避するために使用します。
  ///
  /// - Parameter minimumCapacity: 作成される赤黒木セットが再割り当てなしで
  ///   格納できる最低限の要素数。
  @inlinable @inline(__always)
  public init(minimumCapacity: Int) {
    header = .zero
    nodes = []
    values = []
    nodes.reserveCapacity(minimumCapacity)
    values.reserveCapacity(minimumCapacity)
  }
}

extension RedBlackTreeSet {

  /// 有限のアイテム列から新しい赤黒木セットを作成します。
  ///
  /// このイニシャライザは、配列や範囲などの既存のシーケンスから新しい赤黒木セットを作成するために使用します。
  ///
  /// 例:
  ///
  ///     let validIndices = RedBlackTreeSet(0..<7).subtracting([2, 4, 5])
  ///     print(validIndices)
  ///     // 出力: "[6, 0, 1, 3]"
  ///
  /// - Parameter sequence: 新しい赤黒木セットのメンバーとして使用する要素列。
  @inlinable
  public init<Source>(_ sequence: Source)
  where Element == Source.Element, Source: Sequence {
    // valuesは一旦全部の分を確保する
    var _values: [Element] = sequence + []
    var _header: RedBlackTree.___Header = .zero
    // nodesの初期化回数を減らそうとして以下のようにしている
    self.nodes = [RedBlackTree.___Node](
      unsafeUninitializedCapacity: _values.count
    ) { _nodes, initializedCount in
      withUnsafeMutablePointer(to: &_header) { _header in
        var count = 0
        _values.withUnsafeMutableBufferPointer { _values in
          func __construct_node(_ __k: Element) -> _NodePtr {
            _nodes[count] = .zero
            // 前方から詰め直している
            _values[count] = __k
            defer { count += 1 }
            return count
          }
          let tree = _UnsafeMutatingHandle<Self>(
            __header_ptr: _header,
            __node_ptr: _nodes.baseAddress!,
            __value_ptr: _values.baseAddress!)
          var i = 0
          while i < _values.count {
            let __k = _values[i]
            i += 1
            // 以下は、__insert_uniqueと等価だが、__construct_nodeが初期化中で使えないため、
            // べた書きしている
            var __parent = _NodePtr.nullptr
            let __child = tree.__find_equal(&__parent, __k)
            if tree.__ref_(__child) == .nullptr {
              let __h = __construct_node(__k)
              tree.__insert_node_at(__parent, __child, __h)
            }
          }
          initializedCount = count
        }
        // 詰め終わった残りの部分を削除する
        _values.removeLast(_values.count - count)
      }
    }
    self.header = _header
    self.values = _values
    self.stock = []
  }
}

#if false
  // naive
  extension RedBlackTreeSet {
    @inlinable @inline(__always)
    public init<S>(_ _a: S) where S: Collection, S.Element == Element {
      self.nodes = []
      self.header = .zero
      self.values = []
      self.stock = []
      for a in _a {
        _ = insert(a)
      }
    }
  }
#endif

extension RedBlackTreeSet {

  /// 赤黒木セットが空であるかどうかを示すブール値。
  @inlinable
  public var isEmpty: Bool {
    ___isEmpty
  }

  /// 赤黒木セットに含まれる要素の数。
  ///
  /// - 計算量: O(1)
  @inlinable
  public var count: Int {
    ___count
  }

  /// 新しい領域を割り当てることなく、赤黒木セットが格納できる要素の総数。
  @inlinable
  public var capacity: Int {
    ___capacity
  }
}

extension RedBlackTreeSet {

  /// 指定された要素数を格納するのに十分な領域を確保します。
  ///
  /// 挿入する要素数が事前にわかっている場合、このメソッドを使用すると、
  /// 複数回の領域再割り当てを避けることができます。このメソッドは、
  /// 赤黒木セットが一意で変更可能な連続した領域を持つようにし、
  /// 少なくとも指定された要素数を格納できる領域を確保します。
  ///
  /// 既存のストレージに `minimumCapacity` 個の要素を格納できる余地があったとしても、
  /// `reserveCapacity(_:)` メソッドを呼び出すと、連続した新しい領域へのコピーが発生します。
  ///
  /// - Parameter minimumCapacity: 確保したい要素数。
  @inlinable
  public mutating func reserveCapacity(_ minimumCapacity: Int) {
    nodes.reserveCapacity(minimumCapacity)
    values.reserveCapacity(minimumCapacity)
  }
}

extension RedBlackTreeSet: ValueComparer {

  @inlinable @inline(__always)
  static func __key(_ e: Element) -> Element { e }

  @inlinable
  static func value_comp(_ a: Element, _ b: Element) -> Bool {
    a < b
  }
}

extension RedBlackTreeSet: RedBlackTreeSetContainer {}
extension RedBlackTreeSet: _UnsafeHandleBase {}
extension RedBlackTreeSet: _UnsafeMutatingHandleBase {

  // プロトコルでupdateが書けなかったため、個別で実装している
  @inlinable @inline(__always)
  mutating func _update<R>(_ body: (_UnsafeMutatingHandle<Self>) throws -> R) rethrows -> R {
    return try withUnsafeMutablePointer(to: &header) { header in
      try nodes.withUnsafeMutableBufferPointer { nodes in
        try values.withUnsafeMutableBufferPointer { values in
          try body(
            _UnsafeMutatingHandle<Self>(
              __header_ptr: header,
              __node_ptr: nodes.baseAddress!,
              __value_ptr: values.baseAddress!))
        }
      }
    }
  }
}

extension RedBlackTreeSet: InsertUniqueProtocol {}
extension RedBlackTreeSet: RedBlackTreeEraseProtocol {}
extension RedBlackTreeSet: RedBlackTree.SetInternal {}

extension RedBlackTreeSet {

  /// 指定された要素を赤黒木セットに挿入します（既に存在しない場合のみ）。
  ///
  /// `newMember` と等しい要素が既にセットに含まれている場合、このメソッドは何も行いません。
  /// 以下の例では、曜日を表すセット `classDays` に新しい要素が挿入されます。既存の要素を挿入しようとすると、セットの内容は変化しません。
  ///
  /// ```swift
  /// enum DayOfTheWeek: Int {
  ///     case sunday, monday, tuesday, wednesday, thursday, friday, saturday
  /// }
  ///
  /// var classDays: RedBlackTreeSet<DayOfTheWeek> = [.wednesday, .friday]
  /// print(classDays.insert(.monday))
  /// // 出力: "(inserted: true, memberAfterInsert: DayOfTheWeek.monday)"
  /// print(classDays)
  /// // 出力: "[DayOfTheWeek.friday, DayOfTheWeek.wednesday, DayOfTheWeek.monday]"
  ///
  /// print(classDays.insert(.friday))
  /// // 出力: "(inserted: false, memberAfterInsert: DayOfTheWeek.friday)"
  /// print(classDays)
  /// // 出力: "[DayOfTheWeek.friday, DayOfTheWeek.wednesday, DayOfTheWeek.monday]"
  /// ```
  ///
  /// - Parameter newMember: セットに挿入する要素。
  /// - Returns: `(true, newMember)` を返します（`newMember` がセットに含まれていなかった場合）。
  ///   既に `newMember` と等しい要素がセットに含まれていた場合、このメソッドは `(false, oldMember)` を返します。
  ///   ここで `oldMember` は `newMember` と等しい要素であり、一部のケースでは識別比較やその他の手段で `newMember` と区別できる場合があります。
  @discardableResult
  @inlinable public mutating func insert(_ newMember: Element) -> (
    inserted: Bool, memberAfterInsert: Element
  ) {
    let (__r, __inserted) = __insert_unique(newMember)
    return (__inserted, __inserted ? newMember : _read { values[$0.__ref_(__r)] })
  }

  /// 指定された要素を条件なしで赤黒木セットに挿入します。
  ///
  /// `newMember` と等しい要素が既にセットに含まれている場合、`newMember` は既存の要素を置き換えます。
  /// 以下の例では、曜日を表すセット `classDays` に既存の要素を挿入し、置き換えられた要素が返されます。
  ///
  /// ```swift
  /// enum DayOfTheWeek: Int {
  ///     case sunday, monday, tuesday, wednesday, thursday, friday, saturday
  /// }
  ///
  /// var classDays: RedBlackTreeSet<DayOfTheWeek> = [.monday, .wednesday, .friday]
  /// print(classDays.update(with: .monday))
  /// // 出力: "Optional(DayOfTheWeek.monday)"
  /// ```
  ///
  /// - Parameter newMember: セットに挿入する要素。
  /// - Returns: セット内に既に存在していた `newMember` と等しい要素を返します。それ以外の場合は `nil` を返します。
  ///   一部のケースでは、返される要素が `newMember` と識別比較やその他の手段によって区別できる場合があります。
  @discardableResult
  @inlinable public mutating func update(with newMember: Element) -> Element? {
    let (__r, __inserted) = __insert_unique(newMember)
    return __inserted
      ? nil
      : _read {
        let __p = $0.__ref_(__r)
        let oldMember = values[__p]
        values[__p] = newMember
        return oldMember
      }
  }

  /// 指定された要素を赤黒木セットから削除します。
  ///
  /// 以下の例では、材料を表すセット `ingredients` から `"sugar"` を削除しています。
  ///
  /// ```swift
  /// var ingredients: RedBlackTreeSet = ["cocoa beans", "sugar", "cocoa butter", "salt"]
  /// let toRemove = "sugar"
  /// if let removed = ingredients.remove(toRemove) {
  ///     print("The recipe is now \(removed)-free.")
  /// }
  /// // 出力: "The recipe is now sugar-free."
  /// ```
  ///
  /// - Parameter member: セットから削除する要素。
  /// - Returns: 指定された `member` がセットに含まれていた場合、その値を返します。それ以外の場合は `nil` を返します。
  @discardableResult
  @inlinable public mutating func remove(_ member: Element) -> Element? {
    __erase_unique(member) ? member : nil
  }

  /// 指定されたインデックス位置にある要素を赤黒木セットから削除します。
  ///
  /// - Parameter index: 削除する要素のインデックス。
  ///   `index` はセット内の有効なインデックスであり、セットの終端インデックス（`endIndex`）と等しくない必要があります。
  /// - Returns: セットから削除された要素。
  @inlinable
  @discardableResult
  public mutating func remove(at index: Index) -> Element {
    guard let element = __remove(at: index.pointer) else {
      fatalError("Attempting to access RedBlackTreeSet elements using an invalid index")
    }
    return element
  }

  /// 赤黒木セットからすべての要素を削除します。
  ///
  /// - Parameter keepingCapacity: `true` を指定すると、セットのバッファ容量が保持されます。
  ///   `false` を指定すると、内部バッファが解放されます（デフォルトは `false`）。
  @inlinable
  public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
    __removeAll(keepingCapacity: keepCapacity)
  }
}

extension RedBlackTreeSet {

  /// 指定された要素が赤黒木セット内に存在するかを示すブール値を返します。
  ///
  /// 以下の例では、`contains(_:)` メソッドを使用して、整数が素数のセットに含まれているかを判定しています。
  ///
  /// ```swift
  /// let primes: RedBlackTreeSet = [2, 3, 5, 7]
  /// let x = 5
  /// if primes.contains(x) {
  ///     print("\(x) is prime!")
  /// } else {
  ///     print("\(x). Not prime.")
  /// }
  /// // 出力: "5 is prime!"
  /// ```
  ///
  /// - Parameter member: セット内で探す要素。
  /// - Returns: `member` がセット内に存在する場合は `true`、存在しない場合は `false`。
  ///
  /// - 計算量: O(log *n*)
  @inlinable public func contains(_ member: Element) -> Bool {
    ___contains(member)
  }

  @inlinable public func min() -> Element? {
    ___min()
  }

  @inlinable public func max() -> Element? {
    ___max()
  }
}

extension RedBlackTreeSet: ExpressibleByArrayLiteral {

  /// 指定された配列リテラルの要素を含む赤黒木セットを作成します。
  ///
  /// このイニシャライザを直接呼び出さないでください。
  /// 配列リテラルを使用した際にコンパイラによって自動的に利用されます。
  /// 配列リテラルを使用して赤黒木セットを作成するには、コンマで区切った値のリストを角括弧で囲んでください。
  /// 配列リテラルは、型コンテキストがセットを期待する任意の場所で使用できます。
  ///
  /// 例として、文字列だけを含む配列リテラルから赤黒木セットを作成しています:
  ///
  ///     let ingredients: RedBlackTreeSet = ["cocoa beans", "sugar", "cocoa butter", "salt"]
  ///     if ingredients.isSuperset(of: ["sugar", "salt"]) {
  ///         print("Whatever it is, it's bound to be delicious!")
  ///     }
  ///     // 出力: "Whatever it is, it's bound to be delicious!"
  ///
  /// - Parameter elements: 新しい赤黒木セットの要素として使用する可変長引数リスト。
  @inlinable public init(arrayLiteral elements: Element...) {
    self.init(elements)
  }
}

extension RedBlackTreeSet {

  /// 指定された値以上の最小の要素を見つけ、そのインデックスを返します。
  ///
  /// このメソッドは、赤黒木セット内で指定された値 `value` と等しい、またはそれより大きい最小の要素を効率的に見つけます。
  /// 見つかった要素のインデックスを返します。該当する要素が存在しない場合は、`endIndex` を返します。
  ///
  /// 以下は、`lowerBound(_:)` メソッドを使用した例です:
  ///
  /// ```swift
  /// let numbers: RedBlackTreeSet = [1, 3, 5, 7, 9]
  /// if let index = numbers.lowerBound(4) {
  ///     print("Lower bound for 4 is \(numbers[index])") // 出力: "Lower bound for 4 is 5"
  /// } else {
  ///     print("No elements are greater than or equal to 4.")
  /// }
  /// ```
  ///
  /// - Parameter value: 検索対象の値。
  /// - Returns: 指定された値以上の最小要素のインデックスを返します。該当する要素が存在しない場合は `endIndex` を返します。
  ///
  /// - 計算量: O(log *n*)
  @inlinable public func lowerBound(_ member: Element) -> Index {
    Index(___lower_bound(member))
  }

  /// 指定された値より大きい最小の要素を見つけ、そのインデックスを返します。
  ///
  /// このメソッドは、赤黒木セット内で指定された値 `value` より大きい最小の要素を効率的に見つけます。
  /// 見つかった要素のインデックスを返します。該当する要素が存在しない場合は、`endIndex` を返します。
  ///
  /// 以下は、`upperBound(_:)` メソッドを使用した例です:
  ///
  /// ```swift
  /// let numbers: RedBlackTreeSet = [1, 3, 5, 7, 9]
  /// if let index = numbers.upperBound(7) {
  ///     print("Upper bound for 7 is \(numbers[index])") // 出力: "Upper bound for 7 is 9"
  /// } else {
  ///     print("No elements are greater than 7.")
  /// }
  /// ```
  ///
  /// - Parameter value: 検索対象の値。
  /// - Returns: 指定された値より大きい最小要素のインデックスを返します。該当する要素が存在しない場合は `endIndex` を返します。
  ///
  /// - 計算量: O(log *n*)
  @inlinable public func upperBound(_ member: Element) -> Index {
    Index(___upper_bound(member))
  }
}

extension RedBlackTreeSet {

  @inlinable public func lessThan(_ p: Element) -> Element? {
    ___lt(p)
  }
  @inlinable public func greatorThan(_ p: Element) -> Element? {
    ___gt(p)
  }
  @inlinable public func lessEqual(_ p: Element) -> Element? {
    ___le(p)
  }
  @inlinable public func greatorEqual(_ p: Element) -> Element? {
    ___ge(p)
  }
}

extension RedBlackTreeSet: BidirectionalCollection {

  @inlinable public subscript(position: RedBlackTree.Index) -> Element {
    values[position.pointer]
  }

  @inlinable public func index(before i: Index) -> Index {
    Index(_read { $0.__tree_prev_iter(i.pointer) })
  }

  @inlinable public func index(after i: Index) -> Index {
    Index(_read { $0.__tree_next_iter(i.pointer) })
  }

  @inlinable public var startIndex: Index {
    Index(___begin())
  }

  @inlinable public var endIndex: Index {
    Index(___end())
  }
}

/// Overwrite Default implementation for bidirectional collections.
extension RedBlackTreeSet {

  /// Replaces the given index with its predecessor.
  ///
  /// - Parameter i: A valid index of the collection. `i` must be greater than
  ///   `startIndex`.
  @inlinable public func formIndex(before i: inout Index) {
    i = Index(_read { $0.__tree_prev_iter(i.pointer) })
  }

  @inlinable public func index(_ i: Index, offsetBy distance: Int) -> Index {
    _read {
      Index($0.pointer(i.pointer, offsetBy: distance, type: "RedBlackTreeSet"))
    }
  }

  @inlinable public func index(
    _ i: Index, offsetBy distance: Int, limitedBy limit: Index
  ) -> Index? {
    _read {
      Index(
        $0.pointer(i.pointer, offsetBy: distance, limitedBy: limit.pointer, type: "RedBlackTreeSet")
      )
    }
  }

  @inlinable func distance(__last: _NodePtr) -> Int {
    if __last == end() { return count }
    return _read { $0.distance(__first: $0.__begin_node, __last: __last) }
  }

  /// O(n)
  @inlinable public func distance(from start: Index, to end: Index) -> Int {
    distance(__last: end.pointer) - distance(__last: start.pointer)
  }
}

extension RedBlackTreeSet: CustomStringConvertible, CustomDebugStringConvertible {
  /// 人間が読みやすい形式でセットの内容を文字列として表現します。
  public var description: String {
    "[\((map {"\($0)"} as [String]).joined(separator: ", "))]"
  }

  /// デバッグ時にセットの詳細情報を含む文字列を返します。
  public var debugDescription: String {
    "RedBlackTreeSet(\(description))"
  }
}

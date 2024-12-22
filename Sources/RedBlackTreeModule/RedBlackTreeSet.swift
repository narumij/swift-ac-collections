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

// AC https://atcoder.jp/contests/abc370/submissions/57922896
// AC https://atcoder.jp/contests/abc385/submissions/61003801

/// ユニークな要素を格納する順序付きコレクションである赤黒木セット。
///
/// `RedBlackTreeSet` は、赤黒木（Red-Black Tree）を基盤としたデータ構造で、効率的な要素の挿入、削除、および探索をサポートします。
/// 順序を意識したコレクション操作が必要な場合に、リストや配列の代わりに利用できます。
///
/// ## 主な特徴
/// - 要素はユニークで、重複を許容しません。
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
    typealias Index = ___RedBlackTree.Index

  @usableFromInline
  typealias _Key = Element

  @usableFromInline
  var ___header: ___RedBlackTree.___Header

  @usableFromInline
  var ___nodes: [___RedBlackTree.___Node]

  @usableFromInline
  var ___values: [Element]

  @usableFromInline
  var ___stock: Heap<_NodePtr>
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
    ___header = .zero
    ___nodes = []
    ___values = []
    ___stock = []
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
    ___header = .zero
    ___nodes = []
    ___values = []
    ___stock = []
    ___nodes.reserveCapacity(minimumCapacity)
    ___values.reserveCapacity(minimumCapacity)
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
  public init<Source>(_ sequence: __owned Source)
  where Element == Source.Element, Source: Sequence {
    (
      ___header,
      ___nodes,
      ___values,
      ___stock
    ) = Self.___initialize(
      _sequence: sequence,
      _to_elements: { $0.map { $0 } }
    ) { tree, __k, _, __construct_node in
      var __parent = _NodePtr.nullptr
      let __child = tree.__find_equal(&__parent, __k)
      if tree.__ref_(__child) == .nullptr {
        let __h = __construct_node(__k)
        tree.__insert_node_at(__parent, __child, __h)
      }
    }
  }
}

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
    ___nodes.reserveCapacity(minimumCapacity)
    ___values.reserveCapacity(minimumCapacity)
  }
}

extension RedBlackTreeSet: ValueComparer {

  @inlinable @inline(__always)
  static func __key(_ e: Element) -> Element { e }

  @inlinable @inline(__always)
  static func value_comp(_ a: Element, _ b: Element) -> Bool {
    a < b
  }
}

extension RedBlackTreeSet: ___RedBlackTreeUpdate {

  // プロトコルでupdateが書けなかったため、個別で実装している
  @inlinable @inline(__always)
  mutating func _update<R>(_ body: (___UnsafeMutatingHandle<Self>) throws -> R) rethrows -> R {
    return try withUnsafeMutablePointer(to: &___header) { header in
      try ___nodes.withUnsafeMutableBufferPointer { nodes in
        try ___values.withUnsafeMutableBufferPointer { values in
          try body(
            ___UnsafeMutatingHandle<Self>(
              __header_ptr: header,
              __node_ptr: nodes.baseAddress!,
              __value_ptr: values.baseAddress!))
        }
      }
    }
  }
}

extension RedBlackTreeSet: InsertUniqueProtocol {}
extension RedBlackTreeSet: EraseUniqueProtocol {}
extension RedBlackTreeSet: ___RedBlackTreeEraseProtocol {}

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
    return (__inserted, __inserted ? newMember : ___values[__ref_(__r)])
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
        let oldMember = ___values[__p]
        ___values[__p] = newMember
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
    guard let element = ___remove(at: index.pointer) else {
      fatalError("Attempting to access RedBlackTreeSet elements using an invalid index")
    }
    return element
  }

  /// 赤黒木セットの最初の要素を削除して返します。
  ///
  /// このメソッドは、赤黒木セット内の最小要素を削除して返します。
  /// 赤黒木セットは要素がソートされた状態で格納されるため、「最初の要素」とは順序的に最小の要素を指します。
  /// セットが空であってはいけません。
  ///
  /// 以下は、`removeFirst()` メソッドの使用例です:
  ///
  /// ```swift
  /// var set: RedBlackTreeSet = [1, 2, 3, 4]
  /// let first = set.removeFirst()
  /// print(first)       // 出力: 1
  /// print(set)         // 出力: [2, 3, 4]
  /// ```
  ///
  /// - Returns: セットから削除された要素（順序的に最小の要素）。
  /// - Complexity: O(log *n*), ここで *n* はセット内の要素数。
  ///
  /// - Precondition: セットが空でないこと。
  @inlinable
  @discardableResult
  public mutating func removeFirst() -> Element {
    guard !isEmpty else {
      preconditionFailure("Can't removeFirst from an empty RedBlackTreeSet")
    }
    return remove(at: startIndex)
  }

  @inlinable
  @discardableResult
  public mutating func removeLast() -> Element {
    guard !isEmpty else {
      preconditionFailure("Can't removeFirst from an empty RedBlackTreeSet")
    }
    return remove(at: index(before: endIndex))
  }

  /// 赤黒木セットからすべての要素を削除します。
  ///
  /// - Parameter keepingCapacity: `true` を指定すると、セットのバッファ容量が保持されます。
  ///   `false` を指定すると、内部バッファが解放されます（デフォルトは `false`）。
  @inlinable
  public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
    ___removeAll(keepingCapacity: keepCapacity)
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

  /// 赤黒木セット内の最小要素を返します。
  ///
  /// このメソッドは、`RedBlackTreeSet` 内で順序的に最小の要素を返します。
  /// セットが空の場合は `nil` を返します。
  ///
  /// 以下は、`min()` メソッドを使用した例です:
  ///
  /// ```swift
  /// let set: RedBlackTreeSet = [3, 1, 4, 5, 9]
  /// if let minValue = set.min() {
  ///     print("Minimum value: \(minValue)") // 出力: "Minimum value: 1"
  /// } else {
  ///     print("The set is empty.")
  /// }
  /// ```
  ///
  /// - Returns: セット内の最小要素。セットが空の場合は `nil`。
  ///
  /// - Complexity: O(log *n*), ここで *n* はセット内の要素数。
  ///
  /// - Note: `RedBlackTreeSet` は要素を昇順で管理しているため、最小要素は割と効率的に取得できます。
  @inlinable public func min() -> Element? {
    // O(1)にできるが、オリジナルにならい、一旦このまま
    ___min()
  }

  /// 赤黒木セット内の最大要素を返します。
  ///
  /// このメソッドは、`RedBlackTreeSet` 内で順序的に最大の要素を返します。
  /// セットが空の場合は `nil` を返します。
  ///
  /// 以下は、`max()` メソッドを使用した例です:
  ///
  /// ```swift
  /// let set: RedBlackTreeSet = [3, 1, 4, 5, 9]
  /// if let maxValue = set.max() {
  ///     print("Maximum value: \(maxValue)") // 出力: "Maximum value: 9"
  /// } else {
  ///     print("The set is empty.")
  /// }
  /// ```
  ///
  /// - Returns: セット内の最大要素。セットが空の場合は `nil`。
  ///
  /// - Complexity: O(log *n*), ここで *n* はセット内の要素数。
  ///
  /// - Note: `RedBlackTreeSet` は要素を昇順で管理しているため、最大要素は割と効率的に取得できます。
  @inlinable public func max() -> Element? {
    // O(1)にできるが、オリジナルにならい、一旦このまま
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
    ___index_lower_bound(member)
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
    ___index_upper_bound(member)
  }
}

extension RedBlackTreeSet {

  /// セット内の最小の要素を返します。
  ///
  /// - Returns: セット内の最小の要素。セットが空の場合は `nil`。
  ///
  /// - Complexity: O(1)。
  @inlinable
  public var first: Element? {
    isEmpty ? nil : self[startIndex]
  }

  /// セット内の最大の要素を返します。
  ///
  /// - Returns: セット内の最大の要素。セットが空の場合は `nil`。
  ///
  /// - Complexity: O(1)。
  @inlinable
  public var last: Element? {
    isEmpty ? nil : self[index(before: .end)]
  }

  /// 指定された要素のインデックスを返します。要素がセットに存在しない場合は `nil` を返します。
  ///
  /// このメソッドは、赤黒木セット内で指定された要素 `member` を検索し、存在する場合はその要素のインデックスを返します。
  /// 要素がセット内に存在しない場合は `nil` を返します。
  ///
  /// 以下は、`index(of:)` メソッドの使用例です:
  ///
  /// ```swift
  /// let set: RedBlackTreeSet = [1, 3, 5, 7]
  ///
  /// if let index = set.index(of: 5) {
  ///     print("Index of 5: \(index)")
  ///     print("Value at index: \(set[index])") // 出力: 5
  /// } else {
  ///     print("5 is not in the set.")
  /// }
  /// ```
  ///
  /// - Parameter member: セット内で検索する要素。
  /// - Returns: `member` のインデックスを返します。要素が存在しない場合は `nil`。
  ///
  /// - Complexity: O(log *n*), ここで *n* はセット内の要素数。
  @inlinable
  public func firstIndex(of member: Element) -> Index? {
    _read { tree in
      var __parent = _NodePtr.nullptr
      let ptr = tree.__ref_(tree.__find_equal(&__parent, member))
      return Index?(ptr)
    }
  }

  /// 指定された述語を満たす最初の要素のインデックスを返します。
  ///
  /// このメソッドは、`RedBlackTreeSet` 内の要素を順序に従って走査し、指定された述語 `predicate` が `true` を返す最初の要素のインデックスを返します。
  /// 述語を満たす要素が存在しない場合は `nil` を返します。
  ///
  /// 以下は、`firstIndex(where:)` メソッドを使用した例です:
  ///
  /// ```swift
  /// let set: RedBlackTreeSet = [1, 3, 5, 7, 9]
  ///
  /// if let index = set.firstIndex(where: { $0 > 4 }) {
  ///     print("First index where element > 4: \(index)")
  ///     print("Value at index: \(set[index])") // 出力: 5
  /// } else {
  ///     print("No elements match the condition.")
  /// }
  /// ```
  ///
  /// - Parameter predicate: 各要素に対して評価する述語。`predicate` は `true` または `false` を返します。
  /// - Returns: `predicate` を満たす最初の要素のインデックス。条件に一致する要素がない場合は `nil`。
  ///
  /// - Complexity: O(*n*), ここで *n* はセット内の要素数。
  ///
  /// - Note: このメソッドは、セット内の要素を昇順に走査します。
  @inlinable
  public func firstIndex(where predicate: (Element) throws -> Bool) rethrows -> Index? {
    try ___enumerated_sequence.first(where: { try predicate($0.element) })?.position
  }
}

extension RedBlackTreeSet {

  /// 赤黒木セット内の要素を昇順にソートして配列として返します。
  ///
  /// `RedBlackTreeSet` は要素を昇順に保持しているため、このメソッドはセット内の全要素を順序通りに取り出し、配列として返します。
  ///
  /// 以下は、`sorted()` メソッドを使用した例です:
  ///
  /// ```swift
  /// let set: RedBlackTreeSet = [3, 1, 4, 1, 5, 9]
  /// let sortedArray = set.sorted()
  /// print(sortedArray) // 出力: [1, 3, 4, 5, 9]
  /// ```
  ///
  /// - Returns: セット内の要素を昇順に並べた配列。
  ///
  /// - Complexity: O(*n*), ここで *n* はセット内の要素数。
  ///
  /// - Note: `RedBlackTreeSet` は既に要素を昇順で管理しているため、このメソッドは効率的に全要素を抽出します。
  @inlinable
  func sorted() -> [Element] {
    // _readでトラバースする方が速い可能性があるが、未検証
    map { $0 }
  }
}

extension RedBlackTreeSet: Collection {

  /// 指定された位置にある要素へアクセスします。
  ///
  /// インデックスを使用して `RedBlackTreeSet` 内の要素を取得します。
  /// 指定されたインデックスはセット内の有効な位置である必要があります。
  ///
  /// - Parameter position: アクセスする要素のインデックス。
  /// - Returns: 指定されたインデックス位置にある要素。
  ///
  /// - Complexity: O(1)。
  ///
  /// - Precondition: `position` は `startIndex` 以上、`endIndex` 未満である必要があります。
  @inlinable public subscript(position: ___RedBlackTree.Index) -> Element {
    ___values[position.pointer]
  }

  /// 指定されたインデックスの直前の位置を返します。
  ///
  /// `index(before:)` メソッドは、指定されたインデックス `i` の直前にあるインデックスを返します。
  /// `i` は `startIndex` より大きい有効なインデックスである必要があります。
  ///
  /// - Parameter i: 基準となるインデックス。`startIndex` を超える位置でなければなりません。
  /// - Returns: 指定されたインデックスの直前の位置。
  ///
  /// - Complexity: O(1)。
  ///
  /// - Precondition: `i` は `startIndex` より大きく、`endIndex` 以下である必要があります。
  @inlinable public func index(before i: Index) -> Index {
    ___index_prev(i, type: "RedBlackTreeSet")
  }

  /// 指定されたインデックスの直後の位置を返します。
  ///
  /// `index(after:)` メソッドは、指定されたインデックス `i` の直後にあるインデックスを返します。
  /// `i` は `endIndex` より小さい有効なインデックスである必要があります。
  ///
  /// - Parameter i: 基準となるインデックス。`endIndex` 未満でなければなりません。
  /// - Returns: 指定されたインデックスの直後の位置。
  ///
  /// - Complexity: O(1)。
  ///
  /// - Precondition: `i` は `startIndex` 以上、`endIndex` 未満である必要があります。
  @inlinable public func index(after i: Index) -> Index {
    ___index_next(i, type: "RedBlackTreeSet")
  }

  /// セット内の要素を反復処理するための開始位置を返します。
  ///
  /// セットが空の場合、`startIndex` は `endIndex` と等しくなります。
  ///
  /// - Returns: セット内の最初の要素を指すインデックス。セットが空の場合は `endIndex`。
  ///
  /// - Complexity: O(1)。
  @inlinable public var startIndex: Index {
    ___index_begin()
  }

  /// セットの「終端を過ぎた」位置を返します。
  ///
  /// このプロパティは、`RedBlackTreeSet` 内の最後の有効な要素の次の位置を指します。
  /// セットが空の場合、`endIndex` は `startIndex` と等しくなります。
  ///
  /// - Returns: セットの終端を過ぎた位置を指すインデックス。
  ///
  /// - Complexity: O(1)。
  @inlinable public var endIndex: Index {
    ___index_end()
  }
}

/// Overwrite Default implementation for bidirectional collections.
extension RedBlackTreeSet {

  /// 指定されたインデックスから、指定された距離分だけオフセットした位置のインデックスを返します。
  ///
  /// `index(_:offsetBy:)` メソッドは、指定されたインデックス `i` から `distance` 要素分進んだ、または戻った位置のインデックスを返します。
  /// 正の距離は前方へのオフセット、負の距離は後方へのオフセットを意味します。
  ///
  /// - Parameters:
  ///   - i: 基準となるインデックス。`startIndex` 以上 `endIndex` 以下である必要があります。
  ///   - distance: オフセットする要素数。正の場合は前方、負の場合は後方へ移動します。
  /// - Returns: 指定された距離だけオフセットされたインデックス。
  ///
  /// - Complexity: O(*k*)、ここで *k* は移動する距離の要素数です。
  ///
  /// - Precondition: 結果のインデックスは `startIndex` 以上 `endIndex` 以下である必要があります。
  @inlinable public func index(_ i: Index, offsetBy distance: Int) -> Index {
    ___index(i, offsetBy: distance, type: "RedBlackTreeSet")
  }

  /// 指定されたインデックスから、指定された距離分オフセットした位置のインデックスを返します。
  /// ただし、結果が指定された制限インデックスを超える場合は `nil` を返します。
  ///
  /// `index(_:offsetBy:limitedBy:)` メソッドは、指定されたインデックス `i` から `distance` 要素分だけ
  /// 進む、または戻る位置を計算します。結果が制限インデックス `limit` を超えない場合にのみ有効です。
  ///
  /// - Parameters:
  ///   - i: 基準となるインデックス。`startIndex` 以上 `endIndex` 以下である必要があります。
  ///   - distance: オフセットする要素数。正の場合は前方、負の場合は後方へ移動します。
  ///   - limit: 計算結果が超えてはいけない制限インデックス。
  /// - Returns: 指定された距離だけオフセットされたインデックス。
  ///            結果が `limit` を超える場合は `nil` を返します。
  ///
  /// - Complexity: O(*k*)、ここで *k* は移動する距離の要素数です。
  ///
  /// - Precondition: `i` と `limit` は有効なインデックスである必要があります。
  @inlinable public func index(_ i: Index, offsetBy distance: Int, limitedBy limit: Index) -> Index?
  {
    ___index(i, offsetBy: distance, limitedBy: limit, type: "RedBlackTreeSet")
  }

  /// 2つのインデックス間の距離を返します。
  ///
  /// `distance(from:to:)` メソッドは、指定された開始インデックス `start` から終了インデックス `end` までの要素数を計算します。
  /// インデックス間の距離は正または負の整数で返されます。
  ///
  /// - Parameters:
  ///   - start: 距離の計算を開始するインデックス。`startIndex` 以上 `endIndex` 以下である必要があります。
  ///   - end: 距離の計算を終了するインデックス。`startIndex` 以上 `endIndex` 以下である必要があります。
  /// - Returns: `start` から `end` までの要素数。`start` より `end` が後の場合は正の値、前の場合は負の値になります。
  ///
  /// - Complexity: O(*k*), ここで *k* は2つのインデックス間にある要素数です。
  ///
  /// - Precondition: `start` および `end` は有効なインデックスである必要があります。
  @inlinable
  public func distance(from start: Index, to end: Index) -> Int {
    ___distance(__last: end.pointer) - ___distance(__last: start.pointer)
  }
}

extension RedBlackTreeSet: CustomStringConvertible, CustomDebugStringConvertible {
  /// 人間が読みやすい形式でセットの内容を文字列として表現します。
  @inlinable
  public var description: String {
    "[\((map {"\($0)"} as [String]).joined(separator: ", "))]"
  }

  /// デバッグ時にセットの詳細情報を含む文字列を返します。
  @inlinable
  public var debugDescription: String {
    "RedBlackTreeSet(\(description))"
  }
}

extension RedBlackTreeSet: Equatable {

  @inlinable
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.___equal_with(rhs)
  }
}

extension RedBlackTreeSet {

  public typealias IndexRange = ___RedBlackTree.Range
  public typealias SeqenceState = (current: _NodePtr, next: _NodePtr, to: _NodePtr)
  public typealias EnumeratedElement = (position: Index, element: Element)

  public typealias EnumeratedSequence = UnfoldSequence<EnumeratedElement, SeqenceState>
  public typealias ElementSequence = ArraySlice<Element>

  @inlinable
  public subscript(bounds: IndexRange) -> ElementSequence {
    .init(___element_sequence(from: bounds.lhs, to: bounds.rhs))
  }

  @inlinable
  public func enumrated() -> EnumeratedSequence {
    ___enumerated_sequence
  }

  @inlinable
  public func enumrated(from: Index, to: Index) -> EnumeratedSequence {
    ___enumerated_sequence(from: from, to: to)
  }
}

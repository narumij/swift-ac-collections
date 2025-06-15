//
//  Untitled.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/06/16.
//

@frozen
public struct RedBlackTreeTupleMap<each K: Comparable, Value> {

  public
    typealias Key = (repeat each K)

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

extension RedBlackTreeTupleMap: ___RedBlackTreeBase {
  public static func __key(_ v: Element) -> _Key {
    v.key
  }
  public static func value_comp(_ lhs: _Key, _ rhs: _Key) -> Bool {
    for (l, r) in repeat (each lhs, each rhs) {
      if l != r {
        return l < r
      }
    }
    return false
  }
}
extension RedBlackTreeTupleMap: ___RedBlackTreeCopyOnWrite {}
extension RedBlackTreeTupleMap: ___RedBlackTreeUnique {}
extension RedBlackTreeTupleMap: ___RedBlackTreeSequence {}
extension RedBlackTreeTupleMap: KeyValueComparer {}

// MARK: - Creating a Dictionay

extension RedBlackTreeTupleMap {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public init() {
    self.init(minimumCapacity: 0)
  }

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public init(minimumCapacity: Int) {
    _storage = .create(withCapacity: minimumCapacity)
  }
}

extension RedBlackTreeTupleMap {

  /// - Complexity: O(*n* log *n* + *n*)
  @inlinable
  public init<S>(uniqueKeysWithValues keysAndValues: __owned S)
  where S: Sequence, S.Element == (Key, Value) {
    let count = (keysAndValues as? (any Collection))?.count
    var tree: Tree = .create(minimumCapacity: count ?? 0)
    for (key, value) in keysAndValues {
      if count == nil {
        Tree.ensureCapacity(tree: &tree)
      }
      var __parent = _NodePtr.nullptr
      // 検索の計算量がO(log *n*)
      let __child = tree.__find_equal(&__parent, key)
      if tree.__ptr_(__child) == .nullptr {
        let __h = tree.__construct_node((key,value))
        // バランシングの計算量がO(log *n*)
        tree.__insert_node_at(__parent, __child, __h)
      } else {
        fatalError("Dupricate values for key: '\(key)'")
      }
    }
    self._storage = .init(tree: tree)
  }
}

// MARK: - Inspecting a MultiMap

extension RedBlackTreeTupleMap {

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

// MARK: - Accessing Keys and Values

extension RedBlackTreeTupleMap {

  /// - Complexity: O(1)
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

extension RedBlackTreeTupleMap {

  /// - Complexity: O(log *n*)
  @inlinable @inline(__always)
  public subscript(key: Key) -> Value? {
    ___value_for(key)?.value
    // コンパイラのクラッシュに見舞われて、セッターがつけられない
  }

  /// - Complexity: O(log *n*)
  @inlinable @inline(__always)
  public subscript(
    key: Key, default defaultValue: @autoclosure () -> Value
  ) -> Value {
    ___value_for(key)?.value ?? defaultValue()
    // コンパイラのクラッシュに見舞われて、セッターがつけられない
  }
}

// MARK: - Insert

extension RedBlackTreeTupleMap {

#if false
  // compiler crash
  /// - Complexity: O(log *n*)
  @inlinable
  @inline(__always)
  @discardableResult
  public mutating func insert(key: Key, value: Value) -> (
    inserted: Bool, memberAfterInsert: Element
  ) {
//    insert((key, value))
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
    _ = __tree_.__insert_unique(newMember)
    return (true, newMember)
  }
}

extension RedBlackTreeTupleMap {

  /// - Complexity: O(log *n*)
  @inlinable
  @inline(__always)
  @discardableResult
  public mutating func updateValue(
    _ value: Value,
    forKey key: Key
  ) -> Value? {
    _ensureUniqueAndCapacity()
    let (__r, __inserted) = __tree_.__insert_unique((key, value))
    guard !__inserted else { return nil }
    let oldMember = __tree_[__r]
    __tree_[__r] = (key, value)
    return oldMember.value
  }
}

extension RedBlackTreeTupleMap {

  @inlinable
  public mutating func reserveCapacity(_ minimumCapacity: Int) {
    _ensureUniqueAndCapacity(to: minimumCapacity)
  }
}

// MARK: - Remove

extension RedBlackTreeTupleMap {

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

extension RedBlackTreeTupleMap {

  /// - Important: 削除したメンバーを指すインデックスが無効になります。
  /// - Complexity: O(log *n*)
  @inlinable
  @inline(__always)
  @discardableResult
  public mutating func removeValue(forKey __k: Key) -> Value? {
    let __i = __tree_.find(__k)
    if __i == __tree_.end() {
      return nil
    }
    let value = __tree_.___element(__i).value
    _ensureUnique()
    _ = __tree_.erase(__i)
    return value
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

extension RedBlackTreeTupleMap {

  /// - Complexity: O(1)
  @inlinable
  public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
    _ensureUnique()
    ___removeAll(keepingCapacity: keepCapacity)
  }
}

// MARK: Finding Elements

extension RedBlackTreeTupleMap {

  /// - Complexity: O(log *n*)
  @inlinable
  public func contains(key: Key) -> Bool {
    ___contains(key)
  }
}

extension RedBlackTreeTupleMap {

  /// - Complexity: O(*n*)
  @inlinable
  public func first(where predicate: (Element) throws -> Bool) rethrows -> Element? {
    try ___first(where: predicate)
  }
}

extension RedBlackTreeTupleMap {

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

extension RedBlackTreeTupleMap: Sequence {}

// MARK: - Index Range

extension RedBlackTreeTupleMap {

  public typealias Indices = Tree.Indices
}

// MARK: - ExpressibleByDictionaryLiteral

extension RedBlackTreeTupleMap: ExpressibleByDictionaryLiteral {

  /// - Complexity: O(*n* log *n*)
  @inlinable
  @inline(__always)
  public init(dictionaryLiteral elements: (Key, Value)...) {
    self.init(uniqueKeysWithValues: elements)
  }
}

// MARK: - ExpressibleByArrayLiteral

extension RedBlackTreeTupleMap: ExpressibleByArrayLiteral {

  /// `[("key", value), ...]` 形式のリテラルから辞書を生成します。
  ///
  /// - Important: キーが重複していた場合は
  ///   `Dictionary(uniqueKeysWithValues:)` と同じく **ランタイムエラー** になります。
  ///   （重複を許容してマージしたい場合は `merge` / `merging` を使ってください）
  ///
  /// 使用例
  /// ```swift
  /// let d: RedBlackTreeDictionary = [("a", 1), ("b", 2)]
  /// ```
  /// - Complexity: O(*n* log *n*)
  @inlinable
  @inline(__always)
  public init(arrayLiteral elements: (Key, Value)...) {
    self.init(uniqueKeysWithValues: elements)
  }
}

// MARK: - CustomStringConvertible

extension RedBlackTreeTupleMap: CustomStringConvertible {

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

extension RedBlackTreeTupleMap: CustomDebugStringConvertible {

  public var debugDescription: String {
    var result = "RedBlackTreeDictionary<\(Key.self), \(Value.self)>("
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

extension RedBlackTreeTupleMap: CustomReflectable {
  /// The custom mirror for this instance.
  public var customMirror: Mirror {
    Mirror(self, unlabeledChildren: self, displayStyle: .dictionary)
  }
}

// MARK: - Equatable

extension RedBlackTreeTupleMap: Equatable where Value: Equatable {

  /// - Complexity: O(*m*), where *m* is the lesser of the length of `lhs` and `rhs`.
  @inlinable
  @inline(__always)
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.count == rhs.count && lhs.elementsEqual(rhs)
  }
}

// MARK: - Comparable

extension RedBlackTreeTupleMap: Comparable where Value: Comparable {

  /// - Complexity: O(*m*), where *m* is the lesser of the length of `lhs` and `rhs`.
  @inlinable
  @inline(__always)
  public static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.lexicographicallyPrecedes(rhs)
  }
}

// MARK: -

extension RedBlackTreeTupleMap where Value: Equatable {

  /// - Complexity: O(*m*), where *m* is the lesser of the length of the
  ///   sequence and the length of `other`.
  @inlinable
  @inline(__always)
  public func elementsEqual<OtherSequence>(_ other: OtherSequence) -> Bool
  where OtherSequence: Sequence, Element == OtherSequence.Element {
    elementsEqual(other, by: Tree.___key_value_equiv)
  }
}

extension RedBlackTreeTupleMap where Value: Comparable {

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
  extension RedBlackTreeTupleMap: @unchecked Sendable
  where Element: Sendable {}
#endif

#if PERFOMANCE_CHECK
extension RedBlackTreeTupleMap {

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

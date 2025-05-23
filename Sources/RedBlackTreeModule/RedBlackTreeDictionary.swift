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

/// `RedBlackTreeDictionary` は、`Key` 型のキーと `Value` 型の値のペアを一意に格納するための
/// 赤黒木（Red-Black Tree）ベースの辞書型です。
///
/// ### 使用例
/// ```swift
/// /// `RedBlackTreeDictionary` を使用する例
/// var dictionary = RedBlackTreeDictionary<String, Int>()
/// dictionary.insert(key: "apple", value: 5)
/// dictionary.insert(key: "banana", value: 3)
/// dictionary.insert(key: "cherry", value: 7)
///
/// // キーを使用して値にアクセス
/// if let value = dictionary.value(forKey: "banana") {
///     print("banana の値は \(value) です。") // 出力例: banana の値は 3 です。
/// }
///
/// // キーと値のペアを削除
/// dictionary.remove(key: "apple")
/// ```
@frozen
public struct RedBlackTreeDictionary<Key: Comparable, Value> {

  public
    typealias Index = Tree.Pointer

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

extension RedBlackTreeDictionary {
  public typealias RawIndex = Tree.RawPointer
}

extension RedBlackTreeDictionary: ___RedBlackTreeBase {}
extension RedBlackTreeDictionary: ___RedBlackTreeStorageLifetime {}
extension RedBlackTreeDictionary: KeyValueComparer {}

extension RedBlackTreeDictionary {

  @inlinable @inline(__always)
  public init() {
    self.init(minimumCapacity: 0)
  }

  @inlinable @inline(__always)
  public init(minimumCapacity: Int) {
    _storage = .create(withCapacity: minimumCapacity)
  }
}

extension RedBlackTreeDictionary {

  @inlinable
  public init<S>(uniqueKeysWithValues keysAndValues: __owned S)
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
      if __parent == .end || tree[__parent].0 != __k.0 {
        // バランシングの計算量がO(log *n*)
        (__parent, __child) = tree.___emplace_hint_right(__parent, __child, __k)
        assert(tree.__tree_invariant(tree.__root()))
      } else {
        fatalError("Dupricate values for key: '\(__k.0)'")
      }
    }
    self._storage = .init(__tree: tree)
  }
}

extension RedBlackTreeDictionary {

  @inlinable
  public init<S>(
    _ keysAndValues: __owned S,
    uniquingKeysWith combine: (Value, Value) throws -> Value
  ) rethrows where S: Sequence, S.Element == (Key, Value) {
    let count = (keysAndValues as? (any Collection))?.count
    var tree: Tree = .create(minimumCapacity: count ?? 0)
    // 初期化直後はO(1)
    var (__parent, __child) = tree.___max_ref()
    // ソートの計算量がO(*n* log *n*)
    for __k in keysAndValues.sorted(by: { $0.0 < $1.0 }) {
      if count == nil {
        Tree.ensureCapacity(tree: &tree)
      }
      if __parent == .end || tree[__parent].0 != __k.0 {
        // バランシングの計算量がO(log *n*)
        (__parent, __child) = tree.___emplace_hint_right(__parent, __child, __k)
        assert(tree.__tree_invariant(tree.__root()))
      } else {
        tree[__parent].value = try combine(tree[__parent].value, __k.1)
      }
    }
    self._storage = .init(__tree: tree)
  }
}

extension RedBlackTreeDictionary {

  @inlinable
  public init<S: Sequence>(
    grouping values: __owned S,
    by keyForValue: (S.Element) throws -> Key
  ) rethrows where Value == [S.Element] {
    let count = (values as? (any Collection))?.count
    var tree: Tree = .create(minimumCapacity: count ?? 0)
    // 初期化直後はO(1)
    var (__parent, __child) = tree.___max_ref()
    // ソートの計算量がO(*n* log *n*)
    for (__k, __v) in try values.map({ (try keyForValue($0), $0) }).sorted(by: { $0.0 < $1.0 }) {
      if count == nil {
        Tree.ensureCapacity(tree: &tree)
      }
      if __parent == .end || tree[__parent].0 != __k {
        // バランシングの計算量がO(log *n*)
        (__parent, __child) = tree.___emplace_hint_right(__parent, __child, (__k, [__v]))
        assert(tree.__tree_invariant(tree.__root()))
      } else {
        tree[__parent].value.append(__v)
      }
    }
    self._storage = .init(__tree: tree)
  }
}

extension RedBlackTreeDictionary {

  /// - 計算量: O(1)
  @inlinable
  public var isEmpty: Bool {
    ___is_empty
  }

  /// - 計算量: O(1)
  @inlinable
  public var capacity: Int {
    ___capacity
  }
}

extension RedBlackTreeDictionary {

  @inlinable
  public mutating func reserveCapacity(_ minimumCapacity: Int) {
    _ensureUniqueAndCapacity(to: minimumCapacity)
  }
}

extension RedBlackTreeDictionary {

  @usableFromInline
  struct ___ModifyHelper {
    @inlinable @inline(__always)
    init(pointer: UnsafeMutablePointer<Value>) {
      self.pointer = pointer
    }
    @usableFromInline
    var isNil: Bool = false
    @usableFromInline
    var pointer: UnsafeMutablePointer<Value>
    @inlinable
    var value: Value? {
      @inline(__always)
      get { isNil ? nil : pointer.pointee }
      @inline(__always)
      _modify {
        var value: Value? = pointer.move()
        defer {
          if let value {
            isNil = false
            pointer.initialize(to: value)
          } else {
            isNil = true
          }
        }
        yield &value
      }
    }
  }

  @inlinable
  public subscript(key: Key) -> Value? {
    @inline(__always)
    get { ___value_for(key)?.value }
    @inline(__always)
    _modify {
      // TODO: もうすこしライフタイム管理に明るくなったら、再度ここのチューニングに取り組む
      let (__parent, __child, __ptr) = _prepareForKeyingModify(key)
      if __ptr == .nullptr {
        var value: Value?
        defer {
          if let value {
            _ensureUniqueAndCapacity()
            let __h = _tree.__construct_node((key, value))
            _tree.__insert_node_at(__parent, __child, __h)
          }
        }
        yield &value
      } else {
        _ensureUnique()
        var helper = ___ModifyHelper(pointer: &_tree[__ptr].value)
        defer {
          if helper.isNil {
            _ = _tree.erase(__ptr)
          }
        }
        yield &helper.value
      }
    }
  }

  @inlinable
  public subscript(
    key: Key, default defaultValue: @autoclosure () -> Value
  ) -> Value {
    @inline(__always)
    get { ___value_for(key)?.value ?? defaultValue() }
    @inline(__always)
    _modify {
      defer { _fixLifetime(self) }
      var (__parent, __child, __ptr) = _prepareForKeyingModify(key)
      if __ptr == .nullptr {
        _ensureUniqueAndCapacity()
        assert(_tree.header.capacity > _tree.count)
        __ptr = _tree.__construct_node((key, defaultValue()))
        _tree.__insert_node_at(__parent, __child, __ptr)
      } else {
        _ensureUnique()
      }
      yield &_tree[__ptr].value
    }
  }

  @inlinable
  @inline(__always)
  internal func _prepareForKeyingModify(
    _ key: Key
  ) -> (__parent: _NodePtr, __child: _NodeRef, __ptr: _NodePtr) {
    var __parent = _NodePtr.nullptr
    let __child = _tree.__find_equal(&__parent, key)
    let __ptr = _tree.__ptr_(__child)
    return (__parent, __child, __ptr)
  }
}

extension RedBlackTreeDictionary {

  public var keys: Keys {
    map(\.key)
  }

  public var values: Values {
    map(\.value)
  }
}

extension RedBlackTreeDictionary {

  @discardableResult
  @inlinable
  public mutating func updateValue(
    _ value: Value,
    forKey key: Key
  ) -> Value? {
    _ensureUniqueAndCapacity()
    let (__r, __inserted) = _tree.__insert_unique((key, value))
    guard !__inserted else { return nil }
    let oldMember = _tree[__r]
    _tree[__r] = (key, value)
    return oldMember.value
  }

  @inlinable
  @discardableResult
  public mutating func removeValue(forKey __k: Key) -> Value? {
    let __i = _tree.find(__k)
    if __i == _tree.end() {
      return nil
    }
    let value = _tree.___element(__i).value
    _ensureUnique()
    _ = _tree.erase(__i)
    return value
  }

  @inlinable
  @discardableResult
  public mutating func removeFirst() -> Element {
    guard !isEmpty else {
      preconditionFailure(.emptyFirst)
    }
    return remove(at: startIndex)
  }

  @inlinable
  @discardableResult
  public mutating func removeLast() -> Element {
    guard !isEmpty else {
      preconditionFailure(.emptyLast)
    }
    return remove(at: index(before: endIndex))
  }

  @inlinable
  @discardableResult
  public mutating func remove(at index: Index) -> KeyValue {
    _ensureUnique()
    guard let element = ___remove(at: index.rawValue) else {
      fatalError(.invalidIndex)
    }
    return element
  }

  @inlinable
  @discardableResult
  public mutating func remove(at index: RawIndex) -> KeyValue {
    _ensureUnique()
    guard let element = ___remove(at: index.rawValue) else {
      fatalError(.invalidIndex)
    }
    return element
  }

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

extension RedBlackTreeDictionary {

  @inlinable
  @inline(__always)
  public mutating func remove(contentsOf keyRange: Range<Key>) {
    let lower = lowerBound(keyRange.lowerBound)
    let upper = lowerBound(keyRange.upperBound)
    removeSubrange(lower..<upper)
  }

  @inlinable
  @inline(__always)
  public mutating func remove(contentsOf keyRange: ClosedRange<Key>) {
    let lower = lowerBound(keyRange.lowerBound)
    let upper = upperBound(keyRange.upperBound)
    removeSubrange(lower..<upper)
  }
}

extension RedBlackTreeDictionary {

  @inlinable
  public func lowerBound(_ p: Key) -> Index {
    ___index_lower_bound(p)
  }

  @inlinable
  public func upperBound(_ p: Key) -> Index {
    ___index_upper_bound(p)
  }
}

extension RedBlackTreeDictionary {

  @inlinable
  public var first: Element? {
    isEmpty ? nil : self[startIndex]
  }

  @inlinable
  public var last: Element? {
    isEmpty ? nil : self[index(before: endIndex)]
  }

  @inlinable
  public func first(where predicate: (Element) throws -> Bool) rethrows -> Element? {
    try ___first(where: predicate)
  }

  @inlinable
  public func firstIndex(of key: Key) -> Index? {
    ___first_index(of: key)
  }

  @inlinable
  public func firstIndex(where predicate: (Element) throws -> Bool) rethrows -> Index? {
    try ___first_index(where: predicate)
  }
}

extension RedBlackTreeDictionary: ExpressibleByDictionaryLiteral {

  @inlinable
  public init(dictionaryLiteral elements: (Key, Value)...) {
    self.init(uniqueKeysWithValues: elements)
  }
}

extension RedBlackTreeDictionary: ExpressibleByArrayLiteral {

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
  @inlinable
  public init(arrayLiteral elements: (Key, Value)...) {
    self.init(uniqueKeysWithValues: elements)
  }
}

extension RedBlackTreeDictionary: CustomStringConvertible, CustomDebugStringConvertible {

  // MARK: - CustomStringConvertible

  @inlinable
  public var description: String {
    let pairs = map { "\($0.key): \($0.value)" }
    return "[\(pairs.joined(separator: ", "))]"
  }

  // MARK: - CustomDebugStringConvertible

  @inlinable
  public var debugDescription: String {
    return "RedBlackTreeDictionary(\(description))"
  }
}

// MARK: - Equatable

extension RedBlackTreeDictionary: Equatable where Value: Equatable {

  @inlinable
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.___equal_with(rhs)
  }
}

// MARK: - Sequence, BidirectionalCollection

extension RedBlackTreeDictionary: Sequence {

  @inlinable
  @inline(__always)
  public func forEach(_ body: (Element) throws -> Void) rethrows {
    try _tree.___for_each_(body)
  }

  @frozen
  public struct Iterator: IteratorProtocol {
    @usableFromInline
    internal var _iterator: Tree.Iterator

    @inlinable
    @inline(__always)
    internal init(_base: RedBlackTreeDictionary) {
      self._iterator = _base._tree.makeIterator()
    }

    @inlinable
    @inline(__always)
    public mutating func next() -> Element? {
      return self._iterator.next()
    }
  }

  @inlinable
  @inline(__always)
  public __consuming func makeIterator() -> Iterator {
    return Iterator(_base: self)
  }

  #if false
    @inlinable
    @inline(__always)
    public func enumerated() -> AnySequence<EnumElement> {
      AnySequence { _tree.makeEnumIterator() }
    }
  #else
    @inlinable
    @inline(__always)
    public func enumerated() -> EnumuratedSequence {
      EnumuratedSequence(_subSequence: _tree.enumeratedSubsequence())
    }
  #endif

  @inlinable
  @inline(__always)
  public func indices() -> IndexSequence {
    IndexSequence(_subSequence: _tree.indexSubsequence())
  }
}

extension RedBlackTreeDictionary: BidirectionalCollection {
  
  @inlinable
  @inline(__always)
  public var startIndex: Index {
    ___index_start()
  }
  
  @inlinable
  @inline(__always)
  public var endIndex: Index {
    ___index_end()
  }
  
  @inlinable
  @inline(__always)
  public var count: Int {
    ___count
  }
  
  @inlinable
  @inline(__always)
  public func distance(from start: Index, to end: Index) -> Int {
    ___distance(from: start.rawValue, to: end.rawValue)
  }
  
  @inlinable
  @inline(__always)
  public func index(after i: Index) -> Index {
    ___index(after: i.rawValue)
  }
  
  @inlinable
  @inline(__always)
  public func formIndex(after i: inout Index) {
    ___form_index(after: &i.rawValue)
  }
  
  @inlinable
  @inline(__always)
  public func index(before i: Index) -> Index {
    ___index(before: i.rawValue)
  }
  
  @inlinable
  @inline(__always)
  public func formIndex(before i: inout Index) {
    ___form_index(before: &i.rawValue)
  }
  
  @inlinable
  @inline(__always)
  public func index(_ i: Index, offsetBy distance: Int) -> Index {
    ___index(i.rawValue, offsetBy: distance)
  }
  
  @inlinable
  @inline(__always)
  public func formIndex(_ i: inout Index, offsetBy distance: Int) {
    ___form_index(&i.rawValue, offsetBy: distance)
  }
  
  @inlinable
  @inline(__always)
  public func index(_ i: Index, offsetBy distance: Int, limitedBy limit: Index) -> Index? {
    ___index(i.rawValue, offsetBy: distance, limitedBy: limit.rawValue)
  }
  
  @inlinable
  @inline(__always)
  public func formIndex(_ i: inout Index, offsetBy distance: Int, limitedBy limit: Index)
  -> Bool
  {
    ___form_index(&i.rawValue, offsetBy: distance, limitedBy: limit.rawValue)
  }
  
  @inlinable
  @inline(__always)
  public subscript(position: Index) -> Element {
    return _tree[position.rawValue]
  }
  
  @inlinable
  @inline(__always)
  public subscript(position: RawIndex) -> Element {
    return _tree[position.rawValue]
  }
  
  @inlinable
  public subscript(bounds: Range<Index>) -> SubSequence {
    SubSequence(
      _subSequence:
        _tree.subsequence(
          from: bounds.lowerBound.rawValue,
          to: bounds.upperBound.rawValue)
    )
  }
}

extension RedBlackTreeDictionary {

  // setやmultisetと比べて、驚き最小違反とはいいにくいので、deprecatedには一旦しない
  /// 範囲 `[lower, upper)` に含まれる要素を返します。
  @inlinable
  public subscript(bounds: Range<Key>) -> SubSequence {
    elements(in: bounds)
  }

  // setやmultisetと比べて、驚き最小違反とはいいにくいので、deprecatedには一旦しない
  /// 範囲 `[lower, upper]` に含まれる要素を返します。
  @inlinable
  public subscript(bounds: ClosedRange<Key>) -> SubSequence {
    elements(in: bounds)
  }
}

extension RedBlackTreeDictionary {
  /// キーレンジ `[lower, upper)` に含まれる要素のスライス
  @inlinable
  public func elements(in range: Range<Key>) -> SubSequence {
    SubSequence(
      _subSequence:
        _tree.subsequence(
          from: ___ptr_lower_bound(range.lowerBound),
          to: ___ptr_lower_bound(range.upperBound)))
  }

  /// キーレンジ `[lower, upper]` に含まれる要素のスライス
  @inlinable
  public func elements(in range: ClosedRange<Key>) -> SubSequence {
    SubSequence(
      _subSequence:
        _tree.subsequence(
          from: ___ptr_lower_bound(range.lowerBound),
          to: ___ptr_upper_bound(range.upperBound)))
  }
}

extension RedBlackTreeDictionary {

  @frozen
  public struct SubSequence {

    @usableFromInline
    internal typealias _SubSequence = Tree.SubSequence

    @usableFromInline
    internal let _subSequence: _SubSequence

    @inlinable
    init(_subSequence: _SubSequence) {
      self._subSequence = _subSequence
    }
  }
}

extension RedBlackTreeDictionary.SubSequence {

  public typealias Base = RedBlackTreeDictionary
  public typealias SubSequence = Self
  public typealias Index = Base.Index
  public typealias RawIndex = Base.RawIndex
  public typealias Element = Base.Element
  public typealias EnumuratedSequence = Base.EnumuratedSequence
  public typealias IndexSequence = Base.IndexSequence
}

extension RedBlackTreeDictionary.SubSequence: Sequence {

  public struct Iterator: IteratorProtocol {
    @usableFromInline
    internal var _iterator: _SubSequence.Iterator

    @inlinable
    @inline(__always)
    internal init(_ _iterator: _SubSequence.Iterator) {
      self._iterator = _iterator
    }

    @inlinable
    @inline(__always)
    public mutating func next() -> Element? {
      _iterator.next()
    }
  }

  @inlinable
  @inline(__always)
  public __consuming func makeIterator() -> Iterator {
    Iterator(_subSequence.makeIterator())
  }

  #if false
    @inlinable
    @inline(__always)
    public func enumerated() -> AnySequence<EnumElement> {
      AnySequence {
        tree.makeEnumeratedIterator(start: startIndex.rawValue, end: endIndex.rawValue)
      }
    }
  #else
    @inlinable
    @inline(__always)
    public func enumerated() -> EnumuratedSequence {
      EnumuratedSequence(
        _subSequence: _tree.enumeratedSubsequence(from: startIndex.rawValue, to: endIndex.rawValue))
    }
  #endif

  @inlinable
  @inline(__always)
  public func indices() -> IndexSequence {
    IndexSequence(
      _subSequence: _tree.indexSubsequence(from: startIndex.rawValue, to: endIndex.rawValue))
  }
}

extension RedBlackTreeDictionary.SubSequence: ___RedBlackTreeSubSequenceBase {}

extension RedBlackTreeDictionary.SubSequence: BidirectionalCollection {
  @inlinable
  @inline(__always)
  public var startIndex: Index {
    ___start_index
  }

  @inlinable
  @inline(__always)
  public var endIndex: Index {
    ___end_index
  }

  @inlinable
  @inline(__always)
  public var count: Int {
    ___count
  }

  @inlinable
  @inline(__always)
  public func forEach(_ body: (Element) throws -> Void) rethrows {
    try ___for_each(body)
  }

  @inlinable
  @inline(__always)
  public func distance(from start: Index, to end: Index) -> Int {
    ___distance(from: start, to: end)
  }

  @inlinable
  @inline(__always)
  public func index(after i: Index) -> Index {
    ___index(after: i)
  }

  @inlinable
  @inline(__always)
  public func formIndex(after i: inout Index) {
    ___form_index(after: &i)
  }

  @inlinable
  @inline(__always)
  public func index(before i: Index) -> Index {
    ___index(before: i)
  }

  @inlinable
  @inline(__always)
  public func formIndex(before i: inout Index) {
    ___form_index(before: &i)
  }

  @inlinable
  @inline(__always)
  public func index(_ i: Index, offsetBy distance: Int) -> Index {
    ___index(i, offsetBy: distance)
  }

  @inlinable
  @inline(__always)
  public func formIndex(_ i: inout Index, offsetBy distance: Int) {
    ___form_index(&i, offsetBy: distance)
  }

  @inlinable
  @inline(__always)
  public func index(_ i: Index, offsetBy distance: Int, limitedBy limit: Index) -> Index? {
    ___index(i, offsetBy: distance, limitedBy: limit)
  }

  @inlinable
  @inline(__always)
  public func formIndex(_ i: inout Index, offsetBy distance: Int, limitedBy limit: Index)
    -> Bool
  {
    ___form_index(&i, offsetBy: distance, limitedBy: limit)
  }

  @inlinable
  @inline(__always)
  public subscript(position: Index) -> Element {
    _subSequence[position.rawValue]
  }

  @inlinable
  @inline(__always)
  public subscript(position: RawIndex) -> Element {
    _subSequence[position.rawValue]
  }

  @inlinable
  public subscript(bounds: Range<Index>) -> SubSequence {
    SubSequence(
      _subSequence:
        _subSequence[bounds.lowerBound..<bounds.upperBound])
  }
}

// MARK: - Enumerated Sequence

extension RedBlackTreeDictionary {

  @frozen
  public struct EnumuratedSequence {

    public typealias Enumurated = Tree.Enumerated

    @usableFromInline
    internal typealias _SubSequence = Tree.EnumSequence

    @usableFromInline
    internal let _subSequence: _SubSequence

    @inlinable
    init(_subSequence: _SubSequence) {
      self._subSequence = _subSequence
    }
  }
}

extension RedBlackTreeDictionary.EnumuratedSequence: Sequence {

  public struct Iterator: IteratorProtocol {

    @usableFromInline
    internal var _iterator: _SubSequence.Iterator

    @inlinable
    @inline(__always)
    internal init(_ _iterator: _SubSequence.Iterator) {
      self._iterator = _iterator
    }

    @inlinable
    @inline(__always)
    public mutating func next() -> Enumurated? {
      _iterator.next()
    }
  }

  @inlinable
  @inline(__always)
  public __consuming func makeIterator() -> Iterator {
    Iterator(_subSequence.makeIterator())
  }
}

extension RedBlackTreeDictionary.EnumuratedSequence {

  @inlinable
  @inline(__always)
  public func forEach(_ body: (Enumurated) throws -> Void) rethrows {
    try _subSequence.forEach(body)
  }
}

// MARK: - Index Sequence

extension RedBlackTreeDictionary {

  @frozen
  public struct IndexSequence {

    public typealias RawPointer = Tree.RawPointer

    @usableFromInline
    internal typealias _SubSequence = Tree.IndexSequence

    @usableFromInline
    internal let _subSequence: _SubSequence

    @inlinable
    init(_subSequence: _SubSequence) {
      self._subSequence = _subSequence
    }
  }
}

extension RedBlackTreeDictionary.IndexSequence: Sequence {

  public struct Iterator: IteratorProtocol {

    @usableFromInline
    internal var _iterator: _SubSequence.Iterator

    @inlinable
    @inline(__always)
    internal init(_ _iterator: _SubSequence.Iterator) {
      self._iterator = _iterator
    }

    @inlinable
    @inline(__always)
    public mutating func next() -> RawPointer? {
      _iterator.next()
    }
  }

  @inlinable
  @inline(__always)
  public __consuming func makeIterator() -> Iterator {
    Iterator(_subSequence.makeIterator())
  }
}

extension RedBlackTreeDictionary.IndexSequence {

  @inlinable
  @inline(__always)
  public func forEach(_ body: (RawPointer) throws -> Void) rethrows {
    try _subSequence.forEach(body)
  }
}

// MARK: -

extension RedBlackTreeDictionary {

  @inlinable
  @inline(__always)
  public func isValid(index: Index) -> Bool {
    _tree.___is_valid_index(index.rawValue)
  }

  @inlinable
  @inline(__always)
  public func isValid(index: RawIndex) -> Bool {
    _tree.___is_valid_index(index.rawValue)
  }
}

extension RedBlackTreeDictionary.SubSequence {

  @inlinable
  @inline(__always)
  public func isValid(index i: Index) -> Bool {
    _subSequence.___is_valid_index(index: i.rawValue)
  }

  @inlinable
  @inline(__always)
  public func isValid(index i: RawIndex) -> Bool {
    _subSequence.___is_valid_index(index: i.rawValue)
  }
}

// MARK: -

extension RedBlackTreeDictionary {

  @inlinable
  @inline(__always)
  public mutating func insert(contentsOf other: RedBlackTreeDictionary<Key, Value>) {
    _ensureUniqueAndCapacity(to: count + other.count)
    _tree.__node_handle_merge_unique(other._tree)
  }
}

// MARK: -

extension RedBlackTreeDictionary {

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

extension RedBlackTreeDictionary {

  @inlinable
  public func mapValues<T>(_ transform: (Value) throws -> T) rethrows
    -> RedBlackTreeDictionary<Key, T>
  {
    typealias Tree = RedBlackTreeDictionary<Key, T>.Tree
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
    rethrows -> RedBlackTreeDictionary<Key, T>
  {
    typealias Tree = RedBlackTreeDictionary<Key, T>.Tree
    var tree: Tree = .create(minimumCapacity: count)
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

// MARK: -

extension RedBlackTreeDictionary {

  /// 辞書に `other` の要素をマージします。
  /// キーが重複したときは `combine` の戻り値を採用します。
  @inlinable
  public mutating func merge<S>(
    _ other: __owned S,
    uniquingKeysWith combine: (Value, Value) throws -> Value
  ) rethrows where S: Sequence, S.Element == KeyValue {

    for (k, v) in other {
      if let old = self[k] {
        self[k] = try combine(old, v)
      } else {
        self[k] = v
      }
    }
  }

  /// `self` と `other` をマージした新しい辞書を返します。
  @inlinable
  public func merging<S>(
    _ other: __owned S,
    uniquingKeysWith combine: (Value, Value) throws -> Value
  ) rethrows -> Self where S: Sequence, S.Element == KeyValue {
    var result = self
    try result.merge(other, uniquingKeysWith: combine)
    return result
  }
}

// MARK: -

extension RedBlackTreeDictionary {
  /// 最小キーのペアを取り出して削除
  @inlinable
  public mutating func popFirst() -> KeyValue? {
    guard !isEmpty else { return nil }
    return remove(at: startIndex)
  }
}

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

@frozen
public struct RedBlackTreeDictionary<Key: Comparable, Value> {

  public
    typealias Index = ___RedBlackTree.Index

  public
    typealias KeyValue = (key: Key, value: Value)

  public
    typealias Keys = [Key]

  public
    typealias Values = [Value]

  @usableFromInline
  typealias KeyInfo = ___RedBlackTree.KeyInfo<Key>

  @usableFromInline
  typealias _Key = Key

  @usableFromInline
  var ___header: ___RedBlackTree.___Header

  @usableFromInline
  var ___nodes: [___RedBlackTree.___Node]

  @usableFromInline
  var ___values: [KeyValue]

  @usableFromInline
  var ___stock: Heap<_NodePtr>
}

extension RedBlackTreeDictionary {

  @inlinable @inline(__always)
  public init() {
    ___header = .zero
    ___nodes = []
    ___values = []
    ___stock = []
  }

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

extension RedBlackTreeDictionary {

  @inlinable public init<S>(uniqueKeysWithValues keysAndValues: __owned S)
  where S: Sequence, S.Element == (Key, Value) {
    (
      ___header,
      ___nodes,
      ___values,
      ___stock
    ) = Self.___initialize(
      _sequence: keysAndValues,
      _to_elements: { $0.map { k, v in (k, v) } }
    ) { tree, __k, _, ___construct_node in
      var __parent = _NodePtr.nullptr
      let __child = tree.__find_equal(&__parent, __k.0)
      if tree.__ref_(__child) == .nullptr {
        let __h = ___construct_node(__k)
        tree.__insert_node_at(__parent, __child, __h)
      } else {
        fatalError("Dupricate values for key: '\(__k.0)'")
      }
    }
  }
}

extension RedBlackTreeDictionary {

  @inlinable public init<S>(
    _ keysAndValues: __owned S,
    uniquingKeysWith combine: (Value, Value) throws -> Value
  ) rethrows where S: Sequence, S.Element == (Key, Value) {
    (
      ___header,
      ___nodes,
      ___values,
      ___stock
    ) = try Self.___initialize(
      _sequence: keysAndValues,
      _to_elements: { $0.map { k, v in (k, v) } }
    ) { tree, __k, _values, ___construct_node in
      var __parent = _NodePtr.nullptr
      let __child = tree.__find_equal(&__parent, __k.0)
      if tree.__ref_(__child) == .nullptr {
        let __h = ___construct_node(__k)
        tree.__insert_node_at(__parent, __child, __h)
      } else {
        _values[tree.__ref_(__child)].value = try combine(
          _values[tree.__ref_(__child)].value, __k.value)
      }
    }
  }
}

extension RedBlackTreeDictionary {

  // naive
  @inlinable
  public init<S: Sequence>(
    grouping values_: __owned S,
    by keyForValue: (S.Element) throws -> Key
  ) rethrows where Value == [S.Element] {
    ___header = .zero
    ___nodes = []
    ___values = []
    ___stock = []
    for v in values_ {
      self[try keyForValue(v), default: []].append(v)
    }
  }
}

extension RedBlackTreeDictionary {

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

extension RedBlackTreeDictionary {

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

extension RedBlackTreeDictionary: ValueComparer {

  @inlinable @inline(__always)
  static func __key(_ kv: KeyValue) -> Key { kv.key }

  @inlinable @inline(__always)
  static func __value(_ kv: KeyValue) -> Value { kv.value }

  @inlinable @inline(__always)
  static func value_comp(_ a: Key, _ b: Key) -> Bool {
    KeyInfo.value_comp(a, b)
  }
}

extension RedBlackTreeDictionary: ___RedBlackTreeContainerBase {}

extension RedBlackTreeDictionary: ___RedBlackTreeUpdate {

  @inlinable
  @inline(__always)
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

extension RedBlackTreeDictionary: InsertUniqueProtocol, EraseUniqueProtocol {}

extension RedBlackTreeDictionary {

  @inlinable
  public subscript(key: Key) -> Value? {
    get {
      let (_, _, __ptr) = _prepareForKeyingModify(key)
      return __ptr == .nullptr ? nil : ___values[__ptr].value
    }
    set {
      let (__parent, __child, _) = _prepareForKeyingModify(key)
      _finalizeKeyingModify(__parent, __child, key: key, value: newValue)
    }
    @inline(__always)
    _modify {
      let (__parent, __child, __ptr) = _prepareForKeyingModify(key)
      var value: Value? = __ptr == .nullptr ? nil : ___values[__ptr].value
      defer {
        _finalizeKeyingModify(__parent, __child, key: key, value: value)
      }
      yield &value
    }
  }

  @inlinable
  public subscript(
    key: Key, default defaultValue: @autoclosure () -> Value
  ) -> Value {
    get {
      let (_, _, __ptr) = _prepareForKeyingModify(key)
      return __ptr == .nullptr ? defaultValue() : ___values[__ptr].value
    }
    set {
      let (__parent, __child, _) = _prepareForKeyingModify(key)
      _finalizeKeyingModify(__parent, __child, key: key, value: newValue)
    }
    @inline(__always)
    _modify {
      let (__parent, __child, __ptr) = _prepareForKeyingModify(key)
      var value = __ptr == .nullptr ? defaultValue() : ___values[__ptr].value
      defer {
        _finalizeKeyingModify(__parent, __child, key: key, value: value)
      }
      yield &value
    }
  }

  @inlinable
  internal func _prepareForKeyingModify(
    _ key: Key
  ) -> (__parent: _NodePtr, __child: _NodeRef, __ptr: _NodePtr) {
    _read { tree in
      var __parent = _NodePtr.nullptr
      let __child = tree.__find_equal(&__parent, key)
      let __ptr = tree.__ref_(__child)
      return (__parent, __child, __ptr)
    }
  }

  @inlinable
  mutating func _finalizeKeyingModify(
    _ __parent: _NodePtr, _ __child: _NodeRef, key: Key, value: Value?
  ) {
    let __ptr = __ref_(__child)
    switch (__ptr, value) {
    // 変更前が空で、変更後も空の場合
    case (.nullptr, .none):
      // 変わらない
      break
    // 変更前が空で、変更後は値の場合
    case (.nullptr, .some(let value)):
      // 追加する
      let __h = __construct_node((key, value))
      __insert_node_at(__parent, __child, __h)
      break
    // 変更前が値で、変更後は空の場合
    case (_, .none):
      // 削除する
      _ = erase(__ptr)
      break
    // 変更前が値で、変更後も値の場合
    case (_, .some(let value)):
      // 更新する
      ___values[__ptr].value = value
      break
    }
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

extension RedBlackTreeDictionary: ___RedBlackTreeEraseProtocol {}

extension RedBlackTreeDictionary {

  @discardableResult
  @inlinable
  public mutating func updateValue(
    _ value: Value,
    forKey key: Key
  ) -> Value? {
    let (__r, __inserted) = __insert_unique((key, value))
    return __inserted
      ? nil
      : _read { tree in
        let __p = tree.__ref_(__r)
        let oldMember = ___values[__p]
        ___values[__p] = (key, value)
        return oldMember.value
      }
  }

  @inlinable
  @discardableResult
  public mutating func removeValue(forKey __k: Key) -> Value? {
    let __i = find(__k)
    if __i == end() {
      return nil
    }
    let value = ___values[__i].value
    _ = erase(__i)
    return value
  }

  @inlinable
  @discardableResult
  public mutating func remove(at index: Index) -> KeyValue {
    guard let element = ___remove(at: index.pointer) else {
      fatalError("Attempting to access RedBlackTreeSet elements using an invalid index")
    }
    return element
  }

  @inlinable
  public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
    ___removeAll(keepingCapacity: keepCapacity)
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
    isEmpty ? nil : self[index(before: .end)]
  }

  @inlinable
  public func first(where predicate: (Element) throws -> Bool) rethrows -> Element? {
    try ___element_sequence.first(where: predicate)
  }

  @inlinable
  public func firstIndex(where predicate: (Element) throws -> Bool) rethrows -> Index? {
    try ___enumerated_sequence.first(where: { try predicate($0.element) })?.position
  }
}

extension RedBlackTreeDictionary: ExpressibleByDictionaryLiteral {

  @inlinable public init(dictionaryLiteral elements: (Key, Value)...) {
    self.init(uniqueKeysWithValues: elements)
  }
}

extension RedBlackTreeDictionary: Collection {

  public
    typealias Element = KeyValue

  @inlinable
  @inline(__always)
  public subscript(position: ___RedBlackTree.Index) -> KeyValue {
    ___values[position.pointer]
  }

  @inlinable public func index(before i: Index) -> Index {
    ___index_prev(i, type: "RedBlackTreeDictionary")
  }

  @inlinable public func index(after i: Index) -> Index {
    ___index_next(i, type: "RedBlackTreeDictionary")
  }

  @inlinable public var startIndex: Index {
    ___index_begin()
  }

  @inlinable public var endIndex: Index {
    ___index_end()
  }
}

/// Overwrite Default implementation for bidirectional collections.
extension RedBlackTreeDictionary {

  @inlinable public func index(_ i: Index, offsetBy distance: Int) -> Index {
    ___index(i, offsetBy: distance, type: "RedBlackTreeDictionary")
  }

  @inlinable public func index(_ i: Index, offsetBy distance: Int, limitedBy limit: Index) -> Index?
  {
    ___index(i, offsetBy: distance, limitedBy: limit, type: "RedBlackTreeDictionary")
  }

  /// O(n)
  @inlinable public func distance(from start: Index, to end: Index) -> Int {
    ___distance(__last: end.pointer) - ___distance(__last: start.pointer)
  }
}

extension RedBlackTreeDictionary: CustomStringConvertible, CustomDebugStringConvertible {

  // MARK: - CustomStringConvertible

  /// 人間が読みやすい形式で辞書の内容を文字列として表現します。
  @inlinable
  public var description: String {
    let pairs = map { "\($0.key): \($0.value)" }
    return "[\(pairs.joined(separator: ", "))]"
  }

  // MARK: - CustomDebugStringConvertible

  /// デバッグ時に辞書の詳細情報を含む文字列を返します。
  @inlinable
  public var debugDescription: String {
    return "RedBlackTreeDictionary(\(description))"
  }
}

extension RedBlackTreeDictionary: Equatable where Value: Equatable {

  @inlinable
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.___equal_with(rhs)
  }
}

extension RedBlackTreeDictionary {
  
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

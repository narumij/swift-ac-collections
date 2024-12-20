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

  public init() {
    ___header = .zero
    ___nodes = []
    ___values = []
    ___stock = []
  }

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

  @inlinable public init<S>(uniqueKeysWithValues keysAndValues: S)
  where S: Sequence, S.Element == (Key, Value) {
    // valuesは一旦全部の分を確保する
    var _values: [Element] = keysAndValues.map { ($0.0, $0.1) }
    var _header: ___RedBlackTree.___Header = .zero
    self.___nodes = [___RedBlackTree.___Node](
      unsafeUninitializedCapacity: _values.count
    ) { _nodes, initializedCount in
      withUnsafeMutablePointer(to: &_header) { _header in
        var count = 0
        _values.withUnsafeMutableBufferPointer { _values in
          func ___construct_node(_ __k: Element) -> _NodePtr {
            _nodes[count] = .zero
            // 前方から詰め直している
            _values[count] = __k
            defer { count += 1 }
            return count
          }
          let tree = ___UnsafeMutatingHandle<Self>(
            __header_ptr: _header,
            __node_ptr: _nodes.baseAddress!,
            __value_ptr: _values.baseAddress!)
          var i = 0
          while i < _values.count {
            let __k = _values[i]
            i += 1
            var __parent = _NodePtr.nullptr
            let __child = tree.__find_equal(&__parent, __k.0)
            if tree.__ref_(__child) == .nullptr {
              let __h = ___construct_node(__k)
              tree.__insert_node_at(__parent, __child, __h)
            } else {
              fatalError("Dupricate values for key: '\(__k.0)'")
            }
          }
          initializedCount = count
        }
        // 詰め終わった残りの部分を削除する
        _values.removeLast(_values.count - count)
      }
    }
    self.___header = _header
    self.___values = _values
    self.___stock = []
  }
}

#if false
  // naive
  extension RedBlackTreeDictionary {
    @inlinable public init<S>(uniqueKeysWithValues keysAndValues: S)
    where S: Sequence, S.Element == (Key, Value) {
      self.___header = .zero
      self.___nodes = []
      self.___values = []
      self.___stock = []
      for (k, v) in keysAndValues {
        assert(self[k] == nil)
        self[k] = v
      }
    }
  }
#endif

extension RedBlackTreeDictionary {

  @inlinable public init<S>(
    _ keysAndValues: S,
    uniquingKeysWith combine: (Value, Value) throws -> Value
  ) rethrows where S: Sequence, S.Element == (Key, Value) {
    // valuesは一旦全部の分を確保する
    var _values: [Element] = keysAndValues.map { ($0.0, $0.1) }
    var _header: ___RedBlackTree.___Header = .zero
    self.___nodes = try [___RedBlackTree.___Node](
      unsafeUninitializedCapacity: _values.count
    ) { _nodes, initializedCount in
      try withUnsafeMutablePointer(to: &_header) { _header in
        var count = 0
        try _values.withUnsafeMutableBufferPointer { _values in
          func ___construct_node(_ __k: Element) -> _NodePtr {
            _nodes[count] = .zero
            // 前方から詰め直している
            _values[count] = __k
            defer { count += 1 }
            return count
          }
          let tree = ___UnsafeMutatingHandle<Self>(
            __header_ptr: _header,
            __node_ptr: _nodes.baseAddress!,
            __value_ptr: _values.baseAddress!)
          var i = 0
          while i < _values.count {
            let __k = _values[i]
            i += 1
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
          initializedCount = count
        }
        // 詰め終わった残りの部分を削除する
        _values.removeLast(_values.count - count)
      }
    }
    self.___header = _header
    self.___values = _values
    self.___stock = []
  }
}

#if false
  // naive
  extension RedBlackTreeDictionary {
    @inlinable public init<S>(
      _ keysAndValues: S,
      uniquingKeysWith combine: (Value, Value) throws -> Value
    ) rethrows where S: Sequence, S.Element == (Key, Value) {
      self.___header = .zero
      self.___nodes = []
      self.___values = []
      self.___stock = []
      for (k, v) in keysAndValues {
        self[k] = self[k] == nil ? v : try combine(self[k]!, v)
      }
    }
  }
#endif

extension RedBlackTreeDictionary {

  // naive
  @inlinable
  public init<S: Sequence>(
    grouping values_: __owned S,
    by keyForValue: (S.Element) throws -> Key
  ) rethrows where Value == [S.Element] {
    self.___header = .zero
    self.___nodes = []
    self.___values = []
    self.___stock = []
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

extension RedBlackTreeDictionary: ValueComparer {

  @inlinable
  static func __key(_ kv: KeyValue) -> Key { kv.key }

  @inlinable
  static func __value(_ kv: KeyValue) -> Value { kv.value }

  @inlinable
  static func value_comp(_ a: Key, _ b: Key) -> Bool {
    KeyInfo.value_comp(a, b)
  }
}

extension RedBlackTreeDictionary: ___RedBlackTreeContainerBase, ___UnsafeHandleBase {}

extension RedBlackTreeDictionary: ___UnsafeMutatingHandleBase {

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
    _read {
      var __parent = _NodePtr.nullptr
      let __child = $0.__find_equal(&__parent, key)
      let __ptr = $0.__ref_(__child)
      return (__parent, __child, __ptr)
    }
  }

  @inlinable
  mutating func _finalizeKeyingModify(
    _ __parent: _NodePtr,_ __child: _NodeRef, key: Key, value: Value?
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
      : _read {
        let __p = $0.__ref_(__r)
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
    Index(_read { $0.__lower_bound(p, $0.__root(), .end) })
  }

  @inlinable
  public func upperBound(_ p: Key) -> Index {
    Index(_read { $0.__upper_bound(p, $0.__root(), .end) })
  }
}

extension RedBlackTreeDictionary: ___RedBlackTreeSetContainer {}

extension RedBlackTreeDictionary {

  @inlinable
  func contains(_ p: Key) -> Bool {
    _read {
      let it = $0.__lower_bound(p, $0.__root(), $0.__left_)
      guard it >= 0 else { return false }
      return $0.__value_ptr[it].key == p
    }
  }

  @inlinable
  func min() -> KeyValue? {
    _read {
      let p = $0.__tree_min($0.__root())
      return p == .end ? nil : $0.__value_(p)
    }
  }

  @inlinable
  func max() -> KeyValue? {
    _read {
      let p = $0.__tree_max($0.__root())
      return p == .end ? nil : $0.__value_(p)
    }
  }
}

extension RedBlackTreeDictionary: ExpressibleByDictionaryLiteral {
  public init(dictionaryLiteral elements: (Key, Value)...) {
    self.init(uniqueKeysWithValues: elements)
  }
}

extension RedBlackTreeDictionary: BidirectionalCollection {

  public
    typealias Element = KeyValue

  @inlinable
  @inline(__always)
  public subscript(position: ___RedBlackTree.Index) -> KeyValue {
    ___values[position.pointer]
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
extension RedBlackTreeDictionary {

  @inlinable public func index(_ i: Index, offsetBy distance: Int) -> Index {
    _read {
      Index($0.pointer(i.pointer, offsetBy: distance, type: "RedBlackTreeDictionary"))
    }
  }

  @inlinable public func index(
    _ i: Index, offsetBy distance: Int, limitedBy limit: Index
  ) -> Index? {
    _read {
      Index(
        $0.pointer(
          i.pointer, offsetBy: distance, limitedBy: limit.pointer, type: "RedBlackTreeDictionary"))
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

extension RedBlackTreeDictionary {

  @inlinable mutating func update(at position: Index, _ value: Value) {
    ___values[position.pointer].value = value
  }
}

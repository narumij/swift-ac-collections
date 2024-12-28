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

@frozen
public struct RedBlackTreeDictionary<Key: Comparable, Value> {

  public
    typealias Index = ___RedBlackTree.Index

  public
    typealias IndexRange = ___RedBlackTree.Range

  public
    typealias KeyValue = (key: Key, value: Value)

  public
    typealias Element = KeyValue

  public
    typealias Keys = [Key]

  public
    typealias Values = [Value]

  @usableFromInline
  typealias _Key = Key

  @usableFromInline
  typealias _Value = Value

  @usableFromInline
  var tree: Tree
}

extension RedBlackTreeDictionary: ___RedBlackTreeBase {}
extension RedBlackTreeDictionary: KeyValueComparer {}

extension RedBlackTreeDictionary {

  @inlinable @inline(__always)
  public init() {
    self.init(minimumCapacity: 0)
  }

  @inlinable @inline(__always)
  public init(minimumCapacity: Int) {
    tree = .create(withCapacity: minimumCapacity)
  }
}

extension RedBlackTreeDictionary {

  @inlinable public init<S>(uniqueKeysWithValues keysAndValues: __owned S)
  where S: Sequence, S.Element == (Key, Value) {
    self.init()
    for __k in keysAndValues {
      Tree.ensureCapacity(tree: &tree, minimumCapacity: tree.count + 1)
      var __parent = _NodePtr.nullptr
      let __child = tree.__find_equal(&__parent, __k.0)
      if tree.__ref_(__child) == .nullptr {
        let __h = tree.__construct_node(__k)
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
    self.init()
    for __k in keysAndValues {
      Tree.ensureCapacity(tree: &tree, minimumCapacity: tree.count + 1)
      var __parent = _NodePtr.nullptr
      let __child = tree.__find_equal(&__parent, __k.0)
      if tree.__ref_(__child) == .nullptr {
        let __h = tree.__construct_node(__k)
        tree.__insert_node_at(__parent, __child, __h)
      } else {
        tree[node : tree.__ref_(__child)].__value_.value = try combine(
          tree[node : tree.__ref_(__child)].__value_.value, __k.1)
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
    self.init()
    for v in values_ {
      self[try keyForValue(v), default: []].append(v)
    }
  }
}

extension RedBlackTreeDictionary {

  /// - 計算量: O(1)
  @inlinable
  public var isEmpty: Bool {
    ___isEmpty
  }

  /// - 計算量: O(1)
  @inlinable
  public var count: Int {
    ___count
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
    ensureUniqueAndCapacity(minimumCapacity: minimumCapacity)
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
    get { ___value_for(key)?.value }
    @inline(__always)
    _modify {
      let (__parent, __child, __ptr) = _prepareForKeyingModify(key)
      if __ptr == .nullptr {
        let pointer = UnsafeMutablePointer<Value>.allocate(capacity: 1)
        var helper = ___ModifyHelper(pointer: pointer)
        defer {
          if !helper.isNil {
            ensureUniqueAndCapacity()
            let __h = tree.__construct_node((key, pointer.move()))
            tree.__insert_node_at(__parent, __child, __h)
          }
          pointer.deallocate()
        }
        yield &helper.value
      } else {
        ensureUnique()
        var helper = ___ModifyHelper(pointer: &tree[__ptr].value)
        defer {
          if helper.isNil {
            _ = tree.erase(__ptr)
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
    get { ___value_for(key)?.value ?? defaultValue() }
    @inline(__always)
    _modify {
      var (__parent, __child, __ptr) = _prepareForKeyingModify(key)
      if __ptr == .nullptr {
        ensureUniqueAndCapacity()
        __ptr = tree.__construct_node((key, defaultValue()))
        tree.__insert_node_at(__parent, __child, __ptr)
      } else {
        ensureUnique()
      }
      yield &tree[__ptr].value
    }
  }

  @inlinable
  @inline(__always)
  internal func _prepareForKeyingModify(
    _ key: Key
  ) -> (__parent: _NodePtr, __child: _NodeRef, __ptr: _NodePtr) {
    var __parent = _NodePtr.nullptr
    let __child = tree.__find_equal(&__parent, key)
    let __ptr = tree.__ref_(__child)
    return (__parent, __child, __ptr)
  }
}

extension RedBlackTreeDictionary {

  public var keys: Keys {
    ___element_sequence__(\.key)
  }

  public var values: Values {
    ___element_sequence__(\.value)
  }
}

extension RedBlackTreeDictionary {

  @discardableResult
  @inlinable
  public mutating func updateValue(
    _ value: Value,
    forKey key: Key
  ) -> Value? {
    ensureUniqueAndCapacity()
    let (__r, __inserted) = tree.__insert_unique((key, value))
    guard !__inserted else { return nil }
    let __p = tree.__ref_(__r)
    let oldMember = tree[node : __p].__value_
    tree[node : __p].__value_ = (key, value)
    return oldMember.value
  }

  @inlinable
  @discardableResult
  public mutating func removeValue(forKey __k: Key) -> Value? {
    let __i = tree.find(__k)
    if __i == tree.end() {
      return nil
    }
    let value = tree[node : __i].__value_.value
    ensureUnique()
    _ = tree.erase(__i)
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
    guard let element = ___remove(at: index.pointer) else {
      fatalError(.invalidIndex)
    }
    return element
  }

  @inlinable
  public mutating func removeSubrange(_ range: ___RedBlackTree.Range) {
    ___remove(from: range.lhs.pointer, to: range.rhs.pointer)
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

  @inlinable public init(dictionaryLiteral elements: (Key, Value)...) {
    self.init(uniqueKeysWithValues: elements)
  }
}

extension RedBlackTreeDictionary: Collection {

  @inlinable
  @inline(__always)
  public subscript(position: ___RedBlackTree.Index) -> KeyValue {
    tree[position.pointer]
  }

  @inlinable public func index(before i: Index) -> Index {
    ___index_prev(i)
  }

  @inlinable public func index(after i: Index) -> Index {
    ___index_next(i)
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

  /// fromからtoまでの符号付き距離を返す
  ///
  /// O(*n*)
  @inlinable public func distance(from start: Index, to end: Index) -> Int {
    ___distance(from: start, to: end)
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

extension RedBlackTreeDictionary: Equatable where Value: Equatable {

  @inlinable
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.___equal_with(rhs)
  }
}

extension RedBlackTreeDictionary {

  public typealias ElementSequence = [Element]

  @inlinable
  public subscript(bounds: IndexRange) -> ElementSequence {
    ___element_sequence__(from: bounds.lhs, to: bounds.rhs)
  }
}

extension RedBlackTreeDictionary {

  @inlinable public func map<T>(_ transform: (Element) throws -> T) rethrows -> [T] {
    try ___element_sequence__(from: ___index_begin(), to: ___index_end(), transform: transform)
  }

  @inlinable public func filter(_ isIncluded: (Element) throws -> Bool) rethrows -> [Element] {
    try ___element_sequence__(from: ___index_begin(), to: ___index_end(), isIncluded: isIncluded)
  }

  @inlinable public func reduce<Result>(
    into initialResult: Result, _ updateAccumulatingResult: (inout Result, Element) throws -> Void
  ) rethrows -> Result {
    try ___element_sequence__(
      from: ___index_begin(), to: ___index_end(), into: initialResult, updateAccumulatingResult)
  }

  @inlinable public func reduce<Result>(
    _ initialResult: Result, _ nextPartialResult: (Result, Element) throws -> Result
  ) rethrows -> Result {
    try ___element_sequence__(
      from: ___index_begin(), to: ___index_end(), initialResult, nextPartialResult)
  }
}

extension RedBlackTreeDictionary {

  public typealias EnumeratedElement = (position: Index, element: Element)
  public typealias EnumeratedSequence = [EnumeratedElement]

  @inlinable
  public func enumerated() -> EnumeratedSequence {
    ___enumerated_sequence__
  }

  @inlinable
  public func enumeratedSubrange(_ range: ___RedBlackTree.Range) -> EnumeratedSequence {
    ___enumerated_sequence__(from: range.lhs, to: range.rhs)
  }
}

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
  typealias Index = Tree.TreePointer

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
  
  @inlinable
  @inline(__always)
  var _tree: Tree {
    get { _storage.tree }
    _modify { yield &_storage.tree }
  }
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

  @inlinable public init<S>(uniqueKeysWithValues keysAndValues: __owned S)
  where S: Sequence, S.Element == (Key, Value) {
    self.init()
    for __k in keysAndValues {
      Tree.ensureCapacity(tree: &_tree, minimumCapacity: _tree.count + 1)
      var __parent = _NodePtr.nullptr
      let __child = _tree.__find_equal(&__parent, __k.0)
      if _tree.__ref_(__child) == .nullptr {
        let __h = _tree.__construct_node(__k)
        _tree.__insert_node_at(__parent, __child, __h)
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
      Tree.ensureCapacity(tree: &_tree, minimumCapacity: _tree.count + 1)
      var __parent = _NodePtr.nullptr
      let __child = _tree.__find_equal(&__parent, __k.0)
      if _tree.__ref_(__child) == .nullptr {
        let __h = _tree.__construct_node(__k)
        _tree.__insert_node_at(__parent, __child, __h)
      } else {
        _tree[node: _tree.__ref_(__child)].__value_.value = try combine(
          _tree[node: _tree.__ref_(__child)].__value_.value, __k.1)
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
  public var capacity: Int {
    ___capacity
  }
}

extension RedBlackTreeDictionary {

  @inlinable
  public mutating func reserveCapacity(_ minimumCapacity: Int) {
    _ensureUniqueAndCapacity(minimumCapacity: minimumCapacity)
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
    let __ptr = _tree.__ref_(__child)
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
    let oldMember = _tree[ref: __r]
    _tree[ref: __r] = (key, value)
    return oldMember.value
  }

  @inlinable
  @discardableResult
  public mutating func removeValue(forKey __k: Key) -> Value? {
    let __i = _tree.find(__k)
    if __i == _tree.end() {
      return nil
    }
    let value = _tree[node: __i].__value_.value
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
    guard let element = ___remove(at: index._pointer) else {
      fatalError(.invalidIndex)
    }
    return element
  }

  @inlinable
  public mutating func removeSubrange(_ range: Range<Index>) {
    ___remove(from: range.lowerBound._pointer, to: range.upperBound._pointer)
  }

  @inlinable
  public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
    _ensureUnique()
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
    isEmpty ? nil : self[index(before: .end(_storage))]
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

    @usableFromInline
    let tree: Tree

    @inlinable
    @inline(__always)
    internal init(_base: RedBlackTreeDictionary) {
      self._iterator = _base._tree.makeIterator()
      self.tree = _base._tree
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
  
  @inlinable
  @inline(__always)
  public func enumerated() -> AnySequence<Tree.EnumElement> {
//    AnySequence { tree.makeEnumIterator(lifeStorage: lifeStorage) }
    fatalError()
  }
}

extension RedBlackTreeDictionary: BidirectionalCollection {
  
  @inlinable
  @inline(__always)
  public var startIndex: Index { Index(__storage: _storage, pointer: _tree.startIndex) }

  @inlinable
  @inline(__always)
  public var endIndex: Index { Index(__storage: _storage, pointer: _tree.endIndex) }

  @inlinable
  @inline(__always)
  public var count: Int { _tree.count }
  
  @inlinable
  @inline(__always)
  public func distance(from start: Index, to end: Index) -> Int {
    return _tree.distance(from: start._pointer, to: end._pointer)
  }

  @inlinable
  @inline(__always)
  public func index(after i: Index) -> Index {
    return Index(__storage: _storage, pointer: _tree.index(after: i._pointer))
  }

  @inlinable
  @inline(__always)
  public func formIndex(after i: inout Index) {
    return _tree.formIndex(after: &i._pointer)
  }

  @inlinable
  @inline(__always)
  public func index(before i: Index) -> Index {
    return Index(__storage: _storage, pointer: _tree.index(before: i._pointer))
  }

  @inlinable
  @inline(__always)
  public func formIndex(before i: inout Index) {
    _tree.formIndex(before: &i._pointer)
  }

  @inlinable
  @inline(__always)
  public func index(_ i: Index, offsetBy distance: Int) -> Index {
    return Index(__storage: _storage, pointer: _tree.index(i._pointer, offsetBy: distance))
  }

  @inlinable
  @inline(__always)
  internal func formIndex(_ i: inout Index, offsetBy distance: Int) {
    _tree.formIndex(&i._pointer, offsetBy: distance)
  }

  @inlinable
  @inline(__always)
  public func index(_ i: Index, offsetBy distance: Int, limitedBy limit: Index) -> Index? {

    if let i = _tree.index(i._pointer, offsetBy: distance, limitedBy: limit._pointer) {
      return Index(__storage: _storage, pointer: i)
    } else {
      return nil
    }
  }

  @inlinable
  @inline(__always)
  internal func formIndex(_ i: inout Index, offsetBy distance: Int, limitedBy limit: Self.Index)
    -> Bool
  {
    return _tree.formIndex(&i._pointer, offsetBy: distance, limitedBy: limit._pointer)
  }

  @inlinable
  @inline(__always)
  public subscript(position: Index) -> Element {
    return _tree[position._pointer]
  }

  @inlinable
  @inline(__always)
  public subscript(position: ___RedBlackTree.SimpleIndex) -> Element {
    return _tree[position.rawValue]
  }

  @inlinable
  public subscript(bounds: Range<Index>) -> SubSequence {
    SubSequence(
      _subSequence:
        _tree.subsequence(from: bounds.lowerBound._pointer, to: bounds.upperBound._pointer)
    )
  }
  
  @inlinable
  public subscript(bounds: Range<Key>) -> SubSequence {
    self[lowerBound(bounds.lowerBound) ..< upperBound(bounds.upperBound)]
  }
}

extension RedBlackTreeDictionary {

  @frozen
  public struct SubSequence {

    @usableFromInline
    internal typealias _TreeSubSequence = Tree.SubSequence

    @usableFromInline
    internal typealias _Tree = Tree

    @usableFromInline
    internal let _subSequence: _TreeSubSequence

    @inlinable
    init(_subSequence: _TreeSubSequence) {
      self._subSequence = _subSequence
    }

    @inlinable
    @inline(__always)
    internal var tree: Tree { _subSequence._tree }
  }
}

extension RedBlackTreeDictionary.SubSequence: Sequence {

  @inlinable
  @inline(__always)
  public func forEach(_ body: (Element) throws -> Void) rethrows {
    try tree.___for_each_(__p: startIndex._pointer, __l: endIndex._pointer, body: body)
  }
  
  public typealias Element = RedBlackTreeDictionary.Element
  public typealias EnumeratedElement = RedBlackTreeDictionary.Tree.EnumElement

  public struct Iterator: IteratorProtocol {
    @usableFromInline
    internal var _iterator: _TreeSubSequence.Iterator

    @inlinable
    @inline(__always)
    internal init(_ _iterator: _TreeSubSequence.Iterator) {
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

  @inlinable
  @inline(__always)
  public func enumerated() -> AnySequence<EnumeratedElement> {
//    AnySequence { tree.makeEnumeratedIterator(lifeStorage: lifeStorage, start: startIndex.pointer, end: endIndex.pointer) }
    fatalError()
  }
}

extension RedBlackTreeDictionary.SubSequence: BidirectionalCollection {
  
  public typealias Index = RedBlackTreeDictionary.Index
  public typealias SubSequence = Self

  @inlinable
  @inline(__always)
  public var startIndex: Index { Index(__tree: tree, pointer: _subSequence.startIndex) }

  @inlinable
  @inline(__always)
  public var endIndex: Index { Index(__tree: tree, pointer: _subSequence.endIndex) }

  @inlinable
  @inline(__always)
  public var count: Int { _subSequence.count }
  
  @inlinable
  @inline(__always)
  public func distance(from start: Index, to end: Index) -> Int {
    return _subSequence.distance(from: start._pointer, to: end._pointer)
  }

  @inlinable
  @inline(__always)
  public func index(after i: Index) -> Index {
    return Index(__tree: tree, pointer: _subSequence.index(after: i._pointer))
  }

  @inlinable
  @inline(__always)
  public func formIndex(after i: inout Index) {
    return _subSequence.formIndex(after: &i._pointer)
  }

  @inlinable
  @inline(__always)
  public func index(before i: Index) -> Index {
    return Index(__tree: tree, pointer: _subSequence.index(before: i._pointer))
  }

  @inlinable
  @inline(__always)
  public func formIndex(before i: inout Index) {
    _subSequence.formIndex(before: &i._pointer)
  }

  @inlinable
  @inline(__always)
  public func index(_ i: Index, offsetBy distance: Int) -> Index {
    return Index(__tree: tree, pointer: _subSequence.index(i._pointer, offsetBy: distance))
  }

  @inlinable
  @inline(__always)
  internal func formIndex(_ i: inout Index, offsetBy distance: Int) {
    _subSequence.formIndex(&i._pointer, offsetBy: distance)
  }

  @inlinable
  @inline(__always)
  public func index(_ i: Index, offsetBy distance: Int, limitedBy limit: Index) -> Index? {

    if let i = _subSequence.index(i._pointer, offsetBy: distance, limitedBy: limit._pointer) {
      return Index(__tree: tree, pointer: i)
    } else {
      return nil
    }
  }

  @inlinable
  @inline(__always)
  internal func formIndex(_ i: inout Index, offsetBy distance: Int, limitedBy limit: Self.Index)
    -> Bool
  {
    return _subSequence.formIndex(&i._pointer, offsetBy: distance, limitedBy: limit._pointer)
  }

  @inlinable
  @inline(__always)
  public subscript(position: Index) -> Element {
    return _subSequence[position._pointer]
  }

  @inlinable
  @inline(__always)
  public subscript(position: ___RedBlackTree.SimpleIndex) -> Element {
    return tree[position.rawValue]
  }

  @inlinable
  public subscript(bounds: Range<Index>) -> SubSequence {
    SubSequence(
      _subSequence:
        _subSequence[bounds.lowerBound..<bounds.upperBound])
  }
}

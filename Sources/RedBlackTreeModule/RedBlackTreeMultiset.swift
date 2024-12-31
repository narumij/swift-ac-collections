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

// AC https://atcoder.jp/contests/abc358/submissions/59018223

@frozen
public struct RedBlackTreeMultiset<Element: Comparable> {

  public
    typealias Element = Element
  
  public
    typealias EnumElement = Tree.EnumElement

  public
  typealias Index = Tree.TreePointer

  public
  typealias _Key = Element

  @usableFromInline
  var _storage: Tree.Storage
  
  @inlinable
  @inline(__always)
  var _tree: Tree {
    get { _storage.tree }
    _modify { yield &_storage.tree }
  }
}

extension RedBlackTreeMultiset: ___RedBlackTreeBase {}
extension RedBlackTreeMultiset: ___RedBlackTreeStorageLifetime {}
extension RedBlackTreeMultiset: ScalarValueComparer {}

extension RedBlackTreeMultiset {

  @inlinable @inline(__always)
  public init() {
    self.init(minimumCapacity: 0)
  }

  @inlinable @inline(__always)
  public init(minimumCapacity: Int) {
    _storage = .create(withCapacity: minimumCapacity)
  }
}

extension RedBlackTreeMultiset {

  /// - Complexity: O(*n* log *n*), ここで *n* はシーケンスの要素数。
  @inlinable
  public init<Source>(_ sequence: __owned Source)
  where Element == Source.Element, Source: Sequence {

    self.init()
    for __k in sequence {
      Tree.ensureCapacity(tree: &_tree, minimumCapacity: _tree.count + 1)
      let __h = _tree.__construct_node(__k)
      var __parent = _NodePtr.nullptr
      let __child = _tree.__find_leaf_high(&__parent, __k)
      _tree.__insert_node_at(__parent, __child, __h)
    }
  }
}

extension RedBlackTreeMultiset {

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

extension RedBlackTreeMultiset {

  @inlinable
  public mutating func reserveCapacity(_ minimumCapacity: Int) {
    _ensureUniqueAndCapacity(minimumCapacity: minimumCapacity)
  }
}

extension RedBlackTreeMultiset {

  @inlinable
  @discardableResult
  public mutating func insert(_ newMember: Element) -> (
    inserted: Bool, memberAfterInsert: Element
  ) {
    _ensureUniqueAndCapacity()
    _ = _tree.__insert_multi(newMember)
    return (true, newMember)
  }

  @inlinable
  @discardableResult
  public mutating func remove(_ member: Element) -> Element? {
    _strongEnsureUnique()
    return _tree.___erase_multi(member) != 0 ? member : nil
  }

  @inlinable
  @discardableResult
  public mutating func remove(at index: ___RedBlackTree.RawPointer) -> Element {
    guard let element = ___remove(at: index.rawValue) else {
      fatalError(.invalidIndex)
    }
    return element
  }

  @inlinable
  @discardableResult
  public mutating func remove(at index: Index) -> Element {
    guard let element = ___remove(at: index.rawValue) else {
      fatalError(.invalidIndex)
    }
    return element
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
  public mutating func removeSubrange(_ range: Range<Index>) {
    ___remove(from: range.lowerBound.rawValue, to: range.upperBound.rawValue)
  }

  @inlinable
  public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
    _ensureUnique()
    ___removeAll(keepingCapacity: keepCapacity)
  }
}

extension RedBlackTreeMultiset {

  /// - Complexity: O(*n*), ここで *n* はマルチセット内の要素数。
  @inlinable public func contains(_ member: Element) -> Bool {
    ___contains(member)
  }

  /// - Complexity: O(log *n*), ここで *n* はセット内の要素数。
  @inlinable public func min() -> Element? {
    ___min()
  }

  /// - Complexity: O(log *n*), ここで *n* はセット内の要素数。
  @inlinable public func max() -> Element? {
    ___max()
  }
}

extension RedBlackTreeMultiset: ExpressibleByArrayLiteral {

  /// - Complexity: O(*n* log *n*), ここで *n* は配列リテラル内の要素数。
  @inlinable public init(arrayLiteral elements: Element...) {
    self.init(elements)
  }
}

extension RedBlackTreeMultiset {

  /// - Complexity: O(log *n*), ここで *n* はマルチセット内の要素数。
  @inlinable public func lowerBound(_ member: Element) -> Index {
    ___index_lower_bound(member)
  }

  /// - Complexity: O(log *n*), ここで *n* はマルチセット内の要素数。
  @inlinable public func upperBound(_ member: Element) -> Index {
    ___index_upper_bound(member)
  }
}

extension RedBlackTreeMultiset {

  /// - Complexity: O(1)。
  @inlinable
  public var first: Element? {
    isEmpty ? nil : self[startIndex]
  }

  /// - Complexity: O(1)。
  @inlinable
  public var last: Element? {
    isEmpty ? nil : self[index(before: .end(_storage))]
  }

  @inlinable
  public func first(where predicate: (Element) throws -> Bool) rethrows -> Element? {
    try ___first(where: predicate)
  }

  /// - Complexity: O(log *n*), ここで *n* はセット内の要素数。
  @inlinable
  public func firstIndex(of member: Element) -> Index? {
    ___first_index(of: member)
  }

  /// - Complexity: O(*n*), ここで *n* はセット内の要素数。
  @inlinable
  public func firstIndex(where predicate: (Element) throws -> Bool) rethrows -> Index? {
    try ___first_index(where: predicate)
  }
}

extension RedBlackTreeMultiset {

  @inlinable
  func sorted() -> [Element] {
    _tree.___sorted
  }
}

extension RedBlackTreeMultiset {

  /// - Complexity: O(log *n* + *k*), ここで *n* はマルチセット内の要素数、*k* は指定された要素の出現回数。
  @inlinable public func count(_ element: Element) -> Int {
    _tree.__count_multi(__k: element)
  }
}

extension RedBlackTreeMultiset: CustomStringConvertible, CustomDebugStringConvertible {

  @inlinable
  public var description: String {
    "[\((map {"\($0)"} as [String]).joined(separator: ", "))]"
  }

  @inlinable
  public var debugDescription: String {
    "RedBlackTreeMultiset(\(description))"
  }
}

extension RedBlackTreeMultiset: Equatable {

  @inlinable
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.___equal_with(rhs)
  }
}

extension RedBlackTreeMultiset: Sequence {

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
    internal init(_base: RedBlackTreeMultiset) {
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
    Iterator(_base: self)
  }
  
#if true
  @inlinable
  @inline(__always)
  public func enumerated() -> AnySequence<EnumElement> {
    AnySequence { _tree.makeEnumIterator() }
  }
#else
  @inlinable
  @inline(__always)
  public func enumerated() -> EnumSequence {
    EnumSequence(_subSequence: _storage.enumeratedSubsequence())
  }
#endif
//  @inlinable
//  @inline(__always)
//  public func enumerated() -> AnySequence<Tree.EnumElement> {
////    AnySequence { tree.makeEnumIterator(lifeStorage: lifeStorage) }
//    fatalError()
//  }
}

extension RedBlackTreeMultiset: BidirectionalCollection {
  
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
    return _tree.distance(from: start.rawValue, to: end.rawValue)
  }

  @inlinable
  @inline(__always)
  public func index(after i: Index) -> Index {
    return Index(__storage: _storage, pointer: _tree.index(after: i.rawValue))
  }

  @inlinable
  @inline(__always)
  public func formIndex(after i: inout Index) {
    return _tree.formIndex(after: &i.rawValue)
  }

  @inlinable
  @inline(__always)
  public func index(before i: Index) -> Index {
    return Index(__storage: _storage, pointer: _tree.index(before: i.rawValue))
  }

  @inlinable
  @inline(__always)
  public func formIndex(before i: inout Index) {
    _tree.formIndex(before: &i.rawValue)
  }

  @inlinable
  @inline(__always)
  public func index(_ i: Index, offsetBy distance: Int) -> Index {
    return Index(__storage: _storage, pointer: _tree.index(i.rawValue, offsetBy: distance))
  }

  @inlinable
  @inline(__always)
  internal func formIndex(_ i: inout Index, offsetBy distance: Int) {
    _tree.formIndex(&i.rawValue, offsetBy: distance)
  }

  @inlinable
  @inline(__always)
  public func index(_ i: Index, offsetBy distance: Int, limitedBy limit: Index) -> Index? {

    if let i = _tree.index(i.rawValue, offsetBy: distance, limitedBy: limit.rawValue) {
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
    return _tree.formIndex(&i.rawValue, offsetBy: distance, limitedBy: limit.rawValue)
  }

  @inlinable
  @inline(__always)
  public subscript(position: Index) -> Element {
    return _tree[position.rawValue]
  }

  @inlinable
  @inline(__always)
  public subscript(position: ___RedBlackTree.RawPointer) -> Element {
    return _tree[position.rawValue]
  }

  @inlinable
  public subscript(bounds: Range<Index>) -> SubSequence {
    SubSequence(
      _subSequence:
        _tree.subsequence(from: bounds.lowerBound.rawValue, to: bounds.upperBound.rawValue)
    )
  }
  
  @inlinable
  public subscript(bounds: Range<Element>) -> SubSequence {
    self[lowerBound(bounds.lowerBound) ..< upperBound(bounds.upperBound)]
  }
}


extension RedBlackTreeMultiset {

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

extension RedBlackTreeMultiset.SubSequence: Sequence {

  @inlinable
  @inline(__always)
  public func forEach(_ body: (Element) throws -> Void) rethrows {
    try tree.___for_each_(__p: startIndex.rawValue, __l: endIndex.rawValue, body: body)
  }
  
  public typealias Element = RedBlackTreeMultiset.Element
  public typealias EnumElement = RedBlackTreeMultiset.Tree.EnumElement
//  public typealias EnumeratedElement = RedBlackTreeMultiset.Tree.EnumElement

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

#if true
    @inlinable
    @inline(__always)
    public func enumerated() -> AnySequence<EnumElement> {
      AnySequence { tree.makeEnumeratedIterator(start: startIndex.rawValue, end: endIndex.rawValue) }
    }
  #else
    @inlinable
    @inline(__always)
    public func enumerated() -> EnumSequence {
      EnumSequence(
        _subSequence: tree.enumeratedSubsequence(lifeStorage: lifeStorage, from: startIndex._pointer, to: endIndex._pointer))
    }
  #endif
//  @inlinable
//  @inline(__always)
//  public func enumerated() -> AnySequence<EnumeratedElement> {
////    AnySequence { tree.makeEnumeratedIterator(lifeStorage: lifeStorage, start: startIndex.pointer, end: endIndex.pointer) }
//    fatalError()
//  }
}

extension RedBlackTreeMultiset.SubSequence: BidirectionalCollection {
  
  public typealias Index = RedBlackTreeMultiset.Index
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
    return _subSequence.distance(from: start.rawValue, to: end.rawValue)
  }

  @inlinable
  @inline(__always)
  public func index(after i: Index) -> Index {
    return Index(__tree: tree, pointer: _subSequence.index(after: i.rawValue))
  }

  @inlinable
  @inline(__always)
  public func formIndex(after i: inout Index) {
    return _subSequence.formIndex(after: &i.rawValue)
  }

  @inlinable
  @inline(__always)
  public func index(before i: Index) -> Index {
    return Index(__tree: tree, pointer: _subSequence.index(before: i.rawValue))
  }

  @inlinable
  @inline(__always)
  public func formIndex(before i: inout Index) {
    _subSequence.formIndex(before: &i.rawValue)
  }

  @inlinable
  @inline(__always)
  public func index(_ i: Index, offsetBy distance: Int) -> Index {
    return Index(__tree: tree, pointer: _subSequence.index(i.rawValue, offsetBy: distance))
  }

  @inlinable
  @inline(__always)
  internal func formIndex(_ i: inout Index, offsetBy distance: Int) {
    _subSequence.formIndex(&i.rawValue, offsetBy: distance)
  }

  @inlinable
  @inline(__always)
  public func index(_ i: Index, offsetBy distance: Int, limitedBy limit: Index) -> Index? {

    if let i = _subSequence.index(i.rawValue, offsetBy: distance, limitedBy: limit.rawValue) {
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
    return _subSequence.formIndex(&i.rawValue, offsetBy: distance, limitedBy: limit.rawValue)
  }

  @inlinable
  @inline(__always)
  public subscript(position: Index) -> Element {
    return _subSequence[position.rawValue]
  }

  @inlinable
  @inline(__always)
  public subscript(position: ___RedBlackTree.RawPointer) -> Element {
    return tree[position.rawValue]
  }

  @inlinable
  public subscript(bounds: Range<Index>) -> SubSequence {
    SubSequence(
      _subSequence:
        _subSequence[bounds.lowerBound..<bounds.upperBound])
  }
}


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

// AC https://atcoder.jp/contests/abc358/submissions/59018223

@frozen
public struct RedBlackTreeMultiset<Element: Comparable> {

  public
    typealias Element = Element

  public
    typealias Index = ___RedBlackTree.Index

  public
    typealias IndexRange = ___RedBlackTree.Range

  @usableFromInline
  typealias _Key = Element

  @usableFromInline
  var ___header: ___RedBlackTree.___Header

  @usableFromInline
  var ___nodes: [___RedBlackTree.___Node]

  @usableFromInline
  var ___elements: [Element]
  
  @usableFromInline
  var ___recycle: [_NodePtr]
}

extension RedBlackTreeMultiset: ScalarValueComparer {}
extension RedBlackTreeMultiset: InsertMultiProtocol {}
extension RedBlackTreeMultiset: ___RedBlackTreeInitializeHelper {}
extension RedBlackTreeMultiset: ___RedBlackTreeDefaultAllocator {}
extension RedBlackTreeMultiset: ___RedBlackTreeRemove {}
extension RedBlackTreeMultiset: ___RedBlackTreeMember {}
extension RedBlackTreeMultiset: ___RedBlackTreeInsert {}
extension RedBlackTreeMultiset: ___RedBlackTreeUpdate {

  // プロトコルでupdateが書けなかったため、個別で実装している
  @inlinable
  @inline(__always)
  mutating func _update<R>(_ body: (___UnsafeMutatingHandle<Self>) throws -> R) rethrows -> R {
    return try withUnsafeMutablePointer(to: &___header) { header in
      try ___elements.withUnsafeMutableBufferPointer { elements in
        try ___nodes.withUnsafeMutableBufferPointer { nodes in
          try body(
            ___UnsafeMutatingHandle<Self>(
              __header_ptr: header,
              __node_ptr: nodes.baseAddress!,
              __element_ptr: elements.baseAddress!))
        }
      }
    }
  }
}

extension RedBlackTreeMultiset {

  @inlinable @inline(__always)
  public init() {
    ___header = .zero
    ___nodes = []
    ___elements = []
    ___recycle = []
  }

  @inlinable
  public init(minimumCapacity: Int) {
    ___header = .zero
    ___nodes = []
    ___elements = []
    ___recycle = []
    ___nodes.reserveCapacity(minimumCapacity)
    ___elements.reserveCapacity(minimumCapacity)
  }
}

extension RedBlackTreeMultiset {

  /// - Complexity: O(*n* log *n*), ここで *n* はシーケンスの要素数。
  @inlinable
  public init<Source>(_ sequence: __owned Source)
  where Element == Source.Element, Source: Sequence {
    (
      ___header,
      ___nodes,
      ___elements,
      ___recycle
    ) = Self.___initialize(
      _sequence: sequence,
      _to_elements: { $0.map { $0 } }
    ) { tree, __k, _, __construct_node in
      let __h = __construct_node(__k)
      var __parent = _NodePtr.nullptr
      let __child = tree.__find_leaf_high(&__parent, __k)
      tree.__insert_node_at(__parent, __child, __h)
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
  public var count: Int {
    ___count
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
    ___nodes.reserveCapacity(minimumCapacity)
    ___elements.reserveCapacity(minimumCapacity)
  }
}


extension RedBlackTreeMultiset {

  @inlinable
  @discardableResult
  public mutating func insert(_ newMember: Element) -> (
    inserted: Bool, memberAfterInsert: Element
  ) {
    _ = __insert_multi(newMember)
    return (true, newMember)
  }

  @inlinable
  @discardableResult
  public mutating func remove(_ member: Element) -> Element? {
    ___erase_multi(member) != 0 ? member : nil
  }

  @inlinable
  @discardableResult
  public mutating func remove(at index: Index) -> Element {
    guard let element = ___remove(at: index.pointer) else {
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
  public mutating func removeSubrange(_ range: ___RedBlackTree.Range) {
    ___remove(from: range.lhs.pointer, to: range.rhs.pointer)
  }

  @inlinable
  public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
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
    isEmpty ? nil : self[index(before: .end)]
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
    ___element_sequence__
  }
}

extension RedBlackTreeMultiset: Collection {

  @inlinable public subscript(position: ___RedBlackTree.Index) -> Element {
    ___elements[position.pointer]
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
extension RedBlackTreeMultiset {

  @inlinable public func index(_ i: Index, offsetBy distance: Int) -> Index {
    ___index(i, offsetBy: distance, type: "RedBlackTreeMultiset")
  }

  @inlinable public func index(_ i: Index, offsetBy distance: Int, limitedBy limit: Index) -> Index?
  {
    ___index(i, offsetBy: distance, limitedBy: limit, type: "RedBlackTreeMultiset")
  }

  /// fromからtoまでの符号付き距離を返す
  ///
  /// O(*n*)
  @inlinable public func distance(from start: Index, to end: Index) -> Int {
    ___distance(from: start, to: end)
  }
}

extension RedBlackTreeMultiset {

  /// - Complexity: O(log *n* + *k*), ここで *n* はマルチセット内の要素数、*k* は指定された要素の出現回数。
  @inlinable public func count(_ element: Element) -> Int {
    _read { tree in
      tree.distance(
        __first: tree.__lower_bound(element, tree.__root(), tree.__end_node()),
        __last: tree.__upper_bound(element, tree.__root(), tree.__end_node()))
    }
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

extension RedBlackTreeMultiset {

  public typealias ElementSequence = [Element]

  @inlinable
  public subscript(bounds: IndexRange) -> ElementSequence {
    ___element_sequence__(from: bounds.lhs, to: bounds.rhs)
  }
}

extension RedBlackTreeMultiset {

  @inlinable public func map<T>(_ transform: (Element) throws -> T) rethrows -> [T] {
    try ___element_sequence__(from: ___index_begin(), to: ___index_end(), transform: transform)
  }

  @inlinable public func filter(_ isIncluded: (Element) throws -> Bool) rethrows -> [Element] {
    try ___element_sequence__(from: ___index_begin(), to: ___index_end(), isIncluded: isIncluded)
  }

  @inlinable public func reduce<Result>(
    into initialResult: Result, _ updateAccumulatingResult: (inout Result, Element) throws -> Void
  ) rethrows -> Result {
    try ___element_sequence__(from: ___index_begin(), to: ___index_end(), into: initialResult, updateAccumulatingResult)
  }

  @inlinable public func reduce<Result>(
    _ initialResult: Result, _ nextPartialResult: (Result, Element) throws -> Result
  ) rethrows -> Result {
    try ___element_sequence__(from: ___index_begin(), to: ___index_end(), initialResult, nextPartialResult)
  }
}

extension RedBlackTreeMultiset {

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

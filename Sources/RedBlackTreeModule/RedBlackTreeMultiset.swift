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

// AC https://atcoder.jp/contests/abc358/submissions/59018223

@frozen
public struct RedBlackTreeMultiset<Element: Comparable> {

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
  var stock: Heap<_NodePtr>
}

extension RedBlackTreeMultiset {
  
  @inlinable @inline(__always)
  public init() {
    header = .zero
    nodes = []
    values = []
    stock = []
  }

  @inlinable
  public init(minimumCapacity: Int) {
    header = .zero
    nodes = []
    values = []
    stock = []
    nodes.reserveCapacity(minimumCapacity)
    values.reserveCapacity(minimumCapacity)
  }
}

extension RedBlackTreeMultiset {
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

extension RedBlackTreeMultiset {
  @inlinable
  public mutating func reserveCapacity(_ minimumCapacity: Int) {
    nodes.reserveCapacity(minimumCapacity)
    values.reserveCapacity(minimumCapacity)
  }
}

extension RedBlackTreeMultiset {
  
  @inlinable
  public var count: Int {
    ___count
  }
  
  @inlinable
  public var isEmpty: Bool {
    ___isEmpty
  }
}

extension RedBlackTreeMultiset: ValueComparer {

  @inlinable @inline(__always)
  static func __key(_ e: Element) -> Element { e }

  @inlinable
  static func value_comp(_ a: Element, _ b: Element) -> Bool {
    a < b
  }
}

extension RedBlackTreeMultiset: RedBlackTreeSetContainer {}
extension RedBlackTreeMultiset: _UnsafeHandleBase {}

extension RedBlackTreeMultiset: _UnsafeMutatingHandleBase {

  // プロトコルでupdateが書けなかったため、個別で実装している
  @inlinable
  @inline(__always)
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

extension RedBlackTreeMultiset: InsertMultiProtocol {}
extension RedBlackTreeMultiset: EraseProtocol2 {}

extension RedBlackTreeMultiset: RedBlackTree.SetInternal {}
extension RedBlackTreeMultiset: RedBlackTreeEraseProtocol {}

extension RedBlackTreeMultiset {
  
  @inlinable
  @discardableResult
  public mutating func insert(_ p: Element) -> Bool {
    _ = __insert_multi(p)
    return true
  }

  @inlinable
  @discardableResult
  public mutating func remove(_ p: Element) -> Element? {
    __erase_unique(p) ? p : nil
  }

  @inlinable
  @discardableResult
  public mutating func remove(at index: Index) -> Element {
    remove(at: index.pointer)!
  }
}

extension RedBlackTreeMultiset {

  @inlinable
  public func contains(_ p: Element) -> Bool {
    ___contains(p)
  }
  
  @inlinable
  public func min() -> Element? {
    ___min()
  }
  
  @inlinable
  public func max() -> Element? {
    ___max()
  }
}

extension RedBlackTreeMultiset: ExpressibleByArrayLiteral {
  public init(arrayLiteral elements: Element...) {
    self.init(elements)
  }
}

extension RedBlackTreeMultiset {

  @inlinable
  public func lowerBound(_ p: Element) -> Index {
    Index(___lower_bound(p))
  }

  @inlinable
  public func upperBound(_ p: Element) -> Index {
    Index(___upper_bound(p))
  }
}

extension RedBlackTreeMultiset {

  @inlinable
  public func lessThan(_ p: Element) -> Element? {
    ___lt(p)
  }
  @inlinable
  public func greatorThan(_ p: Element) -> Element? {
    ___gt(p)
  }
  @inlinable
  public func lessEqual(_ p: Element) -> Element? {
    ___le(p)
  }
  @inlinable
  public func greatorEqual(_ p: Element) -> Element? {
    ___ge(p)
  }
}

extension RedBlackTreeMultiset: BidirectionalCollection {

  public subscript(position: RedBlackTree.Index) -> Element {
    self[position.pointer]
  }

  public func index(before i: Index) -> Index {
    Index(_read { $0.__tree_prev_iter(i.pointer) })
  }

  public func index(after i: Index) -> Index {
    Index(_read { $0.__tree_next_iter(i.pointer) })
  }

  public var startIndex: Index {
    Index(___begin())
  }

  public var endIndex: Index {
    Index(___end())
  }
}

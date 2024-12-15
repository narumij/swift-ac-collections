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

@frozen
public struct RedBlackTreeSet<Element: Comparable> {

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
  var stock: Heap<_NodePtr> = []
}

extension RedBlackTreeSet {

  @inlinable @inline(__always)
  public init() {
    header = .zero
    nodes = []
    values = []
  }

  @inlinable @inline(__always)
  public init(minimumCapacity: Int) {
    header = .zero
    nodes = []
    values = []
    nodes.reserveCapacity(minimumCapacity)
    values.reserveCapacity(minimumCapacity)
  }
}

#if false
  // リーク上等のスタンスでカリカリチューニングをしているため、公開には適さない初期化子となっている。
  // その点が修正できれば第一戦に復帰できるが、今のところ目処はない。
  // 将来的に削除する可能性が依然として高い。
  extension RedBlackTreeSet {

    @inlinable @inline(__always)
    public init<S>(_ _a: S) where S: Collection, S.Element == Element {
      var _values: [Element] = _a + []
      var _header: RedBlackTree.___Header = .zero
      self.nodes = [RedBlackTree.___Node](
        unsafeUninitializedCapacity: _values.count
      ) { _nodes, initializedCount in
        withUnsafeMutablePointer(to: &_header) { _header in
          _values.withUnsafeMutableBufferPointer { _values in
            var count = 0
            func ___construct_node(_ __k: Element) -> _NodePtr {
              _nodes[count] = .zero
              _values[count] = __k
              defer { count += 1 }
              return count
            }
            let tree = _UnsafeMutatingHandle<Self>(
              __header_ptr: _header,
              __node_ptr: _nodes.baseAddress!,
              __value_ptr: _values.baseAddress!)
            var i = 0
            while i < _a.count {
              let __k = _values[i]
              i += 1
              var __parent = _NodePtr.nullptr
              let __child = tree.__find_equal(&__parent, __k)
              if tree.__ref_(__child) == .nullptr {
                let __h = ___construct_node(__k)
                tree.__insert_node_at(__parent, __child, __h)
              }
            }
            initializedCount = count
          }
        }
      }
      self.header = _header
      self.values = _values
      self.stock = []
    }
  }
#else
  extension RedBlackTreeSet {
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
#endif

extension RedBlackTreeSet {

  @inlinable
  public mutating func reserveCapacity(_ minimumCapacity: Int) {
    nodes.reserveCapacity(minimumCapacity)
    values.reserveCapacity(minimumCapacity)
  }
}

extension RedBlackTreeSet {

  @inlinable
  public var count: Int {
    ___count
  }

  @inlinable
  public var isEmpty: Bool {
    ___isEmpty
  }
}

extension RedBlackTreeSet: ValueComparer {

  @inlinable @inline(__always)
  static func __key(_ e: Element) -> Element { e }

  @inlinable
  static func value_comp(_ a: Element, _ b: Element) -> Bool {
    a < b
  }
}

extension RedBlackTreeSet: RedBlackTreeSetContainer {}
extension RedBlackTreeSet: _UnsafeHandleBase {}

extension RedBlackTreeSet: _UnsafeMutatingHandleBase {

  // プロトコルでupdateが書けなかったため、個別で実装している
  @inlinable @inline(__always)
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

extension RedBlackTreeSet: InsertUniqueProtocol {}

extension RedBlackTreeSet: RedBlackTreeEraseProtocol {}

extension RedBlackTreeSet: RedBlackTree.SetInternal {}

extension RedBlackTreeSet {

  @inlinable
  @discardableResult
  public mutating func insert(_ p: Element) -> Bool {
    __insert_unique(p).__inserted
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

extension RedBlackTreeSet {

  @inlinable public func contains(_ p: Element) -> Bool {
    ___contains(p)
  }

  @inlinable public func min() -> Element? {
    ___min()
  }

  @inlinable public func max() -> Element? {
    ___max()
  }
}

extension RedBlackTreeSet: ExpressibleByArrayLiteral {
  @inlinable public init(arrayLiteral elements: Element...) {
    self.init(elements)
  }
}

extension RedBlackTreeSet {

  @inlinable public func lowerBound(_ p: Element) -> Index {
    Index(___lower_bound(p))
  }

  @inlinable public func upperBound(_ p: Element) -> Index {
    Index(___upper_bound(p))
  }
}

extension RedBlackTreeSet {

  @inlinable public func lessThan(_ p: Element) -> Element? {
    ___lt(p)
  }
  @inlinable public func greatorThan(_ p: Element) -> Element? {
    ___gt(p)
  }
  @inlinable public func lessEqual(_ p: Element) -> Element? {
    ___le(p)
  }
  @inlinable public func greatorEqual(_ p: Element) -> Element? {
    ___ge(p)
  }
}

extension RedBlackTreeSet: BidirectionalCollection {

  @inlinable public subscript(position: RedBlackTree.Index) -> Element {
    self[position.pointer]
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
extension RedBlackTreeSet {

  /// Replaces the given index with its predecessor.
  ///
  /// - Parameter i: A valid index of the collection. `i` must be greater than
  ///   `startIndex`.
  @inlinable public func formIndex(before i: inout Index) {
    i = Index(_read { $0.__tree_prev_iter(i.pointer) })
  }

  @inlinable public func index(_ i: Index, offsetBy distance: Int) -> Index {
    _read {
      Index($0.pointer(i.pointer, offsetBy: distance))
    }
  }

  @inlinable public func index(
    _ i: Index, offsetBy distance: Int, limitedBy limit: Index
  ) -> Index? {
    _read {
      Index($0.pointer(i.pointer, offsetBy: distance, limitedBy: limit.pointer))
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

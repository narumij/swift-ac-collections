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
    typealias Index = RedBlackTree.Index

  public
    typealias KeyValue = (key: Key, value: Value)

  @usableFromInline
  typealias KeyInfo = RedBlackTree.KeyInfo<Key>

  @usableFromInline
  typealias _Key = Key

  public init() {
    header = .zero
    nodes = []
    values = []
    stock = []
  }

  public subscript(key: Key) -> Value? {
    get {
      _read {
        let it = $0.__lower_bound(key, $0.__root(), $0.__left_)
        guard it >= 0,
          !Self.value_comp(Self.__key($0.__value_ptr[it]), key),
          !Self.value_comp(key, Self.__key($0.__value_ptr[it]))
        else { return nil }
        return Self.__value($0.__value_ptr[it])
      }
    }
    set {
      if let newValue {
        _ = __insert_unique((key, newValue))
      } else {
        _ = __erase_unique(key)
      }
    }
  }

  @usableFromInline
  var header: RedBlackTree.___Header
  @usableFromInline
  var nodes: [RedBlackTree.___Node]
  @usableFromInline
  var values: [KeyValue]
  @usableFromInline
  var stock: Heap<_NodePtr>

  public var count: Int { header.size }
  public var isEmpty: Bool { count == 0 }
}

extension RedBlackTreeDictionary: ValueComparer {

  @inlinable
  static func __key(_ kv: KeyValue) -> Key { kv.0 }

  @inlinable
  static func __value(_ kv: KeyValue) -> Value { kv.1 }

  @inlinable
  static func value_comp(_ a: Key, _ b: Key) -> Bool {
    KeyInfo.value_comp(a, b)
  }
}

extension RedBlackTreeDictionary: RedBlackTreeContainerBase, _UnsafeHandleBase {}

extension RedBlackTreeDictionary: _UnsafeMutatingHandleBase {

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

extension RedBlackTreeDictionary: InsertUniqueProtocol, EraseProtocol {

  @inlinable
  mutating func __construct_node(_ k: KeyValue) -> _NodePtr {
    if let stock = stock.popMin() {
      return stock
    }
    let n = Swift.min(nodes.count, values.count)
    nodes.append(.zero)
    values.append(k)
    return n
  }

  @inlinable
  mutating func destroy(_ p: _NodePtr) {
    stock.insert(p)
  }
}

extension RedBlackTreeDictionary: RedBlackTreeEraseProtocol {}

extension RedBlackTreeDictionary {

  @inlinable
  @discardableResult
  public mutating func remove(_ p: Key) -> Bool {
    __erase_unique(p)
  }

  @inlinable
  @discardableResult
  public mutating func remove(at index: Index) -> KeyValue? {
    remove(at: index.pointer)
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

extension RedBlackTreeDictionary: RedBlackTreeSetContainer {}

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
    self.init()
    for (k, v) in elements {
      self[k] = v
    }
  }
}

extension RedBlackTreeDictionary: BidirectionalCollection {

  public
    typealias Element = KeyValue

  @inlinable public subscript(position: RedBlackTree.Index) -> KeyValue {
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
extension RedBlackTreeDictionary {

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

extension RedBlackTreeDictionary {

  @inlinable mutating func update(at position: Index, _ value: Value) {
    values[position.pointer].value = value
  }
}

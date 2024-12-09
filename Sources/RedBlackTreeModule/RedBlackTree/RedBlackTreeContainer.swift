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
// Copyright © [年] The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.

import Foundation
import Collections

@usableFromInline
protocol RedBlackTreeContainerBase: EndProtocol, ValueComparer {
  associatedtype Element
  var header: RedBlackTree.___Header { get set }
  var nodes: [RedBlackTree.___Node] { get set }
  var values: [Element] { get set }
  var stock: Heap<_NodePtr> { get set }
}

extension RedBlackTreeContainerBase {

  @inlinable
  @inline(__always)
  func _read<R>(_ body: (_UnsafeHandle<Self>) throws -> R) rethrows -> R {
    return try withUnsafePointer(to: header) { header in
      try nodes.withUnsafeBufferPointer { nodes in
        try values.withUnsafeBufferPointer { values in
          try body(
            _UnsafeHandle<Self>(
              __header_ptr: header,
              __node_ptr: nodes.baseAddress!,
              __value_ptr: values.baseAddress!))
        }
      }
    }
  }
}

extension RedBlackTreeContainerBase {

  @inlinable
  public var ___count: Int { header.size }

  @inlinable
  public var ___isEmpty: Bool { header.size == 0 }

  @inlinable
  public func ___begin() -> _NodePtr {
    header.__begin_node
  }

  @inlinable
  public func ___end() -> _NodePtr {
    .end
  }
}

@usableFromInline
protocol RedBlackTreeContainer: RedBlackTreeContainerBase {}

extension RedBlackTreeContainer {

  @inlinable
  public subscript(node: _NodePtr) -> Element {
    values[node]
  }

  @inlinable public subscript(node: _NodePtr, offsetBy distance: Int) -> Element {
    element(node, offsetBy: distance)!
  }

  @inlinable func element(_ ptr: _NodePtr, offsetBy distance: Int) -> Element? {
    let ptr = pointer(ptr, offsetBy: distance)
    return ptr == .end ? nil : values[ptr]
  }

  @inlinable func pointer(_ ptr: _NodePtr, offsetBy distance: Int) -> _NodePtr {
    _read { $0.pointer(ptr, offsetBy: distance) }
  }

  #if DEBUG
    @inlinable
    var elements: [Element] {
      var result: [Element] = []
      var p = header.__begin_node
      _read {
        while p != .end {
          result.append($0.__value_(p))
          p = $0.__tree_next_iter(p)
        }
      }
      return result
    }

    func distance(to ptr: _NodePtr) -> Int {
      _read { $0.distance(to: ptr) }
    }
  #endif
}

@usableFromInline
protocol RedBlackTreeSetContainer: RedBlackTreeContainer {}

extension RedBlackTreeSetContainer {

  @inlinable
  mutating func __construct_node(_ k: Element) -> _NodePtr {
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

@usableFromInline
protocol RedBlackTreeEraseProtocol: RedBlackTreeContainer, EraseProtocol {
  mutating func erase(_ __p: _NodePtr) -> _NodePtr
}

extension RedBlackTreeEraseProtocol {
  @inlinable
  @discardableResult
  public mutating func remove(at ptr: _NodePtr) -> Element? {
    guard ptr != .end else { return nil }
    let e = values[ptr]
    _ = erase(ptr)
    return e
  }
}

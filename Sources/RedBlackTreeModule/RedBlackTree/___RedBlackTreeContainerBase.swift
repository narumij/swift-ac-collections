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

@usableFromInline
protocol ___RedBlackTreeContainerBase: EndProtocol, ValueComparer {
  associatedtype Element
  var ___header: ___RedBlackTree.___Header { get set }
  var ___nodes: [___RedBlackTree.___Node] { get set }
  var ___values: [Element] { get set }
}

extension ___RedBlackTreeContainerBase {

  @inlinable public var ___count: Int {
    ___header.size
  }

  @inlinable public var ___isEmpty: Bool {
    ___header.size == 0
  }

  @inlinable public var ___capacity: Int {
    Swift.min(___values.capacity, ___nodes.capacity)
  }

  @inlinable public func ___begin() -> _NodePtr {
    ___header.__begin_node
  }

  @inlinable public func ___end() -> _NodePtr {
    .end
  }
}

extension ___RedBlackTreeContainerBase {

  @inlinable
  @inline(__always)
  func _read<R>(_ body: (___UnsafeHandle<Self>) throws -> R) rethrows -> R {
    return try withUnsafePointer(to: ___header) { header in
      try ___nodes.withUnsafeBufferPointer { nodes in
        try ___values.withUnsafeBufferPointer { values in
          try body(
            ___UnsafeHandle<Self>(
              __header_ptr: header,
              __node_ptr: nodes.baseAddress!,
              __value_ptr: values.baseAddress!))
        }
      }
    }
  }
}

extension ___RedBlackTreeContainerBase {

  @inlinable
  func __ref_(_ rhs: _NodeRef) -> _NodePtr {
    _read { tree in
      tree.__ref_(rhs) }
  }
  
  @inlinable
  func __find_leaf_high(_ __parent: inout _NodePtr, _ __v: _Key) -> _NodeRef {
    _read { tree in
      tree.__find_leaf_high(&__parent, __v) }
  }

  @inlinable
  func __find_equal(_ __parent: inout _NodePtr, _ __v: _Key) -> _NodeRef {
    _read { tree in
      tree.__find_equal(&__parent, __v) }
  }

  @inlinable
  func find(_ __v: _Key) -> _NodePtr {
    _read { tree in
      tree.find(__v) }
  }
  
  @inlinable
  func
  __equal_range_multi(_ __k: _Key) -> (_NodePtr, _NodePtr) {
    _read { tree in
      tree.__equal_range_multi(__k) }
  }
}

extension ___RedBlackTreeContainerBase {
  
  @inlinable
  @inline(__always)
  func ___for_each(_ body: (Element) throws -> Void) rethrows {
    try _read { tree in
      var ptr = tree.__begin_node
      while ptr != tree.__end_node() {
        try body(___values[ptr])
        ptr = tree.__tree_next_iter(ptr)
      }
    }
  }
  
  @inlinable
  @inline(__always)
  func ___for_each<T>(_ body: (Element) throws -> T?) rethrows -> T? {
    try _read { tree in
      var ptr = tree.__begin_node
      while ptr != tree.__end_node() {
        if let result = try body(___values[ptr]) {
          return result
        }
        ptr = tree.__tree_next_iter(ptr)
      }
      return nil
    }
  }
  
  @inlinable
  @inline(__always)
  func ___for_each<T>(_ body: (_NodePtr, Element) throws -> T?) rethrows -> T? {
    try _read { tree in
      var ptr = tree.__begin_node
      while ptr != tree.__end_node() {
        if let result = try body(ptr, ___values[ptr]) {
          return result
        }
        ptr = tree.__tree_next_iter(ptr)
      }
      return nil
    }
  }
}

extension ___RedBlackTreeContainerBase {
  
  @inlinable @inline(__always)
  func ___contains(_ __k: _Key) -> Bool where _Key: Equatable {
    _read { tree in
      let it = tree.__lower_bound(__k, tree.__root(), tree.__left_)
      guard it >= 0 else { return false }
      return Self.__key(tree.__value_ptr[it]) == __k
    }
  }
  
  @inlinable @inline(__always)
  func ___min() -> Element? {
    _read { tree in
      let p = tree.__tree_min(tree.__root())
      return p == .end ? nil : tree.__value_(p)
    }
  }

  @inlinable @inline(__always)
  func ___max() -> Element? {
    _read { tree in
      let p = tree.__tree_max(tree.__root())
      return p == .end ? nil : tree.__value_(p)
    }
  }
}

extension ___RedBlackTreeContainerBase {

  @inlinable @inline(__always)
  func ___lower_bound(_ __k: _Key) -> _NodePtr {
    _read { tree in
      tree.__lower_bound(__k, tree.__root(), .end)
    }
  }

  @inlinable @inline(__always)
  func ___upper_bound(_ __k: _Key) -> _NodePtr {
    _read { tree in
      tree.__upper_bound(__k, tree.__root(), .end)
    }
  }
}

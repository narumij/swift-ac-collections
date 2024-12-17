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

extension ___RedBlackTree {

  /// メモ化向け
  @frozen
  public struct ___MapBase<KeyInfo, Value>
  where KeyInfo: ___RedBlackTree.KeyProtocol  //, KeyInfo.Key: Equatable
  {

    public
      typealias Key = KeyInfo.Key

    public
      typealias Value = Value

    @usableFromInline
    typealias _Key = Key

    public init() {
      ___header = .zero
      ___nodes = []
      ___values = []
      ___stock = []
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
    var ___header: ___RedBlackTree.___Header
    @usableFromInline
    var ___nodes: [___RedBlackTree.___Node]
    @usableFromInline
    var ___values: [Element]
    @usableFromInline
    var ___stock: Heap<_NodePtr>

    public var count: Int { ___header.size }
    public var isEmpty: Bool { count == 0 }
  }
}

extension ___RedBlackTree.___MapBase: ValueComparer {

  @inlinable
  static func __key(_ kv: (Key, Value)) -> Key { kv.0 }

  @inlinable
  static func __value(_ kv: (Key, Value)) -> Value { kv.1 }

  @inlinable
  static func value_comp(_ a: Key, _ b: Key) -> Bool {
    KeyInfo.value_comp(a, b)
  }
}

extension ___RedBlackTree.___MapBase: RedBlackTreeContainerBase, _UnsafeHandleBase {}

extension ___RedBlackTree.___MapBase: _UnsafeMutatingHandleBase {

  @inlinable
  @inline(__always)
  mutating func _update<R>(_ body: (_UnsafeMutatingHandle<Self>) throws -> R) rethrows -> R {
    return try withUnsafeMutablePointer(to: &___header) { header in
      try ___nodes.withUnsafeMutableBufferPointer { nodes in
        try ___values.withUnsafeMutableBufferPointer { values in
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

extension ___RedBlackTree.___MapBase: InsertUniqueProtocol, EraseProtocol {

  @inlinable
  mutating func __construct_node(_ k: (Key, Value)) -> _NodePtr {
    if let stock = ___stock.popMin() {
      return stock
    }
    let n = Swift.min(___nodes.count, ___values.count)
    ___nodes.append(.zero)
    ___values.append(k)
    return n
  }

  @inlinable
  mutating func destroy(_ p: _NodePtr) {
    ___stock.insert(p)
  }
}

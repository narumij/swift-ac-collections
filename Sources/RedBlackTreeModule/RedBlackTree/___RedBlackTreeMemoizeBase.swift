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

/// メモ化向け
///
///  メモリ管理をゆるめにしている
@frozen
public struct ___RedBlackTreeMemoizeBase<KeyInfo, Value>
where KeyInfo: ___RedBlackTreeKeyProtocol  //, KeyInfo.Key: Equatable
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
  }

  public subscript(key: Key) -> Value? {
    get {
      _read { tree in
        let it = tree.__lower_bound(key, tree.__root(), tree.__left_)
        guard it >= 0,
          !Self.value_comp(Self.__key(tree.__value_ptr[it]), key),
          !Self.value_comp(key, Self.__key(tree.__value_ptr[it]))
        else { return nil }
        return Self.__value(tree.__value_ptr[it])
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

  public var count: Int { ___header.size }
  public var isEmpty: Bool { count == 0 }
}

extension ___RedBlackTreeMemoizeBase: ValueComparer {

  @inlinable
  static func __key(_ kv: (Key, Value)) -> Key { kv.0 }

  @inlinable
  static func __value(_ kv: (Key, Value)) -> Value { kv.1 }

  @inlinable
  static func value_comp(_ a: Key, _ b: Key) -> Bool {
    KeyInfo.value_comp(a, b)
  }
}

extension ___RedBlackTreeMemoizeBase: ___RedBlackTreeContainerBase {}

extension ___RedBlackTreeMemoizeBase: ___RedBlackTreeUpdate {

  @inlinable
  @inline(__always)
  mutating func _update<R>(_ body: (___UnsafeMutatingHandle<Self>) throws -> R) rethrows -> R {
    return try withUnsafeMutablePointer(to: &___header) { header in
      try ___nodes.withUnsafeMutableBufferPointer { nodes in
        try ___values.withUnsafeMutableBufferPointer { values in
          try body(
            ___UnsafeMutatingHandle<Self>(
              __header_ptr: header,
              __node_ptr: nodes.baseAddress!,
              __value_ptr: values.baseAddress!))
        }
      }
    }
  }
}

extension ___RedBlackTreeMemoizeBase: InsertUniqueProtocol, EraseUniqueProtocol {

  @inlinable
  mutating func __construct_node(_ k: (Key, Value)) -> _NodePtr {
    let n = Swift.min(___nodes.count, ___values.count)
    ___nodes.append(.zero)
    ___values.append(k)
    return n
  }

  @inlinable
  mutating func destroy(_ p: _NodePtr) {
    ___nodes[p].invalidate()
  }
}

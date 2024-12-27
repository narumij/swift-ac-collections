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
public struct ___RedBlackTreeMemoizeBase<CustomKey, Value>
where CustomKey: CustomKeyProtocol
{

  public
    typealias Key = CustomKey.Key

  public
    typealias Value = Value

  public
    typealias KeyValue = (key: Key, value: Value)
  
  public
  typealias Element = KeyValue

  @usableFromInline
  typealias _Key = Key
  
  @usableFromInline
  typealias _Value = Value

  public init() {
    ___header = .zero
    ___nodes = []
    ___elements = []
  }

  public subscript(key: Key) -> Value? {
    get { ___value_for(key)?.value }
    set {
      if let newValue {
        _ = __insert_unique((key, newValue))
      } else {
        _ = ___erase_unique(key)
      }
    }
  }

  @usableFromInline
  var ___header: ___RedBlackTree.___Header
  @usableFromInline
  var ___nodes: [___RedBlackTree.___Node]
  @usableFromInline
  var ___elements: [Element]

  public var count: Int { ___header.size }
  public var isEmpty: Bool { count == 0 }
}

extension ___RedBlackTreeMemoizeBase: ___RedBlackTreeUpdate {

  @inlinable
  @inline(__always)
  mutating func _update<R>(_ body: (___UnsafeMutatingHandle<Self>) throws -> R) rethrows -> R {
    return try withUnsafeMutablePointer(to: &___header) { header in
      try ___nodes.withUnsafeMutableBufferPointer { nodes in
        try ___elements.withUnsafeMutableBufferPointer { values in
          try body(
            ___UnsafeMutatingHandle<Self>(
              __header_ptr: header,
              __node_ptr: nodes.baseAddress!,
              __element_ptr: values.baseAddress!))
        }
      }
    }
  }
}

extension ___RedBlackTreeMemoizeBase: ___RedBlackTreeLeakingAllocator {}
extension ___RedBlackTreeMemoizeBase: ___RedBlackTreeCustomKeyProtocol {}
extension ___RedBlackTreeMemoizeBase: ___RedBlackTreeContainerBase {}
extension ___RedBlackTreeMemoizeBase: ___RedBlackTreeMember {}
extension ___RedBlackTreeMemoizeBase: ___RedBlackTreeInsert {}
extension ___RedBlackTreeMemoizeBase: ___RedBlackTreeErase {}

extension ___RedBlackTreeMemoizeBase: InsertUniqueProtocol {}


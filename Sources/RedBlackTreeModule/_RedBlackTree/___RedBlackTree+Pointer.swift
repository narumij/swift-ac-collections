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

extension ___RedBlackTree.___Tree {

  public struct TreePointer: Comparable {

    public typealias Pointer = Self

    @inlinable
    internal static func rank(_ rhs: Pointer) -> Int {
      //      rhs.pointer != .end ? rhs.pointer : Int.max
      switch rhs.pointer {
      case .nullptr: return 3
      case .end: return 2
      default: return 1
      }
    }

    public static func < (lhs: Pointer, rhs: Pointer) -> Bool {

      if lhs.pointer == rhs.pointer {
        return false
      }

      guard rank(lhs) == rank(rhs) else {
        return rank(lhs) < rank(rhs)
      }

      return with(lhs.tree) { tree in
        return tree.value_comp(tree[key: lhs.pointer], tree[key: rhs.pointer])
      }
    }

    public static func == (lhs: Pointer, rhs: Pointer) -> Bool {
      lhs.pointer == rhs.pointer
    }

    @inlinable
    internal init(__tree: Tree.Manager, pointer: _NodePtr) {
      guard pointer != .nullptr else {
        preconditionFailure("_NodePtr is nullptr")
      }
      self.tree = __tree
      self.pointer = pointer
    }

    @usableFromInline
    let tree: Tree.Manager

    @usableFromInline
    var pointer: _NodePtr

    @inlinable
    public var rawValue: Int {
      pointer
    }

    @inlinable
    public var isNullptr: Bool {
      pointer == .nullptr
    }

    @inlinable
    public var isEnd: Bool {
      pointer == .end
    }

    @inlinable
    public var ___pointee: Element {
      Tree.with(tree) { $0[pointer] }
    }

    @inlinable
    static func end(_ tree: Tree.Manager) -> Pointer {
      .init(__tree: tree, pointer: .end)
    }

    @inlinable
    public mutating func ___next() {
      pointer = Tree.with(tree) { $0.__tree_next_iter(pointer) }
    }

    @inlinable
    public mutating func ___prev() {
      pointer = Tree.with(tree) { $0.__tree_prev_iter(pointer) }
    }
  }
}

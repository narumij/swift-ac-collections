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
      
      return lhs.tree.value_comp(lhs.tree[key: lhs.pointer], rhs.tree[key: rhs.pointer])
    }
    
    public static func == (lhs: Pointer, rhs: Pointer) -> Bool {
      lhs.pointer == rhs.pointer
    }
    
    @inlinable
    internal init(__tree: Tree, pointer: _NodePtr) {
      guard pointer != .nullptr else {
        preconditionFailure("_NodePtr is nullptr")
      }
      self.tree = __tree
      self.pointer = pointer
    }
    
    // 性能の面でunownedを選択することにした。このためSendableには適合できない
    @usableFromInline
    unowned let tree: Tree
    
    @usableFromInline
    var pointer: _NodePtr
    
    // これを公開にすると、リテインが必要な使い方を奨励してしまう
    @inlinable
    var pointee: Element {
      get { tree[pointer] }
      _modify { yield &tree[pointer] }
    }

    @inlinable
    internal static func end(_ tree: Tree) -> Pointer {
      .init(__tree: tree, pointer: tree.__end_node())
    }
    
    // これを公開にすると、リテインが必要な使い方を奨励してしまう
    @inlinable
    internal func ___next() -> Pointer {
      .init(__tree: tree, pointer: tree.__tree_next(pointer))
    }

    // これを公開にすると、リテインが必要な使い方を奨励してしまう
    @inlinable
    internal func ___prev() -> Pointer {
      .init(__tree: tree, pointer: tree.__tree_prev_iter(pointer))
    }
  }
}

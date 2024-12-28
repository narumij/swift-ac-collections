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

extension ___RedBlackTree {
  
  public struct TreePointer<Base: ValueComparer>: Comparable {

    public typealias Tree = ___RedBlackTree.___Buffer<Base>
    public typealias Pointer = Self
    
    @inlinable
    internal static func rank(_ rhs: Pointer) -> Int {
      rhs.pointer != .end ? rhs.pointer : Int.max
    }
    
    public static func < (lhs: Pointer, rhs: Pointer) -> Bool {
      
      if lhs.pointer == rhs.pointer {
        return false
      }
      
      guard rank(lhs) == rank(rhs) else {
        return rank(lhs) < rank(rhs)
      }
      
      return lhs.tree.distance(__l: lhs.pointer, __r: rhs.pointer) < 0
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
    
    // retainすると死ぬほど遅い場面がある。
    // しばらく悩むことにする
    @usableFromInline
    unowned let tree: ___RedBlackTree.___Buffer<Base>
    
    @usableFromInline
    let pointer: _NodePtr
    
    @inlinable
    public var pointee: Base.Element {
      get { tree[pointer] }
      _modify { yield &tree[pointer] }
    }

    @inlinable
    internal static func end(_ tree: Tree) -> Pointer {
      .init(__tree: tree, pointer: tree.__end_node())
    }
    
    @inlinable
    public func ___next() -> Pointer {
      .init(__tree: tree, pointer: tree.__tree_next(pointer))
    }

    @inlinable
    public func ___prev() -> Pointer {
      .init(__tree: tree, pointer: tree.__tree_prev_iter(pointer))
    }
  }
}

//extension Range: Sequence where Bound == ___RedBlackTree.TreePointer<Any> {
//  
//}




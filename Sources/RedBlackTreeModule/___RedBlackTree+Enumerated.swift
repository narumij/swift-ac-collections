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
  
  public typealias EnumeratedElement = (offset: TreePointer, element: Element)
  
  public struct EnumeratedIterator: IteratorProtocol {
    
    @inlinable
    internal init(tree: Tree) {
      self.init(tree: tree, start: tree.__begin_node, end: tree.__end_node())
    }
    
    @inlinable
    internal init(tree: Tree, start: _NodePtr, end: _NodePtr) {
      self.tree = tree
      self.current = start
      self.end = end
    }
    
    @usableFromInline
    unowned let tree: Tree
    
    @usableFromInline
    var current, end: _NodePtr
    
    @inlinable
    @inline(__always)
    public mutating func next() -> EnumeratedElement?
    {
      guard current != end else { return nil }
      defer { current = tree.__tree_next(current) }
      return (TreePointer(__tree: tree, pointer: current), tree[current])
    }
  }
}

extension ___RedBlackTree.___Tree {
  
  @inlinable
  public func makeEnumeratedIterator() -> EnumeratedIterator {
    makeEnumeratedIterator(start: __begin_node, end: __end_node())
  }
  
  @inlinable
  public func makeEnumeratedIterator(start: _NodePtr, end: _NodePtr) -> EnumeratedIterator {
    .init(tree: self, start: start, end: end)
  }
}

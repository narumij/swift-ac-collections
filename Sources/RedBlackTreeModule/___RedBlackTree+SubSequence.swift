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

public protocol ___Tree: ValueComparer {
  init(___tree: Tree)
  func ___makeIterator(startIndex: ___Pointer, endIndex: ___Pointer) -> ___Iterator
}

extension ___Tree {
  public typealias ___Pointer = ___RedBlackTree.TreePointer<Self>
  public typealias ___Iterator = ___RedBlackTree.Iterator<Self>
  public typealias ___SubSequence = ___RedBlackTree.SubSequence<Self>
}

extension ___RedBlackTree {

  public struct SubSequence<Base>
  where Base: ___Tree {
    
    @inlinable
    init(_subSequence: ___RedBlackTree.SubSequence<Base>._Tree.___SubSequence) {
      self._subSequence = _subSequence
    }

    public typealias _Tree = ___RedBlackTree.___Buffer<Base>

    public typealias Index = ___RedBlackTree.TreePointer<Base>

    public typealias Element = Base.Element
    
    public typealias Base = Base

    @usableFromInline
    internal let _subSequence: _Tree.___SubSequence
    public
      var startIndex: Index
    { Index(__tree: _subSequence.base, pointer: _subSequence.startIndex) }
    public
      var endIndex: Index
    { Index(__tree: _subSequence.base, pointer: _subSequence.endIndex) }

    @inlinable
    @inline(__always)
    internal var base: Base { Base(___tree: _subSequence.base) }
  }
}

extension ___RedBlackTree.SubSequence: Sequence {
  
  @usableFromInline
  var _tree: _Tree { _subSequence.base }

  @inlinable
  public func makeIterator() -> ___RedBlackTree.Iterator<Base> {
    .init(_tree.makeIterator(start: startIndex.pointer, end: endIndex.pointer))
  }
}

extension ___RedBlackTree.SubSequence: Collection {
  
  public func index(after i: Index) -> Index {
    i.___next()
  }
  
  public subscript(position: Index) -> Base.Element {
    position.pointee
  }
  
  // この実装がないと、迷子になる
  @inlinable
  public func distance(from start: Index, to end: Index) -> Int {
    _subSequence.distance(from: start.pointer, to: end.pointer)
  }
}

extension ___RedBlackTree.SubSequence: BidirectionalCollection {
  
  public func index(before i: Index) -> Index {
    i.___prev()
  }
}

extension ___RedBlackTreeBase {
  
//  public func ___makeIterator(startIndex: ___RedBlackTree.SimpleIndex, endIndex: ___RedBlackTree.SimpleIndex) -> ___RedBlackTree.Iterator<Self> {
//    .init(tree.makeIterator(start: startIndex.pointer, end: endIndex.pointer))
//  }
  
  public func ___makeIterator(startIndex: ___RedBlackTree.TreePointer<Self>, endIndex: ___RedBlackTree.TreePointer<Self>) -> ___RedBlackTree.Iterator<Self> {
    .init(tree.makeIterator(start: startIndex.pointer, end: endIndex.pointer))
  }

}

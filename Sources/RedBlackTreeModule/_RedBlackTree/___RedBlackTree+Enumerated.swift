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

@usableFromInline
protocol RawPointerBuilderProtocol {}

extension RawPointerBuilderProtocol {

  @usableFromInline
  internal typealias Index = ___RedBlackTree.RawPointer

  @inlinable
  @inline(__always)
  internal func ___index(_ p: _NodePtr) -> Index {
    .init(p)
  }
}

#if false
@usableFromInline
protocol TreePointerBuilderProtocol {
  associatedtype VC: ValueComparer
  var _tree: Tree { get }
}

extension TreePointerBuilderProtocol {
  @usableFromInline
  internal typealias Tree = ___RedBlackTree.___Tree<VC>
  
  @usableFromInline
  internal typealias Index = ___RedBlackTree.___Tree<VC>.Pointer

  @inlinable
  @inline(__always)
  internal func ___index(_ p: _NodePtr) -> Index {
    .init(__tree: _tree, pointer: p)
  }
}
#endif

extension ___RedBlackTree.___Tree {
  
  #if true
    typealias EnumIndexMaker = RawPointerBuilderProtocol
    public typealias EnumuratedIndex = ___RedBlackTree.RawPointer
  #else
    typealias EnumIndexMaker = TreePointerBuilderProtocol
    public typealias EnumIndex = TreePointer
  #endif

  public typealias Enumerated = (offset: EnumuratedIndex, element: Element)

  @frozen
  public struct EnumIterator: RedBlackTreeIteratorNextProtocol, EnumIndexMaker {

    @inlinable
    @inline(__always)
    internal init(tree: Tree, start: _NodePtr, end: _NodePtr) {
      self._tree = tree
      self._current = start
      self._end = end
      self._next = start == .end ? .end : tree.__tree_next(start)
    }

    @usableFromInline
    let _tree: Tree

    @usableFromInline
    var _current, _next, _end: _NodePtr

    @inlinable
    @inline(__always)
    public mutating func next() -> Enumerated? {
      _next().map { (___index($0), _tree[$0]) }
    }
  }
}

extension ___RedBlackTree.___Tree {

  // AnySequence用
  @inlinable
  __consuming func makeEnumIterator() -> EnumIterator {
    .init(tree: self, start: __begin_node, end: __end_node())
  }

  @inlinable
  __consuming func makeEnumeratedIterator(start: _NodePtr, end: _NodePtr) -> EnumIterator {
    .init(tree: self, start: start, end: end)
  }
}

extension ___RedBlackTree.___Tree {

  @frozen
  public struct EnumSequence: Sequence, EnumIndexMaker {

    public typealias Element = Tree.Enumerated
    
    @usableFromInline
    typealias Index = _NodePtr

    @inlinable
    init(tree: Tree, start: Index, end: Index) {
      self._tree = tree
      self.startIndex = start
      self.endIndex = end
    }

    @usableFromInline
    let _tree: Tree

    @usableFromInline
      var startIndex: Index

    @usableFromInline
      var endIndex: Index

    @inlinable
    public func makeIterator() -> EnumIterator {
      _tree.makeEnumeratedIterator(start: startIndex, end: endIndex)
    }
  }
}

extension ___RedBlackTree.___Tree {

  @inlinable
  internal func enumeratedSubsequence() -> EnumSequence {
    .init(tree: self, start: __begin_node, end: __end_node())
  }

  @inlinable
  internal func enumeratedSubsequence(from: _NodePtr, to: _NodePtr) -> EnumSequence {
    .init(tree: self, start: from, end: to)
  }
}

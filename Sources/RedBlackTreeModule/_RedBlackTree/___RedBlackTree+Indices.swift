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

  @frozen
  public struct IndexIterator: RawPointerBuilderProtocol, RedBlackTreeIteratorNextProtocol {

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
    public mutating func next() -> RawPointer? {
      _next().map { .init($0) }
    }
  }
}

extension ___RedBlackTree.___Tree {

  @inlinable
  __consuming func makeIndexIterator(start: _NodePtr, end: _NodePtr) -> IndexIterator {
    .init(tree: self, start: start, end: end)
  }
}

extension ___RedBlackTree.___Tree {

  @frozen
  public struct IndexSequence: Sequence {

    public typealias Element = Tree.RawPointer

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
    public func makeIterator() -> IndexIterator {
      _tree.makeIndexIterator(start: startIndex, end: endIndex)
    }

    @inlinable
    @inline(__always)
    internal func forEach(_ body: (Element) throws -> Void) rethrows {
      var __p = startIndex
      while __p != endIndex {
        let __c = __p
        __p = _tree.__tree_next(__p)
        try body(.init(__c))
      }
    }
  }
}

extension ___RedBlackTree.___Tree {

  @inlinable
  internal func indexSubsequence() -> IndexSequence {
    .init(tree: self, start: __begin_node, end: __end_node())
  }

  @inlinable
  internal func indexSubsequence(from: _NodePtr, to: _NodePtr) -> IndexSequence {
    .init(tree: self, start: from, end: to)
  }
}

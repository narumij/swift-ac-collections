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
protocol SimpleIndexBuilder { }

extension SimpleIndexBuilder {
  
  public typealias EnumeratedIndex = ___RedBlackTree.SimpleIndex
  
  @inlinable
  @inline(__always)
  public func ___index(_ p: _NodePtr) -> EnumeratedIndex {
    .init(p)
  }
}

@usableFromInline
protocol TreePointerBuilder {
  associatedtype VC: ValueComparer
  var _tree: Tree { get }
}

extension TreePointerBuilder {
  public typealias Tree = ___RedBlackTree.___Tree<VC>
  public typealias EnumeratedIndex = ___RedBlackTree.___Tree<VC>.TreePointer
  
  @inlinable
  @inline(__always)
  public func ___index(_ p: _NodePtr) -> EnumeratedIndex {
    .init(__tree: _tree, pointer: p)
  }
}

extension ___RedBlackTree.___Tree {

#if true
  typealias EnumIndexMaker = SimpleIndexBuilder
  public typealias EnumIndex = ___RedBlackTree.SimpleIndex
#else
  typealias EnumIndexMaker = TreePointerBuilder
  public typealias EnumIndex = TreePointer
#endif

  public typealias EnumElement = (offset: EnumIndex, element: Element)
  
  @frozen
  public struct EnumIterator: RedBlackTreeIteratorNextProtocol, EnumIndexMaker {
    
    @inlinable
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
    public mutating func next() -> EnumElement? {
      _next().map { (___index($0), _tree[$0]) }
    }
  }
}

extension ___RedBlackTree.___Tree {
  
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

    public typealias Element = Tree.EnumElement
    public typealias Index = _NodePtr

    @inlinable
    init(tree: Tree, start: Index, end: Index) {
      self._tree = tree
      self.startIndex = start
      self.endIndex = end
    }

    @usableFromInline
    let _tree: Tree
    
    public
      var startIndex: Index
    
    public
      var endIndex: Index

    @inlinable
    public func makeIterator() -> EnumIterator {
      _tree.makeEnumeratedIterator(start: startIndex, end: endIndex)
    }
    
    @inlinable
    @inline(__always)
    public var count: Int {
      _tree.distance(from: startIndex, to: endIndex)
    }
    
    @inlinable
    @inline(__always)
    public func forEach(_ body: (Element) throws -> Void) rethrows {
      var __p = startIndex
      while __p != endIndex {
        let __c = __p
        __p = _tree.__tree_next(__p)
        try body((___index(__c), _tree[__c]))
      }
    }
    
    // この実装がないと、迷子になる
    @inlinable
    @inline(__always)
    public func distance(from start: Index, to end: Index) -> Int {
      _tree.distance(from: start, to: end)
    }
    
    @inlinable
    @inline(__always)
    public func index(after i: Index) -> Index {
      _tree.index(after: i)
    }
    
    @inlinable
    @inline(__always)
    public func formIndex(after i: inout Index) {
      _tree.formIndex(after: &i)
    }
    
    @inlinable
    @inline(__always)
    public func index(before i: Index) -> Index {
      _tree.index(before: i)
    }
    
    @inlinable
    @inline(__always)
    public func formIndex(before i: inout Index) {
      _tree.formIndex(before: &i)
    }
    
    @inlinable
    @inline(__always)
    public func index(_ i: Index, offsetBy distance: Int) -> Index {
      _tree.index(i, offsetBy: distance)
    }
    
    @inlinable
    @inline(__always)
    internal func formIndex(_ i: inout Index, offsetBy distance: Int) {
      _tree.formIndex(&i, offsetBy: distance)
    }
    
    @inlinable
    @inline(__always)
    public func index(_ i: Index, offsetBy distance: Int, limitedBy limit: Index) -> Index? {
      _tree.index(i, offsetBy: distance, limitedBy: limit)
    }
    
    @inlinable
    @inline(__always)
    internal func formIndex(_ i: inout Index, offsetBy distance: Int, limitedBy limit: Self.Index) -> Bool {
      if let ii = index(i, offsetBy: distance, limitedBy: limit) {
        i = ii
        return true
      }
      return false
    }
    
    @inlinable
    @inline(__always)
    public subscript(position: Index) -> EnumElement {
      (___index(position),_tree[position])
    }
    
    @inlinable
    public subscript(bounds: Range<TreePointer>) -> EnumSequence {
      .init(tree: _tree, start: bounds.lowerBound._pointer, end: bounds.upperBound._pointer)
    }
  }
}

extension ___RedBlackTree.___Tree {

  @inlinable
  func enumeratedSubsequence() -> EnumSequence {
    .init(tree: self, start: __begin_node, end: __end_node())
  }

  @inlinable
  func enumeratedSubsequence(from: _NodePtr, to: _NodePtr) -> EnumSequence {
    .init(tree: self, start: from, end: to)
  }
}

//extension ___RedBlackTree.___Tree {
//  public typealias _EnumSequence = EnumSequence
//}
//
//extension ___RedBlackTree.___Tree.Storage {
//  
//  public typealias EnumSequence = ___RedBlackTree.___Tree<VC>.EnumSequence
//  
//  @inlinable
//  func enumeratedSubsequence() -> EnumSequence {
//    .init(tree: tree, start: tree.__begin_node, end: tree.__end_node())
//  }
//
//  @inlinable
//  func enumeratedSubsequence(from: _NodePtr, to: _NodePtr) -> EnumSequence {
//    .init(tree: tree, start: from, end: to)
//  }
//}

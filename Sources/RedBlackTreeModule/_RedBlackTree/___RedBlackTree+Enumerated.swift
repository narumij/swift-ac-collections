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

  public typealias EnumeratedIndex = ___RedBlackTree.SimpleIndex

  public typealias EnumeratedElement = (offset: EnumeratedIndex, element: Element)
  
  @frozen
  public struct EnumIterator: RedBlackTreeIteratorNextProtocol {
    
    @inlinable
    internal init(tree: Tree, lifeStorage: LifeStorage, start: _NodePtr, end: _NodePtr) {
      self._tree = tree
      self._current = start
      self._end = end
      self._next = start == .end ? .end : tree.__tree_next(start)
    }
    
    @usableFromInline
    unowned let _tree: Tree
    
    @usableFromInline
    var _current, _next, _end: _NodePtr

    @inlinable
    @inline(__always)
    public mutating func next() -> EnumeratedElement? {
      _next().map { (.init($0), _tree[$0]) }
    }
  }
}

extension ___RedBlackTree.___Tree {
  
  @inlinable
  __consuming func makeEnumIterator(lifeStorage: LifeStorage) -> EnumIterator {
    .init(tree: self, lifeStorage: lifeStorage, start: __begin_node, end: __end_node())
  }
  
  @inlinable
  __consuming func makeEnumeratedIterator(lifeStorage: LifeStorage, start: _NodePtr, end: _NodePtr) -> EnumIterator {
    .init(tree: self, lifeStorage: lifeStorage, start: start, end: end)
  }
}

extension ___RedBlackTree.___Tree {

  @frozen
  public struct EnumSequence: Sequence {

    public typealias Element = Tree.EnumeratedElement
    public typealias Index = _NodePtr

    @inlinable
    init(tree: Tree, lifeStorage: LifeStorage, start: Index, end: Index) {
      self.base = tree
      self.lifeStorage = lifeStorage
      self.startIndex = start
      self.endIndex = end
    }

    @usableFromInline
    let base: Tree
    
    @usableFromInline
    let lifeStorage: LifeStorage

    public
      var startIndex: Index
    
    public
      var endIndex: Index

    @inlinable
    public func makeIterator() -> EnumIterator {
      base.makeEnumeratedIterator(lifeStorage: lifeStorage, start: startIndex, end: endIndex)
    }
    
    @inlinable
    @inline(__always)
    public var count: Int {
      base.distance(from: startIndex, to: endIndex)
    }
    
    @inlinable
    @inline(__always)
    public func forEach(_ body: @escaping (EnumeratedElement) throws -> Void) rethrows {
      var __p = startIndex
      while __p != endIndex {
        let __c = __p
        __p = base.__tree_next(__p)
        try body((.init(__c), base[__c]))
      }
    }
    
    // この実装がないと、迷子になる
    @inlinable
    @inline(__always)
    public func distance(from start: Index, to end: Index) -> Int {
      base.distance(from: start, to: end)
    }
    
    @inlinable
    @inline(__always)
    public func index(after i: Index) -> Index {
      base.index(after: i)
    }
    
    @inlinable
    @inline(__always)
    public func formIndex(after i: inout Index) {
      base.formIndex(after: &i)
    }
    
    @inlinable
    @inline(__always)
    public func index(before i: Index) -> Index {
      base.index(before: i)
    }
    
    @inlinable
    @inline(__always)
    public func formIndex(before i: inout Index) {
      base.formIndex(before: &i)
    }
    
    @inlinable
    @inline(__always)
    public func index(_ i: Index, offsetBy distance: Int) -> Index {
      base.index(i, offsetBy: distance)
    }
    
    @inlinable
    @inline(__always)
    internal func formIndex(_ i: inout Index, offsetBy distance: Int) {
      base.formIndex(&i, offsetBy: distance)
    }
    
    @inlinable
    @inline(__always)
    public func index(_ i: Index, offsetBy distance: Int, limitedBy limit: Index) -> Index? {
      base.index(i, offsetBy: distance, limitedBy: limit)
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
    public subscript(position: Index) -> EnumeratedElement {
      (.init(position),base[position])
    }
    
    @inlinable
    public subscript(bounds: Range<TreePointer>) -> EnumSequence {
      .init(tree: base, lifeStorage: lifeStorage, start: bounds.lowerBound.pointer, end: bounds.upperBound.pointer)
    }
  }
}

extension ___RedBlackTree.___Tree {

  @inlinable
  func enumeratedSubsequence(lifeStorage: LifeStorage) -> EnumSequence {
    .init(tree: self, lifeStorage: lifeStorage, start: __begin_node, end: __end_node())
  }

  @inlinable
  func enumeratedSubsequence(lifeStorage: LifeStorage, from: _NodePtr, to: _NodePtr) -> EnumSequence {
    .init(tree: self, lifeStorage: lifeStorage, start: from, end: to)
  }
}

extension ___RedBlackTree.___Tree {
  public typealias _EnumSequence = EnumSequence
}

extension ___RedBlackTree.___Tree.Storage {
  
  public typealias EnumSequence = ___RedBlackTree.___Tree<VC>.EnumSequence
  
  @inlinable
  func enumeratedSubsequence() -> EnumSequence {
    .init(tree: tree, lifeStorage: lifeStorage, start: tree.__begin_node, end: tree.__end_node())
  }

  @inlinable
  func enumeratedSubsequence(from: _NodePtr, to: _NodePtr) -> EnumSequence {
    .init(tree: tree, lifeStorage: lifeStorage, start: from, end: to)
  }
}

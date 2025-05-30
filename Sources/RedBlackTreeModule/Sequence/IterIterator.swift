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

extension ___RedBlackTree.___Tree {
  
  public
  struct ForwardIterator: IteratorProtocol {
    
    public typealias Element = ___Iterator
    
    @usableFromInline
    let _tree: Tree
    
    @usableFromInline
    var _current, _next, _end: _NodePtr
    
    @inlinable
    @inline(__always)
    internal init(tree: Tree, start: _NodePtr, end: _NodePtr) {
      self._tree = tree
      self._current = start
      self._end = end
      self._next = start == .end ? .end : tree.__tree_next(start)
    }
    
    // 性能変化の反応が過敏なので、慎重さが必要っぽい。
    
    @inlinable
    @inline(__always)
    public mutating func next() -> ___Iterator? {
      guard _current != _end else { return nil }
      defer {
        _current = _next
        _next = _next == _end ? _end : _tree.__tree_next(_next)
      }
      return _tree.makeIndex(rawValue: _current)
    }
  }
  
  public
  struct BackwordIterator: IteratorProtocol {
    
    public typealias Element = ___Iterator
    
    @usableFromInline
    let _tree: Tree
    
    @usableFromInline
    var _current, _next, _start, _begin: _NodePtr

    @inlinable
    @inline(__always)
    internal init(tree: Tree, start: _NodePtr, end: _NodePtr) {
      self._tree = tree
      self._current = end
      self._next = _tree.__tree_prev_iter(end)
      self._start = start
      self._begin = _tree.__begin_node
    }
    
    @inlinable
    @inline(__always)
    public mutating func next() -> ___Iterator? {
      guard _current != _start else { return nil }
      _current = _next
      _next = _current != _begin ? _tree.__tree_prev_iter(_current) : .nullptr
      return _tree.makeIndex(rawValue: _current)
    }
  }
  
  public
  struct IterSequence: Sequence, ReversableSequence {
    
    public
    typealias _Tree = Tree
    
    @usableFromInline
    let _tree: Tree
    
    @usableFromInline
    var _start, _end: _NodePtr
    
    public typealias Index = ___Iterator
    
    @inlinable
    @inline(__always)
    internal init(tree: Tree) {
      self.init(
        tree: tree,
        start: tree.__begin_node,
        end: tree.__end_node())
    }
    
    @inlinable
    @inline(__always)
    internal init(tree: Tree, start: _NodePtr, end: _NodePtr) {
      _tree = tree
      _start = start
      _end = end
    }
    
    @inlinable
    public func makeIterator() -> ForwardIterator {
      .init(tree: _tree, start: _start, end: _end)
    }
    
    @inlinable
    public func makeReversedIterator() -> BackwordIterator {
      .init(tree: _tree, start: _start, end: _end)
    }
  }
}

extension ___RedBlackTree.___Tree.IterSequence: Collection, BidirectionalCollection {
  
  public
  func index(after i: Index) -> Index {
    return i.advanced(by: 1)
//    i.___next_
  }
  
  public
  func index(before i: Index) -> Index {
    return i.advanced(by: -1)
//    i.___prev_
  }
  
  public
  subscript(position: Index) -> Index {
    _tree.makeIndex(rawValue: position.rawValue)
  }
  
  public
  var startIndex: Index {
    _tree.makeIndex(rawValue: _start)
  }
  
  public
  var endIndex: Index {
    _tree.makeIndex(rawValue: _end)
  }
  
  public typealias SubSequence = Self
  
  public subscript(bounds: Range<Index>) -> SubSequence {
    .init(tree: _tree, start: bounds.lowerBound.rawValue, end: bounds.upperBound.rawValue)
  }
  
  public func reversed() -> ReversedSequence<Self> {
    .init(base: self)
  }
}

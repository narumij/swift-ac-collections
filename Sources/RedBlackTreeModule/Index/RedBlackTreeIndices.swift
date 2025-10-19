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

@frozen
public struct RedBlackTreeIndices<VC> where VC: ValueComparer & CompareTrait & ThreeWayComparator {
  public typealias Tree = ___Tree<VC>
  public typealias _Value = Tree._Value
  
  @usableFromInline
  let __tree_: Tree
  
  @usableFromInline
  var _start, _end: _NodePtr
  
  public typealias Index = Tree.Index
  
  @inlinable
  @inline(__always)
  internal init(tree: Tree, start: _NodePtr, end: _NodePtr) {
    __tree_ = tree
    _start = start
    _end = end
  }
}

extension RedBlackTreeIndices {
  
  @frozen
  public struct ForwardIterator: IteratorProtocol {
    
    @usableFromInline
    let __tree_: Tree
    
    @usableFromInline
    var _current, _next, _end: _NodePtr
    
    @inlinable
    @inline(__always)
    internal init(tree: Tree, start: _NodePtr, end: _NodePtr) {
      self.__tree_ = tree
      self._current = start
      self._end = end
      self._next = start == .end ? .end : tree.__tree_next(start)
    }
    
    @inlinable
    @inline(__always)
    public mutating func next() -> Index? {
      guard _current != _end else { return nil }
      defer {
        _current = _next
        _next = _next == _end ? _end : __tree_.__tree_next(_next)
      }
      return __tree_.makeIndex(rawValue: _current)
    }
  }
}

extension RedBlackTreeIndices {

  @frozen
  public struct BackwordIterator: Sequence, IteratorProtocol {
    
    @usableFromInline
    let __tree_: Tree
    
    @usableFromInline
    var _current, _next, _start, _begin: _NodePtr
    
    @inlinable
    @inline(__always)
    internal init(tree: Tree, start: _NodePtr, end: _NodePtr) {
      self.__tree_ = tree
      self._current = end
      self._next = end == start ? end : __tree_.__tree_prev_iter(end)
      self._start = start
      self._begin = __tree_.__begin_node
    }
    
    @inlinable
    @inline(__always)
    public mutating func next() -> Index? {
      guard _current != _start else { return nil }
      _current = _next
      _next = _current != _begin ? __tree_.__tree_prev_iter(_current) : .nullptr
      return __tree_.makeIndex(rawValue: _current)
    }
  }
}

extension RedBlackTreeIndices: Collection, BidirectionalCollection {
  
  @inlinable
  @inline(__always)
  public __consuming func makeIterator() -> ForwardIterator {
    .init(tree: __tree_, start: _start, end: _end)
  }
  
  @inlinable
  @inline(__always)
  public __consuming func reversed() -> BackwordIterator {
    .init(tree: __tree_, start: _start, end: _end)
  }

  @inlinable
  @inline(__always)
  public func index(after i: Index) -> Index {
    return i.advanced(by: 1)
    //    i.___next_
  }

  @inlinable
  @inline(__always)
  public func index(before i: Index) -> Index {
    return i.advanced(by: -1)
    //    i.___prev_
  }

  @inlinable
  @inline(__always)
  public subscript(position: Index) -> Index {
    __tree_.makeIndex(rawValue: position.rawValue)
  }

  @inlinable
  @inline(__always)
  public var startIndex: Index {
    __tree_.makeIndex(rawValue: _start)
  }

  @inlinable
  @inline(__always)
  public var endIndex: Index {
    __tree_.makeIndex(rawValue: _end)
  }

  public typealias SubSequence = Self

  @inlinable
  @inline(__always)
  public subscript(bounds: Range<Index>) -> SubSequence {
    .init(
      tree: __tree_,
      start: bounds.lowerBound.rawValue,
      end: bounds.upperBound.rawValue)
  }
  
  @inlinable
  @inline(__always)
  public subscript<R>(bounds: R) -> SubSequence where R: RangeExpression, R.Bound == Index {
    let bounds: Range<Index> = bounds.relative(to: self)
    return .init(
      tree: __tree_,
      start: bounds.lowerBound.rawValue,
      end: bounds.upperBound.rawValue)
  }
}

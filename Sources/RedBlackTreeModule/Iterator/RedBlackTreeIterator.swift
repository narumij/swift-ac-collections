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
public enum RedBlackTreeIterator<Base> where Base: ___TreeBase {
  
  @frozen
  public struct Values: Sequence, IteratorProtocol {
    
    public typealias Tree = ___Tree<Base>
    public typealias _Value = Tree._Value
    
    @usableFromInline
    let __tree_: Tree
    
    @usableFromInline
    var _start, _end, _current, _next: _NodePtr

    @inlinable
    @inline(__always)
    internal init(tree: Tree, start: _NodePtr, end: _NodePtr) {
      self.__tree_ = tree
      self._current = start
      self._start = start
      self._end = end
      self._next = start == .end ? .end : tree.__tree_next_iter(start)
    }

    @inlinable
    @inline(__always)
    public mutating func next() -> Tree._Value? {
      guard _current != _end else { return nil }
      defer {
        _current = _next
        _next = _next == _end ? _end : __tree_.__tree_next_iter(_next)
      }
      return __tree_[_current]
    }
  }
}

extension RedBlackTreeIterator.Values {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public __consuming func keys() -> RedBlackTreeIterator<Base>.Keys
  where Base: KeyValueComparer {
    .init(tree: __tree_, start: _start, end: _end)
  }

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public __consuming func values() -> RedBlackTreeIterator<Base>.MappedValues
  where Base: KeyValueComparer {
    .init(tree: __tree_, start: _start, end: _end)
  }
}

extension RedBlackTreeIterator.Values: Equatable where Tree._Value: Equatable {

  @inlinable
  @inline(__always)
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.isIdentical(to: rhs) || lhs.elementsEqual(rhs)
  }
}

extension RedBlackTreeIterator.Values: Comparable where Tree._Value: Comparable {

  @inlinable
  @inline(__always)
  public static func < (lhs: Self, rhs: Self) -> Bool {
    !lhs.isIdentical(to: rhs) && lhs.lexicographicallyPrecedes(rhs)
  }
}

extension RedBlackTreeIterator.Values: ___RedBlackTreeIsIdenticalTo {}

extension ___Tree {
  public typealias _ValueIterator = RedBlackTreeIterator<VC>.Values
}

// Copyright 2024-2026 narumij
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
// Copyright © 2003-2025 The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.

import Foundation

extension RedBlackTreeIteratorV2.MappedValues {
  
  @frozen
  public struct Reversed: Sequence, IteratorProtocol, UnsafeTreePointer, UnsafeImmutableIndexingProtocol
  where Base: KeyValueComparer
  {
    public typealias Tree = UnsafeTreeV2<Base>
    public typealias _MappedValue = RedBlackTreeIteratorV2.Base._MappedValue

    @usableFromInline
    internal let __tree_: ImmutableTree
    
    @usableFromInline
    internal var _start, _end, _begin, _current, _next: _NodePtr
    
    @usableFromInline
    var poolLifespan: PoolLifespan

    @inlinable
    @inline(__always)
    internal init(tree: Tree, start: _NodePtr, end: _NodePtr) {
      self.__tree_ = .init(__tree_: tree)
      self._current = end
      self._next = end == start ? end : __tree_.__tree_prev_iter(end)
      self._start = start
      self._end = end
      self._begin = __tree_.__begin_node_
      self.poolLifespan = tree.poolLifespan
    }
    
    @inlinable
    internal init(
      __tree_: ImmutableTree,
      start: _NodePtr,
      end: _NodePtr,
      poolLifespan: PoolLifespan
    ) {

      self.__tree_ = __tree_
      self._current = end
      self._next = end == start ? end : __tree_.__tree_prev_iter(end)
      self._start = start
      self._end = end
      self._begin = __tree_.__begin_node_
      self.poolLifespan = poolLifespan
    }
    
    @inlinable
    @inline(__always)
    public mutating func next() -> _MappedValue? {
      guard _current != _start else { return nil }
      _current = _next
      _next = _current != _begin ? __tree_.__tree_prev_iter(_current) : __tree_.nullptr
      return __tree_.___mapped_value(_current)
    }
  }
}

extension RedBlackTreeIteratorV2.MappedValues.Reversed: Equatable where _MappedValue: Equatable {

  @inlinable
  @inline(__always)
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.isTriviallyIdentical(to: rhs) || lhs.elementsEqual(rhs)
  }
}

extension RedBlackTreeIteratorV2.MappedValues.Reversed: Comparable where _MappedValue: Comparable {

  @inlinable
  @inline(__always)
  public static func < (lhs: Self, rhs: Self) -> Bool {
    !lhs.isTriviallyIdentical(to: rhs) && lhs.lexicographicallyPrecedes(rhs)
  }
}

#if swift(>=5.5)
  extension RedBlackTreeIteratorV2.MappedValues.Reversed: @unchecked Sendable
  where _MappedValue: Sendable {}
#endif

// MARK: - Is Identical To

extension RedBlackTreeIteratorV2.MappedValues.Reversed: ___UnsafeImmutableIsIdenticalToV2 {}

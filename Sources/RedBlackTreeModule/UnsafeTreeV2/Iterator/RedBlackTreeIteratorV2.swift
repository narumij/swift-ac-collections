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

@frozen
public enum RedBlackTreeIteratorV2<Base> where Base: ___TreeBase & ___TreeIndex {

  public typealias Base = Base

  @frozen
  public struct Values: Sequence, IteratorProtocol, UnsafeTreePointer {

    public typealias Tree = UnsafeTreeV2<Base>
    public typealias _Value = RedBlackTreeIteratorV2.Base._Value

    #if false
      @usableFromInline
      internal let __tree_: ImmutableTree

      @usableFromInline
      internal var _start, _end, _current, _next: _NodePtr

      @usableFromInline
      var poolLifespan: PoolLifespan

      @inlinable
      internal init(tree: Tree, start: _NodePtr, end: _NodePtr) {
        self.__tree_ = .init(__tree_: tree)
        self._current = start
        self._start = start
        self._end = end
        self._next = start == tree.end ? tree.end : tree.__tree_next_iter(start)
        self.poolLifespan = tree.poolLifespan
      }

      @inlinable
      @inline(__always)
      public mutating func next() -> _Value? {
        guard _current != _end else { return nil }
        defer {
          _current = _next
          _next = _next == _end ? _end : __tree_.__tree_next_iter(_next)
        }
        return __tree_.__value_(_current)
      }
    #else

      @usableFromInline
      var source: ___UnsafeRemoveAwareWrapper<___UnsafeNaiveIterator>

      @usableFromInline
      var poolLifespan: Deallocator

      @inlinable
      internal init(tree: Tree, start: _NodePtr, end: _NodePtr) {
        self.poolLifespan = tree.poolLifespan
        source = .init(iterator: .init(nullptr: tree.nullptr, __first: start, __last: end))
      }

      @inlinable
      @inline(__always)
      public mutating func next() -> _Value? {
        source.next().map { $0.__value_().pointee }
      }
    #endif
  }
}

#if false
  extension RedBlackTreeIteratorV2.Values: Equatable where _Value: Equatable {

    @inlinable
    @inline(__always)
    public static func == (lhs: Self, rhs: Self) -> Bool {
      lhs.isTriviallyIdentical(to: rhs) || lhs.elementsEqual(rhs)
    }
  }

  extension RedBlackTreeIteratorV2.Values: Comparable where _Value: Comparable {

    @inlinable
    @inline(__always)
    public static func < (lhs: Self, rhs: Self) -> Bool {
      !lhs.isTriviallyIdentical(to: rhs) && lhs.lexicographicallyPrecedes(rhs)
    }
  }
#endif

#if swift(>=5.5)
  extension RedBlackTreeIteratorV2.Values: @unchecked Sendable
  where _Value: Sendable {}
#endif

// MARK: - Is Identical To

#if false
  extension RedBlackTreeIteratorV2.Values: ___UnsafeImmutableIsIdenticalToV2 {}
#endif

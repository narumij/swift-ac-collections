// Copyright 2024-2025 narumij
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

extension RedBlackTreeIterator_old.KeyValues {

  @frozen
  public struct Reversed: Sequence, IteratorProtocol {
    public typealias Tree = ___Tree<Base>
    public typealias _Value = Tree._Value

    @usableFromInline
    internal let __tree_: Tree

    @usableFromInline
    internal var _start, _end, _begin, _current, _next: _NodePtr

    @inlinable
    @inline(__always)
    internal init(tree: Tree, start: _NodePtr, end: _NodePtr) {
      self.__tree_ = tree
      self._current = end
      self._next = end == start ? end : __tree_.__tree_prev_iter(end)
      self._start = start
      self._end = end
      self._begin = __tree_.__begin_node_
    }

    @inlinable
    @inline(__always)
    public mutating func next() -> (key: Base._Key, value: Base._MappedValue)? {
      guard _current != _start else { return nil }
      _current = _next
      _next = _current != _begin ? __tree_.__tree_prev_iter(_current) : .nullptr
      return (__tree_.__get_value(_current), __tree_.___mapped_value(_current))
    }
  }
}

extension RedBlackTreeIterator_old.KeyValues.Reversed {
  
  @inlinable
  @inline(__always)
  public func forEach(_ body: (Tree.Index, Tree._Value) throws -> Void) rethrows {
    try __tree_.___rev_for_each_(__p: _start, __l: _end) {
      try body(__tree_.makeIndex(rawValue: $0), __tree_[$0])
    }
  }
}

extension RedBlackTreeIterator_old.KeyValues.Reversed {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public var indices: RedBlackTreeIndices_old<Base>.Reversed {
    .init(tree: __tree_, start: _start, end: _end)
  }
}

extension RedBlackTreeIterator_old.KeyValues.Reversed where Base: KeyValueComparer {

  #if COMPATIBLE_ATCODER_2025
    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public func keys() -> RedBlackTreeIterator_old<Base>.Keys.Reversed {
      .init(tree: __tree_, start: _start, end: _end)
    }

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public func values() -> RedBlackTreeIterator_old<Base>.MappedValues.Reversed {
      .init(tree: __tree_, start: _start, end: _end)
    }
  #else
    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public var keys: RedBlackTreeIterator_old<Base>.Keys.Reversed {
      .init(tree: __tree_, start: _start, end: _end)
    }

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public var values: RedBlackTreeIterator_old<Base>.MappedValues.Reversed {
      .init(tree: __tree_, start: _start, end: _end)
    }
  #endif
}

extension RedBlackTreeIterator_old.KeyValues.Reversed {

  @inlinable
  @inline(__always)
  package func ___node_positions() -> ___SafePointers<Base>.Reversed {
    .init(tree: __tree_, start: _start, end: _end)
  }
}

extension RedBlackTreeIterator_old.KeyValues.Reversed: Equatable
where Base._Key: Equatable, Base._MappedValue: Equatable {

  @inlinable
  @inline(__always)
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.isIdentical(to: rhs) || lhs.elementsEqual(rhs, by: ==)
  }
}

extension RedBlackTreeIterator_old.KeyValues.Reversed: Comparable
where Base._Key: Comparable, Base._MappedValue: Comparable {

  @inlinable
  @inline(__always)
  public static func < (lhs: Self, rhs: Self) -> Bool {
    !lhs.isIdentical(to: rhs) && lhs.lexicographicallyPrecedes(rhs, by: <)
  }
}

#if swift(>=5.5)
  extension RedBlackTreeIterator_old.KeyValues.Reversed: @unchecked Sendable
  where Tree._Value: Sendable {}
#endif

// MARK: - Is Identical To

extension RedBlackTreeIterator_old.KeyValues.Reversed: ___IsIdenticalTo {}

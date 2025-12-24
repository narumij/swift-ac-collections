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

extension RedBlackTreeIterator.Values {

  @frozen
  public struct Reversed: Sequence, IteratorProtocol {
    public typealias Tree = ___Tree<Base>
    public typealias _Value = Tree._Value

    @usableFromInline
    let __tree_: Tree

    @usableFromInline
    var _start, _end, _begin, _current, _next: _NodePtr

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
    public mutating func next() -> Tree._Value? {
      guard _current != _start else { return nil }
      _current = _next
      _next = _current != _begin ? __tree_.__tree_prev_iter(_current) : .nullptr
      return __tree_[_current]
    }
  }
}

extension RedBlackTreeIterator.Values.Reversed {

  @inlinable
  @inline(__always)
  public func forEach(_ body: (Tree.Index, Tree._Value) throws -> Void) rethrows {
    try __tree_.___rev_for_each_(__p: _start, __l: _end) {
      try body(__tree_.makeIndex(rawValue: $0), __tree_[$0])
    }
  }

  @inlinable
  @inline(__always)
  public func ___forEach(_ body: (_NodePtr, Tree._Value) throws -> Void) rethrows {
    try __tree_.___rev_for_each_(__p: _start, __l: _end) {
      try body($0, __tree_[$0])
    }
  }
}

extension RedBlackTreeIterator.Values.Reversed {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public var indices: RedBlackTreeIndices<Base>.Reversed {
    .init(tree: __tree_, start: _start, end: _end)
  }
}

extension RedBlackTreeIterator.Values.Reversed {

  @inlinable
  @inline(__always)
  public func ___node_positions() -> ___SafePointers<Base>.Reversed {
    .init(tree: __tree_, start: _start, end: _end)
  }
}

extension RedBlackTreeIterator.Values.Reversed: Equatable where Element: Equatable {

  @inlinable
  @inline(__always)
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.isIdentical(to: rhs) || lhs.elementsEqual(rhs)
  }
}

extension RedBlackTreeIterator.Values.Reversed: Comparable where Element: Comparable {

  @inlinable
  @inline(__always)
  public static func < (lhs: Self, rhs: Self) -> Bool {
    !lhs.isIdentical(to: rhs) && lhs.lexicographicallyPrecedes(rhs)
  }
}

#if swift(>=5.5)
  extension RedBlackTreeIterator.Values.Reversed: @unchecked Sendable
  where Tree._Value: Sendable {}
#endif

// MARK: - Is Identical To

extension RedBlackTreeIterator.Values.Reversed: ___IsIdenticalTo {}

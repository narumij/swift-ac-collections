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

extension RedBlackTreeIteratorV2 {

  @frozen
  public struct KeyValues: Sequence, IteratorProtocol
  where Base: KeyValueComparer {

    public typealias Tree = UnsafeTreeV2<Base,Base._Key>
    public typealias _NodePtr = Tree._NodePtr

    @usableFromInline
    internal let __tree_: Tree

    @usableFromInline
    internal var _start, _end, _current, _next: _NodePtr

    @inlinable
    @inline(__always)
    internal init(tree: Tree, start: _NodePtr, end: _NodePtr) {
      self.__tree_ = tree
      self._current = start
      self._start = start
      self._end = end
      self._next = start == tree.end ? tree.end : tree.__tree_next_iter(start)
    }

    @inlinable
    @inline(__always)
    public mutating func next() -> (key: Base._Key, value: Base._MappedValue)? {
      guard _current != _end else { return nil }
      defer {
        _current = _next
        _next = _next == _end ? _end : __tree_.__tree_next_iter(_next)
      }
      return (__tree_.__get_value(_current), __tree_.___mapped_value(_current))
    }
  }
}

extension RedBlackTreeIteratorV2.KeyValues where Base: KeyValueComparer {

  #if COMPATIBLE_ATCODER_2025
    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public func keys() -> RedBlackTreeIteratorV2<Base>.Keys {
      .init(tree: __tree_, start: _start, end: _end)
    }

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public func values() -> RedBlackTreeIteratorV2<Base>.MappedValues {
      .init(tree: __tree_, start: _start, end: _end)
    }
  #else
    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public var keys: RedBlackTreeIteratorV2<Base>.Keys {
      .init(tree: __tree_, start: _start, end: _end)
    }

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public var values: RedBlackTreeIteratorV2<Base>.MappedValues {
      .init(tree: __tree_, start: _start, end: _end)
    }
  #endif
}

extension RedBlackTreeIteratorV2.KeyValues: Equatable
where Base._Key: Equatable, Base._MappedValue: Equatable {

  @inlinable
  @inline(__always)
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.isIdentical(to: rhs) || lhs.elementsEqual(rhs, by: ==)
  }
}

extension RedBlackTreeIteratorV2.KeyValues: Comparable
where Base._Key: Comparable, Base._MappedValue: Comparable {

  @inlinable
  @inline(__always)
  public static func < (lhs: Self, rhs: Self) -> Bool {
    !lhs.isIdentical(to: rhs) && lhs.lexicographicallyPrecedes(rhs, by: <)
  }
}

#if swift(>=5.5)
  extension RedBlackTreeIteratorV2.KeyValues: @unchecked Sendable
  where Tree._Value: Sendable {}
#endif

// MARK: - Is Identical To

extension RedBlackTreeIteratorV2.KeyValues: ___UnsafeIsIdenticalToV2 {}

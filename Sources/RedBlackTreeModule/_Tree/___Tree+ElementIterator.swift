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

extension ___Tree {

  @frozen
  public struct ElementIterator: Sequence, IteratorProtocol {

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

    // 性能変化の反応が過敏なので、慎重さが必要っぽい。

    @inlinable
    @inline(__always)
    public mutating func next() -> Tree.Element? {
      guard _current != _end else { return nil }
      defer {
        _current = _next
        _next = _next == _end ? _end : __tree_.__tree_next_iter(_next)
      }
      return __tree_[_current]
    }
  }
}

extension ___Tree.ElementIterator: Equatable where Element: Equatable {

  @inlinable
  @inline(__always)
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.elementsEqual(rhs)
  }
}

extension ___Tree.ElementIterator: Comparable where Element: Comparable {

  @inlinable
  @inline(__always)
  public static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.lexicographicallyPrecedes(rhs)
  }
}

extension ___Tree {

  @frozen
  public struct ReversedElementIterator: Sequence, IteratorProtocol {

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
      self._begin = __tree_.__begin_node
    }

    @inlinable
    @inline(__always)
    public mutating func next() -> Tree.Element? {
      guard _current != _start else { return nil }
      _current = _next
      _next = _current != _begin ? __tree_.__tree_prev_iter(_current) : .nullptr
      return __tree_[_current]
    }
  }
}

extension ___Tree.ReversedElementIterator {

  @inlinable
  @inline(__always)
  public func forEach(_ body: (___Tree.Index, Element) throws -> Void) rethrows {
    try __tree_.___rev_for_each_(__p: _start, __l: _end) {
      try body(__tree_.makeIndex(rawValue: $0), __tree_[$0])
    }
  }

  @inlinable
  @inline(__always)
  public func ___forEach(_ body: (_NodePtr, Element) throws -> Void) rethrows {
    try __tree_.___rev_for_each_(__p: _start, __l: _end) {
      try body($0, __tree_[$0])
    }
  }
}

extension ___Tree.ReversedElementIterator {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public var indices: ___Tree.BackwordIterator {
    .init(tree: __tree_, start: _start, end: _end)
  }
}

extension ___Tree.ReversedElementIterator {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public __consuming func keys<Key, Value>() -> ReversedKeyIterator<___Tree, Key, Value>
  where Element == _KeyValueTuple_<Key, Value> {
    .init(tree: __tree_, start: _start, end: _end)
  }

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public __consuming func values<Key, Value>() -> ReversedValueIterator<___Tree, Key, Value>
  where Element == _KeyValueTuple_<Key, Value> {
    .init(tree: __tree_, start: _start, end: _end)
  }
}

extension ___Tree.ReversedElementIterator {

  @inlinable
  @inline(__always)
  public __consuming func ___node_positions() -> ReversedNodeIterator<___Tree> {
    .init(tree: __tree_, start: _start, end: _end)
  }
}

extension ___Tree.ReversedElementIterator: Equatable where Element: Equatable {

  @inlinable
  @inline(__always)
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.elementsEqual(rhs)
  }
}

extension ___Tree.ReversedElementIterator: Comparable where Element: Comparable {

  @inlinable
  @inline(__always)
  public static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.lexicographicallyPrecedes(rhs)
  }
}

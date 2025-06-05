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

@frozen
public struct ValueIterator<Tree: Tree_IterateProtocol, K, Value>: Sequence, IteratorProtocol
where Tree.Element == _KeyValueTuple_<K, Value> {

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
  public mutating func next() -> Value? {
    guard _current != _end else { return nil }
    defer {
      _current = _next
      _next = _next == _end ? _end : __tree_.__tree_next_iter(_next)
    }
    return __tree_[_current].value
  }

  @inlinable
  @inline(__always)
  public __consuming func reversed() -> ReversedValueIterator<Tree, K, Value> {
    .init(tree: __tree_, start: _start, end: _end)
  }
}

extension ValueIterator: Equatable where Value: Equatable {

  @inlinable
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.elementsEqual(rhs)
  }
}

extension ValueIterator: Comparable where Value: Comparable {

  @inlinable
  public static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.lexicographicallyPrecedes(rhs)
  }
}

@frozen
public struct ReversedValueIterator<Tree: Tree_IterateProtocol, K, Value>: Sequence,
  IteratorProtocol
where Tree.Element == _KeyValueTuple_<K, Value> {

  @usableFromInline
  let _tree_: Tree

  @usableFromInline
  var _start, _begin, _current, _next: _NodePtr

  @inlinable
  @inline(__always)
  internal init(tree: Tree, start: _NodePtr, end: _NodePtr) {
    self._tree_ = tree
    self._current = end
    self._next = _tree_.__tree_prev_iter(end)
    self._start = start
    self._begin = _tree_.__begin_node
  }

  @inlinable
  @inline(__always)
  public mutating func next() -> Value? {
    guard _current != _start else { return nil }
    _current = _next
    _next = _current != _begin ? _tree_.__tree_prev_iter(_current) : .nullptr
    return _tree_[_current].value
  }
}

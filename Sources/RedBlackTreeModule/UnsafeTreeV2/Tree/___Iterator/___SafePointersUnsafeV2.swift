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

// TODO: 利用時の寿命管理の確認
// 寿命延長を行わないので、利用側で寿命安全を守る必要がある

@frozen
@usableFromInline
package struct ___SafePointersUnsafeV2<Base>: Sequence, IteratorProtocol, UnsafeTreeProtocol
where Base: ___TreeBase {

  @usableFromInline
  package let __tree_: ImmutableTree

  @usableFromInline
  package var _start, _end, _current, _next: _NodePtr

  @inlinable
  @inline(__always)
  package init(tree: Tree, start: _NodePtr, end: _NodePtr) {
    self.__tree_ = .init(__tree_: tree)
    self._current = start
    self._start = start
    self._end = end
    self._next = start == tree.end ? tree.end : tree.__tree_next_iter(start)
  }

  @inlinable
  @inline(__always)
  package init(__tree_: ImmutableTree, start: _NodePtr, end: _NodePtr) {
    self.__tree_ = __tree_
    self._current = start
    self._start = start
    self._end = end
    self._next = start == __tree_.end ? __tree_.end : __tree_.__tree_next_iter(start)
  }

  @inlinable
  @inline(__always)
  package mutating func next() -> _NodePtr? {
    guard _current != _end else { return nil }
    defer {
      _current = _next
      _next = _next == _end ? _end : __tree_.__tree_next_iter(_next)
    }
    return _current
  }

  @inlinable
  @inline(__always)
  internal func reversed() -> Reversed {
    .init(__tree_: __tree_, start: _start, end: _end)
  }
}

extension ___SafePointersUnsafeV2 {

  @frozen
  @usableFromInline
  package struct Reversed: Sequence, IteratorProtocol, UnsafeTreeProtocol
  where Base: ___TreeBase {

    @usableFromInline
    internal let __tree_: ImmutableTree

    @usableFromInline
    internal var _start, _begin, _current, _next: _NodePtr

    @inlinable
    @inline(__always)
    internal init(tree: Tree, start: _NodePtr, end: _NodePtr) {
      self.__tree_ = .init(__tree_: tree)
      self._current = end
      self._next = end == start ? end : __tree_.__tree_prev_iter(end)
      self._start = start
      self._begin = __tree_.__begin_node_
    }

    @inlinable
    @inline(__always)
    package init(__tree_: ImmutableTree, start: _NodePtr, end: _NodePtr) {
      self.__tree_ = __tree_
      self._current = end
      self._next = end == start ? end : __tree_.__tree_prev_iter(end)
      self._start = start
      self._begin = __tree_.__begin_node_
    }

    @inlinable
    @inline(__always)
    package mutating func next() -> _NodePtr? {
      guard _current != _start else { return nil }
      _current = _next
      _next = _current != _begin ? __tree_.__tree_prev_iter(_current) : __tree_.nullptr
      return _current
    }
  }
}

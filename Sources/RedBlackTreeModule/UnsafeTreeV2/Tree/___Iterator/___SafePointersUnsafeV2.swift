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

// TODO: CoW挙動検討
// 内部用シーケンスはCoW対象外でいいかもしれない

@frozen
@usableFromInline
package struct ___SafePointersUnsafeV2<Base>: Sequence, IteratorProtocol
where Base: ___TreeBase {

  @usableFromInline
  package typealias Tree = UnsafeTreeV2<Base>

  @usableFromInline
  package typealias _NodePtr = Tree._NodePtr

  @usableFromInline
  package let __tree_: Tree

  @usableFromInline
  package var _start, _end, _current, _next: _NodePtr

  @inlinable
  @inline(__always)
  package init(tree: Tree, start: _NodePtr, end: _NodePtr) {
    self.__tree_ = tree
    self._current = start
    self._start = start
    self._end = end
    self._next = start == tree.end ? tree.end : tree.__tree_next_iter(start)
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
    .init(tree: __tree_, start: _start, end: _end)
  }
}

extension ___SafePointersUnsafeV2 {

  @frozen
  @usableFromInline
  package struct Reversed: Sequence, IteratorProtocol
  where Base: ___TreeBase {

    @usableFromInline
    internal typealias Tree = UnsafeTreeV2<Base>

    @usableFromInline
    internal let __tree_: Tree

    @usableFromInline
    internal var _start, _begin, _current, _next: _NodePtr

    @inlinable
    @inline(__always)
    internal init(tree: Tree, start: _NodePtr, end: _NodePtr) {
      self.__tree_ = tree
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

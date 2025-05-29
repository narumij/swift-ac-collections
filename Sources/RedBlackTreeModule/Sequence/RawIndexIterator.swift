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

public
struct RawIndexIterator<Tree: ___IterateNextProtocol>: IteratorProtocol {

  @usableFromInline
  let _tree: Tree

  @usableFromInline
  var _current, _next, _end: _NodePtr
  
  @inlinable
  @inline(__always)
  internal init(tree: Tree, start: _NodePtr, end: _NodePtr) {
    self._tree = tree
    self._current = start
    self._end = end
    self._next = start == .end ? .end : tree.__tree_next(start)
  }
  
  @inlinable
  @inline(__always)
  public mutating func next() -> RawIndex? {
    guard _current != _end else { return nil }
    defer {
      _current = _next
      _next = _next == _end ? _end : _tree.__tree_next(_next)
    }
    return RawIndex(_current)
  }
}

public
struct ReversedRawIndexIterator<Tree: ___IterateNextProtocol>: IteratorProtocol {

  @usableFromInline
  let _tree: Tree

  @usableFromInline
  var _current, _next, _start, _begin: _NodePtr

  @inlinable
  @inline(__always)
  internal init(tree: Tree, start: _NodePtr, end: _NodePtr) {
    self._tree = tree
    self._current = end
    self._next = _tree.__tree_prev_iter(end)
    self._start = start
    self._begin = _tree.__begin_node
  }
  
  @inlinable
  @inline(__always)
  public mutating func next() -> RawIndex? {
    guard _current != _start else { return nil }
    _current = _next
    _next = _current != _begin ? _tree.__tree_prev_iter(_current) : .nullptr
    return RawIndex(_current)
  }
}

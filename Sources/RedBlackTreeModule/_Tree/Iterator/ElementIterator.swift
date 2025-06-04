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
public
struct ElementIterator<Tree: Tree_IterateProtocol>: Sequence, IteratorProtocol {
    
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
  
  @inlinable
  public __consuming func reversed() -> ReversedElementIterator<Tree> {
    .init(tree: __tree_, start: _start, end: _end)
  }
}

@frozen
public
struct ReversedElementIterator<Tree: Tree_IterateProtocol>: Sequence, IteratorProtocol {
  
  @usableFromInline
  let __tree_: Tree

  @usableFromInline
  var _start, _begin, _current, _next: _NodePtr

  @inlinable
  @inline(__always)
  internal init(tree: Tree, start: _NodePtr, end: _NodePtr) {
    self.__tree_ = tree
    self._current = end
    self._next = __tree_.__tree_prev_iter(end)
    self._start = start
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

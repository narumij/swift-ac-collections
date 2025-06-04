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
struct KeyIterator<Tree: Tree_IterateProtocol & Tree_KeyCompare,Key,V>: Sequence, IteratorProtocol
where Tree.Element == _KeyValueTuple_<Key,V>, Tree.Key == Key
{

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
  public mutating func next() -> Key? {
    guard _current != _end else { return nil }
    defer {
      _current = _next
      _next = _next == _end ? _end : __tree_.__tree_next_iter(_next)
    }
    return __tree_[_current].key
  }
  
  @inlinable
  public __consuming func reversed() -> ReversedKeyIterator<Tree,Key,V> {
    .init(tree: __tree_, start: _start, end: _end)
  }
}

extension KeyIterator: Equatable {
  
  public static func == (lhs: KeyIterator<Tree, Key, V>, rhs: KeyIterator<Tree, Key, V>) -> Bool {
    lhs.elementsEqual(rhs, by: { !Tree.value_comp($0,$1) && !Tree.value_comp($1,$0) })
  }
}

extension KeyIterator: Comparable {
  
  public static func < (lhs: KeyIterator<Tree, Key, V>, rhs: KeyIterator<Tree, Key, V>) -> Bool {
    lhs.lexicographicallyPrecedes(rhs, by: Tree.value_comp)
  }
}

@frozen
public
struct ReversedKeyIterator<Tree: Tree_IterateProtocol,Key,V>: Sequence, IteratorProtocol
where Tree.Element == _KeyValueTuple_<Key,V>
{

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
  public mutating func next() -> Key? {
    guard _current != _start else { return nil }
    _current = _next
    _next = _current != _begin ? __tree_.__tree_prev_iter(_current) : .nullptr
    return __tree_[_current].key
  }
}

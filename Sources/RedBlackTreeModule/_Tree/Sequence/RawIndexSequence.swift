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
struct RawIndexSequence<Tree: Tree_IterateProtocol>: Sequence {
  
  @usableFromInline
  let __tree_: Tree
  
  @usableFromInline
  var _start, _end: _NodePtr
  
  @inlinable
  @inline(__always)
  internal init(tree: Tree) where Tree: BeginNodeProtocol & EndNodeProtocol {
    self.init(
      tree: tree,
      start: tree.__begin_node,
      end: tree.__end_node())
  }
  
  @inlinable
  @inline(__always)
  internal init(tree: Tree, start: _NodePtr, end: _NodePtr) {
    __tree_ = tree
    _start = start
    _end = end
  }
  
  @inlinable
  public __consuming func makeIterator() -> RawIndexIterator<Tree> {
    .init(tree: __tree_, start: _start, end: _end)
  }
  
  @inlinable
  @inline(__always)
  internal func forEach(_ body: (Element) throws -> Void) rethrows {
    var __p = _start
    while __p != _end {
      let __c = __p
      __p = __tree_.__tree_next_iter(__p)
      try body(RawIndex(__c))
    }
  }
  
  @inlinable
  public __consuming func reversed() -> ReversedRawIndexIterator<Tree> {
    .init(tree: __tree_, start: _start, end: _end)
  }
}

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

import Collections

extension ___RedBlackTreeContainerBase {
  
  @inlinable @inline(__always)
  func ___contains(_ __k: _Key) -> Bool where _Key: Equatable {
    _read { tree in
      let it = tree.__lower_bound(__k, tree.__root(), tree.__left_)
      guard it >= 0 else { return false }
      return Self.__key(tree.__element_ptr[it]) == __k
    }
  }
}

extension ___RedBlackTreeContainerBase {

  @inlinable @inline(__always)
  func ___min() -> Element? {
    _read { tree in
      tree.__root() == .nullptr ? nil : tree.___element(tree.__tree_min(tree.__root()))
    }
  }

  @inlinable @inline(__always)
  func ___max() -> Element? {
    _read { tree in
      tree.__root() == .nullptr ? nil : tree.___element(tree.__tree_max(tree.__root()))
    }
  }
}

extension ___RedBlackTreeContainerBase {
  
  @inlinable @inline(__always)
  func ___value_for(_ __k: _Key) -> Element?
  {
    _read {
      let __ptr = $0.find(__k)
      return __ptr < 0 ? nil : ___elements[__ptr]
    }
  }
}

extension ___RedBlackTreeContainerBase {
  
  @inlinable
  public func ___first(where predicate: (Element) throws -> Bool) rethrows -> Element? {
    try _read { tree in
      var result: Element?
      try tree.___for_each(__p: tree.__begin_node, __l: tree.__end_node()) { __p, cont in
        if try predicate(___elements[__p]) {
          result = ___elements[__p]
          cont = false
        }
      }
      return result
    }
  }
}

extension ___RedBlackTreeContainerBase {

#if false
  @inlinable
  func __ref_(_ rhs: _NodeRef) -> _NodePtr {
    _read { tree in
      tree.__ref_(rhs)
    }
  }
  
  @inlinable
  func find(_ __v: _Key) -> _NodePtr {
    _read { tree in
      tree.find(__v)
    }
  }

  @inlinable
  func
    __equal_range_multi(_ __k: _Key) -> (_NodePtr, _NodePtr)
  {
    _read { tree in
      tree.__equal_range_multi(__k)
    }
  }
#endif
}


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

import Foundation

@usableFromInline
protocol ___RedBlackTreeInsert: ___RedBlackTreeUpdate { }

extension ___RedBlackTreeInsert {

  @inlinable
  mutating func __insert_node_at(
    _ __parent: _NodePtr,
    _ __child: _NodeRef,
    _ __new_node: _NodePtr
  ) {
    _update { tree in
      tree.__insert_node_at(__parent, __child, __new_node)
    }
  }
}

// MARK: - Insert Unique

extension ___RedBlackTreeContainerBase {
  
  @inlinable
  func __find_equal(_ __parent: inout _NodePtr, _ __v: _Key) -> _NodeRef {
    _read { tree in
      tree.__find_equal(&__parent, __v)
    }
  }
}

// MARK: - Insert Multi

extension ___RedBlackTreeContainerBase {
  
  @inlinable
  func __find_leaf_high(_ __parent: inout _NodePtr, _ __v: _Key) -> _NodeRef {
    _read { tree in
      tree.__find_leaf_high(&__parent, __v)
    }
  }
}

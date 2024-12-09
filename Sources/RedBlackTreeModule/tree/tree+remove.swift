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
// Copyright © [年] The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.

import Foundation

@usableFromInline
protocol RemoveProtocol: MemberSetProtocol
    & BeginNodeProtocol
    & EndNodeProtocol
    & SizeProtocol
{}

extension RemoveProtocol {

  @inlinable
  func next(_ p: _NodePtr) -> _NodePtr {
    __tree_next_iter(p)
  }

  @inlinable
  func __ptr_(_ p: _NodePtr) -> _NodePtr { p }

  @inlinable
  func iterator(_ p: _NodePtr) -> _NodePtr { p }

  @inlinable
  func static_cast__node_base_pointer(_ p: _NodePtr) -> _NodePtr { p }

  @inlinable
  func __remove_node_pointer(_ __ptr: _NodePtr) -> _NodePtr {
    var __r = iterator(__ptr)
    __r = next(__r)
    if __begin_node == __ptr {
      __begin_node = __ptr_(__r)
    }
    size -= 1
    __tree_remove(__left_(__end_node()), static_cast__node_base_pointer(__ptr))
    return __r
  }
}

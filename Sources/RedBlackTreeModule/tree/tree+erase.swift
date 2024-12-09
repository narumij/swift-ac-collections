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
protocol EraseProtocol: StorageProtocol & EndProtocol {
  func find(_ __v: _Key) -> _NodePtr
  mutating func __remove_node_pointer(_ __ptr: _NodePtr) -> _NodePtr
}

extension EraseProtocol {

  @inlinable
  func __get_np(_ p: _NodePtr) -> _NodePtr { p }

  @inlinable
  mutating func
    erase(_ __p: _NodePtr) -> _NodePtr
  {
    let __np = __get_np(__p)
    let __r = __remove_node_pointer(__np)
    destroy(__p)
    return __r
  }

  @inlinable
  mutating func
    __erase_unique(_ __k: _Key) -> Bool
  {
    let __i = find(__k)
    if __i == end() {
      return false
    }
    _ = erase(__i)
    return true
  }
}

@usableFromInline
protocol EraseProtocol2: EraseProtocol {
  func __equal_range_multi(_ __k: _Key) -> (_NodePtr, _NodePtr)
}

extension EraseProtocol2 {

  @inlinable
  mutating func __erase_multi(_ __k: _Key) -> Int {
    var __p = __equal_range_multi(__k)
    var __r = 0
    while __p.0 != __p.1 {
      defer { __r += 1 }
      __p.0 = erase(__p.0)
    }
    return __r
  }
}

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
protocol BoundProtocol: ValueProtocol & RootProtocol & EndNodeProtocol {}

extension BoundProtocol {

  @inlinable
  @inline(__always)
  func lower_bound(_ __v: _Key) -> _NodePtr {
    return __lower_bound(__v, __root(), __end_node())
  }

  @inlinable
  @inline(__always)
  func upper_bound(_ __v: _Key) -> _NodePtr {
    return __upper_bound(__v, __root(), __end_node())
  }
}

extension ValueProtocol {

  @inlinable
//  @inline(__always)
  func
    __lower_bound(_ __v: _Key, _ __root: _NodePtr, _ __result: _NodePtr) -> _NodePtr
  {
    var (__root, __result) = (__root, __result)

    while __root != .nullptr {
      if !value_comp(__value_(__root), __v) {
        __result = __root
        __root = __left_(__root)
      } else {
        __root = __right_(__root)
      }
    }
    return __result
  }

  @inlinable
//  @inline(__always)
  func
    __upper_bound(_ __v: _Key, _ __root: _NodePtr, _ __result: _NodePtr) -> _NodePtr
  {
    var (__root, __result) = (__root, __result)

    while __root != .nullptr {
      if value_comp(__v, __value_(__root)) {
        __result = __root
        __root = __left_(__root)
      } else {
        __root = __right_(__root)
      }
    }
    return __result
  }
}

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
protocol FindLeafProtocol: ValueProtocol
    & RootProtocol
    & RefProtocol
    & EndNodeProtocol
{}

extension FindLeafProtocol {

  @inlinable
  @inline(__always)
  func
    __find_leaf_low(_ __parent: inout _NodePtr, _ __v: _Key) -> _NodeRef
  {
    var __nd: _NodePtr = __root()
    if __nd != .nullptr {
      while true {
        if value_comp(__value_(__nd), __v) {
          if __right_(__nd) != .nullptr {
            __nd = __right_(__nd)
          } else {
            __parent = __nd
            return __right_ref(__nd)
          }
        } else {
          if __left_unsafe(__nd) != .nullptr {
            __nd = __left_unsafe(__nd)
          } else {
            __parent = __nd
            return __left_ref(__parent)
          }
        }
      }
    }
    __parent = __end_node()
    return __left_ref(__parent)
  }

  @inlinable
  @inline(__always)
  func
    __find_leaf_high(_ __parent: inout _NodePtr, _ __v: _Key) -> _NodeRef
  {
    var __nd: _NodePtr = __root()
    if __nd != .nullptr {
      while true {
        if value_comp(__v, __value_(__nd)) {
          if __left_unsafe(__nd) != .nullptr {
            __nd = __left_unsafe(__nd)
          } else {
            __parent = __nd
            return __left_ref(__parent)
          }
        } else {
          if __right_(__nd) != .nullptr {
            __nd = __right_(__nd)
          } else {
            __parent = __nd
            return __right_ref(__nd)
          }
        }
      }
    }
    __parent = __end_node()
    return __left_ref(__parent)
  }
}

@usableFromInline
protocol FindEqualProtocol: FindProtocol & RefProtocol & RootPtrProtocol {}

extension FindEqualProtocol {

  @inlinable
  @inline(never)
  func
    __find_equal(_ __parent: inout _NodePtr, _ __v: _Key) -> _NodeRef
  {
    var __nd = __root()
    var __nd_ptr = __root_ptr()
    if __nd != .nullptr {
      while true {
        let __value__nd = __value_(__nd)
        if value_comp(__v, __value__nd) {
          if __left_unsafe(__nd) != .nullptr {
            __nd_ptr = __left_ref(__nd)
            __nd = __left_unsafe(__nd)
          } else {
            __parent = __nd
            return __left_ref(__parent)
          }
        } else if value_comp(__value__nd, __v) {
          if __right_(__nd) != .nullptr {
            __nd_ptr = __right_ref(__nd)
            __nd = __right_(__nd)
          } else {
            __parent = __nd
            return __right_ref(__nd)
          }
        } else {
          __parent = __nd
          return __nd_ptr
        }
      }
    }
    __parent = __end_node()
    return __left_ref(__parent)
  }
}

@usableFromInline
protocol FindProtocol: ValueProtocol
    & RootProtocol
    & EndNodeProtocol
    & EndProtocol
{}

extension FindProtocol {

  @inlinable
  @inline(__always)
  func find(_ __v: _Key) -> _NodePtr {
    let __p = __lower_bound(__v, __root(), __end_node())
    if __p != end(), !value_comp(__v, __value_(__p)) {
      return __p
    }
    return end()
  }
}

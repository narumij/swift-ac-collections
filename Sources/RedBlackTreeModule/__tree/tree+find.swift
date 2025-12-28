// Copyright 2024-2025 narumij
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
protocol FindLeafProtocol: ValueProtocol, TreeNodeRefProtocol, RootProtocol, EndNodeProtocol {}

extension FindLeafProtocol {

  @inlinable
  @inline(__always)
  internal func
    __find_leaf_low(_ __parent: inout _NodePtr, _ __v: _Key) -> _NodeRef
  {
    var __nd: _NodePtr = __root()
    if __nd != nullptr {
      while true {
        if value_comp(__get_value(__nd), __v) {
          if __right_(__nd) != nullptr {
            __nd = __right_(__nd)
          } else {
            __parent = __nd
            return __right_ref(__nd)
          }
        } else {
          if __left_unsafe(__nd) != nullptr {
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
  internal func
    __find_leaf_high(_ __parent: inout _NodePtr, _ __v: _Key) -> _NodeRef
  {
    var __nd: _NodePtr = __root()
    if __nd != nullptr {
      while true {
        if value_comp(__v, __get_value(__nd)) {
          if __left_unsafe(__nd) != nullptr {
            __nd = __left_unsafe(__nd)
          } else {
            __parent = __nd
            return __left_ref(__parent)
          }
        } else {
          if __right_(__nd) != nullptr {
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
protocol FindEqualProtocol: ValueProtocol, TreeNodeRefProtocol, RootProtocol, RootPtrProtocol,
  ThreeWayComparatorProtocol
{}

extension FindEqualProtocol {

  @inlinable
  @inline(__always)
  internal func
    __find_equal(_ __v: _Key) -> (__parent: _NodePtr, __child: _NodeRef)
  {
    var __nd = __root()
    if __nd == nullptr {
      return (__end_node(), __left_ref(end))
    }
    var __nd_ptr = __root_ptr()
    let __comp = __lazy_synth_three_way_comparator

    while true {

      let __comp_res = __comp(__v, __get_value(__nd))

      if __comp_res.__less() {
        if __left_unsafe(__nd) == nullptr {
          return (__nd, __left_ref(__nd))
        }

        __nd_ptr = __left_ref(__nd)
        __nd = __left_unsafe(__nd)
      } else if __comp_res.__greater() {
        if __right_(__nd) == nullptr {
          return (__nd, __right_ref(__nd))
        }

        __nd_ptr = __right_ref(__nd)
        __nd = __right_(__nd)
      } else {
        return (__nd, __nd_ptr)
      }
    }
  }
}

@usableFromInline
protocol FindProtocol: BoundProtocol & EndProtocol & FindEqualProtocol {}

extension FindProtocol {

  @inlinable
  @inline(__always)
  internal func find(_ __v: _Key) -> _NodePtr {
    #if true
      let __p = lower_bound(__v)
      if __p != end, !value_comp(__v, __get_value(__p)) {
        return __p
      }
      return end
    #else
      // llvmの__treeに寄せたが、multimapの挙動が変わってしまうので保留
      let (_, __match) = __find_equal(__v)
      if __ptr_(__match) == .nullptr {
        return .end
      }
      return __ptr_(__match)
    #endif
  }
}

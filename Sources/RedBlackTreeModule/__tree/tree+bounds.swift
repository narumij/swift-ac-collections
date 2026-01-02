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
protocol BoundProtocol: BoundAlgorithmProtocol & CompareTrait {}

extension BoundProtocol {

  @inlinable
  @inline(__always)
  internal func lower_bound(_ __v: _Key) -> _NodePtr {
    Self.isMulti ? __lower_bound_multi(__v) : __lower_bound_unique(__v)
  }

  @inlinable
  @inline(__always)
  internal func upper_bound(_ __v: _Key) -> _NodePtr {
    Self.isMulti ? __upper_bound_multi(__v) : __upper_bound_unique(__v)
  }
}

@usableFromInline
protocol BoundAlgorithmProtocol: ValueProtocol & RootProtocol & EndNodeProtocol
    & ThreeWayComparatorProtocol
{}

extension BoundAlgorithmProtocol {

  @inlinable
  @inline(__always)
  internal func
    __lower_upper_bound_unique_impl(_LowerBound: Bool, _ __v: _Key) -> _NodePtr
  {
    var __rt = __root
    var __result = __end_node
    let __comp = __lazy_synth_three_way_comparator
    while __rt != nullptr {
      let __comp_res = __comp(__v, __get_value(__rt))
      if __comp_res.__less() {
        __result = __rt
        __rt = __left_unsafe(__rt)
      } else if __comp_res.__greater() {
        __rt = __right_(__rt)
      } else if _LowerBound {
        return __rt
      } else {
        return __right_(__rt) != nullptr ? __tree_min(__right_(__rt)) : __result
      }
    }
    return __result
  }

  @inlinable
  @inline(__always)
  internal func __lower_bound_unique(_ __v: _Key) -> _NodePtr {
    #if true
      // Benchmarkで速度低下がみられるので、一旦保留
      // 最適化不足かとおもってlower bound専用を試したが変わらなかった
      __lower_upper_bound_unique_impl(_LowerBound: true, __v)
    #else
      __lower_bound_multi(__v, __root, __end_node)
    #endif
  }

  @inlinable
  @inline(__always)
  internal func __upper_bound_unique(_ __v: _Key) -> _NodePtr {
    #if true
      // Benchmarkで速度低下がみられるので、一旦保留
      __lower_upper_bound_unique_impl(_LowerBound: false, __v)
    #else
      __upper_bound_multi(__v, __root, __end_node)
    #endif
  }

  @inlinable
  @inline(__always)
  internal func __lower_bound_multi(_ __v: _Key) -> _NodePtr {
    __lower_bound_multi(__v, __root, __end_node)
  }

  @inlinable
  @inline(__always)
  internal func __upper_bound_multi(_ __v: _Key) -> _NodePtr {
    __upper_bound_multi(__v, __root, __end_node)
  }

  @inlinable
  @inline(__always)
  internal func
    __lower_bound_multi(_ __v: _Key, _ __root: _NodePtr, _ __result: _NodePtr) -> _NodePtr
  {
    var (__root, __result) = (__root, __result)

    while __root != nullptr {
      if !value_comp(__get_value(__root), __v) {
        __result = __root
        __root = __left_unsafe(__root)
      } else {
        __root = __right_(__root)
      }
    }
    return __result
  }

  @inlinable
  @inline(__always)
  internal func
    __upper_bound_multi(_ __v: _Key, _ __root: _NodePtr, _ __result: _NodePtr) -> _NodePtr
  {
    var (__root, __result) = (__root, __result)

    while __root != nullptr {
      if value_comp(__v, __get_value(__root)) {
        __result = __root
        __root = __left_unsafe(__root)
      } else {
        __root = __right_(__root)
      }
    }
    return __result
  }
}

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
protocol CountProtocol: BoundAlgorithmProtocol & DistanceProtocol_std {}

extension CountProtocol {

  @usableFromInline
  typealias size_type = Int

  @usableFromInline
  typealias __node_pointer = _NodePtr

  @usableFromInline
  typealias __iter_pointer = _NodePtr

  @inlinable
  @inline(__always)
  internal func __count_unique(_ __k: _Key) -> size_type {
    var __rt: __node_pointer = __root
    let __comp = __lazy_synth_three_way_comparator
    while __rt != nullptr {
      let __comp_res = __comp(__k, __get_value(__rt))
      if __comp_res.__less() {
        __rt = __left_unsafe(__rt)
      } else if __comp_res.__greater() {
        __rt = __right_(__rt)
      } else {
        return 1
      }
    }
    return 0
  }

  @inlinable
  @inline(__always)
  internal func __count_multi(_ __k: _Key) -> size_type {
    var __result: __iter_pointer = __end_node
    var __rt: __node_pointer = __root
    let __comp = __lazy_synth_three_way_comparator
    while __rt != nullptr {
      let __comp_res = __comp(__k, __get_value(__rt))
      if __comp_res.__less() {
        __result = __rt
        __rt = __left_unsafe(__rt)
      } else if __comp_res.__greater() {
        __rt = __right_(__rt)
      } else {
        return __distance(
          __lower_bound_multi(__k, __left_unsafe(__rt), __rt),
          __upper_bound_multi(__k, __right_(__rt), __result))
      }
    }
    return 0
  }
}

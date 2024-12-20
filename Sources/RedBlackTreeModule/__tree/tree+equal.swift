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

extension EqualProtocol {

  //  template <class _Tp, class _Compare, class _Allocator>
  //  template <class _Key>
  //  pair<typename __tree<_Tp, _Compare, _Allocator>::const_iterator,
  //       typename __tree<_Tp, _Compare, _Allocator>::const_iterator>
  //  __tree<_Tp, _Compare, _Allocator>::__equal_range_multi(const _Key& __k) const {
  //    typedef pair<const_iterator, const_iterator> _Pp;
  //    __iter_pointer __result = __end_node();
  //    __node_pointer __rt     = __root();
  //    while (__rt != nullptr) {
  //      if (value_comp()(__k, __rt->__value_)) {
  //        __result = static_cast<__iter_pointer>(__rt);
  //        __rt     = static_cast<__node_pointer>(__rt->__left_);
  //      } else if (value_comp()(__rt->__value_, __k))
  //        __rt = static_cast<__node_pointer>(__rt->__right_);
  //      else
  //        return _Pp(__lower_bound(__k, static_cast<__node_pointer>(__rt->__left_), static_cast<__iter_pointer>(__rt)),
  //                   __upper_bound(__k, static_cast<__node_pointer>(__rt->__right_), __result));
  //    }
  //    return _Pp(const_iterator(__result), const_iterator(__result));
  //  }

  @inlinable
  func
    __equal_range_multi(_ __k: _Key) -> (_NodePtr, _NodePtr)
  {
    var __result = __end_node()
    var __rt = __root()
    while __rt != .nullptr {
      if value_comp(__k, __value_(__rt)) {
        __result = __rt
        __rt = __left_(__rt)
      } else if value_comp(__value_(__rt), __k) {
        __rt = __right_(__rt)
      } else {
        return (
          __lower_bound(
            __k,
            __left_(__rt),
            __rt),
          __upper_bound(
            __k,
            __right_(__rt),
            __result)
        )
      }
    }
    return (__result, __result)
  }
}

//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-ac-collections project
//
// Copyright (c) 2024 - 2026 narumij.
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// This code is based on work originally distributed under the Apache License 2.0 with LLVM Exceptions:
//
// Copyright © 2003-2026 The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.
//
//===----------------------------------------------------------------------===//

@usableFromInline
protocol EqualProtocol_ptr:
  _UnsafeNodePtrType
    & EndNodeInterface
    & RootInterface
    & EqualInterface
    & _TreeNode_KeyInterface
    & _TreeKey_LazyThreeWayCompInterface
    & _nullptr_interface
{
  func __lower_bound_multi(_ __v: _Key, _ __root: _NodePtr, _ __result: _NodePtr) -> _NodePtr
  func __upper_bound_multi(_ __v: _Key, _ __root: _NodePtr, _ __result: _NodePtr) -> _NodePtr
}

extension EqualProtocol_ptr {

  @inlinable
  @inline(__always)
  internal func
    __equal_range_unique(_ __k: _Key) -> (_NodePtr, _NodePtr)
  {
    var __result = __end_node
    var __rt = __root
    let __comp = __lazy_synth_three_way_comparator
    while __rt != nullptr {
      let __comp_res = __comp(__k, __get_value(__rt))
      if __comp_res.__less() {
        __result = __rt
        __rt = __rt.__left_
      } else if __comp_res.__greater() {
        __rt = __rt.__right_
      } else {
        return (
          __rt,
          __rt.__right_ != nullptr
            ? __tree_min(__rt.__right_)
            : __result
        )
      }
    }
    return (__result, __result)
  }

  @inlinable
  @inline(__always)
  internal func
    __equal_range_multi(_ __k: _Key) -> (_NodePtr, _NodePtr)
  {
    var __result = __end_node
    var __rt = __root
    let __comp = __lazy_synth_three_way_comparator
    while __rt != nullptr {
      let __comp_res = __comp(__k, __get_value(__rt))
      if __comp_res.__less() {
        __result = __rt
        __rt = __rt.__left_
      } else if __comp_res.__greater() {
        __rt = __rt.__right_
      } else {
        return (
          __lower_bound_multi(
            __k,
            __rt.__left_,
            __rt),
          __upper_bound_multi(
            __k,
            __rt.__right_,
            __result)
        )
      }
    }
    return (__result, __result)
  }
}

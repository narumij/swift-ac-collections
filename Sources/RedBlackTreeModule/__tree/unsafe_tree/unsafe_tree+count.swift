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
protocol CountProtocol_ptr:
  _UnsafeNodePtrType
    & EndNodeInterface
    & RootInterface
    & _TreeKey_ThreeWayCompInterface
    & BoundInteface
    & _TreeNode_KeyInterface
    & BoundAlgorithmProtocol_common_ptr
    & NullPtrInterface
where
  _InputIter == _NodePtr,
  difference_type == Int
{
  associatedtype _InputIter
  associatedtype difference_type

  func
    __distance(_ __first: _InputIter, _ __last: _InputIter) -> difference_type
}

extension CountProtocol_ptr {

  @usableFromInline
  typealias size_type = Int

  @usableFromInline
  typealias __node_pointer = _NodePtr

  @usableFromInline
  typealias __iter_pointer = _NodePtr

  @inlinable
  internal func __count_unique(_ __k: _Key) -> size_type {
    var __rt: __node_pointer = __root
    // let __comp = __lazy_synth_three_way_comparator
    while __rt != nullptr {
      let __comp_res = __comp(__k, __get_value(__rt))
      if __comp_res.__less() {
        __rt = __rt.__left_
      } else if __comp_res.__greater() {
        __rt = __rt.__right_
      } else {
        return 1
      }
    }
    return 0
  }

  @inlinable
  internal func __count_multi(_ __k: _Key) -> size_type {
    var __result: __iter_pointer = __end_node
    var __rt: __node_pointer = __root
    // let __comp = __lazy_synth_three_way_comparator
    while __rt != nullptr {
      let __comp_res = __comp(__k, __get_value(__rt))
      if __comp_res.__less() {
        __result = __rt
        __rt = __rt.__left_
      } else if __comp_res.__greater() {
        __rt = __rt.__right_
      } else {
        return __distance(
          __lower_bound_multi(__k, __rt.__left_, __rt),
          __upper_bound_multi(__k, __rt.__right_, __result))
      }
    }
    return 0
  }
}

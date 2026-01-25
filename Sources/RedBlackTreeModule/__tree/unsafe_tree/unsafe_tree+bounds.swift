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
protocol BoundBothProtocol:
  BoundInteface
    & BoundBothInterface
    & IsMultiTraitInterface
{}

extension BoundBothProtocol {

  @inlinable
  @inline(__always)
  internal func lower_bound(_ __v: _Key) -> _NodePtr {
    isMulti ? __lower_bound_multi(__v) : __lower_bound_unique(__v)
  }

  @inlinable
  @inline(__always)
  internal func upper_bound(_ __v: _Key) -> _NodePtr {
    isMulti ? __upper_bound_multi(__v) : __upper_bound_unique(__v)
  }
}

@usableFromInline
protocol BoundAlgorithmProtocol_ptr:
  BoundAlgorithmProtocol_common_ptr
    & _TreeKey_ThreeWayCompInterface
    & _nullptr_interface
{}

extension BoundAlgorithmProtocol_ptr {

  @inlinable
  @inline(__always)
  internal func
    __lower_upper_bound_unique_impl(_LowerBound: Bool, _ __v: _Key) -> _NodePtr
  {
    var __rt = __root
    var __result = __end_node
    // let __comp = __lazy_synth_three_way_comparator
    while __rt != nullptr {
      let __comp_res = __comp(__v, __get_value(__rt))
      if __comp_res.__less() {
        __result = __rt
        __rt = __rt.__left_
      } else if __comp_res.__greater() {
        __rt = __rt.__right_
      } else if _LowerBound {
        return __rt
      } else {
        return __rt.__right_ != nullptr ? __tree_min(__rt.__right_) : __result
      }
    }
    return __result
  }

  @inlinable
  @inline(__always)
  internal func __lower_bound_unique(_ __v: _Key) -> _NodePtr {
    __lower_upper_bound_unique_impl(_LowerBound: true, __v)
  }

  @inlinable
  @inline(__always)
  internal func __upper_bound_unique(_ __v: _Key) -> _NodePtr {
    __lower_upper_bound_unique_impl(_LowerBound: false, __v)
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
}

@usableFromInline
protocol BoundAlgorithmProtocol_common_ptr:
  _UnsafeNodePtrType
    & EndNodeInterface
    & RootInterface
    & _TreeNode_KeyInterface
    & _TreeKey_CompInterface
    & _nullptr_interface
{}

extension BoundAlgorithmProtocol_common_ptr {

  @inlinable
  @inline(__always)
  internal func
    __lower_bound_multi(_ __v: _Key, _ __root: _NodePtr, _ __result: _NodePtr) -> _NodePtr
  {
    var (__root, __result) = (__root, __result)

    while __root != nullptr {
      if !value_comp(__get_value(__root), __v) {
        __result = __root
        __root = __root.__left_
      } else {
        __root = __root.__right_
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
        __root = __root.__left_
      } else {
        __root = __root.__right_
      }
    }
    return __result
  }
}

@usableFromInline
protocol BoundAlgorithmProtocol_old_ptr: BoundAlgorithmProtocol_common_ptr {}

extension BoundAlgorithmProtocol_old_ptr {

  @inlinable
  @inline(__always)
  internal func __lower_bound_unique(_ __v: _Key) -> _NodePtr {
    __lower_bound_multi(__v, __root, __end_node)
  }

  @inlinable
  @inline(__always)
  internal func __upper_bound_unique(_ __v: _Key) -> _NodePtr {
    __upper_bound_multi(__v, __root, __end_node)
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
}

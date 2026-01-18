//
//  unsafe_tree+equal.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/18.
//

@usableFromInline
protocol EqualProtocol_ptr: _UnsafeNodePtrType, EqualInterface, BoundInteface, EndNodeInterface,  RootInterface, ThreeWayComparatorInterface, TreeNodeValueInterface {
  
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
    while __rt != .nullptr {
      let __comp_res = __comp(__k, __get_value(__rt))
      if __comp_res.__less() {
        __result = __rt
        __rt = __rt.__left_
      } else if __comp_res.__greater() {
        __rt = __rt.__right_
      } else {
        return (
          __rt,
          __rt.__right_ != .nullptr
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
    while __rt != .nullptr {
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

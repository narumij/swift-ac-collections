//
//  unsafe_tree+find.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/18.
//

@usableFromInline
protocol FindEqualProtocol_ptr: _UnsafeNodePtrType, ValueCompInterface, RootInterface, RootPtrInterface, EndProtocol, _nullptr_interface, EndNodeProtocol,
  ThreeWayComparatorInterface
{}

extension FindEqualProtocol_ptr {

  @inlinable
  @inline(__always)
  internal func
    __find_equal(_ __v: _Key) -> (__parent: _NodePtr, __child: _NodeRef)
  {
    var __nd = __root
    if __nd == nullptr {
      return (__end_node, end.__left_ref)
    }
    var __nd_ptr = __root_ptr()
    let __comp = __lazy_synth_three_way_comparator

    while true {

      let __comp_res = __comp(__v, __nd.__value_().pointee)

      if __comp_res.__less() {
        if __nd.__left_ == nullptr {
          return (__nd, __nd.__left_ref)
        }

        __nd_ptr = __nd.__left_ref
        __nd = __nd.__left_
      } else if __comp_res.__greater() {
        if __nd.__right_ == nullptr {
          return (__nd, __nd.__right_ref)
        }

        __nd_ptr = __nd.__right_ref
        __nd = __nd.__right_
      } else {
        return (__nd, __nd_ptr)
      }
    }
  }
}

@usableFromInline
protocol FindEqualProtocol_ptr_old: _UnsafeNodePtrType, ValueProtocol,
                                    RootInterface, RootPtrProtocol
{}

extension FindEqualProtocol_ptr_old {

  @inlinable
  @inline(__always)
  func
    __find_equal(_ __v: _Key) -> (__parent: _NodePtr, __child: _NodeRef)
  {
    var __parent: _NodePtr = end
    var __nd = __root
    var __nd_ptr = __root_ptr()
    if __nd != nullptr {
      while true {
        if value_comp(__v, __get_value(__nd)) {
          if __nd.__left_ != .nullptr {
            __nd_ptr = __nd.__left_ref
            __nd = __nd.__left_
          } else {
            __parent = __nd
            return (__parent, __parent.__left_ref)
          }
        } else if value_comp(__get_value(__nd), __v) {
          if __nd.__right_ != nullptr {
            __nd_ptr = __nd.__right_ref
            __nd = __nd.__right_
          } else {
            __parent = __nd
            return (__parent, __nd.__right_ref)
          }
        } else {
          __parent = __nd
          return (__parent, __nd_ptr)
        }
      }
    }
    __parent = __end_node
    return (__parent, __parent.__left_ref)
  }
}

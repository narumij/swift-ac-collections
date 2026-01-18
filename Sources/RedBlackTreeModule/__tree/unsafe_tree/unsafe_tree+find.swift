//
//  unsafe_tree+find.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/18.
//

@usableFromInline
protocol FindEqualProtocol_ptr: _UnsafeNodePtrType, ValueCompInterface, RootInterface,
  RootPtrInterface, EndInterface, EndNodeInterface,
  ThreeWayComparatorInterface
{}

extension FindEqualProtocol_ptr {

  @inlinable
  @inline(__always)
  internal func
    __find_equal(_ __v: _Key) -> (__parent: _NodePtr, __child: _NodeRef)
  {
    var __nd = __root
    if __nd == .nullptr {
      return (__end_node, end.__left_ref)
    }
    var __nd_ptr = __root_ptr()
    let __comp = __lazy_synth_three_way_comparator

    while true {

      let __comp_res = __comp(__v, __nd.__value_().pointee)

      if __comp_res.__less() {
        if __nd.__left_ == .nullptr {
          return (__nd, __nd.__left_ref)
        }

        __nd_ptr = __nd.__left_ref
        __nd = __nd.__left_
      } else if __comp_res.__greater() {
        if __nd.__right_ == .nullptr {
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
  RootInterface, RootPtrInterface, EndNodeInterface
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

@usableFromInline
protocol FindProtocol_ptr: _UnsafeNodePtrType, FindInteface, FindEqualInterface,
  EndInterface
{}

extension FindProtocol_ptr {

  @inlinable
  @inline(__always)
  internal func find(_ __v: _Key) -> _NodePtr {
    #if USE_OLD_FIND
      let __p = lower_bound(__v)
      if __p != end, !value_comp(__v, __get_value(__p)) {
        return __p
      }
      return end
    #else
      // llvmの__treeに寄せたが、multimapの挙動が変わってしまうので保留
      let (_, __match) = __find_equal(__v)
      if __match.pointee == .nullptr {
        return end
      }
      return __match.pointee
    #endif
  }
}

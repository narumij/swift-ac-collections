import Foundation

@usableFromInline
protocol FindLeafEtcProtocol: ValueProtocol
    & RootProtocol
    & RefProtocol
    & EndNodeProtocol
{}

extension FindLeafEtcProtocol {

  @inlinable
  func
    __find_leaf_low(_ __parent: inout _NodePtr, _ __v: _Key) -> _NodeRef
  {
    var __nd: _NodePtr = __root()
    if __nd != .nullptr {
      while true {
        if value_comp(__value_(__nd), __v) {
          if __right_(__nd) != .nullptr {
            __nd = __right_(__nd)
          } else {
            __parent = __nd
            return __right_ref(__nd)
          }
        } else {
          if __left_(__nd) != .nullptr {
            __nd = __left_(__nd)
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
  func
    __find_leaf_high(_ __parent: inout _NodePtr, _ __v: _Key) -> _NodeRef
  {
    var __nd: _NodePtr = __root()
    if __nd != .nullptr {
      while true {
        if value_comp(__v, __value_(__nd)) {
          if __left_(__nd) != .nullptr {
            __nd = __left_(__nd)
          } else {
            __parent = __nd
            return __left_ref(__parent)
          }
        } else {
          if __right_(__nd) != .nullptr {
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
protocol NodeFindEtcProtocol: NodeFindProtocol
    & RefProtocol
    & RootPtrProrototol
{}

extension NodeFindEtcProtocol {

  @inlinable
  @inline(__always)
  func
    addressof(_ p: _NodeRef) -> _NodeRef
  { p }

  @inlinable
  @inline(__always)
  func
    static_cast__node_pointer(_ p: _NodePtr) -> _NodePtr
  { p }

  @inlinable
  @inline(__always)
  func
    static_cast__parent_pointer(_ p: _NodePtr) -> _NodePtr
  { p }
}

extension NodeFindEtcProtocol {

  @inlinable
  func
    __find_equal(_ __parent: inout _NodePtr, _ __v: _Key) -> _NodeRef
  {
    var __nd = __root()
    var __nd_ptr = __root_ptr()
    if __nd != .nullptr {
      while true {
        if value_comp(__v, __value_(__nd)) {
          if __left_(__nd) != .nullptr {
            __nd_ptr = addressof(__left_ref(__nd))
            __nd = static_cast__node_pointer(__left_(__nd))
          } else {
            __parent = static_cast__parent_pointer(__nd)
            return __left_ref(__parent)
          }
        } else if value_comp(__value_(__nd), __v) {
          if __right_(__nd) != .nullptr {
            __nd_ptr = addressof(__right_ref(__nd))
            __nd = static_cast__node_pointer(__right_(__nd))
          } else {
            __parent = static_cast__parent_pointer(__nd)
            return __right_ref(__nd)
          }
        } else {
          __parent = static_cast__parent_pointer(__nd)
          return __nd_ptr
        }
      }
    }
    __parent = static_cast__parent_pointer(__end_node())
    return __left_ref(__parent)
  }
}

@usableFromInline
protocol NodeFindProtocol: ValueProtocol
    & RootProtocol
    & EndNodeProtocol
    & EndProtocol
{}

extension NodeFindProtocol {

  @inlinable
  func find(_ __v: _Key) -> _NodePtr {
    let __p = __lower_bound(__v, __root(), __end_node())
    if __p != end() && !value_comp(__v, __value_(__p)) {
      return __p
    }
    return end()
  }
}

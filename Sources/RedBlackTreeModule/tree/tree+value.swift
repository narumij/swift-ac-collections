import Foundation

extension ValueProtocol {

  @inlinable
  func
    __lower_bound(_ __v: _Key, _ __root: _NodePtr, _ __result: _NodePtr) -> _NodePtr
  {
    var __root = __root
    var __result = __result

    while __root != .nullptr {
      if !value_comp(__value_(__root), __v) {
        __result = __root
        __root = __left_(__root)
      } else {
        __root = __right_(__root)
      }
    }
    return __result
  }

  @inlinable
  func
    __upper_bound(_ __v: _Key, _ __root: _NodePtr, _ __result: _NodePtr) -> _NodePtr
  {
    var __root = __root
    var __result = __result

    while __root != .nullptr {
      if value_comp(__v, __value_(__root)) {
        __result = __root
        __root = __left_(__root)
      } else {
        __root = __right_(__root)
      }
    }
    return __result
  }
}

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

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
protocol FindLeafProtocol_ptr:
  _UnsafeNodePtrType
    & _TreeNode_KeyInterface
    & _TreeKey_CompInterface
    & FindLeafInterface
    & RootInterface
    & RootPtrInterface
    & EndNodeInterface
    & NullPtrInterface
{}

extension FindLeafProtocol_ptr {

  @inlinable
  @inline(__always)
  internal func
    __find_leaf_low(_ __parent: inout _NodePtr, _ __v: _Key) -> _NodeRef
  {
    var __nd: _NodePtr = __root
    if __nd != nullptr {
      while true {
        if value_comp(__get_value(__nd), __v) {
          if __nd.__right_ != nullptr {
            __nd = __nd.__right_
          } else {
            __parent = __nd
            return __nd.__right_ref
          }
        } else {
          if __nd.__left_ != nullptr {
            __nd = __nd.__left_
          } else {
            __parent = __nd
            return __parent.__left_ref
          }
        }
      }
    }
    __parent = __end_node
    return __parent.__left_ref
  }

  @inlinable
  @inline(__always)
  internal func
    __find_leaf_high(_ __parent: inout _NodePtr, _ __v: _Key) -> _NodeRef
  {
    var __nd: _NodePtr = __root
    if __nd != nullptr {
      while true {
        if value_comp(__v, __get_value(__nd)) {
          if __nd.__left_ != nullptr {
            __nd = __nd.__left_
          } else {
            __parent = __nd
            return __parent.__left_ref
          }
        } else {
          if __nd.__right_ != nullptr {
            __nd = __nd.__right_
          } else {
            __parent = __nd
            return __nd.__right_ref
          }
        }
      }
    }
    __parent = __end_node
    return __parent.__left_ref
  }
}

@usableFromInline
protocol FindEqualProtocol_ptr:
  _UnsafeNodePtrType
    & _TreeKey_ThreeWayCompInterface
    & _TreeNode_KeyInterface
    & EndNodeInterface
    & EndInterface
    & RootInterface
    & RootPtrInterface
    & NullPtrInterface
{}

extension FindEqualProtocol_ptr {

  @inlinable
  // @inline(__always)
  internal func
    __find_equal(_ __v: _Key) -> (__parent: _NodePtr, __child: _NodeRef)
  {
    var __nd = __root
    if __nd == nullptr {
      // return (__end_node, end.__left_ref)
      return (__end_node, __root_ptr())
    }
    var __nd_ptr = __root_ptr()
    // let __comp = __lazy_synth_three_way_comparator

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
protocol FindEqualProtocol_ptr_old:
  _UnsafeNodePtrType
    & _TreeKey_CompInterface
    & _TreeNode_KeyInterface
    & RootInterface
    & RootPtrInterface
    & EndNodeInterface
    & EndInterface
    & NullPtrInterface
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
          if __nd.__left_ != nullptr {
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
protocol FindProtocol_ptr:
  _UnsafeNodePtrType
    & FindInteface
    & FindEqualInterface
    & EndInterface
    & NullPtrInterface
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

      // chat gptが言うには、multimapでfindが何を返すかは未規定だから仕様違反ではないそう
      // でもますます使えないことになる

      // https://en.cppreference.com/w/cpp/container/multimap/find.html

      // 1,2) Finds an element with key equivalent to key.If there are several elements with the requested key in the container, any of them may be returned.
      // 確かにどれか返せばいいことになってる

      // https://learn.microsoft.com/en-us/cpp/standard-library/multimap-class?view=msvc-170&utm_source=chatgpt.com

      // Returns an iterator addressing the first location of an element in a multimap that has a key equivalent to a specified key.
      // MSは、先頭になっている

      // 戻すのもありではあるけど、先頭を消す操作はViewで可能なので、注意だけ書く方向にしそう。でもモヤる

      // https://en.cppreference.com/w/cpp/container/multimap.html?utm_source=chatgpt.com

      // The order of the key-value pairs whose keys compare equivalent is the order of insertion and does not change.

      // 同値キーの場合は挿入順となることが保証されている

      let (_, __match) = __find_equal(__v)
      if __match.pointee == nullptr {
        return end
      }
      return __match.pointee
    #endif
  }
}

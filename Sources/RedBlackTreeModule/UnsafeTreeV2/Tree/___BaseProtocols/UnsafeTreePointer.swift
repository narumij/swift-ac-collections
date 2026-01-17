// Copyright 2024-2026 narumij
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
// Copyright © 2003-2025 The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.

public protocol UnsafeTreePointer: _TreePointer
where
  _NodePtr == UnsafeMutablePointer<UnsafeNode>,
  _NodeRef == UnsafeMutablePointer<UnsafeMutablePointer<UnsafeNode>>
{}

@usableFromInline
protocol FindEqualProtocol_ptr: UnsafeTreePointer, ValueProtocol, RootProtocol, RootPtrProtocol,
  ThreeWayComparatorProtocol
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
protocol InsertNodeAtProtocol_ptr: UnsafeTreePointer, InsertNodeAtProtocol, BeginNodeProtocol,
  EndNodeProtocol, SizeProtocol
{}

extension InsertNodeAtProtocol_ptr {

  @inlinable
  @inline(__always)
  internal func
    __insert_node_at(
      _ __parent: _NodePtr, _ __child: _NodeRef,
      _ __new_node: _NodePtr
    )
  {
    var __new_node = __new_node
    __new_node.__left_ = nullptr
    __new_node.__right_ = nullptr
    __new_node.__parent_ = __parent
    // __new_node->__is_black_ is initialized in __tree_balance_after_insert
    __child.pointee = __new_node
    // unsafe operation not allowed
    if __begin_node_.__left_ != nullptr {
      __begin_node_ = __begin_node_.__left_
    }
    _std__tree_balance_after_insert(__end_node.__left_, __child.pointee)
    __size_ += 1
  }
}

@usableFromInline
protocol RemoveProtocol_ptr: UnsafeTreePointer
    & BeginNodeProtocol
    & EndNodeProtocol
    & SizeProtocol
{
  func __remove_node_pointer(_ __ptr: _NodePtr) -> _NodePtr
}

extension RemoveProtocol_ptr {

  @inlinable
  @inline(__always)
  internal func __remove_node_pointer(_ __ptr: _NodePtr) -> _NodePtr {
    var __r = __ptr
    __r = __tree_next_iter(__r)
    if __begin_node_ == __ptr {
      __begin_node_ = __r
    }
    __size_ -= 1
    _std__tree_remove(__end_node.__left_, __ptr)
    return __r
  }
}

@usableFromInline
protocol FindEqualProtocol_ptr_old: UnsafeTreePointer, ValueProtocol,
  RootProtocol, RootPtrProtocol
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

// Copyright 2024 narumij
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
// Copyright © 2003-2024 The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.

import Foundation

@usableFromInline
protocol FindLeafProtocol: ValueProtocol
    & RootProtocol
    & RefProtocol
    & EndNodeProtocol
{}

extension FindLeafProtocol {

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
protocol NodeFindEqualProtocol: NodeFindProtocol
    & RefProtocol
    & RootPtrProrototol
{}

extension NodeFindEqualProtocol {

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

extension NodeFindEqualProtocol {

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

// 辞書型用、作業中
@usableFromInline
protocol NodeFindEqual2Protocol: NodeFindEqualProtocol
    & BeginNodeProtocol
    & BeginProtocol
{}

extension NodeFindEqual2Protocol {

  //  // Find place to insert if __v doesn't exist
  //  // First check prior to __hint.
  //  // Next check after __hint.
  //  // Next do O(log N) search.
  //  // Set __parent to parent of null leaf
  //  // Return reference to null leaf
  //  // If __v exists, set parent to node of __v and return reference to node of __v
  //  template <class _Tp, class _Compare, class _Allocator>
  //  template <class _Key>
  //  typename __tree<_Tp, _Compare, _Allocator>::__node_base_pointer& __tree<_Tp, _Compare, _Allocator>::__find_equal(
  //      const_iterator __hint, __parent_pointer& __parent, __node_base_pointer& __dummy, const _Key& __v) {
  //    if (__hint == end() || value_comp()(__v, *__hint)) // check before
  //    {
  //      // __v < *__hint
  //      const_iterator __prior = __hint;
  //      if (__prior == begin() || value_comp()(*--__prior, __v)) {
  //        // *prev(__hint) < __v < *__hint
  //        if (__hint.__ptr_->__left_ == nullptr) {
  //          __parent = static_cast<__parent_pointer>(__hint.__ptr_);
  //          return __parent->__left_;
  //        } else {
  //          __parent = static_cast<__parent_pointer>(__prior.__ptr_);
  //          return static_cast<__node_base_pointer>(__prior.__ptr_)->__right_;
  //        }
  //      }
  //      // __v <= *prev(__hint)
  //      return __find_equal(__parent, __v);
  //    } else if (value_comp()(*__hint, __v)) // check after
  //    {
  //      // *__hint < __v
  //      const_iterator __next = std::next(__hint);
  //      if (__next == end() || value_comp()(__v, *__next)) {
  //        // *__hint < __v < *std::next(__hint)
  //        if (__hint.__get_np()->__right_ == nullptr) {
  //          __parent = static_cast<__parent_pointer>(__hint.__ptr_);
  //          return static_cast<__node_base_pointer>(__hint.__ptr_)->__right_;
  //        } else {
  //          __parent = static_cast<__parent_pointer>(__next.__ptr_);
  //          return __parent->__left_;
  //        }
  //      }
  //      // *next(__hint) <= __v
  //      return __find_equal(__parent, __v);
  //    }
  //    // else __v == *__hint
  //    __parent = static_cast<__parent_pointer>(__hint.__ptr_);
  //    __dummy  = static_cast<__node_base_pointer>(__hint.__ptr_);
  //    return __dummy;
  //  }
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
    if __p != end(), !value_comp(__v, __value_(__p)) {
      return __p
    }
    return end()
  }
}

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

extension MemberProtocol {

  @inlinable
  @inline(__always)
  func
    __tree_is_left_child(_ __x: _NodePtr) -> Bool
  {
    return __x == __left_(__parent_(__x))
  }

  #if TREE_INVARIANT_CHECKS
    @usableFromInline
    func
      __tree_sub_invariant(_ __x: _NodePtr) -> UInt
    {
      if __x == .nullptr {
        return 1
      }
      // parent consistency checked by caller
      // check __x->__left_ consistency
      if __left_(__x) != .nullptr && __parent_(__left_(__x)) != __x {
        return 0
      }
      // check __x->__right_ consistency
      if __right_(__x) != .nullptr && __parent_(__right_(__x)) != __x {
        return 0
      }
      // check __x->__left_ != __x->__right_ unless both are nullptr
      if __left_(__x) == __right_(__x) && __left_(__x) != .nullptr {
        return 0
      }
      // If this is red, neither child can be red
      if !__is_black_(__x) {
        if __left_(__x) != .nullptr && !__is_black_(__left_(__x)) {
          return 0
        }
        if __right_(__x) != .nullptr && !__is_black_(__right_(__x)) {
          return 0
        }
      }
      let __h = __tree_sub_invariant(__left_(__x))
      if __h == 0 {
        return 0
      }  // invalid left subtree
      if __h != __tree_sub_invariant(__right_(__x)) {
        return 0
      }  // invalid or different height right subtree
      return __h + (__is_black_(__x) ? 1 : 0)  // return black height of this node
    }
  #endif

  #if TREE_INVARIANT_CHECKS
    @usableFromInline
    func
      __tree_invariant(_ __root: _NodePtr) -> Bool
    {
      if __root == .nullptr {
        return true
      }
      // check __x->__parent_ consistency
      if __parent_(__root) == .nullptr {
        return false
      }
      if !__tree_is_left_child(__root) {
        return false
      }
      // root must be black
      if !__is_black_(__root) {
        return false
      }
      // do normal node checks
      return __tree_sub_invariant(__root) != 0
    }
  #else
    @inlinable
    @inline(__always)
    func __tree_invariant(_ __root: _NodePtr) -> Bool { true }
  #endif

  @inlinable
  @inline(__always)
  func
    __tree_min(_ __x: _NodePtr) -> _NodePtr
  {
    assert(__x != .nullptr, "Root node shouldn't be null")
    var __x = __x
    while __left_unsafe(__x) != .nullptr {
      __x = __left_unsafe(__x)
    }
    return __x
  }

  @inlinable
  @inline(__always)
  func
    __tree_max(_ __x: _NodePtr) -> _NodePtr
  {
    assert(__x != .nullptr, "Root node shouldn't be null")
    var __x = __x
    while __right_(__x) != .nullptr {
      __x = __right_(__x)
    }
    return __x
  }

  @inlinable
  @inline(__always)
  func
    __tree_next(_ __x: _NodePtr) -> _NodePtr
  {
    assert(__x != .nullptr, "node shouldn't be null")
    var __x = __x
    if __right_(__x) != .nullptr {
      return __tree_min(__right_(__x))
    }
    while !__tree_is_left_child(__x) {
      __x = __parent_unsafe(__x)
    }
    return __parent_unsafe(__x)
  }

  @inlinable
  @inline(__always)
  public func
    __tree_next_iter(_ __x: _NodePtr) -> _NodePtr
  {
    assert(__x != .nullptr, "node shouldn't be null")
    var __x = __x
    if __right_(__x) != .nullptr {
      return __tree_min(__right_(__x))
    }
    while !__tree_is_left_child(__x) {
      __x = __parent_unsafe(__x)
    }
    return __parent_(__x)
  }

  @inlinable
  @inline(__always)
  public func
    __tree_prev_iter(_ __x: _NodePtr) -> _NodePtr
  {
    assert(__x != .nullptr, "node shouldn't be null")
    if __left_(__x) != .nullptr {
      return __tree_max(__left_(__x))
    }
    var __xx = __x
    while __tree_is_left_child(__xx) {
      __xx = __parent_unsafe(__xx)
    }
    return __parent_unsafe(__xx)
  }

  @inlinable
  @inline(__always)
  func
    __tree_leaf(_ __x: _NodePtr) -> _NodePtr
  {
    assert(__x != .nullptr, "node shouldn't be null")
    var __x = __x
    while true {
      if __left_(__x) != .nullptr {
        __x = __left_(__x)
        continue
      }
      if __right_(__x) != .nullptr {
        __x = __right_(__x)
        continue
      }
      break
    }
    return __x
  }
}

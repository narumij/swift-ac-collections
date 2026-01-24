// Copyright 2024-2025 narumij
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
protocol TreeAlgorithmBaseProtocol_std: TreeAlgorithmInterface & TreeAlgorithmBaseInterface & TreeNodeInterface {}

extension TreeAlgorithmBaseProtocol_std {

  /// Returns:  true if `__x` is a left child of its parent, else false
  /// Precondition:  `__x` != nullptr.
  @inlinable
  @inline(__always)
  package func
    __tree_is_left_child(_ __x: _NodePtr) -> Bool
  {
    // unsafe不可
    return __x == __left_(__parent_(__x))
  }

  #if TREE_INVARIANT_CHECKS
    /// Determines if the subtree rooted at `__x` is a proper red black subtree.  If
    ///    `__x` is a proper subtree, returns the black height (null counts as 1).  If
    ///    `__x` is an improper subtree, returns 0.
    @usableFromInline
    package func
      __tree_sub_invariant(_ __x: _NodePtr) -> UInt
    {
      if __x == nullptr {
        return 1
      }
      // parent consistency checked by caller
      // check __x->__left_ consistency
      if __left_(__x) != nullptr && __parent_(__left_(__x)) != __x {
        return 0
      }
      // check __x->__right_ consistency
      if __right_(__x) != nullptr && __parent_(__right_(__x)) != __x {
        return 0
      }
      // check __x->__left_ != __x->__right_ unless both are nullptr
      if __left_(__x) == __right_(__x) && __left_(__x) != nullptr {
        return 0
      }
      // If this is red, neither child can be red
      if !__is_black_(__x) {
        if __left_(__x) != nullptr && !__is_black_(__left_(__x)) {
          return 0
        }
        if __right_(__x) != nullptr && !__is_black_(__right_(__x)) {
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

    /// Determines if the red black tree rooted at `__root` is a proper red black tree.
    ///    `__root` == nullptr is a proper tree.  Returns true if `__root` is a proper
    ///    red black tree, else returns false.
    @usableFromInline
    package func
      __tree_invariant(_ __root: _NodePtr) -> Bool
    {
      if __root == nullptr {
        return true
      }
      // check __x->__parent_ consistency
      if __parent_(__root) == nullptr {
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
    package func __tree_invariant(_ __root: _NodePtr) -> Bool { true }
  #endif

  /// Returns:  pointer to the left-most node under `__x`.
  @inlinable
  @inline(__always)
  package func
    __tree_min(_ __x: _NodePtr) -> _NodePtr
  {
    assert(__x != nullptr, "Root node shouldn't be null")
    var __x = __x
    while __left_unsafe(__x) != nullptr {
      __x = __left_unsafe(__x)
    }
    return __x
  }

  /// Returns:  pointer to the right-most node under `__x`.
  @inlinable
  @inline(__always)
  package func
    __tree_max(_ __x: _NodePtr) -> _NodePtr
  {
    assert(__x != nullptr, "Root node shouldn't be null")
    var __x = __x
    while __right_(__x) != nullptr {
      __x = __right_(__x)
    }
    return __x
  }

  /// Returns:  pointer to the next in-order node after __x.
  @inlinable
  @inline(__always)
  package func
    __tree_next(_ __x: _NodePtr) -> _NodePtr
  {
    assert(__x != nullptr, "node shouldn't be null")
    var __x = __x
    if __right_(__x) != nullptr {
      return __tree_min(__right_(__x))
    }
    while !__tree_is_left_child(__x) {
      __x = __parent_unsafe(__x)
    }
    return __parent_unsafe(__x)
  }

  /// `__tree_next_iter` and `__tree_prev_iter` implement iteration through the tree. The order is as follows:
  /// left sub-tree -> node -> right sub-tree. When the right-most node of a sub-tree is reached, we walk up the tree until
  /// we find a node where we were in the left sub-tree. We are _always_ in a left sub-tree, since the `__end_node_` points
  /// to the actual root of the tree through a `__left_` pointer. Incrementing the end() pointer is UB, so we can assume that
  /// never happens.
  @inlinable
  @inline(__always)
  package func
    __tree_next_iter(_ __x: _NodePtr) -> _NodePtr
  {
    assert(__x != nullptr, "node shouldn't be null")
    var __x = __x
    if __right_(__x) != nullptr {
      return __tree_min(__right_(__x))
    }
    while !__tree_is_left_child(__x) {
      __x = __parent_unsafe(__x)
    }
    return __parent_(__x)
  }

  /// Returns:  pointer to the previous in-order node before `__x`.
  /// Note: `__x` may be the end node.
  @inlinable
  @inline(__always)
  package func
    __tree_prev_iter(_ __x: _NodePtr) -> _NodePtr
  {
    assert(__x != nullptr, "node shouldn't be null")
    // unsafe not allowed
    if __left_(__x) != nullptr {
      return __tree_max(__left_(__x))
    }
    var __xx = __x
    while __tree_is_left_child(__xx) {
      __xx = __parent_unsafe(__xx)
    }
    return __parent_unsafe(__xx)
  }

  /// Returns:  pointer to a node which has no children
  @inlinable
  @inline(__always)
  package func
    __tree_leaf(_ __x: _NodePtr) -> _NodePtr
  {
    // unsafe不明
    assert(__x != nullptr, "node shouldn't be null")
    var __x = __x
    while true {
      if __left_(__x) != nullptr {
        __x = __left_(__x)
        continue
      }
      if __right_(__x) != nullptr {
        __x = __right_(__x)
        continue
      }
      break
    }
    return __x
  }
}

// MARK: -

// 一般ノード相当の機能
@usableFromInline
package protocol TreeAlgorithmProtocol_std: TreeNodeInterface {}

extension TreeAlgorithmProtocol_std {

  /// Effects:  Makes `__x`->`__right_` the subtree root with `__x` as its left child
  ///           while preserving in-order order.
  @inlinable
  @inline(__always)
  package func
    __tree_left_rotate(_ __x: _NodePtr)
  {
    assert(__x != nullptr, "node shouldn't be null")
    assert(__right_(__x) != nullptr, "node should have a right child")
    let __y = __right_(__x)
    __right_(__x, __left_unsafe(__y))
    if __right_(__x) != nullptr {
      __parent_(__right_(__x), __x)
    }
    __parent_(__y, __parent_(__x))
    if __tree_is_left_child(__x) {
      __left_(__parent_(__x), __y)
    } else {
      __right_(__parent_(__x), __y)
    }
    __left_(__y, __x)
    __parent_(__x, __y)
  }

  /// Effects:  Makes `__x`->`__left_` the subtree root with `__x` as its right child
  ///           while preserving in-order order.
  @inlinable
  @inline(__always)
  package func
    __tree_right_rotate(_ __x: _NodePtr)
  {
    assert(__x != nullptr, "node shouldn't be null")
    assert(__left_(__x) != nullptr, "node should have a left child")
    let __y = __left_unsafe(__x)
    __left_(__x, __right_(__y))
    if __left_unsafe(__x) != nullptr {
      __parent_(__left_unsafe(__x), __x)
    }
    __parent_(__y, __parent_(__x))
    if __tree_is_left_child(__x) {

      __left_(__parent_(__x), __y)
    } else {
      __right_(__parent_(__x), __y)
    }
    __right_(__y, __x)
    __parent_(__x, __y)
  }

  /// Effects:  Rebalances `__root` after attaching `__x` to a leaf.
  /// Precondition:  `__x` has no children.
  ///                `__x` == `__root` or == a direct or indirect child of `__root`.
  ///                If `__x` were to be unlinked from `__root` (setting `__root` to
  ///                  nullptr if `__root` == `__x`), `__tree_invariant(__root)` == true.
  /// Postcondition: `__tree_invariant(end_node->__left_)` == true.  end_node->`__left_`
  ///                may be different than the value passed in as `__root`.
  @inlinable
  @inline(__always)
  package func
    __tree_balance_after_insert(_ __root: _NodePtr, _ __x: _NodePtr)
  {
    assert(__root != nullptr, "Root of the tree shouldn't be null")
    assert(__x != nullptr, "Can't attach null node to a leaf")
    var __x = __x
    __is_black_(__x, __x == __root)
    while __x != __root, !__is_black_(__parent_unsafe(__x)) {
      // __x->__parent_ != __root because __x->__parent_->__is_black == false
      if __tree_is_left_child(__parent_unsafe(__x)) {
        let __y = __right_(__parent_unsafe(__parent_unsafe(__x)))
        if __y != nullptr, !__is_black_(__y) {
          __x = __parent_unsafe(__x)
          __is_black_(__x, true)
          __x = __parent_unsafe(__x)
          __is_black_(__x, __x == __root)
          __is_black_(__y, true)
        } else {
          if !__tree_is_left_child(__x) {
            __x = __parent_unsafe(__x)
            __tree_left_rotate(__x)
          }
          __x = __parent_unsafe(__x)
          __is_black_(__x, true)
          __x = __parent_unsafe(__x)
          __is_black_(__x, false)
          __tree_right_rotate(__x)
          break
        }
      } else {
        let __y = __left_unsafe(__parent_(__parent_unsafe(__x)))
        if __y != nullptr, !__is_black_(__y) {
          __x = __parent_unsafe(__x)
          __is_black_(__x, true)
          __x = __parent_unsafe(__x)
          __is_black_(__x, __x == __root)
          __is_black_(__y, true)
        } else {
          if __tree_is_left_child(__x) {
            __x = __parent_unsafe(__x)
            __tree_right_rotate(__x)
          }
          __x = __parent_unsafe(__x)
          __is_black_(__x, true)
          __x = __parent_unsafe(__x)
          __is_black_(__x, false)
          __tree_left_rotate(__x)
          break
        }
      }
    }
  }

  /// Precondition:  `__z` == `__root` or == a direct or indirect child of `__root`.
  /// Effects:  unlinks `__z` from the tree rooted at `__root`, rebalancing as needed.
  /// Postcondition: `__tree_invariant(end_node->__left_)` == true && end_node->`__left_`
  ///                nor any of its children refer to `__z`.  end_node->`__left_`
  ///                may be different than the value passed in as `__root`.
  @inlinable
  @inline(__always)
  package func
    __tree_remove(_ __root: _NodePtr, _ __z: _NodePtr)
  {
    assert(__root != nullptr, "Root node should not be null")
    assert(__z != nullptr, "The node to remove should not be null")
    assert(__tree_invariant(__root), "The tree invariants should hold")
    var __root = __root
    // __z will be removed from the tree.  Client still needs to destruct/deallocate it
    // __y is either __z, or if __z has two children, __tree_next(__z).
    // __y will have at most one child.
    // __y will be the initial hole in the tree (make the hole at a leaf)
    let __y = (__left_unsafe(__z) == nullptr || __right_(__z) == nullptr) ? __z : __tree_next(__z)
    // __x is __y's possibly null single child
    var __x = __left_unsafe(__y) != nullptr ? __left_unsafe(__y) : __right_(__y)
    // __w is __x's possibly null uncle (will become __x's sibling)
    var __w: _NodePtr = nullptr
    // link __x to __y's parent, and find __w
    if __x != nullptr {
      __parent_(__x, __parent_(__y))
    }
    if __tree_is_left_child(__y) {
      __left_(__parent_(__y), __x)
      if __y != __root {
        __w = __right_(__parent_(__y))
      } else {
        __root = __x
      }  // __w == nullptr
    } else {
      __right_(__parent_(__y), __x)
      // __y can't be root if it is a right child
      __w = __left_unsafe(__parent_(__y))
    }
    let __removed_black = __is_black_(__y)
    // If we didn't remove __z, do so now by splicing in __y for __z,
    //    but copy __z's color.  This does not impact __x or __w.
    if __y != __z {
      // __z->__left_ != nulptr but __z->__right_ might == __x == nullptr
      __parent_(__y, __parent_(__z))
      if __tree_is_left_child(__z) {
        __left_(__parent_(__y), __y)
      } else {
        __right_(__parent_(__y), __y)
      }
      __left_(__y, __left_unsafe(__z))
      __parent_(__left_unsafe(__y), __y)
      __right_(__y, __right_(__z))
      if __right_(__y) != nullptr {
        __parent_(__right_(__y), __y)
      }
      __is_black_(__y, __is_black_(__z))
      if __root == __z {
        __root = __y
      }
    }
    // There is no need to rebalance if we removed a red, or if we removed
    //     the last node.
    if __removed_black && __root != nullptr {
      // Rebalance:
      // __x has an implicit black color (transferred from the removed __y)
      //    associated with it, no matter what its color is.
      // If __x is __root (in which case it can't be null), it is supposed
      //    to be black anyway, and if it is doubly black, then the double
      //    can just be ignored.
      // If __x is red (in which case it can't be null), then it can absorb
      //    the implicit black just by setting its color to black.
      // Since __y was black and only had one child (which __x points to), __x
      //   is either red with no children, else null, otherwise __y would have
      //   different black heights under left and right pointers.
      // if (__x == __root || __x != nullptr && !__x->__is_black_)
      if __x != nullptr {
        __is_black_(__x, true)
      } else {
        //  Else __x isn't root, and is "doubly black", even though it may
        //     be null.  __w can not be null here, else the parent would
        //     see a black height >= 2 on the __x side and a black height
        //     of 1 on the __w side (__w must be a non-null black or a red
        //     with a non-null black child).
        while true {
          if !__tree_is_left_child(__w)  // if x is left child
          {
            if !__is_black_(__w) {
              __is_black_(__w, true)
              __is_black_(__parent_(__w), false)
              __tree_left_rotate(__parent_(__w))
              // __x is still valid
              // reset __root only if necessary
              if __root == __left_unsafe(__w) {
                __root = __w
              }
              // reset sibling, and it still can't be null
              __w = __right_(__left_unsafe(__w))
            }
            // __w->__is_black_ is now true, __w may have null children
            if (__left_unsafe(__w) == nullptr || __is_black_(__left_unsafe(__w)))
              && (__right_(__w) == nullptr || __is_black_(__right_(__w)))
            {
              __is_black_(__w, false)
              __x = __parent_(__w)
              // __x can no longer be null
              if __x == __root || !__is_black_(__x) {
                __is_black_(__x, true)
                break
              }
              // reset sibling, and it still can't be null
              __w =
                __tree_is_left_child(__x) ? __right_(__parent_(__x)) : __left_unsafe(__parent_(__x))
              // continue;
            } else  // __w has a red child
            {
              if __right_(__w) == nullptr || __is_black_(__right_(__w)) {
                // __w left child is non-null and red
                __is_black_(__left_unsafe(__w), true)
                __is_black_(__w, false)
                __tree_right_rotate(__w)
                // __w is known not to be root, so root hasn't changed
                // reset sibling, and it still can't be null
                __w = __parent_(__w)
              }
              // __w has a right red child, left child may be null
              __is_black_(__w, __is_black_(__parent_(__w)))
              __is_black_(__parent_(__w), true)
              __is_black_(__right_(__w), true)
              __tree_left_rotate(__parent_(__w))
              break
            }
          } else {
            if !__is_black_(__w) {
              __is_black_(__w, true)
              __is_black_(__parent_(__w), false)
              __tree_right_rotate(__parent_(__w))
              // __x is still valid
              // reset __root only if necessary
              if __root == __right_(__w) {
                __root = __w
              }
              // reset sibling, and it still can't be null
              __w = __left_unsafe(__right_(__w))
            }
            // __w->__is_black_ is now true, __w may have null children
            if (__left_unsafe(__w) == nullptr || __is_black_(__left_unsafe(__w)))
              && (__right_(__w) == nullptr || __is_black_(__right_(__w)))
            {
              __is_black_(__w, false)
              __x = __parent_(__w)
              // __x can no longer be null
              if !__is_black_(__x) || __x == __root {
                __is_black_(__x, true)
                break
              }
              // reset sibling, and it still can't be null
              __w =
                __tree_is_left_child(__x) ? __right_(__parent_(__x)) : __left_unsafe(__parent_(__x))
              // continue;
            } else  // __w has a red child
            {
              if __left_unsafe(__w) == nullptr || __is_black_(__left_unsafe(__w)) {
                // __w right child is non-null and red
                __is_black_(__right_(__w), true)
                __is_black_(__w, false)
                __tree_left_rotate(__w)
                // __w is known not to be root, so root hasn't changed
                // reset sibling, and it still can't be null
                __w = __parent_(__w)
              }
              // __w has a left red child, right child may be null
              __is_black_(__w, __is_black_(__parent_(__w)))
              __is_black_(__parent_(__w), true)
              __is_black_(__left_unsafe(__w), true)
              __tree_right_rotate(__parent_(__w))
              break
            }
          }
        }
      }
    }
  }
}

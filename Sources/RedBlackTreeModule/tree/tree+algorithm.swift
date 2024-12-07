import Foundation

extension MemberSetProtocol {

  @inlinable
  func
    __tree_left_rotate(_ __x: _NodePtr)
  {
    assert(__x != .nullptr, "node shouldn't be null")
    assert(__right_(__x) != .nullptr, "node should have a right child")
    let __y = __right_(__x)
    __right_(__x, __left_(__y))
    if __right_(__x) != .nullptr {
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

  @inlinable
  func
    __tree_right_rotate(_ __x: _NodePtr)
  {
    assert(__x != .nullptr, "node shouldn't be null")
    assert(__left_(__x) != .nullptr, "node should have a left child")
    let __y = __left_(__x)
    __left_(__x, __right_(__y))
    if __left_(__x) != .nullptr {
      __parent_(__left_(__x), __x)
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

  @inlinable
  func
    __tree_balance_after_insert(_ __root: _NodePtr, _ __x: _NodePtr)
  {
    assert(__root != .nullptr, "Root of the tree shouldn't be null")
    assert(__x != .nullptr, "Can't attach null node to a leaf")
    var __x = __x
    __is_black_(__x, __x == __root)
    while __x != __root && !__is_black_(__parent_unsafe(__x)) {
      // __x->__parent_ != __root because __x->__parent_->__is_black == false
      if __tree_is_left_child(__parent_unsafe(__x)) {
        let __y = __right_(__parent_unsafe(__parent_unsafe(__x)))
        if __y != .nullptr && !__is_black_(__y) {
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
        let __y = __left_(__parent_(__parent_unsafe(__x)))
        if __y != .nullptr && !__is_black_(__y) {
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

  @inlinable
  func
    __tree_remove(_ __root: _NodePtr, _ __z: _NodePtr)
  {
    assert(__root != .nullptr, "Root node should not be null")
    assert(__z != .nullptr, "The node to remove should not be null")
    assert(__tree_invariant(__root), "The tree invariants should hold")
    var __root = __root
    // __z will be removed from the tree.  Client still needs to destruct/deallocate it
    // __y is either __z, or if __z has two children, __tree_next(__z).
    // __y will have at most one child.
    // __y will be the initial hole in the tree (make the hole at a leaf)
    let __y = (__left_(__z) == .nullptr || __right_(__z) == .nullptr) ? __z : __tree_next(__z)
    // __x is __y's possibly null single child
    var __x = __left_(__y) != .nullptr ? __left_(__y) : __right_(__y)
    // __w is __x's possibly null uncle (will become __x's sibling)
    var __w: _NodePtr = .nullptr
    // link __x to __y's parent, and find __w
    if __x != .nullptr {
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
      __w = __left_(__parent_(__y))
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
      __left_(__y, __left_(__z))
      __parent_(__left_(__y), __y)
      __right_(__y, __right_(__z))
      if __right_(__y) != .nullptr {
        __parent_(__right_(__y), __y)
      }
      __is_black_(__y, __is_black_(__z))
      if __root == __z {
        __root = __y
      }
    }
    // There is no need to rebalance if we removed a red, or if we removed
    //     the last node.
    if __removed_black && __root != .nullptr {
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
      if __x != .nullptr {
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
              if __root == __left_(__w) {
                __root = __w
              }
              // reset sibling, and it still can't be null
              __w = __right_(__left_(__w))
            }
            // __w->__is_black_ is now true, __w may have null children
            if (__left_(__w) == .nullptr || __is_black_(__left_(__w)))
              && (__right_(__w) == .nullptr || __is_black_(__right_(__w)))
            {
              __is_black_(__w, false)
              __x = __parent_(__w)
              // __x can no longer be null
              if __x == __root || !__is_black_(__x) {
                __is_black_(__x, true)
                break
              }
              // reset sibling, and it still can't be null
              __w = __tree_is_left_child(__x) ? __right_(__parent_(__x)) : __left_(__parent_(__x))
              // continue;
            } else  // __w has a red child
            {
              if __right_(__w) == .nullptr || __is_black_(__right_(__w)) {
                // __w left child is non-null and red
                __is_black_(__left_(__w), true)
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
              __w = __left_(__right_(__w))
            }
            // __w->__is_black_ is now true, __w may have null children
            if (__left_(__w) == .nullptr || __is_black_(__left_(__w)))
              && (__right_(__w) == .nullptr || __is_black_(__right_(__w)))
            {
              __is_black_(__w, false)
              __x = __parent_(__w)
              // __x can no longer be null
              if !__is_black_(__x) || __x == __root {
                __is_black_(__x, true)
                break
              }
              // reset sibling, and it still can't be null
              __w = __tree_is_left_child(__x) ? __right_(__parent_(__x)) : __left_(__parent_(__x))
              // continue;
            } else  // __w has a red child
            {
              if __left_(__w) == .nullptr || __is_black_(__left_(__w)) {
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
              __is_black_(__left_(__w), true)
              __tree_right_rotate(__parent_(__w))
              break
            }
          }
        }
      }
    }
  }
}

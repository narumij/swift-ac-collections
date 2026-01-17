/*

_NodePtr algorithms

The algorithms taking _NodePtr are red black tree algorithms.  Those
algorithms taking a parameter named __root should assume that __root
points to a proper red black tree (unless otherwise specified).

Each algorithm herein assumes that __root->__parent_ points to a non-null
structure which has a member __left_ which points back to __root.  No other
member is read or written to at __root->__parent_.

__root->__parent_ will be referred to below (in comments only) as end_node.
end_node->__left_ is an externably accessible lvalue for __root, and can be
changed by node insertion and removal (without explicit reference to end_node).

All nodes (with the exception of end_node), even the node referred to as
__root, have a non-null __parent_ field.

*/

/// Returns:  true if `__x` is a left child of its parent, else false
/// Precondition:  `__x` != nullptr.
@inlinable
@inline(__always)
internal func
  __tree_is_left_child(_ __x: UnsafeMutablePointer<UnsafeNode>) -> Bool
{
  __x == __x.__parent_.__left_
}

/// Determines if the subtree rooted at `__x` is a proper red black subtree.  If
///    `__x` is a proper subtree, returns the black height (null counts as 1).  If
///    `__x` is an improper subtree, returns 0.
@usableFromInline
internal func
  __tree_sub_invariant(_ __x: UnsafeMutablePointer<UnsafeNode>) -> UInt
{
  if __x == .nullptr {
    return 1
  }
  // parent consistency checked by caller
  // check __x->__left_ consistency
  if __x.__left_ != .nullptr && __x.__left_.__parent_ != __x {
    return 0
  }
  // check __x->__right_ consistency
  if __x.__right_ != .nullptr && __x.__right_.__parent_ != __x {
    return 0
  }
  // check __x->__left_ != __x->__right_ unless both are nullptr
  if __x.__left_ == __x.__right_ && __x.__left_ != .nullptr {
    return 0
  }
  // If this is red, neither child can be red
  if !__x.__is_black_ {
    if __x.__left_ != .nullptr && !__x.__left_.__is_black_ {
      return 0
    }
    if __x.__right_ != .nullptr && !__x.__right_.__is_black_ {
      return 0
    }
  }
  let __h = __tree_sub_invariant(__x.__left_)
  if __h == 0 {
    return 0
  }  // invalid left subtree
  if __h != __tree_sub_invariant(__x.__right_) {
    return 0
  }  // invalid or different height right subtree
  return __h + (__x.__is_black_ ? 1 : 0)  // return black height of this node
}

/// Determines if the red black tree rooted at `__root` is a proper red black tree.
///    `__root` == nullptr is a proper tree.  Returns true if `__root` is a proper
///    red black tree, else returns false.
@usableFromInline
internal func
  __tree_invariant(_ __root: UnsafeMutablePointer<UnsafeNode>) -> Bool
{
  if __root == .nullptr {
    return true
  }
  // check __x->__parent_ consistency
  if __root.__parent_ == .nullptr {
    return false
  }
  if !__tree_is_left_child(__root) {
    return false
  }
  // root must be black
  if !__root.__is_black_ {
    return false
  }
  // do normal node checks
  return __tree_sub_invariant(__root) != 0
}

/// Returns:  pointer to the left-most node under `__x`.
@inlinable
internal func
  __tree_min(_ __x: UnsafeMutablePointer<UnsafeNode>) -> UnsafeMutablePointer<UnsafeNode>
{
  assert(__x != .nullptr, "Root node shouldn't be null")
  var __x = __x
  while __x.__left_ != .nullptr {
    __x = __x.__left_
  }
  return __x
}

/// Returns:  pointer to the right-most node under `__x`.
@inlinable
internal func
  __tree_max(_ __x: UnsafeMutablePointer<UnsafeNode>) -> UnsafeMutablePointer<UnsafeNode>
{
  assert(__x != .nullptr, "Root node shouldn't be null")
  var __x = __x
  while __x.__right_ != .nullptr {
    __x = __x.__right_
  }
  return __x
}

/// Returns:  pointer to the next in-order node after __x.
@inlinable
internal func
  __tree_next(_ __x: UnsafeMutablePointer<UnsafeNode>) -> UnsafeMutablePointer<UnsafeNode>
{
  assert(__x != .nullptr, "node shouldn't be null")
  var __x = __x
  if __x.__right_ != .nullptr {
    return __tree_min(__x.__right_)
  }
  while !__tree_is_left_child(__x) {
    __x = __x.__parent_unsafe
  }
  return __x.__parent_unsafe
}

/// `__tree_next_iter` and `__tree_prev_iter` implement iteration through the tree. The order is as follows:
/// left sub-tree -> node -> right sub-tree. When the right-most node of a sub-tree is reached, we walk up the tree until
/// we find a node where we were in the left sub-tree. We are _always_ in a left sub-tree, since the `__end_node_` points
/// to the actual root of the tree through a `__left_` pointer. Incrementing the end() pointer is UB, so we can assume that
/// never happens.
@inlinable
internal func
  __tree_next_iter(_ __x: UnsafeMutablePointer<UnsafeNode>) -> UnsafeMutablePointer<UnsafeNode>
{
  assert(__x != .nullptr, "node shouldn't be null")
  var __x = __x
  if __x.__right_ != .nullptr {
    return __tree_min(__x.__right_)
  }
  while !__tree_is_left_child(__x) {
    __x = __x.__parent_unsafe
  }
  return __x.__parent_
}

/// Returns:  pointer to the previous in-order node before `__x`.
/// Note: `__x` may be the end node.
@inlinable
internal func
  __tree_prev_iter(_ __x: UnsafeMutablePointer<UnsafeNode>) -> UnsafeMutablePointer<UnsafeNode>
{
  assert(__x != .nullptr, "node shouldn't be null")
  // unsafe not allowed
  if __x.__left_ != .nullptr {
    return __tree_max(__x.__left_)
  }
  var __xx = __x
  while __tree_is_left_child(__xx) {
    __xx = __xx.__parent_unsafe
  }
  return __xx.__parent_unsafe
}

/// Returns:  pointer to a node which has no children
@inlinable
internal func
  __tree_leaf(_ __x: UnsafeMutablePointer<UnsafeNode>) -> UnsafeMutablePointer<UnsafeNode>
{
  // unsafe不明
  assert(__x != .nullptr, "node shouldn't be null")
  var __x = __x
  while true {
    if __x.__left_ != .nullptr {
      __x = __x.__left_
      continue
    }
    if __x.__right_ != .nullptr {
      __x = __x.__right_
      continue
    }
    break
  }
  return __x
}

/// Effects:  Makes `__x`->`__right_` the subtree root with `__x` as its left child
///           while preserving in-order order.
@inlinable
@inline(__always)
internal func
  __tree_left_rotate(_ __x: UnsafeMutablePointer<UnsafeNode>)
{
  var __x = __x
  assert(__x != .nullptr, "node shouldn't be null")
  assert(__x.__right_ != .nullptr, "node should have a right child")
  var __y = __x.__right_
  __x.__right_ = __y.__left_
  if __x.__right_ != .nullptr {
    __x.__right_.__parent_ = __x
  }
  __y.__parent_ = __x.__parent_
  if __tree_is_left_child(__x) {
    __x.__parent_.__left_ = __y
  } else {
    __x.__parent_unsafe.__right_ = __y
  }
  __y.__left_ = __x
  __x.__parent_ = __y
}

/// Effects:  Makes `__x`->`__left_` the subtree root with `__x` as its right child
///           while preserving in-order order.
@inlinable
@inline(__always)
internal func
  __tree_right_rotate(_ __x: UnsafeMutablePointer<UnsafeNode>)
{
  var __x = __x
  assert(__x != .nullptr, "node shouldn't be null")
  assert(__x.__left_ != .nullptr, "node should have a left child")
  var __y = __x.__left_
  __x.__left_ = __y.__right_
  if __x.__left_ != .nullptr {
    __x.__left_.__parent_ = __x
  }
  __y.__parent_ = __x.__parent_
  if __tree_is_left_child(__x) {
    __x.__parent_.__left_ = __y
  } else {
    __x.__parent_unsafe.__right_ = __y
  }
  __y.__right_ = __x
  __x.__parent_ = __y
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
internal func
  _std__tree_balance_after_insert(
    _ __root: UnsafeMutablePointer<UnsafeNode>, _ __x: UnsafeMutablePointer<UnsafeNode>
  )
{
  var __x = __x
  assert(__root != .nullptr, "Root of the tree shouldn't be null")
  assert(__x != .nullptr, "Can't attach null node to a leaf")
  __x.__is_black_ = __x == __root
  while __x != __root, !__x.__parent_unsafe.__is_black_ {
    // __x->__parent_ != __root because __x->__parent_->__is_black == false
    if __tree_is_left_child(__x.__parent_unsafe) {
      var __y = __x.__parent_unsafe.__parent_unsafe.__right_
      if __y != .nullptr, !__y.__is_black_ {
        __x = __x.__parent_unsafe
        __x.__is_black_ = true
        __x = __x.__parent_unsafe
        __x.__is_black_ = __x == __root
        __y.__is_black_ = true
      } else {
        if !__tree_is_left_child(__x) {
          __x = __x.__parent_unsafe
          __tree_left_rotate(__x)
        }
        __x = __x.__parent_unsafe
        __x.__is_black_ = true
        __x = __x.__parent_unsafe
        __x.__is_black_ = false
        __tree_right_rotate(__x)
        break
      }
    } else {
      var __y = __x.__parent_unsafe.__parent_.__left_
      if __y != .nullptr, !__y.__is_black_ {
        __x = __x.__parent_unsafe
        __x.__is_black_ = true
        __x = __x.__parent_unsafe
        __x.__is_black_ = __x == __root
        __y.__is_black_ = true
      } else {
        if __tree_is_left_child(__x) {
          __x = __x.__parent_unsafe
          __tree_right_rotate(__x)
        }
        __x = __x.__parent_unsafe
        __x.__is_black_ = true
        __x = __x.__parent_unsafe
        __x.__is_black_ = false
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
internal func
  _std__tree_remove(
    _ __root: UnsafeMutablePointer<UnsafeNode>, _ __z: UnsafeMutablePointer<UnsafeNode>
  )
{
  typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>
  assert(__root != .nullptr, "Root node should not be null")
  assert(__z != .nullptr, "The node to remove should not be null")
  assert(__tree_invariant(__root), "The tree invariants should hold")
  var __root = __root
  // __z will be removed from the tree.  Client still needs to destruct/deallocate it
  // __y is either __z, or if __z has two children, __tree_next(__z).
  // __y will have at most one child.
  // __y will be the initial hole in the tree (make the hole at a leaf)
  var __y = (__z.__left_ == .nullptr || __z.__right_ == .nullptr) ? __z : __tree_next(__z)
  // __x is __y's possibly null single child
  var __x = __y.__left_ != .nullptr ? __y.__left_ : __y.__right_
  // __w is __x's possibly null uncle (will become __x's sibling)
  var __w: _NodePtr = .nullptr
  // link __x to __y's parent, and find __w
  if __x != .nullptr {
    __x.__parent_ = __y.__parent_
  }
  if __tree_is_left_child(__y) {
    __y.__parent_.__left_ = __x
    if __y != __root {
      __w = __y.__parent_unsafe.__right_
    } else {
      __root = __x
    }  // __w == nullptr
  } else {
    __y.__parent_unsafe.__right_ = __x
    // __y can't be root if it is a right child
    __w = __y.__parent_.__left_
  }
  let __removed_black = __y.__is_black_
  // If we didn't remove __z, do so now by splicing in __y for __z,
  //    but copy __z's color.  This does not impact __x or __w.
  if __y != __z {
    // __z->__left_ != nulptr but __z->__right_ might == __x == nullptr
    __y.__parent_ = __z.__parent_
    if __tree_is_left_child(__z) {
      __y.__parent_.__left_ = __y
    } else {
      __y.__parent_unsafe.__right_ = __y
    }
    __y.__left_ = __z.__left_
    __y.__left_.__set_parent = __y
    __y.__right_ = __z.__right_
    if __y.__right_ != .nullptr {
      __y.__right_.__set_parent = __y
    }
    __y.__is_black_ = __z.__is_black_
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
      __x.__is_black_ = true
    } else {
      //  Else __x isn't root, and is "doubly black", even though it may
      //     be null.  __w can not be null here, else the parent would
      //     see a black height >= 2 on the __x side and a black height
      //     of 1 on the __w side (__w must be a non-null black or a red
      //     with a non-null black child).
      while true {
        if !__tree_is_left_child(__w)  // if x is left child
        {
          if !__w.__is_black_ {
            __w.__is_black_ = true
            __w.__parent_unsafe.__is_black_ = false
            __tree_left_rotate(__w.__parent_unsafe)
            // __x is still valid
            // reset __root only if necessary
            if __root == __w.__left_ {
              __root = __w
            }
            // reset sibling, and it still can't be null
            __w = __w.__left_.__right_
          }
          // __w->__is_black_ is now true, __w may have null children
          if __w.__left_ == .nullptr || __w.__left_.__is_black_,
            __w.__right_ == .nullptr || __w.__right_.__is_black_
          {
            __w.__is_black_ = false
            __x = __w.__parent_unsafe
            // __x can no longer be null
            if __x == __root || !__x.__is_black_ {
              __x.__is_black_ = true
              break
            }
            // reset sibling, and it still can't be null
            __w = __tree_is_left_child(__x) ? __x.__parent_unsafe.__right_ : __x.__parent_.__left_
            // continue;
          } else  // __w has a red child
          {
            if __w.__right_ == .nullptr || __w.__right_.__is_black_ {
              // __w left child is non-null and red
              __w.__left_.__is_black_ = true
              __w.__is_black_ = false
              __tree_right_rotate(__w)
              // __w is known not to be root, so root hasn't changed
              // reset sibling, and it still can't be null
              __w = __w.__parent_unsafe
            }
            // __w has a right red child, left child may be null
            __w.__is_black_ = __w.__parent_unsafe.__is_black_
            __w.__parent_unsafe.__is_black_ = true
            __w.__right_.__is_black_ = true
            __tree_left_rotate(__w.__parent_unsafe)
            break
          }
        } else {
          if !__w.__is_black_ {
            __w.__is_black_ = true
            __w.__parent_unsafe.__is_black_ = false
            __tree_right_rotate(__w.__parent_unsafe)
            // __x is still valid
            // reset __root only if necessary
            if __root == __w.__right_ {
              __root = __w
            }
            // reset sibling, and it still can't be null
            __w = __w.__right_.__left_
          }
          // __w->__is_black_ is now true, __w may have null children
          if __w.__left_ == .nullptr || __w.__left_.__is_black_,
            __w.__right_ == .nullptr || __w.__right_.__is_black_
          {
            __w.__is_black_ = false
            __x = __w.__parent_unsafe
            // __x can no longer be null
            if !__x.__is_black_ || __x == __root {
              __x.__is_black_ = true
              break
            }
            // reset sibling, and it still can't be null
            __w = __tree_is_left_child(__x) ? __x.__parent_unsafe.__right_ : __x.__parent_.__left_
            // continue;
          } else  // __w has a red child
          {
            if __w.__left_ == .nullptr || __w.__left_.__is_black_ {
              // __w right child is non-null and red
              __w.__right_.__is_black_ = true
              __w.__is_black_ = false
              __tree_left_rotate(__w)
              // __w is known not to be root, so root hasn't changed
              // reset sibling, and it still can't be null
              __w = __w.__parent_unsafe
            }
            // __w has a left red child, right child may be null
            __w.__is_black_ = __w.__parent_unsafe.__is_black_
            __w.__parent_unsafe.__is_black_ = true
            __w.__left_.__is_black_ = true
            __tree_right_rotate(__w.__parent_unsafe)
            break
          }
        }
      }
    }
  }
}

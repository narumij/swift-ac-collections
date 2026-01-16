//
//  UnsafeMutablePointer+UnsafeNode+_tree.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/17.
//

/// Returns:  true if `__x` is a left child of its parent, else false
/// Precondition:  `__x` != nullptr.
@inlinable
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

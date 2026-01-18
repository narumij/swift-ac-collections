//
//  unsafe_tree+insert.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/18.
//

@usableFromInline
protocol InsertNodeAtProtocol_ptr: UnsafeTreePointer, InsertNodeAtProtocol, BeginNodeProtocol,
  EndNodeProtocol, SizeProtocol
{}

extension InsertNodeAtProtocol_ptr {

  @inlinable
  @inline(never)
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

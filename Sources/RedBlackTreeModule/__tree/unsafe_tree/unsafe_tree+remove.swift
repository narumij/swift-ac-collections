//
//  unsafe_tree+remove.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/18.
//

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

//
//  unsafe_tree+remove.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/18.
//

@usableFromInline
protocol RemoveProtocol_ptr:
  _UnsafeNodePtrType
    & BeginNodeInterface
    & EndNodeInterface
    & RootInterface
    & SizeInterface
    & RemoveInteface
{}

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
    // _std__tree_remove(__end_node.__left_, __ptr)
    _std__tree_remove(__root, __ptr)
    return __r
  }

  @inlinable
  @inline(__always)
  internal func ___remove_node_pointer(_ __ptr: _NodePtr) {
    if __begin_node_ == __ptr {
      // 単に要素を削除したい場合、無駄な手間になるので限定してみた
      __begin_node_ = __tree_next_iter(__ptr)
    }
    __size_ -= 1
    // __root等は、llvmと異なり木の保持の仕方がリッチなうえ型チェックが邪魔なので直接とった方がいい
    _std__tree_remove(__root, __ptr)
  }
}

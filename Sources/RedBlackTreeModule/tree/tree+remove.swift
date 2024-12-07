import Foundation

@usableFromInline
protocol RemoveProtocol: MemberSetProtocol
    & BeginNodeProtocol
    & EndNodeProtocol
    & SizeProtocol
{}

extension RemoveProtocol {

  @inlinable
  func next(_ p: _NodePtr) -> _NodePtr {
    __tree_next_iter(p)
  }

  @inlinable
  func __ptr_(_ p: _NodePtr) -> _NodePtr { p }

  @inlinable
  func iterator(_ p: _NodePtr) -> _NodePtr { p }

  @inlinable
  func static_cast__node_base_pointer(_ p: _NodePtr) -> _NodePtr { p }

  @inlinable
  func __remove_node_pointer(_ __ptr: _NodePtr) -> _NodePtr {
    var __r = iterator(__ptr)
    __r = next(__r)
    if __begin_node == __ptr {
      __begin_node = __ptr_(__r)
    }
    size -= 1
    __tree_remove(__left_(__end_node()), static_cast__node_base_pointer(__ptr))
    return __r
  }
}

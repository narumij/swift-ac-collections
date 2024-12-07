import Foundation

@frozen
@usableFromInline
struct _UnsafeMutatingHandle<VC> where VC: ValueComparer {

  @inlinable @inline(__always)
  init(
    __header_ptr: UnsafeMutablePointer<RedBlackTree.Header>,
    __node_ptr: UnsafeMutablePointer<RedBlackTree.Node>,
    __value_ptr: UnsafeMutablePointer<Element>
  ) {
    self.__header_ptr = __header_ptr
    self.__node_ptr = __node_ptr
    self.__value_ptr = __value_ptr
  }
  @usableFromInline
  let __header_ptr: UnsafeMutablePointer<RedBlackTree.Header>
  @usableFromInline
  let __node_ptr: UnsafeMutablePointer<RedBlackTree.Node>
  @usableFromInline
  let __value_ptr: UnsafeMutablePointer<Element>
}

extension _UnsafeMutatingHandle: _UnsafeHandleCommon {

  @inlinable func __value_(_ p: _NodePtr) -> _Key {
    __value_(__value_ptr[p])
  }
}

extension _UnsafeMutatingHandle: UpdateHandleImpl {}
extension _UnsafeMutatingHandle: NodeFindProtocol & NodeFindEtcProtocol {}
extension _UnsafeMutatingHandle: NodeInsertProtocol {}
extension _UnsafeMutatingHandle: RemoveProtocol {}

@usableFromInline
protocol _UnsafeMutatingHandleBase {
  associatedtype VC: ValueComparer
  mutating func _update<R>(_ body: (_UnsafeMutatingHandle<VC>) throws -> R) rethrows -> R
}

extension _UnsafeMutatingHandleBase {

  @inlinable
  mutating func __insert_node_at(_ __parent: _NodePtr, _ __child: _NodeRef, _ __new_node: _NodePtr)
  {
    _update { $0.__insert_node_at(__parent, __child, __new_node) }
  }

  @inlinable
  mutating func __remove_node_pointer(_ __ptr: _NodePtr) -> _NodePtr {
    _update { $0.__remove_node_pointer(__ptr) }
  }

}

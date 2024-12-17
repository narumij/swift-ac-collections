import Foundation
@testable import RedBlackTreeModule

@frozen
@usableFromInline
struct _UnsafeUpdateHandle<Element: Comparable> {

  @inlinable
  @inline(__always)
  init(
    __header_ptr: UnsafeMutablePointer<___RedBlackTree.___Header>,
    __node_ptr: UnsafeMutablePointer<___RedBlackTree.___Node>,
    __value_ptr: UnsafeMutablePointer<Element>
  ) {
    self.__header_ptr = __header_ptr
    self.__node_ptr = __node_ptr
    self.__value_ptr = __value_ptr
  }
  @usableFromInline
  let __header_ptr: UnsafeMutablePointer<___RedBlackTree.___Header>
  @usableFromInline
  let __node_ptr: UnsafeMutablePointer<___RedBlackTree.___Node>
  @usableFromInline
  let __value_ptr: UnsafeMutablePointer<Element>
}

extension _UnsafeUpdateHandle: UpdateHandleImpl {}
extension _UnsafeUpdateHandle: NodeFindProtocol & NodeFindEtcProtocol {
    @inlinable
    func value_comp(_ a: Element, _ b: Element) -> Bool {
        a < b
    }
}
extension _UnsafeUpdateHandle: NodeInsertProtocol {}
extension _UnsafeUpdateHandle: RemoveProtocol {}
